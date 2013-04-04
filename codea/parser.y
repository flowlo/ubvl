%{
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "symbol_table.h"
#include "ast.h"
#include "glue.h"
#define YYERROR_VERBOSE

extern int yylineno;

int yyerror(const char*);
int yylex(void);
%}

%token T_ID T_NUM T_END T_ARRAY T_OF T_INT T_RETURN T_IF T_THEN T_ELSE T_WHILE T_DO T_VAR T_NOT T_OR T_ASSIGN
%start Program

@attributes { int value; }								T_NUM
@attributes { char *name; }								T_ID
@attributes { symbol_table *sym; ast_node* node; }					Stats Bterm Bool Args
@attributes { symbol_table *sym; }							Pars
@attributes { symbol_table *in; symbol_table *out; ast_node* node; }			Stat
@attributes { symbol_dimensions dimensions; }						Type
@attributes { char* name; symbol_dimensions dimensions; }				Vardef
@attributes { symbol_table *sym; symbol_dimensions dimensions; ast_node* node; }	Expr Term Lexpr

@traversal @postorder run
@traversal @postorder assert
@traversal @postorder code

%%

Program: Program Funcdef ';'
	|
;



Funcdef: T_ID '(' Pars ')' Stats T_END /* Funktionsdefinition */
	@{
		@i @Stats.sym@ = symbol_table_merge(@Pars.sym@, @Stats.sym@, true);
		@code node_print(@Stats.node@, 2); funcdef(@T_ID.name@, @Pars.sym@, @Stats.node@);
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
		@i @Stats.0.node@ = node_new(O_STATS, @Stat.node@, @Stats.1.node@);
	@}
	|
	@{
		@i @Stats.node@ = NULL;
	@}
;

Stat: T_RETURN Expr
	@{
		@i @Stat.out@ = @Stat.in@;
		@i @Expr.sym@ = @Stat.in@;
		@i @Stat.node@ = node_new(O_RETURN, @Expr.node@, NULL);

		@code @revorder(1) burm_label(@Stat.node@); /* burm_reduce(@Stat.node@, 1); */
	@}
	| T_IF Bool T_THEN Stats T_END
	@{
		@i @Stat.out@ = @Stat.in@;
		@i @Bool.sym@ = @Stat.in@;
		@i @Stats.sym@ = @Stat.in@;
		@i @Stat.node@ = node_new(O_IF, @Bool.node@, @Stats.node@);

		@code @revorder(1) burm_label(@Stat.node@); //burm_reduce(@Stat.node@, 1);
	@}
	| T_IF Bool T_THEN Stats T_ELSE Stats T_END
	@{
		@i @Stat.out@ = @Stat.in@;
		@i @Bool.sym@ = @Stat.in@;
		@i @Stats.0.sym@ = @Stat.in@;
		@i @Stats.1.sym@ = @Stat.in@;
		@i @Stat.node@ = node_new(O_IF, @Bool.node@, node_new(O_ELSE, @Stats.0.node@, @Stats.1.node@));
	@}
	| T_WHILE Bool T_DO Stats T_END
	@{
		@i @Stat.out@ = @Stat.in@;
		@i @Bool.sym@ = @Stat.in@;
		@i @Stats.sym@ = @Stat.in@;
		@i @Stat.node@ = node_new(O_WHILE, @Bool.node@, @Stats.node@);
	@}
	| T_VAR Vardef T_ASSIGN Expr /* Variablendefinition */
	@{
		@i @Stat.out@ = symbol_table_add(symbol_table_clone(@Stat.in@), @Vardef.name@, @Vardef.dimensions@, false);
		@i @Expr.sym@ = @Stat.in@;
		@i @Stat.node@ = node_new_definition(@Vardef.name@, @Expr.node@);

		@assert same_dimensions(@Vardef.dimensions@, @Expr.dimensions@);

		@code @revorder(1) burm_label(@Stat.node@); //burm_reduce(@Stat.node@, 1);
	@}
	| Lexpr T_ASSIGN Expr /* Zuweisung */
	@{
		@i @Stat.out@ = @Stat.in@;
		@i @Lexpr.sym@ = @Stat.in@;
		@i @Expr.sym@ = @Stat.in@;
		@i @Stat.node@ = node_new(O_ASSIGN, @Lexpr.node@, @Expr.node@);

		@assert same_dimensions(@Lexpr.dimensions@, @Expr.dimensions@);

		@code @revorder(1) burm_label(@Stat.node@); //burm_reduce(@Stat.node@, 1);
	@}
	| Term
	@{
		@i @Stat.out@ = @Stat.in@;
		@i @Term.sym@ = @Stat.in@;
		@i @Stat.node@ = NULL;
	@}
;

Bool: Bterm
	@{
		@i @Bterm.sym@ = @Bool.sym@;
		@i @Bool.node@ = @Bterm.node@;
	@}
	| Bool T_OR Bterm
	@{
		@i @Bool.1.sym@ = @Bool.0.sym@;
		@i @Bterm.sym@ = @Bool.0.sym@;
		@i @Bool.0.node@ = node_new(O_OR, @Bool.1.node@, @Bterm.node@);
	@}
;

Bterm: '(' Bool ')'
	@{
		@i @Bool.sym@ = @Bterm.sym@;
		@i @Bterm.node@ = @Bool.node@;
	@}
	| T_NOT Bterm
	@{
		@i @Bterm.1.sym@ = @Bterm.0.sym@;
		@i @Bterm.0.node@ = node_new(O_NOT, @Bterm.1.node@, NULL);
	@}
	| Expr '#' Expr
	@{
		@i @Expr.0.sym@ = @Bterm.sym@;
		@i @Expr.1.sym@ = @Bterm.sym@;
		@i @Bterm.node@ = node_new(O_NEQ, @Expr.0.node@, @Expr.1.node@);

		@assert is_integer(@Expr.0.dimensions@);
		@assert is_integer(@Expr.1.dimensions@);
	@}
	| Expr '<' Expr
	@{
		@i @Expr.0.sym@ = @Bterm.sym@;
		@i @Expr.1.sym@ = @Bterm.sym@;
		@i @Bterm.node@ = node_new(O_LT, @Expr.0.node@, @Expr.1.node@);

		@assert is_integer(@Expr.0.dimensions@);
		@assert is_integer(@Expr.1.dimensions@);
	@}
;

Lexpr: T_ID /* schreibender Variablenzugriff */
	@{
		@i @Lexpr.dimensions@ = -128;
		@i @Lexpr.node@ = node_new_id(@T_ID.name@);
		@run @Lexpr.dimensions@ = symbol_table_get_dimensions(@Lexpr.sym@, @T_ID.name@);

		@assert variable_exists(@Lexpr.sym@, @T_ID.name@);
	@}
	| Term '[' Expr ']' /* schreibender Arrayzugriff */
	@{
		@i @Lexpr.dimensions@ = -128;
		@i @Term.sym@ = @Lexpr.sym@;
		@i @Expr.sym@ = @Lexpr.sym@;
		@i @Lexpr.node@ = node_new(O_ARRAY, @Term.node@, @Expr.node@);

		@run @Lexpr.dimensions@ = @Term.dimensions@ - 1;

		@assert is_array(@Term.dimensions@);
		@assert is_integer(@Expr.dimensions@);
	@}
;

Expr: Term
	@{
		@i @Term.sym@ = @Expr.sym@;
		@i @Expr.dimensions@ = -128;
		@i @Expr.node@ = @Term.node@;

		@run @Expr.dimensions@ = @Term.dimensions@;
	@}
	| Expr '-' Term
	@{
		@i @Term.sym@ = @Expr.0.sym@;
		@i @Expr.1.sym@ = @Expr.0.sym@;
		@i @Expr.0.dimensions@ = 0;
		@i @Expr.0.node@ = node_new(O_SUB, @Expr.1.node@, @Term.node@);

		@assert is_integer(@Expr.dimensions@);
		@assert is_integer(@Term.dimensions@);

	@}
	| Expr '+' Term
	@{
		@i @Term.sym@ = @Expr.1.sym@;
		@i @Expr.1.sym@ = @Expr.0.sym@;
		@i @Expr.0.dimensions@ = 0;
		@i @Expr.0.node@ = node_new(O_ADD, @Expr.1.node@, @Term.node@);

		@assert is_integer(@Expr.dimensions@);
		@assert is_integer(@Term.dimensions@);
	@}
	| Expr '*' Term
	@{
		@i @Term.sym@ = @Expr.1.sym@;
		@i @Expr.1.sym@ = @Expr.0.sym@;
		@i @Expr.0.dimensions@ = 0;
		@i @Expr.0.node@ = node_new(O_MUL, @Expr.1.node@, @Term.node@);

		@assert is_integer(@Expr.dimensions@);
		@assert is_integer(@Term.dimensions@);
	@}
;

Term: '(' Expr ')'
	@{
		@i @Expr.sym@ = @Term.sym@;
		@i @Term.dimensions@ = -128;
		@i @Term.node@ = @Expr.node@;

		@run @Term.dimensions@ = @Expr.dimensions@;
	@}
	| T_NUM
	@{
		@i @Term.dimensions@ = 0;
		@i @Term.node@ = node_new_num(@T_NUM.value@);
	@}
	| Term '[' Expr ']' /* lesender Arrayzugriff */
	@{
		@i @Term.1.sym@ = @Term.0.sym@;
		@i @Expr.sym@ = @Term.0.sym@;
		@i @Term.0.dimensions@ = -128;
		@i @Term.node@ = node_new(O_ARRAY, @Term.node@, @Expr.node@);

		@run @Term.0.dimensions@ = @Term.1.dimensions@ - 1;
	@}
	| T_ID /* Variablenverwendung */
	@{
		@i @Term.dimensions@ = -128;
		@i @Term.node@ = node_new_id(@T_ID.name@);

		@run @Term.dimensions@ = symbol_table_get_dimensions(@Term.sym@, @T_ID.name@);

		@assert variable_exists(@Term.sym@, @T_ID.name@);
	@}
	| T_ID '(' ')' ':' Type /* Funktionsaufruf */
	@{
		@i @Term.dimensions@ = -128;
		@i @Term.node@ = node_new_call(@T_ID.name@, NULL);

		@run @Term.dimensions@ = @Type.dimensions@;
	@}
	| T_ID '(' Args ')' ':' Type
	@{
		@i @Args.sym@ = @Term.sym@;
		@i @Term.dimensions@ = -128;
		@i @Term.node@ = node_new_call(@T_ID.name@, @Args.node@);

		@run @Term.dimensions@ = @Type.dimensions@;
	@}
;

Args: Expr
	@{
		@i @Expr.sym@ = @Args.sym@;
		@i @Args.node@ = node_new(O_ARG, @Expr.node@, NULL);
	@}
	| Expr ',' Args
	@{
		@i @Expr.sym@ = @Args.sym@;
		@i @Args.1.sym@ = @Args.0.sym@;
		@i @Args.0.node@ = node_new(O_ARG, @Expr.node@, @Args.1.node@);
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
