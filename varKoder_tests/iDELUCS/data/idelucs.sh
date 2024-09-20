#!/bin/bash
#SBATCH -p shared               # partition (queue)
#SBATCH -n 1                     # number of cores
#SBATCH --mem 10000        # memory pool for each cores
#SBATCH -t 1-0:00                 # time (D-HH:MM)
#SBATCH -o lmcai.out        # STDOUT
#SBATCH -e lmcai.err

module load Anaconda2
source activate getorg
python iDELUCS.py $1
