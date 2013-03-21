#include "ast.h"

ast_node *node_new(int op, ast_node *left, ast_node *right) {
	ast_node *result = malloc(sizeof(ast_node));
	result->op = op;
	result->left = left;
	result->right = right;

	return result;
}

ast_node *node_new_imm(long value) {
	return NULL;
}

ast_node *node_new_id(char *name) {
	return NULL;
}

ast_node *node_new_call(char *name, ast_node *args) {
	return NULL;
}

ast_node *node_new_definition(char* name, ast_node *expr) {
	return NULL;
}

void node_print(ast_node *node, int indent) {
	if (node == NULL)
		return;

	printf("%*d", indent, node->op);
	node_print(node->left, indent + 1);
	node_print(node->right, indent + 1);
}
