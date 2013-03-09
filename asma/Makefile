asma.o: asma.s
	gcc -g -c asma.s

main.o: main.c
	gcc -g -c main.c

debug: asma.o main.o
	gcc -g -Wall asma.o main.o -o asma

clean:
	rm -f asma.o main.o asma
