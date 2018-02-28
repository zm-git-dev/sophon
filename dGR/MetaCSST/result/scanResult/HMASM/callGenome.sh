#!/usr/bin/bash

for i in *gtf
do
    pre=${i%.gtf}
    echo $pre
    ./../../callGenome.pl /share/data/HMP/HMASM_unzip/$pre.scaffolds.fa $i $i-partial.fa
done
exit
