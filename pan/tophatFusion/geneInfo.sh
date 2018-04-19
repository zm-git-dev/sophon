#!/bin/bash

for i in `cat 33gene.txt`
do
    num=$(grep "\"$i\"" gencode-gene.info |awk '{print $14"\t"$10"\t"$1"\t"$4"\t"$5"\t"$7}' |tr -d "\";" |wc -l)
    echo -e "$i\t$num"
done
exit
