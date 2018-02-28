#!/usr/bin/bash

echo -e "id\treads\tlen\tcov"

arr=(ERP019800 HMP SRA045646 SRA050230 SRP115494)
for i in ${arr[@]}
do
    for j in $i/bowtie2/*bam
    do
	num=$(samtools view $j |wc -l)
	
	suf=${j#$i/bowtie2/}
	pre=${suf%.bam}
	len=$(length $i/dgrFa/$pre.dgr.fa |grep -v "Max" |awk '{print $2}')
	
	cov=`echo "scale=2; $num * 100 / $len" | bc`
	echo -e "$pre\t$num\t$len\t$cov"
    done
done
exit
