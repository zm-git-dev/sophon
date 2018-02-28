#!/usr/bin/bash


for i in blastn/*.m8.id
do
    pre=${i%.m8.id}
    pre2=${pre#blastn/}
    id=${i%-*}
    id2=${id#blastn/}
    echo "$pre2..."
    sbatch getCandidate.slurm $id2 $i $pre2
    #filterFa ~/data/HMP/HMIWGS/fa/$id2.fa $i candidate/$pre2.fa
done

exit
