

#mkdir -p /data/bdemedeiros/skmer_ref
#ln -s /data/bdemedeiros/skmer_ref ./

#create folders
mkdir -p skmer_ref
mkdir -p training_data
mkdir -p query_data

#get reference data: the largest sequence file for each sample used as training in varKoding
grep False ../varkoder_trained_model/input_data.csv | cut -d , -f 3 | while read accession
    do find ../varkoder_int_SRA/split_fastqs/ -name "*${accession}*"  | sort | tail -n 1 | xargs -I {} ln -sf $(readlink -f {}) training_data/
done

#get query data: all sequence files for each sample used as query in varKoding
grep True ../varkoder_trained_model/input_data.csv | cut -d , -f 3 | while read accession
    do find ../varkoder_int_SRA/split_fastqs/ -name "*${accession}*" -exec ln -sf $(readlink -f {}) query_data/ \;
done

