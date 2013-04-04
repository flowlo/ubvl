#ifndef GLUE_H
#define GLUE_H
#include <stdio.h>
#include <string.h>
#include "ast.h"
#include "symbol_table.h"

void funcdef(char *name, symbol_table *table, ast_node *node);

#endif
