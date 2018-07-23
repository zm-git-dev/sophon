#!/bin/bash

#arr=(iden60len40 iden40len20 gb2015-136gene)

arr=(gb2015-136gene)

for target in ${arr[@]}
do
    #./../region-non-mammal.pl ../$target.fa nonmammal-$target/*-500bp.out >nonmammal-$target/region-nonmammal.out
    for i in mammal-$target/GC*-cov.txt
    do
	id=${i%.txt}
	nohup ./../merge-mammal-cov.pl $i $id-merged.txt &
    done
done
