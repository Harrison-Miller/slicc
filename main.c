#include <stdio.h>
#include "y.tab.h"
#include "LinkedList.h"

int main(int argc, char** argv)
{
  //testList();


  int code = yyparse();
  if(code == 0)
  {
    printf("parsing succeeded\n");

  }
  else
  {
    printf("parsing failed: %d\n", code);

  }

  return 0;

}
