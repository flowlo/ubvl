#include <stdbool.h>

#ifndef SYMBOLS_H
#define SYMBOLS_H

typedef int symbol_dimensions;

struct symbol_table {
	struct symbol_table *next;
	char *id;
	symbol_dimensions dimensions;
};

typedef struct symbol_table symbol_table;

symbol_table *symbol_table_new(void);
symbol_table *symbol_table_clone(symbol_table *table);
symbol_table *symbol_table_get(symbol_table *table, char *id);
symbol_table *symbol_table_del(symbol_table *table, char *id);
symbol_table *symbol_table_merge(symbol_table *table, symbol_table *to_add, bool check);
symbol_table *symbol_table_add(symbol_table *table, char *id, symbol_dimensions dimensions, bool check);
symbol_dimensions symbol_table_get_dimensions(symbol_table *table, char* id);
void symbol_table_print(symbol_table *table);
void symbol_table_print_descriptive(symbol_table *table, char* description);
void assert_dimensions(int a, int b);
symbol_table *assert_variable_exists(symbol_table *table, char *id);
void check_variable(symbol_table *table, char *id);
void check_label(symbol_table *table, char *id);

#endif
