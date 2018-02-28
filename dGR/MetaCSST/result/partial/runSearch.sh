#!/usr/bin/bash


for i in candidate/*.fa
do
    tmp=${i#candidate/}
    sample=${tmp%-*}
    tmp2=${tmp#*-}
    tr=${tmp2%.fa}
    
    sbatch searchVR.slurm $tr $sample
    #./searchVR.pl TR/$tr.TR.fa candidate/$sample-$tr.fa search/$tr.out 3
done
exit
