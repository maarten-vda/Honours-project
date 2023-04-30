import pandas as pd
import matplotlib.pyplot as plt

# Read in predictions.csv
df = pd.read_csv('predictions.csv')

# Define the enrichment factors to plot
enrichment_factors = [0.5, 1, 2, 5]

# Define the scoring functions to plot
scoring_functions = ['SCORCH', 'SCORCH_WD', 'SCORCH_FFNN', 'SCORCH_XGBT', 'SCORCH_ML',
                     'drugscore', 'nnscore1', 'nnscore2', 'xscore1.3', 'rfscore-4', 'rfscore-vs2']

# Define the colors to use for each scoring function
colors = {'SCORCH': 'tab:blue', 'SCORCH_WD': 'tab:orange', 'SCORCH_FFNN': 'tab:green',
          'SCORCH_XGBT': 'tab:red', 'SCORCH_ML': 'tab:purple', 'drugscore': 'tab:brown',
          'nnscore1': 'tab:pink', 'nnscore2': 'tab:gray', 'xscore1.3': 'tab:olive',
          'rfscore-4': 'tab:cyan', 'rfscore-vs2': 'tab:purple'}

# Loop over the enrichment factors and create a separate plot for each one
for ef in range(len(enrichment_factors)):
    # Subtract 1 from the index to get the correct enrichment factor
    enrichment_factor = enrichment_factors[ef]
    # Create a dictionary to store the data for each scoring function
    data = {}
    for scoring_function in scoring_functions:
        # Extract the data for the current scoring function
        ef_col = f'EF{ef+1}' # Subtract 1 from the index to get the correct EF column
        scores = df[scoring_function]
        labels = df['Real affinity']
        
        # Compute the enrichment factor for the current scoring function
        num_actives = sum(labels <= 0)
        print(num_actives)
        num_total = len(labels)
        sorted_scores = sorted(zip(scores, labels), reverse=True)
        num_hits = sum([x[1] <= 0 for x in sorted_scores[:int(num_total * enrichment_factor / 100)]])
        if num_actives == 0:
            enrichment_factor_value = 0
        else:
            enrichment_factor_value = num_hits / num_actives / (enrichment_factor / 100)
                
        # Add the enrichment factor to the data dictionary
        if scoring_function in data:
            data[scoring_function].append(enrichment_factor_value)
        else:
            data[scoring_function] = [enrichment_factor_value]
    
    # Create a list of the scores for each scoring function
    score_lists = [data[scoring_function] for scoring_function in scoring_functions]
    
    # Create the box and whisker plot
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.boxplot(score_lists, showmeans=True, meanprops={"markerfacecolor": "black", "marker": "D"})
    
    # Set the x-axis labels and the title
    ax.set_xticklabels(scoring_functions, rotation=45)
    ax.set_xlabel('Scoring Functions')
    ax.set_ylabel('Enrichment Factor @ ' + str(enrichment_factor) + '%')
    ax.set_title('Enrichment Factor Box and Whisker Plot @ ' + str(enrichment_factor) + '%')
    
    # Set the colors for the boxes and whiskers
    for i, box in enumerate(ax.artists):
        box.set_edgecolor(colors[scoring_functions[i]])
        box.set_facecolor(colors[scoring_functions[i]])
    # Save the figure as a png file
    fig.savefig('enrichment_factor_boxplot_' + str(enrichment_factor) + '.png', dpi=300, bbox_inches='tight')
