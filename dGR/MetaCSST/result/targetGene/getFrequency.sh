#!/usr/bin/bash

for TERM in `cat targetGene-GO.blastp-uniprot.GOterm.txt`
do
    a=$(grep $TERM targetGene-GO.blastp-uniprot-common.txt |awk '{print $1}' |sort |uniq |wc -l)
    b=$(grep $TERM background-GO.blastp-uniprot.txt |awk '{print $1}' |sort |uniq |wc -l)
    echo -e "$TERM\t$a\t$b"
done
exit
