.SECONDARY:

parser: parser.o scanner.o
	gcc -Wall -o parser scanner.o parser.o -lfl

%.o: %.c
	gcc -Wall -c $*.c

scanner.c: scanner.l
	flex -o scanner.c scanner.l

parser.c: parser.y
	bison -v -d -o parser.c parser.y

clean:
	rm -f scanner.c scanner.o parser.h parser.c parser.o parser parser.output
