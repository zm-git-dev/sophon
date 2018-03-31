#!/bin/bash

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "start at $date $time" >>test.log

gzip -dc data/53genome/GCA_000004035.1_Meug_1.1_genomic.fna.gz |blastn -query - -db db/hg19-seg1k-step1k-4mer-pass.fa -out mm -evalue 1e-5

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "end at $date $time"  >>test.log


