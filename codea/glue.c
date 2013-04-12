#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "glue.h"

char vars[9][4]= { "rax", "r10", "r11", "r9", "r8", "rcx", "rdx", "rsi", "rdi" };
char pars[6][4]= { "rdi", "rsi", "rdx", "rcx", "r8", "r9" };
static int var_usage[9] = { 0, 0, 0, 0, 0, 0, 0, 0, 0 };
int par_usage[6] = { 0, 0, 0, 0, 0, 0 };

void print_var_usage() {
	int i;
	for (i = 0; i < 9; i++)
		printf("%s: %d  ", vars[i], var_usage[i]);
	
	printf("\n");
}

void reg_reset_all() {
reg_reset();
}

void funcdef(char *name, symbol_table *table, ast_node *node) {
	printf(".globl %1$s\n.type %1$s, @function\n%1$s:\n", name);

//	symbol_table_print(table);

//	reg_reset(); TODO ?!?!

	int i;
	symbol_table *element;
	for (i = 5, element = table; i > -1 && element != NULL; i--, element = element->next) {
		element->reg = strdup(pars[i]);
	}

	return;
}

char *binary(char *op, char *first, char *second, bool commutative) {
	bool first_is_par = is_par(first), second_is_par = is_par(second);
	char *reg;

	if (first_is_par && second_is_par) {
		reg = reg_new_var();
		printi("movq %%%s, %%%s", first, reg);
		printi("%s %%%s, %%%s", op, second, reg);
	} else if (!first_is_par && !second_is_par) {
		reg = first;
		printi("%s %%%s, %%%s", op, first, second);
		reg_free(second);
	} else if (first_is_par && !second_is_par) {
		reg = second;
		printi("%s %%%s, %%%s", op, first, second);
	} else if (commutative) {
		reg = first;
		printi("%s %%%s, %%%s", op, second, first);
	} else {
		fprintf(stderr, "Failed to arrange for \"%s %%%s, %%%s\"!", op, first, second);
		exit(4);
	}

	return reg;
}

char *reg_new_var(void) {
	int i = 0;
	for (i = 0; i < 9; i++)
		if (var_usage[i] == 0) {
			var_usage[i]++;
			return strdup(vars[i]);
		}

	fprintf(stderr, "Not enough variable registers!");
	exit(4);
}

char *reg_new_par(void) {
	int i = 0;
	for (i = 0; i < 9; i++)
		if (par_usage[i] == 0) {
			par_usage[i]++;
			return strdup(pars[i]);
		}

	fprintf(stderr, "Not enough parameter registers!");
	exit(4);
}

void reg_free(char *reg) {
	if (reg == NULL) {
		fprintf(stderr, "Tried to free a register that is NULL.\n");
		return;
	}

	int i;
	for (i = 0; i < 9; i++) {
		if (strcmp(reg, vars[i]) == 0) {
			var_usage[i]--;
			return;
		}
	}

	fprintf(stderr, "Unknown register \"%s\"!", reg);
}

bool is_var(char *reg) {
	if (reg == NULL) {
		fprintf(stderr, "A register is NULL.\n");
		return false;
	}

	int i = 0;
	for (i = 0; i < 9; i++)
		if (strcmp(reg, vars[i]) == 0)
			return true;
	return false;
}

bool is_par(char *reg) {
	if (reg == NULL) {
		fprintf(stderr, "A register is NULL.\n");
		return false;
	}

	int i = 0;
	for (i = 0; i < 6; i++)
		if (strcmp(reg, pars[i]) == 0)
			return true;
	return false;
}
