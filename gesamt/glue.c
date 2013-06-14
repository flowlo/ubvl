#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "glue.h"

unsigned long label = 0;
bool print_trees = false;

char vars[9][4]= { "rax", "r10", "r11", "r9", "r8", "rcx", "rdx", "rsi", "rdi" };
char pars[6][4]= { "rdi", "rsi", "rdx", "rcx", "r8", "r9" };
static int var_usage[9] = { 0, 0, 0, 0, 0, 0, 0, 0, 0 };
int par_usage[6] = { 0, 0, 0, 0, 0, 0 };

ast_node* compress(ast_node *root) {
	if (root == NULL) {
		return NULL;
	}

	ast_node *cp = root;
	int tmp = 0;

	if (root->op == O_ADD || root->op == O_SUB) {
		while (root->left != NULL) {
			if ((root->left->op == O_ADD || root->left->op == O_SUB) && root->left->right->is_imm) {
				tmp += root->left->op == O_ADD ? root->left->right->value : -root->left->right->value;
				root->left = root->left->left;
			} else {
				root = root->left;
			}
		}
		if (tmp != 0) {
			if (cp->right->is_imm) {
				cp->right->value += cp->op == O_ADD ? tmp : -tmp;
				return cp;
			} else {
				return node_new(O_ADD, cp, node_new_num(tmp));
			}
		} else {
			return cp;
		}
	} else if (root->op == O_MUL) {
		tmp = 1;
		while (root->left != NULL) {
			if (root->left->op != O_MUL) {
				break;
			} else if (root->left->right->is_imm) {
				tmp *= root->left->right->value;
				root->left = root->left->left;
			}
			else {
				root = root->left;
			}
		}
		if (tmp != 1) {
			if (cp->right->is_imm) {
				cp->right->value *= tmp;
				return cp;
			} else {
				return node_new(O_MUL, cp, node_new_num(tmp));
			}
		}
	}

	return root;
}

void print_var_usage() {
	printf ("# ");

	int i;
	for (i = 0; i < 9; i++)
		printf("%s: %d  ", vars[i], var_usage[i]);

	printf("\n");
}

void reg_reset() {
	memset(var_usage, 0, sizeof(int) * 9);
	memset(par_usage, 0, sizeof(int) * 6);
}

void funcdef(char *name, symbol_table *table) {
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

	reg_usage_print();

	return;
}

void reg_restore(symbol_table *table) {
	reg_reset();

	if (table == NULL)
		return;

	printf("#");

	int i;
	do {
		if (table->reg != NULL) {
			printf(" %s@%s", table->id, table->reg);

			for (i = 0; i < 9; i++)
				if (strcmp(table->reg, vars[i]) == 0)
					var_usage[i]++;
		}
	} while((table = table->next) != NULL);
	printf("\n");
}

char *gen_mul(ast_node *bnode) {
	if (bnode->left->is_imm) {
		if (bnode->left->value == 1) {
			return bnode->right->reg;
		}
		else {
			if (!is_par(bnode->right->reg) && bnode->right->name == NULL) {
				printi("imulq $%ld, %%%s", bnode->left->value, bnode->right->reg);
				return bnode->right->reg;
			}
			else {
				char *reg = reg_new_var();
#ifdef DEBUG
				printf("# gen_mul allocated %s\n", reg);
#endif
				printi("movq %%%s, %%%s", bnode->right->reg, reg);
				printi("imulq $%ld, %%%s", bnode->left->value, reg);
				return reg;
			}
		}
	}
	else if (bnode->right->is_imm) {
		if (bnode->right->value == 1) {
			return bnode->left->reg;
		}
		else {
			if (!is_par(bnode->left->reg) && bnode->left->name == NULL) {
				printi("imulq $%ld, %%%s", bnode->right->value, bnode->left->reg);
				return bnode->left->reg;
			}
			else {
				char *reg = reg_new_var();
#ifdef DEBUG
				printf("# gen_mul allocated %s\n", reg);
#endif
				printi("movq %%%s, %%%s", bnode->left->reg, reg);
				printi("imulq $%ld, %%%s", bnode->right->value, reg);
				return reg;
			}
		}
	}
	else {
		return binary("imulq", bnode->left, bnode->right, true);
	}
}

char *gen_add(ast_node *bnode) {
	if (bnode->left->is_imm) {
		if (bnode->left->value == 0) {
			return bnode->right->reg;
		}
		else {
			if (!is_par(bnode->right->reg) && bnode->right->name == NULL) {
				if (bnode->left->value == 1) {
					printi("incq %%%s", bnode->right->reg);
					return bnode->right->reg;
				} else {
					printi("addq $%ld, %%%s", bnode->left->value, bnode->right->reg);
					return bnode->right->reg;
				}
			}
			else {
				char *reg = reg_new_var();
#ifdef DEBUG
				printf("# gen_add allocated %s\n", reg);
#endif

				printi("leaq %ld (%%%s), %%%s", bnode->left->value, bnode->right->reg, reg);
				return reg;
			}
		}
	}
	else if (bnode->right->is_imm) {
		if (bnode->right->value == 0) {
			return bnode->left->reg;
		}
		else {
			if (!is_par(bnode->left->reg) && bnode->left->name == NULL) {
				if (bnode->right->value == 1) {
					printi("incq %%%s", bnode->left->reg);
					return bnode->left->reg;
				} else {
					printi("addq $%ld, %%%s", bnode->right->value, bnode->left->reg);
					return bnode->left->reg;
				}
			}
			else {
				char *reg = reg_new_var();
#ifdef DEBUG
				printf("# gen_add allocated %s\n", reg);
#endif
//				printi("movq %%%s, %%%s", bnode->left->reg, reg);
				printi("leaq %ld (%%%s), %%%s", bnode->right->value, bnode->left->reg, reg);
				return reg;
			}
		}
	}
	else {
		return binary("addq", bnode->left, bnode->right, true);
	}
}

char *gen_sub(ast_node *bnode) {
	if (bnode->left->is_imm) {
		if (bnode->left->value == 0 && !is_par(bnode->right->reg) && bnode->right->name == NULL) {
			printi("neg %%%s", bnode->right->reg);
			return bnode->right->reg;
		}
		else {
			if (!is_par(bnode->right->reg) && bnode->right->name == NULL) {
				printi("movq $%ld, %%%s", bnode->left->value, bnode->left->reg = reg_new_var());
				return binary("subq", bnode->left, bnode->right, false);
			} else {
				printi("subq $%ld, %%%s", bnode->left->value, bnode->right->reg);
				return bnode->right->reg;
			}
		}
	}
	else if (bnode->right->is_imm) {
		if (bnode->right->value == 0) {
			return bnode->left->reg;
		}
		else {
			if (!is_par(bnode->left->reg) && bnode->left->name == NULL) {
				if (bnode->right->value == 1) {
					printi("decq %%%s", bnode->left->reg);
					return bnode->left->reg;
				} else {
					printi("subq $%ld, %%%s", bnode->right->value, bnode->left->reg);
					return bnode->left->reg;
				}
			}
			else {
				char* reg = reg_new_var();
				printi("leaq %ld (%%%s), %%%s #bizz", -bnode->right->value, bnode->left->reg, reg);
				return reg;
			}
		}
	}
	else {
		return binary("subq", bnode->left, bnode->right, false);
	}
}

char *binary(char *op, ast_node *first, ast_node *second, bool commutative) {
	bool first_is_par = is_par(first->reg), second_is_par = is_par(second->reg);
	char *reg;

	if (first_is_par && second_is_par) {
		reg = reg_new_var();
#ifdef DEBUG
		printf("#\ttwo parameters\n");
#endif
		printi("movq %%%s, %%%s", first->reg, reg);
		printi("%s %%%s, %%%s", op, second->reg, reg);
	} else if (!first_is_par && !second_is_par) {
		if (first->name == NULL) {
			reg = first->reg;
#ifdef DEBUG
			printf("#\ttwo variables!\n");
#endif
			printi("%s %%%s, %%%s # %s, %s", op, second->reg, first->reg, second->name, first->name);
		} else {
			reg = reg_new_var();
			printi("mov %%%s, %%%s", first->reg, reg);
			printi("%s %%%s, %%%s", op, second->reg, reg);
		}
	} else if (!first_is_par && second_is_par) {
		if (first->name != NULL) {
#ifdef DEBUG
			printf("#\t tricky!\n");
#endif
			reg = reg_new_var();
			printi("movq %%%s, %%%s", first->reg, reg);
			printi("%s %%%s, %%%s", op, second->reg, reg);
		} else {
#ifdef DEBUG
			printf("#\tshould do it!\n");
#endif
			reg = first->reg;
			printi("%s %%%s, %%%s", op, second->reg, first->reg);
		}
	} else if (commutative) {
		if (second->name != NULL) {
			reg = reg_new_var();
			printi("movq %%%s, %%%s", second->reg, reg);
			printi("%s %%%s, %%%s", op, first->reg, reg);
		} else {
#ifdef DEBUG
			printf("#\tcommutativity strikes back!\n");
#endif
			reg = second->reg;
			printi("%s %%%s, %%%s", op, first->reg, second->reg);
		}
	} else if (first_is_par && !second_is_par) {
#ifdef DEBUG
		printf("#\tlet me see ...\n");
#endif
		reg = reg_new_var();
		printi("movq %%%s, %%%s", second->reg, reg);
		printi("%s %%%s, %%%s", op, reg, first->reg);
		reg_free(reg);
		reg = first->reg;
	} else {
		fprintf(stderr, "Failed to arrange for \"%s %%%s, %%%s\" (%s) (%s)!\n", op, first->reg, second->reg, first->name, second->name);
		exit(4);
	}

	return reg;
}

char *reg_new_var(void) {
	reg_usage_print();

	int i = 0;
	for (i = 0; i < 9; i++)
		if (var_usage[i] == 0) {
			var_usage[i]++;
#ifdef DEBUG
			printf("#! allocated %s\n", vars[i]);
#endif
			return strdup(vars[i]);
		}

	fprintf(stderr, "Not enough variable registers!");
	exit(4);
}

char *reg_new_par(void) {
	reg_usage_print();

	int i = 0;
	for (i = 0; i < 9; i++)
		if (par_usage[i] == 0) {
			par_usage[i]++;
#ifdef DEBUG
			printf("#! allocated %s\n", pars[i]);
#endif
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

	reg_usage_print();

	int i;
	for (i = 0; i < 9; i++) {
		if (strcmp(reg, vars[i]) == 0) {
			var_usage[i]--;
			return;
		}
	}

	fprintf(stderr, "Unknown register \"%s\"!", reg);
}

void reg_free_recursive(ast_node *node) {
	if (node != NULL) {
		if (node->reg != NULL && node->name == NULL) {
			reg_free(node->reg);
		}
		reg_free_recursive(node->left);
		reg_free_recursive(node->right);
	}
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

void reg_usage_print() {
#ifdef DEBUG
	printf("# used:");

	int i = 0;
	for (i = 0; i < 9; i++)
		if (var_usage[i] > 0)
			printf(" %s", vars[i]);

	printf("\n");
#endif
}
