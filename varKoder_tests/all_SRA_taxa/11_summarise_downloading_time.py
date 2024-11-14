import os
import re
import pandas as pd
from datetime import datetime
import glob

def analyze_fastq_dumps(filepath):
    """Analyze fastq-dump operations in a single log file"""
    sample_data = []
    current_chunk = None
    
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        
        # Check for chunk marker
        if 'Processing chunk' in line:
            chunk_match = re.search(r'Processing chunk (\d+)', line)
            if chunk_match:
                current_chunk = int(chunk_match.group(1))
                i += 1
                continue
        
        # Look for fastq-dump attempt
        if 'Attempt' in line and 'to run fastq-dump for' in line:
            # Get accession
            accession = line.split('fastq-dump for')[1].strip('...\n ')
            
            # Get start time from previous line
            if i > 0:
                try:
                    start_time = datetime.strptime(lines[i-1].strip(), '%Y-%m-%d %H:%M:%S')
                except ValueError:
                    i += 1
                    continue
                
                # Look ahead for success message and end time
                look_ahead = i + 1
                while look_ahead < len(lines) and look_ahead < i + 10:  # Limit look-ahead to 10 lines
                    if f'fastq-dump successful for {accession}' in lines[look_ahead]:
                        # Get end time from next line
                        if look_ahead + 1 < len(lines):
                            try:
                                end_time = datetime.strptime(lines[look_ahead+1].strip(), '%Y-%m-%d %H:%M:%S')
                                duration = (end_time - start_time).total_seconds()
                                
                                sample_data.append({
                                    'accession': accession,
                                    'output_file': os.path.basename(filepath),
                                    'chunk': current_chunk,
                                    'start_time': start_time,
                                    'duration_seconds': duration
                                })
                                break
                            except ValueError:
                                pass
                    look_ahead += 1
        
        i += 1
    
    return sample_data

def main():
    os.makedirs('computing_resources', exist_ok=True)
    
    all_sample_data = []
    
    for logfile in sorted(glob.glob('5_*.out')):
        print(f"Processing {logfile}...")
        sample_data = analyze_fastq_dumps(logfile)
        all_sample_data.extend(sample_data)
        print(f"Found {len(sample_data)} fastq-dump operations in {logfile}")
    
    # Create DataFrame
    sample_df = pd.DataFrame(all_sample_data)
    
    # Sort DataFrame
    if not sample_df.empty:
        sample_df = sample_df.sort_values(['output_file', 'chunk', 'start_time'])
    
    # Save to CSV file
    sample_df.to_csv('computing_resources/sample_level_summary.csv', index=False)
    
    # Print summary
    print("\nFinal Summary:")
    print(f"Total fastq-dump operations: {len(sample_df) if not sample_df.empty else 0}")
    
    if not sample_df.empty:
        print("\nOperations by output file:")
        print(sample_df.groupby('output_file').size())
        
        print("\nSummary statistics for durations (seconds):")
        print(sample_df['duration_seconds'].describe())
        
        print("\nNumber of operations by chunk:")
        print(sample_df.groupby(['output_file', 'chunk']).size())

if __name__ == "__main__":
    main()
