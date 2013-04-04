typedef struct burm_state *STATEPTR_TYPE;

#ifndef CODE_BFE
#define CODE_BFE
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "ast.h"
#include "glue.h"
#endif
#ifndef ALLOC
#define ALLOC(n) malloc(n)
#endif

#ifndef burm_assert
#define burm_assert(x,y) if (!(x)) { extern void abort(void); y; abort(); }
#endif

#define burm_stat_NT 1
#define burm_ret_NT 2
#define burm_num_NT 3
int burm_max_nt = 3;

struct burm_state {
	int op;
	STATEPTR_TYPE left, right;
	short cost[4];
	struct {
		unsigned burm_stat:1;
		unsigned burm_ret:1;
		unsigned burm_num:1;
	} rule;
};

static short burm_nts_0[] = { burm_ret_NT, 0 };
static short burm_nts_1[] = { burm_num_NT, 0 };
static short burm_nts_2[] = { 0 };

short *burm_nts[] = {
	0,	/* 0 */
	burm_nts_0,	/* 1 */
	burm_nts_1,	/* 2 */
	burm_nts_2,	/* 3 */
};

char burm_arity[] = {
	0,	/* 0=O_NEQ */
	0,	/* 1=O_LT */
	0,	/* 2=O_ADD */
	0,	/* 3=O_MUL */
	0,	/* 4=O_SUB */
	0,	/* 5=O_ID */
	0,	/* 6=O_NUM */
	1,	/* 7=O_RETURN */
	0,	/* 8=O_ASSIGN */
	0,	/* 9=O_IF */
	0,	/* 10=O_WHILE */
	0,	/* 11=O_STATS */
	0,	/* 12=O_ELSE */
	0,	/* 13=O_ARRAY */
	0,	/* 14=O_OR */
	0,	/* 15=O_NOT */
	0,	/* 16=O_ARG */
};

static short burm_decode_stat[] = {
	0,
	1,
};

static short burm_decode_ret[] = {
	0,
	2,
};

static short burm_decode_num[] = {
	0,
	3,
};

int burm_rule(STATEPTR_TYPE state, int goalnt) {
	burm_assert(goalnt >= 1 && goalnt <= 3, PANIC("Bad goal nonterminal %d in burm_rule\n", goalnt));
	if (!state)
		return 0;
	switch (goalnt) {
	case burm_stat_NT:
		return burm_decode_stat[state->rule.burm_stat];
	case burm_ret_NT:
		return burm_decode_ret[state->rule.burm_ret];
	case burm_num_NT:
		return burm_decode_num[state->rule.burm_num];
	default:
		burm_assert(0, PANIC("Bad goal nonterminal %d in burm_rule\n", goalnt));
	}
	return 0;
}

static void burm_closure_ret(STATEPTR_TYPE, int);

static void burm_closure_ret(STATEPTR_TYPE p, int c) {
	if (c + 0 < p->cost[burm_stat_NT]) {
		p->cost[burm_stat_NT] = c + 0;
		p->rule.burm_stat = 1;
	}
}

STATEPTR_TYPE burm_state(int op, STATEPTR_TYPE left, STATEPTR_TYPE right) {
	int c;
	STATEPTR_TYPE p, l = left, r = right;

	if (burm_arity[op] > 0) {
		p = (STATEPTR_TYPE)ALLOC(sizeof *p);
		burm_assert(p, PANIC("ALLOC returned NULL in burm_state\n"));
		p->op = op;
		p->left = l;
		p->right = r;
		p->rule.burm_stat = 0;
		p->cost[1] =
		p->cost[2] =
		p->cost[3] =
			32767;
	}
	switch (op) {
	case 0: /* O_NEQ */
		{
			static struct burm_state z = { 0, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 1: /* O_LT */
		{
			static struct burm_state z = { 1, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 2: /* O_ADD */
		{
			static struct burm_state z = { 2, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 3: /* O_MUL */
		{
			static struct burm_state z = { 3, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 4: /* O_SUB */
		{
			static struct burm_state z = { 4, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 5: /* O_ID */
		{
			static struct burm_state z = { 5, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 6: /* O_NUM */
		{
			static struct burm_state z = { 6, 0, 0,
				{	0,
					32767,
					32767,
					0,	/* num: O_NUM */
				},{
					0,
					0,
					1,	/* num: O_NUM */
				}
			};
			return &z;
		}
	case 7: /* O_RETURN */
		assert(l);
		{	/* ret: O_RETURN(num) */
			c = l->cost[burm_num_NT] + 1;
			if (c + 0 < p->cost[burm_ret_NT]) {
				p->cost[burm_ret_NT] = c + 0;
				p->rule.burm_ret = 1;
				burm_closure_ret(p, c + 0);
			}
		}
		break;
	case 8: /* O_ASSIGN */
		{
			static struct burm_state z = { 8, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 9: /* O_IF */
		{
			static struct burm_state z = { 9, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 10: /* O_WHILE */
		{
			static struct burm_state z = { 10, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 11: /* O_STATS */
		{
			static struct burm_state z = { 11, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 12: /* O_ELSE */
		{
			static struct burm_state z = { 12, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 13: /* O_ARRAY */
		{
			static struct burm_state z = { 13, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 14: /* O_OR */
		{
			static struct burm_state z = { 14, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 15: /* O_NOT */
		{
			static struct burm_state z = { 15, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	case 16: /* O_ARG */
		{
			static struct burm_state z = { 16, 0, 0,
				{	0,
					32767,
					32767,
					32767,
				},{
					0,
					0,
					0,
				}
			};
			return &z;
		}
	default:
		burm_assert(0, PANIC("Bad operator %d in burm_state\n", op));
	}
	return p;
}

#ifdef STATE_LABEL
static void burm_label1(NODEPTR_TYPE p) {
	burm_assert(p, PANIC("NULL tree in burm_label\n"));
	switch (burm_arity[OP_LABEL(p)]) {
	case 0:
		STATE_LABEL(p) = burm_state(OP_LABEL(p), 0, 0);
		break;
	case 1:
		burm_label1(LEFT_CHILD(p));
		STATE_LABEL(p) = burm_state(OP_LABEL(p),
			STATE_LABEL(LEFT_CHILD(p)), 0);
		break;
	case 2:
		burm_label1(LEFT_CHILD(p));
		burm_label1(RIGHT_CHILD(p));
		STATE_LABEL(p) = burm_state(OP_LABEL(p),
			STATE_LABEL(LEFT_CHILD(p)),
			STATE_LABEL(RIGHT_CHILD(p)));
		break;
	}
}

STATEPTR_TYPE burm_label(NODEPTR_TYPE p) {
	burm_label1(p);
	return STATE_LABEL(p)->rule.burm_stat ? STATE_LABEL(p) : 0;
}

NODEPTR_TYPE *burm_kids(NODEPTR_TYPE p, int eruleno, NODEPTR_TYPE kids[]) {
	burm_assert(p, PANIC("NULL tree in burm_kids\n"));
	burm_assert(kids, PANIC("NULL kids in burm_kids\n"));
	switch (eruleno) {
	case 1: /* stat: ret */
		kids[0] = p;
		break;
	case 2: /* ret: O_RETURN(num) */
		kids[0] = LEFT_CHILD(p);
		break;
	case 3: /* num: O_NUM */
		break;
	default:
		burm_assert(0, PANIC("Bad external rule number %d in burm_kids\n", eruleno));
	}
	return kids;
}

int burm_op_label(NODEPTR_TYPE p) {
	burm_assert(p, PANIC("NULL tree in burm_op_label\n"));
	return OP_LABEL(p);
}

STATEPTR_TYPE burm_state_label(NODEPTR_TYPE p) {
	burm_assert(p, PANIC("NULL tree in burm_state_label\n"));
	return STATE_LABEL(p);
}

NODEPTR_TYPE burm_child(NODEPTR_TYPE p, int index) {
	burm_assert(p, PANIC("NULL tree in burm_child\n"));
	switch (index) {
	case 0:	return LEFT_CHILD(p);
	case 1:	return RIGHT_CHILD(p);
	}
	burm_assert(0, PANIC("Bad index %d in burm_child\n", index));
	return 0;
}

#endif
void burm_reduce(NODEPTR_TYPE bnode, int goalnt)
{
  int ruleNo = burm_rule (STATE_LABEL(bnode), goalnt);
  short *nts = burm_nts[ruleNo];
  NODEPTR_TYPE kids[100];
  int i;

  if (ruleNo==0) {
    fprintf(stderr, "tree cannot be derived from start symbol");
    exit(1);
  }
  burm_kids (bnode, ruleNo, kids);
  for (i = 0; nts[i]; i++)
    burm_reduce (kids[i], nts[i]);    /* reduce kids */

#if DEBUG
  printf ("%s", burm_string[ruleNo]);  /* display rule */
#endif

  switch (ruleNo) {
  case 1:
 printf("stat -> ret?\n");
    break;
  case 2:
 printf("\tmovq $%li, %%rax\n", bnode->left->value);
    break;
  case 3:
 printf("num -> O_NUM?\n");
    break;
  default:    assert (0);
  }
}
