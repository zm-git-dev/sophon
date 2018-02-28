#!/usr/bin/bash

in=$1

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "MetaCSST start at $date $time" >>$in.log

./metacsstMain -build arg.config -in $in -out $in-MetaCSST -thread 1
#./reBuildDGR.pl $in-MetaCSST/out.gtf $i $i-rebuild.gtf $i-rebuild.summary 0.5 3 30 >$i-rebuild.log

date=`date +%Y-%m-%d`
time=`date +%H:%M:%S`
echo "MetaCSST end at $date $time"  >>$in.log
