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
	size_t asmb_result = asmb(argv[1], n);
	printf("asmb:     %lu\n", asmb_result);
	size_t asmb_ref_result = asmb_ref(argv[1], n);
	printf("asmb_ref: %lu\n", asmb_ref_result);
	printf(asmb_ref_result == asmb_result ? "ok\n" : "fail\n");
	return 0;
}
