#include "Errors.h"
#include "y.tab.h"
#include <string.h>
#include <stdio.h>

void errorRedefinition(char* name)
{
  char buf[255];
  sprintf(buf, "redefinition of '%s'", name);
  yyerror(buf);

}

void yyerror(char* m)
{
  printf("line %d: error: %s\n%s\n", yylineno, m, linebuf);

}
