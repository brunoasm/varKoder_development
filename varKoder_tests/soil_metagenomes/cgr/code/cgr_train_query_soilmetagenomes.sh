salloc -p gpu_test -t 0-06:00 --mem 90000 --gres=gpu:3

module load python/3.10.12-fasrc01
source activate varKoder_cgr1
cd /n/holyscratch01/davis_lab/pflynn/soil

varKoder train --overwrite -b 300 -r 0.1 --single-label -e 30 -z 0 cgr_images varkoder_trained_model_SL1_images_cgr_FINAL

val_samples=$(grep -E 'True$' varkoder_trained_model_SL1_images_cgr_FINAL/input_data.csv | cut -d , -f 1 | paste -sd, -)
echo $val_samples > validation_samples_SL1_images_cgr_FINAL.txt

varKoder train -V validation_samples_SL1_images_cgr_FINAL.txt -b 64 -r 0.01 -e 3 -z 5 --pretrained-model varkoder_trained_model_SL1_images_cgr_FINAL/trained_model.pkl cgr_images varkoder_trained_model_ML1_images_cgr_FINAL


#query
mkdir -p varkoder_query_images_cgr_FINAL

cat validation_samples_SL1_images_cgr_FINAL.txt | tr ',' '\n' | xargs -L 500 -I {} bash -c 'for sample in "$@"; do for file in $(find  cgr_images/ -name "${sample}@*"); do ln -sf ../"$file" varkoder_query_images_cgr_FINAL/; done; done' bash {}

#now do query

varKoder query --include-probs --overwrite --threshold 0.7 -I -b 64 --model varkoder_trained_model_ML1_images_cgr_FINAL/trained_model.pkl varkoder_query_images_VarKode_FINAL varkoder_query_results_images_cgr_FINAL

