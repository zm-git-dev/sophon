#!/bin/bash

sh pos.sh |awk '{print $1"\t"$2"|"$5}' |sort |uniq >tmp.txt

for fusion in `cat 17fusion.out |awk '{print $1}'`
do
    sample=$(grep $fusion tmp.txt |awk '{print $1}' |sort |uniq |tr '\n' ',')
    echo -e "$fusion\t$sample"
done

rm tmp.txt