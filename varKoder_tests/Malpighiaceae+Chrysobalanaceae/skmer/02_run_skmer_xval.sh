#!/bin/bash
#SBATCH -J skmer                               # Job name 
#SBATCH -o skmer.%A.%a.out                     # File to which stdout will be written
#SBATCH -N 1
#SBATCH --array 0-8%2
#SBATCH -n 16                                    # number of ranks
#SBATCH -t 7-00:00:00                             # Runtime in DD-HH:MM
#SBATCH --mem 50000                              # Memory for all cores in Mbytes (--mem-per-cpu for MPI jobs)
#SBATCH -p shared                      # Partition general, serial_requeue, unrestricted, interact


module load Anaconda3 parallel
source activate skmer

mkdir -p skmer_xval_results

all_bp=(00200000K 00001000K 00000500K 00050000K 000100000K 00020000K 00010000K 00005000K 00002000K)

bp=${all_bp[$SLURM_ARRAY_TASK_ID]}

echo REFERENCES: $bp
rm -rf temp_ref_$bp temp_query_$bp
mkdir -p ~/scratchdir/skmer_xval/temp_ref_$bp
ln -sf ~/scratchdir/skmer_xval/temp_ref_$bp temp_ref_$bp
cp -P ./$bp/*.fq.gz ./temp_ref_$bp/
find ./temp_ref_$bp/ -name '*.gz' | parallel -j $SLURM_NTASKS gunzip -f {}
mkdir -p ~/scratchdir/skmer_xval/temp_out_$bp
ln -sf ~/scratchdir/skmer_xval/temp_out_$bp temp_out_$bp
mkdir -p ~/scratchdir/skmer_xval/temp_query_$bp
ln -sf ~/scratchdir/skmer_xval/temp_query_$bp temp_query_$bp
mkdir -p ~/scratchdir/skmer_xval/temp_skmer_$bp
ln -sf ~/scratchdir/skmer_xval/temp_skmer_$bp temp_skmer_$bp

export RANDOM=42$SLURM_ARRAY_TASK_ID

for sample in S-1 S-10 S-100 S-11 S-12 S-13 S-14 S-15 S-16 S-17 S-18 S-19 S-2 S-20 S-21 S-22 S-23 S-24 S-25 S-26 S-27 S-28 S-29 S-3 S-30 S-31 S-32 S-33 S-34 S-35 S-36 S-37 S-38 S-39 S-4 S-40 S-41 S-42 S-43 S-44 S-45 S-46 S-47 S-48 S-49 S-5 S-50 S-51 S-52 S-53 S-54 S-55 S-56 S-57 S-58 S-59 S-6 S-60 S-61 S-62 S-63 S-64 S-65 S-66 S-67 S-68 S-69 S-7 S-70 S-71 S-72 S-73 S-74 S-75 S-76 S-77 S-78 S-79 S-8 S-80 S-81 S-82 S-83 S-84 S-85 S-86 S-87 S-88 S-89 S-9 S-90 S-91 S-92 S-93 S-94 S-95 S-96 S-97 S-98 S-99
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
            find ./temp_query_$bp/ -name '*.gz' | parallel -j $SLURM_NTASKS gunzip -f {}
        }
        echo ELAPSED UNZIP $bp $sample:$(( SECONDS - start_unzip ))

        start_reference=$SECONDS
        time skmer reference -S $RANDOM -p $SLURM_NTASKS -l temp_skmer_$bp temp_ref_$bp
        echo ELAPSED REFERENCE $bp $sample:$(( SECONDS - start_reference ))

        for query_samp in ./temp_query_$bp/*.fq
        do
            bp_query=$(echo $query_samp | cut -f 3 -d / | grep -Eo "[0-9]+K")
            start_query=$SECONDS
            time skmer query -p $SLURM_NTASKS -o dist_r${bp}- temp_query_$bp/*$bp_query*.fq temp_skmer_$bp
            echo ELAPSED QUERY ref_$bp ${sample}_$bp_query:$(( SECONDS - start_query ))
        done

        mv dist* skmer_xval_results/
        mv ./temp_out_$bp/*.fq ./temp_ref_$bp/
        rm -r ./temp_query_$bp/*
        rm -r ./temp_skmer_$bp/* ref-dist-mat.txt
    fi
done


export outfile=skmer.${SLURM_JOBID}.${SLURM_ARRAY_TASK_ID}.out 
sbatch -p test -t 0:1:00 --mem 10M -o $outfile --open-mode=append --wrap "sleep 30; seff $SLURM_JOBID"
rm -r temp_skmer_$bp $(readlink -f temp_skmer_$bp) temp_ref_$bp $(readlink -f temp_ref_$bp) temp_query_$bp $(readlink -f temp_query_$bp)
