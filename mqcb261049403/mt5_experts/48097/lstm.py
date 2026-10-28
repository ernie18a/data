# -------------------------------------------------------#
# Script for the creation and comparative testing of     #
# a fully connected perceptron model with different      #
# convolutional models using the same dataset.           #
# The script creates three models:                       #
# - fully connected perceptron with three hidden layers  #
#   & regularization.                                    #
# - 2-dimensional convolutional layer                    #
# - recurrent network with LSTM block                    #
# When training models, from training dataset, script    #
# allocates 1% to validate the outputs.                  #
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

# Load training dataset
if not mt5.initialize():
    print("initialize() failed, error code =",mt5.last_error())
    quit()

path=os.path.join(mt5.terminal_info().data_path,r'MQL5\Files')
mt5.shutdown()
filename = os.path.join(path,'study_data.csv')
data = np.asarray( pd.read_table(filename,
                   sep=',',
                   header=None,
                   skipinitialspace=True,
                   encoding='utf-8',
                   float_precision='high',
                   dtype=np.float64,
                   low_memory=False))

# Split training dataset to input data and target
inputs=data.shape[1]-2
targerts=2
train_data=data[:,0:inputs]
train_target=data[:,inputs:]

callback = tf.keras.callbacks.EarlyStopping(monitor='loss', patience=20)
# Creating a perceptron model with three hidden layers and regularization
model1 = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
                           keras.layers.Dense(40, activation=tf.nn.swish, kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(40, activation=tf.nn.swish, kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(40, activation=tf.nn.swish, kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(targerts, activation=tf.nn.tanh) 
                         ])
model1.summary()
keras.utils.plot_model(model1, show_shapes=True, to_file=os.path.join(path,'model1.png'),dpi=72,show_layer_names=False,rankdir='LR')

# Add the LSTM block to the model
model2 = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
                           # Reformat tensor to a 3-dimensional one. Specify 2 dimensions as 3rd one is defined by batch size
                           keras.layers.Reshape((-1,4)), 
                           # LSTM block contains 40 elements and returns results at each step  
                           keras.layers.LSTM(40, return_sequences=False, 
                           kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),
                           keras.layers.Dense(40, activation=tf.nn.swish, kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(40, activation=tf.nn.swish, kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(40, activation=tf.nn.swish, kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(targerts, activation=tf.nn.tanh) 
                         ])
model2.summary()
keras.utils.plot_model(model2, show_shapes=True, to_file=os.path.join(path,'model2.png'),dpi=72,show_layer_names=False,rankdir='LR',expand_nested=True)

# Model with 2-dimensional convolutional layer
model3 = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
                           # Reformat tensor into 4-dimensional. Specify 3 dimensions as the 4th dimension is determined by the batch size
                           keras.layers.Reshape((-1,4,1)), 
                           # Convolutional later with 8 filters
                           keras.layers.Conv2D(8,(3,1),1,activation=tf.nn.swish, kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)),
                           # Pooling layer
                           keras.layers.MaxPooling2D((2,1),strides=1),                         
                           # Reformat tensor to a 2-dimensional one for fully connected layers
                           keras.layers.Flatten(),
                           keras.layers.Dense(40, activation=tf.nn.swish, kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(40, activation=tf.nn.swish, kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(40, activation=tf.nn.swish, kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(targerts, activation=tf.nn.tanh) 
                         ])
model3.summary()
keras.utils.plot_model(model3, show_shapes=True, to_file=os.path.join(path,'model3.png'),dpi=72,show_layer_names=False,rankdir='LR')

# Model LSTM block without fully connected layers
model4 = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
                           # Reformat tensor to a 3-dimensional one. Specify 2 dimensions as 3rd one is defined by batch size
                           keras.layers.Reshape((-1,4)), 
                           # 2 consecutive LSTM blocks
                           # 2st contains 40 elements  
                           keras.layers.LSTM(40,
                           kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5),
                           return_sequences=False),
                           # 2nd produces output instead of fully connected layer
                           keras.layers.Reshape((-1,2)), 
                           keras.layers.LSTM(targerts) 
                         ])
model4.summary()
keras.utils.plot_model(model4, show_shapes=True, to_file=os.path.join(path,'model4.png'),dpi=72,show_layer_names=False,rankdir='LR')

# Model LSTM block without fully connected layers
model5 = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
                           # Reformat tensor to a 3-dimensional one. Specify 2 dimensions as 3rd one is defined by batch size
                           keras.layers.Reshape((-1,4)), 
                           # 2 consecutive LSTM blocks
                           # 1st one contains 40 elements and returns the result at each step  
                           keras.layers.LSTM(40, 
                           kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5),
                           return_sequences=True),
                           # 2nd produces output instead of fully connected layer
                           keras.layers.LSTM(targerts) 
                         ])
model5.summary()
keras.utils.plot_model(model5, show_shapes=True, to_file=os.path.join(path,'model5.png'),dpi=72,show_layer_names=False,rankdir='LR')

model1.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])
history1 = model1.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.01,
                      shuffle=True)
model1.save(os.path.join(path,'rnn1.h5'))

model2.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])
history2 = model2.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.01,
                      shuffle=False)
model2.save(os.path.join(path,'rnn2.h5'))

model3.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])
history3 = model3.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.01,
                      shuffle=True)
model3.save(os.path.join(path,'rnn3.h5'))

model4.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])
history4 = model4.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.01,
                      shuffle=False)
model4.save(os.path.join(path,'rnn4.h5'))

model5.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])
history5 = model5.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.01,
                      shuffle=False)
model5.save(os.path.join(path,'rnn5.h5'))

# Render model training results
plt.figure()
plt.plot(history1.history['loss'], label='Perceptron train')
plt.plot(history1.history['val_loss'], label='Perceptron validation')
plt.plot(history3.history['loss'], label='Conv2D train')
plt.plot(history3.history['val_loss'], label='Conv2D validation')
plt.plot(history2.history['loss'], label='LSTM train')
plt.plot(history2.history['val_loss'], label='LSTM validation')
plt.plot(history4.history['loss'], label='LSTM only train')
plt.plot(history4.history['val_loss'], label='LSTM only validation')
plt.plot(history5.history['loss'], label='LSTM sequences train')
plt.plot(history5.history['val_loss'], label='LSTM sequences validation')
plt.ylabel('$MSE$ $loss$')
plt.xlabel('$Epochs$')
plt.title('Model training dynamics')
plt.legend(loc='upper right', ncol=2)

plt.figure()
plt.plot(history1.history['accuracy'], label='Perceptron train')
plt.plot(history1.history['val_accuracy'], label='Perceptron validation')
plt.plot(history3.history['accuracy'], label='Conv2D train')
plt.plot(history3.history['val_accuracy'], label='Conv2D validation')
plt.plot(history2.history['accuracy'], label='LSTM train')
plt.plot(history2.history['val_accuracy'], label='LSTM validation')
plt.plot(history4.history['accuracy'], label='LSTM only train')
plt.plot(history4.history['val_accuracy'], label='LSTM only validation')
plt.plot(history5.history['accuracy'], label='LSTM sequences train')
plt.plot(history5.history['val_accuracy'], label='LSTM sequences validation')
plt.ylabel('$Accuracy$')
plt.xlabel('$Epochs$')
plt.title('Model training dynamics')
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

# Check model results on a test dataset
test_loss1, test_acc1 = model1.evaluate(test_data, test_target, verbose=2) 
test_loss2, test_acc2 = model2.evaluate(test_data, test_target, verbose=2) 
test_loss3, test_acc3 = model3.evaluate(test_data, test_target, verbose=2) 
test_loss4, test_acc4 = model4.evaluate(test_data, test_target, verbose=2) 
test_loss5, test_acc5 = model5.evaluate(test_data, test_target, verbose=2) 

# Log testing results
print('Perceptron model')
print('Test accuracy:', test_acc1)
print('Test loss:', test_loss1)

print('Conv2D model')
print('Test accuracy:', test_acc3)
print('Test loss:', test_loss3)

print('LSTM model')
print('Test accuracy:', test_acc2)
print('Test loss:', test_loss2)

print('LSTM only model')
print('Test accuracy:', test_acc4)
print('Test loss:', test_loss4)

print('LSTM sequences model')
print('Test accuracy:', test_acc5)
print('Test loss:', test_loss5)

plt.figure()
plt.bar(['Perceptron','Conv2D','LSTM', 'LSTM only', 'LSTM sequences'],[test_loss1,test_loss3,test_loss2,test_loss4,test_loss5])
plt.ylabel('$MSE$ $loss$')
plt.title('Test results')
plt.figure()
plt.bar(['Perceptron','Conv2D','LSTM', 'LSTM only', 'LSTM sequences'],[test_acc1,test_acc3,test_acc2,test_acc4,test_acc5])
plt.ylabel('$Accuracy$')
plt.title('Test results')

plt.show()