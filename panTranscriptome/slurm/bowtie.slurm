#!/bin/bash

#SBATCH -J bowtie2
#SBATCH --partition=cpu
#SBATCH --mail-type=ALL
#SBATCH -n 16
#SBATCH --exclusive
#SBATCH --output=%J.out
#SBATCH --error=%J.err


i=$1

~/fzyan/softwares/bowtie2-2.2.4/bowtie2 -p 16 -x GRCh38.p10 -1 ~/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R1_trimmed.fq.gz -2 /lustre/home/acct-clswcc/clswcc/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R2_trimmed.fq.gz -S $i-genome.sam

#~/fzyan/softwares/bowtie2-2.2.4/bowtie2 -p 16 -x gencode.v26.transcripts -1 ~/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R1_trimmed.fq.gz -2 /lustre/home/acct-clswcc/clswcc/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R2_trimmed.fq.gz -S $i-trans.sam

#~/fzyan/softwares/bowtie2-2.2.4/bowtie2 -p 16 -x gencode.v26.lncRNA_transcripts -1 ~/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R1_trimmed.fq.gz -2 /lustre/home/acct-clswcc/clswcc/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R2_trimmed.fq.gz -S $i-lncRNA.sam

#~/fzyan/softwares/bowtie2-2.2.4/bowtie2 -p 16 -x gencode.v26.pc_transcripts -1 ~/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R1_trimmed.fq.gz -2 /lustre/home/acct-clswcc/clswcc/fzyan/pan-transcriptome_cancer/trimmomatic/$i/"$i"_R2_trimmed.fq.gz -S $i-pc.sam


samtools view -bS $i-genome.sam -o $i-genome.bam
#samtools view -bS $i-trans.sam -o $i-trans.bam
#samtools view -bS $i-lncRNA.sam -o $i-lncRNA.bam
#samtools view -bS $i-pc.sam -o $i-pc.bam

exit