#!/bin/sh

# Run at FMNH server
set +e
source /home/bdemedeiros/software/miniconda3/etc/profile.d/conda.sh
conda activate varKoder
export CUDA_VISIBLE_DEVICES=0,1

#varKoder convert --overwrite -n 24 cgr varkoder_images_SRA vkfCGR_images_SRA
#varKoder convert --overwrite -n 24 cgr varkoder_query_images vkfCGR_query_images

#we have randomly picked validation samples already when we trained with varKodes, let's use the same

time varKoder train --overwrite -V validation_samples_SL.txt -b 300 -r 0.1 --single-label -e 30 -z 0  vkfCGR_images_SRA vkfCGR_trained_model_SL


time varKoder train -V validation_samples_SL.txt -b 300 -r 0.01 -e 3 -z 5  --pretrained-model vkfCGR_trained_model_SL/trained_model.pkl vkfCGR_images_SRA vkfCGR_trained_model_ML

exit
