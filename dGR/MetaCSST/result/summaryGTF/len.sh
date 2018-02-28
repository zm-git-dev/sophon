#!/usr/bin/bash


len_10k=$(grep -v DGR_ID summaryDGR.txt |awk '{if($2<=10000){print $0}}'  |wc -l)
len_100k=$(grep -v DGR_ID summaryDGR.txt |awk '{if($2>10000 && $2<=100000){print $0}}'  |wc -l)
len_1M=$(grep -v DGR_ID summaryDGR.txt |awk '{if($2>100000 && $2<=1000000){print $0}}'  |wc -l)
len_1Mplus=$(grep -v DGR_ID summaryDGR.txt |awk '{if($2>1000000){print $0}}'  |wc -l)

echo -e "(0,10kb]\t$len_10k"
echo -e "(10kb,100KB]\t$len_100k"
echo -e "(100kb,1M]\t$len_1M"
echo -e "(1M,+oo)\t$len_1Mplus"
