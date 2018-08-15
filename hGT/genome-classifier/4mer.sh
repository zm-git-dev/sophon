#!/bin/bash


arr=(fungi invertebrate plant protozoa vertebrate_mammalian vertebrate_other)

for type in ${arr[@]}
do
    #for genome in /share/data/refseq/$type/GCF/*.fna.gz
    #do
#	~/hGT/src/kmerGenome.pl $genome 4 >>$type.txt
 #   done
    awk '{print $0"\t'$type'"}' $type.txt >>4mer.txt
done

