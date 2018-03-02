#!/usr/bin/bash
 
k=10
#k-fold cross validation

if [ 1 == 2 ]
then

#split the dataset to training and test, repeating k times, with different test datasets;
./splitData.pl dataSet/merged.gtf dataSet/merged.DGR.fa $k

for ((i=1; i<=$k; i ++))
do
    type=(TR VR)
    for j in ${type[@]}
    do
    muscle3.8.31_i86linux64 -in group_$i/train/$j.fa -out group_$i/classify/classify_$j/$j.muscle
    nohup muscle -in group_$i/train/RT.fa -out group_$i/classify/classify_RT/RT.muscle &
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
nohup sh simulation.sh group_10 410 213 280 249 394 260 218 396 268  &
nohup sh simulation.sh group_1 326 282 309 224 380 313 377 286 214  &
nohup sh simulation.sh group_2 297 299 323 365 336 218 379 250 248  &
nohup sh simulation.sh group_3 360 275 284 260 341 318 384 227 266  &
nohup sh simulation.sh group_4 244 494 181 344 362 213 360 238 279  &
nohup sh simulation.sh group_5 375 305 237 327 311 279 268 211 398  &
nohup sh simulation.sh group_6 374 354 189 349 341 227 174 372 331  &
nohup sh simulation.sh group_7 312 331 276 333 389 197 395 279 203  &
nohup sh simulation.sh group_8 261 262 397 290 301 329 223 318 336  &
nohup sh simulation.sh group_9 361 202 349 319 420 173 292 212 373  &


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
    cd ~/dGR/byHand/group_$i
    echo -e "Type\tTP_train\tTP_test\tFPR" >>evaluation.txt
    type=(TR VR)
    for j in ${type[@]}
    do
	./../metacsstSub -build $j.config -in train/$j.fa -out mm -thread 30
	train=$(grep ">" train/$j.fa |wc -l)
	right=$(grep ">" mm/out.txt |wc -l)
	TP_train=`echo "scale=4; $right / $train" | bc`
	
	./../metacsstSub -build $j.config -in test/$j.fa -out mm -thread 30
        test=$(grep ">" test/$j.fa |wc -l)
        right=$(grep ">" mm/out.txt |wc -l)
        TP_test=`echo "scale=4; $right / $test" | bc`
	
	./../metacsstSub -build $j.config -in ../random/300bp.fa -out mm -thread 30
	wrong=$(grep ">" mm/out.txt |wc -l)
	FPR=`echo "scale=4; $wrong / 10000" | bc`
	
	echo -e "$j\t$TP_train\t$TP_test\t$FPR" >>evaluation.txt
    done
    
    ./../metacsstSub -build RT.config -in train/RT.fa -out mm -thread 30
    train=$(grep ">" train/RT.fa |wc -l)
    right=$(grep ">" mm/out.txt |wc -l)
    TP_train=`echo "scale=4; $right / $train" | bc`
    
    ./../metacsstSub -build RT.config -in test/RT.fa -out mm -thread 30
    test=$(grep ">" test/RT.fa |wc -l)
    right=$(grep ">" mm/out.txt |wc -l)
    TP_test=`echo "scale=4; $right / $test" | bc`
    
    ./../metacsstSub -build RT.config -in ../random/2kbp.fa -out mm -thread 30
    wrong=$(grep ">" mm/out.txt |wc -l)
    FPR=`echo "scale=4; $wrong / 10000" | bc`
    
    echo -e "RT\t$TP_train\t$TP_test\t$FPR" >>evaluation.txt
	
    ./../metacsstMain -build arg.config -in train/DGR.fa -out mm -thread 30
    train=$(grep ">" train/DGR.fa |wc -l)
    right=$(grep "DGR" mm/out.gtf |wc -l)
    TP_train=`echo "scale=4; $right / $train" | bc`
    
    ./../metacsstMain -build arg.config -in test/DGR.fa -out mm -thread 30
    test=$(grep ">" test/DGR.fa |wc -l)
    right=$(grep "DGR" mm/out.gtf |wc -l)
    TP_test=`echo "scale=4; $right / $test" | bc`

    ./../metacsstMain -build arg.config -in ../random/5kbp.fa -out mm -thread 30
    wrong=$(grep "DGR" mm/out.gtf |wc -l)
    FPR=`echo "scale=4; $wrong / 10000" | bc`
    echo -e "DGR\t$TP_train\t$TP_test\t$FPR" >>evaluation.txt    
done

exit
