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

void errorUndeclared(char* name)
{
  char buf[255];
  sprintf(buf, "'%s' undeclared", name);
  yyerror(buf);

}

void errorMustCountingInt(char* name)
{
  char buf[255];
  sprintf(buf, "'%s' in counting must be of type integer", name);
  yyerror(buf);

}

void errorInvalidArraySize(char* name)
{
  char buf[255];
  sprintf(buf, "size of array '%s' is invalid", name);
  yyerror(buf);

}

void yyerror(char* m)
{
  printf("line %d: error: %s\n%s\n", yylineno, m, linebuf);

}
