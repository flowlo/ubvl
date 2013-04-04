#ifndef GLUE_H
#define GLUE_H
#include <stdio.h>
#include <string.h>
#include "ast.h"
#include "symbol_table.h"

#define printi(...) putchar('\t'); printf(__VA_ARGS__); putchar('\n');

void funcdef(char *name, symbol_table *table, ast_node *node);
char *binary(char *op, char *first, char *second, bool commutative);
char *reg_new(void);
bool is_var(char *reg);
bool is_par(char *reg);
void reg_free(char *reg);
symbol_table *symbol_table_merge_and_assign_regs(symbol_table *a, symbol_table *b, bool check);

#endif
