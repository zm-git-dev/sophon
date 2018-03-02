#!/bin/bash

#SBATCH -J sam2bam
#SBATCH --partition=centos7cpu
#SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err
echo start

arr=(WGC013094R WGC013096R WGC013098R WGC013100R WGC013102R WGC013104R WGC013106R WGC013108R WGC013110R WGC013112R WGC013114R WGC013116R WGC013118R WGC013122R WGC013124R WGC013126R WGC013128R WGC013130R WGC013132R)

for i in ${arr[@]}
do
echo "$i..." >>bamCount.txt
samtools view -bS $i/$i.sam -o $i/$i.bam
perl bamCount.pl $i/$i.bam >>bamCount.txt
done

echo  end
exit
