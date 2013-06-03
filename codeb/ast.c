#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "ast.h"
#include "symbol_table.h"

const char *op_name[] = {
	FOREACH(GENERATE_STRING)
};

unsigned long label = 0;

ast_node *node_new(int op, ast_node *left, ast_node *right) {
	ast_node *result = malloc(sizeof(ast_node));
	result->op = op;
	result->left = left;
	result->right = right;
	result->is_imm = false;

	return result;
}

ast_node *node_new_num(long value) {
	ast_node *result = malloc(sizeof(ast_node));
	result->op = O_NUM;
	result->left = NULL;
	result->right = NULL;
	result->value = value;
	result->is_imm = true;

	return result;
}

ast_node *node_new_id(char *name, symbol_table *table) {
	ast_node *result = malloc(sizeof(ast_node));
	result->op = O_ID;
	result->left = NULL;
	result->right = NULL;
	result->name = strdup(name);
	result->is_imm = false;
	table = symbol_table_get(table, name);

	if (table != NULL)
		result->reg = table->reg;

	return result;
}

ast_node *node_new_call(char *name, ast_node *args) {
	return NULL;
}

void node_print(ast_node *node, int indent) {
	if (node == NULL)
		return;

	printf("# %*d %s ", indent, node->op, op_name[node->op]);
	switch (node->op) {
		case O_ID:	printf("%s", node->name);	break;
		case O_NUM:	printf("%ld", node->value);	break;
	}
	printf("\n");
	node_print(node->left, indent + 8);
	node_print(node->right, indent + 8);
}
