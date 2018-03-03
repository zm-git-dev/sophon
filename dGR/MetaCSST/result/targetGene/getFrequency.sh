#!/usr/bin/bash

term=$1
target=$2
background=$3
for TERM in `cat $term`
#for TERM in `cat targetGene-GO.blastp-uniprot.GOterm.txt`
do
    a=$(grep $TERM $target |awk '{print $1}' |sort |uniq |wc -l)
    b=$(grep $TERM $background |awk '{print $1}' |sort |uniq |wc -l)
    echo -e "$TERM\t$a\t$b"
done
exit
