#!/usr/bin/bash

arr=(HMASM_DGRscan)
for id in ${arr[@]}
do

    date=`date +%Y-%m-%d`
    time=`date +%H:%M:%S`
    echo "$id start at $date $time" >>run.log
    
    ./metacsstMain_pthread.pl arg.config ~/dGR/data/$id.fa tmpScan $id.gtf 32
    rm -rf tmpScan
    ./callGenome.pl ~/dGR/data/$id.fa $id.gtf $id-partial.fa

    date=`date +%Y-%m-%d`
    time=`date +%H:%M:%S`
    echo "$id calling VRs at $date $time" >>run.log
    
    ./reBuildDGR_pthread.pl $id.gtf $id-partial.fa $id-rebuild.gtf $id-rebuild.summary 0.5 3 30 32 >$id-rebuild.log
    
    date=`date +%Y-%m-%d`
    time=`date +%H:%M:%S`
    echo "$id end at $date $time" >>run.log
    
done