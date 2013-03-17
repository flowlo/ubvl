#ifndef TREE_H
#define TREE_H
#include <stdlib.h>

#ifndef CODE_BFE
typedef struct burm_state *STATEPTR_TYPE;
#endif

enum {
	O_NEQ = 1,
	O_LT,
	O_ADD,
	O_MUL,
	O_SUB,
	O_ID,
	O_NUM,
	O_RETURN,
	O_ASSIGN,
	O_IF,
	O_WHILE,
	O_STATS,
	O_ELSE,
	O_ARRAY,
	O_OR,
	O_NOT,
	O_ARG
};

typedef struct ast_node {
	struct ast_node *left;
	struct ast_node *right;
	int op;
	long value;
	STATEPTR_TYPE label;
} ast_node;

typedef ast_node* ast_node_ptr;

#define NODEPTR_TYPE		ast_node_ptr
#define OP_LABEL(node)		((node)->op)
#define LEFT_CHILD(node)	((node)->left)
#define RIGHT_CHILD(node)	((node)->right)
#define STATE_LABEL(node)	((node)->label)
#define PANIC(...)		fprintf(stderr, __VA_ARGS__)

ast_node *node_new(int op, ast_node *left, ast_node *right);
ast_node *node_new_imm(long value);
ast_node *node_new_id(char *name);
ast_node *node_new_call(char *name, ast_node *args);
ast_node *node_new_definition(char* name, ast_node *expr);
void node_print(ast_node *node, int indent);
#endif
