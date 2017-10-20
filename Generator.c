#include "Generator.h"
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

LinkedList code;

#define ADD_CODE(x, ...) { char* str = malloc(sizeof(char)*50); sprintf(str, x, __VA_ARGS__); push_back(&code, str); }
#define ADD_SCODE(x) { char* str = malloc(sizeof(char)*50); sprintf(str, x); push_back(&code, str); }
#define INSERT_CODE(i, x, ...) { char* str = malloc(sizeof(char)*50); sprintf(str, x, __VA_ARGS__); insert(&code, str, i); }

void cleanCharNode(void* c)
{
  if(c)
  {
    free(c);

  }

}

void resetCode()
{
  clear(&code);
  code = makeList(&cleanCharNode);

}

void generateSymbolTable(SymbolTable* table)
{
  if(table->nextAddr)
  {
    ADD_CODE("ISP %d", table->nextAddr);

  }

}

void generateAST(AST* ast)
{
  do
  {
    generateStatement(ast);
    ast = ast->next;

  } while(ast);

}

void endFlowControl(AST* ast)
{
  //this ensures the jump to after flowcontrol is valid.
  if(!ast->next)
  {
    ADD_SCODE("HLT");

  }

}

int generateVarRef(AST* ast)
{
  Symbol* symbol = ast->symbol;
  ADD_CODE("LAA %d", symbol->addr);

  //array references
  if(symbol->size > 1)
  {
    generateExpression(ast->cond);
    ADD_SCODE("ADI"); // adds address + offset

  }

  return symbol->type == INT_TYPE ? INTLIT : REALLIT;

}

int generateExpression(AST* ast)
{
  if(ast->type == INTLIT)
  {
    ADD_CODE("LLI %d", ast->d);
    return INTLIT;

  }
  else if(ast->type == REALLIT)
  {
    ADD_CODE("LLF %f", ast->f);
    return REALLIT;

  }
  else if(ast->type == VARIABLE)
  {
    int type = generateVarRef(ast);
    ADD_SCODE("LOD");

    return type;

  }
  else if(ast->cond)
  {
    int type = generateExpression(ast->cond);

    if(ast->type == NOT)
    {
      ADD_CODE("LLI %d", 1);
      ADD_SCODE("GEI");
      ADD_CODE("LLI %d", 1);
      ADD_SCODE("SBI");

    }
    else if(ast->type == SUB)
    {
      ADD_SCODE("NGI");

    }

    return type;

  }
  else
  {
    int leftType = generateExpression(ast->left);
    int rightType = generateExpression(ast->right);

    switch(ast->type)
    {
      case EQ:  ADD_SCODE("EQI"); break;
      case NEQ: ADD_SCODE("NEI"); break;
      case LT:  ADD_SCODE("LTI"); break;
      case GT:  ADD_SCODE("GTI"); break;
      case LTE: ADD_SCODE("LEI"); break;
      case GTE: ADD_SCODE("GEI"); break;
      case OR:  ADD_SCODE("ADI"); break;
      case AND: ADD_SCODE("MLI"); break;
      case ADD: ADD_SCODE("ADI"); break;
      case SUB: ADD_SCODE("SBI"); break;
      case MUL: ADD_SCODE("MLI"); break;
      case DIV: ADD_SCODE("DVI"); break;

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
    int refType = generateVarRef(ast->left);
    int type = generateExpression(ast->right);

    // convert to the type of the variable
    if(refType == INTLIT && type == REALLIT)
    {
      ADD_SCODE("FTI");

    }
    else if(refType == REALLIT && type == INTLIT)
    {
      ADD_SCODE("ITF");

    }

    ADD_SCODE("STO");

  }
  else if(ast->type == PRINT)
  {
    generatePrintList(ast->left);

  }
  else if(ast->type == READ)
  {
    int type = generateVarRef(ast->left);

    if(type == INTLIT)
    {
      ADD_SCODE("INI");

    }
    else
    {
      ADD_SCODE("INF");

    }

    ADD_SCODE("STO");

  }
  else if(ast->type == IF)
  {
    ADD_SCODE("NOP ; if expression");
    generateExpression(ast->cond);
    int pos = code.size;
    generateAST(ast->left);
    ADD_SCODE("NOP ; end if");
    INSERT_CODE(pos, "JPF %d ; if", code.size + 1);

    endFlowControl(ast);

  }
  else if(ast->type == ELSE)
  {
    ADD_SCODE("NOP ; if expression");
    generateExpression(ast->cond);
    int pos = code.size;
    generateAST(ast->left);
    ADD_SCODE("NOP ; else");
    INSERT_CODE(pos, "JPF %d ; if", code.size + 2);
    pos = code.size;
    generateAST(ast->right);
    ADD_SCODE("NOP ; end if");
    INSERT_CODE(pos, "JMP %d", code.size + 1);

    endFlowControl(ast);

  }
  else if(ast->type == COUNTING)
  {
    ADD_SCODE("NOP ; counting init");
    generateVarRef(ast->left);
    generateExpression(ast->cond->left);
    ADD_SCODE("STO");
    ADD_SCODE("NOP ; counting expression");
    int check = code.size;

    generateVarRef(ast->left);
    ADD_SCODE("LOD");

    generateExpression(ast->cond->right);

    if(ast->cond->type == UPWARD)
    {
      ADD_SCODE("LEI");

    }
    else
    {
      ADD_SCODE("GEI");

    }

    int pos = code.size;
    generateAST(ast->right);

    ADD_SCODE("NOP ; counting mutate");
    generateVarRef(ast->left);
    generateVarRef(ast->left);
    ADD_SCODE("LOD");
    ADD_CODE("LLI %d", 1);

    if(ast->cond->type == UPWARD)
    {
      ADD_SCODE("ADI");

    }
    else
    {
      ADD_SCODE("SBI");

    }

    ADD_SCODE("STO");

    ADD_CODE("JMP %d", check);
    ADD_SCODE("NOP ; end counting");
    INSERT_CODE(pos, "JPF %d ; counting", code.size + 1);

    endFlowControl(ast);

  }
  else if(ast->type == WHILE)
  {
    ADD_SCODE("NOP ; while expression");
    int check = code.size;
    generateExpression(ast->cond);
    int pos = code.size;
    generateAST(ast->left);
    ADD_CODE("JMP %d", check);
    ADD_SCODE("NOP ; end while");
    INSERT_CODE(pos, "JPF %d ; while", code.size + 1);

    endFlowControl(ast);

  }
  else if(ast->type == EXIT)
  {
    ADD_SCODE("HLT");

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
        ADD_CODE("LLI %d", (int)c);
        ADD_SCODE("PTC");

        if(c == '"')
        {
          i++;

        }

      }

    }
    else if(ast->type == BANG)
    {
      ADD_SCODE("PTL");

    }
    else if(ast->type == VARIABLE)
    {
      int type = generateExpression(ast);
      if(type == INTLIT)
      {
        ADD_SCODE("PTI");

      }
      else if(type == REALLIT)
      {
        ADD_SCODE("PTF");

      }

    }

    ast = ast->left;

  } while(ast);

}
