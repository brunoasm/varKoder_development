#!/bin/bash
conda activate skmer

#Because skmer fails to do sketches for very low coverage samples sometimes,
#we will resume but first delete folders for samples that failed

#The following deletes folders that do not contain a *.msh file:

echo deleting folders that do not contain *.msh file

find ./skmer_ref/ -mindepth 1 -type d '!' -exec sh -c 'ls -1 "{}"/*.msh >/dev/null 2>&1' ';' -print | xargs -I {} rm "training_data/{}*"

#now we can resume:
echo retrying skmer

time skmer reference -S 3152637 -p 8 -l skmer_ref training_data
ps -ly $!

exit
