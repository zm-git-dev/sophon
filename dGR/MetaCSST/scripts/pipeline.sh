#!/usr/bin/bash
 
k=10
#k-fold cross validation

if [ 1 == 2 ] #annotation
then
#split the dataset to training and test, repeating k times, with different test datasets;
./splitData.pl dataSet/merged.gtf dataSet/merged.DGR.fa $k

#classification of training sequences(TR,VR,RT),based on mafft distance and K-means clustering
#calculating distance between sequences, based on MAFFT
for ((i=1; i<=$k; i ++))
do
    mafft-distance group_$i/train/TR.fa > group_$i/classify/classify_TR/TR.distance
    ./transDistance.pl group_$i/classify/classify_TR/TR.distance group_$i/classify/classify_TR/distance.matrix
    mafft-distance group_$i/train/VR.fa > group_$i/classify/classify_VR/VR.distance
    ./transDistance.pl group_$i/classify/classify_VR/VR.distance group_$i/classify/classify_VR/distance.matrix
    mafft-distance group_$i/train/RT.fa > group_$i/classify/classify_RT/RT.distance
    ./transDistance.pl group_$i/classify/classify_RT/RT.distance group_$i/classify/classify_RT/distance.matrix
done
 
#K-means clustering in R language
for ((i=1; i<=$k; i ++))
 do
    type=(TR VR RT)
    for j in ${type[@]}
     do
 	cp group_$i/classify/classify_$j/distance.matrix .
 	R CMD BATCH kmeans.R
 	mv class1.txt class2.txt class3.txt kmeans.Rout group_$i/classify/classify_$j/
     done
done
 
#split the training dataset to some groups, accoring to the clustering result
for ((i=1; i<=$k; i ++))
do
     type=(TR VR RT)
     for j in ${type[@]}
     do
         for ((c=1; c<=3; c ++))
 	 do
 	     ./split.pl group_$i/train/$j.fa group_$i/classify/classify_$j/class$c.txt group_$i/classify/classify_$j/class$c.fa
 	 done
     done
done

#motif-search for TR and VR, based on GLAM2
for ((i=1; i<=$k; i ++))
do
    type=(TR VR)
    for j in ${type[@]}
    do
        for ((c=1; c<=3; c ++))
	do
	    ./glam2.pl group_$i/classify/classify_$j/class$c.fa group_$i/align/$j-class$c.align group_$i/motif/$j-class$c
	done
    done
done
 
#motif-finding for RTs, based on muscle
for ((i=1; i<=$k; i ++))
do
    nohup sh muscle.sh $i &
done

###arguments simulation
#sh simulation.sh group_number RT_1 RT_2 RT_3 TR_1 TR_2 TR_3 VR_1 VR_2 VR_3
nohup sh simulation.sh group_10 549 314 19 343 206 354 202 352 349 &
nohup sh simulation.sh group_1 214 417 246 17 715 185 340 202 375 &
nohup sh simulation.sh group_2 253 229 395 366 183 370 527 108 284 &
nohup sh simulation.sh group_3 489 287 101 735 24 160 451 136 332 &
nohup sh simulation.sh group_4 23 525 329 81 644 194 199 435 285 &
nohup sh simulation.sh group_5 256 200 421 369 202 346 515 290 112 &
nohup sh simulation.sh group_6 301 559 17 656 20 241 362 423 132 &
nohup sh simulation.sh group_7 565 20 292 375 149 395 455 138 326 &
nohup sh simulation.sh group_8 254 149 474 348 365 207 715 181 24 &
nohup sh simulation.sh group_9 333 205 339 90 157 665 647 50 215 &

fi


##generate config files according to the arguments simulation result
for ((i=1; i<=$k; i ++))
do
    cp DGR_summary.txt arg.config group_$i
    type=(TR VR RT)
    for j in ${type[@]}
    do
	score1=$(awk '{if($5=="00"){print $0}}' group_$i/simulation/$j-class1.sml |sort -rnk 4 |head -1 |awk '{print $1}')
	ratio1=$(awk '{if($5=="00"){print $0}}' group_$i/simulation/$j-class1.sml |sort -rnk 4 |head -1 |awk '{print $2}')
	len1=$(awk '{if($5=="00"){print $0}}' group_$i/simulation/$j-class1.sml |sort -rnk 4 |head -1 |awk '{print $3}')

	score2=$(awk '{if($5=="00"){print $0}}' group_$i/simulation/$j-class2.sml |sort -rnk 4 |head -1 |awk '{print $1}')
	ratio2=$(awk '{if($5=="00"){print $0}}' group_$i/simulation/$j-class2.sml |sort -rnk 4 |head -1 |awk '{print $2}')
	len2=$(awk '{if($5=="00"){print $0}}' group_$i/simulation/$j-class2.sml |sort -rnk 4 |head -1 |awk '{print $3}')

	score3=$(awk '{if($5=="00"){print $0}}' group_$i/simulation/$j-class3.sml |sort -rnk 4 |head -1 |awk '{print $1}')
	ratio3=$(awk '{if($5=="00"){print $0}}' group_$i/simulation/$j-class3.sml |sort -rnk 4 |head -1 |awk '{print $2}')
	len3=$(awk '{if($5=="00"){print $0}}' group_$i/simulation/$j-class3.sml |sort -rnk 4 |head -1 |awk '{print $3}')

	./writeConfig.pl $j.config group_$i/$j.config $score1 $ratio1 $len1 $score2 $ratio2 $len2 $score3 $ratio3 $len3
	
    done
done

#calculate sensitivity and specificity
for ((i=1; i<=$k; i ++))
do
    cd ~/dGR/foldCV3/group_$i
    echo -e "Type\tTP_train\tTP_test\tFPR" >>evaluation.txt
    type=(TR VR)
    for j in ${type[@]}
    do
	./../metacsstSub -build $j.config -in train/$j.fa -out mm -thread 20
	train=$(grep ">" train/$j.fa |wc -l)
	right=$(grep ">" mm/out.txt |wc -l)
	TP_train=`echo "scale=4; $right / $train" | bc`
	
	./../metacsstSub -build $j.config -in test/$j.fa -out mm -thread 20
        test=$(grep ">" test/$j.fa |wc -l)
        right=$(grep ">" mm/out.txt |wc -l)
        TP_test=`echo "scale=4; $right / $test" | bc`
	
	./../metacsstSub -build $j.config -in ../random/200bp.fa -out mm -thread 20
	wrong=$(grep ">" mm/out.txt |wc -l)
	FPR=`echo "scale=4; $wrong / 10000" | bc`
	
	echo -e "$j\t$TP_train\t$TP_test\t$FPR" >>evaluation.txt
    done
    
    ./../metacsstSub -build RT.config -in train/RT.fa -out mm -thread 20
    train=$(grep ">" train/RT.fa |wc -l)
    right=$(grep ">" mm/out.txt |wc -l)
    TP_train=`echo "scale=4; $right / $train" | bc`
    
    ./../metacsstSub -build RT.config -in test/RT.fa -out mm -thread 20
    test=$(grep ">" test/RT.fa |wc -l)
    right=$(grep ">" mm/out.txt |wc -l)
    TP_test=`echo "scale=4; $right / $test" | bc`
    
    ./../metacsstSub -build RT.config -in ../random/2kbp.fa -out mm -thread 20
    wrong=$(grep ">" mm/out.txt |wc -l)
    FPR=`echo "scale=4; $wrong / 10000" | bc`
    
    echo -e "RT\t$TP_train\t$TP_test\t$FPR" >>evaluation.txt
	
    ./../metacsstMain -build arg.config -in train/DGR.fa -out mm -thread 20
    train=$(grep ">" train/DGR.fa |wc -l)
    right=$(grep "DGR" mm/out.gtf |wc -l)
    TP_train=`echo "scale=4; $right / $train" | bc`
    
    ./../metacsstMain -build arg.config -in test/DGR.fa -out mm -thread 20
    test=$(grep ">" test/DGR.fa |wc -l)
    right=$(grep "DGR" mm/out.gtf |wc -l)
    TP_test=`echo "scale=4; $right / $test" | bc`

    ./../metacsstMain -build arg.config -in ../random/5kbp.fa -out mm -thread 20
    wrong=$(grep "DGR" mm/out.gtf |wc -l)
    FPR=`echo "scale=4; $wrong / 10000" | bc`
    echo -e "DGR\t$TP_train\t$TP_test\t$FPR" >>evaluation.txt    
done

exit