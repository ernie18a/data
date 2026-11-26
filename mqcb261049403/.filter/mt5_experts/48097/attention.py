# -------------------------------------------------------#
# Script for the creation and comparative testing of     #
# multiple models using one dataset.                     #
# The script creates three models:                       #
# - 2-dimensional convolutional layer                    #
# - recurrent network with LSTM block                    #
# - Multi-Head Self-Attention                            #
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
(                   })

# Connect to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =",mt5.last_error())
    quit()
# Request path to the Sandbox
path=os.path.join(mt5.terminal_info().data_path,r'MQL5\Files')
mt5.shutdown()
# Load training dataset
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
#keras.utils.plot_model(model3, show_shapes=True, to_file=os.path.join(path,'model3.png'),dpi=72,show_layer_names=False,rankdir='LR')

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
#keras.utils.plot_model(model4, show_shapes=True, to_file=os.path.join(path,'model4.png'),dpi=72,show_layer_names=False,rankdir='LR')

# Model Multi-Head Self-Attention
@tf.keras.utils.register_keras_serializable(package="Custom", name='MHAttention')
class MHAttention(tf.keras.layers.Layer):
  def __init__(self,key_size, heads, **kwargs):
    super(MHAttention, self).__init__(**kwargs)

    self.m_iHeads = heads
    self.m_iKeysSize = key_size
    self.m_iDimension=self.m_iHeads*self.m_iKeysSize;

    self.m_cQuerys = tf.keras.layers.Dense(self.m_iDimension)
    self.m_cKeys = tf.keras.layers.Dense(self.m_iDimension)
    self.m_cValues = tf.keras.layers.Dense(self.m_iDimension)
    self.m_cNormAttention=tf.keras.layers.LayerNormalization(epsilon=1e-6)
    self.m_cNormOutput=tf.keras.layers.LayerNormalization(epsilon=1e-6)

  def build(self, input_shape):
    self.m_iWindow=input_shape[-1]
    self.m_cW0 = tf.keras.layers.Dense(self.m_iWindow)
    self.m_cFF1=tf.keras.layers.Dense(4*self.m_iWindow, activation=tf.nn.swish)
    self.m_cFF2=tf.keras.layers.Dense(self.m_iWindow)

  def split_heads(self, x, batch_size):
    x = tf.reshape(x, (batch_size, -1, self.m_iHeads, self.m_iKeysSize))
    return tf.transpose(x, perm=[0, 2, 1, 3])

  def call(self, data):
    batch_size = tf.shape(data)[0]

    query = self.m_cQuerys(data)
    key = self.m_cKeys(data)
    value = self.m_cValues(data)

    query = self.split_heads(query, batch_size)
    key = self.split_heads(key, batch_size)
    value = self.split_heads(value, batch_size) 

    score = tf.matmul(query, key, transpose_b=True)

    score = score / tf.math.sqrt(tf.cast(self.m_iKeysSize, tf.float32))
    score = tf.nn.softmax(score, axis=-1)

    attention = tf.matmul(score, value)

    attention = tf.transpose(attention, perm=[0, 2, 1, 3])
    attention = tf.reshape(attention,(batch_size, -1, self.m_iDimension))

    attention = self.m_cW0(attention)
    attention=self.m_cNormAttention(data + attention)

    output=self.m_cFF1(attention)
    output=self.m_cFF2(output)
    output=self.m_cNormOutput(attention+output)
    return output
    
  def get_config(self):
    config={'key_size': self.m_iKeysSize,
            'heads': self.m_iHeads,
            'dimension': self.m_iDimension,
            'window': self.m_iWindow
            }
    base_config = super(MHAttention, self).get_config()
    return dict(list(base_config.items()) + list(config.items()))

  @classmethod
  def from_config(cls, config):
    dimension=config.pop('dimension')
    window=config.pop('window')
    layer = cls(**config)
    layer._build_from_signature(dimension, window)
    return layer             

  def _build_from_signature(self, dimension, window):
    self.m_iDimension=dimension
    self.m_iWindow=window

heads=8
key_dimension=4

model5 = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
        # Reformat tensor to a 3-dimensional one. Specify 2 dimensions
        # as the 3rd dimension is defined by batch size
        # 1st dimension - sequence elements
        # 2nd dimension - one element description vector
                           keras.layers.Reshape((-1,4)), 
                           MHAttention(key_dimension,heads), 
        # Reformat tensor to a 2-dimensional one for fully connected layers
                           keras.layers.Flatten(),
                           keras.layers.Dense(40, activation=tf.nn.swish, kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(40, activation=tf.nn.swish, kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(40, activation=tf.nn.swish, kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(targerts, activation=tf.nn.tanh) 
                         ])
model5.summary()
#keras.utils.plot_model(model5, show_shapes=True, to_file=os.path.join(path,'model5.png'),dpi=72,show_layer_names=False,rankdir='LR')

model6 = keras.Sequential([keras.layers.InputLayer(input_shape=inputs),
        # Reformat tensor to a 3-dimensional one. Specify 2 dimensions
        # as the 3rd dimension is defined by batch size
        # 1st dimension - sequence elements
        # 2nd dimension - one element description vector
                           keras.layers.Reshape((-1,4)), 
                           MHAttention(key_dimension,heads), 
                           MHAttention(key_dimension,heads), 
                           MHAttention(key_dimension,heads), 
                           MHAttention(key_dimension,heads), 
        # Reformat tensor to a 2-dimensional one for fully connected layers
                           keras.layers.Flatten(),
                           keras.layers.Dense(40, activation=tf.nn.swish, 
                        kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(40, activation=tf.nn.swish, 
                        kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(40, activation=tf.nn.swish,
                        kernel_regularizer=keras.regularizers.l1_l2(l1=1e-7, l2=1e-5)), 
                           keras.layers.Dense(targerts, activation=tf.nn.tanh) 
                         ])
model6.summary()

model3.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])

model4.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])
model5.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])

#model5=keras.models.load_model(os.path.join(path,'attention.h5'))

model6.compile(optimizer='Adam', 
               loss='mean_squared_error', 
               metrics=['accuracy'])

callback = tf.keras.callbacks.EarlyStopping(monitor='loss', patience=5)

history3 = model3.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.01,
                      shuffle=True)
model3.save(os.path.join(path,'conv2d'))

history4 = model4.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.01,
                      shuffle=False)
model4.save(os.path.join(path,'rnn'))

history5 = model5.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.01,
                      shuffle=True)
model5.save(os.path.join(path,'attention'))

history6 = model6.fit(train_data, train_target,
                      epochs=500, batch_size=1000,
                      callbacks=[callback],
                      verbose=2,
                      validation_split=0.01,
                      shuffle=True)
model6.save(os.path.join(path,'attention2'))

# Render model training results
plt.figure()
plt.plot(history3.history['loss'], label='Conv2D train')
plt.plot(history3.history['val_loss'], label='Conv2D validation')
plt.plot(history4.history['loss'], label='LSTM only train')
plt.plot(history4.history['val_loss'], label='LSTM only validation')
plt.plot(history5.history['loss'], label='MH Attention train')
plt.plot(history5.history['val_loss'], label='MH Attention validation')
plt.plot(history6.history['loss'], label='MH Attention 4 layers train')
plt.plot(history6.history['val_loss'], label='MH Attention 4 layers validation')
plt.ylabel('$MSE$ $loss$')
plt.xlabel('$Epochs$')
plt.title('Model training dynamics')
plt.legend(loc='upper right', ncol=2)

plt.figure()
plt.plot(history3.history['accuracy'], label='Conv2D train')
plt.plot(history3.history['val_accuracy'], label='Conv2D validation')
plt.plot(history4.history['accuracy'], label='LSTM only train')
plt.plot(history4.history['val_accuracy'], label='LSTM only validation')
plt.plot(history5.history['accuracy'], label='MH Attention train')
plt.plot(history5.history['val_accuracy'], label='MH Attention validation')
plt.plot(history6.history['accuracy'], label='MH Attention 4 layers train')
plt.plot(history6.history['val_accuracy'], label='MH Attention 4 layers validation')
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
test_loss3, test_acc3 = model3.evaluate(test_data, test_target, verbose=2) 
test_loss4, test_acc4 = model4.evaluate(test_data, test_target, verbose=2) 
test_loss5, test_acc5 = model5.evaluate(test_data, test_target, verbose=2) 
test_loss6, test_acc6 = model6.evaluate(test_data, test_target, verbose=2) 

# Log testing results
print('Conv2D model')
print('Test accuracy:', test_acc3)
print('Test loss:', test_loss3)

print('LSTM only model')
print('Test accuracy:', test_acc4)
print('Test loss:', test_loss4)

print('MH Attention model')
print('Test accuracy:', test_acc5)
print('Test loss:', test_loss5)

print('MH Attention 4 layers model')
print('Test accuracy:', test_acc6)
print('Test loss:', test_loss6)

plt.figure()
plt.bar(['Conv2D','LSTM', 'MH Attention','MH Attention\n4 layers'],[test_loss3,test_loss4,test_loss5,test_loss6])
plt.ylabel('$MSE$ $loss$')
plt.title('Test results')

plt.figure()
plt.bar(['Conv2D','LSTM', 'MH Attention','MH Attention\n4 layers'],[test_acc3,test_acc4,test_acc5,test_acc6])
plt.ylabel('$Accuracy$')
plt.title('Test results')

plt.show()
