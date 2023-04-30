import os
import csv

# Create a list of directories in the current folder
directories = [d for d in os.listdir('.') if os.path.isdir(d)]

# Open the output CSV file for writing
with open('constituents.csv', 'w', newline='') as csvfile:
    # Define the column names for the CSV
    fieldnames = ['ID'] + [f'ffnn_{i}' for i in range(1, 16)] + \
                 [f'wd_{i}' for i in range(1, 16)]

    # Create a CSV writer object
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    # Write the header row to the CSV
    writer.writeheader()

    # Loop through each directory
    for directory in directories:
        # Check if the directory contains the required files
        ffnn_file = os.path.join(directory, 'ffnn_15.txt')
        wd_file = os.path.join(directory, 'wd_15.txt')
        if os.path.isfile(ffnn_file) and os.path.isfile(wd_file):
            # Open the ffnn_15.txt file and extract the scores
            with open(ffnn_file, 'r') as f:
                ffnn_scores = [float(line.strip()[2:-2]) for line in f if line.startswith("[[")] 

            # Open the wd_15.txt file and extract the scores
            with open(wd_file, 'r') as f:
                wd_scores = [float(line.strip()[2:-2]) for line in f if line.startswith("[[")]

            # Create a dictionary containing the ID and scores for this directory
            data = {'ID': directory}
            for i in range(1, 16):
                data[f'ffnn_{i}'] = ffnn_scores[i-1]
                data[f'wd_{i}'] = wd_scores[i-1]

            # Write the data to the CSV
            writer.writerow(data)
