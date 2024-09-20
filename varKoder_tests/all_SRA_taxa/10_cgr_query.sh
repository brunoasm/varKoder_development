#!/bin/sh

# Run at FMNH server
set +e
source /home/bdemedeiros/software/miniconda3/etc/profile.d/conda.sh
conda activate base

#create folder with query images (i. e. those chosen as validation)
mkdir -p query_cgrs

cat validation_set.txt | tr ',' '\n' | xargs -L 100 -I {} bash -c '
    chunk_index=$(printf "%03d" $(($RANDOM % 1000)))
    mkdir -p query_cgrs/chunk_$chunk_index
    for sample in "$@"; do
        for file in $(find cgrs/ -name "${sample}@*"); do
            ln -sf "../../$file" query_cgrs/chunk_$chunk_index/
        done
    done' bash {}


#now do query
conda activate varKoder
export CUDA_VISIBLE_DEVICES=0,1

time varKoder query -I -b 100 --model cgrs_ViT_ML/trained_model.pkl query_cgrs results_cgrs


exit
