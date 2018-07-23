#!/bin/bash

len=(1000 1500 2000 2500)
step=(200 500 800 1000)
kmer=(1 2 3 4 5 6)

for i in ${len[@]}
do
    for j in ${step[@]}
    do
	#nohup ~/hGT/src/segment.pl ../chr22.fa $i $j chr22-seg$i-step$j.fa &
	for k in ${kmer[@]}
	do
	    #nohup ~/hGT/src/kmer.pl chr22-seg$i-step$j.fa $k >chr22-seg$i-step$j-$k"mer".txt &
	    #nohup ~/hGT/src/compareKmer.pl ~/hGT/human-hg19/kmer/hg19-$k"mer".txt chr22-seg$i-step$j-$k"mer".txt chr22-seg$i-step$j-$k"mer"-distance.txt &
	    #num=$(grep -v region chr22-seg$i-step$j-$k"mer"-distance.txt |wc -l)
	    #top=`expr $num / 100`
	    #grep -v region chr22-seg$i-step$j-$k"mer"-distance.txt |sort -rnk 2 |head -$top |awk '{print $1}' >chr22-seg$i-step$j-$k"mer"-distance-pass.info
	    #awk -F '-' '{print $1"\t"$2"\t"$3}' chr22-seg$i-step$j-$k"mer"-distance-pass.info |sort -k1,1 -k2n,2 >chr22-seg$i-step$j-$k"mer"-distance-pass.bed
	    #overlap=$(./biodiff-500bp.pl chr22-seg$i-step$j-$k"mer"-distance-pass.bed ../screenHGT-chr22.bed |awk '{if($5>=500) print $1$2$3}' |sort |uniq |wc -l)
	    #echo -e "$i\t$j\t$k\t$overlap"
	    ~/hGT/src/getHGTseq.pl ../chr22.fa chr22-seg$i-step$j-$k"mer"-distance-pass.bed chr22-seg$i-step$j-$k"mer"-distance-pass.fa 
	done
    done
done

