#ifndef LINKEDLIST_H_
#define LINKEDLIST_H_

typedef void (*NodeRecycler)(void*);

typedef struct Node
{
  void* data;
  NodeRecycler recycler;

  struct Node* next;

} Node;

Node* makeNode(void* data, NodeRecycler recycler);

void cleanNode(Node* node);

void addNode(Node* root, Node* n);

/*
returns the new root node if index == 0
n is inserted as the last element if index >= size
*/
Node* insertNode(Node* root, Node* n, int index);

int getSize(Node* root);

Node* getNode(Node* root, int index);

void* getData(Node* root, int index);

void removeNode(Node* root, Node* node);

void removeIndex(Node* root, int index);

void destroyList(Node* root);

// slightly nicer wrapper instead of handling the root node yourself.
typedef struct LinkedList
{
  Node* root;
  int size;
  NodeRecycler recycler;

} LinkedList;

LinkedList makeList(NodeRecycler recycler);

void insert(LinkedList* list, void* data, int index);

void push_back(LinkedList* list, void* data);

void erase(LinkedList* list, int index);

void* get(LinkedList* list, int index);

void setRecycler(LinkedList* list, NodeRecycler recycler);

void clear(LinkedList* list);

void testList();

#endif /*LINKEDLIST*/
