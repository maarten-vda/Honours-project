import csv

# read in the csv file
with open('collated_scores.csv') as csv_file:
    csv_reader = csv.reader(csv_file)
    next(csv_reader) # skip the header row
    scores_dict = {row[0]: row[1:] for row in csv_reader}

# read in the text file and append affinity values to scores_dict
with open('realaffinities_sorted.txt') as txt_file:
    for line in txt_file:
        protein_ligand, affinity = line.strip().split()
        scores_dict[protein_ligand].append(affinity)

# write out the combined scores to a new csv file
with open('combined_scores.csv', mode='w', newline='') as combined_file:
    writer = csv.writer(combined_file)
    writer.writerow(['Directory name', 'ffnn score', 'wd score', 'xgbt score', 'actual affinity'])
    for key, values in scores_dict.items():
        writer.writerow([key] + values)
