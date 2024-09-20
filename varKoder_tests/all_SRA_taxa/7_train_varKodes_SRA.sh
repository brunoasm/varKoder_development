#!/bin/sh

# Run at FMNH server
set +e
source /home/bdemedeiros/software/miniconda3/etc/profile.d/conda.sh
conda activate varKoder
export CUDA_VISIBLE_DEVICES=2,3



# Start by pretraining with single labels on the training set only, no validation metrics

#create validation set file
awk -F, '$5 == "True" {print $1}' train_valid_sets.csv | sort | uniq | paste -sd, - > validation_set.txt

#create a simplified labels file
echo "sample,labels" > labels_SL_training.csv

awk -F, 'NR > 1 {
    split($4, labels, ";")
    filtered_labels = ""
    for (i in labels) {
        if (labels[i] ~ /LibraryStrategy|Platform|Taxonomy_kingdom|Taxonomy_family|Taxonomy_genus/) {
            filtered_labels = (filtered_labels == "" ? labels[i] : filtered_labels ";" labels[i])
        }
    }
    print $1 "," filtered_labels
}' train_valid_sets.csv >> labels_SL_training.csv

#pretrain
#time varKoder train --label-table labels_SL_training.csv --single-label --no-metrics --validation-set validation_set.txt --architecture vit_large_patch32_224 --random-weights -n 12 -b 500 -r 0.1 -e 30 -z 0 varKodes varkodes_ViT_SL

# After pretraining on single labels is done, we will done continue with multilabel

# create label table for multilabel training
# this is faster than let varKoder extract from the exif metadata
echo "sample,labels" > labels_ML_training.csv

# Define the random seed
RANDOM_SEED=12345

# Generate a random source file for reproducibility
awk 'BEGIN{srand('$RANDOM_SEED');for(i=0;i<65536;i++)print int(65536*rand())}' > random_source.txt

# Extract records where is_valid is False
awk -F, '
BEGIN {
    OFS=",";
}
NR > 1 && $5 == "False" {
    sample = $1;
    labels = $4;
    print sample, labels;
}
' train_valid_sets.csv >> labels_ML_training.csv

# Extract and shuffle records where is_valid is True, then take 1000 random ones
awk -F, '
BEGIN {
    OFS=",";
}
NR > 1 && $5 == "True" {
    print $0;
}
' train_valid_sets.csv | shuf --random-source=random_source.txt -n 1000 | awk -F, '
BEGIN {
    OFS=",";
}
{
    sample = $1;
    labels = $4;
    print sample, labels;
}
' >> labels_ML_training.csv

# Clean up the random source file
rm random_source.txt


time varKoder train --label-table labels_ML_training.csv --validation-set validation_set.txt -n 12 -b 600 -r 0.05 -e 50 -z 10 --pretrained-model varkodes_ViT_SL/trained_model.pkl varKodes varkodes_ViT_ML

exit
