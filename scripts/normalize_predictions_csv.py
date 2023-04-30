import pandas as pd

# read the predictions.csv file
df = pd.read_csv('merged_predictions.csv')

# select the columns to be normalized
cols_to_normalize = ['Real affinity', 'SCORCH', 'SCORCH_WD', 'SCORCH_FFNN', 'SCORCH_XGBT', 'SCORCH_ML', 'drugscore', 'nnscore1', 'nnscore2', 'xscore1.3', 'rfscore-4', 'rfscore-vs2', 'SCORCH_ML','ffnn_15','autoencoder_3','autoencoder_15']

# normalize the selected columns if they are not already normalized
for col in cols_to_normalize:
    if not all(df[col].between(0, 1)):
        df[col] = (df[col] - df[col].min()) / (df[col].max() - df[col].min())

# save the normalized dataframe to a new csv file
df.to_csv('normalized_predictions.csv', index=False)
