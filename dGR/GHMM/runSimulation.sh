#!/usr/bin/bash

score=(0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1)
ratio=(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1)
len=(3 4 5 6 7 8)

align=$1
in=$2
num=$3
out=$4
tmp=$5
echo -e  "Score\tRatio\tLen\tTP\tFP" >>$out
for s in ${score[@]}
do
    for r in ${ratio[@]}
    do
	for l in ${len[@]}
	do
	    a=$(./scanSub -build $align -score $s -ratio $r -len $l -in $in -tmp $tmp -gap 40 |grep ">" |wc -l)
	    b=$(./scanSub -build $align -score $s -ratio $r -len $l -in random/200bp.fa -tmp $tmp -thread 8 |grep ">" |wc -l)
	    tp=`echo "scale=4; $a / $num" | bc`
	    fp=`echo "scale=4; $b / 10000" | bc`
	    echo -e  "$s\t$r\t$l\t0$tp\t0$fp" >>$out
	done
    done
done

exit