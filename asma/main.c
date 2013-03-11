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
	int asma_result = asma(argv[1]);
	printf("asma:     %d\n", asma_result);
	int asma_ref_result = asma_ref(argv[1]);
	printf("asma_ref: %d\n", asma_ref_result);
	printf(asma_ref_result == asma_result ? "ok\n" : "fail\n");
	return 0;
}
