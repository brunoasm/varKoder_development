#!/bin/bash
conda activate skmer

# In a first run, we got this error:
#Coverage of 8522+SRR16117178@00003994K is too low, not able to estimate it; no correction applied
#Coverage of 7100+ERR4094845@00003940K is too low, not able to estimate it; no correction applied
#Coverage of 8522+SRR16117178@00003994K is too low, not able to estimate it; no correction applied
#Coverage of 7100+ERR4094845@00003940K is too low, not able to estimate it; no correction applied
#Coverage of 156323+ERR4991846@00010000K is too low, not able to estimate it; no correction applied
#Coverage of 156323+ERR4991846@00010000K is too low, not able to estimate it; no correction applied
# for that reason, we will redo it and delete these samples before

rm training_data/8522+SRR16117178*
rm training_data/100+ERR4094845*
rm training_data/522+SRR16117178*
rm training_data/100+ERR4094845*
rm training_data/56323+ERR4991846*
rm training_data/56323+ERR4991846*

cd training_data

time find . -name '*.gz' | parallel --progress -j 32 gunzip -f {}  

cd ..

time skmer reference -S 3152637 -p 32 -l skmer_ref training_data

exit
