%{
#ifndef DEBUG
#pragma GCC diagnostic ignored "-Wformat"
#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic ignored "-Wimplicit"
#pragma GCC diagnostic ignored "-Wparentheses"
#endif
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "symbol_table.h"
#include "ast.h"
#include "glue.h"

#define YYERROR_VERBOSE
#define burm_invoke(root) burm_label(root); burm_reduce(root, 1);

extern int yylineno;
extern int label;
extern int yyerror(const char*);
extern int yylex(void);

extern void burm_reduce(NODEPTR_TYPE bnode, int goalnt);
extern void burm_label(NODEPTR_TYPE p);
%}

%left  '+'  '-'
%left  '*'
%token T_ID T_NUM T_END T_ARRAY T_OF T_INT T_RETURN T_IF T_THEN T_ELSE T_WHILE T_DO T_VAR T_NOT T_OR T_ASSIGN
%start Program

@attributes { int value; }											T_NUM
@attributes { char *value; }											T_ID
@attributes { symbol_table *sym; }										Pars
@attributes { @autoinh symbol_table *sym; @autosyn ast_node *node; }						Args Bterm Bool Stats
@attributes { @autoinh symbol_table *sym; symbol_table *out; ast_node *node; }					Stat
@attributes { symbol_dimensions dimensions; }									Type
@attributes { @autosyn char* value; @autosyn symbol_dimensions dimensions; }					Vardef
@attributes { @autoinh symbol_table *sym; @autosyn symbol_dimensions dimensions; @autosyn ast_node *node; }	Expr Term Lexpr

@traversal @preorder assert
@traversal @preorder code

@macro arithmetic(type,)
	@i @Expr.0.dimensions@ = @Expr.1.dimensions@ + @Term.dimensions@;
	@i @Expr.0.node@ = node_new(type, @Expr.1.node@, @Term.node@);
	@assert is_integer(@Expr.dimensions@); is_integer(@Term.dimensions@);
@end

@macro boolean(type,)
	@i @Bterm.node@ = node_new(type, @Expr.0.node@, @Expr.1.node@);
	@assert is_integer(@Expr.0.dimensions@); is_integer(@Expr.1.dimensions@);
@end

%%
Program	:	Program Funcdef ';'
	|
	;
Vardef	:	T_ID ':' Type
	;
Args	:	Expr 						@{ @i @Args.node@ = node_new(O_ARG, @Expr.node@, NULL); @}
	|	Args ',' Expr					@{ @i @Args.0.node@ = node_new(O_ARG, @Expr.node@, @Args.1.node@); @}
	| 							@{ @i @Args.node@ = NULL; @}
	;
Bool	:	Bterm
	|	Bool T_OR Bterm 				@{ @i @Bool.0.node@ = node_new(O_OR, @Bool.1.node@, @Bterm.node@); @}
	;
Bterm	:	'(' Bool ')'
	|	T_NOT Bterm					@{ @i @Bterm.0.node@ = node_new(O_NOT, @Bterm.1.node@, NULL); @}
	|	Expr '#' Expr					@{ boolean(O_NEQ,) @}
	|	Expr '<' Expr					@{ boolean(O_LT,) @}
	;
Expr	:	Term
	|	Expr '-' Term					@{ arithmetic(O_SUB,) @}
	|	Expr '+' Term					@{ arithmetic(O_ADD,) @}
	|	Expr '*' Term					@{ arithmetic(O_MUL,) @}
	;
Stat	:	T_RETURN Expr
@{
	@i @Stat.out@ = @Stat.sym@;
	@i @Stat.node@ = node_new(O_RETURN, @Expr.node@, NULL);

	@code burm_invoke(@Stat.node@);
@}
	|	T_IF Bool T_THEN Stats T_END
@{
	@i @Stat.out@ = @Stat.sym@;
	@i @Stat.node@ = node_new(O_IF, @Stats.node@, @Bool.node@);

	@code /* burm_invoke(@Bool.node@); */ burm_invoke(@Stats.node@); printi("jmp _i_%lx", label);
	@code @revorder(1) printf("_i_%lx:\n", label);
@}
	|	T_IF Bool T_THEN Stats T_ELSE Stats T_END
@{
	@i @Stat.out@ = @Stat.sym@;

	@i @Stat.node@ = node_new_else(@Stats.0.node@, @Stats.1.node@, @Bool.node@);
/*	@code burm_invoke(@Stat.node@); printi("jmp %s", @Stats.0.node@->name);
	@code @revorder(1) printf("%s:\n", @Bool.node@->name);

	@i @Stat.node@ = node_new(O_IF, @Stats.1.node@, @Bool.node@);
	@code burm_invoke(@Stat.node@); @revorder(1) printf("huh?\n");
	@code @revorder(1) printi("jmp c"); printf("b%lx:\n", label++); 
	@code @revorder(1) printf("c:\n");
*/
@}
	|	T_WHILE Bool T_DO Stats T_END
@{
	@i @Stat.out@ = @Stat.sym@;
	@i @Stat.node@ = node_new(O_WHILE, @Bool.node@, @Stats.node@);
@}
	|	Term
@{
	@i @Stat.out@ = @Stat.sym@;
	@i @Stat.node@ = NULL;
@}
	|	T_VAR Vardef T_ASSIGN Expr
@{
	@i @Stat.out@ = symbol_table_add_var(symbol_table_clone(@Stat.sym@), @Vardef.value@, @Vardef.dimensions@, false);
	@i @Stat.node@ = node_new_definition(@Vardef.value@, @Stat.out@, @Expr.node@);

	@code burm_invoke(@Stat.node@);
	@assert same_dimensions(@Vardef.dimensions@, @Expr.dimensions@);
@}
	|	Lexpr T_ASSIGN Expr
@{
	@i @Stat.out@ = @Stat.sym@;
	@i @Stat.node@ = node_new(O_ASSIGN, @Lexpr.node@, @Expr.node@);

	@assert same_dimensions(@Lexpr.dimensions@, @Expr.dimensions@);

	@code burm_invoke(@Stat.node@);
@}
	;
Funcdef	:	T_ID '(' Pars ')' Stats T_END
@{
	@e Stats.sym : Pars.sym ; @Stats.sym@ = symbol_table_merge(@Pars.sym@, @Stats.sym@, true);

	@code reg_reset_all(); //node_print(@Stats.node@, 2);
	funcdef(@T_ID.value@, @Pars.sym@, @Stats.node@);
@}
	;
Type	:	T_INT						@{ @i @Type.dimensions@ = 0; @}
	|	T_ARRAY T_OF Type				@{ @i @Type.0.dimensions@ = @Type.1.dimensions@ + 1; @}
	;
Stats	:	Stat ';' Stats
@{
	@i @Stats.1.sym@ = @Stat.out@;
	@i @Stats.0.node@ = node_new(O_STATS, @Stat.node@, @Stats.1.node@);
	@code burm_invoke(@Stats.0.node@);
@}
	|
@{
	@i @Stats.node@ = node_new(O_STATS, NULL, NULL);
@}
	;
Pars	:	Vardef 						@{ @i @Pars.sym@ = symbol_table_add_par(NULL, @Vardef.value@, @Vardef.dimensions@, true); @}
	|	Pars ',' Vardef					@{ @i @Pars.0.sym@ = symbol_table_add_par(@Pars.1.sym@, @Vardef.value@, @Vardef.dimensions@, true); @}
	|							@{ @i @Pars.sym@ = NULL; @}
	;

Lexpr	:	T_ID
@{
	@i @Lexpr.dimensions@ = symbol_table_get_dimensions(@Lexpr.sym@, @T_ID.value@);
	@i @Lexpr.node@ = node_new_id(@T_ID.value@, @Lexpr.sym@);
@}
	|	Term '[' Expr ']'
@{
	@i @Lexpr.dimensions@ = @Term.dimensions@ - 1;
	@i @Lexpr.node@ = node_new(O_ARRAY, @Term.node@, @Expr.node@);
	@assert is_array(@Term.dimensions@); is_integer(@Expr.dimensions@);
@}
	;
Term	:	'(' Expr ')' | T_ID '(' Args ')' ':' Type	@{ @i @Term.node@ = node_new_call(@T_ID.value@, @Args.node@); @}
	|	T_NUM						@{ @i @Term.dimensions@ = 0; @i @Term.node@ = node_new_num(@T_NUM.value@); @}
	|	Term '[' Expr ']'
@{
	@i @Term.0.dimensions@ = @Term.1.dimensions@ - 1;
	@i @Term.0.node@ = node_new(O_ARRAY, @Term.1.node@, @Expr.node@);
@}
	|	T_ID
@{
	@i @Term.dimensions@ = symbol_table_get_dimensions(@Term.sym@, @T_ID.value@);
	@i @Term.node@ = node_new_id(@T_ID.value@, @Term.sym@);
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
