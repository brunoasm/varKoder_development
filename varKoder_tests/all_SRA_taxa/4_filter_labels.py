import pandas as pd, csv, random

# Set options to display all rows and columns
pd.set_option('display.max_rows', None)  # None means show all rows
pd.set_option('display.max_columns', None)  # None means show all columns
pd.set_option('display.width', None)  # Use to set the display width for columns
pd.set_option('display.max_colwidth', None)  # Display full width of each column


def process_csv(file_path, output_file_path, seed=2456):
    # Set random seed
    random.seed(seed)

    # Load the CSV file
    df = pd.read_csv(file_path, low_memory = False)

    # Step 1: Unpack the column labels as a list of strings for each sample
    df['labels'] = df['labels'].apply(lambda x: x.split(';'))

    # Step 2: Create a new boolean column named "is_valid"
    valid_indices = random.sample(range(len(df)), k=int(0.1 * len(df)))
    df['is_valid'] = False
    df.loc[valid_indices, 'is_valid'] = True

    # Step 3: Count labels for samples with False in "is_valid"
    label_count = {}
    for labels in df[df['is_valid'] == False]['labels']:
        for label in labels:
            if label in label_count:
                label_count[label] += 1
            else:
                label_count[label] = 1

    # Step 4: Remove labels that do not reach a count of 3
    df['labels'] = df['labels'].apply(lambda labels: [label for label in labels if label_count.get(label, 0) >= 3])

    # Step 5: Remove records with empty label lists
    initial_record_count = len(df)
    df = df[df['labels'].map(len) > 0]
    records_dropped = initial_record_count - len(df)

    # Reconstruct labels column
    df['labels'] = df['labels'].apply(lambda x: ';'.join(sorted([y.replace(',','_') for y in x])))

    # Outputting the new CSV file
    df.to_csv(output_file_path, 
              columns=['Run','spots','AveSpotsTo20Mbp', 'labels','is_valid'], 
              index=False,
              quoting = csv.QUOTE_NONE
              )

    return records_dropped, df

def summarize_labels(df):
    # Separate counts for valid and train sets
    label_count_valid = {}
    label_count_train = {}

    for index, row in df.iterrows():
        for label in row['labels'].split(';'):
            if row['is_valid']:
                label_count_valid[label] = label_count_valid.get(label, 0) + 1
            else:
                label_count_train[label] = label_count_train.get(label, 0) + 1

    # Summarize label counts for valid and train sets
    def summarize_counts(label_counts):
        summary = {}
        for count in label_counts.values():
            summary[count] = summary.get(count, 0) + 1
        return summary

    summary_valid = summarize_counts(label_count_valid)
    summary_train = summarize_counts(label_count_train)

    summary_train = pd.DataFrame.from_dict(summary_train, orient='index', columns=['N_records'])
    summary_train.index.name = 'Label Count'

    max_index = summary_train.index.max()

    bins = list(range(0,10,1)) + list(range(10, 100, 10)) + list(range(100, 1000, 100)) + list(range(1000, 10000, 1000)) + [10000, df.index.max() + 1]

    summary_train['Slice'] = pd.cut(summary_train.index, bins, right=True,include_lowest=True)
    summary_train = summary_train.groupby("Slice").sum()

    return summary_train

def summarize_keys(df):
    label_key_count = {}
    for index, row in df.iterrows():
        seen_keys = []
        for label in row['labels'].split(';'):
            key = label.split(':')[0]
            if key in seen_keys:
                continue
            else:
                seen_keys.append(key)
            if key in label_key_count:
                if row['is_valid']:
                    label_key_count[key]['valid'] += 1
                else:
                    label_key_count[key]['train'] += 1
            else:
                label_key_count[key] = {'valid': 1 if row['is_valid'] else 0, 'train': 0 if row['is_valid'] else 1}
    return pd.DataFrame.from_dict(label_key_count, orient='index')




file_path = 'accessions_to_download.csv'
output_file_path = 'train_valid_sets.csv'
records_dropped, processed_df = process_csv(file_path, output_file_path)
label_summary = summarize_labels(processed_df)
keys_summary = summarize_keys(processed_df)

# Print summary
print(f"Records dropped: {records_dropped}")
print("Label frequencies in training set:")
print(label_summary)
print("Label key frequencies in training and validation sets:")
print(keys_summary)
