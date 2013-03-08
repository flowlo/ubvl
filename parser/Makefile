parser: parser.o scanner.o
	gcc -Wall -o parser scanner.o parser.o -lfl

%.o: %.c
	gcc -Wall -c $*.c

scanner.c: scanner.lex parser.h
	flex -o scanner.c scanner.lex

%.c %.h: %.y
	bison -d -o $*.c $*.y

clean:
	rm -f scanner.c scanner.o parser.h parser.c parser.o parser
