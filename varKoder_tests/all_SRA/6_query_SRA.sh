#!/bin/sh
# Run at FMNH server

conda deactivate
conda activate varKoder
export CUDA_VISIBLE_DEVICES=3

#create folder with query images (i. e. those chosen as validation)
mkdir -p varkoder_query_images

cat validation_samples_SL.txt | tr ',' '\n' | xargs -L 500 -I {} bash -c 'for sample in "$@"; do for file in $(find varkoder_images_SRA/ -name "${sample}@*"); do ln -sf ../"$file" varkoder_query_images/; done; done' bash {}

#now do query
VARKODER_PATH=/home/bdemedeiros/varKoder_test/varKoder/varKoder.py

time python $VARKODER_PATH query --overwrite -I -b 300 varkoder_trained_model_ML/trained_model.pkl varkoder_query_images varkoder_query_results


exit
