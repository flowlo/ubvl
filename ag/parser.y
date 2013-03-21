%{
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "symbol_table.h"
#define YYERROR_VERBOSE

extern int yylineno;

int yyerror(const char*);
int yylex(void);
%}

%token T_ID T_NUM T_END T_ARRAY T_OF T_INT T_RETURN T_IF T_THEN T_ELSE T_WHILE T_DO T_VAR T_NOT T_OR T_ASSIGN
%start Program

@attributes { int value; }						T_NUM
@attributes { char *name; }						T_ID
@attributes { symbol_table *sym; }					Pars Stats Bterm Bool Args
@attributes { symbol_table *in; symbol_table *out; }			Stat
@attributes { symbol_dimensions dimensions; }				Type
@attributes { char* name; symbol_dimensions dimensions; }		Vardef
@attributes { symbol_table *sym; symbol_dimensions dimensions; }	Expr Term Lexpr

@traversal @postorder run
@traversal @postorder assert

%%

Program:
	| Program Funcdef ';'
;

Funcdef: T_ID '(' Pars ')' Stats T_END /* Funktionsdefinition */
	@{
		@i @Stats.sym@ = symbol_table_merge(@Pars.sym@, @Stats.sym@, true);
	@}
;

Pars: Vardef /* Parameterdefinition */
	@{
		@i @Pars.sym@ = symbol_table_add(NULL, @Vardef.name@, @Vardef.dimensions@, true);
	@}
	| Pars ',' Vardef
	@{
		@i @Pars.0.sym@ = symbol_table_add(@Pars.1.sym@, @Vardef.name@, @Vardef.dimensions@, true);
	@}
	|
	@{
		@i @Pars.sym@ = NULL;
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

Stats: Stat ';' Stats
	@{
		@i @Stat.in@ = @Stats.0.sym@;
		@i @Stats.1.sym@ = @Stat.out@;
	@}
	|
	@{
	@}
;

Stat: T_RETURN Expr
	@{
		@i @Stat.out@ = @Stat.in@;
		@i @Expr.sym@ = @Stat.in@;
	@}
	| T_IF Bool T_THEN Stats T_END
	@{
		@i @Stat.out@ = @Stat.in@;
		@i @Bool.sym@ = @Stat.in@;
		@i @Stats.sym@ = @Stat.in@;
	@}
	| T_IF Bool T_THEN Stats T_ELSE Stats T_END
	@{
		@i @Stat.out@ = @Stat.in@;
		@i @Bool.sym@ = @Stat.in@;
		@i @Stats.0.sym@ = @Stat.in@;
		@i @Stats.1.sym@ = @Stat.in@;
	@}
	| T_WHILE Bool T_DO Stats T_END
	@{
		@i @Stat.out@ = @Stat.in@;
		@i @Bool.sym@ = @Stat.in@;
		@i @Stats.sym@ = @Stat.in@;
	@}
	| T_VAR Vardef T_ASSIGN Expr /* Variablendefinition */
	@{
		@i @Stat.out@ = symbol_table_add(symbol_table_clone(@Stat.in@), @Vardef.name@, @Vardef.dimensions@, false);
		@i @Expr.sym@ = @Stat.in@;

		@assert same_dimensions(@Vardef.dimensions@, @Expr.dimensions@);
	@}
	| Lexpr T_ASSIGN Expr /* Zuweisung */
	@{
		@i @Stat.out@ = @Stat.in@;
		@i @Lexpr.sym@ = @Stat.in@;
		@i @Expr.sym@ = @Stat.in@;

		@assert same_dimensions(@Lexpr.dimensions@, @Expr.dimensions@);
	@}
	| Term
	@{
		@i @Stat.out@ = @Stat.in@;
		@i @Term.sym@ = @Stat.in@;
	@}
;

Bool: Bterm
	@{
		@i @Bterm.sym@ = @Bool.sym@;
	@}
	| Bool T_OR Bterm
	@{
		@i @Bool.1.sym@ = @Bool.0.sym@;
		@i @Bterm.sym@ = @Bool.0.sym@;
	@}
;

Bterm: '(' Bool ')'
	@{
		@i @Bool.sym@ = @Bterm.sym@;
	@}
	| T_NOT Bterm
	@{
		@i @Bterm.1.sym@ = @Bterm.0.sym@;
	@}
	| Expr '#' Expr
	@{
		@i @Expr.0.sym@ = @Bterm.sym@;
		@i @Expr.1.sym@ = @Bterm.sym@;

		@assert is_integer(@Expr.0.dimensions@);
		@assert is_integer(@Expr.1.dimensions@);
	@}
	| Expr '<' Expr
	@{
		@i @Expr.0.sym@ = @Bterm.sym@;
		@i @Expr.1.sym@ = @Bterm.sym@;

		@assert is_integer(@Expr.0.dimensions@);
		@assert is_integer(@Expr.1.dimensions@);
	@}
;

Lexpr: T_ID /* schreibender Variablenzugriff */
	@{
		@i @Lexpr.dimensions@ = -128;

		@run @Lexpr.dimensions@ = symbol_table_get_dimensions(@Lexpr.sym@, @T_ID.name@);

		@assert variable_exists(@Lexpr.sym@, @T_ID.name@);
	@}
	| Term '[' Expr ']' /* schreibender Arrayzugriff */
	@{
		@i @Lexpr.dimensions@ = -128;
		@i @Term.sym@ = @Lexpr.sym@;
		@i @Expr.sym@ = @Lexpr.sym@;

		@run @Lexpr.dimensions@ = @Term.dimensions@ - 1;

		@assert is_array(@Term.dimensions@);
		@assert is_integer(@Expr.dimensions@);
	@}
;

Expr: Term
	@{
		@i @Term.sym@ = @Expr.sym@;
		@i @Expr.dimensions@ = -128;

		@run @Expr.dimensions@ = @Term.dimensions@;
	@}
	| Expr '-' Term
	@{
		@i @Term.sym@ = @Expr.0.sym@;
		@i @Expr.1.sym@ = @Expr.0.sym@;
		@i @Expr.0.dimensions@ = 0;

		@assert is_integer(@Expr.dimensions@);
		@assert is_integer(@Term.dimensions@);

	@}
	| Expr '+' Term
	@{
		@i @Term.sym@ = @Expr.1.sym@;
		@i @Expr.1.sym@ = @Expr.0.sym@;
		@i @Expr.0.dimensions@ = 0;

		@assert is_integer(@Expr.dimensions@);
		@assert is_integer(@Term.dimensions@);
	@}
	| Expr '*' Term
	@{
		@i @Term.sym@ = @Expr.1.sym@;
		@i @Expr.1.sym@ = @Expr.0.sym@;
		@i @Expr.0.dimensions@ = 0;

		@assert is_integer(@Expr.dimensions@);
		@assert is_integer(@Term.dimensions@);
	@}
;

Term: '(' Expr ')'
	@{
		@i @Expr.sym@ = @Term.sym@;
		@i @Term.dimensions@ = -128;

		@run @Term.dimensions@ = @Expr.dimensions@;
	@}
	| T_NUM
	@{
		@i @Term.dimensions@ = 0;
	@}
	| Term '[' Expr ']' /* lesender Arrayzugriff */
	@{
		@i @Term.1.sym@ = @Term.0.sym@;
		@i @Expr.sym@ = @Term.0.sym@;
		@i @Term.0.dimensions@ = -128;

		@run @Term.0.dimensions@ = @Term.1.dimensions@ - 1;
	@}
	| T_ID /* Variablenverwendung */
	@{
		@i @Term.dimensions@ = -128;

		@run @Term.dimensions@ = symbol_table_get_dimensions(@Term.sym@, @T_ID.name@);

		@assert variable_exists(@Term.sym@, @T_ID.name@);
	@}
	| T_ID '(' ')' ':' Type /* Funktionsaufruf */
	@{
		@i @Term.dimensions@ = -128;

		@run @Term.dimensions@ = @Type.dimensions@;
	@}
	| T_ID '(' Args ')' ':' Type
	@{
		@i @Args.sym@ = @Term.sym@;
		@i @Term.dimensions@ = -128;

		@run @Term.dimensions@ = @Type.dimensions@;
	@}
;

Args: Expr
	@{
		@i @Expr.sym@ = @Args.sym@;
	@}
	| Args ',' Expr
	@{
		@i @Expr.sym@ = @Args.sym@;
		@i @Args.1.sym@ = @Args.0.sym@;
	@}
;

%%

int yyerror(const char *e) {
	printf("%s on line %d\n", e, yylineno);
	exit(2);
}

int main(int argc, char **argv) {
	return yyparse();
}
