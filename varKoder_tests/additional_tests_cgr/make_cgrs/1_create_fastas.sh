#!/bin/bash

# Define input and output directories
input_dir="../../fam_gen_sp_multi/intermediate_files/split_fastqs"
output_dir="./fastas"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through all *.fq.gz files in the input directory
for fq_gz_file in "$input_dir"/*.fq.gz; do
    # Extract the filename without the path and extension
    base_name=$(basename "$fq_gz_file" .fq.gz)

    # Define the output file path
    fasta_file="$output_dir/$base_name.fasta"

    # Convert fastq.gz to fasta
    # Decompress the file, extract all sequences, and concatenate them under a single header
    echo ">${base_name}" > "$fasta_file"
    zcat "$fq_gz_file" | awk 'NR%4==2{printf "%s", $0}' >> "$fasta_file"
    echo >> "$fasta_file"  # Add a newline at the end for good formatting
    
    #echo "Converted $fq_gz_file to $fasta_file"
done

echo "All files converted successfully."

