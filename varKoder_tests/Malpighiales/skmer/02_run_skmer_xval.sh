mkdir -p skmer_xval_results

conda activate skmer

export bp=maxdata

echo REFERENCES: $bp
rm -rf temp_query_$bp
find ./temp_ref_$bp/ -name '*.gz' | parallel -j 64 gunzip -f {}
mkdir -p temp_out_$bp
mkdir -p temp_query_$bp
mkdir -p temp_skmer_$bp

export RANDOM=426547

for sample in $(find 00000500K/ -name '*.fq.gz' -exec basename {} \; | cut -d @ -f 1 | sort | uniq)
do
    echo STARTING $bp $sample
    
    if compgen -G skmer_xval_results/dist_r${bp}*${sample,,}* > /dev/null; #tests if glob pattern exists
    then
        echo $sample done already, skipping
    else
        mv ./temp_ref_$bp/${sample}@*.fq ./temp_out_$bp/ 
        find ./0*K/ -name "${sample}@*" -exec cp -P {} ./temp_query_$bp/ \;
        echo UNZIPPING
        start_unzip=$SECONDS
        time {
            find ./temp_query_$bp/ -name '*.gz' | parallel -j 64 gunzip -f {}
        }
        echo ELAPSED UNZIP $bp $sample:$(( SECONDS - start_unzip ))
        start_reference=$SECONDS
        time skmer reference -S $RANDOM -p 20 -l temp_skmer_$bp temp_ref_$bp
        echo ELAPSED REFERENCE $bp $sample:$(( SECONDS - start_reference ))
	echo disk space for reference: $(du -sh temp_skmer_$bp)
	echo disk space for sequences: $(du -sh temp_ref_$bp)

        for query_samp in ./temp_query_$bp/*.fq
        do
            bp_query=$(echo $query_samp | cut -f 3 -d / | grep -Eo "[0-9]+K")
            start_query=$SECONDS
            time skmer query -p 20 -o dist_${bp} temp_query_$bp/*$bp_query*.fq temp_skmer_$bp
            echo ELAPSED QUERY ref_$bp ${sample}_$bp_query:$(( SECONDS - start_query ))
        done

        mv dist* skmer_xval_results/
        mv ./temp_out_$bp/*.fq ./temp_ref_$bp/
        rm -r ./temp_query_$bp/*
        rm -r ./temp_skmer_$bp/* ref-dist-mat.txt
    fi
done

echo DONE