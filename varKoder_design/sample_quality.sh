#!/bin/sh
#SBATCH -p gpu_requeue
#SBATCH -t 1-00:00 
#SBATCH --mem 20G 
#SBATCH -n 2 
#SBATCH --constraint=a100|v100  
#SBATCH --gres=gpu:2 
#SBATCH -o sample_quality.out 

sleep 30
scontrol show jobid=$SLURM_JOBID

module load Anaconda3
source activate barcoding
python sample_quality.py

scontrol show jobid=$SLURM_JOBID

exit
