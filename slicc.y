%{

#include <stdio.h>

int yylex();
int yyerror();

#define DEBUG 1

%}

%code requires
{
  #include "SymbolTable.h"
}

%union
{
  char* str;
  int d;
  float f;
  Symbol* symbol;
  SymbolTable table;

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

%type <table> data;
%type <table> data_list
%type <table> data_item
%type <table> var_decl_list
%type <symbol> var_decl

%%

prog          : MAIN SEMI data[table] algorithm END MAIN SEMI
                {
                  printTitledSymbolTable("Symbol Table", &$table);
                  cleanSymbolTable(&$table);

                }
              ;

//data section grammar
data          : DATA COLON data_list[table]
                {
                  $$ = $table;


                }
              | DATA COLON
                {
                  $$ = makeSymbolTable();


                }
              ;

data_list     : data_item[table] SEMI data_list[other]
                {
                  combineSymbolTables(&$table, &$other);
                  $$ = $table;

                }
              | data_item[table] SEMI
                {
                  $$ = $table;

                }
              ;

data_item     : INT COLON var_decl_list[table]
                {
                  setTypeOfSymbols(&$table, INT_TYPE);
                  $$ = $table;

                }
              | REAL COLON var_decl_list[table]
                {
                  setTypeOfSymbols(&$table, REAL_TYPE);
                  $$ = $table;

                }
              ;

var_decl_list : var_decl[symbol] COMMA var_decl_list[table]
                {
                  SymbolTable newTable = makeSymbolTable();
                  addSymbol(&newTable, $symbol);
                  combineSymbolTables(&newTable, &$table);
                  $$ = newTable;

                }
              | var_decl[symbol]
                {
                  $$ = makeSymbolTable();
                  addSymbol(&$$, $symbol);

                }
              ;

var_decl      : VARIABLE[name]
                {
                  $$ = makeSymbol($name);

                }
              | VARIABLE[name] LBRACKET INTLIT[size] RBRACKET
                {
                  $$ = makeSymbol($name);
                  $$->size = $size;

                }
              ;

//algorithm section grammar
algorithm     : ALGORITHM COLON stmnt_list
              | ALGORITHM COLON
              ;

//expressions
expr          : comparison
              ;

comparison    : comparison EQ logical
              | comparison NEQ logical
              | comparison LT logical
              | comparison GT logical
              | comparison LTE logical
              | comparison GTE logical
              | logical
              ;

logical       : logical OR operators
              | logical AND operators
              | NOT operators
              | operators
              ;

operators     : operators ADD iterative
              | operators SUB iterative
              | iterative
              ;

iterative     : iterative MUL factor
              | iterative DIV factor
              | iterative MOD factor
              | factor
              ;

factor        : SUB factor
              | LPAREN expr RPAREN
              | var_or_lit
              ;

var_or_lit    : var_ref
              | INTLIT
              | REALLIT
              ;

var_ref       : VARIABLE
              | VARIABLE LBRACKET expr RBRACKET
              ;

//statements
stmnt_list    : stmnt_item SEMI stmnt_list
              | stmnt_item SEMI
              ;

stmnt_item    : assignment
              | print
              | read
              | conditional
              | counting
              | while
              | exit
              ;

assignment    : var_ref ASSIGN expr
              ;

print         : PRINT print_list
              ;

print_list    : print_item COMMA print_list
              | print_item
              ;

print_item    : expr
              | STRINGLIT
              | BANG
              ;

read          : READ var_ref
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

exit          : EXIT
              ;

%%

int yyerror()
{
  printf("yyerror()\n");
  return 0;

}
