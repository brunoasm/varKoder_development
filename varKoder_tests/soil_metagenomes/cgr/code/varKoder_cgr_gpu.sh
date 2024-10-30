#!/bin/bash
#SBATCH -p gpu
#SBATCH -t 0-06:00
#SBATCH --mem=220000
#SBATCH --gres=gpu:3
#SBATCH -o /n/holyscratch01/davis_lab/pflynn/soil/varkoder_cgr_gpu_output1.log
#SBATCH -e /n/holyscratch01/davis_lab/pflynn/soil/varkoder_cgr_gpu_error1.log

module load python/3.10.12-fasrc01
source activate varKoder_cgr1
cd /n/holyscratch01/davis_lab/pflynn/soil

varKoder train --overwrite -b 6 -r 0.1 --single-label -e 30 -z 0 images_cgr_NEW varkoder_trained_model_SL1_images_cgr_NEW

val_samples=$(grep -E 'True$' varkoder_trained_model_SL1_images_cgr_NEW/input_data.csv | cut -d , -f 1 | paste -sd, -)
echo $val_samples > validation_samples_SL1_images_cgr_NEW.txt

varKoder train -V validation_samples_SL1_images_cgr_NEW.txt -b 300 -r 0.01 -e 3 -z 5 --pretrained-model varkoder_trained_model_SL1_images_cgr_NEW/trained_model.pkl images_cgr_NEW varkoder_trained_model_ML1_images_cgr_NEW


#query
mkdir -p varkoder_query_images_cgr_NEW

cat validation_samples_SL1_images_cgr_NEW.txt | tr ',' '\n' | xargs -L 500 -I {} bash -c 'for sample in "$@"; do for file in $(find  images_cgr_NEW/ -name "${sample}@*"); do ln -sf ../"$file" varkoder_query_images_cgr_NEW/; done; done' bash {}

varKoder query --include-probs --overwrite --threshold 0.7 -I -b 64 --model varkoder_trained_model_ML1_images_cgr_NEW/trained_model.pkl varkoder_query_images_cgr_NEW varkoder_query_results_images_cgr_NEW
