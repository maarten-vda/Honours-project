import csv
import os

# Read the combined_scores.csv file
with open('combined_scores.csv') as f:
    reader = csv.reader(f)
    next(reader)  # Skip the header row
    data = [row for row in reader]

# Create a dictionary to hold the data
predictions = {}

# Process the data
for row in data:
    id = row[0]
    ffnn, wd, xgbt = map(float, row[1:-1])
    actual_affinity = float(row[-1])
    scorch = sum([ffnn, wd, xgbt]) / 3
    scores_file = f'{id}/scores.txt'
    if not os.path.isfile(scores_file):
        # If scores.txt does not exist for this ID, skip it
        continue
    with open(scores_file) as f:
        scores_data = f.read()
        drugscore = float(scores_data.split('DSX score: ')[1].split('\n')[0]) if 'DSX score: ' in scores_data else 0
        nnscore1 = float(scores_data.split('nnscore: ')[1].split('\n')[0]) if 'nnscore: ' in scores_data else 0
        nnscore2 = float(scores_data.split('nnscore2: ')[1].split('\n')[0]) if 'nnscore2: ' in scores_data else 0
        xscore1_3 = float(scores_data.split('xscore1.3: ')[1].split('\n')[0]) if 'xscore1.3: ' in scores_data else 0
        rfscore_4 = float(scores_data.split('rfscore-4: ')[1].split('\n')[0]) if 'rfscore-4: ' in scores_data else 0
        rfscore_vs2 = float(scores_data.split('rfscore-vs2: ')[1].split('\n')[0]) if 'rfscore-vs2: ' in scores_data else 0
    prediction_file = f'{id}/ensemble_prediction.txt'
    if not os.path.isfile(prediction_file):
        # If ensemble_prediction.txt does not exist for this ID, skip it
        continue
    with open(prediction_file) as f:
        for line in f:
            if line.startswith(id):
                scorch_ml = float(line.split(',')[-2])
                break
        else:
            # If the ID is not found in ensemble_prediction.txt, skip it
            continue
    predictions[id] = {
        'actual_affinity': actual_affinity,
        'SCORCH': scorch,
        'SCORCH_FFNN': ffnn,
        'SCORCH_XGBT': xgbt,
        'SCORCH_WD': wd,
        'SCORCH_ML': scorch_ml,
        'drugscore': drugscore,
        'nnscore1': nnscore1,
        'nnscore2': nnscore2,
        'xscore1.3': xscore1_3,
        'rfscore-4': rfscore_4,
        'rfscore-vs2': rfscore_vs2
    }

# Write values to predictions.csv
with open('predictions.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['ID', 'Real affinity', 'SCORCH', 'SCORCH_WD', 'SCORCH_FFNN', 'SCORCH_XGBT', 'SCORCH_ML', 'drugscore', 'nnscore1', 'nnscore2', 'xscore1.3', 'rfscore-4', 'rfscore-vs2'])
    for id in predictions:
        row = [id, predictions[id]['actual_affinity'], predictions[id]['SCORCH'], predictions[id]['SCORCH_WD'], predictions[id]['SCORCH_FFNN'], predictions[id]['SCORCH_XGBT'], predictions[id]['SCORCH_ML'], predictions[id]['drugscore'], predictions[id]['nnscore1'], predictions[id]['nnscore2'], predictions[id]['xscore1.3'], predictions[id]['rfscore-4'], predictions[id]['rfscore-vs2']]
        writer.writerow(row)
