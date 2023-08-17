# Testing family-level identification for all Eukarya on SRA

Here we will download sequences for up to 10 biosamples for each eukaryotic family on SRA.

We will use NCBI Entrez to download the data and then python to select the samples

The we will use fastq-dump to download up to 200,000 reads per SRA accession and finally use varKoder to generate varKodes

# Downloading software

To use Entrez and sra-toolkit, we install using Anaconda:

`conda create -n sra -c bioconda -c conda-forge entrez-direct sra-tools pandas csvkit xmlstarlet`

# Querying SRA

We start by using Entrez to download SRA accession data and associated taxonomic data with the script `1_download_entrez_data.sh`

# Choosing records

We choose the 10 biosamples per family with python script `2_choose_data_to_download.py`. This is fast and can be run interactively.

This is script selects, for each eukaryotic family, up to 10 random biosamples. Biosamples with less than 15Mb of data are discarded. Families with less than 3 biosamples are discarded.

# Downloading

# Processing
python $VARKODER_PATH image -k 7 -m 500K -M 10M -n $SLURM_NTASKS -c $SLURM_CPUS_PER_TASK -i varkoder_int_SRA/ -o varkoder_images_SRA/ -f image_stats.csv varkoder_SRA/

During the process, some samples resulted in errors and were manually removed:
too few reads: varkoder_SRA/196982/SRR18105716
too few reads: varkoder_SRA/213546/SRR12928426
too few reads: varkoder_SRA/24079/SRR13970210
too few reads: varkoder_SRA/24079/SRR13970214


