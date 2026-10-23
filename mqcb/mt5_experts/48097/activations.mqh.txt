//+------------------------------------------------------------------+
//|                                                  activations.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//---
const double theta = 0;
const double a = 1.0;
const double b = 0.0;
//+------------------------------------------------------------------+
/// Threshold activation function
/// Constant 'theta' determines neuron activation function.
/// Parameter 'x' receives weighted sum of raw data.
//+------------------------------------------------------------------+
double ActStep(double x)
  {
   return (x >= theta ? 1 : 0);
  }
//+------------------------------------------------------------------+
/// Linear activation function
/// Constant 'a' defines the angle of inclination of line
/// Constant 'b' defines line offset from the origin
/// Parameter 'x' receives weighted sum of raw data.
//+------------------------------------------------------------------+
double ActLinear(double x)
  {
   return (a * x + b);
  }
//+------------------------------------------------------------------+
/// Derivative of linear activation function
/// Constant 'a' defines the angle of inclination of line
/// Parameter 'y' last state of the activation function (result of the feed-forward)
/// Here the parameter is added to unify the function form with similar ones for other activation functions.
//+------------------------------------------------------------------+
double ActLinearDerivative(double y)
  {
   return a;
  }
//+------------------------------------------------------------------+
/// Logistic activation function (Sigmoid)
/// Constant 'a' defines the range of function values from '0' to 'a'
/// Constant 'b' defines line offset from the origin
/// Parameter 'x' receives weighted sum of raw data.
//+------------------------------------------------------------------+
double ActSigmoid(double x)
  {
   return (a / (1 + exp(-x)) - b);
  }
//+------------------------------------------------------------------+
/// Derivative of logistic function
/// Constant 'a' defines the range of function values from '0' to 'a'
/// Constant 'b' defines line offset from the origin
/// Parameter 'y' last state of the activation function (result of the feed-forward)
//+------------------------------------------------------------------+
double ActSigmoidDerivative(double y)
  {
   y = MathMax(MathMin(y + b, a), 0.0);
   return (y * (1 - y / a));
  }
//+------------------------------------------------------------------+
/// Hyperbolic tangent
/// Parameter 'x' receives weighted sum of raw data.
//+------------------------------------------------------------------+
double ActTanh(double x)
  {
   return tanh(x);
  }
//+------------------------------------------------------------------+
/// Derivative of the hyperbolic tangent
/// Parameter 'y' last state of the activation function (result of the feed-forward)
//+------------------------------------------------------------------+
double ActTanhDerivative(double y)
  {
   y = MathMax(MathMin(y, 1.0), -1.0);
   return (1 - pow(y, 2));
  }
//+------------------------------------------------------------------+
/// PReLU activation function
/// Constant 'a' defines leakage coefficient (skipping negative values)
/// Parameter 'x' receives weighted sum of raw data.
//+------------------------------------------------------------------+
double ActPReLU(double x)
  {
   return (x >= 0 ? x : a * x);
  }
//+------------------------------------------------------------------+
/// Derivative of PReLU
/// Constant 'a' defines leakage coefficient (skipping negative values)
/// Parameter 'y' last state of the activation function (result of the feed-forward)
/// Here the parameter is added to unify the function form with similar ones for other activation functions.
//+------------------------------------------------------------------+
double ActPReLUDerivative(double y)
  {
   return (y >= 0 ? 1 : a);
  }
//+------------------------------------------------------------------+
/// Swish activation function
/// Constant 'b' defines function nonlinearity.
/// Parameter 'x' receives weighted sum of raw data.
//+------------------------------------------------------------------+
double ActSwish(double x)
  {
   return (x / (1 + exp(-b * x)));
  }
//+------------------------------------------------------------------+
/// Derivative of Swish
/// Constant 'b' defines function nonlinearity.
/// Parameter 'x' receives weighted sum of raw data.
/// Parameter 'y' last state of the activation function (result of the feed-forward)
//+------------------------------------------------------------------+
double ActSwishDerivative(double x, double y)
  {
   if(x == 0)
      return 0.5;
   double by = b * y;
   return (by + (y * (1 - by)) / x);
  }
//+------------------------------------------------------------------+
/// SoftMax activation function
/// Parameter 'X' gets array of weighted sums of raw data.
//+------------------------------------------------------------------+
bool SoftMax(vector& X, vector& Y)
  {
   ulong total = X.Size();
   if(total == 0)
      return false;
//--- Calculate exponent for each array element
   Y = MathExp(X);
//--- Normalize data in the array
   Y /= Y.Sum();
//---
   return true;
  }
//+------------------------------------------------------------------+
/// Derivative of SoftMax
/// Parameter 'Y' last state of the activation function (result of the feed-forward)
/// Parameter 'G' error gradient received from the subsequent layer
/// Function returns vector of adjusted gradients of error 'D'
//+------------------------------------------------------------------+
bool ActSoftMaxDerivative(vector& Y, vector& G, vector& D)
  {
   ulong total = Y.Size();
   if(total == 0)
      return false;
//---
   matrix e=matrix::Identity(total,total);
   for(ulong r = 0; r < total; r++)
      if(!e.Row(e.Row(r) - Y, r))
         return false;
   D = (Y * G).MatMul(e);
//---
   return true;
  }
//+------------------------------------------------------------------+
