#!/usr/bin/bash

echo start

for i in *.fa.gz
do
    pre=${i%.fa.gz}
    bwa mem ref.fa $i 1>$pre-ref.sam 2>$pre-ref.log
    samtools view -bS $pre-ref.sam -o $pre-ref.bam
    rm $pre-ref.sam $pre-ref.log

###Or:bwa -> sort -> index
#    bwa mem ref.fa $i |samtools view -uSh - |samtools sort - $pre-ref
#    samtools index $pre-ref.bam &
done

echo done