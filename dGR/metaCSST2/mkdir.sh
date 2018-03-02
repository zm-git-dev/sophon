#!/usr/bin/bash

num=$1
for ((i=1; i<=$num; i ++))  
do 
    mkdir group_$i/align
    mkdir group_$i/classify
    mkdir group_$i/classify/classify_RT
    mkdir group_$i/classify/classify_TR
    mkdir group_$i/classify/classify_VR
    mkdir group_$i/motif
    mkdir group_$i/simulation
done
exit