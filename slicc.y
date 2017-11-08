%{

#include <stdio.h>
#include "Errors.h"
#include "common.h"

int yylex();

#define MAKE_EXPR(x, ret, l, r) AST* ast = makeAST(x); ast->left = l; ast->right = r; ret = ast;

%}

%union
{
  char* str;
  int d;
  float f;
  struct AST* ast;

}

//reserved words
%token ALGORITHM
%token COUNTING
%token DATA
%token DOWNWARD
%token ELSE
%token END
%token EXIT
%token IF
%token INT
%token MAIN
%token PRINT
%token READ
%token REAL
%token TO
%token UPWARD
%token WHILE

//sugar
%token BANG
%token COLON
%token COMMA
%token COMMENT
%token LBRACKET
%token LPAREN
%token RBRACKET
%token RPAREN
%token SEMI

//operators
%token ADD
%token AND
%token ASSIGN
%token DIV
%token MOD
%token MUL
%token NOT
%token OR
%token SUB

//comparison
%token EQ
%token GTE
%token GT
%token LTE
%token LT
%token NEQ

//literals
%token <d> INTLIT
%token <f> REALLIT
%token <str> STRINGLIT
%token <str> VARIABLE

//white space
%token BLANK
%token NL
%token UNKOWN

//types... they're all asts
%type <ast> algorithm;
%type <ast> expr;
%type <ast> comparison;
%type <ast> logical;
%type <ast> operators;
%type <ast> iterative;
%type <ast> factor;
%type <ast> var_or_lit;
%type <ast> var_ref;
%type <ast> stmnt_list;
%type <ast> stmnt_item;
%type <ast> assignment;
%type <ast> print;
%type <ast> print_list;
%type <ast> print_item;
%type <ast> read;
%type <ast> conditional;
%type <ast> counting;
%type <ast> bounds;
%type <ast> while;
%type <ast> exit;

%%

prog          : MAIN SEMI data algorithm END MAIN SEMI { root = $4; }
              ;

//data section grammar
data          : DATA COLON data_list
              | DATA COLON
              ;

data_list     : data_item SEMI data_list
              | data_item SEMI
              ;

data_item     : INT { symbolType = INT_TYPE; } COLON var_decl_list
              | REAL { symbolType = REAL_TYPE; } COLON var_decl_list
              ;

var_decl_list : var_decl COMMA var_decl_list
              | var_decl
              ;

var_decl      : VARIABLE
                {
                  char* name = $1;

                  Symbol* symbol = makeSymbol(name, symbolType);
                  if(addSymbol(&table, symbol))
                  {
                    errorRedefinition(symbol->name);
                    cleanSymbol(symbol);
                    YYERROR;

                  }

                }
              | VARIABLE LBRACKET INTLIT RBRACKET
                {
                  char* name = $1;
                  int size = $3;

                  if(size <= 1)
                  {
                    errorInvalidArraySize(name);
                    YYERROR;

                  }

                  Symbol* symbol = makeSymbol(name, symbolType);
                  symbol->size = size;
                  if(addSymbol(&table, symbol))
                  {
                    errorRedefinition(symbol->name);
                    cleanSymbol(symbol);
                    YYERROR;

                  }

                }
              ;

//algorithm section grammar
algorithm     : ALGORITHM COLON stmnt_list { $$ = $3; }
              | ALGORITHM COLON { $$ = NULL; }
              ;

//expressions
expr          : logical { $$ = $1; }
              ;

logical       : logical OR comparison { MAKE_EXPR(OR, $$, $1, $3); }
              | logical AND comparison { MAKE_EXPR(AND, $$, $1, $3); }
              | NOT comparison
                {
                  AST* cond = $2;
                  AST* ast = makeAST(NOT);
                  ast->cond = cond;
                  $$ = ast;

                }
              | comparison { $$ = $1; }
              ;

comparison    : comparison EQ operators { MAKE_EXPR(EQ, $$, $1, $3); }
              | comparison NEQ operators { MAKE_EXPR(NEQ, $$, $1, $3); }
              | comparison LT operators { MAKE_EXPR(LT, $$, $1, $3); }
              | comparison GT operators { MAKE_EXPR(GT, $$, $1, $3); }
              | comparison LTE operators { MAKE_EXPR(LTE, $$, $1, $3); }
              | comparison GTE operators { MAKE_EXPR(GTE, $$, $1, $3); }
              | operators { $$ = $1; }
              ;

operators     : operators ADD iterative { MAKE_EXPR(ADD, $$, $1, $3); }
              | operators SUB iterative { MAKE_EXPR(SUB, $$, $1, $3); }
              | iterative { $$ = $1; }
              ;

iterative     : iterative MUL factor { MAKE_EXPR(MUL, $$, $1, $3); }
              | iterative DIV factor { MAKE_EXPR(DIV, $$, $1, $3); }
              | iterative MOD factor { MAKE_EXPR(MOD, $$, $1, $3); }
              | factor { $$ = $1; }
              ;

factor        : SUB factor
                {
                  AST* cond = $2;
                  AST* ast = makeAST(SUB);
                  ast->cond = cond;
                  $$ = ast;

                }
              | LPAREN expr RPAREN { $$ = $2; }
              | var_or_lit { $$ = $1; }
              ;

var_or_lit    : var_ref { $$ = $1; }
              | INTLIT { $$ = makeIntLit($1); }
              | REALLIT { $$ = makeRealLit($1); }
              ;

var_ref       : VARIABLE
                {
                  char* name = $1;

                  Symbol* symbol = getSymbol(&table, name);
                  if(!symbol)
                  {
                    errorUndeclared(name);
                    YYERROR;

                  }

                  AST* ast = makeReference(symbol);
                  $$ = ast;

                }
              | VARIABLE LBRACKET expr RBRACKET
                {
                  char* name = $1;
                  AST* cond = $3;

                  Symbol* symbol = getSymbol(&table, name);
                  if(!symbol)
                  {
                    errorUndeclared(name);
                    YYERROR;

                  }

                  AST* ast = makeReference(symbol);
                  ast->cond = cond;

                  $$ = ast;

                }
              ;

//statements
stmnt_list    : stmnt_item SEMI stmnt_list
                {
                  $1->next = $3;
                  $$ = $1;

                }
              | stmnt_item SEMI { $$ = $1; }
              ;

stmnt_item    : assignment { $$ = $1; }
              | print { $$ = $1; }
              | read { $$ = $1; }
              | conditional { $$ = $1; }
              | counting { $$ = $1; }
              | while { $$ = $1; }
              | exit { $$ = $1; }
              ;

assignment    : var_ref ASSIGN expr
                {
                  AST* ast = makeAST(ASSIGN);
                  ast->left = $1;
                  ast->right = $3;
                  $$ = ast;

                }
              ;

print         : PRINT print_list
                {
                  AST* ast = makeAST(PRINT);
                  ast->left = $2;
                  $$ = ast;

                }
              ;

print_list    : print_item COMMA print_list
                {
                  $1->next = $3;
                  $$ = $1;

                }
              | print_item { $$ = $1; }
              ;

print_item    : expr { $$ = $1; }
              | STRINGLIT { $$ = makeStringLit($1); }
              | BANG { $$ = makeAST(BANG); }
              ;

read          : READ var_ref
                {
                  AST* ast = makeAST(READ);
                  ast->left = $2;
                  $$ = ast;

                }
              ;

conditional   : IF expr SEMI stmnt_list END IF
                {
                  AST* ast = makeAST(IF);
                  ast->cond = $2;
                  ast->left = $4;
                  $$ = ast;

                }
              | IF expr SEMI stmnt_list ELSE SEMI stmnt_list END IF
                {
                  AST* ast = makeAST(ELSE);
                  ast->cond = $2;
                  ast->left = $4;
                  ast->right = $7;
                  $$ = ast;

                }
              ;

counting      : COUNTING var_ref bounds SEMI stmnt_list END COUNTING
                {
                  if($2->symbol->type == REAL_TYPE)
                  {
                    errorMustCountingInt($2->symbol->name);
                    YYERROR;

                  }

                  AST* ast = makeAST(COUNTING);
                  ast->cond = $3;
                  ast->left = $2;
                  ast->right = $5;
                  $$ = ast;

                }
              ;

bounds        : UPWARD expr TO expr
                {
                  AST* ast = makeAST(UPWARD);
                  ast->left = $2;
                  ast->right = $4;
                  $$ = ast;

                }
              | DOWNWARD expr TO expr
                {
                  AST* ast = makeAST(DOWNWARD);
                  ast->left = $2;
                  ast->right = $4;
                  $$ = ast;

                }
              ;

while         : WHILE expr SEMI stmnt_list END WHILE
                {
                  AST* ast = makeAST(WHILE);
                  ast->cond = $2;
                  ast->left = $4;
                  $$ = ast;

                }
              ;

exit          : EXIT { $$  = makeAST(EXIT); }
              ;

%%

int symbolType = UNKOWN_TYPE;
