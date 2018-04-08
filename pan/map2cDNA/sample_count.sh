#!/bin/bash

for ((i=2; i<=39; i ++))
do
    gene=$(awk '{print $'$i'}' summaryCov2.txt |head -1)
    cat summaryCov2.txt |grep -v Sample |awk '{sum+=$'$i'} END {print "'$gene': "sum}'
done
exit
