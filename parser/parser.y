%{
#include <stdlib.h>
#include <stdio.h>
#define YYERROR_VERBOSE

extern int yylineno;

int yyerror(const char*);
%}

%token T_ID T_NUM T_END T_ARRAY T_OF T_INT T_RETURN T_IF T_THEN T_ELSE T_WHILE T_DO T_VAR T_NOT T_OR T_ASSIGN
%start Program

%%

Program	:	Program Funcdef ';'
	|
	;
Funcdef	:	T_ID '(' Pars ')' Stats T_END		/* Funktionsdefinition */
	;
Pars	:	Vardef					/* Parameterdefinition */
	|	Pars ',' Vardef
	|
	;
Vardef	:	T_ID ':' Type
	;
Type	:	T_INT
	|	T_ARRAY T_OF Type
	;
Stats	:	Stat ';' Stats
	|
	;
Stat	:	T_RETURN Expr
	|	T_IF Bool T_THEN Stats T_END
	|	T_IF Bool T_THEN Stats T_ELSE Stats T_END
	|	T_WHILE Bool T_DO Stats T_END
	|	T_VAR Vardef T_ASSIGN Expr		/* Variablendefinition */
	|	Lexpr T_ASSIGN Expr			/* Zuweisung */
	|	Term
	;
Bool	:	Bterm
	|	Bool T_OR Bterm
	;
Bterm	:	'(' Bool ')'
	|	T_NOT Bterm
	|	Expr '#' Expr
	|	Expr '<' Expr
	;
Lexpr	:	T_ID 					/* schreibender Variablenzugriff */
	|	Term '[' Expr ']' 			/* schreibender Arrayzugriff */
	;
Expr	:	Term
	|	Add
	|	Sub
	|	Mul
	;
Add	:	Term '+' Term
	|	Add '+' Term
	;
Sub	:	Term '-' Term
	|	Sub '-' Term
	;
Mul	:	Term '*' Term
	|	Mul '*'	Term
	;
Term	:	'(' Expr ')'
	|	T_NUM
	|	Term '[' Expr ']'			/* lesender Arrayzugriff */
	|	T_ID 					/* Variablenverwendung */
	|	T_ID '(' ')' ':' Type			/* Funktionsaufruf */
	|	T_ID '(' Args ')' ':' Type
	;
Args	:	Expr
	|	Args ',' Expr
	;
%%

int yyerror(const char *e) {
	printf("%s on line %d\n", e, yylineno);
	exit(2);
}

int main(int argc, char **argv) {
	return yyparse();
}
