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
@attributes { @autoinh symbol_table *sym; symbol_table *out; ast_node *node; }					Stat
@attributes { symbol_dimensions dimensions; }									Type
@attributes { @autosyn char* value; @autosyn symbol_dimensions dimensions; }					Vardef
@attributes { @autoinh symbol_table *sym; @autosyn symbol_dimensions dimensions; @autosyn ast_node *node; }	Expr Term Add Sub Mul

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

%%
Program	:	Program Funcdef ';'
	|
	;
Vardef	:	T_ID ':' Type
	;
Expr    :       Term
        |       Add
        |       Sub
        |       Mul
        ;
Add     :       Term '+' Term                                   @{ arithmetic(Add,O_ADD,) @}
        |       Add '+' Term                                    @{ arithmeticRecursive(Add,O_ADD,) @}
        ;
Sub     :       Term '-' Term                                   @{ arithmetic(Sub,O_SUB,) @}
        |       Sub '-' Term                                    @{ arithmeticRecursive(Sub,O_SUB,) @}
        ;
Mul     :       Term '*' Term                                   @{ arithmetic(Mul,O_MUL,) @}
        |       Mul '*' Term                                    @{ arithmeticRecursive(Mul,O_MUL,) @}
        ;
Stat	:	T_RETURN Expr
@{
	@i @Stat.out@ = @Stat.sym@;
	@i @Stat.node@ = node_new(O_RETURN, @Expr.node@, NULL);

	@code burm_invoke(@Stat.node@);
@}
Funcdef	:	T_ID '(' Pars ')' Stat ';' T_END
@{
	@i @Stat.sym@ = @Pars.sym@; reg_reset();

	@code funcdef(@T_ID.value@, @Pars.sym@, @Stat.node@);
@}
	|	T_ID '(' ')' Stat ';'  T_END
@{
	@i @Stat.sym@ = NULL; reg_reset();

	@code funcdef(@T_ID.value@, NULL, @Stat.node@);
@}
	;
Type	:	T_INT						@{ @i @Type.dimensions@ = 0; @}
	|	T_ARRAY T_OF Type				@{ @i @Type.0.dimensions@ = @Type.1.dimensions@ + 1; @}
	;
Pars	:	Vardef 						@{ @i @Pars.sym@ = symbol_table_add_par(NULL, @Vardef.value@, @Vardef.dimensions@, true); @}
	|	Pars ',' Vardef					@{ @i @Pars.0.sym@ = symbol_table_add_par(@Pars.1.sym@, @Vardef.value@, @Vardef.dimensions@, true); @}
	;
Term	:	'(' Expr ')'
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
