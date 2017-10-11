%{

#include <stdio.h>

%}

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
%token INTLIT
%token UINTLIT
%token REALLIT
%token STRINGLIT
%token VARIABLE

//white space
%token BLANK
%token NL
%token UNKOWN

%%

prog          : MAIN SEMI data algorithm END MAIN SEMI
              ;

//data section grammar
data          : DATA COLON data_list
              | DATA COLON
              ;

data_list     : data_item data_list
              | data_item
              ;

data_item     : INT COLON var_decl_list SEMI
              | REAL COLON var_decl_list SEMI
              ;

var_decl_list : var_decl COMMA var_decl_list
              | var_decl
              ;

var_decl      : VARIABLE
              | VARIABLE LBRACKET INTLIT RBRACKET
              ;

//algorithm section grammar
algorithm     : ALGORITHM COLON stmnt_list
              | ALGORITHM COLON
              ;

stmnt_list    : stmnt_item COMMA stmnt_list
              | stmnt_item
              ;

stmnt_item    : exit
              ;

exit          : EXIT SEMI
              ;

/*
stmnt_item    : assignment
              | print
              | read
              | conditional
              | counting
              | while
              | exit
              ;
*/

//statements
/*
assignment    : var_ref ASSIGN expr SEMI

//expressions
variable    : VARIABLE
            | VARIABLE LBRACKET exp RBRACKET
            | VARIABLE LBRACKET variable RBRACKET
            ;

var_or_lit  : variable
            | INTLIT
            | REALLIT
            ;

exp         : binop
            ;

binop       : binop OR addsub
            | binop AND addsub
            | NOT binop
            | addsub
            ;

addsub      : addsub ADD muldivmod
            | addsub SUB muldivmod
            | muldivmod
            ;

muldivmod   : muldivmod MUL factor
            | muldivmod DIV factor
            | muldivmod MOD factor
            | factor
            ;

factor      : var_or_lit
            | LPAREN exp RPAREN
            | SUB factor
            ;

algorithm   : ALGORITHM COLON exp_list
            ;

exp_list    : assignment exp_list 
            | print exp_list
            | read exp_list
            | conditional exp_list
            | counting exp_list
            | while exp_list
            | EXIT SEMI exp_list
            | /* empty 
            ;

assignment  : variable ASSIGN exp SEMI
            ;

print       : PRINT print_list SEMI
            ;

print_list  : str_or_var COMMA print_list
            | str_or_var
            ;

str_or_var  : exp
            | STRINGLIT
            | BANG
            ;

read        : READ variable SEMI
            ;

conditional : IF exp SEMI exp_list END IF SEMI
            | IF exp SEMI exp_list ELSE SEMI exp_list END IF SEMI
            ;

counting    : COUNTING variable updown exp TO exp SEMI exp_list END COUNTING SEMI
            ;

updown      : UPWARD
            | DOWNWARD
            ;

while       : WHILE exp SEMI exp_list END WHILE SEMI
            ;

*/

%%

int yyerror()
{
  printf("yyerror()\n");
  return 0;

}
