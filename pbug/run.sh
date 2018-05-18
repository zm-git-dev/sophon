#!/bin/bash

if [ 1 == 2 ]  ###code annotation start
then

head -1 agg.csv |awk -F ',' '{print $2","$6","$8","$9","$10","$11","$13","$15}' >agg-1.csv
awk -F ',' '{if($5==1){print $2","$6","$8","$9","$10","$11","$13","$15}}' agg.csv >>agg-1.csv

./sample.pl agg-1.csv 14039650 10000 sample/agg-1w.csv
./sample.pl agg-1.csv 14039650 50000 sample/agg-5w.csv
./sample.pl agg-1.csv 14039650 100000 sample/agg-10w.csv
./sample.pl agg-1.csv 14039650 500000 sample/agg-50w.csv
./sample.pl agg-1.csv 14039650 1000000 sample/agg-100w.csv


awk -F ',' '{if($9==1) print $4","$5",Chicken-Dinner"; else print $4","$5",Dailure"}' plotData/agg-1w.csv >plotData/drive-scatter.csv

awk -F ',' '{if($4>0) print $9",Yes"; else print $9",No"}' plotData/agg-1w.csv >plotData/drive2.csv

awk -F ',' '{if($4==0) print $9",0";}' plotData/agg-1w.csv >>plotData/drive3.csv
awk -F ',' '{if($4>0 && $4<=1000) print $9",(0-1k]";}' plotData/agg-1w.csv >>plotData/drive3.csv
awk -F ',' '{if($4>1000 && $4<=2000) print $9",(1k-2k]";}' plotData/agg-1w.csv >>plotData/drive3.csv
awk -F ',' '{if($4>2000 && $4<=3000) print $9",(2k-3k]";}' plotData/agg-1w.csv >>plotData/drive3.csv
awk -F ',' '{if($4>3000 && $4<=4000) print $9",(3k-4k]";}' plotData/agg-1w.csv >>plotData/drive3.csv
awk -F ',' '{if($4>4000 && $4<=5000) print $9",(4k-5k]";}' plotData/agg-1w.csv >>plotData/drive3.csv
awk -F ',' '{if($4>5000 && $4<=6000) print $9",(5k-6k]";}' plotData/agg-1w.csv >>plotData/drive3.csv
awk -F ',' '{if($4>6000 && $4<=7000) print $9",(6k-7k]";}' plotData/agg-1w.csv >>plotData/drive3.csv
awk -F ',' '{if($4>7000 && $4<=8000) print $9",(7k-8k]";}' plotData/agg-1w.csv >>plotData/drive3.csv
awk -F ',' '{if($4>8000 && $4<=9000) print $9",(8k-9k]";}' plotData/agg-1w.csv >>plotData/drive3.csv
awk -F ',' '{if($4>9000 && $4<=10000) print $9",(9k-10k]";}' plotData/agg-1w.csv >>plotData/drive3.csv
awk -F ',' '{if($4>10000) print $9",(10k-+00)";}' plotData/agg-1w.csv >>plotData/drive3.csv

fi   ###code annotation end

arr=(1w 5w 10w 50w 100w)
for i in ${arr[@]}
do
    awk -F ',' '{if($8==1) print $1","$2","$3","$4","$5","$6","$7","$8; else print $1","$2","$3","$4","$5","$6","$7",0"}' sample/agg-$i.csv >sample-binary/agg-$i.csv
done


awk -F  ','  '{if($1=="S12K" || $1=="S686" || $1=="Kar98K" || $1=="Mini 14" || $1=="S1897" || $1=="UMP9" || $1=="AKM" || $1=="SCAR-L" || $1=="M16A4" || $1=="M416") print $0}' kill.csv |head -50000 


