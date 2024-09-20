#!/bin/bash

source /home/bdemedeiros/software/miniconda3/etc/profile.d/conda.sh
conda activate sra

#first, find all metadata about DNA records with fastq files on SRA
#esearch -db sra -query '"filetype fastq"[Properties] AND "biomol dna"[Properties]' | efetch -format runinfo | gzip -9 > SRA_records.csv.gz

#now, retrieve taxonomic information
gunzip -c SRA_records.csv.gz | csvcut -c TaxID | grep -Eo '[0-9]{2,}' | sort | uniq | xargs -L 1000 | sed 's/ /,/g' | xargs -P 1 -I {} sh -c 'efetch -db taxonomy -format xml -id {} >> SRA_taxonomy.xml; sleep 30'

grep -Ev 'xml version|DOCTYPE TaxaSet>|TaxaSet' SRA_taxonomy.xml > temp
head -n 3 SRA_taxonomy.xml > SRA_taxonomy_clean.xml
cat temp >> SRA_taxonomy_clean.xml
tail -n 1 SRA_taxonomy.xml >> SRA_taxonomy_clean.xml
rm temp SRA_taxonomy.xml
gzip -9 SRA_taxonomy_clean.xml

exit
