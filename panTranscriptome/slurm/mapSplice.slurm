#!/bin/bash

#SBATCH -J MapSplice
#SBATCH --partition=cpu
#SBATCH --mail-type=ALL
#SBATCH -n 16
#SBATCH --exclusive
#SBATCH --output=%J.out
#SBATCH --error=%J.err
echo start

#config=$1
#python ~/fzyan/softwares/MapSplice_1.15.2/bin/mapsplice_segments.py $config

#sample=$1
python ~/fzyan/softwares/MapSplice_1.15.2/bin/mapsplice_segments.py -u WGC017518R/reads_end1,WGC017518R/reads_end2 -c chromosome/ -B GRCh38.p10 -o MapSplice_WGC017518R -Q fq -X 16 --pairend --fusion

echo  end

exit
