#!/usr/bin/bash
 
i=$1
echo $i
cd ~/dGR/byHand2/group_$i
echo -e "Type\tTP_train\tTP_test\tFPR" >>evaluation.txt

if [ 1 == 2 ]
then

type=(TR VR)
for j in ${type[@]}
do
    ./../metacsstSub -build $j.config -in train/$j.fa -out mm -thread 4
    train=$(grep ">" train/$j.fa |wc -l)
    right=$(grep ">" mm/out.txt |wc -l)
    TP_train=`echo "scale=4; $right / $train" | bc`
    
    ./../metacsstSub -build $j.config -in test/$j.fa -out mm -thread 4
        test=$(grep ">" test/$j.fa |wc -l)
        right=$(grep ">" mm/out.txt |wc -l)
        TP_test=`echo "scale=4; $right / $test" | bc`
	
	./../metacsstSub -build $j.config -in ../random/200bp.fa -out mm -thread 4
	wrong=$(grep ">" mm/out.txt |wc -l)
	FPR=`echo "scale=4; $wrong / 10000" | bc`
	
	echo -e "$j\t$TP_train\t$TP_test\t$FPR" >>evaluation.txt
done

./../metacsstSub -build RT.config -in train/RT.fa -out mm -thread 4
train=$(grep ">" train/RT.fa |wc -l)
right=$(grep ">" mm/out.txt |wc -l)
TP_train=`echo "scale=4; $right / $train" | bc`

./../metacsstSub -build RT.config -in test/RT.fa -out mm -thread 4
test=$(grep ">" test/RT.fa |wc -l)
right=$(grep ">" mm/out.txt |wc -l)
TP_test=`echo "scale=4; $right / $test" | bc`

./../metacsstSub -build RT.config -in ../random/2kbp.fa -out mm -thread 4
wrong=$(grep ">" mm/out.txt |wc -l)
FPR=`echo "scale=4; $wrong / 10000" | bc`

echo -e "RT\t$TP_train\t$TP_test\t$FPR" >>evaluation.txt

fi

./../metacsstMain -build arg.config -in train/DGR.fa -out mm -thread 4
train=$(grep ">" train/DGR.fa |wc -l)
right=$(grep "DGR" mm/out.gtf |wc -l)
TP_train_partial=`echo "scale=4; $right / $train" | bc`

./../reBuildDGR_pthread.pl mm/out.gtf train/DGR.fa 1.txt 2.txt 0.5 3 30 4
right=$(grep "DGR" 1.txt |wc -l)
TP_train_intact=`echo "scale=4; $right / $train" | bc`

rm -rf mm 1.txt 2.txt

./../metacsstMain -build arg.config -in test/DGR.fa -out mm -thread 4
test=$(grep ">" test/DGR.fa |wc -l)
right=$(grep "DGR" mm/out.gtf |wc -l)
TP_test_partial=`echo "scale=4; $right / $test" | bc`

./../reBuildDGR_pthread.pl mm/out.gtf test/DGR.fa 1.txt 2.txt 0.5 3 30 4
right=$(grep "DGR" 1.txt |wc -l)
TP_test_intact=`echo "scale=4; $right / $test" | bc`

rm -rf mm 1.txt 2.txt

./../metacsstMain -build arg.config -in ../random/5kbp.fa -out mm -thread 4
wrong=$(grep "DGR" mm/out.gtf |wc -l)
FPR_partial=`echo "scale=4; $wrong / 10000" | bc`

./../reBuildDGR_pthread.pl mm/out.gtf ../random/5kbp.fa 1.txt 2.txt 0.5 3 30 4
wrong=$(grep "DGR" 1.txt |wc -l)
FPR_intact=`echo "scale=4; $wrong / 10000" | bc`

rm -rf mm 1.txt 2.txt 
echo -e "DGR\t$TP_train_partial\t$TP_train_intact\t$TP_test_partial\t$TP_test_intact\t$FPR_partial\t$FPR_intact" >>evaluation.txt

exit
