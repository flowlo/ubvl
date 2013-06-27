#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

#include "symbol_table.h"
#include "glue.h"

symbol_table *symbol_table_clone(symbol_table *table) {
	if (table == NULL)
		return NULL;

	#ifdef DEBUG
	printf("# cloning table:\n");
	symbol_table_print(table);
	#endif

	symbol_table *result = malloc(sizeof(symbol_table));

	if (result == NULL) {
		fprintf(stderr, "Out of memory initializing new table while cloning table %p, malloc failed (tried to allocate %lu bytes).", table, sizeof(symbol_table));
		exit(42);
	}

	symbol_table *i = result, *j = table;

	while (j->next != NULL) {
		i->next = malloc(sizeof(symbol_table));

		if (i->next == NULL) {
			fprintf(stderr, "Out of memory adding symbol '%s' while cloning table %p, malloc failed (tried to allocate %lu bytes).", j->id, table, sizeof(symbol_table));
			exit(42);
		}

		i->id = strdup(j->id);
		i->reg = j->reg;
		i->dimensions = j->dimensions;
		i = i->next;
		j = j->next;
	}

	i->id = strdup(j->id);
	i->reg = j->reg;
	i->dimensions = j->dimensions;
	i->next = NULL;

	return result;
}

symbol_table *symbol_table_add(symbol_table *table, char *id, symbol_dimensions dimensions, bool check) {
	return symbol_table_add_with_reg(table, id, dimensions, check, -1);
}

symbol_table *symbol_table_add_with_reg(symbol_table *table, char *id, symbol_dimensions dimensions, bool check, char reg) {
	symbol_table *result = malloc(sizeof(symbol_table));

	if (result == NULL) {
		fprintf(stderr, "Out of memory adding symbol '%s' to table %p, malloc failed (tried to allocate %lu bytes).", id, table, sizeof(symbol_table));
		exit(42);
	}
	else if (check && symbol_table_get(table, id) != NULL) {
		fprintf(stderr, "Duplicate symbol '%s'.\n", id);
		exit(3);
	}

	#ifdef DEBUG
	printf("# added symbol '%s' with register '%s'.\n", id, regs[reg]);
	print_var_usage();
	#endif

	result->next = table;
	result->id = strdup(id);
	result->reg = reg;
	result->dimensions = dimensions;

	return result;
}

symbol_table *symbol_table_add_var(symbol_table *table, char *id, symbol_dimensions dimensions, bool check) {
	return symbol_table_add_with_reg(table, id, dimensions, check, reg_new_var());
}

symbol_table *symbol_table_add_par(symbol_table *table, char *id, symbol_dimensions dimensions, bool check) {
	/* when adding the first parameter, clear register allocations. TODO move this to a more suitable place. */
	if (table == NULL)
		reg_reset();

	return symbol_table_add_with_reg(table, id, dimensions, check, reg_new_par());
}

symbol_table *symbol_table_get(symbol_table *table, char *id) {
	symbol_table *i = table;

	while (i != NULL) {
		if (strcmp(i->id, id) == 0)
			return i;

		i = i->next;
	}

	return NULL;
}

symbol_dimensions symbol_table_get_dimensions(symbol_table *table, char *id) {
	table = symbol_table_get(table, id);
	if (table == NULL) {
		fprintf(stderr, "Unknown symbol '%s'.\n", id);
		symbol_table_print(table);
		exit(3);
	}
	return table->dimensions;
}

symbol_table *symbol_table_merge(symbol_table *a, symbol_table *b, bool check) {
	if (a == NULL)
		return symbol_table_clone(b);
	if (b == NULL)
		return symbol_table_clone(a);

	symbol_table *result = malloc(sizeof(symbol_table));

	if (result == NULL) {
		fprintf(stderr, "Out of memory initializing new table in order to merge tables %p and %p, malloc failed (tried to allocate %lu bytes).", a, b, sizeof(symbol_table));
		exit(42);
	}

	symbol_table *i = result, *j = b;

	while (j->next != NULL) {
		i->next = malloc(sizeof(symbol_table));

		if (i->next == NULL) {
			fprintf(stderr, "Out of memory adding symbol '%s' while merging tables %p and %p, malloc failed (tried to allocate %lu bytes).", j->id, a, b, sizeof(symbol_table));
			exit(42);
		}

		i->id = strdup(j->id);
		i->reg = j->reg;
		i->dimensions = j->dimensions;
		i = i->next;
		j = j->next;
	}

	j = a;

	while (j->next != NULL) {
		i->next = malloc(sizeof(symbol_table));

		if (i->next == NULL) {
			fprintf(stderr, "Out of memory adding symbol '%s' while merging tables %p and %p, malloc failed (tried to allocate %lu bytes).", j->id, a, b, sizeof(symbol_table));
			exit(42);
		}

		i->id = strdup(j->id);
		i->reg = j->reg;
		i->dimensions = j->dimensions;
		i = i->next;
		j = j->next;
	}

	i->id = strdup(j->id);
	i->reg = j->reg;
	i->dimensions = j->dimensions;
	i->next = NULL;

	return result;
}

void symbol_table_print(symbol_table *table) {
	if (table == NULL) {
		printf("# no symbols available.\n");
		return;
	}

	fprintf(stderr, "# available symbols:\n");

	symbol_table *i = table;
	do {
		if (i->dimensions)
			fprintf(stderr, "# %p\t%s\t%d-dimensional array\t%%%s\n", i, i->id, i->dimensions, regs[i->reg]);
		else
			fprintf(stderr, "# %p\t%s\tinteger\t%%%s\n", i, i->id, regs[i->reg]);
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

	printf("# identified '%s' as %p in register '%s'.\n", id, element, regs[element->reg]);
}

void same_dimensions(symbol_dimensions a, symbol_dimensions b) {
	if (a != b) {
		fprintf(stderr, "# dimension mismatch (%d != %d).\n", a, b);
		exit(3);
	}
#ifdef DEBUG
	printf("# successfull dimension match (%d == %d).\n", a, b);
#endif
}
