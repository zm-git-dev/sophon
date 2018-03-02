#!/usr/bin/bash


mkdir tmp_call
for i in HMASM-GHMM/SRS0*.gtf
do
suf=${i#HMASM-GHMM/}
pre=${suf%.gtf}
./callGenome.pl ../data/HMASM_fa/$pre.scaffolds.fa $i tmp_call/$pre-GHMM.fa
done

cat tmp_call/*.fa >HMASM-GHMM.fa
rm -rf tmp_call
exit