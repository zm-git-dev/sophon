#!/bin/bash

#SBATCH -J identity
#SBATCH -p cpu128
#SBATCH -n 1
#SBATCH --output=log/%J.out
#SBATCH --error=log/%J.err

export PATH=$PATH:/usr/bin:/bin

id=$1

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "identity: $id start at $date $time"

arr=(40 50 60 70 80 90)
for threshold in ${arr[@]}
do
    awk '{if($9*100>='$threshold') print $1"\t"$2"\t"$3}' cov/$id.cov |sort -k1,1 -k2n,2 >iden$threshold/$id.tmp
    num=$(cat iden$threshold/$id.tmp |wc -l)
    if [ $num != 0 ]
    then
	~/fzyan/hGT/src/mergeBed.pl iden$threshold/$id.tmp iden$threshold/$id.bed
	rm iden$threshold/$id.tmp
    else
	mv iden$threshold/$id.tmp iden$threshold/$id.bed
    fi
done

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "identity: $id complete at $date $time"

exit
