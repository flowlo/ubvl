#ifndef GLUE_H
#define GLUE_H
#include "ast.h"
#include "symbol_table.h"

#define printi(...) putchar('\t'); printf(__VA_ARGS__); putchar('\n');
#define printl(label) printf("L%ld:\n", label);
#define burm_invoke(root) root = compress(root); if(print_trees) { node_print(root, 0); } burm_label(root); burm_reduce(root, 1);

ast_node* compress(ast_node*);
void funcdef(char *name, symbol_table *table, bool call);
char *gen_add(ast_node *bnode);
char *gen_ladd(ast_node *bnode);
char *gen_sub(ast_node *bnode);
char *gen_lsub(ast_node *bnode);
char *gen_mul(ast_node *bnode);
char *binary(char *op, ast_node *first, ast_node *second, bool commutative);
char *reg_new_var(void);
char *reg_new_par(void);
bool is_var(char *reg);
bool is_par(char *reg);
void reg_free(char *reg);
void reg_reset();
void reg_usage_print();
void save(char*);
void restore(char*);
void prepare_call(ast_node*);
void move(char*, char*);

extern bool need_stack;
extern bool print_trees;
extern unsigned long label;

extern void burm_reduce(NODEPTR_TYPE bnode, int goalnt);
extern STATEPTR_TYPE burm_label(NODEPTR_TYPE p);
#endif
