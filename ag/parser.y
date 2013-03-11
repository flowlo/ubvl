%{
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "symbols.h"
#define YYERROR_VERBOSE

extern int yylineno;

int yyerror(const char*);
int yylex(void);
%}

%token T_ID T_NUM T_END T_ARRAY T_OF T_INT T_RETURN T_IF T_THEN T_ELSE T_WHILE T_DO T_VAR T_NOT T_OR T_ASSIGN
%start Program
%debug
%verbose
%locations

@attributes { int value; }						T_NUM
@attributes { char *name; }						T_ID
@attributes { symbol_table *vars; }					Pars Stats Stat Bterm Bool Args
@attributes { symbol_dimensions dimensions; }				Type
@attributes { char* name; symbol_dimensions dimensions; }		Vardef
@attributes { symbol_table *vars; symbol_dimensions dimensions; }	Expr Term Lexpr

@traversal @postorder run
@traversal @postorder assert

%%

Program: Funcdef ';'
	| Program Program
	|
;

Funcdef: T_ID '(' Pars ')' Stats T_END /* Funktionsdefinition */
	@{
		@i @Stats.vars@ = symbol_table_merge(@Pars.vars@, @Stats.vars@, true);
	@}
;

Pars: Vardef /* Parameterdefinition */
	@{
		@i @Pars.vars@ = symbol_table_add(NULL, @Vardef.name@, @Vardef.dimensions@, true);
	@}
	| Pars ',' Vardef
	@{
		@i @Pars.0.vars@ = symbol_table_add(@Pars.1.vars@, @Vardef.name@, @Vardef.dimensions@, true);
	@}
	|
	@{
		@i @Pars.vars@ = NULL;
	@}
;

Vardef: T_ID ':' Type
	@{
		@i @Vardef.name@ = @T_ID.name@;
		@i @Vardef.dimensions@ = @Type.dimensions@;
	@}
;

Type: T_INT
	@{
		@i @Type.dimensions@ = 0;
	@}
	| T_ARRAY T_OF Type
	@{
		@i @Type.0.dimensions@ = @Type.1.dimensions@ + 1;
	@}
;

Stats: Stat ';'
	@{
		@i @Stat.vars@ = @Stats.vars@;
	@}
	| Stats Stat ';'
	@{
		@i @Stats.1.vars@ = @Stats.0.vars@;
		@i @Stat.vars@ = @Stats.0.vars@;
	@}
	|
	@{
	@}
;

Stat: T_RETURN Expr
	@{
		@i @Expr.vars@ = @Stat.vars@;
	@}
	| T_IF Bool T_THEN Stats T_END
	@{
		@i @Bool.vars@ = @Stat.vars@;
		@i @Stats.vars@ = @Stat.vars@;
	@}
	| T_IF Bool T_THEN Stats T_ELSE Stats T_END
	@{
		@i @Bool.vars@ = @Stat.vars@;
		@i @Stats.0.vars@ = @Stat.vars@;
		@i @Stats.1.vars@ = @Stat.vars@;
	@}
	| T_WHILE Bool T_DO Stats T_END
	@{
		@i @Bool.vars@ = @Stat.vars@;
		@i @Stats.vars@ = @Stat.vars@;
	@}
	| T_VAR Vardef T_ASSIGN Expr		/* Variablendefinition */
	@{
		@i @Expr.vars@ = @Stat.vars@;

                @run @Stat.vars@ = symbol_table_add(@Stat.vars@, @Vardef.name@, @Vardef.dimensions@, true);
	@}
	| Lexpr T_ASSIGN Expr		/* Zuweisung */
	@{
		@i @Expr.vars@ = @Stat.vars@;
		@i @Lexpr.vars@ = @Stat.vars@;

		@assert same_dimensions(@Lexpr.dimensions@, @Expr.dimensions@);
	@}
	| Term
	@{
		@i @Term.vars@ = @Stat.vars@;
	@}
;

Bool: Bterm
	@{
		@i @Bterm.vars@ = @Bool.vars@;
	@}
	| Bool T_OR Bterm
	@{
		@i @Bool.1.vars@ = @Bool.0.vars@;
		@i @Bterm.vars@ = @Bool.0.vars@;
	@}
;

Bterm: '(' Bool ')'
	@{
		@i @Bool.vars@ = @Bterm.vars@;
	@}
	| T_NOT Bterm
	@{
		@i @Bterm.1.vars@ = @Bterm.0.vars@;
	@}
	| Expr '#' Expr
	@{
		@i @Expr.0.vars@ = @Bterm.vars@;
		@i @Expr.1.vars@ = @Bterm.vars@;

		@assert is_integer(@Expr.0.dimensions@);
		@assert is_integer(@Expr.1.dimensions@);
	@}
	| Expr '<' Expr
	@{
		@i @Expr.0.vars@ = @Bterm.vars@;
		@i @Expr.1.vars@ = @Bterm.vars@;

		@assert is_integer(@Expr.0.dimensions@);
		@assert is_integer(@Expr.1.dimensions@);
	@}
;

Lexpr: T_ID 				/* schreibender Variablenzugriff */
	@{
		@i @Lexpr.dimensions@ = -128;

		@run @Lexpr.dimensions@ = symbol_table_get_dimensions(@Lexpr.vars@, @T_ID.name@);

		@assert variable_exists(@Lexpr.vars@, @T_ID.name@);
	@}
	| Term '[' Expr ']' 		/* schreibender Arrayzugriff */
	@{
		@i @Lexpr.dimensions@ = -128;
		@i @Term.vars@ = @Lexpr.vars@;
		@i @Expr.vars@ = @Lexpr.vars@;

		@run @Lexpr.dimensions@ = @Term.dimensions@ - 1;

		@assert is_array(@Term.dimensions@);
		@assert is_integer(@Expr.dimensions@);
	@}
;

Expr: Term
	@{
		@i @Term.vars@ = @Expr.vars@;
		@i @Expr.dimensions@ = -128;

		@run @Expr.dimensions@ = @Term.dimensions@;
	@}
	| Expr '-' Term
	@{
		@i @Term.vars@ = @Expr.0.vars@;
		@i @Expr.1.vars@ = @Expr.0.vars@;
		@i @Expr.0.dimensions@ = 0;

		@assert is_integer(@Expr.dimensions@);
		@assert is_integer(@Term.dimensions@);

	@}
	| Expr '+' Term
	@{
		@i @Term.vars@ = @Expr.1.vars@;
		@i @Expr.1.vars@ = @Expr.0.vars@;
		@i @Expr.0.dimensions@ = 0;

		@assert is_integer(@Expr.dimensions@);
		@assert is_integer(@Term.dimensions@);
	@}
	| Expr '*' Term
	@{
		@i @Term.vars@ = @Expr.1.vars@;
		@i @Expr.1.vars@ = @Expr.0.vars@;
		@i @Expr.0.dimensions@ = 0;

		@assert is_integer(@Expr.dimensions@);
		@assert is_integer(@Term.dimensions@);
	@}
;

Term: '(' Expr ')'
	@{
		@i @Term.dimensions@ = -128;
		@i @Expr.vars@ = @Term.vars@;

		@run @Term.dimensions@ = @Expr.dimensions@;
	@}
	| T_NUM
	@{
		@i @Term.dimensions@ = 0;
	@}
	| Term '[' Expr ']'				/* lesender Arrayzugriff */
	@{
		@i @Term.1.vars@ = @Term.0.vars@;
		@i @Expr.vars@ = @Term.0.vars@;
		@i @Term.0.dimensions@ = -128;

		@run @Term.0.dimensions@ = @Term.1.dimensions@ - 1;
	@}
	| T_ID 						/* Variablenverwendung */
	@{
		@i @Term.dimensions@ = -128;

		@run @Term.dimensions@ = symbol_table_get_dimensions(@Term.vars@, @T_ID.name@);

		@assert variable_exists(@Term.vars@, @T_ID.name@);
	@}
	| T_ID '(' ')' ':' Type	/* Funktionsaufruf */
	@{
		@i @Term.dimensions@ = -128;

		@run @Term.dimensions@ = @Type.dimensions@;
	@}
	| T_ID '(' Args ')' ':' Type
	@{
		@i @Args.vars@ = @Term.vars@;
		@i @Term.dimensions@ = -128;

		@run @Term.dimensions@ = @Type.dimensions@;
	@}
;

Args: Expr
	@{
		@i @Expr.vars@ = @Args.vars@;
	@}
	| Args ',' Expr
	@{
		@i @Expr.vars@ = @Args.vars@;
		@i @Args.1.vars@ = @Args.0.vars@;
	@}
;

%%

int yyerror(const char *e) {
	printf("%s on line %d\n", e, yylineno);
	exit(2);
}

int main(int argc, char **argv) {
	yydebug = false;
	int result = yyparse();
	if (result == 0)
		printf("success!\n");
	return result;
}
