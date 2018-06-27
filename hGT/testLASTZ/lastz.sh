#!/bin/bash

id=$1

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "start at $date $time" >>log/$id.txt

lastz 350seg.fa[multiple] ~/hGT/data/53genome/$id.fna --format=axt+ --output=axt/350seg-$id.axt

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "350seg complete at $date $time" >>log/$id.txt

lastz chr22.fa ~/hGT/data/53genome/$id.fna --format=axt+ --output=axt/chr22-$id.axt

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "end at $date $time"  >>log/$id.txt

