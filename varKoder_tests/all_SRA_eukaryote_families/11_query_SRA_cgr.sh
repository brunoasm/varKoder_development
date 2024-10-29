#!/bin/sh

# Run at FMNH server
set +e
source /home/bdemedeiros/software/miniconda3/etc/profile.d/conda.sh
conda activate varKoder
export CUDA_VISIBLE_DEVICES=0,1

#the folder with query images was converted from varKodes
#varKoder convert --overwrite -n 24 cgr varkoder_query_images vkfCGR_query_images


time varKoder query --overwrite -I -b 300 --model vkfCGR_trained_model_ML/trained_model.pkl vkfCGR_query_images vkfCGR_query_results


exit
