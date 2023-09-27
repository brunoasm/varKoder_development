#!/bin/sh
# Run at FMNH server

conda deactivate
conda activate varKoder

#now do query
VARKODER_PATH=/home/bdemedeiros/varKoder_test/varKoder/varKoder.py

#create folder with query images
time python $VARKODER_PATH image -k 7 -m 500K -M 10M -n 20 -c 2 -i varkoder_int_SRA/ -o varkoder_images_SRA_notincluded/ -f image_stats_3.csv varkoder_SRA_notincluded/

time python $VARKODER_PATH query --overwrite -I -b 300 varkoder_trained_model_ML/trained_model.pkl varkoder_images_SRA_notincluded varkoder_query_notincluded_results

echo DONE

exit
