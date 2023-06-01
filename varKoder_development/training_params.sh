#!/bin/sh
#SBATCH -p gpu
#SBATCH -t 7-00:00 
#SBATCH --mem 20G 
#SBATCH -n 4 
#SBATCH --constraint=a100|v100  
#SBATCH --gres=gpu:2 
#SBATCH -o training_params.out 

sleep 30
scontrol show jobid=$SLURM_JOBID

module load Anaconda3
source activate barcoding
python training_params.py

scontrol show jobid=$SLURM_JOBID

exit
