/*
 * Operations:
 *
 * NEQ		left != right
 * LT		left < right
 * ADD		left + right
 * MUL		left * right
 * SUB		left - right
 * ID		Refers to a defined variable. (name)
 * NUM		Numeric constant.
 * RETURN	Returns left.
 * ASSIGN	left: variable, right: value
 * IF		left: either O_STATS if there is no else clause, or O_ELSE, right: the condition (O_NEQ, O_LT)
 * WHILE
 * STATS
 * ELSE
 * ARRAY
 * OR		left || right
 * NOT		!left
 */

#ifndef AST_H
#define AST_H
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifndef CODE_BFE
typedef struct burm_state *STATEPTR_TYPE;
#endif

#define FOREACH(CALLBACK) \
	CALLBACK(O_NEQ) \
	CALLBACK(O_LT) \
	CALLBACK(O_ADD) \
	CALLBACK(O_MUL) \
	CALLBACK(O_SUB) \
	CALLBACK(O_ID) \
	CALLBACK(O_NUM) \
	CALLBACK(O_RETURN) \
	CALLBACK(O_ASSIGN) \
	CALLBACK(O_IF) \
	CALLBACK(O_WHILE) \
	CALLBACK(O_STATS) \
	CALLBACK(O_ELSE) \
	CALLBACK(O_ARRAY) \
	CALLBACK(O_OR) \
	CALLBACK(O_NOT) \
	CALLBACK(O_ARG)

#define GENERATE_FIELD(FIELD) FIELD,
#define GENERATE_STRING(STRING) #STRING,

enum {
	FOREACH(GENERATE_FIELD)
};

static const char *op_name[] = {
	FOREACH(GENERATE_STRING)
};

typedef struct ast_node {
	struct ast_node *left;
	struct ast_node *right;
	int op;
	long value;
	char *reg;
	char *name;
	STATEPTR_TYPE label;
} ast_node;

typedef ast_node* ast_node_ptr;

#define TREENULL		(struct ast_node *)NULL
#define TREESIZE		(sizeof(struct ast_node))
#define TREECAST		struct ast_node *
#define NODEPTR_TYPE		ast_node_ptr
#define OP_LABEL(node)		((node)->op)
#define LEFT_CHILD(node)	((node)->left)
#define RIGHT_CHILD(node)	((node)->right)
#define STATE_LABEL(node)	((node)->label)
#define PANIC(...)		fprintf(stderr, __VA_ARGS__)

ast_node *node_new(int op, ast_node *left, ast_node *right);
ast_node *node_new_num(long value);
ast_node *node_new_id(char *name);
ast_node *node_new_call(char *name, ast_node *args);
ast_node *node_new_definition(char* name, ast_node *expr);
void node_print(ast_node *node, int indent);
#endif
