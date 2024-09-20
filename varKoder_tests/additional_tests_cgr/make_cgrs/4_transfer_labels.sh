#!/bin/bash

# Define the paths to the folders
folderA="../fam_gen_sp_multi/images"
folderB="./cgr_imgs"

# Create the CSV file with headers
echo "sample,labels" > "$folderB/labels.csv"

# Loop through all PNG files in Folder B
for fileB in "$folderB"/*.png; do
    # Extract the base filename without the path
    filename=$(basename "$fileB")
    
    # Corresponding file in Folder A
    fileA="$folderA/$filename"
    
    # Check if the file exists in Folder A
    if [ -f "$fileA" ]; then
        # Use exiftool to extract VarkoderKeywords
        labels=$(exiftool -s -s -s -VarkoderKeywords "$fileA")
        
        # Extract the sample name before '@'
        sample=${filename%%@*}
        
        # Write to the CSV file
        echo "$sample,$labels" >> "$folderB/labels.csv"
    else
        echo "No matching file found in Folder A for $filename"
    fi
done

echo "CSV file creation complete."

