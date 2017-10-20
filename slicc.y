%{

#include <stdio.h>
#include "Errors.h"

int yylex();

#define MAKE_EXPR(x, ret, l, r) AST* ast = makeAST(x); ast->left = l; ast->right = r; ret = ast;

%}

%code requires
{
  #include "SymbolTable.h"
  #include "AST.h"

  extern SymbolTable table;
  extern int symbolType;

  extern AST* root;

  extern char* yytext;
  extern int yylineno;
  extern char linebuf[1024];

}

%union
{
  char* str;
  int d;
  float f;
  AST* ast;

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

prog          : MAIN SEMI data algorithm[ast] END MAIN SEMI { root = $ast; }
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

var_decl      : VARIABLE[name]
                {
                  Symbol* symbol = makeSymbol($name, symbolType);
                  if(addSymbol(&table, symbol))
                  {
                    errorRedefinition(symbol->name);
                    cleanSymbol(symbol);
                    YYERROR;

                  }

                }
              | VARIABLE[name] LBRACKET INTLIT[size] RBRACKET
                {
                  Symbol* symbol = makeSymbol($name, symbolType);
                  symbol->size = $size;
                  if(addSymbol(&table, symbol))
                  {
                    errorRedefinition(symbol->name);
                    cleanSymbol(symbol);
                    YYERROR;

                  }

                }
              ;

//algorithm section grammar
algorithm     : ALGORITHM COLON stmnt_list[ast] { $$ = $ast; }
              | ALGORITHM COLON { $$ = NULL; }
              ;

//expressions
expr          : logical[ast] { $$ = $ast; }
              ;

logical       : logical[left] OR comparison[right] { MAKE_EXPR(OR, $$, $left, $right); }
              | logical[left] AND comparison[right] { MAKE_EXPR(AND, $$, $left, $right); }
              | NOT comparison[cond]
                {
                  AST* ast = makeAST(NOT);
                  ast->cond = $cond;
                  $$ = ast;

                }
              | comparison[ast] { $$ = $ast; }
              ;

comparison    : comparison[left] EQ operators[right] { MAKE_EXPR(EQ, $$, $left, $right); }
              | comparison[left] NEQ operators[right] { MAKE_EXPR(NEQ, $$, $left, $right); }
              | comparison[left] LT operators[right] { MAKE_EXPR(LT, $$, $left, $right); }
              | comparison[left] GT operators[right] { MAKE_EXPR(GT, $$, $left, $right); }
              | comparison[left] LTE operators[right] { MAKE_EXPR(LTE, $$, $left, $right); }
              | comparison[left] GTE operators[right] { MAKE_EXPR(GTE, $$, $left, $right); }
              | operators[ast] { $$ = $ast; }
              ;

operators     : operators[left] ADD iterative[right] { MAKE_EXPR(ADD, $$, $left, $right); }
              | operators[left] SUB iterative[right] { MAKE_EXPR(SUB, $$, $left, $right); }
              | iterative[ast] { $$ = $ast; }
              ;

iterative     : iterative[left] MUL factor[right] { MAKE_EXPR(MUL, $$, $left, $right); }
              | iterative[left] DIV factor[right] { MAKE_EXPR(DIV, $$, $left, $right); }
              | iterative[left] MOD factor[right] { MAKE_EXPR(MOD, $$, $left, $right); }
              | factor[ast] { $$ = $ast; }
              ;

factor        : SUB factor[cond]
                {
                  AST* ast = makeAST(SUB);
                  ast->cond = $cond;
                  $$ = ast;

                }
              | LPAREN expr[ast] RPAREN { $$ = $ast; }
              | var_or_lit[ast] { $$ = $ast; }
              ;

var_or_lit    : var_ref[ast] { $$ = $ast; }
              | INTLIT[value] { $$ = makeIntLit($value); }
              | REALLIT[value] { $$ = makeRealLit($value); }
              ;

var_ref       : VARIABLE[name]
                {
                  Symbol* symbol = getSymbol(&table, $name);
                  if(!symbol)
                  {
                    errorUndeclared($name);
                    YYERROR;

                  }

                  AST* ast = makeReference(symbol);
                  $$ = ast;

                }
              | VARIABLE[name] LBRACKET expr[cond] RBRACKET
                {
                  Symbol* symbol = getSymbol(&table, $name);
                  if(!symbol)
                  {
                    errorUndeclared($name);
                    YYERROR;

                  }

                  AST* ast = makeReference(symbol);
                  ast->cond = $cond;

                  $$ = ast;

                }
              ;

//statements
stmnt_list    : stmnt_item[ast] SEMI stmnt_list[next]
                {
                  $ast->next = $next;
                  $$ = $ast;

                }
              | stmnt_item[ast] SEMI { $$ = $ast; }
              ;

stmnt_item    : assignment[ast] { $$ = $ast; }
              | print[ast] { $$ = $ast; }
              | read[ast] { $$ = $ast; }
              | conditional[ast] { $$ = $ast; }
              | counting[ast] { $$ = $ast; }
              | while[ast] { $$ = $ast; }
              | exit[ast] { $$ = $ast; }
              ;

assignment    : var_ref[left] ASSIGN expr[right]
                {
                  AST* ast = makeAST(ASSIGN);
                  ast->left = $left;
                  ast->right = $right;
                  $$ = ast;

                }
              ;

print         : PRINT print_list[left]
                {
                  AST* ast = makeAST(PRINT);
                  ast->left = $left;
                  $$ = ast;

                }
              ;

print_list    : print_item[ast] COMMA print_list[left]
                {
                  $ast->left = $left;
                  $$ = $ast;

                }
              | print_item[ast] { $$ = $ast; }
              ;

print_item    : expr[ast] { $$ = $ast; }
              | STRINGLIT[str] { $$ = makeStringLit($str); }
              | BANG { $$ = makeAST(BANG); }
              ;

read          : READ var_ref[left]
                {
                  AST* ast = makeAST(READ);
                  ast->left = $left;
                  $$ = ast;

                }
              ;

conditional   : IF expr[cond] SEMI stmnt_list[left] END IF
                {
                  AST* ast = makeAST(IF);
                  ast->cond = $cond;
                  ast->left = $left;
                  $$ = ast;

                }
              | IF expr[cond] SEMI stmnt_list[left] ELSE SEMI stmnt_list[right] END IF
                {
                  AST* ast = makeAST(ELSE);
                  ast->cond = $cond;
                  ast->left = $left;
                  ast->right = $right;
                  $$ = ast;

                }
              ;

counting      : COUNTING var_ref[left]
                {
                  if($left->symbol->type == REAL_TYPE)
                  {
                    errorMustCountingInt($left->symbol->name);
                    YYERROR;

                  }

                }
                bounds[cond] SEMI stmnt_list[right] END COUNTING
                {
                  AST* ast = makeAST(COUNTING);
                  ast->cond = $cond;
                  ast->left = $left;
                  ast->right = $right;
                  $$ = ast;

                }
              ;

bounds        : UPWARD expr[left] TO expr[right]
                {
                  AST* ast = makeAST(UPWARD);
                  ast->left = $left;
                  ast->right = $right;
                  $$ = ast;

                }
              | DOWNWARD expr[left] TO expr[right]
                {
                  AST* ast = makeAST(DOWNWARD);
                  ast->left = $left;
                  ast->right = $right;
                  $$ = ast;

                }
              ;

while         : WHILE expr[cond] SEMI stmnt_list[left] END WHILE
                {
                  AST* ast = makeAST(WHILE);
                  ast->cond = $cond;
                  ast->left = $left;
                  $$ = ast;

                }
              ;

exit          : EXIT { $$  = makeAST(EXIT); }
              ;

%%

int symbolType = UNKOWN_TYPE;
