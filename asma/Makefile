asma.o:
	gcc -g -c asma.s

main.o:
	gcc -g -c main.c

debug: asma.o main.o
	gcc -g -Wall asma.o main.o -o asma

clean:
	rm -f asma.o main.o asma
