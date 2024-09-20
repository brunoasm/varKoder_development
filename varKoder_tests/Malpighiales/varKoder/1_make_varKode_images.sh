#!/bin/sh
#SBATCH -p test
#SBATCH -t 0-08:00 
#SBATCH --mem 50G 
#SBATCH -n 8 
#SBATCH -c 2
#SBATCH -o 1_generate_varkodes.%A.out 

sleep 30
scontrol show jobid=$SLURM_JOBID

module load Anaconda3/2020.11 cuda
source activate varKoder

VARKODER_PATH=/n/home08/souzademedeiros/programs/varKoder/varKoder.py

time python $VARKODER_PATH image -k 7 -n $SLURM_NTASKS -c $SLURM_CPUS_PER_TASK -i intermediate_files -m 500K -M 200M -o images -f stats.csv ../../datasets/all_multilabel/files_corrected.csv 

scontrol show jobid=$SLURM_JOBID

exit
