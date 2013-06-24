#include <stdio.h>
#include <stdlib.h>

#include "glue.h"

unsigned long label = 0;
bool print_trees = false;
bool need_stack = false;

char regs[9][4]= { "rax", "r10", "r11", "r9", "r8", "rcx", "rdx", "rsi", "rdi" };
static int usage[9] = { 0, 0, 0, 0, 0, 0, 0, 0, 0 };
bool last_save[9] = { false, false, false, false, false, false, false, false, false };

void move(char a, char b) {
	if (a != b)
		printi("movq %%%s, %%%s", regs[a], regs[b]);
}

void prepare_call(ast_node* args) {
#ifdef DEBUG
	node_print(args, 0);
#endif
	ast_node *cp = args;
	int num_args = 0;
	/* count arguments */
	while (args != NULL && args->op != O_NULL) {
		num_args++;
		args = args->left;
	}

	printf("# num_args = %d\n", num_args);

	args = cp;
	int i = 1;
	/* make sure arguments to this function are not overwritten in case they swap position */
	while (args != NULL && args->op != O_NULL) {
		if (args->right->op != O_NUM && is_par(args->right->reg) && args->right->reg != 8 - num_args + i++) {
			printf("# dealing with %s\n", args->right->name);
			char reg = reg_new_var();
			move(args->right->reg, reg);
			args->right->reg = reg;
		}
		args = args->left;
	}

	args = cp;
	i = 1;
	/* move everything to the right place */
	while (args != NULL && args->op != O_NULL) {
		if (args->right->op == O_NUM) {
			printi("movq $%ld, %%%s", args->right->value, regs[8 - num_args + i++]);
		} else {
			move(args->right->reg, 8 - num_args + i++);
			if (args->right->op != O_ID)
				reg_free(args->right->reg);
		}
		args = args->left;
	}
}

void save(char result) {
#ifdef DEBUG
	reg_usage_print();
#endif
	char i;
	for (i = 0; i < 9; i++)
		if ((last_save[i] = (result != i && usage[i] > 0)))
			printi("pushq %%%s", regs[i]);
}

void restore(char result) {
#ifdef DEBUG
	reg_usage_print();
#endif
	char i;
	for (i = 8; i > -1; i--)
		if (last_save[i])
			printi("popq %%%s", regs[i]);
}

ast_node* compress(ast_node *root) {
	if (root == NULL)
		return NULL;

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

void reg_reset() {
	memset(usage, 0, sizeof(int) * 9);
}

void funcdef(char *name, symbol_table *table, bool call) {
	printf(".globl %1$s\n.type %1$s, @function\n%1$s:\n", name);

#ifdef DEBUG
	symbol_table_print(table);
#endif

	if ((need_stack = call))
		printf("# stack needed!\n");

	if (table != NULL) {
		printf("#");

		do {
			printf(" %s@%s", table->id, regs[table->reg]);
			usage[table->reg]++;
		} while((table = table->next) != NULL);

		printf("\n");

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
		if (table->reg > -1) {
			printf(" %s@%s", table->id, regs[table->reg]);
			usage[table->reg]++;
		}
	} while((table = table->next) != NULL);
	printf("\n");
}

char gen_mul(ast_node *bnode) {
	if (bnode->left->is_imm) {
		if (bnode->left->value == 1) {
			return bnode->right->reg;
		}
		else {
			if (!is_par(bnode->right->reg) && bnode->right->name == NULL) {
				printi("imulq $%ld, %%%s", bnode->left->value, regs[bnode->right->reg]);
				return bnode->right->reg;
			}
			else {
				char reg = reg_new_var();
#ifdef DEBUG
				printf("# gen_mul allocated %s\n", reg);
#endif
				printi("movq %%%s, %%%s", regs[bnode->right->reg], regs[reg]);
				printi("imulq $%ld, %%%s", bnode->left->value, regs[reg]);
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
				printi("imulq $%ld, %%%s", bnode->right->value, regs[bnode->left->reg]);
				return bnode->left->reg;
			}
			else {
				char reg = reg_new_var();
#ifdef DEBUG
				printf("# gen_mul allocated %s\n", reg);
#endif
				printi("movq %%%s, %%%s", regs[bnode->left->reg], regs[reg]);
				printi("imulq $%ld, %%%s", bnode->right->value, regs[reg]);
				return reg;
			}
		}
	}
	else {
		return binary("imulq", bnode->left, bnode->right, true);
	}
}

char gen_add(ast_node *bnode) {
	if (bnode->left->is_imm) {
		if (bnode->left->value == 0) {
			return bnode->right->reg;
		}
		else {
			if (!is_par(bnode->right->reg) && bnode->right->name == NULL) {
				if (bnode->left->value == 1) {
					printi("incq %%%s", regs[bnode->right->reg]);
					return bnode->right->reg;
				} else {
					printi("addq $%ld, %%%s", bnode->left->value, regs[bnode->right->reg]);
					return bnode->right->reg;
				}
			}
			else {
				char reg = reg_new_var();
#ifdef DEBUG
				printf("# gen_add allocated %s\n", regs[reg]);
#endif

				printi("leaq %ld (%%%s), %%%s", bnode->left->value, regs[bnode->right->reg], regs[reg]);
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
					printi("incq %%%s", regs[bnode->left->reg]);
					return bnode->left->reg;
				} else {
					printi("addq $%ld, %%%s", bnode->right->value, regs[bnode->left->reg]);
					return bnode->left->reg;
				}
			}
			else {
				char reg = reg_new_var();
#ifdef DEBUG
				printf("# gen_add allocated %s\n", reg);
#endif
//				printi("movq %%%s, %%%s", bnode->left->reg, reg);
				printi("leaq %ld (%%%s), %%%s", bnode->right->value, regs[bnode->left->reg], regs[reg]);
				return reg;
			}
		}
	}
	else {
//		printf("%d %d %d %d\n", !is_par(bnode->left->reg) ?0:1, bnode->left->name == NULL ?0:1, !is_par(bnode->right->reg) ?0:1, bnode->right->name == NULL?0:1);
//		if ((!is_par(bnode->left->reg)) && (bnode->left->name == NULL) && (!is_par(bnode->right->reg)) && (bnode->right->name == NULL)) {
//			char *reg = reg_new_var();
//			printi("leaq (%%%s, %%%s), %%%s", bnode->left->reg, bnode->right->reg, reg);
//			return reg;
//		} else {
			return binary("addq", bnode->left, bnode->right, true);
//		}
	}
}

char gen_ladd(ast_node* bnode) {
	char reg;
	if (!is_par(bnode->left->right->reg) && bnode->left->right->name == NULL) {
		reg = bnode->left->right->reg;
		printi("leaq %ld (%%%s, %%%s), %%%s", bnode->right->value, regs[bnode->left->left->reg], regs[bnode->left->right->reg], regs[reg]);
	} else {
		reg = reg_new_var();
		printi("leaq %ld (%%%s, %%%s), %%%s", bnode->right->value, regs[bnode->left->left->reg], regs[bnode->left->right->reg], regs[reg]);
	}
	return reg;
}

char gen_lsub(ast_node* bnode) {
	char reg;
	if (!is_par(bnode->left->right->reg) && bnode->left->right->name == NULL) {
		reg = bnode->left->right->reg;
		printi("leaq %ld (%%%s, %%%s), %%%s", -bnode->right->value, regs[bnode->left->left->reg], regs[bnode->left->right->reg], regs[reg]);
	} else {
		reg = reg_new_var();
		printi("leaq %ld (%%%s, %%%s), %%%s", -bnode->right->value, regs[bnode->left->left->reg], regs[bnode->left->right->reg], regs[reg]);
	}
	return reg;
}

char gen_sub(ast_node *bnode) {
	if (bnode->left->is_imm) {
		if (bnode->left->value == 0 && !is_par(bnode->right->reg) && bnode->right->name == NULL) {
			printi("neg %%%s", regs[bnode->right->reg]);
			return bnode->right->reg;
		}
		else {
			if (!is_par(bnode->right->reg) && bnode->right->name == NULL) {
				printi("movq $%ld, %%%s", bnode->left->value, regs[bnode->left->reg = reg_new_var()]);
				return binary("subq", bnode->left, bnode->right, false);
			} else {
				printi("subq $%ld, %%%s", bnode->left->value, regs[bnode->right->reg]);
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
					printi("decq %%%s", regs[bnode->left->reg]);
					return bnode->left->reg;
				} else {
					printi("subq $%ld, %%%s", bnode->right->value, regs[bnode->left->reg]);
					return bnode->left->reg;
				}
			}
			else {
				char reg = reg_new_var();
				printi("leaq %ld (%%%s), %%%s", -bnode->right->value, regs[bnode->left->reg], regs[reg]);
				return reg;
			}
		}
	}
	else {
		return binary("subq", bnode->left, bnode->right, false);
	}
}

char binary(char *op, ast_node *first, ast_node *second, bool commutative) {
	bool first_is_par = is_par(first->reg), second_is_par = is_par(second->reg);
	char reg;

	if (first_is_par && second_is_par) {
		reg = reg_new_var();
#ifdef DEBUG
		printf("#\ttwo parameters\n");
#endif
		printi("movq %%%s, %%%s", regs[first->reg], regs[reg]);
		printi("%s %%%s, %%%s", op, regs[second->reg], regs[reg]);
	} else if (!first_is_par && !second_is_par) {
		if (first->name == NULL) {
			reg = first->reg;
#ifdef DEBUG
			printf("#\ttwo variables!\n");
#endif
			printi("%s %%%s, %%%s # %s, %s", op, regs[second->reg], regs[first->reg], second->name, first->name);
		} else {
			reg = reg_new_var();
			printi("mov %%%s, %%%s", regs[first->reg], regs[reg]);
			printi("%s %%%s, %%%s", op, regs[second->reg], regs[reg]);
		}
	} else if (!first_is_par && second_is_par) {
		if (first->name != NULL) {
#ifdef DEBUG
			printf("#\t tricky!\n");
#endif
			reg = reg_new_var();
			printi("movq %%%s, %%%s", regs[first->reg], regs[reg]);
			printi("%s %%%s, %%%s", op, regs[second->reg], regs[reg]);
		} else {
#ifdef DEBUG
			printf("#\tshould do it!\n");
#endif
			reg = first->reg;
			printi("%s %%%s, %%%s", op, regs[second->reg], regs[first->reg]);
		}
	} else if (commutative) {
		if (second->name != NULL) {
			reg = reg_new_var();
			printi("movq %%%s, %%%s", regs[second->reg], regs[reg]);
			printi("%s %%%s, %%%s", op, regs[first->reg], regs[reg]);
		} else {
#ifdef DEBUG
			printf("#\tcommutativity strikes back!\n");
#endif
			reg = second->reg;
			printi("%s %%%s, %%%s", op, regs[first->reg], regs[second->reg]);
		}
	} else if (first_is_par && !second_is_par) {
#ifdef DEBUG
		printf("#\tlet me see ...\n");
#endif
		reg = reg_new_var();
		printi("movq %%%s, %%%s", regs[second->reg], regs[reg]);
		printi("%s %%%s, %%%s", op, regs[reg], regs[first->reg]);
		reg_free(reg);
		reg = first->reg;
	} else {
		fprintf(stderr, "Failed to arrange for \"%s %%%s, %%%s\" (%s) (%s)!\n", op, regs[first->reg], regs[second->reg], first->name, second->name);
		exit(4);
	}

	return reg;
}

char reg_new_var(void) {
	reg_usage_print();

	char i = 0;
	for (i = 0; i < 9; i++)
		if (usage[i] == 0) {
			usage[i]++;
#ifdef DEBUG
			printf("#! allocated %s\n", vars[i]);
#endif
			return i;
		}

	fprintf(stderr, "Not enough variable registers!");
	exit(4);
}

char reg_new_par(void) {
	reg_usage_print();

	char i;
	for (i = 8; i > 2; i--)
		if (usage[i] == 0) {
			usage[i]++;
#ifdef DEBUG
			printf("#! allocated %s\n", pars[i]);
#endif
			return i;
		}

	fprintf(stderr, "Not enough parameter registers!");
	exit(4);
}

void reg_free(char reg) {
	if (reg < 0) {
		fprintf(stderr, "Invalid register!");
		return;
	}

	reg_usage_print();
	usage[reg]--;
}

void reg_free_recursive(ast_node *node) {
	if (node != NULL) {
		if (node->reg > -1 && node->name == NULL) {
			reg_free(node->reg);
		}
		reg_free_recursive(node->left);
		reg_free_recursive(node->right);
	}
}

bool is_par(char reg) {
	return reg > 2;
}

void reg_usage_print() {
#ifdef DEBUG
	printf("# used:");

	char i = 0;
	for (i = 0; i < 9; i++)
		if (usage[i] > 0)
			printf(" %s(%d)", regs[i], usage[i]);

	printf("\n");
#endif
}
