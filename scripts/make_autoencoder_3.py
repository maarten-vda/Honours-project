import tensorflow as tf
import pandas as pd
import numpy as np

# load the data
data = pd.read_csv('predictions.csv')

# create the input layer
input_layer = tf.keras.layers.Input(shape=(3,))

# create the encoding layer
encoding_layer = tf.keras.layers.Dense(2, activation='relu')(input_layer)

# create the decoding layer
decoding_layer = tf.keras.layers.Dense(3, activation='sigmoid')(encoding_layer)

# create the autoencoder model
autoencoder = tf.keras.models.Model(input_layer, decoding_layer)

# compile the model
autoencoder.compile(optimizer='adam', loss='mse')

# train the model
autoencoder.fit(data[['SCORCH_WD', 'SCORCH_FFNN', 'SCORCH_XGBT']], data[['SCORCH_WD', 'SCORCH_FFNN', 'SCORCH_XGBT']], epochs=100)

# save the trained model as a .h5 file
tf.keras.models.save_model(autoencoder, 'autoencoder_3.h5', save_format='h5')
