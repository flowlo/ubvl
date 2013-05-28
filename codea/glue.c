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

void reg_reset() {
	memset(var_usage, 0, sizeof(int) * 9);
	memset(par_usage, 0, sizeof(int) * 6);
}

void funcdef(char *name, symbol_table *table, ast_node *node) {
	printf(".globl %1$s\n.type %1$s, @function\n%1$s:\n", name);

	if (table != NULL) {
		printf("#");

		do {
			printf(" %s@%s", table->id, table->reg);
		} while((table = table->next) != NULL);

		printf("\n");
	}

	int i;
	symbol_table *element;
	for (i = 5, element = table; i > -1 && element != NULL; i--, element = element->next) {
		element->reg = strdup(pars[i]);
	}

	return;
}

char *gen_add(ast_node *bnode) {
	if (bnode->left->is_imm) {
		if (bnode->left->value == 0) {
			return bnode->right->reg;
		}
		else {
			if (!is_par(bnode->right->reg)) {
				printi("addq $%ld, %%%s", bnode->left->value, bnode->right->reg);
				return bnode->right->reg;
			}
			else {
				char *reg = reg_new_var();
				printi("movq %%%s, %%%s", bnode->right->reg, reg);
				printi("addq $%ld, %%%s", bnode->left->value, reg);
				return reg;
			}
		}
	}
	else if (bnode->right->is_imm) {
		if (bnode->right->value == 0) {
			return bnode->left->reg;
		}
		else {
			if (!is_par(bnode->left->reg)) {
#ifdef DEBUG
				printf("# right is imm, left is var:\n");
#endif
				printi("addq $%ld, %%%s", bnode->right->value, bnode->left->reg);
				return bnode->left->reg;
			}
			else {
				char *reg = reg_new_var();
				printi("movq %%%s, %%%s", bnode->left->reg, reg);
				printi("addq $%ld, %%%s", bnode->right->value, reg);
				return reg;
			}
		}
	}
	else {
		printi("# fallback");
		return binary("addq", bnode->left->reg, bnode->right->reg, true);
	}
}

char *gen_sub(ast_node *bnode) {
	if (bnode->left->is_imm) {
		if (bnode->left->value == 0 && false) {
			printi("neg %%%s", bnode->right->reg);
			return bnode->right->reg;
		}
		else {
			printi("movq $%ld, %%%s", bnode->left->value, bnode->left->reg = reg_new_var());
			return binary("subq", bnode->left->reg, bnode->right->reg, false);
		}
	}
	else if (bnode->right->is_imm) {
		if (bnode->right->value == 0) {
			return bnode->left->reg;
		}
		else {
			if (!is_par(bnode->left->reg)) {
				printi("subq $%ld, %%%s", bnode->right->value, bnode->left->reg);
				return bnode->left->reg;
			}
			else {
				printi("movq $%ld, %%%s", bnode->right->value, bnode->right->reg = reg_new_var());
				return binary("subq", bnode->left->reg, bnode->right->reg, false);
			}
		}
	}
	else {
		return binary("subq", bnode->left->reg, bnode->right->reg, false);
	}
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
		printi("%s %%%s, %%%s", op, second, first);
//		reg_free(second);
	} else if (!first_is_par && second_is_par) {
#ifdef DEBUG
		printf("#\tshould do it!\n");
#endif
		reg = first;
		printi("%s %%%s, %%%s", op, second, first);
	} else if (commutative) {
#ifdef DEBUG
		printf("#\tcommutativity strikes back!\n");
#endif
		reg = second;
		printi("%s %%%s, %%%s", op, first, second);
	} else if (first_is_par && !second_is_par) {
#ifdef DEBUG
		printf("#\tlet me see ...\n");
#endif
		reg = reg_new_var();
		printi("movq %%%s, %%%s", second, reg);
		printi("%s %%%s, %%%s", op, reg, first);
		reg_free(reg);
		reg = first;
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
