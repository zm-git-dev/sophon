#!/bin/bash

for i in /share/home/user/fzyan/hGT/data/53genome/*.fna
do
    genome=${i#/share/home/user/fzyan/hGT/data/53genome/}
    nohup makeblastdb -in $i -dbtype nucl -out db/$genome &
done
exit
