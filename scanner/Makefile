scanner: scanner.c
	gcc -Wall -o scanner scanner.c -lfl

%.c: %.l
	flex -o $*.c $*.l

clean:
	rm -f scanner scanner.c
