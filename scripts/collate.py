import os

# Define the names of the files to search for
file_names = ['scorch_ffnn.py.log', 'scorch_wd.py.log', 'scorch_xgbt.py.log']

# Define an empty list to store the scores
scores = []

# Loop over the subdirectories
for dir_name in os.listdir():
    # Check if the item is a directory
    if os.path.isdir(dir_name):
        # Define a dictionary to store the scores for this directory
        dir_scores = {}
        # Loop over the file names
        for file_name in file_names:
            # Construct the path to the log file
            log_file = os.path.join(dir_name, file_name)
            # Check if the file exists
            if os.path.exists(log_file):
                # Open the file
                with open(log_file, 'r') as f:
                    # Read the lines of the file into a list
                    lines = f.readlines()
                    # Extract the second last value of the bottom line
                    score = lines[-1].strip().split(',')[-2]
                    # Add the score to the dictionary with the file name as key
                    dir_scores[file_name] = score
        # Add the directory name and scores to the list of scores
        scores.append([dir_name] + [dir_scores.get(file_name, '') for file_name in file_names])

# Write the collated scores to a CSV file
with open('collated_scores.csv', 'w') as f:
    # Write the header row
    f.write('Directory name, ffnn score, wd score, xgbt score\n')
    # Write the scores for each directory
    for row in scores:
        f.write(','.join(row) + '\n')
