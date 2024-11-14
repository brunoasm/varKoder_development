import os
import re
import pandas as pd
from datetime import datetime
import glob

def extract_chunk_id_from_path(line):
    """Extract chunk ID from varKoder output path"""
    match = re.search(r'chunk_(\d+)', line)
    if match:
        return match.group(1)
    return None

def analyze_varkoder_runs(filepath):
    """Analyze varKoder runs in a single log file"""
    chunk_data = []
    
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        
        # Look for varKoder start
        if 'varKoder STARTING ASYNCHRONOUSLY:' in line:
            # Get chunk ID from output path
            chunk_id = extract_chunk_id_from_path(line)
            if chunk_id and i > 0:  # Ensure we have a previous line for timestamp
                try:
                    start_time = datetime.strptime(lines[i-1].strip(), '%Y-%m-%d %H:%M:%S')
                    started_samples = set()
                    completed_samples = set()
                    
                    # Look ahead for samples and completion
                    look_ahead = i + 1
                    end_time = None
                    
                    while look_ahead < len(lines):
                        next_line = lines[look_ahead].strip()
                        
                        # Check for next varKoder start (indicating this one didn't complete)
                        if 'varKoder STARTING ASYNCHRONOUSLY:' in next_line:
                            break
                        
                        # Track samples
                        if 'Finding and concatenating files for' in next_line:
                            accession = next_line.split()[-1]
                            started_samples.add(accession)
                        
                        elif 'Images done for' in next_line:
                            accession = next_line.split()[-1]
                            completed_samples.add(accession)
                        
                        # Check for completion
                        elif 'DONE' in next_line:
                            # Look ahead for next timestamp
                            time_look_ahead = look_ahead + 1
                            while time_look_ahead < len(lines):
                                try:
                                    end_time = datetime.strptime(lines[time_look_ahead].strip(), 
                                                               '%Y-%m-%d %H:%M:%S')
                                    break
                                except ValueError:
                                    time_look_ahead += 1
                            break
                        
                        look_ahead += 1
                    
                    # Only record if we found both start and end times
                    if end_time:
                        duration = (end_time - start_time).total_seconds()
                        chunk_data.append({
                            'chunk_id': chunk_id,
                            'output_file': os.path.basename(filepath),
                            'start_time': start_time,
                            'end_time': end_time,
                            'duration_seconds': duration,
                            'samples_started': len(started_samples),
                            'samples_completed': len(completed_samples),
                            'completion_rate': len(completed_samples) / len(started_samples) if started_samples else 0
                        })
                
                except ValueError:
                    pass  # Skip if timestamp parsing fails
        
        i += 1
    
    return chunk_data

def main():
    os.makedirs('computing_resources', exist_ok=True)
    
    all_chunk_data = []
    
    for logfile in sorted(glob.glob('5_*.out')):
        print(f"Processing {logfile}...")
        chunk_data = analyze_varkoder_runs(logfile)
        all_chunk_data.extend(chunk_data)
        print(f"Found {len(chunk_data)} complete varKoder runs in {logfile}")
    
    # Create DataFrame
    chunk_df = pd.DataFrame(all_chunk_data)
    
    # Sort DataFrame
    if not chunk_df.empty:
        chunk_df = chunk_df.sort_values(['output_file', 'chunk_id', 'start_time'])
    
    # Save to CSV file
    chunk_df.to_csv('computing_resources/varkoder_runs_summary.csv', index=False)
    
    # Print summary
    print("\nFinal Summary:")
    print(f"Total complete varKoder runs: {len(chunk_df) if not chunk_df.empty else 0}")
    
    if not chunk_df.empty:
        print("\nRuns by output file:")
        print(chunk_df.groupby('output_file').size())
        
        print("\nSummary statistics for durations (seconds):")
        print(chunk_df['duration_seconds'].describe())
        
        print("\nAverage completion rates by output file:")
        print(chunk_df.groupby('output_file')['completion_rate'].mean())
        
        print("\nTotal samples started and completed by output file:")
        summary = chunk_df.groupby('output_file').agg({
            'samples_started': 'sum',
            'samples_completed': 'sum'
        })
        print(summary)

if __name__ == "__main__":
    main()
