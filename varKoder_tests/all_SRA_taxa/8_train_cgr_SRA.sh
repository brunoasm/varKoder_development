#!/bin/sh

# Run at FMNH server
set +e
source /home/bdemedeiros/software/miniconda3/etc/profile.d/conda.sh
conda activate varKoder
export CUDA_VISIBLE_DEVICES=2,3



# Start by pretraining with single labels on the training set only, no validation metrics


#pretrain
#time varKoder train --label-table labels_SL_training.csv --single-label --no-metrics --validation-set validation_set.txt --architecture vit_large_patch32_224 --random-weights -n 12 -b 500 -r 0.1 -e 30 -z 0 cgrs cgrs_ViT_SL

# After pretraining on single labels is done, we will continue with multilabel

time varKoder train --label-table labels_ML_training.csv --validation-set validation_set.txt -n 12 -b 500 -r 0.01 -e 50 -z 10 --pretrained-model cgrs_ViT_SL/trained_model.pkl cgrs cgrs_ViT_ML

exit
