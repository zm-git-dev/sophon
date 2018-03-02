#include <iostream>
#include <fstream>
#include <cstring>
#include <cstdlib>
#include <cmath>
#include <pthread.h>

///////////////////////////////////////////////////////////////////////////////////////////////
//Package: Metagenomic Complex Sequence Scanning Tool (MetaCSST)                             //
//Developer: Fazhe Yan                                                                       //
//Email: fazheyan33@163.com / ccwei@sjtu.edu                                                 //
//Department: Department of Bioinformatics and Biostatistics, Shanghai Jiao Tong University  //
///////////////////////////////////////////////////////////////////////////////////////////////


#include "ghmm.h"
using namespace std;

/*
This script is used to build a Weight Count Model according to the multiple sequence alignment result.In the meantime,get some conserved regions.And the build HMM models according to the motifs and using these HMM models to predict new structures in unknown sqeuences;
*/

/*
In the phase of finding motif,the training set sequences are clustered according to the result of multi-alignment.Foreach sub class,we find the best motif and build corresponding HMM model.When scaning for a new unknown sequence,these HMM models are combinded.This method may be not so efficient,but will be better in sensitivity as well as specificity.
*/

/*WorkFlow:
1>According to the trainging set,cluster the data to some sub clusters
2>Foreach cluster,find the best sequence motif using glam2 or muscle
3>Foreach motif,a GHMM model is built
4>All the GHMM models are used to scan for a new sequence
5>Combind the results of different GHMM model
*/

struct arg { //arguments to scan the input file when using multi threads
  char *search; //INPUT
  char *putout; //OUTPUT
  HMM_class hmm_class; //some clusters
};

void *scanFile(void *argument); 
//according to the input file and built model,get the matching structure

int main(int argc,char* argv[]){
  if(argc < 3){
    usage(argv[0]);
    return 0;
  }
  else{
    int thread = 1; //thread number
    char *search=NULL; //unknown sequences file to scan
    char *dir="sbcsst_out"; //OUT Directory
    char *config=NULL; //config file
    for(int i=0;i<argc;i++)
      if(strcmp(argv[i],"-thread") == 0) //thread number
        thread = atoi(argv[i+1]);
      else if (strcmp(argv[i],"-in") == 0) //input 
	search = argv[i+1];
      else if (strcmp(argv[i],"-out") == 0) //output
        dir=argv[i+1];
      else if (strcmp(argv[i],"-build") == 0) //tmp directory
        config=argv[i+1];
      else if(strcmp(argv[i],"-h") == 0){ //usage manual
	usage(argv[0]);
	return 0;
      }
        
    if(config == NULL){ //No config file found
      usage(argv[0]);
      return 0;
    }
    else{
      
      /*If the out directory exists,it will be covered*/
      if(access(dir,0) == 0){
	printf("directory %s exists,it will be covered!\n",dir);
	char cmd[D];
	sprintf(cmd,"rm -rf  %s",dir);
	system(cmd);
      }
      
      /*mkdir: the out directory*/
      char cmd[D];
      sprintf(cmd,"mkdir %s",dir);
      system(cmd);
      
      /*tmp directory:used to save the temp results,including the split files and intermediate results*/
      char tmp[D];
      sprintf(tmp,"%s/tmp",dir);
      /*out file:final result*/
      char out[D];
      sprintf(out,"%s/out.txt",dir);

      /*build the GHMM models accoridng to the config file*/
      HMM_class hmm_class;
      hmm_class.init(config);
      hmm_class.print(dir); //print some information to this directory

      if(search != NULL){
	
	char cmd1[D];
	sprintf(cmd1,"mkdir %s",tmp); //tmp directory
	system(cmd1);
	if(thread == 1){
	  char out_tmp[40];sprintf(out_tmp,"%s/out_tmp.txt",tmp);
	  struct arg ARG;
	  ARG.search=search;ARG.putout=out_tmp;ARG.hmm_class=hmm_class;
	  pthread_t thread; //create a new thread
	  scanFile(&ARG); //scaning the input file
	  
	  if(out == NULL){
	    char cmd2[D];sprintf(cmd2,"cat %s/out_tmp.txt",tmp);
	    system(cmd2);
	  }
	  else{
	    char cmd2[D];sprintf(cmd2,"cat %s/out_tmp.txt > %s",tmp,out);
	    system(cmd2);
	  }
	}
	else{
	  int number = split(search,thread,tmp);
	  //split the input big file according to the number of threads
	  pthread_t thread_id[number]; //id for each thread
	  char out_tmp[number][D];
	  char sub_search[number][D];
	  struct arg ARG[number]; //arguments for each thread
	  for(int i=0;i<number;i++){
	    sprintf(out_tmp[i],"%s/out_tmp_%d.txt",tmp,i);
	    if(i >= 10)
	      sprintf(sub_search[i],"%s/split_%d",tmp,i);
	    else
	      sprintf(sub_search[i],"%s/split_0%d",tmp,i);
	    
	    ARG[i].search = sub_search[i];
	    ARG[i].putout = out_tmp[i];
	    ARG[i].hmm_class = hmm_class;

	    pthread_create(&(thread_id[i]),NULL,scanFile,&(ARG[i])); 
	    //create a thread and start scaning the input file
	  }
	  
	  for(int i=0;i<number;i++)
	    pthread_join(thread_id[i],NULL); //Threads Waiting...
	  
	  if(out == NULL){
	    char cmd3[D];sprintf(cmd3,"cat %s/out_tmp_*.txt",tmp);
	    system(cmd3);
	  }
	  else{
	    char cmd3[D];sprintf(cmd3,"cat %s/out_tmp_*.txt > %s",tmp,out);
	    system(cmd3);
	  }
	}
	char cmd4[D];sprintf(cmd4,"rm -rf %s",tmp);
	system(cmd4);
      }
    }
  } 
  return 0;
}

void *scanFile(void *argument){

  arg *ARG=(struct arg *)argument; //get the arguments
  char *tmp = (char *)calloc(N,sizeof(char));
  FILE *out = fopen(ARG->putout,"w");
  if(ARG->search != NULL){ //input file is found
    FILE *IN = fopen(ARG->search,"r");
    char *name=(char *)calloc(100,sizeof(char));
    while(fgets(tmp,N,IN))
      if(tmp[0] == '>')
	//if(judge(tmp) == -1)
	sscanf(tmp,"%[^[ \n]]",name); //get the name of the sequence
      else{
	struct OUT *result = ARG->hmm_class.scanSeq(tmp);
	if(result->number > 0){
	  fprintf(out,"%s\n",name);
	  fprintf(out,"%s",tmp);
	  for(int i=0;i<result->number;i++){
	    char *matchSeq = substr(tmp,result->start[i],result->end[i]-result->start[i]+1);  //match sequence
	    if(result->string[i] == 1)
	      fprintf(out,"Score:%0.2f\t+\tmatchSeq(%d-%d):%s\n",result->score[i],result->start[i],result->end[i],matchSeq); //matching start,end and sequence
	    else{
	      char *matchSeq_complementary = complementary(matchSeq);
              fprintf(out,"Score:%0.2f\t-\tmatchSeq(%d-%d):%s\n",result->score[i],result->start[i],result->end[i],matchSeq_complementary); //matching start,end and sequence
	      free(matchSeq_complementary);
	    }
	    free(matchSeq);
	  }
	}
	free(result);
      }
    fclose(IN);
  }
  fclose(out);
}
