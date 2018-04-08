#!/usr/bin/bash

file=$1
arr=(1 2 3 4 5 6 7 8 9 10 20 30 40 50)
for i in ${arr[@]}
do
    num=$(awk '{if($2>='$i'){print $0}}' $file |wc -l)
    echo -e "$i\t$num"
done
exit

