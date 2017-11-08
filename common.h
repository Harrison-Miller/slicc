#ifndef COMMON_H_
#define COMMON_H_

#include "SymbolTable.h"
#include "AST.h"

extern SymbolTable table;
extern int symbolType;

extern AST* root;

extern char* yytext;
extern int yylineno;
extern char linebuf[1024];

#endif /*COMMON*/
