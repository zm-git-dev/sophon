#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <ctype.h>
#include <time.h>

/*
=======Function.1======
substr:Get the sub string.
[s] is a parent string
[start] is the start position of your substring,it can be negative,which returns a reverse string
[num] is the number of characters in your substring,must be positive and integer
*/
char *substr(char *s,int start,int num){    
  int size = strlen(s);
  num = abs(num);
  char *p = (char *)calloc(size,sizeof(char));
  int i,j;
  if(start >= 0)
    for(i=start,j=0;j < num && i < strlen(s);i++,j++)
      p[j] = s[i];
  else
    for(i = strlen(s)-1+start,j=0;j <num && i >= 0;i--,j++)
      p[j] = s[i];
  return p;
}
/*======Function.1 END======*/



/*
======Function.2======
chop:cut the last character in the given string
*/
char *chop(char *s){
  int size = strlen(s);
  return substr(s,0,size-1);
}
/*======Function.2 END======*/



/*
======Function.3======
chomp:cut the '\n' at the end of the string
*/
char *chomp(char *s){
  int size = strlen(s);
  if (s[size-1] == '\n')
    return substr(s,0,size-1);
  else
    return s;
}
/*======Function.3 END======*/



/*
======Function.4======
count:calculate the number of accurence of character sep in s
*/
int count(char *s,char sep){
  int count = 0;
  int i;
  for(i=0;i<strlen(s);i++)
    if(s[i] == sep)
      count++;
  return count;
}
/*======Function.4 END======*/



/*
======Funciton.5======
split:cut the string to an array accoridng to the given separator,returning the column needed
[sep]:separator used,eg:','
[col]:the needed column,eg:0
*/
char *split(char *s,char sep,int col){
  int size = strlen(s);
  int column = count(s,sep);
  char *p[column+1];
  int i,j,k;
  for(i = 0;i <= column;i++)
    p[i] = (char *)calloc(size,sizeof(char));
  for(i=0,j=0,k=0;i < size;i++)
    if(s[i] == sep){
      j+=1;
      k=0;
    }
    else{
      p[j][k] = s[i];
      k++;
    }
  if(col >= 0)
    if(col > column)
      return p[column];
    else
      return p[col];
  else
    if(column + col <0)
      return p[0];
    else
      return p[column+col];
}
/*======Function.5 END======*/



/*
======Funciton.6======
The Usage of HASH Table in the C type
USAGE:
<1>The [key] and [value] are in the char* type,the value can be transformed into int type
<2>The size of the HASH Tbale--HASH_MAX_SIZE is given,which can be changed
<3>To use the HASH Tbale:  !!!!!!
   hash_init()   ====>>>Initiatioin
   hash_insert("key","value");   ===>>>inset a new key and its corresponding value
              ##Tips:If the key exists,the value will be covered by the new one
   hash_lookup("key")   ===>>>Look up the value of the given key
              ##It returns the value in char* type;If "key" don't exists in the table,returning NULL
   hash_print("key")   ===>>>Print out the whole HASH Table
   hash_remove("key")   ===>>>Remove a node in the table
   
*/
#define HASH_MAX_SIZE 100000
typedef struct hash hashNode;

struct hash
{
  char* Key;
  char* Value;
  hashNode* pNext;
};

hashNode* hashTable[HASH_MAX_SIZE]; //hash table data strcutrue
int HASH_SIZE;  //the number of key-value pairs in the hash table!

//initialize hash table
void hash_init(){
  HASH_SIZE = 0;
  memset(hashTable, 0, sizeof(hashNode*) * HASH_MAX_SIZE);
}

//string hash function
unsigned int hash_str(const char* skey){
  const signed char *p = (const signed char*)skey;
  unsigned int h = *p;
  if(h){
    for(p += 1; *p != '\0'; ++p)
      h = (h << 5) - h + *p;
  }
  return h;
}

//insert key-value into hash table
void hash_insert(const char* skey, char * nvalue){
  if(HASH_SIZE >= HASH_MAX_SIZE){
    printf("out of hash table memory!\n");
    return;
  }
  unsigned int pos = hash_str(skey) % HASH_MAX_SIZE;
  hashNode* pHead =  hashTable[pos];
  while(pHead){
    if(strcmp(pHead->Key, skey) == 0){
      pHead->Value = nvalue;
      return ;
    }
    pHead = pHead->pNext;
  }

  hashNode* pNewNode = (hashNode*)malloc(sizeof(hashNode));
  memset(pNewNode, 0, sizeof(hashNode));
  pNewNode->Key = (char*)malloc(sizeof(char) * (strlen(skey) + 1));
  strcpy(pNewNode->Key, skey);
  pNewNode->Value = nvalue;

  pNewNode->pNext = hashTable[pos];
  hashTable[pos] = pNewNode;

  HASH_SIZE++;
}
//remove key-value frome the hash table

void hash_remove(const char* skey){
  unsigned int pos = hash_str(skey) % HASH_MAX_SIZE;
  if(hashTable[pos]){
    hashNode* pHead = hashTable[pos];
    hashNode* pLast = NULL;
    hashNode* pRemove = NULL;
    while(pHead){
      if(strcmp(skey, pHead->Key) == 0){
	pRemove = pHead;
	break;
      }
      pLast = pHead;
      pHead = pHead->pNext;
    }
    if(pRemove){
      if(pLast)
	pLast->pNext = pRemove->pNext;
      else
	hashTable[pos] = NULL;

      free(pRemove->Key);
      free(pRemove);
    }
  }
}

//lookup a key in the hash table
char * hash_lookup(const char* skey){
  unsigned int pos = hash_str(skey) % HASH_MAX_SIZE;
  if(hashTable[pos]){
    hashNode* pHead = hashTable[pos];
    while(pHead){
      if(strcmp(skey, pHead->Key) == 0)
	return pHead->Value;
      pHead = pHead->pNext;
    }
  }
  return NULL;
}

//print the content in the hash table
void hash_print(){
  int i;
  printf("======The current HASH Table======\n");
  for(i = 0; i < HASH_MAX_SIZE; ++i)
    if(hashTable[i]){
      hashNode* pHead = hashTable[i];
      while(pHead){
	printf("%s=>%s\n", pHead->Key, pHead->Value);
	pHead = pHead->pNext;
      }
    }
}
/*======Function.6 END======*/



