#ifndef GLUE_H
#define GLUE_H
#include "ast.h"
#include "symbol_table.h"

#define printi(...) { putchar('\t'); printf(__VA_ARGS__); putchar('\n'); }
#define printl(label) printf("L%ld:\n", label);
#define burm_invoke(root) root = compress(root); if(print_trees) { node_print(root, 0); } burm_label(root); burm_reduce(root, 1);

ast_node* compress(ast_node*);
void funcdef(char *name, symbol_table *table, bool call);
int gen_add(ast_node *bnode);
int gen_ladd(ast_node *bnode);
int gen_sub(ast_node *bnode);
int gen_lsub(ast_node *bnode);
int gen_mul(ast_node *bnode);
int binary(char *op, ast_node *first, ast_node *second, bool commutative);
int reg_new_var(void);
int reg_new_par(void);
bool is_var(int reg);
bool is_par(int reg);
void reg_free(int reg);
void reg_reset();
void reg_usage_print();
void save(int);
void restore(int);
void prepare_call(ast_node*);
void move(int, int);

extern bool need_stack;
extern bool print_trees;
extern unsigned long label;
extern char regs[9][4];

extern void burm_reduce(NODEPTR_TYPE bnode, int goalnt);
extern STATEPTR_TYPE burm_label(NODEPTR_TYPE p);
#endif
