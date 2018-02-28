#!/usr/bin/bash

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "start at $date $time"

./metacsstMain -build arg.config -in ~/dGR/data/SRA045646.fa -out SRA045646 -thread 32

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "end at $date $time"
