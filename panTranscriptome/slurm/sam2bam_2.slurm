#!/bin/bash

#SBATCH -J sam2bam
#SBATCH --partition=centos7cpu
#SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err
echo start

arr=(WGC013134R WGC013136R WGC013138R WGC013140R WGC013142R WGC013144R WGC013146R WGC013148R WGC013150R WGC013152R WGC013154R WGC013156R WGC013158R WGC013160R WGC013162R WGC013164R WGC013166R WGC013168R WGC013170R WGC013172R WGC013174R WGC013176R)
for i in ${arr[@]}
do
echo "$i..." >>bamCount_2.txt
samtools view -bS $i/$i.sam -o $i/$i.bam
perl bamCount.pl $i/$i.bam >>bamCount_2.txt
done

echo  end
exit
