#include <iostream>
#include <fstream>
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

#include "fun.h"
using namespace std;

struct pattern {
  int length; //pattern box length
  int *sum; //the sum of A,T,C,G appearance time in every position
  int **matrix; //alignment metrix
  float **score; //Position specific scoring matrix
  float max; //max score of a random sequence
  float min; //min score of a random sequence
  int pos_start; //start position of this pattern box in the training set
  int pos_end; //end position pf the pattern box in the training set
};

struct box { //every box is a state in the Hidden Markov Model
  int length; //state matrix length
  int pos_start; //start position of the pattern box in the training set sequence
  int pos_end; //end position of the pattern box in the training set sequence
  float max,min; //max score and min score
  int **align; //align matrix of the state box
  float **score; //scoring matrix of the state box
};

struct sub_hmm { //sub HMM strctures ,such as TR/VR/RT
  int start; //start site of the sub HMM in the input sequence
  int end; //end site
  float score; //match score of this sub HMM structure
  int index; //index=-1 -> init;  index=0->TR;  index=1->VR  index=2->RT;
};

struct OUT { //scaning result,for sub HMM(TR/VR/RT) or the total DGR
  int number; //matchSeq number
  float score[S]; //score of the matches
  int start[S]; //start site
  int end[S]; //end site
  int string[S]; //string of the match,1::'+' or 2::'-'
  
  int type[S]; //used only for scaning fot total DGR;1->TR,2->VR,3->RT;
  int total_start; //used only for scaning for DGR
  int total_end; //used only for scaning for DGR
  float total_score; //used only for scaning for DGR
  int index; //used only for DGR;0->no hot,1->DGR in found
};

class HMM{
 private:
  int len; //length cuttof used to ensure a state
  int size; //state number in the Hidden Markov Model
  int window; //max box length,used as a window size
  int gap; //max gap length between two states
  float cuttof; //cuttof value for a subsequence matching a state box(0~1)
  char **name; //state names
  struct box **state; //every state is a box,represented by a scoring metrix(Position Specific Scoring Metrix)
  float **trans; //Transition probability Metrix beteen the states
  float *start,*end; //start end end probability for the states
 public:
  float score_cuttof; //score cottof for a sequence belong to this HMM model
  void init(float **trans,struct pattern **metrix,int number,float value,int window_size,int gap_length,int state_length,float seq_score_cottof); //iniatialization of the HMM
  void print(char *dir);
  struct OUT *scanSeqSingle(char *seq); //only scan for positive string
  struct OUT *scanSeqFull(char *seq); //scan for the both two directions
};

void HMM::init(float **transition,struct pattern **score,int number,float cuttof_value,int window_size,int gap_length,int state_length,float seq_score_cuttof){
  len = state_length;
  gap = gap_length;
  size=number; 
  window=window_size;
  cuttof=cuttof_value;
  score_cuttof = seq_score_cuttof;
  
  name = (char **)calloc(size,sizeof(char *));  //allocate memory
  state=(struct box **)calloc(size,sizeof(struct box *));
  trans=(float **)calloc(size,sizeof(float *));
  start=(float *)calloc(size,sizeof(float));
  end=(float *)calloc(size,sizeof(float));
  for(int i=0;i<size;i++){
    name[i]=(char *)calloc(10,sizeof(char));
    sprintf(name[i],"pattern%d",i);
    trans[i]=(float *)calloc(size,sizeof(float));
    state[i]=(struct box *)calloc(1,sizeof(struct box));
  }
  for(int i=0;i<size+2;i++) //get the Transition probability Metrix
    for(int j=0;j<size+2;j++)
      if(i==0 && j>=1 && j<=size)
	start[j-1] = transition[0][j];
      else if(j==size+1 && i>=1 && i<=size)
	end[i-1] = transition[i][size+1];
      else if(i>=1 && i<=size && j>=1 && j<=size)
	trans[i-1][j-1]=transition[i][j];
  for(int i=0;i<size;i++){ //get the states accoring the input patterns
    state[i]->length = score[i]->length;
    state[i]->pos_start = score[i]->pos_start;
    state[i]->pos_end = score[i]->pos_end;
    state[i]->max = score[i]->max;
    state[i]->min = score[i]->min;
    state[i]->align = (int **)calloc(4,sizeof(int *));
    state[i]->score = (float **)calloc(4,sizeof(float *));
    for(int j=0;j<4;j++){
      state[i]->align[j] = (int *)calloc(state[i]->length,sizeof(int));
      state[i]->score[j] = (float *)calloc(state[i]->length,sizeof(float));
      for(int k=0;k<score[i]->length;k++){
	state[i]->align[j][k] = score[i]->matrix[j][k];
	state[i]->score[j][k] = score[i]->score[j][k];
      }
    }
  }
  
}

void HMM::print(char *dir){
  
  char align[1000],score[1000];
  sprintf(align,"%s/align.txt",dir);
  sprintf(score,"%s/score.txt",dir);

  FILE *fp1 = fopen(align,"a");
  FILE *fp2 = fopen(score,"a");

  //fprintf(fp1,"Pattern Name:\t");
  for(int i=0;i<size;i++)
    if(state[i] -> length >= len){
      //fprintf(fp1,"%s(%d-%d:%dbp):\n",name[i],state[i]->pos_start,state[i]->pos_end,state[i]->length);
      fprintf(fp1,"align matrix:\n");
      for(int j=0;j<4;j++){
	switch(j){
	case 0:fprintf(fp1,"A\t");break;
	case 1:fprintf(fp1,"T\t");break;
	case 2:fprintf(fp1,"C\t");break;
	case 3:fprintf(fp1,"G\t");break;
	}
      
	for(int k=0;k<state[i] -> length;k++)
	  if(k == state[i]->length -1)
	    fprintf(fp1,"%d\n",state[i]->align[j][k]);
	  else
	    fprintf(fp1,"%d\t",state[i]->align[j][k]);
      }
      fprintf(fp2,"scoring matrix:\n");
      for(int j=0;j<4;j++){
	switch(j){
        case 0:fprintf(fp2,"A\t");break;
        case 1:fprintf(fp2,"T\t");break;
        case 2:fprintf(fp2,"C\t");break;
        case 3:fprintf(fp2,"G\t");break;
        }

        for(int k=0;k<state[i] -> length;k++)
          if(k == state[i]->length -1)
            fprintf(fp2,"%0.2f\n",state[i]->score[j][k]);
          else
            fprintf(fp2,"%0.2f\t",state[i]->score[j][k]);
      }
      
    }
  
  fprintf(fp2,"Start Probabilities\t");
  for(int i=0;i<size;i++)
    if(state[i] -> length >= len)
      fprintf(fp2,"%0.2f\t",start[i]);
  fprintf(fp2,"\nEnding Probabilities\t");
  for(int i=0;i<size;i++)
    if(state[i] -> length >= len)
      fprintf(fp2,"%0.2f\t",end[i]);
      fprintf(fp2,"\nTrasnition Probability Matrix\n");
  for(int i=0;i<size;i++)
    if(state[i]->length >= len){
      for(int j=0;j<size;j++)
	if(state[j]->length >= len)
	  fprintf(fp2,"%0.2f\t",trans[i][j]);
      fprintf(fp2,"\n");
    }
  
  fprintf(fp2,"Window size:%d\n",window);
  fprintf(fp2,"Gap length:%d\n",gap);
  fprintf(fp2,"Match score cuttof:%0.2f\n",score_cuttof);
  fprintf(fp1,"++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
  fprintf(fp2,"++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
  fclose(fp1);fclose(fp2);
}


struct OUT* HMM::scanSeqSingle(char *seq){
  /*workflow of scaning for TR,VR or RT:
    (1)foreach sub state,set down the matching subSeqs(position as well as score).
    (2)according to the gap length,the whole sequence will be splitted to some search space.
    (3)foreach search space,based on the subSeqs,build many paths according to the veterbi algorithm.
    Every path is a solution for the problem,and the path with the best score will be choosed.
    (4)save all the result satisfying the requirements:score(path) > score_cuttof
   */

  struct OUT *result=(struct OUT *)calloc(1,sizeof(struct OUT));
  result->number=0;

  int box_num = 0; //total state box number in the sequence

  int S2 = strlen(seq);

  int *state_pos = (int *)calloc(S2,sizeof(int));
  int *state_index = (int *)calloc(S2,sizeof(int));
  float *state_score = (float *)calloc(S2,sizeof(float));

  /*
  int state_pos[S2];
  int state_index[S2];
  float state_score[S2];
  */
  for(int i=0;i<S2;i++){
    state_pos[i] = -1;
    state_index[i] = -1;
    state_score[i] = 0.0;
  }
  int number = 0;

  /*Motif scaning strategy:
    if there is a sequence matched,then skip length will be the length of this motif rather then 1.This methos is able to accelerate the process,but may miss the best match in the mean while,which reduces the whole score,leading to a wrong result.
  */

  if(strlen(seq) > window){
    for(int i=0;i<S2-window-1;){ //scan the sequence for every stat,set down the position as well as matching score
      int index=0;
      //index:in this position,exists a state match? 0:no  1:yes
      for(int j=0;j<size;j++){
	if(state[j]->length >= len) {
	  float tmp=0.0;
	  
	  for(int k=0;k < state[j]->length;k++){
	    switch(seq[i+k]){
	    case 'A':tmp += state[j]->score[0][k];break;
	    case 'T':tmp += state[j]->score[1][k];break;
	    case 'C':tmp += state[j]->score[2][k];break;
	    case 'G':tmp += state[j]->score[3][k];break;
	    case 'a':tmp += state[j]->score[0][k];break;
            case 't':tmp += state[j]->score[1][k];break;
            case 'c':tmp += state[j]->score[2][k];break;
            case 'g':tmp += state[j]->score[3][k];break;
	    default:tmp += state[j]->min/state[j]->length;
	      //score for base 'N'
	    }
	  }
	    
	  if(tmp > cuttof*state[j]->max && tmp > 0){
	    state_pos[number] = i;
	    state_index[number] = j;
	    state_score[number] = tmp;
	    i += state[j]->length;
	    number++;
	    index = 1;
	    break;
	  }
	}	
      }
      if(index == 0)
	i++;
    }
  }

  /*There may be many mstchSeqs for an input sequence,if gap length more than the gap,then searching for a new matchSeq*/


  int *search_start = (int *)calloc(S2,sizeof(int));
  int *search_end = (int *)calloc(S2,sizeof(int));
  
  //  int search_start[S2]; //the start index number of the search space
  //int search_end[S2]; //the end index number of the search space
  for(int i=0;i<S2;i++){
    search_start[i] = -1;
    search_end[i] = -1;
  }

  int search_number=0; //according to the gap length,devide the total search space to some small search space
  for(int i=0;i<number;i++){
    if(i==0)
      search_start[0] = 0;
    if(i<number-1 && state_pos[i+1]-state_pos[i] > gap){ //the gap length is more than gap
      search_end[search_number] = i;
      search_number++;
      search_start[search_number] = i+1;
    }
    if(i==number-1){
      search_end[search_number] = number-1;
      search_number++;
    }
  }

  /*For each search space,using veterbi algorithm to find the best path.if the path score is larger than the scpre cuttof,save the score and start position as well as the end position*/
 
  float veterbi_score[number]; //score of the possible path using veterbi algorithm
  int veterbi_start[number]; //matching start of the veterbi path
  for(int i=0;i<number;i++){
    veterbi_score[i] = 0.0;
    veterbi_start[i] = -1;
  }

  int num=0; //number of matchSeqs in all the search space
  for(int k=0;k<search_number;k++){
    for(int i=search_start[k];i <= search_end[k];i++){
      float max = 0.0;
      
      if(start[state_index[i]] != 0){
	float score_tmp = start[state_index[i]] * state_score[i]; //start probability
	if(score_tmp > max){
	  max = score_tmp;
	  veterbi_start[i] = state_pos[i];
	}
      }
      if(i > search_start[k])
	for(int j=search_start[k];j<i;j++){
	  float score_tmp = 0.0;
	  if(trans[state_index[j]][state_index[i]] != 0 && veterbi_score[j] != 0){
	    score_tmp = veterbi_score[j] + state_score[i] * trans[state_index[j]][state_index[i]];  //state transition
	    if(score_tmp > max){
	      max = score_tmp;
	      veterbi_start[i] = veterbi_start[j]; //update ths start site of the veterbi path
	    }
	  }
	}
      veterbi_score[i] = max;
    }
    
    float score_search=0.0;int start_search=-1;int end_search=-1;
    /*for each search space,there may be many pathway if exists more then one state.According to the veterbi algorithm,choose the path with the highest score*/
    for(int j=search_start[k];j<=search_end[k];j++){
      if(end[state_index[j]] != 0 && veterbi_score[j] != 0){
	float score_tmp = veterbi_score[j] + end[state_index[j]];
	if(score_tmp > score_search){
	  score_search = score_tmp;
	  end_search = state_pos[j]+state[state_index[j]]->length-1;
	  start_search = veterbi_start[j];
	}
      }
    }
    if(score_search > score_cuttof){
      result->score[num] = score_search;
      result->start[num] = start_search;
      result->end[num] = end_search;
      num++;
      result->number ++;
    }
  } 

  free(state_pos);free(state_index);free(state_score);
  free(search_start);free(search_end);
  return result;
}

struct OUT* HMM::scanSeqFull(char *seq){
  struct OUT *result=(struct OUT *)calloc(1,sizeof(struct OUT));
  result->number=0;
  
  struct OUT *result1 = scanSeqSingle(seq); //positive chain
  char *seq_complementary = complementary(seq);
  struct OUT *result2 = scanSeqSingle(seq_complementary); //negative chain

  int length = strlen(seq);
  int num=0;
  if(result1->number > 0)
    for(int i=0;i<result1->number;i++,num++){
      result->score[num] = result1->score[i];
      result->start[num] = result1->start[i];
      result->end[num] = result1->end[i];
      result->string[num] = 1;
    }
  
  if(result2->number > 0)
    for(int i=0;i<result2->number;i++,num++){
      result->score[num] = result2->score[i];
      result->start[num] = length-1-result2->end[i];
      result->end[num] = length-1-result2->start[i];
      result->string[num] = 2;
    }
  
  result->number = num;
  free(result1);free(result2);free(seq_complementary);
  return result;
}

HMM buildHMM(int ARGC,char* ARGV[]){
  int L=0; //sequence length in the multiAlignment result
  float cov=0.9; //coverage cuttof in every position to make a pattern box
  int box_len_cuttof=7; //pattern box length cuttof
  int max_box_length=0; //max length of the insured patterns
  int pattern_number=0; //pattern box number in total
  float state_score=0.4; //cuttof of the score(ratio) used to ensure a state
  float ratio=1; //TP value to control when testing
  int gap = 100; //gap between the states
  float ic = 0.5; //IC value cuttof

  float **transition; //state transition probability metrix,including start,end,and transition between states
  HMM hmm;

  /*Workflow of building HMM model:
    (1)Some arguments is ensured,including the coverage ,state length cuttof,state score cuttof,scaning ratio value,gap length as well as the information value cuttof(IC).
    (2)according to the input file,get the aligned sequence length and sequence number(number)
    (3)according to the aligned sequences,fetch count metrix,to store the appearance times of A,T,C,G in every position.In the mean while,get the sum of A/T/C/G in every position(in a given pisition,some sequences may be gap '-')
    (4)calculate prior probabilities of A,T,C,G,for example,prior(A)=number of A / number of A+T+C+G
    (5)accoring to the count matrix,calculating the scoring matrix
    the score matrix like this:score[5][L],the first array score[0] is the coverage of this position,score[0][i]=sum[i]/number
    scoring matrix formula:
    score[i+1][j] = log(count[i][j]/(priori[i]*sum[j]))*sum[j]/number;
    (6)IC value calculation:
    for(j=0;j<4;j++)
    IC[i] += log(count[j][i]/(priori[j]*sum[i]))*count[j][i]/sum[i];
    (7)accoring to the scoring matrix(PWM),build some patterns,gapped by some low coverage or low information regions
    for each pattern,the main elements:a scoring matrix and a align matrix
    (8)accoring to the patterns and training set sequences,build transition metrix,like this:
    Start  pattern0  pattern1 ... patternN  End
    pattern0  ...
    pattern1  ...
    .
    .
    .
    End  ...
    for example,transition[0][1] means the start probability of patern0;transition[1][N+2] means the ending probability of pattern0
    (9)based on the transition matrix and patterns,calculate the scores of training set sequences and ensure the scaning score cuttof according to the score ratio
    (10)build the HMM model using the above elements:
    hmm.init(transition,scan,pattern_number,state_score,max_box_length,gap,box_len_cuttof,score_cuttof);
   */

  if(ARGC < 2)
    usage(ARGV[0]);
  else{
    int i,j,k;
    FILE *in=NULL; //file used to build the PWM
    int in_position;
    for(i=0;i<ARGC;i++)
      if(strcmp(ARGV[i],"-build") == 0){
	in=fopen(ARGV[i+1],"r");
	in_position = i+1;
      }
      else if(strcmp(ARGV[i],"-cov") == 0)
	cov = atof(ARGV[i+1]);
      else if (strcmp(ARGV[i],"-len") == 0)
	box_len_cuttof = atoi(ARGV[i+1]);
      else if (strcmp(ARGV[i],"-score") == 0)
	state_score = atof(ARGV[i+1]);
      else if (strcmp(ARGV[i],"-ratio") == 0)
	ratio = atof(ARGV[i+1]);
      else if (strcmp(ARGV[i],"-gap") == 0)
	gap = atoi(ARGV[i+1]);
      else if (strcmp(ARGV[i],"-ic") == 0)
        ic = atof(ARGV[i+1]);
      else if(strcmp(ARGV[i],"-h") == 0)
	usage(ARGV[0]);
    
    if(in == NULL || cov <= 0 || cov >1){
      usage(ARGV[0]);
      return hmm;
    }
    else{
      char *tmp=(char *)calloc(N,sizeof(char));
      while(fgets(tmp,N,in)){
	if(judge(tmp) == 0)
	  if(L == 0)
	    L=strlen(tmp)-1; //get the aligned sequence length
      }
      fclose(in);
      
      in=fopen(ARGV[in_position],"r");
      int count[4][L]; //align metrix,store the appearance times of A,T,C,G in every position
      char symbol[4]={'A','T','C','G'}; //symbol index,A-T-C-G
      float priori[4]; //priori probability of the background
      int pri_tmp[4]; //a buffer to store the appearance times of A,T,C,G,used to calculate the  priori probability
      int sum[L]; //sum of the symbol appearance in every position
      float IC[L]; //information value in every position
      int number=0; //sequence number
      for(i=0;i<4;i++){  //Initialization of the alignment metrix(count) and priori probability
	priori[i] = 0.0;
	pri_tmp[i] = 0;
	for(j=0;j<L;j++)
	  count[i][j]=0;
      }
      while(fgets(tmp,N,in)){  //read the input sequences and build the alignment matrix
	if(judge(tmp) == 0){
	  number++;
	  for(i=0;i<strlen(tmp)-1;i++)
	    switch(tmp[i]){
	    case 'A':count[0][i]++;break;
	    case 'T':count[1][i]++;break;
	    case 'C':count[2][i]++;break;
	    case 'G':count[3][i]++;break;
	    }
	}
      }
      for(i=0;i<L;i++){
	for(j=0;j<4;j++)
	  pri_tmp[j] += count[j][i];
	sum[i]=count[0][i]+count[1][i]+count[2][i]+count[3][i];
      }
      for(j=0;j<4;j++)
	priori[j] = pri_tmp[j]*1.0/(pri_tmp[0]+pri_tmp[1]+pri_tmp[2]+pri_tmp[3]);
      
      float **score=(float **)calloc(5,sizeof(float *)); //Positon Specific Scoring Metrix,including the positon coverage(score[0])
      for(i=0;i<5;i++)
	score[i]=(float *)calloc(L,sizeof(float));
      for(i=0;i<L;i++){
	score[0][i]=sum[i]*1.0/number; //calculate position coverage
	IC[i] = 0.0;
	
	for(j=0;j<4;j++)
	  if(count[j][i] != 0)
	    IC[i] += log(count[j][i]/(priori[j]*sum[i]))*count[j][i]/sum[i]; //calculate IC value
      }
      for(i=0;i<4;i++)
	for(j=0;j<L;j++)  
	  if(count[i][j] == 0)
	    score[i+1][j]=-10.0;
	  else
	    score[i+1][j] = log(count[i][j]/(priori[i]*sum[j]))*sum[j]/number; //formula to calculate the score of every position
      
      struct pattern **scan=(struct pattern **)calloc(M,sizeof(struct pattern *));  //store some subPattern in the whole scoring matrix
      for(i=0;i<M;i++){  //initialization of the pattern boxes
	scan[i]=(struct pattern *)calloc(1,sizeof(struct pattern));
	scan[i]->length=0;
	scan[i]->max=0.0;
	scan[i]->min=0.0;
	scan[i]->pos_start=-1;
	scan[i]->pos_end=-1;
	scan[i]->score=(float **)calloc(4,sizeof(float *));
	scan[i]->matrix=(int **)calloc(4,sizeof(int *));
	scan[i]->sum=(int *)calloc(P,sizeof(int));
	for(j=0;j<4;j++){
	  scan[i]->score[j]=(float *)calloc(P,sizeof(float));
	  scan[i]->matrix[j]=(int *)calloc(P,sizeof(int));
	}
      }
      for(i=0,j=0,k=0;i<L;i++){
	if(score[0][i] >= cov){
	  //	if(score[0][i] >= cov && IC[i] >= ic){
	  if(scan[k]->pos_start == -1)
	    scan[k]->pos_start = i;
	  scan[k]->length += 1;
	  scan[k]->score[0][j]=score[1][i];scan[k]->matrix[0][j]=count[0][i];
	  scan[k]->score[1][j]=score[2][i];scan[k]->matrix[1][j]=count[1][i];
	  scan[k]->score[2][j]=score[3][i];scan[k]->matrix[2][j]=count[2][i];
	  scan[k]->score[3][j]=score[4][i];scan[k]->matrix[3][j]=count[3][i];
	  scan[k]->sum[j]=sum[i];
	  j++;
	  if(i==L-1){
	    scan[k]->pos_end=i;
	    k++;
	  }
	}
	else if(i>0 && score[0][i-1] >= cov){
	//else if(i>0 && score[0][i-1] >= cov && IC[i-1] >= ic){
	  scan[k]->pos_end=i-1;
	  k++;
	  j=0;
	}
      }
      pattern_number = k; //pattern  number satisfying given conditions(such as coverage,length,i.e.)
      //calculate the max_box_length,min/max score,Information content and corresponding p value of every pattern
      for(i=0;i<pattern_number;i++){  
	if(scan[i]->length > max_box_length)
	  max_box_length = scan[i]->length;
	for(j=0;j < scan[i]->length;j++){
	  float max=scan[i]->score[0][j];
	  float min=scan[i]->score[0][j];
	  for(k=1;k<=3;k++){
	    if(scan[i]->score[k][j] > max)
	      max = scan[i]->score[k][j];
	    if(scan[i]->score[k][j] < min)
	      min = scan[i]->score[k][j];
	  }
	  scan[i]->max += max;
	  scan[i]->min += min;
	}
      }
      
      fclose(in);
      in=fopen(ARGV[in_position],"r");
     

/* buildTransition */
      int num=pattern_number+2; //state number:pattern_number+2(start+patterns+end)
      int trans_count[num][num]; //state transition frequency(times) in the training set
      transition = (float **)calloc(num,sizeof(float *)); //start transition probability metrix
      for(i=0;i<num;i++){
	transition[i]=(float *)calloc(num,sizeof(float));
	for(j=0;j<num;j++)
	  trans_count[i][j]=0;
      }
      
      while(fgets(tmp,N,in))
	if(judge(tmp) != -1){
	  int pattern_index[pattern_number];
	  for(i=0;i<pattern_number;i++)
	    pattern_index[i]=-1;
	  for(i=0,k=0;i<pattern_number;i++){
	    if(scan[i]->length >= box_len_cuttof){
	      float score=0.0;
	      char *sub=substr(tmp,scan[i]->pos_start,scan[i]->length);
	      for(j=0;j<strlen(sub);j++)
	        switch(sub[j]){
		case 'A':score += scan[i]->score[0][j];break;
		case 'T':score += scan[i]->score[1][j];break;
		case 'C':score += scan[i]->score[2][j];break;
		case 'G':score += scan[i]->score[3][j];break;
		default:score += 0;
		}
	      if(score > state_score*scan[i]->max){
		pattern_index[k] = i;
		k++;
	      }
	    }
	  }
	  for(i=0;i<k;i++){
	    int id = pattern_index[i];
	    if(i == 0)
	      trans_count[0][id+1]++; //start -> pattern
	    if(i == k-1)
	      trans_count[id+1][num-1]++; //pattern -> end
	    if(i>0){
	      int id2 = pattern_index[i-1]; //pattern -> pattern
	      trans_count[id2+1][id+1]++;
	    }
	  }
	}
      
      for(i=0;i<num;i++){
	int sum_line = 0;
	for(j=0;j<num;j++)
	  sum_line += trans_count[i][j];
	for(j=0;j<num;j++)
	  transition[i][j] = sum_line>0?trans_count[i][j]*1.0/sum_line:0.0; //calculate probability
      }
      fclose(in);
/* BuildTransition End */

/*Get the score cottof for a HMM matching according to the training set */
      int line = 0;
      float *score_train=(float *)calloc(1000,sizeof(float));
      for(i=0;i<1000;i++)
	score_train[i] = 0.0;
      
      in=fopen(ARGV[in_position],"r"); //get the cuttof value of scaning according to the annotated training set
      while(fgets(tmp,N,in))
	if(judge(tmp) == 0){
	  int pri = -1; //the previous state
	  float path_score=0.0;
	  for(i=0,k=0;i<pattern_number;i++){
	    if(scan[i]->length >= box_len_cuttof){
	      float score=0.0;
	      char *sub=substr(tmp,scan[i]->pos_start,scan[i]->length);
	      for(j=0;j<strlen(sub);j++)
		switch(sub[j]){
		case 'A':score += scan[i]->score[0][j];break;
		case 'T':score += scan[i]->score[1][j];break;
		case 'C':score += scan[i]->score[2][j];break;
		case 'G':score += scan[i]->score[3][j];break;
		default:score += 0;
		}
	      if(score > state_score*scan[i]->max){
		if(pri == -1)
		  path_score += score*transition[0][i+1];
		else
		  path_score += score*transition[pri+1][i+1];
		pri = i;
	      }
	    }
	  }
	  if(pri != -1)
	    path_score += transition[pri+1][pattern_number+1];
	  score_train[line] = path_score;
	  line++;
	}
      fclose(in);
      float score_cuttof=cuttof(&score_train,line,ratio);
      hmm.init(transition,scan,pattern_number,state_score,max_box_length,gap,box_len_cuttof,score_cuttof);
    }
  }
  return hmm;
}

class HMM_class { //clusters of GHMM model
 public:
  HMM *hmm;
  //multi similar GHMM models,which belongs to different classes
  int _number; //number of clusters(models)
  void init(char *config); //initialization,based on the config file
  void print(char *dir);
  struct OUT *scanSeq(char *seq); //scaning a new sequence
};

/*build class of HMM models according to the input config file*/
void HMM_class::init(char *config){
  FILE *CONFIG = fopen(config,"r"); //config file
  
  int size = 10;
  //default sub claster number:10 (sub HMM model number:10)

  int ARGC[size];
  char ***ARGV=(char ***)calloc(size,sizeof(char **));
  for(int i=0;i<size;i++){
    ARGC[i] = 1;
    ARGV[i] = (char **)calloc(20,sizeof(char *));
    for(int j=0;j<20;j++)
      ARGV[i][j] = (char *)calloc(100,sizeof(char));
  }
  
  int class_number = -1;
  int arg_number = 0;
  char *tmp = (char *)calloc(N,sizeof(char));
  char *name = (char *)calloc(N,sizeof(char));
  char *content = (char *)calloc(N,sizeof(char));
  
  while(fgets(tmp,N,CONFIG)){
    char *tmp_new = chomp(tmp);
    if(strstr(tmp_new,"[motif]")){ 
      //[motif] means a new motif,and a new GHMM model will be built
      class_number += 1;
      arg_number = 0;
    }
    else if(strstr(tmp_new,"=")){
      name = array_split(tmp_new,'=',0);
      content = array_split(tmp_new,'=',1);      
      ARGV[class_number][arg_number] = arg_name(name);
      ARGV[class_number][arg_number+1] = content;
      arg_number += 2;
      ARGC[class_number] += 2;
    }
  }

  _number = class_number+1;
  hmm = (HMM *)calloc(class_number+1,sizeof(HMM));
  for(int i=0;i<_number;i++)
    hmm[i] = buildHMM(ARGC[i],ARGV[i]);
    //foreach set of arguments,build a corresponding HMM model
}

void HMM_class::print(char *dir){
  for(int i=0;i<_number;i++)
    hmm[i].print(dir);

  char align[1000],score[1000];
  sprintf(align,"%s/align.txt",dir);
  sprintf(score,"%s/score.txt",dir);
  FILE *fp1 = fopen(align,"a");
  FILE *fp2 = fopen(score,"a");
  fprintf(fp1,"######################################################\n");
  fprintf(fp2,"######################################################\n");
  fclose(fp1);fclose(fp2);
}

/*scan the new sequences using the clusters of GHMMs*/
struct OUT* HMM_class::scanSeq(char *seq){
  
/*WorkFlow:
1>Every GHMM model is used to scan a new sequence,and reserve all the results
2>Filter the results,and if two matchSeqs overlap,merge the two matchSeqs(add the score,it means a stronger information)
3>putout the merged results
*/

  int arr_start[S],arr_end[S];int arr_string[S];
  float arr_score[S];

  int num=0;
  /*scaning for all the HMM models and reserve all the result_tmps*/
  for(int i=0;i<_number;i++){
    struct OUT *result_tmp_sub = hmm[i].scanSeqFull(seq);

    if(result_tmp_sub->number != 0)
      for(int j=0;j<result_tmp_sub->number;j++){	
	arr_start[num] = result_tmp_sub->start[j];
	arr_end[num] = result_tmp_sub->end[j];
	arr_score[num] = result_tmp_sub->score[j];
	arr_string[num] = result_tmp_sub->string[j];
	num ++;
      }
    free(result_tmp_sub);
  }

  /*Sort the array according to the start position,using quick sort*/
  q_sort_state(arr_start,arr_end,arr_score,arr_string,0,num-1);
  
  struct OUT *result=(struct OUT *)calloc(1,sizeof(struct OUT));
  result->number = 0;
  
  int pos = 0;
  for(int i=0;i<num;i++){
    if(pos == 0){
      result->start[pos] = arr_start[i];
      result->end[pos] = arr_end[i];
      result->score[pos] = arr_score[i];
      result->string[pos] = arr_string[i];
      pos++;
      result->number ++;
    }
    else if(arr_start[i] < result->end[pos-1] && arr_string[i]==result->string[pos-1]){
      //overlap and merge
      result->end[pos-1] = (result->end[pos-1] > arr_end[i])?result->end[pos-1]:arr_end[i];
      result->score[pos-1] += arr_score[i];
    }
    else{
      result->start[pos] = arr_start[i];
      result->end[pos] = arr_end[i];
      result->score[pos] = arr_score[i];
      result->string[pos] = arr_string[i];
      pos++;
      result->number ++;
    }
  }

  return result;
}


//struct OUT *searchVR(char *seq,struct OUT **TR,int misMatch);

class SCAN{ //main HMM model used to scan the unknown sequence
 private:
  HMM_class state[3]; //three sub state:TR/VR/RT
  int gap; //gap between sub HMMs
  //float **trans; //transition probability
  //float *start; //start probability
  //float *end; //end probability
 public:
  void init(HMM_class init_TR,HMM_class init_VR,HMM_class init_RT,int init_gap);
  //void init(HMM_class init_TR,HMM_class init_VR,HMM_class init_RT,char *dgr_summary,int init_gap);
  void print(char *dir);
  struct OUT *scanSeq(char *seq);
};

void SCAN::init(HMM_class init_TR,HMM_class init_VR,HMM_class init_RT,int init_gap){
//void SCAN::init(HMM_class init_TR,HMM_class init_VR,HMM_class init_RT,char *dgr_summary,int init_gap){
  state[0]=init_TR;state[1]=init_VR;state[2]=init_RT;
  gap=init_gap;

  /*
  FILE *summary = fopen(dgr_summary,"r"); //the DGR summary file,used to get start/end/transition probabilities
  if(summary == NULL)
    printf("Error,%s not exists\n",dgr_summary);
  else{
    start = (float *)calloc(3,sizeof(float)); //initialization and allocate memory
    end = (float *)calloc(3,sizeof(float));
    trans = (float **)calloc(3,sizeof(float *));
    for(int i=0;i<3;i++)
      trans[i] = (float *)calloc(3,sizeof(float));
    
    char **data = (char **)calloc(100,sizeof(char *));
    for(int i=0;i<10;i++)
      data[i] = (char *)calloc(100,sizeof(char));

    int i=0;
    while(fgets(data[i],100,summary)) //read from file 
      i++;

    for(i=0;i<3;i++){
      start[i] = atof(array_split(data[1],'\t',i));
      end[i] = atof(array_split(data[3],'\t',i));
    }
    for(int j=0;j<3;j++){
      trans[0][j] = atof(array_split(data[5],'\t',j));
      trans[1][j] = atof(array_split(data[6],'\t',j));
      trans[2][j] = atof(array_split(data[7],'\t',j));
    }
    fclose(summary);
    }*/
}

void SCAN::print(char *dir){
  for(int i=0;i<3;i++)
    state[i].print(dir);
  
  char score[1000];
  sprintf(score,"%s/score.txt",dir);
  FILE *fp2 = fopen(score,"a");
  /*
  fprintf(fp2,"Start Probability:%0.2f\t%0.2f\t%0.2f\n",start[0],start[1],start[2]);
  fprintf(fp2,"End Probability:%0.2f\t%0.2f\t%0.2f\n",end[0],end[1],end[2]);
  fprintf(fp2,"Transition Probability:\n");
  for(int i=0;i<3;i++)
    fprintf(fp2,"%0.2f\t%0.2f\t%0.2f\n",trans[i][0],trans[i][1],trans[i][2]);
  */
  fprintf(fp2,"Gap Length:%d\n",gap);
  fclose(fp2);
}

/*Workflow for scan the whole DGR:
  1>the sub structures(TR,VR and RT) are found using Motif-GHMM method
  2>split the whole space into some smaller search space according to the distribution of the gap length
  3>recall DGR structure for each search space
*/
struct OUT *SCAN::scanSeq(char *seq){
  struct OUT *result=(struct OUT *)calloc(1,sizeof(struct OUT));
  result->number = 0;result->index = 0;result->total_score = 0.0;
  //the final result
  

/*The scaning order is very important for the efficiency.
  Based on the test result, the scaning order is : TR->RT->VR
*/
  
  struct OUT *scan_sub[3];

  scan_sub[0] = state[0].scanSeq(seq);  
  if(scan_sub[0]->number >0){ //scaning for TR firstly
    scan_sub[2] = state[2].scanSeq(seq);

    if(scan_sub[2]->number >0){ //scaning for RT secondly

      scan_sub[1] = state[1].scanSeq(seq);
      int number_sub=0,start_sub[S],end_sub[S],type_sub[S];
      float score_sub[S];int string_sub[S];
      
      //fetch all the sub matchSequences to some tmp arrayes
      for(int k=0;k<3;k++)
	for(int i=0,j=number_sub;i<scan_sub[k]->number;i++,j++){
	  start_sub[j] = scan_sub[k]->start[i];
	  end_sub[j] = scan_sub[k]->end[i];
	  score_sub[j] = scan_sub[k]->score[i];
	  string_sub[j] = scan_sub[k]->string[i];
	  type_sub[j] = k+1;
	  number_sub += 1;
	}
      
      //int length = strlen(seq);

      //sort the array according to the start position
      for(int i=0;i<number_sub-1;i++){
	int pos = i,current_start=start_sub[i];
	for(int j=i+1;j<number_sub;j++)
	  //compare and set down the exchange position
	  if(start_sub[j] < current_start){
	    pos = j;
	    current_start=start_sub[j];
	  }
	if(pos != i){ //exchange the two matchSeqs
	  int tmp1=start_sub[i],tmp2=end_sub[i],tmp3=type_sub[i];
	  float tmp4=score_sub[i];int tmp5=string_sub[i];
	  start_sub[i]=start_sub[pos];end_sub[i]=end_sub[pos];type_sub[i]=type_sub[pos];score_sub[i]=score_sub[pos];string_sub[i]=string_sub[pos];
	  start_sub[pos]=tmp1;end_sub[pos]=tmp2;type_sub[pos]=tmp3;score_sub[pos]=tmp4;string_sub[pos]=tmp5;
	}
      }
      
      int pos = 0;
      for(int i=0;i<number_sub;){
	if(result->number == 0){
	  result->start[pos] = start_sub[i];
	  result->end[pos] = end_sub[i];
	  result->type[pos] = type_sub[i];
	  result->score[pos] = score_sub[i];
	  result->string[pos] = string_sub[i];
	  result->number ++;
	  pos++;
	  i++;
	}
	else if(start_sub[i]-result->start[pos-1] <= gap){
	  //If a TR and a VR overlaps,merge it to a TR.
	  if(start_sub[i] < result->end[pos-1] && (type_sub[i]*result->type[pos-1])%3 != 0){
	    result->end[pos-1] = (result->end[pos-1]>end_sub[i])?result->end[pos-1]:end_sub[i];
	    result->type[pos-1] = 1;
	    result->score[pos-1] += score_sub[i];
	    i++;
	  }
	  else{
	    result->start[pos] = start_sub[i];
	    result->end[pos] = end_sub[i];
	    result->type[pos] = type_sub[i];
	    result->score[pos] = score_sub[i];
	    result->string[pos] = string_sub[i];
	    result->number ++;
	    pos++;
	    i++;
	  }
	}
	else{
	  //gap length > gap,check for the last search space,whether a DGR can be found.
	  int product = 1; //index for the result,if product%30 == 0 at last,there is a intact DGR structure (30=2*3*5)
	  result->total_start = result->start[0];
	  result->total_end = result->end[0];
	  result->total_score = 0.0;
	  for(int j=0;j<result->number;j++){
	    result->total_score += result->score[j];
	    if(result->end[j] > result->total_end)
	      result->total_end = result->end[j];
	    if(result->type[j] == 1)
	      product *= 2;
	    else if(result->type[j] == 2)
	      product *= 3;
	    else if(result->type[j] == 3)
	      product *= 5;
	  }
	  if(product%10 == 0){ //a DGR is found:TR+VR,maybe no VR
	    result->index = 1;
	    break;
	  }
	  else{
	    result->number = 0;
	    pos = 0;
	  }
	}
      }
      
      if(result->index == 0){
	//no DGR found for the last search space,check the current search space
	int product = 1;
	result->total_start = result->start[0];
	result->total_end = result->end[0];
	result->total_score = 0.0;
	for(int j=0;j<result->number;j++){
	  result->total_score += result->score[j];
	  if(result->end[j] > result->total_end)
	    result->total_end = result->end[j];	    
	  if(result->type[j] == 1)
	    product *= 2;
	  else if(result->type[j] == 2)
	    product *= 3;
	  else if(result->type[j] == 3)
	    product *= 5;
	}
	if(product%10 == 0)
	  result->index = 1;
      }
      free(scan_sub[1]);
    }
    free(scan_sub[2]);
  }
  free(scan_sub[0]);
  return result;
}

