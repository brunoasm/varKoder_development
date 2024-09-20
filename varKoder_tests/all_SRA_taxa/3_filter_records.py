import pandas as pd
import numpy as np

pd.set_option('display.max_rows', None) 

# Randomly select up to 20 records for each combination of TaxID, LibraryStrategy, Platform, LibrarySelection
def sample_group(group):
    n_samples = min(len(group), 20)
    return group.sample(n=n_samples, random_state=1)

# prepend taxonomy_ to taxlabels:
# def transform_taxlabels(value):
#     if pd.isna(value) or value == '':
#         return value  # Returns the original value if it's NaN or an empty string
#     pairs = value.split(';')
#     transformed_pairs = []
#     for pair in pairs:
#         parts = pair.split(':', 1)  # Split at the first colon only
#         if len(parts) == 2:
#             key, val = parts
#             val = val.split(':')[0]  # Take only the substring up to the first colon in the value
#             transformed_pair = key + ':' + val
#             transformed_pairs.append(transformed_pair)
#         else:
#             print("Input causing error:", pair)
#             raise ValueError("Expected key-value pair separated by ':', but got: " + pair)
#     return ';'.join(transformed_pairs)


# Read the Parquet file
df = pd.read_parquet('all_SRA_records.parquet')
print(f"Initial record count: {len(df)}")

# Filter records with no taxonomic information
df = df[df['TaxLabels'].notna() & (df['TaxLabels'] != '')]
#df['TaxLabels'] = df['TaxLabels'].apply(transform_taxlabels)
print(f"Records after TaxLabels filter: {len(df)}")

# Filter based on LibraryStrategy
library_strategies = ['GBS', 'RAD-Seq', 'WGS']
df = df[df['LibraryStrategy'].isin(library_strategies)]
print(f"Records after LibraryStrategy filter: {len(df)}")

# Filter where LibrarySelection is not empty, NA, other, or OTHER
#df = df[~df['LibrarySelection'].isin(['', 'NA', 'other', 'OTHER','unspecified'])]
#print(f"Records after LibrarySelection filter: {len(df)}")

# Filter based on Platform
platforms = ['ILLUMINA', 'OXFORD_NANOPORE', 'PACBIO_SMRT', 'BGISEQ']
df = df[df['Platform'].isin(platforms)]
print(f"Records after Platform filter: {len(df)}")

# Filter where SampleType is simple and Bases are larger than 50 million
df = df[(df['SampleType'] == 'simple') & (df['bases'] > 50e6)]
print(f"Records after SampleType and Bases filter: {len(df)}")

# Randomly select only one record for each combination of BioSample, LibraryStrategy, Platform
df = df.groupby(['BioSample', 'LibraryStrategy', 'Platform']).sample(n=1, random_state=1)
print(f"Records after unique BioSample, LibraryStrategy, Platform selection: {len(df)}")

# Randomly select up to 20 records for each combination of TaxID, LibraryStrategy, Platform, LibrarySelection
df = df.groupby(['TaxID', 'LibraryStrategy', 'Platform']).apply(sample_group).reset_index(drop=True)
print(f"Records after sampling up to 20 per TaxID, LibraryStrategy, Platform, LibrarySelection: {len(df)}")

# Calculate the average number of reads to get to 20 million bp
df['AveSpotsTo20Mbp'] = df['spots'] / df['bases'] * 20e6

# Create labels
df['labels']='Platform:' + df['Platform'] + ';LibraryStrategy:' + df['LibraryStrategy'] + ';' + df['TaxLabels']

# Save result to a CSV file
df.to_csv('accessions_to_download.csv', index=False)
print("Results saved to accessions_to_download.csv")

print("Count for each combination of LibraryStrategy, LibrarySelection, Platform:")
print(df[['Platform','LibraryStrategy', 'LibrarySelection']].value_counts().reset_index(drop=False))
print("Most common Tax IDs:")
cts = df['TaxID'].value_counts()
print(cts.head(n=50))
print("Frequency distribution of Tax IDs:")
print(cts.value_counts().sort_index(ascending=True))

