ag: parser.o scanner.o symbols.o code.o tree.o
	gcc -Wall -o ag scanner.o parser.o symbols.o code.o tree.o -lfl

oxout.y oxout.l: parser.y scanner.l
	ox parser.y scanner.l

scanner.c: oxout.l
	flex -o scanner.c oxout.l

%.o: %.c
	gcc -Wall -c $*.c

parser.c: oxout.y
	bison -d -o parser.c oxout.y

code.c: code.bfe
	bfe < code.bfe | iburg > code.c

clean:
	rm -f oxout.l oxout.y scanner.c scanner.o parser.h parser.c parser.o parser code.c code.o symbols.o tree.o
