#!/bin/bash

# Define the base directory
base_dir="varKodes/"

# Find all accessions with 00010000K reads and store them in an associative array
declare -A accessions_map
while IFS= read -r file; do
    accession=$(basename "$file" | cut -d'@' -f1)
    accessions_map["$accession"]=1
done < <(find "$base_dir" -type f -name '*@00010000K*')

# Print the length of the associative array
echo "Number of unique accessions with 00010000K reads: ${#accessions_map[@]}"

# Initialize variables for counting deletions
delete_count=0
duplicate_delete_count=0

# Create an associative array to track unique file names
declare -A unique_files

# Process and delete unnecessary files
while IFS= read -r file; do
    accession=$(basename "$file" | cut -d'@' -f1)
    file_name=$(basename "$file")

    if [[ -z "${accessions_map[$accession]}" ]]; then
        echo "Deleting: $file"
        rm "$file"
        ((delete_count++))
    else
        if [[ -n "${unique_files[$file_name]}" ]]; then
            echo "Deleting duplicate: $file"
            rm "$file"
            ((duplicate_delete_count++))
        else
            unique_files["$file_name"]="$file"
        fi
    fi
done < <(find "$base_dir" -type f -name '*.png')

# Display counts
echo "Number of samples deleted: $delete_count"
echo "Number of duplicates deleted: $duplicate_delete_count"

