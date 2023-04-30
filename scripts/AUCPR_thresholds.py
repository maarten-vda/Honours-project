import pandas as pd
from sklearn.metrics import precision_recall_curve, auc
import matplotlib.pyplot as plt
import numpy as np

# Load data from file
data = pd.read_csv('merged_predictions.csv')

# Define the threshold values to test
min_threshold = 0
max_threshold = 10
step_size = 0.1
thresholds = np.arange(min_threshold, max_threshold + step_size, step_size)

# Convert real affinity values to binary labels
y_true = (data['Real affinity'] >= thresholds[-1]).astype(int)

# Get scores from different models
scores = data[['SCORCH','SCORCH_WD','SCORCH_FFNN','SCORCH_XGBT','SCORCH_ML','ffnn_15','autoencoder_3','autoencoder_15','drugscore','nnscore1','nnscore2','xscore1.3','rfscore-4','rfscore-vs2']].values

# Calculate AUCPR for each model at different thresholds
aucpr = dict()
for i in range(scores.shape[1]):
    aucpr[i] = []
    for threshold in thresholds:
        y = (data['Real affinity'] >= threshold).astype(int)
        p, r, t = precision_recall_curve(y, scores[:, i])
        aucpr[i].append(auc(r, p))

# Define the names of each scoring function
scoring_func_names = ['SCORCH','SCORCH_WD','SCORCH_FFNN','SCORCH_XGBT','Model_A','Model_B','Model_C','Model_D','drugscore','nnscore1','nnscore2','xscore1.3','rfscore-4','rfscore-vs2']

# Define a mapping between the original score names and the new labels
name_map = {'SCORCH_ML': 'Model_A', 'ffnn_15': 'Model_B', 'autoencoder_3': 'Model_C', 'autoencoder_15': 'Model_D'}

# Plot the AUCPR vs threshold values for each model
fig, ax = plt.subplots()
for i in range(scores.shape[1]):
    linestyle = ':' if scoring_func_names[i] in ['drugscore', 'nnscore1', 'nnscore2', 'xscore1.3', 'rfscore-4', 'rfscore-vs2'] else '--' if scoring_func_names[i] in ['SCORCH', 'SCORCH_WD', 'SCORCH_FFNN', 'SCORCH_XGBT'] else '-'
    label = name_map.get(scoring_func_names[i], scoring_func_names[i])
    if label in ['Model_A', 'Model_B', 'Model_C', 'Model_D']:
        color = ['red', 'blue', 'green', 'purple'][['Model_A', 'Model_B', 'Model_C', 'Model_D'].index(label)]
        ax.plot(thresholds, aucpr[i], label=label, linestyle=linestyle, color=color)
    else:
        ax.plot(thresholds, aucpr[i], label=label, linestyle=linestyle)
ax.set_xlabel('Threshold value')
ax.set_ylabel('AUCPR')
ax.set_title('AUCPR vs Threshold')
ax.legend(loc='center left', bbox_to_anchor=(1.0, 0.5))
plt.savefig('aucpr_vs_threshold.png', bbox_inches='tight')
plt.show()
