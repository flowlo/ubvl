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
#define YYERROR_VERBOSE

extern int yylineno;
int yyerror(const char*);
int yylex(void);
%}

%token T_ID T_NUM T_END T_ARRAY T_OF T_INT T_RETURN T_IF T_THEN T_ELSE T_WHILE T_DO T_VAR T_NOT T_OR T_ASSIGN
%start Program

@attributes { int value; }								T_NUM
@attributes { char *value; }								T_ID
@attributes { symbol_table *sym; }							Pars
@attributes { @autoinh symbol_table *sym; }						Args Bterm Bool Stats
@attributes { @autoinh symbol_table *sym; symbol_table *out; }				Stat
@attributes { symbol_dimensions dimensions; }						Type
@attributes { @autosyn char* value; @autosyn symbol_dimensions dimensions; }		Vardef
@attributes { @autoinh symbol_table *sym; @autosyn symbol_dimensions dimensions; }	Expr Term Lexpr

@traversal @preorder assert

@macro arithmetic()
	@i @Expr.0.dimensions@ = @Expr.dimensions@ + @Term.dimensions@;
	@assert is_integer(@Expr.dimensions@); is_integer(@Term.dimensions@);
@end

@macro boolean()
	@assert is_integer(@Expr.0.dimensions@); is_integer(@Expr.1.dimensions@);
@end
%%

Vardef: T_ID ':' Type ;
Args:	Expr | Args ',' Expr | ;
Bool:	Bterm | Bool T_OR Bterm ;
Program:Program Funcdef ';' | ;
Bterm: '(' Bool ')' | T_NOT Bterm | Expr '#' Expr @{ boolean() @} | Expr '<' Expr @{ boolean() @} ;
Expr:	Term | Expr '-' Term @{ arithmetic() @} | Expr '+' Term @{ arithmetic() @} | Expr '*' Term @{ arithmetic() @} ;

Stat:	T_RETURN Expr					@{ @i @Stat.out@ = @Stat.sym@; @}
|	T_IF Bool T_THEN Stats T_END			@{ @i @Stat.out@ = @Stat.sym@; @}
|	T_IF Bool T_THEN Stats T_ELSE Stats T_END	@{ @i @Stat.out@ = @Stat.sym@; @}
|	T_WHILE Bool T_DO Stats T_END			@{ @i @Stat.out@ = @Stat.sym@; @}
|	Term						@{ @i @Stat.out@ = @Stat.sym@; @}
|	T_VAR Vardef T_ASSIGN Expr
@{
	@i @Stat.out@ = symbol_table_add(symbol_table_clone(@Stat.sym@), @Vardef.value@, @Vardef.dimensions@, false);
	@assert same_dimensions(@Vardef.dimensions@, @Expr.dimensions@);
@}
|	Lexpr T_ASSIGN Expr
@{
	@i @Stat.out@ = @Stat.sym@;
	@assert same_dimensions(@Lexpr.dimensions@, @Expr.dimensions@);
@} ;

Funcdef:T_ID '(' Pars ')' Stats T_END			@{ @i @Stats.sym@ = symbol_table_merge(@Pars.sym@, @Stats.sym@, true); @};

Type:	T_INT						@{ @i @Type.dimensions@ = 0; @}
|	T_ARRAY T_OF Type				@{ @i @Type.0.dimensions@ = @Type.1.dimensions@ + 1; @} ;

Stats:	Stat ';' Stats					@{ @i @Stats.1.sym@ = @Stat.out@; @}
|	;

Pars:	Vardef 						@{ @i @Pars.sym@ = symbol_table_add(NULL, @Vardef.value@, @Vardef.dimensions@, true); @}
|	Pars ',' Vardef					@{ @i @Pars.0.sym@ = symbol_table_add(@Pars.1.sym@, @Vardef.value@, @Vardef.dimensions@, true); @}
|							@{ @i @Pars.sym@ = NULL; @} ;

Lexpr:	T_ID						@{ @i @Lexpr.dimensions@ = symbol_table_get_dimensions(@Lexpr.sym@, @T_ID.value@);  @}
|	Term '[' Expr ']'
@{
	@i @Lexpr.dimensions@ = @Term.dimensions@ - 1;
	@assert is_array(@Term.dimensions@); is_integer(@Expr.dimensions@);
@} ;

Term:	'(' Expr ')' | T_ID '(' Args ')' ':' Type
|	T_NUM						@{ @i @Term.dimensions@ = 0; @}
|	Term '[' Expr ']' 				@{ @i @Term.0.dimensions@ = @Term.1.dimensions@ - 1; @}
|	T_ID						@{ @i @Term.dimensions@ = symbol_table_get_dimensions(@Term.sym@, @T_ID.value@);  @} ;

%%

int yyerror(const char *e) {
	printf("%s on line %d\n", e, yylineno);
	exit(2);
}

int main(int argc, char **argv) {
	return yyparse();
}
