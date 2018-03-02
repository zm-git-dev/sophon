#!/usr/bin/bash

i=$1
type=(TR VR)
for j in ${type[@]}
do
    for ((c=1; c<=5; c ++))
    do
	./glam2.pl group_$i/classify/classify_$j/class$c.fa group_$i/align/$j-class$c.align group_$i/motif/$j-class$c
    done
done