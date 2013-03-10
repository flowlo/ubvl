#include <stdlib.h>

extern int asma(char*);

int main(int argc, char** argv) {
	exit(asma(argv[0]));
}
