#!/bin/bash

#SBATCH -J trimming
#SBATCH --partition=fat
 #SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err
echo start

java -jar ~/fzyan/softwares/trimmomatic-0.32.jar PE ../data/s083r04004_fastq/Sample_WGC017519R/WGC017519R_combined_filtered_R1.fastq.gz ../data/s083r04004_fastq/Sample_WGC017519R/WGC017519R_combined_filtered_R2.fastq.gz WGC017519R_R1_trimmed.fq.gz WGC017519R_R1_unpaired.fq.gz WGC017519R_R2_trimmed.fq.gz WGC017519R_R2_unpaired.fq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 HEADCROP:13 SLIDINGWINDOW:4:15 MINLEN:36

echo  end

exit
