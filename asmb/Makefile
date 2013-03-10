asmb.o: asmb.s
	gcc -g -c asmb.s

main.o: main.c
	gcc -g -c main.c

debug: asmb.o main.o
	gcc -g -Wall asmb.o main.o -o asmb

clean:
	rm -f asmb.o main.o asmb
