#include <stdlib.h>
#include <string.h>
#include <stdio.h>

extern size_t asmb(char*, size_t);

size_t asmb_ref(char *s, size_t n)
{
	size_t c = 0;
	size_t i;

	for (i = 0; i < n; i++)
		if (s[i] == ' ')
			c++;

	return c;
}

int main(int argc, char** argv) {
	size_t n = strlen(argv[1]);
	if (asmb(argv[1], n) == asmb_ref(argv[1], n))
		printf("ok\n");
	else
		printf(":(\n");
	return 0;
}
