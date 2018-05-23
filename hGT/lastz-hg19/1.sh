#!/bin/bash

for id in `cat 41mammal.id`
do
    nohup ./../src/screenHGT.pl iden60/nonmammal/merge-cov2-1kbp.bed tmp-$id 0.4 iden60/mammal/$id-merged.txt >qq-$id &
done
