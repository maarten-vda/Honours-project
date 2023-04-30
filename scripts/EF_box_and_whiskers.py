import pandas as pd
import matplotlib.pyplot as plt

# read the normalized_predictions.csv file
df = pd.read_csv('normalized_predictions.csv')

# calculate EF values for each scoring function
ef_values = {}
for col in df.columns[2:]:
    hits = df[df['Real affinity'] >= 0.5][col]
    ef_values[col] = len(hits) / len(df[col])




# plot the EF distribution as a box and whisker diagram
plt.figure(figsize=(12, 8))
plt.boxplot(list(ef_values.values()), vert=False, widths=0.5)
plt.yticks(range(1, len(ef_values)+1), list(ef_values.keys()))
plt.title('EF Distribution for Each Scoring Function')
plt.xlabel('EF')
plt.savefig('ef_distribution.png')
plt.show()
