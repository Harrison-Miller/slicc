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
expr          : comparison[ast] { $$ = $ast; }
              ;

comparison    : comparison[left] EQ logical[right] { MAKE_EXPR(EQ, $$, $left, $right); }
              | comparison[left] NEQ logical[right] { MAKE_EXPR(NEQ, $$, $left, $right); }
              | comparison[left] LT logical[right] { MAKE_EXPR(LT, $$, $left, $right); }
              | comparison[left] GT logical[right] { MAKE_EXPR(GT, $$, $left, $right); }
              | comparison[left] LTE logical[right] { MAKE_EXPR(LTE, $$, $left, $right); }
              | comparison[left] GTE logical[right] { MAKE_EXPR(GTE, $$, $left, $right); }
              | logical[ast] { $$ = $ast; }
              ;

logical       : logical[left] OR operators[right] { MAKE_EXPR(OR, $$, $left, $right); }
              | logical[left] AND operators[right] { MAKE_EXPR(AND, $$, $left, $right); }
              | NOT operators[next]
                {
                  AST* ast = makeAST(NOT);
                  ast->next = $next;
                  $$ = ast;

                }
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

factor        : SUB factor[next]
                {
                  AST* ast = makeAST(SUB);
                  ast->next = $next;
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
              | VARIABLE[name] LBRACKET expr[left] RBRACKET
                {
                  Symbol* symbol = getSymbol(&table, $name);
                  if(!symbol)
                  {
                    errorUndeclared($name);
                    YYERROR;

                  }

                  AST* ast = makeReference(symbol);
                  ast->left = $left;

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
              | conditional
              | counting
              | while
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

conditional   : IF expr SEMI stmnt_list END IF
              | IF expr SEMI stmnt_list ELSE SEMI stmnt_list END IF
              ;

counting      : COUNTING var_ref bounds SEMI stmnt_list END COUNTING
              ;

bounds        : UPWARD expr TO expr
              | DOWNWARD expr TO expr
              ;

while         : WHILE expr SEMI stmnt_list END WHILE
              ;

exit          : EXIT { $$  = makeAST(EXIT); }
              ;

%%

int symbolType = UNKOWN_TYPE;
