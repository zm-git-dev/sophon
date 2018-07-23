#!/bin/bash

id=$1

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "start at $date $time" >>log/$id.txt

blastn -query 350seg.fa -task blastn -db ~/hGT/db/$id.fna -out alignment/350seg-$id.blastn -outfmt 7 -evalue 1e-3

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "350seg complete at $date $time" >>log/$id.txt

blastn -query chr22.fa -task blastn -db ~/hGT/db/$id.fna -out alignment/chr22-$id.blastn -outfmt 7 -evalue 1e-3

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "end at $date $time"  >>log/$id.txt
