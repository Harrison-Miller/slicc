#include <stdio.h>

int main(int argc, char** argv)
{
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
