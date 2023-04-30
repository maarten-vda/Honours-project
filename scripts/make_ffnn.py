import pandas as pd
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import argparse
import pickle

parser = argparse.ArgumentParser(description='Train and save a TensorFlow model')
parser.add_argument('csv_file', type=str, help='Filepath of the input CSV file')
args = parser.parse_args()

# Load the data from the input CSV file
data = pd.read_csv(args.csv_file, na_values='')

# Separate the input features from the target variable, excluding the first column
X = data.iloc[:, 1:4] # Input features are the 2nd through 4th columns
y = data.iloc[:, -1] # Target variable is the last column

# Split the data into training and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Scale the input features using StandardScaler
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Define the model architecture
model = tf.keras.Sequential([
  tf.keras.layers.Dense(32, activation='relu', input_shape=[X_train.shape[1]]),
  tf.keras.layers.Dense(32, activation='relu'),
  tf.keras.layers.Dense(1)
])

# Compile the model with a mean squared error loss function and an Adam optimizer
model.compile(loss='mse', optimizer=tf.keras.optimizers.Adam(lr=0.001))

# Train the model for 100 epochs
model.fit(X_train_scaled, y_train, epochs=100, validation_split=0.2)

# Evaluate the model on the test set
test_loss = model.evaluate(X_test_scaled, y_test)
print(f'Test Loss: {test_loss:.3f}')

# Save the trained model as an HDF5 file
model.save('100_epochs_model.h5')
