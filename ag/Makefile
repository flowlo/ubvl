ag: parser.o scanner.o symbol_table.o
	gcc -Wall -o ag scanner.o parser.o symbol_table.o -lfl

oxout.y oxout.l: parser.y scanner.l
	ox parser.y scanner.l

scanner.c: oxout.l
	flex -o scanner.c oxout.l

%.o: %.c
	gcc -Wall -c $*.c

parser.c: oxout.y
	bison -v -d -o parser.c oxout.y

clean:
	rm -f oxout.l oxout.y scanner.c scanner.o parser.h parser.c parser.o parser symbol_table.o parser.output
