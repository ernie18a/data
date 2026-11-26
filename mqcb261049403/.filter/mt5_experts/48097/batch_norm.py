# -------------------------------------------------------#
# Script for comparative testing of models with          #
# the batch normalization layer and without it.          #
# When training models, from training dataset, script    #
# allocates 10% to validate the outputs.                 #
# After training, the script tests the performance       #
# of the model on a test dataset (separate data file)    #
# -------------------------------------------------------#
# Import Libraries
import os
import pandas as pd
import numpy as np
import tensorflow as tf 
from tensorflow import keras 
import matplotlib as mp
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
import MetaTrader5 as mt5

# Add fonts
font_list=fm.findSystemFonts()
for f in font_list:
    if(f.__contains__('ClearSans')):
        fm.fontManager.addfont(f)

# Set parameters for output graphs
mp.rcParams.update({'font.family':'serif',
                    'font.serif':'Clear Sans',
                    'axes.titlesize': 'x-large',
                    'axes.labelsize':'medium',
                    'xtick.labelsize':'small',
                    'ytick.labelsize':'small',
                    'legend.fontsize':'small',
                    'figure.figsize':[6.0,4.0],
                    'axes.titlecolor': '#707070',
                    'axes.labelcolor': '#707070',
                    'axes.edgecolor': '#707070',
                    'xtick.labelcolor': '#707070',
                    'ytick.labelcolor': '#707070',
                    'xtick.color': '#707070',
                    'ytick.color': '#707070',
                    'text.color': '#707070',
                    'lines.linewidth': 0.8,
                    'axes.linewidth': 0.5
                   })

# Connect to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =",mt5.last_error())
    quit()
# Request path to the Sandbox
path=os.path.join(mt5.terminal_info().data_path,r'MQL5\Files')
mt5.shutdown()
# Load training dataset
filename = os.path.join(path,'study_data.csv')
filename_not_norm = os.path.join(path,'study_data_not_norm.csv')
data = np.asarray( pd.read_table(filename,
                   sep=',',
                   header=None,
                   skipinitialspace=True,
                   encoding='utf-8',
                   float_precision='high',
                   dtype=np.float64,
                   low_memory=False))

# Split training dataset to input data and target
targets=2
inputs=data.shape[1]-targets
train_data=data[:,0:inputs]
train_target=data[:,inputs:]

# load non-normalized training dataset
data = np.asarray( pd.read_table(filename_not_norm,
                   sep=',',
                   header=None,
                   skipinitialspace=True,
                   encoding='utf-8',
                   float_precision='high',
                   dtype=np.float64,
                   low_memory=False))
# Split non-normalized training dataset to input data and target
train_nn_data=data[:,0:inputs]
train_nn_target=data[:,inputs:]

del data

# Create the first model with one hidden layer
model1 = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
                           keras.layers.Dense(40, activation=tf.nn.swish), 
                           keras.layers.Dense(targets, activation=tf.nn.tanh) 
                         ])
callback = tf.keras.callbacks.EarlyStopping(monitor='loss', patience=20)
model1.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])
model1.summary()

# Add batch normalization for input data to the model with one hidden layer
model1bn = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
                             keras.layers.BatchNormalization(),
                             keras.layers.Dense(40, activation=tf.nn.swish), 
                             keras.layers.Dense(targets, activation=tf.nn.tanh) 
                            ])
model1bn.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])
model1bn.summary()

# Create a model with three hidden layers
model2 = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
                           keras.layers.Dense(40, activation=tf.nn.swish), 
                           keras.layers.Dense(40, activation=tf.nn.swish), 
                           keras.layers.Dense(40, activation=tf.nn.swish), 
                           keras.layers.Dense(targets, activation=tf.nn.tanh) 
                         ])
model2.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])
model2.summary()

# Add batch normalization for the input data and hidden layers of the 2nd model
model2bn = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
                             keras.layers.BatchNormalization(),
                             keras.layers.Dense(40, activation=tf.nn.swish), 
                             keras.layers.BatchNormalization(),
                             keras.layers.Dense(40, activation=tf.nn.swish), 
                             keras.layers.BatchNormalization(),
                             keras.layers.Dense(40, activation=tf.nn.swish), 
                             keras.layers.Dense(targets, activation=tf.nn.tanh) 
                            ])
model2bn.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])
model2bn.summary()

# Train the first model using non-normalized data
history1nn = model1.fit(train_nn_data, train_nn_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.1,
                      shuffle=True)

# Train the first model using normalized data
history1 = model1.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.1,
                      shuffle=True)
model1.save(os.path.join(path,'perceptron1.h5'))

history1bn = model1bn.fit(train_nn_data, train_nn_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.1,
                      shuffle=True)
model1bn.save(os.path.join(path,'perceptron1bn.h5'))


history2 = model2.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.1,
                      shuffle=True)
model2.save(os.path.join(path,'perceptron2.h5'))

history2bn = model2bn.fit(train_nn_data, train_nn_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.1,
                      shuffle=True)
model2bn.save(os.path.join(path,'perceptron2bn.h5'))

# Render training results of models with 1 hidden layer
plt.plot(history1.history['loss'], label='Normalized inputs train')
plt.plot(history1.history['val_loss'], label='Normalized inputs validation')
plt.plot(history1nn.history['loss'], label='Unnormalized inputs train')
plt.plot(history1nn.history['val_loss'], label='Unnormalized inputs vvalidation')
plt.plot(history1bn.history['loss'], label='Unnormalized inputs\nvs BatchNormalization train')
plt.plot(history1bn.history['val_loss'], label='Unnormalized inputs\nvs BatchNormalization validation')
plt.ylabel('$MSE$ $loss$')
plt.xlabel('$Epochs$')
plt.title('Model training dynamics\n1 hidden layer')
plt.legend(loc='upper right', ncol=2)

plt.figure()
plt.plot(history1.history['accuracy'], label='Normalized inputs train')
plt.plot(history1.history['val_accuracy'], label='Normalized inputs validation')
plt.plot(history1nn.history['accuracy'], label='Unnormalized inputs train')
plt.plot(history1nn.history['val_accuracy'], label='Unnormalized inputs validation')
plt.plot(history1bn.history['accuracy'], label='Unnormalized inputs\nvs BatchNormalization train')
plt.plot(history1bn.history['val_accuracy'], label='Unnormalized inputs\nvs BatchNormalization validation')
plt.ylabel('$Accuracy$')
plt.xlabel('$Epochs$')
plt.title('Model training dynamics\n1 hidden layer')
plt.legend(loc='lower right', ncol=2)

# Render training results of models with 3 hidden layers
plt.figure()
plt.plot(history2.history['loss'], label='Normalized inputs train')
plt.plot(history2.history['val_loss'], label='Normalized inputs validation')
plt.plot(history2bn.history['loss'], label='Unnormalized inputs\nvs BatchNormalization train')
plt.plot(history2bn.history['val_loss'], label='Unnormalized inputs\nvs BatchNormalization validation')
plt.ylabel('$MSE$ $loss$')
plt.xlabel('$Epochs$')
plt.title('Model training dynamics\n3 hidden layers')
plt.legend(loc='upper right', ncol=2)

plt.figure()
plt.plot(history2.history['accuracy'], label='Normalized inputs train')
plt.plot(history2.history['val_accuracy'], label='Normalized inputs validation')
plt.plot(history2bn.history['accuracy'], label='Unnormalized inputs\nvs BatchNormalization train')
plt.plot(history2bn.history['val_accuracy'], label='Unnormalized inputs\nvs BatchNormalization validation')
plt.ylabel('$Accuracy$')
plt.xlabel('$Epochs$')
plt.title('Model training dynamics\n3 hidden layers')
plt.legend(loc='lower right', ncol=2)

# Load testing dataset
test_filename = os.path.join(path,'test_data.csv')
test = np.asarray( pd.read_table(test_filename,
                   sep=',',
                   header=None,
                   skipinitialspace=True,
                   encoding='utf-8',
                   float_precision='high',
                   dtype=np.float64,
                   low_memory=False))
# Split test dataset to input data and target
test_data=test[:,0:inputs]
test_target=test[:,inputs:]

test_filename = os.path.join(path,'test_data_not_norm.csv')
test = np.asarray( pd.read_table(test_filename,
                   sep=',',
                   header=None,
                   skipinitialspace=True,
                   encoding='utf-8',
                   float_precision='high',
                   dtype=np.float64,
                   low_memory=False))
# Split test dataset to input data and target
test_nn_data=test[:,0:inputs]
test_nn_target=test[:,inputs:]

del test

# Check model results on a test dataset
test_loss1, test_acc1 = model1.evaluate(test_data, test_target, verbose=2) 
test_loss1bn, test_acc1bn = model1bn.evaluate(test_nn_data, test_nn_target, verbose=2) 
test_loss2, test_acc2 = model2.evaluate(test_data, test_target, verbose=2) 
test_loss2bn, test_acc2bn = model2bn.evaluate(test_nn_data, test_nn_target, verbose=2) 
# Log testing results
print('Model 1 hidden layer')
print('Test accuracy:', test_acc1)
print('Test loss:', test_loss1)

print('Model 1 hidden layer vs BatchNormalization')
print('Test accuracy:', test_acc1bn)
print('Test loss:', test_loss1bn)

print('Model 3 hidden layers')
print('Test accuracy:', test_acc2)
print('Test loss:', test_loss2)

print('Model 3 hidden layers vs BatchNormalization')
print('Test accuracy:', test_acc2bn)
print('Test loss:', test_loss2bn)

plt.figure()
plt.bar(['1 hidden layer','1 hidden layer\nvs BatchNormalization','3 hidden layers','3 hidden layers\nvs BatchNormalization'],
        [test_loss1,test_loss1bn,test_loss2,test_loss2bn])
plt.ylabel('$MSE$ $Loss$')
plt.title('Test results')
plt.figure()
plt.bar(['1 hidden layer','1 hidden layer\nvs BatchNormalization','3 hidden layers','3 hidden layers\nvs BatchNormalization'],
        [test_acc1,test_acc1bn,test_acc2,test_acc2bn])
plt.ylabel('$Accuracy$')
plt.title('Test results')

plt.show()