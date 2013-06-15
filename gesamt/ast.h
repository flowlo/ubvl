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
 * LEXPR	left: variable, right: value
 * ARRAY	left: id or array, right: index
 * OR		left || right
 * NOT		!left
 * ARG		left: next argument or O_NULL, right: expression
 * CALL		left: name of function, right: arguments or O_NULL
 */

#ifndef AST_H
#define AST_H
#include "symbol_table.h"

#ifndef CODE_BFE
typedef struct burm_state *STATEPTR_TYPE;
#endif

#define FOREACH(CALLBACK) \
	CALLBACK(O_NULL) \
	CALLBACK(O_NEQ) \
	CALLBACK(O_LT) \
	CALLBACK(O_ADD) \
	CALLBACK(O_MUL) \
	CALLBACK(O_SUB) \
	CALLBACK(O_ID) \
	CALLBACK(O_NUM) \
	CALLBACK(O_ARRAY) \
	CALLBACK(O_OR) \
	CALLBACK(O_NOT) \
	CALLBACK(O_ARG) \
	CALLBACK(O_LEXPR) \
	CALLBACK(O_CALL)

#define GENERATE_FIELD(FIELD) FIELD,
#define GENERATE_STRING(STRING) #STRING,

/* To define all numeric constants. */
enum {
	FOREACH(GENERATE_FIELD)
};

/* To translate a number into a string in the form O_* */
extern const char *op_name[];

typedef struct ast_node {
	struct ast_node *left;
	struct ast_node *right;
	int op;
	long value;
	char *reg;
	char *name;
	bool is_imm;
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
ast_node *node_new_id(char *name, symbol_table *table);
ast_node *node_new_call(char *name, ast_node *args);
void node_print(ast_node *node, int indent);
#endif
