#!/bin/bash

#SBATCH -J trim
#SBATCH --partition=fat
 #SBATCH --mail-type=ALL
#SBATCH -n 1
#SBATCH --output=%J.out
#SBATCH --error=%J.err

echo "start"
id=$1
java -jar ~/fzyan/softwares/trimmomatic-0.32.jar PE ../data/s083r04004_fastq/Sample_$id/"$id"_combined_filtered_R1.fastq.gz ../data/s083r04004_fastq/Sample_$id/"$id"_combined_filtered_R2.fastq.gz $id/"$id"_R1_trimmed.fq.gz unpaired/"$id"_R1_unpaired.fq.gz $id/"$id"_R2_trimmed.fq.gz unpaired/"$id"_R2_unpaired.fq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 HEADCROP:13 SLIDINGWINDOW:4:15 MINLEN:36

echo "end"

exit
