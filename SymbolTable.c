#include "SymbolTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

Symbol* makeSymbol(char* name, int type)
{
  Symbol* symbol = (Symbol*)malloc(sizeof(Symbol));
  symbol->name = name;
  symbol->type = type;
  symbol->size = 1;
  symbol->addr = 0;

  return symbol;

}

void cleanSymbol(Symbol* symbol)
{
  free(symbol->name);
  free(symbol);

}

void printSymbol(Symbol* symbol)
{
  if(symbol->type == INT_TYPE)
  {
    printf("integer: ");

  }
  else if(symbol->type == REAL_TYPE)
  {
    printf("real: ");

  }
  else if(symbol->type == UNKOWN_TYPE)
  {
    printf("unkown: ");

  }

  printf("%s", symbol->name);

  //size > 1 means this symbol is an array.
  if(symbol->size > 1)
  {
    printf("[%d]", symbol->size);

  }

  printf("\n");

}

SymbolTable makeSymbolTable()
{
  SymbolTable table;
  table.symbols = makeList((NodeRecycler)&cleanSymbol);
  table.nextAddr = 0;

  return table;

}

void cleanSymbolTable(SymbolTable* table)
{
  clear(&table->symbols);

}

int addSymbol(SymbolTable* table, Symbol* symbol)
{
  Symbol* p = getSymbol(table, symbol->name);
  if(p)
  {
    return 1;

  }

  symbol->addr = table->nextAddr;
  table->nextAddr += symbol->size;
  push_back(&table->symbols, (void*)symbol);

  return 0;

}

Symbol* getSymbol(SymbolTable* table, char* name)
{
  if(table->symbols.size == 0)
  {
    return NULL;

  }

  for(Node* it = table->symbols.root; it; it = it->next)
  {
    Symbol* symbol = (Symbol*)it->data;
    if(strcmp(symbol->name, name) == 0)
    {
      return symbol;

    }

  }

  return NULL;

}

void printSymbolTable(SymbolTable* table)
{
  printf("+-----------+------+------+------+\n");
  printf("|name       |type  |size  |addr  |\n");
  printf("+-----------+------+------+------+\n");

  for(Node* it = table->symbols.root; it; it = it->next)
  {
    Symbol* symbol = (Symbol*)it->data;

    printf("|%-11s|%-6s|%-6d|%-6d|\n", symbol->name,
      symbol->type == INT_TYPE ? "INT" : "REAL",
      symbol->size, symbol->addr);
    printf("+-----------+------+------+------+\n");

  }

}

void printTitledSymbolTable(char* title, SymbolTable* table)
{
  printf("+--------------------------------+\n");
  printf("|%-32s|\n", title);

  printSymbolTable(table);

}

void setTypeOfSymbols(SymbolTable* table, int type)
{
  for(Node* it = table->symbols.root; it; it = it->next)
  {
    Symbol* symbol = (Symbol*)it->data;
    symbol->type = type;

  }

}

void combineSymbolTables(SymbolTable* table, SymbolTable* otherTable)
{
  for(Node* it = otherTable->symbols.root; it; it = it->next)
  {
    Symbol* symbol = (Symbol*)it->data;
    addSymbol(table, symbol);

  }

  setRecycler(&otherTable->symbols, NULL);
  cleanSymbolTable(otherTable);

}
