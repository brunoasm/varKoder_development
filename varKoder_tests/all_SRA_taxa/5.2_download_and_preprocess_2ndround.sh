#!/bin/bash

set +e
source /home/bdemedeiros/software/miniconda3/etc/profile.d/conda.sh
conda activate varKoder

### This script is almost the same as the previous one,
### but we attempt to download more spots per sample since
### for some samples a lot more was filtered than expected due to quality
### We are also more lenient with quality, removing --read-filter from fastq-dump
### Chunk size is also bigger since most samples have been downloaded already

#mkdir -p /data/bdemedeiros/varKodes_allSRA
#ln -sf /data/bdemedeiros/varKodes_allSRA/ varKodes

# CSV file name
csv_file="train_valid_sets.csv"

# Function to list records already processed
export RUN_ID_FILE=$(mktemp) # Creates a temporary file

generate_run_id_list() {
    > "$RUN_ID_FILE" # Ensure the file is empty before we start

    declare -A run_id_map=() # Initialize associative array to hold run IDs

    for file in varKodes/*/*@*; do
        local run_id="${file#varKodes/*/}" # Extract part of the filename after 'varKodes/'
        run_id="${run_id%%@*}" # Cut the filename before the first '@'
        run_id_map["$run_id"]=1 # Add to associative array, duplicates will be overwritten
    done

    # Write run IDs to the temporary file
    for run_id in "${!run_id_map[@]}"; do
        echo "$run_id" >> "$RUN_ID_FILE"
    done
}

# Function to check if image files for a run exist in varKodes/
check_images_exist() {
    local run=$1

    # Use grep to search for the run ID in the temporary file
    if grep -q "^$run\$" "$RUN_ID_FILE"; then
        return 0 # Run ID exists
    else
        return 1 # Run ID does not exist
    fi
}
export -f check_images_exist

# Function to process each record
process_record() {
    local run=$1
    local ave_spots=$2
    local label=$3
    local chunk_dir=$4
    local max_spots=$5

    # Check if image files for this run already exist, skip if they do
    if grep -q "^$run\$" "$RUN_ID_FILE"; then
        echo "Skipping $run"
        return
    #else
        #echo $run $RUN_ID_FILE
    fi


    # Ensure chunk_dir is set and writable
    if [[ -z "$chunk_dir" || ! -d "$chunk_dir" || ! -w "$chunk_dir" ]]; then
        echo "Error: chunk_dir is not set correctly or is not writable."
        return 1
    fi

    # Calculate nspots using bc for floating point support and round it
    local nspots=$(printf "%.0f" $(echo "$ave_spots * 5 + 10000" | bc))

    # Calculate the smaller of 10,000 or 10% of max_spots
    local ten_percent_max_spots=$(printf "%.0f" $(echo "$max_spots * 0.10" | bc))
    local min_spots=$(( $ten_percent_max_spots < 10000 ? $ten_percent_max_spots : 10000 ))

    # Attempt to run fastq-dump with dynamically calculated -N value, retry up to 5 times
    local attempt=1
    while [ $attempt -le 3 ]; do
        echo "Attempt $attempt to run fastq-dump for $run..."
	echo fastq-dump -N $min_spots -X $nspots --skip-technical --gzip  --readids --split-spot --split-files --outdir "$chunk_dir" "$run"
        if timeout 90s fastq-dump -N $min_spots -X $nspots --skip-technical --gzip  --readids --split-spot --split-files --outdir "$chunk_dir" "$run"; then
            echo "fastq-dump successful for $run."
            break # Exit the loop if command is successful
        else
            echo "fastq-dump failed for $run, retrying in 10 seconds..."
            sleep 10
        fi
        attempt=$((attempt + 1))
    done

    # Check if fastq-dump failed after 5 attempts
    if [ $attempt -gt 3 ]; then
        echo "Error: fastq-dump failed after 3 attempts for $run."
        return 1 # Or continue to the next record as per your requirement
    fi

    # Collect the filenames generated
    local files=$(ls $chunk_dir | grep $run | tr '\n' ';')
    
    # Check if $files is empty and throw error if true
    if [ -z "$files" ]; then
        echo "Error: No files were generated for $run. Skipping"
    else
        echo "$label,$run,${files%;}" >> "$chunk_dir/chunk_data.csv"
    fi

}
export -f process_record

#Function to run varKoder
process_chunk() {
    local temp_dir=$1
    local last_chunk_timestamp=$2

    # Construct the varKoder command
    varKoder_command="varKoder image --seed $last_chunk_timestamp -k 7 -m 500K -M 20M --trim-bp 10,10 -n 20 -c 2 -o ./varKodes/chunk_$last_chunk_timestamp/ \"$temp_dir/chunk_data.csv\""

    if [[ $(wc -l < "$temp_dir/chunk_data.csv") -ge 2 ]]; then
        # Create a temporary file for stderr redirection
        temp_stderr=$(mktemp)
        
        # Log the start of the varKoder command execution
        echo "varKoder STARTING ASYNCHRONOUSLY:" "$varKoder_command"
        
        # Execute the varKoder command, redirecting stderr to the temporary file
        if eval "$varKoder_command" 2>"$temp_stderr"; then
            # If varKoder succeeds, delete temporary files and directories
	    cat "$temp_stderr" >&2
            echo "varKoder completed successfully."
            rm -rf /tmp/barcoding*
        else
            # If varKoder fails, output the error
            echo "Error: varKoder failed to execute successfully."
            echo "Failed command: $varKoder_command"
            cat "$temp_stderr" >&2
	    rm "$temp_stderr"
            return
        fi
        
        # Remove the temporary stderr file
        rm "$temp_stderr"
    else
        echo "No samples to process in this chunk"
    fi
    rm -rf "$temp_dir"
}

# Generate list of run IDs already processed
export RUN_ID_LIST= 
generate_run_id_list

# Read the CSV header and find column indices
#read -r header_line < "$csv_file"
run_index=1 #$(find_column_index "$header_line" "Run")
ave_spots_index=3 #$(find_column_index "$header_line" "AveSpotsTo20Mbp")
label_index=4 #$(find_column_index "$header_line" "labels")
max_spots_index=2 #$(find_column_index "$header_line" "spots")


# Read CSV in chunks
chunk_size=1000  # Number of SRA records to process in each varKoder run
chunk_number=0
record_count=0
while IFS= read -r line; do
    #echo $(date +"%Y-%m-%d %H:%M:%S")
    # Increment record_count for every line including the header
    ((record_count++))

    # Skip header
    if [ $record_count -eq 1 ]; then
        continue
    fi

    # Split line into columns
    run=$(echo "$line" | cut -d',' -f$run_index)
    ave_spots=$(echo "$line" | cut -d',' -f$ave_spots_index)
    label=$(echo "$line" | cut -d',' -f$label_index)
    label="${label// /_}"
    max_spots=$(echo "$line" | cut -d',' -f$max_spots_index)

    last_chunk_timestamp=$(date "+%Y%m%d%H%M")
    # Check if new chunk should be started
    if (( (record_count - 1) % chunk_size == 1 )); then
        if [[ -n "$temp_dir" ]]; then
		process_chunk "$temp_dir" "$last_chunk_timestamp" &
		sleep 5
        fi
        ((chunk_number++))
        temp_dir="tmp_$chunk_number"
        mkdir -p "$temp_dir"
        # Add the header to the new temporary CSV file
        echo "labels,sample,files" > "$temp_dir/chunk_data.csv"
        echo "Processing chunk $chunk_number"
    fi

    # Process record
    timeout --kill-after=10s 300s bash -c 'process_record "$1" "$2" "$3" "$4" "$5"' _ "$run" "$ave_spots" "$label" "$temp_dir" "$max_spots"
    echo "Records processed:" $(( $record_count - 1 ))

done < "$csv_file"

# Process the last chunk if it has records and was not processed
if [[ -n "$temp_dir" ]]; then
    varKoder image -k 7 -m 500K -M 20M --trim-bp 10,10 -n 20 -c 2 -o ./varKodes/chunk_$last_chunk_timestamp "$temp_dir/chunk_data.csv"
    rm -f stats.csv
    rm -rf "$temp_dir"
fi

echo "Processing completed."
cleanup() {
	    rm -f "$RUN_ID_FILE"
    }

# At the start of your script or before you exit
trap cleanup EXIT


