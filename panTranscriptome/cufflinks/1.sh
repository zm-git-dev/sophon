#!/usr/bin/bash
for i in exp_analysis/*.diff
do
nohup ./fold_change.pl $i &
done
exit