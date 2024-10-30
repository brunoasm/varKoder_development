#!/bin/sh
#SBATCH -p sapphire
#SBATCH -t 0-71:00
#SBATCH --mem 60G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH -o /n/holyscratch01/davis_lab/pflynn/soil/Ma_images_varKode.%A.out
#SBATCH -e /n/holyscratch01/davis_lab/pflynn/soil/Ma_images_varKode.%A.err      # File to which standard err will be written

module load python
source activate varKoder_cgr

cd /n/holyscratch01/davis_lab/pflynn/soil/downloads

varKoder image --kmer-mapping cgr -k 7 -n 20 -c 1 -m 500K -M 10M -o ../images Ma_2023_labels.csv -v

exit
