import csv

# Open the input and output files
with open('normalized_predictions.csv', 'r') as input_file, open('binary_predictions.csv', 'w', newline='') as output_file:
    # Create CSV reader and writer objects
    reader = csv.DictReader(input_file)
    writer = csv.DictWriter(output_file, fieldnames=['ID'] + reader.fieldnames[2:])
    
    # Write the header row to the output file
    writer.writeheader()
    
    # Sort the input rows by Real affinity
    sorted_rows = sorted(reader, key=lambda x: float(x['Real affinity']))
    
    # Loop through each row in the sorted input rows
    for row in sorted_rows:
        # Create a new row for the output file
        output_row = {'ID': row['ID']}
        
        # Loop through each scoring function column in the input file
        for column in reader.fieldnames[2:]:
            # If the MLSF score is higher than the real affinity, set the output value to 1, otherwise 0
            output_row[column] = 1 if float(row[column]) > float(row['Real affinity']) else 0
        
        # Write the output row to the output file
        writer.writerow(output_row)
