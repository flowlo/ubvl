asmb.o: asmb.s
	gcc -g -c asmb.s

main.o: main.c
	gcc -g -c main.c

callingconvention.o: callingconvention.c
	gcc -g -fomit-frame-pointer -fno-defer-pop -c callingconvention.c

debug: asmb.o main.o callingconvention.o
	gcc -g -Wall asmb.o main.o callingconvention.o -o asmb

clean:
	rm -f asmb.o main.o callingconvention.o asmb
