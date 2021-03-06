%option nounput
%option noinput
%option noyywrap

%{
extern int yylineno;
%}

%%

--.*		;
[ \t]		;
"\n"		yylineno++;
[0-9]+		printf("num %x\n", atoi(yytext));

(end|array|of|int|return|if|then|else|while|do|var|not|or|;|\(|\)|,|:|:=|<|#|\[|\]|-|\+|\*) {
	printf("%s\n", yytext);
}

[a-zA-Z][a-zA-Z0-9]* {
	printf("id %s\n", yytext);
}

\$[0-9a-fA-F]+ {
	unsigned int hex;
	sscanf(yytext + 1, "%X", &hex);
	printf("num %x\n", hex);
}

. {
	printf("Lexical error reading token '%s' on line %d.\n", yytext, yylineno);
	return 1;
}

%%

int main(int argc, char **argv) {
	return yylex();
}
