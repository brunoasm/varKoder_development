#This script was used to concatenate all plastid and ITS assemblies into one sequence to generate iDELUCS clusters

import os,sys
from Bio import SeqIO

# Define the directory containing the FASTA files
suffix = sys.argv[1]
output_file = sys.argv[2]

# Find all FASTA files ending with ".5m.assembly.fas"
fasta_files = [f for f in os.listdir('.') if f.endswith(suffix)]

# Sort the files to ensure they are processed in order
fasta_files.sort()

# Open the output file for writing
with open(output_file, 'w') as output_handle:
    for fasta_file in fasta_files:
        # Extract the base name without the ".5m.assembly.fas" suffix
        base_name = os.path.splitext(fasta_file)[0]
        new_name = base_name.split('.')[0]
        
        # Initialize an empty sequence
        concatenated_sequence = ''
        
        # Read the sequences from the current FASTA file and concatenate them
        for record in SeqIO.parse(fasta_file, 'fasta'):
            concatenated_sequence += str(record.seq)
        
        # Write the concatenated sequence to the output file with the new name
        output_handle.write(f'>{new_name}\n{concatenated_sequence}\n')
        
print(f'Successfully merged {len(fasta_files)} FASTA files into {output_file}')