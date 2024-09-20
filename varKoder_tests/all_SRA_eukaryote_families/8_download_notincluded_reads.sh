#!/bin/sh

conda activate sra

cat runs_notincluded_to_download.txt | while read line
do
echo working on $line
accession=$(echo $line | cut -d , -f 1)
famid=$(echo $line | cut -d , -f 2) 

fastq-dump -N 10000 -X 510000 --skip-technical --gzip --read-filter pass --readids --split-spot --split-files --outdir varkoder_SRA_notincluded/$famid/$accession $accession
done

echo DONE

exit
