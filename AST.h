#ifndef AST_H_
#define AST_H_

#include "SymbolTable.h"

// Abstract Syntax Tree

typedef struct AST
{
  int type;

  struct AST* left;
  struct AST* right;

  struct AST* next;

  int d;
  float f;
  char* c;

  Symbol* symbol;

} AST;

AST* makeAST(int type);

AST* makeIntLit(int value);

AST* makeRealLit(float value);

AST* makeStringLit(char* str);

AST* makeReference(Symbol* symbol);

void cleanAST(AST* ast);

#endif /*AST*/
