#!/bin/bash

#if [ 1 == 2 ]
#then
#fi

for i in `cat 53species.id`
do
    echo $i
    #nohup ./../axt2cov.pl cov/$i.cov /share/home/user/fzyan/hGT/data/data-wzhuang/vs$i/*.net.axt &
    #nohup cat cov/$i.cov |sort -k1,1 -k2n,2 >cov/$i-sort.cov &
done


