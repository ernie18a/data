# -------------------------------------------------------#
# Script for comparative testing of models with          #
#  the Dropout layer and without it.                     #
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

# Adding a Dropout to a model with one hidden layer
model1do = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
                           keras.layers.Dropout(0.3),
                           keras.layers.Dense(40, activation=tf.nn.swish), 
                           keras.layers.Dense(targets, activation=tf.nn.tanh) 
                         ])
model1do.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])
model1do.summary()

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
# Adding Dropout to model with batch normalization of input data and one hidden layer
model1bndo = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
                             keras.layers.BatchNormalization(),
                             keras.layers.Dropout(0.3),
                             keras.layers.Dense(40, activation=tf.nn.swish), 
                             keras.layers.Dense(targets, activation=tf.nn.tanh) 
                            ])
model1bndo.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])
model1bndo.summary()

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
# Add Dropout to a model with three hidden layers
model2do = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
                           keras.layers.Dropout(0.3),
                           keras.layers.Dense(40, activation=tf.nn.swish), 
                           keras.layers.Dropout(0.3),
                           keras.layers.Dense(40, activation=tf.nn.swish), 
                           keras.layers.Dropout(0.3),
                           keras.layers.Dense(40, activation=tf.nn.swish), 
                           keras.layers.Dense(targets, activation=tf.nn.tanh) 
                         ])
model2do.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])
model2do.summary()

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

# Adding Dropout to the model with batch normalization of input data 
# and three hidden layers
model2bndo = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
                             keras.layers.BatchNormalization(),
                             keras.layers.Dropout(0.3),
                             keras.layers.Dense(40, activation=tf.nn.swish), 
                             keras.layers.BatchNormalization(),
                             keras.layers.Dropout(0.3),
                             keras.layers.Dense(40, activation=tf.nn.swish), 
                             keras.layers.BatchNormalization(),
                             keras.layers.Dropout(0.3),
                             keras.layers.Dense(40, activation=tf.nn.swish), 
                             keras.layers.Dense(targets, activation=tf.nn.tanh) 
                            ])
model2bndo.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])
model2bndo.summary()

# Train the first model using normalized data
history1 = model1.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.1,
                      shuffle=True)
model1.save(os.path.join(path,'perceptron1.h5'))

history1do = model1do.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.1,
                      shuffle=True)
model1do.save(os.path.join(path,'perceptron1do.h5'))

history1bn = model1bn.fit(train_nn_data, train_nn_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.1,
                      shuffle=True)
model1bn.save(os.path.join(path,'perceptron1bn.h5'))

history1bndo = model1bndo.fit(train_nn_data, train_nn_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.1,
                      shuffle=True)
model1bndo.save(os.path.join(path,'perceptron1bndo.h5'))


history2 = model2.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.1,
                      shuffle=True)
model2.save(os.path.join(path,'perceptron2.h5'))

history2do = model2do.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.1,
                      shuffle=True)
model2do.save(os.path.join(path,'perceptron2do.h5'))

history2bn = model2bn.fit(train_nn_data, train_nn_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.1,
                      shuffle=True)
model2bn.save(os.path.join(path,'perceptron2bn.h5'))

history2bndo = model2bndo.fit(train_nn_data, train_nn_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.1,
                      shuffle=True)
model2bndo.save(os.path.join(path,'perceptron2bndo.h5'))

# Render training results of models with 1 hidden layer
plt.figure()
plt.plot(history1.history['loss'], label='Normalized inputs train')
plt.plot(history1.history['val_loss'], label='Normalized inputs validation')
plt.plot(history1do.history['loss'], label='Normalized inputs\nvs Dropout train')
plt.plot(history1do.history['val_loss'], label='Normalized inputs\nvs Dropout validation')
plt.plot(history1bn.history['loss'], label='Unnormalized inputs\nvs BatchNormalization train')
plt.plot(history1bn.history['val_loss'], label='Unnormalized inputs\nvs BatchNormalization validation')
plt.plot(history1bndo.history['loss'], label='Unnormalized inputs\nvs BatchNormalization and Dropout train')
plt.plot(history1bndo.history['val_loss'], label='Unnormalized inputs\nvs BatchNormalization and Dropout validation')
plt.ylabel('$MSE$ $loss$')
plt.xlabel('$Epochs$')
plt.title('Model training dynamics\n1 hidden layer')
plt.legend(loc='upper right',ncol=2)

plt.figure()
plt.plot(history1.history['accuracy'], label='Normalized inputs trin')
plt.plot(history1.history['val_accuracy'], label='Normalized inputs validation')
plt.plot(history1do.history['accuracy'], label='Normalized inputs\nvs Dropout train')
plt.plot(history1do.history['val_accuracy'], label='Normalized inputs\nvs Dropout validation')
plt.plot(history1bn.history['accuracy'], label='Unnormalized inputs\nvs BatchNormalization train')
plt.plot(history1bn.history['val_accuracy'], label='Unnormalized inputs\nvs BatchNormalization validation')
plt.plot(history1bndo.history['accuracy'], label='Unnormalized inputs\nvs BatchNormalization and Dropout train')
plt.plot(history1bndo.history['val_accuracy'], label='Unnormalized inputs\nvs BatchNormalization and Dropout validation')
plt.ylabel('$Accuracy$')
plt.xlabel('$Epochs$')
plt.title('Model training dynamics\n1 hidden layer')
plt.legend(loc='lower right',ncol=2)

# Render training results of models with 3 hidden layers
plt.figure()
plt.plot(history2.history['loss'], label='Normalized inputs train')
plt.plot(history2.history['val_loss'], label='Normalized inputs validation')
plt.plot(history2do.history['loss'], label='Normalized inputs\nvs Dropout train')
plt.plot(history2do.history['val_loss'], label='Normalizedinputs\nvs Dropout validation')
plt.plot(history2bn.history['loss'], label='Unnormalized inputs\nvs BatchNormalization train')
plt.plot(history2bn.history['val_loss'], label='Unnormalized inputs\nvs BatchNormalization validation')
plt.plot(history2bndo.history['loss'], label='Unnormalized inputs\nvs BatchNormalization and Dropout train')
plt.plot(history2bndo.history['val_loss'], label='Unnormalized inputs\nvs BatchNormalization and Dropout validation')
plt.ylabel('$MSE$ $loss$')
plt.xlabel('$Epochs$')
plt.title('Model training dynamics\n3 hidden layers')
plt.legend(loc='upper right',ncol=2)

plt.figure()
plt.plot(history2.history['accuracy'], label='Normalized inputs train')
plt.plot(history2.history['val_accuracy'], label='Normalized inputs validation')
plt.plot(history2do.history['accuracy'], label='Normalized inputs\nvs Dropout train')
plt.plot(history2do.history['val_accuracy'], label='Normalized inputs\nvs Dropout validation')
plt.plot(history2bn.history['accuracy'], label='Unnormalized inputs\nvs BatchNormalization train')
plt.plot(history2bn.history['val_accuracy'], label='Unnormalized inputs\nvs BatchNormalization validation')
plt.plot(history2bndo.history['accuracy'], label='Unnormalized inputs\nvs BatchNormalization and Dropout train')
plt.plot(history2bndo.history['val_accuracy'], label='Unnormalized inputs\nvs BatchNormalization and Dropout validation')
plt.ylabel('$Accuracy$')
plt.xlabel('$Epochs$')
plt.title('Model training dynamics\n3 hidden layers')
plt.legend(loc='lower right',ncol=2)

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
test_loss1do, test_acc1do = model1do.evaluate(test_data, test_target, verbose=2) 
test_loss1bn, test_acc1bn = model1bn.evaluate(test_nn_data, test_nn_target, verbose=2) 
test_loss1bndo, test_acc1bndo = model1bndo.evaluate(test_nn_data, test_nn_target, verbose=2) 
test_loss2, test_acc2 = model2.evaluate(test_data, test_target, verbose=2) 
test_loss2do, test_acc2do = model2do.evaluate(test_data, test_target, verbose=2) 
test_loss2bn, test_acc2bn = model2bn.evaluate(test_nn_data, test_nn_target, verbose=2) 
test_loss2bndo, test_acc2bndo = model2bndo.evaluate(test_nn_data, test_nn_target, verbose=2)

# Log testing results
print('Model 1 hidden layer')
print('Test accuracy:', test_acc1)
print('Test loss:', test_loss1)

print('Model 1 hidden layer vs Dropout')
print('Test accuracy:', test_acc1do)
print('Test loss:', test_loss1do)

print('Model 1 hidden layer vs BatchNormalization')
print('Test accuracy:', test_acc1bn)
print('Test loss:', test_loss1bn)

print('Model 1 hidden layer vs BatchNormalization and Dropout')
print('Test accuracy:', test_acc1bndo)
print('Test loss:', test_loss1bndo)

print('Model 3 hidden layers')
print('Test accuracy:', test_acc2)
print('Test loss:', test_loss2)

print('Model 3 hidden layers vs Dropout')
print('Test accuracy:', test_acc2do)
print('Test loss:', test_loss2do)

print('Model 3 hidden layers vs BatchNormalization')
print('Test accuracy:', test_acc2bn)
print('Test loss:', test_loss2bn)

print('Model 3 hidden layers vs BatchNormalization and Dropout')
print('Test accuracy:', test_acc2bndo)
print('Test loss:', test_loss2bndo)

plt.figure()
plt.bar(['Normalized inputs','\n\nNormalized inputs\nvs Dropout',
         'Unnormalized inputs\nvs BatchNornalization',
         '\n\nUnnormalized inputs\nvs BatchNornalization and Dropout'],
        [test_loss1,test_loss1do,
         test_loss1bn,test_loss1bndo])
plt.ylabel('$MSE$ $loss$')
plt.title('Test results\n1 hidden layer')
plt.figure()
plt.bar(['Normalized inputs','\n\nNormalized inputs\nvs Dropout',
         'Unnormalized inputs\nvs BatchNornalization',
         '\n\nUnnormalized inputs\nvs BatchNornalization and Dropout'],
        [test_loss2,test_loss2do,
         test_loss2bn,test_loss2bndo])
plt.ylabel('$MSE$ $loss$')
plt.title('Test results\n3 hidden layers')
plt.figure()
plt.bar(['Normalized inputs','\n\nNormalized inputs\nvs Dropout',
         'Unnormalized inputs\nvs BatchNornalization',
         '\n\nUnnormalized inputs\nvs BatchNornalization and Dropout'],
        [test_acc1,test_acc1do,
         test_acc1bn,test_acc1bndo])
plt.ylabel('$Accuracy$')
plt.title('Test results\n1 hidden layer')

plt.figure()
plt.bar(['Normalized inputs','\n\nNormalized inputs\nvs Dropout',
         'Unnormalized inputs\nvs BatchNornalization',
         '\n\nUnnormalized inputs\nvs BatchNornalization and Dropout'],
        [test_acc2,test_acc2do,
         test_acc2bn,test_acc2bndo])
plt.ylabel('$Accuracy$')
plt.title('Test results\n3 hidden layers')

plt.show()
