#include <stdio.h>
#include "y.tab.h"
#include "LinkedList.h"
#include "Generator.h"

SymbolTable table;
AST* root;

int main(int argc, char** argv)
{
  //testList();

  table = makeSymbolTable();

  int code = yyparse();
  if(code == 0)
  {
    //printf("parsing succeeded\n\n");

    //printTitledSymbolTable("Symbol Table", &table);

    generateSymbolTable(&table);

    if(root)
    {
      generateAST(root);

    }

  }
  else
  {
    printf("parsing failed: %d\n", code);
    return -1;

  }

  cleanSymbolTable(&table);

  return 0;

}
