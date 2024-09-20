#This script reduces the number of columns that we will keep from SRA and 
#saves the table in a more compressible format than csv (parquet)
#we do it in chunks to avoid loading it all in the memory

import pandas as pd
import xml.etree.ElementTree as ET
import gzip

# Open and parse the XML file
with gzip.open('SRA_taxonomy_clean.xml.gz', 'r') as f:
    tree = ET.parse(f)
root = tree.getroot()

# Create a dictionary to hold TaxId to Lineage mapping
taxid_to_lineage = {}

for taxon in root.findall('Taxon'):
    tax_id = taxon.find('TaxId').text
    rank_self = taxon.find('Rank').text.replace(" ", "_").replace(".","_").replace(":","_")
    sci_name_self = taxon.find('ScientificName').text.replace(" ", "_").replace(".","_").replace(":","_")
    lineage_list = [f"Taxonomy_{rank_self}:{tax_id}.{sci_name_self}"]  # Include the self taxon at the beginning
    try:
        for intaxon in taxon.find('LineageEx').findall('Taxon'):
            tax_id_inner = intaxon.find('TaxId').text
            rank = intaxon.find('Rank').text.replace(" ", "_").replace(".","_").replace(":","_")
            sci_name = intaxon.find('ScientificName').text.replace(" ", "_").replace(".","_").replace(":","_")
            lineage_list.append(f"Taxonomy_{rank}:{tax_id_inner}.{sci_name}")
    except:
        print(sci_name_self, rank_self, tax_id,"has no lineage")

    taxid_to_lineage[tax_id] = ";".join(lineage_list)

def get_lineage(tax_id):
        return taxid_to_lineage.get(tax_id, "")

# Define the columns to keep and their types
columns_to_keep = [
    'Run', 'spots', 'bases', 'avgLength', 'size_MB', 'AssemblyName',
    'download_path', 'LibraryName', 'LibraryStrategy', 'LibrarySelection',
    'LibrarySource', 'LibraryLayout', 'InsertSize', 'InsertDev',
    'Platform', 'Model', 'BioSample', 'SampleType', 'TaxID', 'ScientificName'
]

# Columns to read as numeric
numeric_columns = ['spots', 'bases', 'avgLength', 'size_MB', 'InsertSize']

# CSV file path
csv_file = 'SRA_records.csv.gz'

# Read and process the CSV in chunks and store in a list
dataframes = []
for chunk in pd.read_csv(csv_file, chunksize=10000, compression='gzip', usecols=columns_to_keep, dtype={col: str for col in columns_to_keep}):
    # Convert specified columns to numeric, coerce errors to NaN
    for col in numeric_columns:
        chunk[col] = pd.to_numeric(chunk[col], errors='coerce')
    chunk = chunk[~chunk.isin([columns_to_keep]).all(axis=1)]
    chunk['TaxLabels'] = chunk['TaxID'].apply(get_lineage)

    dataframes.append(chunk)

# Concatenate all chunks into a single DataFrame
concatenated_df = pd.concat(dataframes, ignore_index=True)

# Write the concatenated DataFrame to a Parquet file
concatenated_df.to_parquet('all_SRA_records.parquet', index=False, compression='snappy')

