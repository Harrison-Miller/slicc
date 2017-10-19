#include "AST.h"
#include "y.tab.h"
#include <stdlib.h>

AST* makeAST(int type)
{
  AST* ast = malloc(sizeof(AST));
  ast->type = type;
  ast->cond = NULL;
  ast->left = NULL;
  ast->right = NULL;
  ast->next = NULL;
  ast->d = 0;
  ast->f = 0.0f;
  ast->symbol = NULL;

  return ast;

}

void cleanAST(AST* ast)
{
  if(ast)
  {
    cleanAST(ast->left);
    cleanAST(ast->right);
    cleanAST(ast->next);

    if(ast->c)
    {
      free(ast->c);

    }

    free(ast);

  }

}

AST* makeIntLit(int value)
{
  AST* ast = makeAST(INTLIT);
  ast->d = value;
  return ast;

}

AST* makeRealLit(float value)
{
  AST* ast = makeAST(REALLIT);
  ast->f = value;
  return ast;

}

AST* makeStringLit(char* str)
{
  AST* ast = makeAST(STRINGLIT);
  ast->c = str;
  return ast;

}

AST* makeReference(Symbol* symbol)
{
  AST* ast = makeAST(VARIABLE);
  ast->symbol = symbol;
  return ast;

}
