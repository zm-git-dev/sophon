#!/bin/bash

#SBATCH -J sam2bam
#SBATCH --partition=centos7cpu
#SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err
echo start

arr=(WGC013178R WGC013180R WGC013182R WGC013184R WGC013186R WGC013188R WGC013190R WGC013192R WGC013194R WGC013197R WGC013198R WGC013199R WGC013200R WGC013202R WGC013203R WGC013204R WGC013205R WGC013206R WGC017518R WGC017519R)

for i in ${arr[@]}
do
echo "$i..." >>bamCount_3.txt
samtools view -bS $i/$i.sam -o $i/$i.bam
perl bamCount.pl $i/$i.bam >>bamCount_3.txt
done

echo  end
exit
