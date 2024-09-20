#!/bin/sh
#SBATCH -p shared
#SBATCH -t 7-00:00 
#SBATCH --mem 10G 
#SBATCH -n 1 
#SBATCH -c 1
#SBATCH -o 3_download_SRA.%A.out 

sleep 30
scontrol show jobid=$SLURM_JOBID

module load Anaconda3/2020.11
source activate sra

cat runs_to_download.txt | while read line
do
echo working on $line
accession=$(echo $line | cut -d , -f 1)
famid=$(echo $line | cut -d , -f 2) 

fastq-dump -N 10000 -X 510000 --skip-technical --gzip --read-filter pass --readids --split-spot --split-files --outdir varkoder_SRA/$famid/$accession $accession
done

scontrol show jobid=$SLURM_JOBID

exit
