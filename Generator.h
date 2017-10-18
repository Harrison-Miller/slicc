#ifndef GENERATOR_H_
#define GENERATOR_H_

#include "SymbolTable.h"
#include "AST.h"

// generate functions will go to stdout

void generateSymbolTable(SymbolTable* table);

void generateAST(AST* ast);

// returns INTLIT or REALLIT
// returns UNKOWN if there was no expression
int generateExpression(AST* ast);

void generateStatement(AST* ast);

void generatePrintList(AST* ast);

#endif /*GENERATOR*/
