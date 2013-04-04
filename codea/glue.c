#include "glue.h"

char vars[9][4]= { "rax", "r10", "r11", "r9", "r8", "rcx", "rdx", "rsi", "rdi" };
char pars[9][4]= { "rdi", "rsi", "rdx", "rcx", "r8", "r9" };
const int usage[9] = { 0, 0, 0, 0, 0, 0, 0, 0, 0 };

void funcdef(char *name, symbol_table *table, ast_node *node) {
	return;
}
