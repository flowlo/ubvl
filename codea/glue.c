#include "glue.h"

char vars[9][4]= { "rax", "r10", "r11", "r9", "r8", "rcx", "rdx", "rsi", "rdi" };
char pars[6][4]= { "rdi", "rsi", "rdx", "rcx", "r8", "r9" };
int usage[9] = { 0, 0, 0, 0, 0, 0, 0, 0, 0 };

#define reg_reset() memset(usage, 0, sizeof(int) * 9);

void funcdef(char *name, symbol_table *table, ast_node *node) {
	printf(".globl %1$s\n.type %1$s, @function\n%1$s:\n", name);

	symbol_table_print(table);

	reg_reset();

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
		reg = reg_new();
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

char *reg_new(void) {
	int i = 0;
	for (i = 0; i < 9; i++)
		if (usage[i] == 0)
			return strdup(vars[i]);

	fprintf(stderr, "Not enough registers!");
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
			usage[i]--;
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

symbol_table *symbol_table_merge_and_assign_regs(symbol_table *a, symbol_table *b, bool check) {
	symbol_table *result = malloc(sizeof(symbol_table));

	if (result == NULL) {
		fprintf(stderr, "Out of memory initializing new table in order to merge tables %p and %p, malloc failed (tried to allocate %lu bytes).", a, b, sizeof(symbol_table));
		exit(128);
	}

	int par = 0, var = 0;
	symbol_table *i = result, *j = b;

	if (j != NULL) {
		while ((j = j->next) != NULL)
			var++;

		j = b;

		while (j->next != NULL) {
			i->next = malloc(sizeof(symbol_table));

			if (i->next == NULL) {
				fprintf(stderr, "Out of memory adding symbol '%s' while merging tables %p and %p, malloc failed (tried to allocate %lu bytes).", j->id, a, b, sizeof(symbol_table));
				exit(128);
			}

			i->id = strdup(j->id);

			if (var <= 0) {
				fprintf(stderr, "Out of variable registers while merging.");
			} else {
				i->reg = strdup(vars[--var]);
				printf("Assigned variable register %s to %s.\n", i->reg, i->id);
			}
			i->dimensions = j->dimensions;
			i = i->next;
			j = j->next;
		}
	}

	j = a;

	if (j != NULL) {
		while ((j = j->next) != NULL)
			par++;

		j = a;

		while (j->next != NULL) {
			i->next = malloc(sizeof(symbol_table));

			if (i->next == NULL) {
				fprintf(stderr, "Out of memory adding symbol '%s' while merging tables %p and %p, malloc failed (tried to allocate %lu bytes).", j->id, a, b, sizeof(symbol_table));
				exit(128);
			}

			i->id = strdup(j->id);

			if (par <= 0) {
				fprintf(stderr, "Out of parameter registers while merging.");
			} else {
				i->reg = strdup(pars[--par]);
				printf("Assigned parameter register %s to %s.\n", i->reg, i->id);
			}
			i->dimensions = j->dimensions;
			i = i->next;
			j = j->next;
		}
		i->id = strdup(j->id);
		if (j->reg != NULL)
			i->reg = strdup(j->reg);
		i->dimensions = j->dimensions;
		i->next = NULL;
	}

	return result;
}
