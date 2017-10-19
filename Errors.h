#ifndef ERRORS_H_
#define ERRORS_H_

void errorRedefinition(char* name);

void errorUndeclared(char* name);

void errorMustCountingInt(char* name);

void yyerror(char*);

#endif /*ERRORS*/
