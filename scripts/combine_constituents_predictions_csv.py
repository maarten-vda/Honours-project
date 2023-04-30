import csv

# Open the two input CSV files
with open('predictions.csv', 'r') as predictions_file, \
     open('constituents.csv', 'r') as constituents_file:

    # Read the contents of each CSV file into separate lists
    predictions_reader = csv.DictReader(predictions_file)
    predictions = [row for row in predictions_reader]

    constituents_reader = csv.DictReader(constituents_file)
    constituents = [row for row in constituents_reader]

# Create a new CSV file for output
with open('constituent_predictions.csv', 'w', newline='') as combined_file:

    # Define the fieldnames for the output CSV file
    fieldnames = ['ID', 'Real affinity', 'ffnn_1', 'ffnn_2', 'ffnn_3', 'ffnn_4', 'ffnn_5', 'ffnn_6', 'ffnn_7', 'ffnn_8', 'ffnn_9', 'ffnn_10', 'ffnn_11', 'ffnn_12', 'ffnn_13', 'ffnn_14', 'ffnn_15', 'wd_1', 'wd_2', 'wd_3', 'wd_4', 'wd_5', 'wd_6', 'wd_7', 'wd_8', 'wd_9', 'wd_10', 'wd_11', 'wd_12', 'wd_13', 'wd_14', 'wd_15', 'SCORCH_XGBT']

    # Create a DictWriter object for writing rows to the output CSV file
    writer = csv.DictWriter(combined_file, fieldnames=fieldnames)

    # Write the header row to the output CSV file
    writer.writeheader()

    # Iterate over each row in the predictions list
    for prediction in predictions:

        # Look up the corresponding row in the constituents list using the ID column
        constituent = next((c for c in constituents if c['ID'] == prediction['ID']), None)

        # If a corresponding constituent row was found, combine it with the prediction row
        if constituent:

            # Create a new dictionary representing the combined row
            combined_row = {'ID': prediction['ID'],
                            'Real affinity': prediction['Real affinity'],
                            'SCORCH_XGBT': prediction['SCORCH_XGBT']}

            # Add the ffnn and wd columns from the constituent row to the combined row
            combined_row.update({f'ffnn_{i}': constituent[f'ffnn_{i}'] for i in range(1, 16)})
            combined_row.update({f'wd_{i}': constituent[f'wd_{i}'] for i in range(1, 16)})

            # Write the combined row to the output CSV file
            writer.writerow(combined_row)
