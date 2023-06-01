for bp in 00000500K 00001000K 00002000K 00005000K 00010000K 00020000K 00050000K 00100000K 00200000K
do
mkdir -p $bp
cd $bp
ln -s $PWD/../../../varKoder/fam_gen_sp_multi/intermediate_files/split_fastqs/*${bp}.fq.gz ./
cd ..
done
