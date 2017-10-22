#include <stdio.h>
#include <string.h>
#include "y.tab.h"
#include "LinkedList.h"
#include "SymbolTable.h"
#include "Generator.h"

SymbolTable table;
AST* root;

extern FILE* yyin;

void printUsage(char** argv)
{
    printf("usage: %s [-o name] file\n", argv[0]);

}

int main(int argc, char** argv)
{
  //testList();

  char* fileName = "a.gstal";
  char* sourceFile = NULL;

  if(!(argc == 2 || argc == 4))
  {
    printUsage(argv);
    return -1;

  }

  if(strcmp(argv[1], "-o") == 0)
  {
    fileName = argv[2];
    sourceFile = argv[3];

  }
  else
  {
    sourceFile = argv[1];

  }

  FILE* in = fopen(sourceFile, "r");
  if(!in)
  {
    printf("Can't open file: %s\n", argv[1]);
    return -1;

  }

  table = makeSymbolTable();

  addSymbol(&table, makeSymbol(strdup("_dividend"), INT_TYPE));
  addSymbol(&table, makeSymbol(strdup("_divisor"), INT_TYPE));

  yyin = in;
  int ret = yyparse();
  if(ret == 0)
  {
    //printf("parsing succeeded\n\n");

    printTitledSymbolTable("Symbol Table", &table);

    resetCode();

    if(root)
    {

      generateSymbolTable(&table);
      generateAST(root);

      FILE* out = fopen(fileName, "w+");
      for(Node* it = code.root; it; it = it->next)
      {
        char* line = (char*)it->data;
        fprintf(out, "%s\n", line);

      }
      fclose(out);

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
