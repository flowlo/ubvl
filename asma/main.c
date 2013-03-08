#include <stdio.h>

int asma(char *s) {
	int c = 0, i;
	for (i = 0; i < 16; i++)
		if (s[i] == ' ')
			c++;
	return c;
}

int main(int argc, char** argv) {
	printf("%d\n", asma("Das sind 3 Abstaende."));
}
