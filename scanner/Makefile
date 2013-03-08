scanner: scanner.c
	gcc -Wall -o scanner scanner.c -lfl

%.c: %.lex
	flex -o $*.c $*.lex

clean:
	rm -f scanner scanner.c
