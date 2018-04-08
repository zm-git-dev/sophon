#!/usr/bin/bash

for i in bam/*-hit.sam
do
    suf=${i#bam/}
    id=${suf%-hit.sam}
    #sbatch sam2cov.slurm $id
    ./sam2cov.pl bam/$id-hit.sam cov/$id.cov.txt
done
exit
