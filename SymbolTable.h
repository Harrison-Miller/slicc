#ifndef SYMBOLTABLE_H_
#define SYMBOLTABLE_H_

#include "LinkedList.h"

#define INT_TYPE 0
#define REAL_TYPE 1
#define UNKOWN_TYPE 2

typedef struct Symbol
{
  char* name;
  int type;
  int size;
  int addr;

} Symbol;

Symbol* makeSymbol(char* name);

void cleanSymbol(Symbol* symbol);

void printSymbol(Symbol* symbol);

typedef struct SymbolTable
{
  LinkedList symbols;
  int nextAddr;

} SymbolTable;

SymbolTable makeSymbolTable();

void cleanSymbolTable(SymbolTable* table);

void addSymbol(SymbolTable* table, Symbol* symbol);

Symbol* getSymbol(SymbolTable* table, char* name);

void printSymbolTable(SymbolTable* table);
void printTitledSymbolTable(char* title, SymbolTable* table);

void setTypeOfSymbols(SymbolTable* table, int type);

void combineSymbolTables(SymbolTable* table, SymbolTable* otherTable);

#endif /*SYMBOLTABLE*/
