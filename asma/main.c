#include <stdio.h>

extern int asma(char*);

int asma_ref(char *s)
{
	int c = 0;
	int i;
	for (i = 0; i < 16; i++)
		if (s[i] == ' ')
			c++;

	return c;
}

int main(int argc, char** argv) {
	if (asma(argv[1]) == asma_ref(argv[1]))
		printf("ok\n");
	else
		printf(":(\n");
	return 0;
}
