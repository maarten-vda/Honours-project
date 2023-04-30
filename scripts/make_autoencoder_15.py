import tensorflow as tf
import pandas as pd
import numpy as np

# load the data
data = pd.read_csv('constituent_predictions.csv')

# create the input layer
input_layer = tf.keras.layers.Input(shape=(31,))

# create the encoding layer
encoding_layer = tf.keras.layers.Dense(2, activation='relu')(input_layer)

# create the decoding layer
decoding_layer = tf.keras.layers.Dense(31, activation='sigmoid')(encoding_layer)

# create the autoencoder model
autoencoder = tf.keras.models.Model(input_layer, decoding_layer)

# compile the model
autoencoder.compile(optimizer='adam', loss='mse')

# train the model
input_data = data[['SCORCH_XGBT', 'ffnn_1', 'ffnn_2', 'ffnn_3', 'ffnn_4', 'ffnn_5', 'ffnn_6', 'ffnn_7', 'ffnn_8', 'ffnn_9', 'ffnn_10', 'ffnn_11', 'ffnn_12', 'ffnn_13', 'ffnn_14', 'ffnn_15', 'wd_1', 'wd_2', 'wd_3', 'wd_4', 'wd_5', 'wd_6', 'wd_7', 'wd_8', 'wd_9', 'wd_10', 'wd_11', 'wd_12', 'wd_13', 'wd_14', 'wd_15']]
target_data = data[['SCORCH_XGBT', 'ffnn_1', 'ffnn_2', 'ffnn_3', 'ffnn_4', 'ffnn_5', 'ffnn_6', 'ffnn_7', 'ffnn_8', 'ffnn_9', 'ffnn_10', 'ffnn_11', 'ffnn_12', 'ffnn_13', 'ffnn_14', 'ffnn_15', 'wd_1', 'wd_2', 'wd_3', 'wd_4', 'wd_5', 'wd_6', 'wd_7', 'wd_8', 'wd_9', 'wd_10', 'wd_11', 'wd_12', 'wd_13', 'wd_14', 'wd_15']]
autoencoder.fit(input_data, target_data, epochs=100)

# save the trained model as a .h5 file
tf.keras.models.save_model(autoencoder, 'autoencoder_15.h5', save_format='h5')
