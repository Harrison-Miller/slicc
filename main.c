#include <stdio.h>
#include "y.tab.h"
#include "LinkedList.h"

SymbolTable table;

int main(int argc, char** argv)
{
  //testList();

  table = makeSymbolTable();

  int code = yyparse();
  if(code == 0)
  {
    printf("parsing succeeded\n\n");

    printTitledSymbolTable("Symbol Table", &table);
    cleanSymbolTable(&table);

  }
  else
  {
    printf("parsing failed: %d\n", code);

  }

  return 0;

}
