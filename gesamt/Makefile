gesamt: parser.o scanner.o symbol_table.o code.o ast.o glue.o
	@gcc -Wall -o gesamt scanner.o parser.o symbol_table.o code.o ast.o glue.o -lfl

oxout.y oxout.l: parser.y scanner.l
	@ox parser.y scanner.l

scanner.c: oxout.l
	@flex -o scanner.c oxout.l

%.o: %.c
	@gcc -Wall -c -g $*.c

parser.c: oxout.y
	@bison -v -d -o parser.c oxout.y

code.c: code.bfe
	@bfe < code.bfe | iburg > code.c

clean:
	@rm -f oxout.l oxout.y scanner.c scanner.o parser.h parser.c parser.o gesamt code.c code.o symbol_table.o ast.o glue.o parser.output testgesamtout*
