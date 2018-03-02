#!/usr/bin/bash
 
k=10
#k-fold cross validation

if [ 1 == 2 ]
then

#move the redundant DGRs in the dataset based on cd-hit-est (identity=0.95)
#cd-hit-est -i dataSet/merged.dgr.fa -c 0.95 -o dataSet/merged.dgr_cdhit0.95.fa
perl dataSet/mvRedundantGTF.pl dataSet/merged.gtf dataSet/merged.dgr_cdhit0.95.fa dataSet/merged_cdhit0.95.gtf

#randomize the sequences order in the merged.gtf
perl dataSet/randomize.pl dataSet/merged_cdhit0.95.gtf dataSet/merged_cdhit0.95_randomized.gtf

#split the dataset to training and test, repeating k times, with different test datasets;
./splitData.pl dataSet/merged_cdhit0.95_randomized.gtf dataSet/merged.dgr_cdhit0.95.fa $k

for ((i=1; i<=$k; i ++))
do
    nohup mafft --quiet --thread 2 group_$i/train/RT.fa > group_$i/classify/classify_RT/RT.mafft &
done


for ((i=1; i<=$k; i ++))
do
    type=(TR VR)
    for j in ${type[@]}
    do
    mafft --quiet group_$i/train/$j.fa > group_$i/classify/classify_$j/$j.mafft
    done
done

for ((i=1; i<=$k; i ++))
do
     type=(TR VR RT)
     for j in ${type[@]}
     do
	 FastTreeMP -nt group_$i/classify/classify_$j/$j.mafft >group_$i/classify/classify_$j/$j.mafft.tree
	 done
done

#split the training dataset to some groups, accoring to the clustering result
for ((i=1; i<=$k; i ++))
do
    for ((c=1; c<=4; c ++))
    do
        ./split.pl group_$i/train/RT.fa group_$i/classify/classify_RT/class$c.txt group_$i/classify/classify_RT/class$c.fa
    done
    
    type=(TR VR)
    for j in ${type[@]}
    do
        for ((c=1; c<=5; c ++))
 	do
 	    ./split.pl group_$i/train/$j.fa group_$i/classify/classify_$j/class$c.txt group_$i/classify/classify_$j/class$c.fa
 	done
    done
done

for ((i=1; i<=$k; i ++))
do
    nohup sh mafft.sh $i &
done

#motif-finding for RTs, based on mafft
#motif-search for TR and VR, based on GLAM2
for ((i=1; i<=$k; i ++))
do
    type=(TR VR)
    for j in ${type[@]}
    do
        for ((c=1; c<=5; c ++))
	do
	    ./glam2.pl group_$i/classify/classify_$j/class$c.fa group_$i/align/$j-class$c.align group_$i/motif/$j-class$c
	done
    done
done

###arguments simulation
###arguments simulation
###arguments simulation
###arguments simulation

fi

##generate config files according to the arguments simulation result
for ((i=1; i<=$k; i ++))
do
    cp DGR_summary.txt arg.config group_$i
    type=(TR VR)
    for j in ${type[@]}
    do
	score1=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class1.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $1}')
	ratio1=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class1.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $2}')
	len1=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class1.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $3}')

	score2=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class2.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $1}')
	ratio2=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class2.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $2}')
	len2=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class2.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $3}')

	score3=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class3.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $1}')
	ratio3=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class3.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $2}')
	len3=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class3.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $3}')

	score4=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class4.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $1}')
        ratio4=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class4.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $2}')
        len4=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class4.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $3}')
	
	score5=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class5.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $1}')
        ratio5=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class5.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $2}')
        len5=$(awk '{if($5<=0.001){print $0}}' group_$i/simulation/$j-class5.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $3}')

	./writeConfigTRVR.pl $j.config group_$i/$j.config $score1 $ratio1 $len1 $score2 $ratio2 $len2 $score3 $ratio3 $len3 $score4 $ratio4 $len4 $score5 $ratio5 $len5
    done
    
    j="RT"
    score1=$(awk '{if($5<=0.0001){print $0}}' group_$i/simulation/$j-class1.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $1}')
    ratio1=$(awk '{if($5<=0.0001){print $0}}' group_$i/simulation/$j-class1.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $2}')
    len1=$(awk '{if($5<=0.0001){print $0}}' group_$i/simulation/$j-class1.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $3}')
    
    score2=$(awk '{if($5<=0.0001){print $0}}' group_$i/simulation/$j-class2.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $1}')
    ratio2=$(awk '{if($5<=0.0001){print $0}}' group_$i/simulation/$j-class2.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $2}')
    len2=$(awk '{if($5<=0.0001){print $0}}' group_$i/simulation/$j-class2.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $3}')
    
    score3=$(awk '{if($5<=0.0001){print $0}}' group_$i/simulation/$j-class3.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $1}')
    ratio3=$(awk '{if($5<=0.0001){print $0}}' group_$i/simulation/$j-class3.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $2}')
    len3=$(awk '{if($5<=0.0001){print $0}}' group_$i/simulation/$j-class3.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $3}')

    score4=$(awk '{if($5<=0.0001){print $0}}' group_$i/simulation/$j-class4.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $1}')
    ratio4=$(awk '{if($5<=0.0001){print $0}}' group_$i/simulation/$j-class4.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $2}')
    len4=$(awk '{if($5<=0.0001){print $0}}' group_$i/simulation/$j-class4.sml |sort -rk4,4 -k5n,5 |head -1 |awk '{print $3}')
    ./writeConfigRT.pl $j.config group_$i/$j.config $score1 $ratio1 $len1 $score2 $ratio2 $len2 $score3 $ratio3 $len3 $score4 $ratio4 $len4

done

#calculate sensitivity and specificity,evaluation
for ((i=1; i<=$k; i ++))
do
    nohup sh evaluation.sh $i &
done

exit
