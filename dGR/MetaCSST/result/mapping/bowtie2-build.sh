#!/usr/bin/bash

arr=(SRP115494)
#arr=(ERP019800 SRA045646 SRA050230)

for i in ${arr[@]}
do
    for fa in $i/dgrFa/*fa
    do
	 bowtie2-build $fa $fa
    done
done
exit
