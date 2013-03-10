%option nounput
%option noinput
%option noyywrap

%{
#include "parser.h"
%}

%%

--.*$				;
[ \n\t]				;

"end"				return T_END;
"array"				return T_ARRAY;
"of"				return T_OF;
"int"				return T_INT;
"return"			return T_RETURN;
"if"				return T_IF;
"then"				return T_THEN;
"else"				return T_ELSE;
"while"				return T_WHILE;
"do"				return T_DO;
"var"				return T_VAR;
"not"				return T_NOT;
"or"				return T_OR;
":="				return T_ASSIGN;
[0-9]+				return T_NUM;
\$[0-9a-fA-F]+			return T_NUM;
[a-zA-Z][a-zA-Z0-9]*		return T_ID;

(;|\(|\)|,|:|<|#|\[|\]|-|\+|\*)	return yytext[0];

. printf("lexical error reading token: '%s'\n", yytext); exit(1);
