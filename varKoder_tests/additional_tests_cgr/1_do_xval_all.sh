#!/bin/bash
# This script uses varKoder 1.0.0a

source $(conda info --base)/etc/profile.d/conda.sh
conda activate varKoder

export CUDA_VISIBLE_DEVICES=2,3

for infolder in datasets/*/;
do
    INPUT_DATA=$(basename "$infolder")
    for architecture in ig_resnext101_32x8d vit_large_patch32_224 fiannaca2018 arias2022;
    do
        outfolder="results_${INPUT_DATA}_${architecture}"
        mkdir -p "$outfolder"

        echo "ARCHITECTURE $architecture DATA $INPUT_DATA"

        # List all samples
        samples=$(find "$infolder" -name '*.png' -exec basename {} \; | cut -d '+' -f 1 | cut -d '@' -f 1 | sort | uniq)

        for sample in $samples
        do
            echo "START TRAINING $sample"
	    #if [[ "$architecture" != "arias2022" && "$architecture" != "fiannaca2018" ]]; then
            /usr/bin/time -v varKoder train --overwrite --random-weights --label-table labels.csv --single-label -b 64 -r 0.05 -c "$architecture" -z 0 -e 20 -V "$sample" "$infolder" "${outfolder}_${sample}"
            /usr/bin/time -v varKoder train --overwrite --label-table labels.csv --pretrained-model "${outfolder}_${sample}/trained_model.pkl" -b 64 -r 0.005 -c "$architecture" -z 10 -e 0 -V "$sample" "$infolder" "${outfolder}_${sample}"
            #else
	    #/usr/bin/time -v varKoder train --overwrite --label-table labels.csv -b 64 -r 0.05 -c "$architecture" -z 0 -e 30 -V "$sample" "$infolder" "${outfolder}_${sample}"
	    #fi
            echo "END TRAINING $sample"

            query_outfolder="${outfolder}_query_$sample"
            mkdir -p "$query_outfolder"
            cd "$query_outfolder" || exit
            ln -s "../$infolder/${sample}@"* ./
            cd - || exit

            echo "START QUERY $sample"
            /usr/bin/time -v varKoder query --include-probs --overwrite -I -l "${outfolder}_${sample}/trained_model.pkl" "$query_outfolder" "$outfolder/${sample}"
            echo "END QUERY $sample"

	    mkdir -p "$outfolder/${sample}/"
            mv "${outfolder}_${sample}/input_data.csv" "$outfolder/${sample}/"
            rm -r "${outfolder}_${sample}" "$query_outfolder"
            echo "DONE WITH SAMPLE $sample ARCHITECTURE $architecture DATA $INPUT_DATA"
        done

    done

done

echo "DONE"
exit

