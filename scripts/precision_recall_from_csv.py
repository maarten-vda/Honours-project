import pandas as pd
from sklearn.metrics import precision_recall_curve
import matplotlib.pyplot as plt

# Load data from file
data = pd.read_csv('merged_predictions.csv')

# Define the threshold values to test
thresholds = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]

# Define the names of the scoring functions
score_names = ['SCORCH','SCORCH_WD','SCORCH_FFNN','SCORCH_XGBT','SCORCH_ML','ffnn_15','autoencoder_3','autoencoder_15','drugscore','nnscore1','nnscore2','xscore1.3','rfscore-4','rfscore-vs2']

# Define the mapping of original names to desired names
name_map = {'SCORCH_ML': 'Model_A', 'ffnn_15': 'Model_B', 'autoencoder_3': 'Model_C', 'autoencoder_15': 'Model_D'}

# Convert real affinity values to binary labels
y_true = (data['Real affinity'] >= thresholds[-1]).astype(int)

# Get scores from different models
scores = data[score_names].values

# Calculate precision-recall curve for each model at different thresholds
precision = dict()
recall = dict()
for i in range(scores.shape[1]):
    precision[i] = []
    recall[i] = []
    for threshold in thresholds:
        y = (data['Real affinity'] >= threshold).astype(int)
        p, r, _ = precision_recall_curve(y, scores[:, i])
        precision[i].append(p)
        recall[i].append(r)

# Plot the precision-recall curves as a 2D plot for each threshold value

colors = ['#FCD0A1', '#A4E4B4', '#B4A4E4', '#E4A4D9', '#D9E4A4', '#A4BFE4', '#E4A4A4', '#A4E4C9', '#E4C9A4', '#C9A4E4', '#A4E4E4', '#E4A4B4', '#E4E4A4', '#A4A4E4']

for j, threshold in enumerate(thresholds):
    fig = plt.figure()
    ax = fig.gca()
    ax.set_xlabel('Recall')
    ax.set_ylabel('Precision')
    ax.set_xlim([0.0, 1.0])
    ax.set_ylim([0.0, 1.0])
    ax.set_title(f'Precision-Recall curve at threshold {threshold}')
    for i in range(scores.shape[1]):
        linestyle = ':' if score_names[i] in ['drugscore', 'nnscore1', 'nnscore2', 'xscore1.3', 'rfscore-4', 'rfscore-vs2'] else '--' if score_names[i] in ['SCORCH', 'SCORCH_WD', 'SCORCH_FFNN', 'SCORCH_XGBT'] else '-'
        label = name_map.get(score_names[i], score_names[i])
        if label in ['Model_A', 'Model_B', 'Model_C', 'Model_D']:
            color = ['red', 'blue', 'green', 'purple'][['Model_A', 'Model_B', 'Model_C', 'Model_D'].index(label)]
            ax.plot(recall[i][j], precision[i][j], linestyle=linestyle, label=label, alpha=1.0, color=color)
        else:
            ax.plot(recall[i][j], precision[i][j], linestyle=linestyle, label=label, alpha=1.0, color=colors[i])
    ax.legend(loc='center left', bbox_to_anchor=(1.0, 0.5))
    plt.savefig(f'precision_recall_{threshold}.png', bbox_inches='tight')
    plt.close()


