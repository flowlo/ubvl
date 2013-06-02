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

extern int yylineno;
extern int label;
extern int yyerror(const char*);
extern int yylex(void);
%}

%left  '+'  '-'
%left  '*'
%token T_ID T_NUM T_END T_ARRAY T_OF T_INT T_RETURN T_IF T_THEN T_ELSE T_WHILE T_DO T_VAR T_NOT T_OR T_ASSIGN
%start Program

@attributes { int value; }											T_NUM
@attributes { char *value; }											T_ID
@attributes { symbol_table *sym; }										Pars
@attributes { @autoinh symbol_table *sym; @autosyn ast_node *node; }						Args Bterm Bool
@attributes { @autoinh symbol_table *sym; @autoinh int labels; }						Stats
@attributes { @autoinh symbol_table *sym; symbol_table *out; @autoinh int labels; }				Stat
@attributes { symbol_dimensions dimensions; }									Type
@attributes { @autosyn char* value; @autosyn symbol_dimensions dimensions; }					Vardef
@attributes { @autoinh symbol_table *sym; @autosyn symbol_dimensions dimensions; @autosyn ast_node *node; }	Expr Term Lexpr Add Sub Mul

@traversal @preorder assert
@traversal @preorder code

@macro arithmetic(op,type,)
        @i @op.dimensions@ = @Term.0.dimensions@ + @Term.1.dimensions@;
	@i @op.0.node@ = node_new(type, @Term.0.node@, @Term.1.node@);
        @assert is_integer(@Term.0.dimensions@); is_integer(@Term.1.dimensions@);
@end

@macro arithmeticRecursive(op,type,)
        @i @op.0.dimensions@ = @op.1.dimensions@ + @Term.dimensions@;
	@i @op.0.node@ = node_new(type, @op.1.node@, @Term.node@);
        @assert is_integer(@op.1.dimensions@); is_integer(@Term.dimensions@);
@end

@macro boolean(type,)
	@i @Bterm.node@ = node_new(type, @Expr.0.node@, @Expr.1.node@);
	@assert is_integer(@Expr.0.dimensions@); is_integer(@Expr.1.dimensions@);
@end

%%
Program	:	Program Funcdef ';' | ;
Vardef	:	T_ID ':' Type
	;
Args	:	Expr 						@{ @i @Args.node@ = node_new(O_ARG, @Expr.node@, NULL); @}
	|	Args ',' Expr					@{ @i @Args.0.node@ = node_new(O_ARG, @Expr.node@, @Args.1.node@); @}
	;
Bool	:	Bterm | Bool T_OR Bterm				@{ @i @Bool.0.node@ = node_new(O_OR, @Bool.1.node@, @Bterm.node@); @}
	;
Bterm	:	'(' Bool ')'
	|	T_NOT Bterm					@{ @i @Bterm.0.node@ = node_new(O_NOT, @Bterm.1.node@, NULL); @}
	|	Expr '#' Expr					@{ boolean(O_NEQ,) @}
	|	Expr '<' Expr					@{ boolean(O_LT,) @}
	;
Expr    :       Term | Add | Sub | Mul ;
Add     :       Term '+' Term                                   @{ arithmetic(Add,O_ADD,) @}
        |       Add '+' Term                                    @{ arithmeticRecursive(Add,O_ADD,) @}
        ;
Sub     :       Term '-' Term                                   @{ arithmetic(Sub,O_SUB,) @}
        |       Sub '-' Term                                    @{ arithmeticRecursive(Sub,O_SUB,) @}
        ;
Mul     :       Term '*' Term
@{
	@i @Mul.dimensions@ = @Term.0.dimensions@ + @Term.1.dimensions@;
	@i @Mul.0.node@ = ((@Term.0.node@->is_imm && @Term.0.node@->value == 0) || (@Term.1.node@->is_imm && @Term.1.node@->value == 0)) ? node_new_num(0) :  node_new(O_MUL, @Term.0.node@, @Term.1.node@);
	@assert is_integer(@Term.0.dimensions@); is_integer(@Term.1.dimensions@);
@}
        |       Mul '*' Term                                    @{ arithmeticRecursive(Mul,O_MUL,) @}
        ;
Stat	:	T_RETURN Expr
@{
	@i @Stat.out@ = @Stat.sym@;

	@code
		burm_invoke(@Expr.node@);
		if (@Expr.node@->is_imm) {
			printi("movq $%ld, %%rax", @Expr.node@->value);
		} else if (strcmp(@Expr.node@->reg, "rax") != 0) {
			printi("movq %%%s, %%rax", @Expr.node@->reg);
		}
		printi("ret");
@}
	|	T_IF Bool T_THEN Stats T_END
@{
	@i @Stat.out@ = @Stat.sym@;
	@i @Stats.labels@ = @Stat.labels@ + 2;

	@code {
		label = @Stat.labels@;
		burm_invoke(@Bool.node@);
		printi("jmp L%ld", @Stat.labels@ + 1);
		printf("L%ld:\n", @Stat.labels@);
	}
	@code @revorder(1) {
		printf("L%ld:\n", @Stat.labels@ + 1);
	}
@}
	|	T_IF Bool T_THEN Stats T_ELSE Stats T_END
@{
	@i @Stat.out@ = @Stat.sym@;

	@code {
		burm_invoke(@Bool.node@);
		printf("# burm_invoke done!\n");
	}
	@code @revorder(1) {
		printf("# This is after everything.\n");
	}
@}
	|	T_WHILE Bool T_DO Stats T_END
@{
	@i @Stat.out@ = @Stat.sym@;
	@i @Stats.labels@ = @Stat.labels@ + 3;

	@code {
		printf("L%ld:\n", @Stat.labels@);
		label = @Stat.labels@ + 1;
		burm_invoke(@Bool.node@);
		printi("jmp L%ld", @Stat.labels@ + 2);
		printf("L%ld:\n", @Stat.labels@ + 1);
	}
	@code @revorder(1) {
		printi("jmp L%ld", @Stat.labels@);
		printf("L%ld:\n", @Stat.labels@ + 2);
	}
@}
	|	Term
@{
	@i @Stat.out@ = @Stat.sym@;
@}
	|	T_VAR Vardef T_ASSIGN Expr
@{
	@i @Stat.out@ = symbol_table_add_var(symbol_table_clone(@Stat.sym@), @Vardef.value@, @Vardef.dimensions@, false);

	@code burm_invoke(@Expr.node@);
	@assert same_dimensions(@Vardef.dimensions@, @Expr.dimensions@);
@}
	|	Lexpr T_ASSIGN Expr
@{
	@i @Stat.out@ = @Stat.sym@;

	@assert same_dimensions(@Lexpr.dimensions@, @Expr.dimensions@);

	@code burm_invoke(@Expr.node@);
@}
	;
Funcdef	:	T_ID '(' Pars ')' Stats T_END
@{
	@e Stats.sym : Pars.sym ; @Stats.sym@ = symbol_table_merge(@Pars.sym@, @Stats.sym@, true); reg_reset();
	@i @Stats.labels@ = 0;

	@code /* node_print(@Stats.node@, 2); */ funcdef(@T_ID.value@, @Pars.sym@);
@}
	|	T_ID '(' ')' Stats T_END
@{
	@i @Stats.sym@ = NULL; reg_reset();
	@i @Stats.labels@ = 0;

	@code //node_print(@Stats.node@, 2);
	funcdef(@T_ID.value@, NULL);
@}
	;
Type	:	T_INT						@{ @i @Type.dimensions@ = 0; @}
	|	T_ARRAY T_OF Type				@{ @i @Type.0.dimensions@ = @Type.1.dimensions@ + 1; @}
	;
Stats	:	Stat ';' Stats
@{
	@i @Stats.1.sym@ = @Stat.out@;
@}
	|
	;
Pars	:	Vardef 						@{ @i @Pars.sym@ = symbol_table_add_par(NULL, @Vardef.value@, @Vardef.dimensions@, true); @}
	|	Pars ',' Vardef					@{ @i @Pars.0.sym@ = symbol_table_add_par(@Pars.1.sym@, @Vardef.value@, @Vardef.dimensions@, true); @}
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
Term	:	'(' Expr ')'
	|	T_ID '(' Args ')' ':' Type			@{ @i @Term.node@ = node_new_call(@T_ID.value@, @Args.node@); @}
	|	T_ID '(' ')' ':' Type				@{ @i @Term.node@ = node_new_call(@T_ID.value@, NULL); @}
	|	T_NUM						@{ @i @Term.dimensions@ = 0; @i @Term.node@ = node_new_num(@T_NUM.value@); @}
	|	Term '[' Expr ']'
@{
	@i @Term.0.dimensions@ = @Term.1.dimensions@ - 1;
	@i @Term.0.node@ = node_new(O_ARRAY, @Term.1.node@, @Expr.node@);

	@assert is_array(@Term.1.dimensions@); is_integer(@Expr.dimensions@);
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
