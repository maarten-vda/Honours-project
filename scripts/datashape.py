import argparse
import h5py

# Create an argument parser to accept the filename as an argument
parser = argparse.ArgumentParser()
parser.add_argument('-i', '--input', required=True, help='input .h5 file name')
args = parser.parse_args()

# Load the data from the .h5 file
with h5py.File(args.input, 'r') as f:
    data_shape = f['data'].shape

# Print the data shape
print("The data shape for the machine learning model should be:", data_shape)
