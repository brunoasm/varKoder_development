#!/usr/bin/env bash
set -e

varKoder image --kmer-mapping cgr -k 7 -o cgr_Cora Cora.csv -v &

pid=$!

# Create a log file in the home directory
logfile=$(mktemp ~/memory.log.XXXX)
start=$(date +%s)

# Function to clean up in case of an error
cleanup() {
    if [[ -n "$logfile" ]]; then
        rm -f "$logfile"
    fi
    exit 1
}

# Trap errors to clean up
trap cleanup ERR

# Get the process' memory usage and run until `ps` fails, which it will do when the PID cannot be found any longer
while mem=$(ps -o rss= -p "$pid" 2>/dev/null); do
    time=$(date +%s)

    # Print the time since starting the program followed by its memory usage
    printf "%d %s\n" $((time-start)) "$mem" >> "$logfile"

    # Sleep for a tenth of a second
    sleep .1
done

# Check if the log file has contents before printing the path
if [[ -s "$logfile" ]]; then
    printf "Find the log at %s\n" "$logfile"
else
    printf "No memory usage was recorded. Process might have terminated immediately.\n"
    rm -f "$logfile"
fi
