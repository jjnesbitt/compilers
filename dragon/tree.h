#ifndef TREE_H
#define TREE_H

#include "node.h"


typedef struct tree_s {
	int type; 		/* token type: INUM, RNUM, ID, RELOP, ADDOP, MULOP, SIGNOP, NOT, ... */
	union {
		int 	ival;	/* INUM */
		float 	rval; 	/* RNUM */
		node_t 	*sval; 	/* ID */
		int 	opval; 	/* RELOP: LT LE GT GE EQ NE */
						/* ADDOP: PLUS MINUS OR */
						/* MULOP: STAR SLASH AND */
	} attribute;

	struct tree_s *left;
	struct tree_s *right;
} tree_t;


/* Define Helper Functions */
tree_t *update_type_information(tree_t *node, tree_t *type_node);


/* Constructors */
tree_t *mktree(int type, tree_t *left, tree_t *right);

/* Special Constructors */
tree_t *mkid(node_t *);
tree_t *mkinum(int);
tree_t *mkrnum(float);
tree_t *mkop(int, int, tree_t *, tree_t *);
tree_t *mkprog(node_t *id, tree_t *ids, tree_t *decls, tree_t *subprog_decls, tree_t *compound_stmt);
tree_t *mkfor(tree_t *var, tree_t *assign_expr, tree_t *to_expr, tree_t *do_stmt);

/* Auxiliary */
void tree_print(tree_t *);

#endif
