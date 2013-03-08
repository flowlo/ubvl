%{
#include "parser.h"
%}
%%
--.*$ ;
[ \n\t] ;

"end"		return T_END;
"array"		return T_ARRAY;
"of"		return T_OF;
"int"		return T_INT;
"return"	return T_RETURN;
"if"		return T_IF;
"then"		return T_THEN;
"else"		return T_ELSE;
"while"		return T_WHILE;
"do"		return T_DO;
"var"		return T_VAR;
"not"		return T_NOT;
"or"		return T_OR;
";"		return ';';
"("		return '(';
")"		return ')';
","		return ',';
":"		return ':';
":="		return T_ASSIGN;
"<"		return '<';
"#"		return '#';
"["		return '[';
"]"		return ']';
"-"		return '-';
"+"		return '+';
"*"		return '*';
[a-zA-Z][a-zA-Z0-9]* return T_ID; /* @{ @T_ID.name@ = strdup(yytext); @} */
[0-9]+ return T_NUM; /* @{ @T_NUM.val@ = atoi(yytext); @} */
\$[0-9a-fA-F]+ return T_NUM; /* @{ unsigned int hex; sscanf(yytext + 1, "%X", &hex); @T_NUM.val@ = hex; @} */
. printf("lexical error reading token: '%s'\n", yytext); exit(1);
