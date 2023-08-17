#!/bin/sh
#SBATCH -p test
#SBATCH -t 0-08:00 
#SBATCH --mem 10G 
#SBATCH -n 1 
#SBATCH -c 1
#SBATCH -o 1_download_entrez.%A.out 

sleep 30
scontrol show jobid=$SLURM_JOBID

module load Anaconda3/2020.11
source activate sra


#esearch -db sra -query '"library selection random"[Properties] AND "wgs"[Strategy] AND txid2759[Organism:exp] AND "filetype fastq"[Properties] AND "biomol dna"[Properties]' | efetch -format runinfo > Eukarya_SRA.csv
csvcut -c TaxID Eukarya_SRA.csv | grep -Eo '[0-9]{2,}' | sort | uniq | xargs -L 1000 | sed 's/ /,/g'  | xargs -I {} efetch -db taxonomy -format xml -id {} >> Eukarya_taxonomy.xml
grep -Ev 'xml version|DOCTYPE TaxaSet>|TaxaSet' Eukarya_taxonomy.xml > temp
head -n 3 Eukarya_taxonomy.xml > Eukarya_taxonomy_clean.xml
cat temp >> Eukarya_taxonomy_clean.xml
tail -n 1 Eukarya_taxonomy.xml >> Eukarya_taxonomy_clean.xml 
rm temp


scontrol show jobid=$SLURM_JOBID

exit
