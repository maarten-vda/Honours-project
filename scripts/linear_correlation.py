import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import spearmanr, pearsonr

# Load the merged_predictions.csv file
df = pd.read_csv('merged_predictions.csv')

# Extract the columns of interest
real_affinity = df['Real affinity']
scorch_ml = df['SCORCH_ML']
ffnn_15 = df['ffnn_15']
autoencoder_3 = df['autoencoder_3']
autoencoder_15 = df['autoencoder_15']

# Create the scatter plot with opaque points
plt.scatter(real_affinity, scorch_ml, label='Model_A', alpha=0.2)
plt.scatter(real_affinity, ffnn_15, label='Model_B', alpha=0.1)
plt.scatter(real_affinity, autoencoder_3, label='Model_C', alpha=0.2)
plt.scatter(real_affinity, autoencoder_15, label='Model_D', alpha=0.2)

# Calculate the regression lines and print the regression equation, R squared, Spearman's rank, and Pearson's correlation coefficient for each line
z = np.polyfit(real_affinity, scorch_ml, 1)
p = np.poly1d(z)
plt.plot(real_affinity,p(real_affinity),"b-")
print('SCORCH_ML: y = %.3f x + %.3f' % (z[0], z[1]))
r2 = np.corrcoef(real_affinity, scorch_ml)[0,1]**2
print('R squared: %.3f' % r2)
spearman_rank = spearmanr(real_affinity, scorch_ml)[0]
print('Spearman\'s rank: %.3f' % spearman_rank)
pearsons_coef = pearsonr(real_affinity, scorch_ml)[0]
print('Pearson\'s correlation coefficient: %.3f' % pearsons_coef)

z = np.polyfit(real_affinity, ffnn_15, 1)
p = np.poly1d(z)
plt.plot(real_affinity,p(real_affinity),"y-")
print('ffnn_15: y = %.3f x + %.3f' % (z[0], z[1]))
r2 = np.corrcoef(real_affinity, ffnn_15)[0,1]**2
print('R squared: %.3f' % r2)
spearman_rank = spearmanr(real_affinity, ffnn_15)[0]
print('Spearman\'s rank: %.3f' % spearman_rank)
pearsons_coef = pearsonr(real_affinity, ffnn_15)[0]
print('Pearson\'s correlation coefficient: %.3f' % pearsons_coef)

z = np.polyfit(real_affinity, autoencoder_3, 1)
p = np.poly1d(z)
plt.plot(real_affinity,p(real_affinity),"g-")
print('autoencoder_3: y = %.3f x + %.3f' % (z[0], z[1]))
r2 = np.corrcoef(real_affinity, ffnn_15)[0,1]**2
print('R squared: %.3f' % r2)
spearman_rank = spearmanr(real_affinity, autoencoder_3)[0]
print('Spearman\'s rank: %.3f' % spearman_rank)
pearsons_coef = pearsonr(real_affinity, autoencoder_3)[0]
print('Pearson\'s correlation coefficient: %.3f' % pearsons_coef)

z = np.polyfit(real_affinity, autoencoder_15, 1)
p = np.poly1d(z)
plt.plot(real_affinity,p(real_affinity),"r-")
print('autoencoder_15: y = %.3f x + %.3f' % (z[0], z[1]))
r2 = np.corrcoef(real_affinity, ffnn_15)[0,1]**2
print('R squared: %.3f' % r2)
spearman_rank = spearmanr(real_affinity, autoencoder_15)[0]
print('Spearman\'s rank: %.3f' % spearman_rank)
pearsons_coef = pearsonr(real_affinity, autoencoder_15)[0]
print('Pearson\'s correlation coefficient: %.3f' % pearsons_coef)

# Add labels and legend
plt.xlabel('Real affinity (nM)')
plt.ylabel('Predicted affinity (nM)')
plt.legend(loc='center left', bbox_to_anchor=(1.0, 0.5))

# Save the plot as a PNG file
plt.savefig('affinity_scatterplot.png', bbox_inches='tight')

# Show the plot
plt.show()
