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
This script is used to build a Weight Count Model according to the motif.In the meantime,get some conserved regions.And build GHMM models according to the motifs and using these GHMM models to predict new structures in unknown sqeuences;
*/

/*
In the phase of finding motif,the training set sequences are clustered according to the result of multi-alignment.Foreach sub class,we find the best motif and build corresponding GHMM model.When scaning for a new unknown sequence,these GHMM models are combinded.This method may be not so efficient,but will be better in sensitivity as well as specificity.
*/

/*WorkFlow:
1>According to the trainging set,cluster the data to some sub clusters
2>Foreach cluster,find the best sequence motif using glam2 or muscle
3>Foreach motif,a GHMM model is built
4>All the GHMM models are used to scan for a new sequence
5>Combind the results of different GHMM model
6>combind the results of different parts,for example:DGR=TR+VR+RT
*/

struct DGR {
  HMM_class TR; //clusters of TR
  HMM_class VR; //clusters of VR
  HMM_class RT; //clusters of RT
  //char *DGR_summary; 
  //summary of DGR structures,includes the starting,ending and transition probability
};

struct arg { 
  //arguments to scan the input file when using multi threads
  char *search; //INPUT
  char *putout; //OUTPUT
  SCAN dgrScan; 
  //the scan method,include three sub GHMM Models and a main GHMM model
};

void *scanDGR(void *argument); //scan the unknown sequence using the model
DGR *buildDGR(FILE *config); //build the DGR according to the config file

int main(int argc,char* argv[]){
  if(argc < 3){
    usage(argv[0]);
    return 0;
  }
  else{
    int thread = 1; //thread number
    FILE *config=NULL; //config file
    char *search=NULL; //unknown sequences file to scan
    char *dir="out_metacsst";; //out directory
    for(int i=1;i<argc;i++)
      if(strcmp(argv[i],"-thread") == 0)
        thread = atoi(argv[i+1]);
      else if (strcmp(argv[i],"-build") == 0)
        config = fopen(argv[i+1],"r");
      else if (strcmp(argv[i],"-in") == 0)
	search = argv[i+1];
      else if (strcmp(argv[i],"-out") == 0)
        dir=argv[i+1];
      else if(strcmp(argv[i],"-h") == 0){
	usage(argv[0]);
	return 0;
      }
    
    if(config != NULL){

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
      sprintf(out,"%s/raw.gtf",dir);


      DGR *dgr = buildDGR(config);
      //build DGR model accoring the config file
      SCAN dgrScan; //a parameter used in the multi-thread scaning
      dgrScan.init(dgr->TR,dgr->VR,dgr->RT,10000);
      //  dgrScan.init(dgr->TR,dgr->VR,dgr->RT,dgr->DGR_summary,10000);
      dgrScan.print(dir);

      if(search != NULL){
	char cmd1[100];sprintf(cmd1,"mkdir %s",tmp);system(cmd1);
	if(thread == 1){
	  char out_tmp[40];sprintf(out_tmp,"%s/out_tmp.txt",tmp);
	  struct arg ARG;
	  ARG.search = search;
	  ARG.putout = out_tmp;
	  ARG.dgrScan = dgrScan;

	  pthread_t thread;
	  scanDGR(&ARG);
	  
	  if(out == NULL){
	    char cmd2[D];sprintf(cmd2,"cat %s/out_tmp.txt",tmp);system(cmd2);
	  }
	  else{
	    char cmd2[D];sprintf(cmd2,"cat %s/out_tmp.txt > %s",tmp,out);system(cmd2);
	  }
	}
	else{
	  int number = split(search,thread,tmp); //split the input big file according to the number of threads
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
	    ARG[i].dgrScan=dgrScan;
	    pthread_create(&(thread_id[i]),NULL,scanDGR,&(ARG[i])); //create a thread and start scaning the input file
	  }

	  for(int i=0;i<number;i++)
	    pthread_join(thread_id[i],NULL); //Threads Waiting...
	  
	  if(out == NULL){
	    char cmd3[D];sprintf(cmd3,"cat %s/out_tmp_*.txt",tmp);system(cmd3);
	  }
	  else{
	    char cmd3[D];sprintf(cmd3,"cat %s/out_tmp_*.txt > %s",tmp,out);system(cmd3);
	  }
	}
	char cmd4[D];sprintf(cmd4,"rm -rf %s",tmp);system(cmd4);
      }
    }
  }
  return 0;
}


DGR *buildDGR(FILE *config){
  /*buildDGR:Reading the arguments from the config file(arg.config) firstly,and then build three GHMM model and a main GHMM model.*/
  DGR *dgr=(DGR *)calloc(1,sizeof(DGR));

  //char *dgr_summary;
  int number=0,index = 0;
  char *tmp = (char *)calloc(N,sizeof(char));
  char *name = (char *)calloc(N,sizeof(char));
  char *content = (char *)calloc(N,sizeof(char));
  while(fgets(tmp,N,config)){
    char *tmp_new = chomp(tmp);
    if(strstr(tmp_new,"[RT]"))
      index = 0;
    else if(strstr(tmp_new,"[TR]"))
      index = 1;
    else if(strstr(tmp_new,"[VR]"))
      index = 2;
    //else if(strstr(tmp_new,"[DGR]"))
    // index = 3;
    else if(strstr(tmp_new,"=")){
      name = array_split(tmp_new,'=',0);
      content = array_split(tmp_new,'=',1);
      if(index == 0){
	dgr->RT.init(content);
      }
      else if(index ==1)
	dgr->TR.init(content);
      else if(index ==2)
        dgr->VR.init(content);
      //else if(index == 3)
      //	dgr_summary = content;
    }
  }
  fclose(config);
  
  //  dgr->DGR_summary = dgr_summary;
  return dgr;
}

void *scanDGR(void *argument){
  arg *ARG=(struct arg *)argument; //get the arguments
  char *tmp = (char *)calloc(N,sizeof(char));
  FILE *out = fopen(ARG->putout,"w");
  if(ARG->search != NULL){

    FILE *IN = fopen(ARG->search,"r");
    char *name=(char *)calloc(100,sizeof(char));
    while(fgets(tmp,N,IN))
      if(tmp[0] == '>'){
      //if(strstr(tmp,">") != NULL){
	sscanf(tmp,">%[^[ \n]]",name); //name of the sequence
      }
      else{
	struct OUT *result = ARG->dgrScan.scanSeq(tmp);
	if(result->index == 1){ //index=1,there is sequence match
	  for(int i=0;i<result->number;i++){
	    if(result->type[i] != 2){
	      int start = result->start[i],end = result->end[i];
	      fprintf(out,"%s\t",name);
	      switch(result->type[i]){
	      case 1:fprintf(out,"TR\t");break;
		//case 2:fprintf(out,"VR\t");break;
	      case 3:fprintf(out,"RT\t");break;
	      }
	      
	      char *matchSeq = substr(tmp,start,end-start+1);
	      if(result->string[i] == 1)
		fprintf(out,"%0.2f\t+\t%d\t%d\t%s\n",result->score[i],start,end,matchSeq);
	      else{
		char *matchSeq_complementary = complementary(matchSeq);
		fprintf(out,"%0.2f\t-\t%d\t%d\t%s\n",result->score[i],start,end,matchSeq_complementary);
		free(matchSeq_complementary);
	      }
	      free(matchSeq);
	    }
	  }
	  char *matchSeq = substr(tmp,result->total_start,result->total_end-result->total_start+1);
	  fprintf(out,"%s\tDGR\t%0.2f\t*\t%d\t%d\t%s\n",name,result->total_score,result->total_start,result->total_end,matchSeq);
	  free(matchSeq);
	}
	free(result);
      }
    fclose(IN);

  }
  fclose(out);
}
