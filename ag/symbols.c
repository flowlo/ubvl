#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "symbols.h"
#include "parser.h"

extern int yylineno;

symbol_table *symbol_table_clone(symbol_table *table) {
	if (table == NULL)
		return NULL;

	symbol_table *result = NULL, *i = table;

	do {
		result = symbol_table_add(result, i->id, i->dimensions, 0);
	} while ((i = i->next) != NULL);

	return result;
}

symbol_table *symbol_table_add(symbol_table *table, char *id, symbol_dimensions dimensions, bool check) {
	symbol_table *result = malloc(sizeof(symbol_table));
	result->next = NULL;
	result->id = strdup(id);
	result->dimensions = dimensions;

	if (table == NULL)
		return result;

	if (symbol_table_get(table, id) != NULL) {
		if (check) {
			fprintf(stderr, "duplicate symbol '%s'.\n", id);
			exit(3);
		}

		table = symbol_table_del(table, id);
	}

	symbol_table *i;
	for (i = table; i->next != NULL; i = i->next);
	i->next = result;

	return table;
}

symbol_table *symbol_table_get(symbol_table *table, char *id) {
	if (table == NULL)
		return NULL;

	symbol_table *i = table;

	do {
		if (strcmp(i->id, id) == 0)
			return i;
	} while ((i = i->next) != NULL);

	fprintf(stderr, "get: unknown symbol '%s'\n", id);
	return NULL;
}

symbol_dimensions symbol_table_get_dimensions(symbol_table *table, char *id) {
	if (table == NULL)
		return NULL;

	symbol_table *i = table;

	do {
		if (strcmp(i->id, id) == 0)
			return i->dimensions;
	} while ((i = i->next) != NULL);

	fprintf(stderr, "get_dimensions: unknown symbol '%s'\n", id);
	return NULL;
}

symbol_table *symbol_table_merge(symbol_table *a, symbol_table *b, bool check) {
	if (a == NULL)
		return symbol_table_clone(b);
	if (b == NULL)
		return symbol_table_clone(a);

	symbol_table *result = symbol_table_clone(a), *i = b;

	do {
		result = symbol_table_add(result, i->id, i->dimensions, check);
	} while ((i = i->next) != NULL);

	return result;
}

symbol_table *symbol_table_del(symbol_table *table, char *id) {
	if (table == NULL)
		return NULL;

	symbol_table *i = table, *prev = NULL, *result;

	do {
		if (strcmp(i->id, id) == 0) {
			if (prev == NULL) {
				result = i->next;
			}
			else {
				prev->next = i->next;
				result = table;
			}
			free(i->id);
			free(i);
			return result;
		}
		prev = i;
	} while ((i = i->next) != NULL);

	return table;
}

void symbol_table_print(symbol_table *table) {
	if (table == NULL) {
		printf("empty symbol table.\n");
		return;
	}

	symbol_table *i = table;
	do {
		printf("%s\t\t%d\n", i->id, i->dimensions);
	} while ((i = i->next) != NULL);
}

void assert_array(symbol_dimensions dimensions) {
	if (dimensions < 1) {
		fprintf(stderr, "trying to access int where array needed");
		exit(3);
	}
}

void assert_int(symbol_dimensions dimensions) {
	if (dimensions < 1) {
		fprintf(stderr, "trying to access array where int needed");
		exit(3);
	}
}

void symbol_table_print_descriptive(symbol_table *table, char *description) {
	printf("%s:\n", description);
	symbol_table_print(table);
}

void check_sym(symbol_table *table, char *id, symbol_dimensions dimensions, bool ignore_unknown) {
	symbol_table *element = symbol_table_get(table, id);

	if (element == NULL) {
		if (!ignore_unknown) {
			fprintf(stderr, "unknown symbol '%s'.\n", id);
			exit(3);
		}
	}
	else if (element->dimensions != dimensions) {
		fprintf(stderr, "dimension mismatch for symbol '%s'.\n", id);
		exit(3);
	}
}

void check_not_label(symbol_table *table, char *id) {
//  check_sym(table, id, SYMBOL_TYPE_VAR, true);
}

symbol_table *assert_variable_exists(symbol_table *table, char *id) {
	symbol_table *element = symbol_table_get(table, id);

	if (element == NULL) {
		fprintf(stderr, "unknown symbol '%s'\n", id);
		exit(3);
	}

	return element;
}

void check_not_variable(symbol_table *table, char *id) {
//  check_sym(table, id, SYMBOL_TYPE_LABEL, true);
}

void check_label_exists(symbol_table *table, char *id) {
//  check_sym(table, id, SYMBOL_TYPE_LABEL, false);
}

void assert_dimensions(int a, int b) {
	if (a != b) {
		fprintf(stderr, "dimension mismatch\n");
		exit(3);
	}
}
