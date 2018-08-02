#!/bin/bash

for id in `cat id/824genome.id`
do
   sbatch lastz.slurm $id
done

for id in `cat 824genome.id`
do
    sbatch filter_identity.slurm $id
done
