#!/bin/bash
#
#SBATCH -n 8                 # Number of cores
#SBATCH -N 1                 # Number of nodes for the cores
#SBATCH -t 2-12:05           # Runtime in D-HH:MM format
#SBATCH -p serial_requeue    # Partition to submit to
#SBATCH --mem=80000            # Memory pool for all CPUs
#SBATCH -o lmcai.out      # File to which standard out will be written
#SBATCH -e lmcai.err      # File to which standard err will be written

module load Anaconda
source activate temp

export DATA_DIR=/n/davis_lab/Lab/Renata_Chrysobalanaceae_Stigmaphyllon_2020/200828_A00794_0250_AHNYLCDRXX/fastq/SUB09764
gunzip < $DATA_DIR/$1_L001_R1_001.fastq.gz >$1.R1.fq
gunzip < $DATA_DIR/$1_L002_R1_001.fastq.gz >$1.R1.fq
gunzip < $DATA_DIR/$1_L001_R2_001.fastq.gz >$1.R2.fq
gunzip < $DATA_DIR/$1_L002_R2_001.fastq.gz >$1.R2.fq

/usr/bin/time -v get_organelle_from_reads.py -1 $1.R1.fq -2 $1.R2.fq -t 8 -o $1 -F embplant_pt -R 10 &>$1.log
rm $1.R?.fq
