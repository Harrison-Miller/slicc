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

  int ret = yyparse();
  if(ret == 0)
  {
    //printf("parsing succeeded\n\n");

    printTitledSymbolTable("Symbol Table", &table);

    resetCode();

    generateSymbolTable(&table);

    if(root)
    {

      generateAST(root);

      FILE* f = fopen("a.gstal", "w+");
      for(Node* it = code.root; it; it = it->next)
      {
        char* line = (char*)it->data;
        fprintf(f, "%s\n", line);

      }
      fclose(f);

      resetCode();

      cleanAST(root);

    }

  }
  else
  {
    printf("parsing failed: %d\n", ret);
    return -1;

  }

  cleanSymbolTable(&table);

  return 0;

}
