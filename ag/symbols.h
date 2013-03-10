#include <stdbool.h>

#ifndef SYMBOLS_H
#define SYMBOLS_H

#define SYMBOL_TYPE_LABEL 1
#define SYMBOL_TYPE_VAR 2

typedef short symbol_type;

struct symbol_table {
	struct symbol_table *next;
	char *id;
	symbol_type type;
};

typedef struct symbol_table symbol_table;

symbol_table *symbol_table_new(void);
symbol_table *symbol_table_clone(symbol_table *table);
symbol_table *symbol_table_get(symbol_table *table, char *id);
symbol_table *symbol_table_del(symbol_table *table, char *id);
symbol_table *symbol_table_merge(symbol_table *table, symbol_table *to_add, bool check);
symbol_table *symbol_table_add(symbol_table *table, char *id, symbol_type type, bool check);
void check_variable(symbol_table *table, char *id);
void check_label(symbol_table *table, char *id);

#endif
