import os
import pandas as pd

# Read in predictions.csv
predictions = pd.read_csv('predictions.csv')

# Create a list of all subdirectories
subdirs = [x[0] for x in os.walk('.') if 'new_predictions.csv' in x[2]]

# Loop through each subdirectory and read in new_predictions.csv
dfs = []
for subdir in subdirs:
    subdir_name = os.path.basename(subdir)
    new_predictions = pd.read_csv(os.path.join(subdir, 'new_predictions.csv'))
    new_predictions['ID'] = subdir_name
    dfs.append(new_predictions)

# Concatenate all dataframes together and merge with predictions.csv
merged = pd.concat(dfs, axis=0).merge(predictions, on='ID')

# Reorder columns
cols = ['ID', 'Real affinity', 'SCORCH', 'SCORCH_WD', 'SCORCH_FFNN', 'SCORCH_XGBT', 'SCORCH_ML',
        'ffnn_15', 'autoencoder_3', 'autoencoder_15', 'drugscore', 'nnscore1', 'nnscore2',
        'xscore1.3', 'rfscore-4', 'rfscore-vs2']
merged = merged[cols]

# Write merged dataframe to output CSV
merged.to_csv('merged_predictions.csv', index=False)
