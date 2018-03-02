#!/bin/bash

#SBATCH -J cuffdiff
#SBATCH --partition=cpu
#SBATCH --mail-type=ALL
#SBATCH -n 16
#SBATCH --exclusive
#SBATCH --output=%J.out
#SBATCH --error=%J.err

echo start
id=$1
mkdir cuffdiff_WGC017518R_add/$id
~/fzyan/softwares/cufflinks-2.2.1.Linux_x86_64/cuffdiff -o cuffdiff_WGC017518R_add/$id -p 16 cuffmerge_noRef/merged.gtf ../tophat2/WGC017518R/accepted_hits.bam ../tophat2/$id/accepted_hits.bam

echo  end

exit
