#include "ast.h"

ast_node *node_new(int op, ast_node *left, ast_node *right) {
	ast_node *result = malloc(sizeof(ast_node));
	result->op = op;
	result->left = left;
	result->right = right;

	return result;
}

ast_node *node_new_num(long value) {
	ast_node *result = malloc(sizeof(ast_node));
	result->op = O_NUM;
	result->left = NULL;
	result->right = NULL;
	result->value = value;

	return result;
}

ast_node *node_new_id(char *name) {
	ast_node *result = malloc(sizeof(ast_node));
	result->op = O_ID;
	result->left = NULL;
	result->right = NULL;
	result->name = strdup(name);

	return result;
}

ast_node *node_new_call(char *name, ast_node *args) {
	return NULL;
}

ast_node *node_new_definition(char* name, ast_node *expr) {
	ast_node *result = malloc(sizeof(ast_node));
	result->left = expr;
	result->name = strdup(name);
	return result;
}

void node_print(ast_node *node, int indent) {
	if (node == NULL)
		return;

	printf("%*d %s\n", indent, node->op, op_name[node->op]);
	node_print(node->left, indent + 8);
	node_print(node->right, indent + 8);
}
