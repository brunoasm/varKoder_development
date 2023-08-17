#!/bin/sh

# Run at FMNH server

conda activate varKoder
export CUDA_VISIBLE_DEVICES=2

#VARKODER_PATH=/n/home08/souzademedeiros/programs/varKoder/varKoder.py
VARKODER_PATH=/home/bdemedeiros/varKoder_test/varKoder/varKoder.py
#time python $VARKODER_PATH train --overwrite -b 300 -r 0.1 --single-label -e 30 -z 0  varkoder_images_SRA varkoder_trained_model_SL

val_samples=$(grep -E 'True$' varkoder_trained_model_SL/input_data.csv | cut -d , -f 2 | paste -sd, -)
echo $val_samples > validation_samples_SL.txt

time python $VARKODER_PATH train -V validation_samples_SL.txt -b 300 -r 0.01 -e 3 -z 5  --pretrained-model varkoder_trained_model_SL/trained_model.pkl varkoder_images_SRA varkoder_trained_model_ML

exit
