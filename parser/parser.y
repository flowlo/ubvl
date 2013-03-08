%{
#include <stdlib.h>
#include <stdio.h>
#define YYERROR_VERBOSE
int yyerror(const char*);
%}

%token T_ID T_NUM T_END T_ARRAY T_OF T_INT T_RETURN T_IF T_THEN T_ELSE T_WHILE T_DO T_VAR T_NOT T_OR T_ASSIGN
%start Program

%%

Program: Funcdef ';'
	| Program Program
	|
;

Funcdef: T_ID '(' Pars ')' Stats T_END /* Funktionsdefinition */
;

Pars: Vardef /* Parameterdefinition */
	| Pars ',' Vardef
	|
;

Vardef: T_ID ':' Type
;

Type: T_ARRAY T_OF T_INT
	| T_INT
;

Stats: Stat ';'
	| Stats Stat ';'
	|
;

Stat: T_RETURN Expr
	| T_IF Bool T_THEN Stats T_END
	| T_IF Bool T_THEN Stats T_ELSE Stats T_END
	| T_WHILE Bool T_DO Stats T_END
	| T_VAR Vardef T_ASSIGN Expr		/* Variablendefinition */
	| Lexpr T_ASSIGN Expr		/* Zuweisung */
	| Term
;

Bool: Bterm
	| Bool T_OR Bterm
;

Bterm: '(' Bool ')'
	| T_NOT Bterm
	| Expr '#' Expr
	| Expr '<' Expr
;

Lexpr: T_ID 				/* schreibender Variablenzugriff */
	| Term '[' Expr ']' 		/* schreibender Arrayzugriff */
;

Expr: Term
	| Expr '-' Term
	| Expr '+' Term
	| Expr '*' Term
;

Term: '(' Expr ')'
	| T_NUM
	| Term '[' Expr ']'				/* lesender Arrayzugriff */
	| T_ID 						/* Variablenverwendung */
	| T_ID '(' ')' ':' Type	/* Funktionsaufruf */
	| T_ID '(' Parlist ')' ':' Type
;

Parlist: Expr
	| Parlist ',' Expr
;

%%

extern int yylineno;

int yyerror(const char *e) {
	printf("parser error '%s' on line %d\n", e, yylineno);
	exit(2);
}

int main(int argc, char **argv) {
	return yyparse();
}
