#include <iostream>
#include <cstring>
#include <cstdlib>
#include <cmath>
#include <time.h>

///////////////////////////////////////////////////////////////////////////////////////////////
//Package: Metagenomic Complex Sequence Scanning Tool (MetaCSST)                             //
//Developer: Fazhe Yan                                                                       //
//Email: fazheyan33@163.com / ccwei@sjtu.edu                                                 //
//Department: Department of Bioinformatics and Biostatistics, Shanghai Jiao Tong University  //
///////////////////////////////////////////////////////////////////////////////////////////////


using namespace std;
#define S 100000 //search space number when scaning for sub HMMs

#define N 20000000 //Max Sequence Length
#define P 1000 //Max subPattern Length
#define M 1000 //Max subPattern number
#define D 1000 //length of directory or file name

char *substr(char *s,int start,int num){ //get the sub string from sequence s,start site->start,substring length->num
  //int size = strlen(s);
  num = abs(num);
  char *p = (char *)calloc(num+1,sizeof(char));
  int i,j;
  if(start >= 0)
    for(i=start,j=0;j < num && i < strlen(s);i++,j++)
      p[j] = s[i];
  else
    for(i = strlen(s)-1+start,j=0;j <num && i >= 0;i--,j++)
      p[j] = s[i];
  p[j] = '\0';
  return p;
}

char *chomp(char *s){ //split the tail '\n' and return the chomped sequence
  int size = strlen(s);
  if (s[size-1] == '\n')
    return substr(s,0,size-1);
  else
    return s;
}

int judge(char *p){ //whether exists '>' in the sequence,is yes,return -1;otherwise return 0
  int i;
  for(i=0;i<strlen(p);i++)
    if(p[i] == '>')
      return -1;
  return 0;
}
 
void swap(float **score,int m,int n){
  float tmp=(*score)[m];
  (*score)[m] =(*score)[n];
  (*score)[n] = tmp;

}

void q_sort(float **score,int left,int right){ //quick sort,the argumants is the address of an array of float
  int i;
  int last;
  if (left >= right) 
    return;
  swap(score,left, (left + right)/2); 
  last = left;
  for ( i = left + 1; i <= right; i++)
    if((*score)[i] < (*score)[left])
      swap(score,++last, i);
  swap(score,left, last);
  q_sort(score,left, last-1); 
  q_sort(score,last+1, right); 
}


float cuttof(float **score,int number,float ratio){ //get the cuttof value of an array of value,with ratio beyween 0~1
  float cuttof_value=0.0;
  q_sort(score,0,number);
  int i=ceil((1-ratio)*number);
  return (*score)[i];
}

int split(char *file,int number,char *dir){ //split the file to n(thread number) or n+1 parts into the given directory
  int num=0;
  if(number != 1){
    int line=0;
    FILE *fp = fopen(file,"r");
    char *tmp = (char *)calloc(N,sizeof(char));
    while(fgets(tmp,N,fp)){
      line++;
    }
    fclose(fp);
    line/=2;
    int per = line/number + 1;
    num = line/per;
    if(line % per != 0)
      num += 1;
    char command[1000];
    sprintf(command,"split -l %d %s -d -a 2 %s/split_",per*2,file,dir);
    system(command);
    free(tmp);
  }
  return num;
}


char *complementary(char *s){ //get the complementary sequence of the given DNA
  char *p = (char *)calloc(strlen(s),sizeof(char));
  int i,j;
  for(i=0,j=strlen(s)-1;j>=0;j--)
    switch(s[j]){
    case 'A':p[i++]='T';break;
    case 'a':p[i++]='T';break;
    case 'T':p[i++]='A';break;
    case 't':p[i++]='A';break;
    case 'C':p[i++]='G';break;
    case 'c':p[i++]='G';break;
    case 'G':p[i++]='C';break;
    case 'g':p[i++]='C';break;
    case 'N':p[i++]=s[j];
    }
  return p;
}

int count(char *s,char sep){ //times of character seq in the sequence s
  int count = 0;
  int i;
  for(i=0;i<strlen(s);i++)
    if(s[i] == sep)
      count++;
  return count;
}

char *array_split(char *s,char sep,int col){ //split the sequence to an array with the seperator sep,return array[col]
  int size = strlen(s);
  int column = count(s,sep);
  char *p[column];
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

int tri_max(int a,int b,int c){ //max number in the three
  if(a >= b && a >= c)
    return a;
  else if(b >= a && b >= c)
    return b;
  else if(c >= a && c >= b)
    return c;
}

int tri_min(int a,int b,int c){ //min number in the three
  if(a <= b && a <= c)
    return a;
  else if(b <= a && b <= c)
    return b;
  else if(c <= a && c <= b)
    return c;
}

char *arg_name(char *name){
  char *arg_name=(char *)calloc(10,sizeof(char));
  if(strcmp(name,"cov") == 0)
    sprintf(arg_name,"-cov");
  else if(strcmp(name,"len") == 0)
    sprintf(arg_name,"-len");
  else if(strcmp(name,"score") == 0)
    sprintf(arg_name,"-score");
  else if(strcmp(name,"ratio") == 0)
    sprintf(arg_name,"-ratio");
  else if(strcmp(name,"gap") == 0)
    sprintf(arg_name,"-gap");
  else if(strcmp(name,"motif") == 0)
    sprintf(arg_name,"-build");
  return arg_name;
}

void usage(char *arg){
  printf("Usage: %s -build arg.config [Options]\n\n",arg);
  printf("Options\n\n");
  printf("-build : Config file to build model\n");
  printf("[-thread] : Number of threads ,[int],default 1\n");
  printf("[-in] : Fasta format file,in which patterns are searched,build a HMM only if not given,[string]\n");
  printf("[-out] : OUT Directory,[string],default 'sbcsst_out'\n");
  printf("[-h] : GHmmMotifScan User Manual\n");
}



void swap_state(int start[],int end[],float score[],int string[],int m,int n){
  int start_tmp = start[m];
  start[m] = start[n];
  start[n] = start_tmp;
  
  int end_tmp = end[m];
  end[m] = end[n];
  end[n] = end_tmp;

  int string_tmp = string[m];
  string[m] = string[n];
  string[n] = string_tmp;

  float score_tmp = score[m];
  score[m] = score[n];
  score[n] = score_tmp;
}

void q_sort_state(int start[],int end[],float score[],int string[],int left,int right){ //quick sort,the argumants is the address of an array of float
  int i;
  int last;
  if (left >= right) 
    return;
  swap_state(start,end,score,string,left,(left + right)/2); 
  last = left;
  for ( i = left + 1; i <= right; i++)
    if(start[i] < start[left])
      swap_state(start,end,score,string,++last, i);
  swap_state(start,end,score,string,left, last);
  q_sort_state(start,end,score,string,left, last-1); 
  q_sort_state(start,end,score,string,last+1, right); 
}

