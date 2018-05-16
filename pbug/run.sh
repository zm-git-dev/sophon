#!/bin/bash

if [ 1 == 2 ]  ###code annotation start
then

head -1 agg.csv |awk -F ',' '{print $2","$6","$7","$8","$9","$10","$11","$13","$15}' >agg-1.csv
awk -F ',' '{if($5==1){print $2","$6","$7","$8","$9","$10","$11","$13","$15}}' agg.csv >>agg-1.csv

./sample.pl agg-1.csv 14039650 10000 sample/agg-1w.csv
./sample.pl agg-1.csv 14039650 50000 sample/agg-5w.csv
./sample.pl agg-1.csv 14039650 100000 sample/agg-10w.csv
./sample.pl agg-1.csv 14039650 500000 sample/agg-50w.csv
./sample.pl agg-1.csv 14039650 1000000 sample/agg-100w.csv

fi   ###code annotation end

