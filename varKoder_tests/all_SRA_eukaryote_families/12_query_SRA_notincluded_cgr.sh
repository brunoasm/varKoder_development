#!/bin/sh

# Run at FMNH server
set +e
source /home/bdemedeiros/software/miniconda3/etc/profile.d/conda.sh
conda activate varKoder
export CUDA_VISIBLE_DEVICES=0,1

# convert not_included
varKoder convert --overwrite -n 24 cgr varkoder_images_SRA_notincluded vkfCGR_images_SRA_notincluded

varKoder query --overwrite -I -b 300 --model vkfCGR_trained_model_ML/trained_model.pkl vkfCGR_images_SRA_notincluded vkfCGR_query_notincluded_results

echo DONE

exit
