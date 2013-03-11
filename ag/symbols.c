#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "symbols.h"
#include "parser.h"

symbol_table *symbol_table_clone(symbol_table *table) {
	if (table == NULL)
		return NULL;

	symbol_table *result = NULL, *i = table;

	do {
		result = symbol_table_add(result, i->id, i->dimensions, 0);
	} while ((i = i->next) != NULL);

	return result;
}

symbol_table *symbol_table_new(void) {
	symbol_table *result = malloc(sizeof(symbol_table));

	if (result == NULL) {
		fprintf(stderr, "Out of memory, malloc failed (tried to allocate %lu bytes).", sizeof(symbol_table));
		exit(128);
	}

	result->next = NULL;
	result->id = NULL;
	result->dimensions = 0;

	return result;
}

symbol_table *symbol_table_add(symbol_table *table, char *id, symbol_dimensions dimensions, bool check) {
	symbol_table *result = malloc(sizeof(symbol_table));

	if (result == NULL) {
		fprintf(stderr, "Out of memory, malloc failed (tried to allocate %lu bytes).", sizeof(symbol_table));
		exit(128);
	}

	result->next = NULL;
	result->id = strdup(id);
	result->dimensions = dimensions;

	if (table == NULL)
		return result;

	if (symbol_table_get(table, id) != NULL) {
		if (check) {
			fprintf(stderr, "Duplicate symbol '%s'.\n", id);
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

	return NULL;
}

symbol_dimensions symbol_table_get_dimensions(symbol_table *table, char *id) {
	if (table == NULL)
		return 0;

	symbol_table *i = table;

	do {
		if (strcmp(i->id, id) == 0)
			return i->dimensions;
	} while ((i = i->next) != NULL);

	fprintf(stderr, "Unknown symbol '%s'.\n", id);
	symbol_table_print(table);
	exit(3);
	return -128;
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
		printf("No symbols available.\n");
		return;
	}

	fprintf(stderr, "Available symbols:\n");

	symbol_table *i = table;
	do {
		if (i->dimensions)
			fprintf(stderr, "%p\t%s\t%d-dimensional array\n", i, i->id, i->dimensions);
		else
			fprintf(stderr, "%p\t%s\tinteger\n", i, i->id);
	} while ((i = i->next) != NULL);
}

void is_array(symbol_dimensions dimensions) {
	if (dimensions > 0)
		return;
	fprintf(stderr, dimensions == 0 ? "Trying to access integer where array needed.\n" : "Trying to access symbol with invalid dimension of %d where array needed.\n", dimensions);
	exit(3);
}

void is_integer(symbol_dimensions dimensions) {
	if (dimensions != 0) {
		fprintf(stderr, "Trying to access %d-dimensional array where integer needed.\n", dimensions);
		exit(3);
	}
}

void variable_exists(symbol_table *table, char *id) {
	symbol_table *element = symbol_table_get(table, id);

	if (element == NULL) {
		fprintf(stderr, "Unknown symbol '%s'.\n", id);
		symbol_table_print(table);
		exit(3);
	}
}

void same_dimensions(symbol_dimensions a, symbol_dimensions b) {
	if (a != b) {
		fprintf(stderr, "Dimension mismatch (%d != %d).\n", a, b);
		exit(3);
	}
}
