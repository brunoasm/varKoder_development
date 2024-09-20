#!/bin/sh
# no sbatch, computations done in FMNH cluster with linus screen

conda activate varKoder

export CUDA_VISIBLE_DEVICES=1
export VARKODER_PATH=../varKoder/varKoder.py

mkdir -p vit_results

echo ARCHITECTURE vit_large_patch32_224, equal weight

#list all samples
export samples=$(find ./images -name '*.png' -exec basename {} \; | cut -d \+ -f 1 | cut -d @ -f 1 | sort | uniq )


for sample in $samples
    do
    nvidia-smi
    echo START TRAINING  $sample
    time python $VARKODER_PATH train --overwrite --single-label -b 64 -r 0.05 -c vit_large_patch32_224 -z 0 -e 20 -V $sample images vit_train_${sample} 
    time python $VARKODER_PATH train --overwrite --pretrained-model vit_train_${sample}/trained_model.pkl -b 64 -r 0.005 -c vit_large_patch32_224 -z 10 -e 0 -V $sample images vit_train_${sample}
    echo END TRAINING $sample
    mkdir -p vit_query_${sample}
    cd vit_query_${sample}
    ln -s ../images/${sample}@* ./
    cd ..
    echo START QUERY $sample
    time python $VARKODER_PATH query --overwrite -I vit_train_${sample}/trained_model.pkl vit_query_${sample} vit_results/${sample}
    echo ELAPSED QUERY $sample
    mv vit_train_${sample}/input_data.csv vit_results/${sample}/ 
    rm -r vit_train_${sample}  vit_query_${sample}
done


cd ..

echo DONE

exit
