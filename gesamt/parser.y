%{
#ifndef DEBUG
#pragma GCC diagnostic ignored "-Wformat"
#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic ignored "-Wimplicit"
#pragma GCC diagnostic ignored "-Wparentheses"
#endif
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "symbol_table.h"
#include "ast.h"
#include "glue.h"

#define YYERROR_VERBOSE

extern int yylineno;
extern int yyerror(const char*);
extern int yylex(void);
%}

%left  '+'  '-'
%left  '*'
%token T_ID T_NUM T_END T_ARRAY T_OF T_INT T_RETURN T_IF T_THEN T_ELSE T_WHILE T_DO T_VAR T_NOT T_OR T_ASSIGN
%start Dummy

@autoinh labels relevant
@autosyn node dimensions labels_out call

@attributes { int value; } T_NUM
@attributes { char *value; } T_ID
@attributes { symbol_table *sym; } Pars
@attributes { symbol_dimensions dimensions; } Type
@attributes {
	int labels;
	int labels_out;
} Funcdef Program
@attributes {
	@autoinh symbol_table *sym;
	ast_node *node;
	bool call;
} Args Bterm Bool
@attributes {
	@autoinh symbol_table *sym;
	int labels;
	int labels_out;
	bool relevant;
	bool call;
} Stats
@attributes {
	@autoinh symbol_table *sym;
	int labels;
	int labels_out;
	bool relevant;
	int hook;
	bool jump;
	bool call;
} Else
@attributes {
	@autoinh symbol_table *sym;
	int labels;
	int labels_out;
	bool relevant;
	symbol_table *out;
	bool call;
} Stat
@attributes {
	@autosyn char* value;
	symbol_dimensions dimensions;
} Vardef
@attributes {
	@autoinh symbol_table *sym;
	ast_node *node;
	symbol_dimensions dimensions;
	bool call;
} Expr Term Lexpr Add Sub Mul

@traversal @preorder assert
@traversal @preorder code

@macro arithmetic(op,)
        @i @op.dimensions@ = @Term.0.dimensions@ + @Term.1.dimensions@;
	@i @op.call@ = @Term.0.call@ || @Term.1.call@;
        @assert is_integer(@Term.0.dimensions@); is_integer(@Term.1.dimensions@);
@end

@macro arithmeticRecursive(op,)
        @i @op.0.dimensions@ = @op.1.dimensions@ + @Term.dimensions@;
	@i @op.0.call@ = @Term.0.call@ || @op.1.call@;
        @assert is_integer(@op.1.dimensions@); is_integer(@Term.dimensions@);
@end

@macro boolean(type,)
	@i @Bterm.node@ = node_new(type, @Expr.0.node@, @Expr.1.node@);
	@i @Bterm.call@ = @Expr.0.call@ || @Expr.1.call@;
	@assert is_integer(@Expr.0.dimensions@); is_integer(@Expr.1.dimensions@);
@end

%%
Dummy	:	Program
@{
	@i @Program.labels@ = 0;
@}
Program	:	Funcdef ';' Program
@{
	@i @Funcdef.labels@ = @Program.0.labels@;
	@i @Program.1.labels@ = @Funcdef.labels_out@;
	@i @Program.0.labels_out@ = @Program.1.labels_out@;
@}
	|
@{
	@i @Program.labels_out@ = 0;
@}
	;
Vardef	:	T_ID ':' Type
	;
Args	:	Expr
@{
	@i @Args.node@ = node_new(O_ARG, node_new(O_NULL, NULL, NULL), @Expr.node@);
@}
	|	Args ',' Expr
@{
	@i @Args.0.node@ = node_new(O_ARG, @Args.1.node@, @Expr.node@);
	@i @Args.0.call@ = @Args.1.call@ || @Expr.call@;
@}
	;
Bool	:	Bterm
	|	Bool T_OR Bterm
@{
		@i @Bool.0.node@ = node_new(O_OR, @Bool.1.node@, @Bterm.node@);
		@i @Bool.0.call@ = @Bool.1.call@ || @Bterm.call@;
@}
	;
Bterm	:	'(' Bool ')'
	|	T_NOT Bterm					@{ @i @Bterm.0.node@ = node_new(O_NOT, @Bterm.1.node@, NULL); @}
	|	Expr '#' Expr					@{ boolean(O_NEQ,) @}
	|	Expr '<' Expr					@{ boolean(O_LT,) @}
	;
Expr    :       Term | Add | Sub | Mul ;
Add     :       Term '+' Term
@{
	arithmetic(Add,)
	@e Add.node : Term.node Term.1.node ; if (@Term.node@->is_imm && @Term.1.node@->is_imm) { @Add.node@ = node_new_num(@Term.node@->value + @Term.1.node@->value); } else if (!@Term.node@->is_imm) { @Add.node@ = node_new(O_ADD, @Term.0.node@, @Term.1.node@); } else { @Add.node@ = node_new(O_ADD, @Term.1.node@, @Term.0.node@); }
@}
        |       Add '+' Term
@{
	arithmeticRecursive(Add,)
	@e Add.node : Add.1.node Term.node ; if (@Add.1.node@->is_imm && @Term.node@->is_imm) { @Add.0.node@ = node_new_num(@Add.1.node@->value + @Term.node@->value); } else if (!@Add.1.node@->is_imm) { @Add.0.node@ = node_new(O_ADD, @Add.1.node@, @Term.node@); } else { @Add.node@ = node_new(O_ADD, @Term.node@, @Add.1.node@); }
@}
        ;
Sub     :       Term '-' Term
@{
	arithmetic(Sub,)
	@i {
		@Sub.0.node@ =
			(@Term.0.node@->is_imm && @Term.1.node@->is_imm)
			?
				node_new_num(@Term.0.node@->value - @Term.1.node@->value)
			:
				(@Term.1.node@->is_imm && @Term.1.node@->value == 0)
				?
					@Term.0.node@
				:
				node_new(O_SUB, @Term.0.node@, @Term.1.node@);
	}
@}
	|	Sub '-' Term
@{
	arithmeticRecursive(Sub,)
        @i {
                @Sub.0.node@ =
			(@Sub.1.node@->is_imm && @Term.node@->is_imm)
			?
				node_new_num(@Sub.1.node@->value - @Term.node@->value)
			:
				(@Term.node@->is_imm && @Term.node@->value == 1)
				?
					@Sub.1.node@
				:
					(@Term.0.node@->is_imm && @Term.0.node@->value == 0)
					?
						@Sub.1.node@
					:
					node_new(O_SUB, @Sub.1.node@, @Term.node@);
        }
@}
        ;
Mul	:	Term '*' Term
@{
	arithmetic(Mul,)
	@i {
		@Mul.0.node@ =
			(@Term.0.node@->is_imm && @Term.1.node@->is_imm)
			?
				node_new_num(@Term.0.node@->value * @Term.1.node@->value)
			:
				(@Term.0.node@->is_imm && @Term.0.node@->value == 1)
				?
					@Term.1.node@
				:
					(@Term.1.node@->is_imm && @Term.1.node@->value == 1)
					?
						@Term.0.node@
					:
						(@Term.0.node@->is_imm)
						?
							node_new(O_MUL, @Term.1.node@, @Term.0.node@)
						:
							node_new(O_MUL, @Term.0.node@, @Term.1.node@);
	}
@}
        |       Mul '*' Term
@{
	arithmeticRecursive(Mul,)
        @i {
                @Mul.0.node@ =
			(@Mul.1.node@->is_imm && @Term.node@->is_imm)
			?
				node_new_num(@Mul.1.node@->value * @Term.node@->value)
			:
				(@Mul.1.node@->is_imm && @Mul.1.node@->value == 1)
				?
					@Term.node@
				:
					(@Term.0.node@->is_imm && @Term.0.node@->value == 1)
					?
						@Mul.1.node@
					:
						(@Mul.1.node@->is_imm)
						?
							node_new(O_MUL, @Term.node@, @Mul.1.node@)
						:
							node_new(O_MUL, @Mul.1.node@, @Term.node@);
        }
@}
        ;
Else	:	Stats T_END
@{
	@code {
		@Stats.relevant@ = @Else.relevant@;
		@Else.call@ = @Stats.call@;
		if (@Else.jump@) {
			printi("jmp L%ld # else", @Else.hook@ + 2);
			printl(@Else.hook@ + 1);
		}
	}
@}
	;
Stat	:	T_RETURN Expr
@{
	@i @Stat.out@ = @Stat.sym@;
	@i @Stat.labels_out@ = @Stat.labels@;
	@i @Stat.call@ = @Expr.call@;

	@code {
		if (@Stat.relevant@) {
			burm_invoke(@Expr.node@);
			if (@Expr.node@->is_imm) {
				printi("movq $%ld, %%rax", @Expr.node@->value);
			} else {
				move(@Expr.node@->reg, 0);
			}

/*			if (need_stack)
				printi("leave");
*/
			printi("ret");
		}
	}
@}
	|	T_IF Bool T_THEN Stats T_END
@{
	@i @Stat.out@ = @Stat.sym@;
	@i @Stats.labels@ = @Stat.labels@ + 2;
	@i @Stat.call@ = @Bool.call@ || @Stats.call@;

	@code {
		if (@Stat.relevant@) {
			label = @Stat.labels@;
			burm_invoke(@Bool.node@);
			if (@Bool.node@->is_imm) {
				@Stats.relevant@ = @Bool.node@->value;
				@Stat.call@ = @Stats.relevant@ && @Stats.call@;
			} else {
				printi("jmp L%ld", @Stat.labels@ + 1);
				@Stats.relevant@ = true;
				printl(@Stat.labels@);
			}
		} else {
			@Stats.relevant@ = false;
		}
	}
	@code @revorder(1) {
		if (@Stat.relevant@ && !@Bool.node@->is_imm) {
			printl(@Stat.labels@ + 1);
		}
	}
@}
	|	T_IF Bool T_THEN Stats T_ELSE Else
@{
	@i @Stat.out@ = @Stat.sym@;
	@i @Stats.labels@ = @Stat.labels@ + 3;
	@i @Else.hook@ = @Stat.labels@;
	@i @Else.labels@ = @Stats.labels_out@;
	@i @Stat.labels_out@ = @Else.labels_out@;
	@i @Else.jump@ = true;
	@i @Stat.call@ = @Bool.call@ || @Stats.call@ || @Else.call@;

	@code {
		if (@Stat.relevant@) {
			label = @Stat.labels@;
			burm_invoke(@Bool.node@);
			if (!@Bool.node@->is_imm) {
				printi("jmp L%ld", @Stat.labels@ + 1);
				printl(@Stat.labels@);
			} else if (@Bool.node@->value) {
				printf("# if condition is always true\n");
				@Else.relevant@ = false;
				@Else.jump@ = false;
			} else {
				printf("# if condition is always false\n");
				@Stats.relevant@ = false;
				@Else.jump@ = false;
			}
		} else {
			@Else.relevant@ = false;
			@Else.jump@ = false;
			@Stats.relevant@ = false;
			@Stat.call@ = false;
		}
	}
	@code @revorder(1) {
		if (@Stat.relevant@ && !@Bool.node@->is_imm) {
			printl(@Stat.labels@ + 2);
		}
	}
@}
	|	T_WHILE Bool T_DO Stats T_END
@{
	@i @Stat.out@ = @Stat.sym@;
	@i @Stats.labels@ = @Stat.labels@ + 3;
	@i @Stat.call@ = @Bool.call@ || @Stats.call@;

	@code {
		@Stats.relevant@ = @Stat.relevant@;
		if (@Stat.relevant@) {
			printl(@Stat.labels@);
			label = @Stat.labels@ + 1;
			burm_invoke(@Bool.node@);
			if (@Bool.node@->is_imm) {
				if (@Bool.node@->value) {
					printf("# warning: infinite loop detected\n");
				} else {
					@Stats.relevant@ = false;
				}
			} else {
				printi("jmp L%ld", @Stat.labels@ + 2);
				printl(@Stat.labels@ + 1);
			}
		} else {
			@Stat.call@ = false;
		}
	}
	@code @revorder(1) {
		if (@Stat.relevant@ && @Stats.relevant@) {
			printi("jmp L%ld", @Stat.labels@);
			if (!@Bool.node@->is_imm) {
				printl(@Stat.labels@ + 2);
			}
		}
	}
@}
	|	Term
@{
	@i @Stat.out@ = @Stat.sym@;
	@i @Stat.labels_out@ = @Stat.labels@;

	@code {
		burm_invoke(@Term.node@);
	}
@}
	|	T_VAR Vardef T_ASSIGN Expr
@{
	@i @Stat.out@ = symbol_table_add_var(symbol_table_clone(@Stat.sym@), @Vardef.value@, @Vardef.dimensions@, false);
	@i @Stat.labels_out@ = @Stat.labels@;

	@assert same_dimensions(@Vardef.dimensions@, @Expr.dimensions@);

	@code {
		if (@Stat.relevant@) {
			burm_invoke(@Expr.node@);
			if (@Expr.node@->is_imm) {
				printi("movq $%li, %%%s", @Expr.node@->value, regs[symbol_table_get(@Stat.out@, @Vardef.value@)->reg]);
			} else {
				move(@Expr.node@->reg, symbol_table_get(@Stat.out@, @Vardef.value@)->reg);
			}
		}
	}
@}
	|	Lexpr T_ASSIGN Expr
@{
	@i @Stat.out@ = @Stat.sym@;
	@i @Stat.labels_out@ = @Stat.labels@;
	@i @Stat.call@ = @Lexpr.call@ || @Expr.call@;

	@assert same_dimensions(@Lexpr.dimensions@, @Expr.dimensions@);

	@code {
		if (@Stat.relevant@) {
			ast_node *dummy = node_new(O_LEXPR, @Lexpr.node@, @Expr.node@);
			burm_invoke(dummy);
		} else {
			@Stat.call@ = false;
		}
	}
@}
	;
Funcdef	:	T_ID '(' Pars ')' Stats T_END
@{
	@e Stats.sym : Pars.sym ; @Stats.sym@ = symbol_table_merge(@Pars.sym@, @Stats.sym@, true); reg_reset();
	@i @Stats.relevant@ = true;

	@code funcdef(@T_ID.value@, @Pars.sym@, @Stats.call@);
@}
	|	T_ID '(' ')' Stats T_END
@{
	@i @Stats.sym@ = NULL; reg_reset();
	@i @Stats.labels@ = 0;
	@i @Stats.relevant@ = true;

	@code funcdef(@T_ID.value@, NULL, @Stats.call@);
@}
	;
Type	:	T_INT						@{ @i @Type.dimensions@ = 0; @}
	|	T_ARRAY T_OF Type				@{ @i @Type.0.dimensions@ = @Type.1.dimensions@ + 1; @}
	;
Stats	:	Stat ';' Stats
@{
	@i @Stats.1.sym@ = @Stat.out@;
	@i @Stats.1.labels@ = @Stat.labels_out@;
	@i @Stats.0.labels_out@ = @Stats.1.labels_out@;
	@i @Stats.0.call@ = @Stats.1.call@ || @Stat.call@;

	@code {
		@Stat.relevant@ = @Stats.0.relevant@;
		@Stats.1.relevant@ = @Stats.0.relevant@;
	}
@}
	|
@{
	@i @Stats.labels_out@ = @Stats.labels@;
	@i @Stats.call@ = false;
@}
	;
Pars	:	Vardef 						@{ @i @Pars.sym@ = symbol_table_add_par(NULL, @Vardef.value@, @Vardef.dimensions@, true); @}
	|	Pars ',' Vardef					@{ @i @Pars.0.sym@ = symbol_table_add_par(@Pars.1.sym@, @Vardef.value@, @Vardef.dimensions@, true); @}
	;

Lexpr	:	T_ID
@{
	@i @Lexpr.dimensions@ = symbol_table_get_dimensions(@Lexpr.sym@, @T_ID.value@);
	@i @Lexpr.node@ = node_new_id(@T_ID.value@, @Lexpr.sym@);
	@i @Lexpr.call@ = false;
@}
	|	Term '[' Expr ']'
@{
	@i @Lexpr.dimensions@ = @Term.dimensions@ - 1;
	@i @Lexpr.node@ = node_new(O_ARRAY, @Term.node@, @Expr.node@);
	@i @Lexpr.call@ = @Term.call@ || @Expr.call@;
	@assert is_array(@Term.dimensions@); is_integer(@Expr.dimensions@);
@}
	;
Term	:	'(' Expr ')'
	|	T_ID '(' Args ')' ':' Type
@{
	@i @Term.node@ = node_new_call(@T_ID.value@, @Args.node@);
	@i @Term.call@ = true;
@}
	|	T_ID '(' ')' ':' Type
@{
	@i @Term.node@ = node_new_call(@T_ID.value@, node_new(O_NULL, NULL, NULL));
	@i @Term.call@ = true;
@}
	|	T_NUM
@{
	@i @Term.dimensions@ = 0;
	@i @Term.node@ = node_new_num(@T_NUM.value@);
	@i @Term.call@ = false;
@}
	|	Term '[' Expr ']'
@{
	@i @Term.0.dimensions@ = @Term.1.dimensions@ - 1;
	@i @Term.0.node@ = node_new(O_ARRAY, @Term.1.node@, @Expr.node@);
	@i @Term.0.call@ = @Term.1.call@ || @Expr.call@;

	@assert is_array(@Term.1.dimensions@); is_integer(@Expr.dimensions@);
@}
	|	T_ID
@{
	@i @Term.dimensions@ = symbol_table_get_dimensions(@Term.sym@, @T_ID.value@);
	@i @Term.node@ = node_new_id(@T_ID.value@, @Term.sym@);
	@i @Term.call@ = false;
@}
	;
%%

int yyerror(const char *e) {
	printf("%s on line %d\n", e, yylineno);
	exit(2);
}

int main(int argc, char **argv) {
	char c = '\0';
	while ((c = getopt (argc, argv, "a")) != -1)
		switch (c) {
			case 'a':
				print_trees = true;
				printf("# printing trees for expressions \n");
			break;
		}

	return yyparse();
}
