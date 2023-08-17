#!/bin/sh
#SBATCH -p shared
#SBATCH -t 7-00:00 
#SBATCH --mem 50G 
#SBATCH -N 1
#SBATCH -n 8 
#SBATCH -c 2
#SBATCH -o 4_generate_varkodes.%A.out 

#This was initially run in Harvard cluster but later iterations 
#were done at the Field Museum, so we comment out Harvard-specific parts

#sleep 30
#scontrol show jobid=$SLURM_JOBID

#module load Anaconda3/2020.11 cuda
#source activate varKoder

conda activate varKoder

#VARKODER_PATH=/n/home08/souzademedeiros/programs/varKoder/varKoder.py
VARKODER_PATH=/home/bdemedeiros/varKoder_test/varKoder/varKoder.py

mkdir -p /data/bdemedeiros/varkoder_int_SRA
ln -sf /data/bdemedeiros/varkoder_int_SRA ./

time python $VARKODER_PATH image -k 7 -m 500K -M 10M -n 20 -c 2 -i varkoder_int_SRA/ -o varkoder_images_SRA/ -f image_stats_2.csv varkoder_SRA/

#scontrol show jobid=$SLURM_JOBID

exit
