#!/bin/bash

## six primates
arr=(GCF_000772875.2_Mmul_8.0.1_genomic GCF_000264685.3_Panu_3.0_genomic GCF_000004665.1_Callithrix_jacchus-3.2_genomic GCF_000151905.2_gorGor4_genomic GCF_002880775.1_Susie_PABv2_genomic GCF_000146795.2_Nleu_3.0_genomic)


for obj in ${arr[@]}
do
    sbatch primateBlastm.slurm $obj
done
exit

