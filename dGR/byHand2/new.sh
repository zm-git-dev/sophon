#!/usr/bin/bash

if [ 1 == 2 ]
then

type=(TR VR)
for j in ${type[@]}
do
    for ((c=1; c<=6; c ++))
    do
        ./split.pl newGroup/train/$j.fa newGroup/classify/classify_$j/class$c.txt newGroup/classify/classify_$j/class$c.fa
    done
done

fi

type=(TR VR)
for j in ${type[@]}
do
    for ((c=1; c<=6; c ++))
    do
        ./glam2.pl newGroup/classify/classify_$j/class$c.fa newGroup/align/$j-class$c.align newGroup/motif/$j-class$c
    done
done
