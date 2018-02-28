#!/usr/bin/bash

mkdir tmp_call
for i in result/bacteria/rebuild/*.gtf
do
suf=${i#result/bacteria/rebuild/bacteria_}
pre=${suf%-rebuild.gtf}
echo $pre
./callGenome.pl ~/dGR/data/bacteria/bacteria_$pre $i tmp_call/$pre.fa
done

exit