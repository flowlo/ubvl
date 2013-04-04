%option nounput
%option noinput
%option noyywrap

%{
#include <stdlib.h>
#include <string.h>
#include "parser.h"
#include "symbol_table.h"

extern int yylineno;
%}

%%

--.*				;
[ \t]				;
"\n"				yylineno++;
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
[0-9]+				return T_NUM; @{ @T_NUM.value@ = atol(yytext); @}
\$[0-9a-fA-F]+			return T_NUM; @{ unsigned long hex; sscanf(yytext + 1, "%lx", &hex); @T_NUM.value@ = hex; @}
[a-zA-Z][a-zA-Z0-9]*		return T_ID;  @{ @T_ID.name@ = strdup(yytext); @}

%{
/* This is pretty lame, but return yytext[0] bothers ox. */
%}
";"				return ';';
"("				return '(';
")"				return ')';
","				return ',';
":"				return ':';
"<"				return '<';
"#"				return '#';
"["				return '[';
"]"				return ']';
"-"				return '-';
"+"				return '+';
"*"				return '*';

. printf("Lexical error reading token '%s' on line %d.\n", yytext, yylineno); exit(1);
