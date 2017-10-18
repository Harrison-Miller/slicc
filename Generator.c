#include "Generator.h"
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

void generateSymbolTable(SymbolTable* table)
{
  printf("ISP %d\n", table->nextAddr);

}

void generateAST(AST* ast)
{
  do
  {
    generateStatement(ast);
    ast = ast->next;

  } while(ast);

}

int generateExpression(AST* ast)
{
  if(ast->type == INTLIT)
  {
    printf("LLI %d\n", ast->d);
    return INTLIT;

  }
  else if(ast->type == REALLIT)
  {
    printf("LLF %f\n", ast->f);
    return REALLIT;

  }
  else if(ast->type == VARIABLE)
  {
    Symbol* symbol = ast->symbol;

    printf("LAA %d\n", symbol->addr);
    printf("LOD\n");

    return symbol->type == INT_TYPE ? INTLIT : REALLIT;

  }
  else
  {
    int leftType = generateExpression(ast->left);
    int rightType = generateExpression(ast->right);

    switch(ast->type)
    {
      case ADD: printf("ADI\n"); break;
      case SUB: printf("SBI\n"); break;
      case MUL: printf("MLI\n"); break;
      case DIV: printf("DVI\n"); break;

    }

    int real = leftType == REALLIT || rightType == REALLIT;
    return real ? REALLIT : INTLIT;

  }

  return UNKOWN;

}

void generateStatement(AST* ast)
{
  if(ast->type == ASSIGN)
  {
    Symbol* ref = ast->left->symbol;
    printf("LAA %d\n", ref->addr);
    int type = generateExpression(ast->right);
    if(ref->type == INT_TYPE && type == REALLIT)
    {
      printf("FTI\n");
    }
    else if(ref->type == REAL_TYPE && type == INTLIT)
    {
      printf("ITF\n");

    }

    printf("STO\n");

  }
  else if(ast->type == PRINT)
  {
    generatePrintList(ast->left);

  }
  else if(ast->type == READ)
  {
    Symbol* symbol = ast->left->symbol;

    printf("LAA %d\n", symbol->addr);

    if(symbol->type == INT_TYPE)
    {
      printf("INI\n");
      printf("STO\n");

    }
    else
    {
      printf("INF\n");

    }

  }
  else if(ast->type == EXIT)
  {
    printf("HLT\n");

  }

}

void generatePrintList(AST* ast)
{
  do
  {

    if(ast->type == STRINGLIT)
    {
      int len = strlen(ast->c);
      for(int i = 0; i < len; i++)
      {
        char c = ast->c[i];
        printf("LLI %d\n", (int)c);
        printf("PTC\n");

        if(c == '"')
        {
          i++;

        }

      }

    }
    else if(ast->type == BANG)
    {
      printf("PTL\n");

    }
    else
    {
      int type = generateExpression(ast);
      if(type == INTLIT)
      {
        printf("PTI\n");

      }
      else if(type == REALLIT)
      {
        printf("PTF\n");

      }

    }

    ast = ast->left;

  } while(ast);

}
