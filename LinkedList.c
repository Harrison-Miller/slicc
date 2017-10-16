#include "LinkedList.h"
#include <assert.h>
#include <stdlib.h>
#include <stdio.h>

Node* makeNode(void* data, NodeRecycler recycler)
{
  Node* node = (Node*)malloc(sizeof(Node));
  node->data = data;
  node->recycler = recycler;
  node->next = NULL;

  return node;

}

void cleanNode(Node* node)
{
  if(node->recycler)
  {
    node->recycler(node->data);

  }

  free(node);

}

void addNode(Node* root, Node* n)
{
  while(root->next)
  {
    root = root->next;

  }

  root->next = n;

}

Node* insertNode(Node* root, Node* n, int index)
{
  if(index == 0)
  {
    n->next = root;
    return n;

  }

  int current = 0;

  Node* prev = NULL;
  Node* cur = root;

  do
  {
    current++;
    prev = cur;
    cur = cur->next;

  } while(cur && current != index);

  if(prev)
  {
    prev->next = n;

  }

  n->next = cur;

  return root;

}

int getSize(Node* root)
{
  int size = 1;
  while(root->next)
  {
    root = root->next;
    size++;

  }

  return size;

}

Node* getNode(Node* root, int index)
{
  if(index == 0)
  {
    return root;

  }
  else
  {
    index--;
    if(root->next)
    {
      return getNode(root->next, index);

    }

    return NULL;

  }

}

void* getData(Node* root, int index)
{
  Node* node = getNode(root, index);
  if(node)
  {
    return node->data;

  }

}

void removeNode(Node* root, Node* node)
{
  Node* prev = NULL;
  while(root->next && root != node)
  {
    prev = root;
    root = root->next;

  }

  if(prev != NULL)
  {
    prev->next = node->next;

  }

  cleanNode(node);

}

void removeIndex(Node* root, int index)
{
  Node* node = getNode(root, index);
  removeNode(root, node);

}

void destroyList(Node* root)
{
  if(root->next)
  {
    destroyList(root->next);

  }

  cleanNode(root);

}
LinkedList makeList(NodeRecycler recycler)
{
  LinkedList list;
  list.root = NULL;
  list.size = 0;
  list.recycler = recycler;

  return list;

}

void insert(LinkedList* list, void* data, int index)
{
  if(!list->root)
  {
    list->root = makeNode(data, list->recycler);

  }
  else
  {
    list->root = insertNode(list->root, makeNode(data, list->recycler), index);

  }

  list->size++;

}

void push_back(LinkedList* list, void* data)
{
  insert(list, data, list->size);

}

void erase(LinkedList* list, int index)
{
  if(index < list->size)
  {
    removeIndex(list->root, index);
    list->size--;

  }

}

void* get(LinkedList* list, int index)
{
  if(!list->root || index >= list->size)
  {
    return NULL;

  }

  return getData(list->root, index);

}

void setRecycler(LinkedList* list, NodeRecycler recycler)
{
  for(Node* it = list->root; it; it = it->next)
  {
    it->recycler = recycler;

  }

}

void clear(LinkedList* list)
{
  if(list->root)
  {
    destroyList(list->root);
    list->root = NULL;

  }

  list->size = 0;

}

int testCounter;

void testRecycler(void* foo)
{
  testCounter--;

}

void testList()
{
  Node* root = makeNode((void*)1, &testRecycler);
  assert((long)root->data == 1);

  // adding elements to the end and getting a random element
  addNode(root, makeNode((void*)1, &testRecycler));
  assert(getSize(root) == 2);

  addNode(root, makeNode((void*)2, &testRecycler));
  addNode(root, makeNode((void*)3, &testRecycler));

  assert(getSize(root) == 4);

  assert((long)getData(root, 2) == 2);

  // removing and element, make sure linked list still connected
  removeIndex(root, 2);
  assert(getSize(root) == 3);
  assert((long)getData(root, 2) == 3);

  // make sure the linked list is still connected
  root = insertNode(root, makeNode((void*)5, &testRecycler), 2);
  assert((long)getData(root, 2) == 5);
  assert((long)getData(root, 3) == 3);
  assert(getSize(root) == 4);

  // inserting as the first element should change the root node
  root = insertNode(root, makeNode((void*)0, &testRecycler), 0);
  assert(getSize(root) == 5);

  // insert at the end properly
  root = insertNode(root, makeNode((void*)8, &testRecycler), 5);
  assert(getSize(root) == 6);


  testCounter = getSize(root);
  destroyList(root);

  // ensures all nodes were removed
  assert(testCounter == 0);

  printf("LinkedList passed test\n");

}
