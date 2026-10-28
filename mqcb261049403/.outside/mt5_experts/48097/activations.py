a=1.0
b=0.0
theta=0
# Step activation function
# Constant 'theta' determines the level of neuron activation.
# Parameter 'x' Weighted sum of initial data.
def ActStep (x):
  return 1 if x>=theta else 0

# Linear activation function
# Constant 'a' defines the angle of inclination of the line, and 'b' - the vertical offset of the line
# Parameter 'x' Weighted sum of initial data.
def ActLinear (x):
  return a*x+b

# Sigmoid activation function
# Constant 'a' stretches the range of values of the function from '0' to 'a'
# Constant 'b' shifts the resulting value
# Parameter 'x' Weighted sum of initial data.
import math
def ActSigmoid(x):
   return a/(1+math.exp(-x))-b
   
# TANH activation function
# Parameter 'x' Weighted sum of initial data.
import math
def ActTanh (x):
  return math.tanh(x)

# PReLU activation function
# Constant 'a' leak parameter
# Parameter 'x' Weighted sum of initial data.
def ActPReLU (x):
  return x if x>=0 else a*x
  
# SoftMax activation function
# Parameter 'X' array of weighted initial data.
from scipy.special import softmax
def ActSoftMax (X):
  return softmax(X)
