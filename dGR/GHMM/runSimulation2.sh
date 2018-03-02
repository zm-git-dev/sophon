#!/usr/bin/bash

#arguments simulation for RT

score=(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1)
#score=(0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1)
ratio=(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1)
len=(10 15 20 25 30 35 40)

align=$1
in=$2
num=$3
out=$4
tmp=$5
echo $out
echo -e  "Score\tRatio\tLen\tTP\tFP" >>$out
for s in ${score[@]}
do
    for r in ${ratio[@]}
    do
	for l in ${len[@]}
	do
	    a=$(./scanSub -build $align -score $s -ratio $r -len $l -in $in -tmp $tmp -gap 400 -thread 6 |grep ">" |wc -l)
	    b=$(./scanSub -build $align -score $s -ratio $r -len $l -in random/2kbp.fa -tmp $tmp -gap 400 -thread 8 |grep ">" |wc -l)
	    tp=`echo "scale=4; $a / $num" | bc`
	    fp=`echo "scale=4; $b / 10000" | bc`
	    echo -e  "$s\t$r\t$l\t0$tp\t0$fp" >>$out
	done
    done
done

exit