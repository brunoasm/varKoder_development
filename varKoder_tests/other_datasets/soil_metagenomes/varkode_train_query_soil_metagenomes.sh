salloc -p gpu_test -t 0-01:00 --mem 80000 --gres=gpu:3

module load python
source activate varKoder_cgr

cd /n/holyscratch01/davis_lab/pflynn/soil


varKoder train --overwrite -b 6 -r 0.1 --single-label -e 30 -z 0  images varkoder_trained_model_SL1_images

val_samples=$(grep -E 'True$' varkoder_trained_model_SL1_images/input_data.csv | cut -d , -f 1 | paste -sd, -)
echo $val_samples > validation_samples_SL1_images.txt

varKoder train -V validation_samples_SL1_images.txt -b 300 -r 0.01 -e 3 -z 5 --pretrained-model varkoder_trained_model_SL1_images/trained_model.pkl images varkoder_trained_model_ML1_images


#query
mkdir -p varkoder_query_images

cat validation_samples_SL1_images.txt | tr ',' '\n' | xargs -L 500 -I {} bash -c 'for sample in "$@"; do for file in $(find  images/ -name "${sample}@*"); do ln -sf ../"$file" varkoder_query_images/; done; done' bash {}

varKoder query --include-probs --overwrite --threshold 0.7 -I -b 64 --model varkoder_trained_model_ML1_images/trained_model.pkl varkoder_query_images varkoder_query_results_IMAGES

