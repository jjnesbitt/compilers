%{
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include "scope.h"
#include "tree.h"
#include "type.h"
#include "y.tab.h"

extern int yyerror(char*);
extern int yylex();

extern scope_t *top_scope;

#define ECHO 1

%}

%union {
    int ival;   /* INUM */
    float rval; /* RNUM */
    int opval;  /* RELOP ADDOP MULOP */
    char *sval; /* ID */
    /*********************************/
    tree_t *tval;
}

%token PROGRAM PROGRAM_ROOT PROGRAM_NODE
%token SUBPROGRAM SUBPROGRAM_ROOT SUBPROGRAM_NODE
%token BBEGIN END
%token VAR
%token PROCEDURE FUNCTION
%token ARRAY OF
%token INTEGER REAL
%token RESULT

%token IF THEN ELSE
%token WHILE DO
%token FOR TO

%token ASSIGNOP
%token <opval> RELOP
%token EQ NE LT LE GT GE
%token <opval> ADDOP
%token PLUS MINUS OR
%token <opval> MULOP
%token STAR SLASH DIV MOD AND
%token NOT

%token DOTDOT
%token <sval> ID
%token <ival> INUM
%token <rval> RNUM

%token LISTOP

%token ARRAY_ACCESS
%token FUNCTION_CALL
%token PROCEDURE_CALL


%token ERROR
%token BOOL





%type <tval> program;
%type <tval> identifier_list;
%type <tval> declarations;
%type <tval> sub_declarations;
%type <tval> type;                      /* Probably wrong */
%type <tval> standard_type;
%type <tval> subprogram_declarations;
%type <tval> subprogram_declaration;
%type <tval> subprogram_head;
%type <tval> arguments;
%type <tval> parameter_list;
%type <tval> compound_statement;
%type <tval> optional_statements;
%type <tval> statement_list;
%type <tval> statement;
%type <tval> matched_statement;
%type <tval> unmatched_statement;
%type <tval> variable;
%type <tval> procedure_statement;
%type <tval> expression_list;
%type <tval> expression;
%type <tval> simple_expression;
%type <tval> term;
%type <tval> factor;

//%type <ival> sign;

%%

start:
    program   {tree_print($1);}
    ;

program:
    PROGRAM ID '(' identifier_list ')' ';'
    declarations
    subprogram_declarations
    compound_statement
    '.'
    {$$ = mkprog(scope_insert(top_scope, $2), $4, $7, $8, $9); }
    ;

identifier_list:
    ID {
        if (scope_search(top_scope, $1) != NULL) {
            yyerror("ID defined twice");
        }
        $$ = mkid(scope_insert(top_scope, $1));
    }
    | identifier_list ',' ID    
        {
            if (scope_search(top_scope, $3) != NULL) {
                yyerror("ID defined twice");
            }
            $$ = mktree(LISTOP, $1, mkid(scope_insert(top_scope, $3)));
        }
    ;

declarations:
    declarations VAR sub_declarations       {$$ = mktree(LISTOP, $1, $3); }
    | /* empty */                           {$$ = NULL; }
    ;

sub_declarations:
    sub_declarations identifier_list ':' type ';'   { $$ = mktree(LISTOP, $1, update_type($2, $4)); }
    | identifier_list ':' type ';'                  { $$ = update_type($1, $3); }
    ;

type:
    standard_type                                           {$$ = $1; }
    | ARRAY '[' INUM DOTDOT INUM ']' OF standard_type       {$$ = mkarray(mkinum($3), mkinum($3), $8); }
    ;

standard_type:
    INTEGER         {$$ = mktree(INTEGER, NULL, NULL); }
    | REAL          {$$ = mktree(REAL, NULL, NULL); }
    ;

subprogram_declarations:
    subprogram_declarations subprogram_declaration ';'      {$$ = mktree(LISTOP, $1, $2); }
    | /* empty */                                           {$$ = NULL; }
    ;

subprogram_declaration:
    subprogram_head
    declarations
    subprogram_declarations
    compound_statement
		{ 
            $$ = mksubprog($1, $2, $3, $4);
            /* pop current scope */ 
            fprintf(stderr, "-----------POP--------\n");
            top_scope = pop_scope(top_scope);
        }
    ;

subprogram_head:
    FUNCTION ID {
            if (scope_search(top_scope, $2) != NULL) {
                yyerror("Function ID defined twice");
            }
            node_t *func_id = scope_insert(top_scope, $2);
            fprintf(stderr, "-----------PUSH--------\n");
            top_scope = push_scope(top_scope);
    } arguments ':' maybe_result standard_type ';' { 
            /* push new scope and update type info of ID */
            node_t *func_id_node = scope_search_all(top_scope, $2);
            $$ = mktree(FUNCTION, update_type(mkid(func_id_node), $7), $4);
    }
    | PROCEDURE ID {
        if (scope_search(top_scope, $2) != NULL) {
            yyerror("Procedure ID defined twice");
        }
        node_t *proc_id = scope_insert(top_scope, $2);
        fprintf(stderr, "-----------PUSH--------\n");
        top_scope = push_scope(top_scope);
    } arguments ';' {
        node_t *proc_id_node = scope_search_all(top_scope, $2);
        $$ = mktree(PROCEDURE, mkid(proc_id_node), $4);
    }
    ;

maybe_result:
    RESULT
    | /* empty */
    ;

arguments: 
    '(' parameter_list ')'      {$$ = $2; }
    | /* empty */               {$$ = NULL; }
    ;

parameter_list:
    identifier_list ':' type
        {$$ = update_type($1, $3); /* update type information of $1 with $3 */ }
    | parameter_list ';' identifier_list ':' type
        {$$ = mktree(LISTOP, $1, update_type($3, $5));  /* update type info of $3 with $5 */}
    ;

compound_statement:
    BBEGIN optional_statements END    {$$ = mktree(BBEGIN, $2, mktree(END, NULL, NULL)); }
    ;

optional_statements:
    statement_list      {$$ = $1;}
    | /* empty */       {$$ = NULL;}
    ;

statement_list:
    statement                           {$$ = $1; }
    | statement_list ';' statement      {$$ = mktree(LISTOP, $1, $3); }
    ;

statement:
    matched_statement       {$$ = $1;}
    | unmatched_statement   {$$ = $1;}
    ;

matched_statement:
    IF expression THEN matched_statement ELSE matched_statement
        {   
            /* Check that expression is BOOLEAN */
            $$ = mktree(IF, $2, mktree(THEN, $4, $6));
        }
    | variable ASSIGNOP expression
        {
            /* Check that variable and expression are the same type */
            eval_type($1);
            eval_type($3);
            if (super_type($1) != super_type($3)){
                yyerror("Mismatched types in assignment");
            }

            $$ = mktree(ASSIGNOP, $1, $3);
        }
    | procedure_statement
        {$$ = $1;}
    | compound_statement
        {$$ = $1;}
    | WHILE expression DO matched_statement /* statement instead of matched_statement causes shift/reduce conflict */  
        {
            /* Check that expression is BOOLEAN */
            check_bool($2);
            $$ = mktree(WHILE, $2, $4); 
        }
    | FOR variable ASSIGNOP simple_expression TO simple_expression DO matched_statement
        {
            /* Check that types of variable? and both expressions match */
            eval_type($2);
            eval_type($4);
            eval_type($6);

            if (super_type($2) != super_type($4) || super_type($4) != super_type($6)){
                yyerror("Type mismatch in FOR expression");
            }

            $$ = mkfor($2, $4, $6, $8); 
        }
    ;

unmatched_statement:
      IF expression THEN statement                                      
        {   
            /* Check that expression is BOOLEAN */
            // eval_type($2);
            // if (super_type($2) != BOOL) {
            //     yyerror("Using non-boolean expression in conditional statment");
            // }

            check_bool($2);
            $$ = mktree(IF, $2, $4);
        }
    | IF expression THEN matched_statement ELSE unmatched_statement     
        {
            /* Check that expression is BOOLEAN */
            // eval_type($2);
            // if (super_type($2) != BOOL) {
            //     yyerror("Using non-boolean expression in conditional statment");
            // }

            check_bool($2);
            $$ = mktree(IF, $2, mktree(THEN, $4, $6));
        }
    ;

/* ------------------below here should use mkid(symtab_search) for IDs? */

variable:
      ID
        {
            $$ = mkid(scope_search_all(top_scope, $1));
        }
    | ID '[' expression ']'
        {
            /* Array access */
            /* Check that expression is of type INTEGER */
            eval_type($3);
            if (super_type($3) != INTEGER){
                yyerror("Array Access with non-integer type");
            }

            $$ = mkid(scope_search_all(top_scope, $1)); 
        }
    ;

procedure_statement:
      ID                            {$$ = mkid(scope_search_all(top_scope, $1));}
    | ID '(' expression_list ')'    {$$ = mktree(PROCEDURE_CALL, mkid(scope_search_all(top_scope, $1)), $3);}
    ;

expression_list:
    expression                          {$$ = $1;}
    | expression_list ',' expression    {$$ = mktree(LISTOP, $1, $3);}
    ;

expression:
    simple_expression                           {$$ = $1; }
    | simple_expression RELOP simple_expression {$$ = mkop(RELOP, $2, $1, $3); /* BOOLEAN TYPE */}
    ;

simple_expression:
    /* Here, need to check type of all children, to ensure matching */
    term                                { $$ = $1; }
    /* | sign term                      { $$ = mkop(ADDOP, $?, 0, $2); } */
    | simple_expression ADDOP term      { $$ = mkop(ADDOP, $2, $1, $3); }
    ;
    /* issue here, sign should be lower than ADDOP */

term:
    factor                  {$$ = $1; }
    | term MULOP factor     {$$ = mkop(MULOP, $2, $1 ,$3);}
    ;

factor:
    ID                              { $$ = mkid(scope_search_all(top_scope, $1));}
    | ID '[' expression ']'         
        { 
            eval_type($3);
            if (super_type($3) != INTEGER){
                yyerror("Array Access with non-integer type");
            }

            $$ = mktree(ARRAY_ACCESS, mkid(scope_search_all(top_scope, $1)), $3);
        }
    | ID '(' expression_list ')'    { $$ = mktree(FUNCTION_CALL, mkid(scope_search_all(top_scope, $1)), $3);}
    | INUM                          { $$ = mkinum($1); }
    | RNUM                          { $$ = mkrnum($1); }
    | '(' expression ')'            { $$ = $2;}
    | NOT factor                    { $$ = mktree(NOT, $2, NULL);}
    ;

/* Not sure what to do with sign */
/* 
sign
    : '+' {$$ =  1;}
    | '-' {$$ = -1;}
    ;
 */


%%

scope_t *top_scope;
int CURRENT_LINE_NUM;

int main() {
    top_scope = mkscope();
    yyparse();
}
