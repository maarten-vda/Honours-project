import csv

# Open the three log files
ffnn_file = open("ffnn_15.log", "r")
autoencoder_3_file = open("autoencoder_3.log", "r")
autoencoder_15_file = open("autoencoder_15.log", "r")

# Extract the second last number in the last line of each file
ffnn_score = ffnn_file.readlines()[-1].split(",")[-2]
autoencoder_3_score = autoencoder_3_file.readlines()[-1].split(",")[-2]
autoencoder_15_score = autoencoder_15_file.readlines()[-1].split(",")[-2]

# Close the log files
ffnn_file.close()
autoencoder_3_file.close()
autoencoder_15_file.close()

# Write the scores to a new CSV file with rows and columns flipped
with open("new_predictions.csv", "w", newline="") as csv_file:
    writer = csv.writer(csv_file)
    writer.writerow(["Model", "ffnn_15", "autoencoder_3", "autoencoder_15"])
    writer.writerow(["Score", ffnn_score, autoencoder_3_score, autoencoder_15_score])
