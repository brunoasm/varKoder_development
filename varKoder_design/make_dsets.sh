#!/bin/bash
#SBATCH -J dsets                              # Job name 
#SBATCH -o dsets.%A.out                     # File to which stdout will be written
#SBATCH -N 1
#SBATCH -n 3                                # number of ranks
#SBATCH -c 2
#SBATCH -t 0-08:00:00                             # Runtime in DD-HH:MM
#SBATCH --mem 30G                              # Memory for all cores in Mbytes (--mem-per-cpu for MPI jobs)
#SBATCH -p test                      # Partition general, serial_requeue, unrestricted, interact


module load Anaconda3
source activate barcoding

for kmer in 5 6 7 8 9
do
python ../../barcode_tool/varKode.py image -d 144 \
                                           --min-bp 500K \
                                           -n $SLURM_NTASKS \
                                           -c $SLURM_CPUS_PER_TASK \
                                           -i intermediate_files \
                                           -k $kmer ../datasets/species/by_folders/ \
                                           --outdir images_$kmer
done

sbatch -t 0:1:00 --mem 10M --wrap "sleep 30; seff $SLURM_JOBID" -o dsets.${SLURM_JOBID}.out --open-mode=append
exit
