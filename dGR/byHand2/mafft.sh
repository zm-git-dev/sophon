#!/usr/bin/bash

i=$1
for ((c=1; c<=4; c ++))
do
    mafft --thread 2 --quiet group_$i/classify/classify_RT/class$c.fa > tmp-$i-$c.txt
    chomp tmp-$i-$c.txt
    grep -v ">" tmp-$i-$c.txt |tr 'a-z' 'A-Z' >group_$i/align/RT-class$c.align
    rm tmp-$i-$c.txt
done