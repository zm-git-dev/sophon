#!/bin/bash


sum:   cat $file |awk '{sum+=$1} END {print sum}'
avg:   cat $file |awk '{sum+=$1} END {print sum/NR}'
max:   cat data|awk 'BEGIN {max=-100000000} {if($1>max) max=$1 fi} END {print max}'
min:   cat data|awk 'BEGIN {min=1000000000} {if($1<min) min=$1 fi} END {print min}'
