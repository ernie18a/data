//+------------------------------------------------------------------+
//|                                         Check_Gradient_percp.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property script_show_inputs
//+------------------------------------------------------------------+
//| Connect the neural network library                               |
//+------------------------------------------------------------------+
#include <NeuroNetworksBook\realization\neuronnet.mqh>
CNet Net;
//+------------------------------------------------------------------+
//| External parameters for script operation                         |
//+------------------------------------------------------------------+
input int      BarsToLine =   10;                     // Input data vector size
input bool     UseOpenCL  =   false;                  // Use of OpenCL
input ENUM_ACTIVATION_FUNCTION HiddenActivation = AF_SWISH; // Hidden layer activation function
//+------------------------------------------------------------------+
//| Script program start                                             |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- create a model
   if(!CreateNet(Net))
      return;
//--- create a buffer to read input data
   CBufferType *pattern = new CBufferType();
   if(!pattern)
     {
      PrintFormat("Error creating Pattern data array: %d", GetLastError());
      return;
     }
//--- generate random initial data
   if(!pattern.BufferInit(1, BarsToLine))
      return;
   for(int i = 0; i < BarsToLine; i++)
      pattern.m_mMatrix[0, i] = (TYPE)MathRand() / (TYPE)32767;
//--- run feed-forward and backpropagation passes to get analytical gradients
   const TYPE delta = (TYPE)1.0e-5;
   TYPE dd = 0;
   CBufferType *init_pattern = new CBufferType();
   init_pattern.m_mMatrix.Copy(pattern.m_mMatrix);
   if(!Net.FeedForward(pattern))
     {
      PrintFormat("Error in FeedForward: %d", GetLastError());
      return;
     }
   CBufferType *etalon_result = new CBufferType();
   if(!Net.GetResults(etalon_result))
     {
      PrintFormat("Error in GetResult: %d", GetLastError());
      return;
     }
//--- create results buffer
   CBufferType *target = new CBufferType();
   if(!target)
     {
      PrintFormat("Error creating Pattern Target array: %d", GetLastError());
      return;
     }
//--- save obtained data into separate files
   target.m_mMatrix.Copy(etalon_result.m_mMatrix);
   target.m_mMatrix[0, 0] = etalon_result.m_mMatrix[0, 0] + delta;
   if(!Net.Backpropagation(target))
     {
      PrintFormat("Error in Backpropagation: %d", GetLastError());
      delete target;
      delete etalon_result;
      delete pattern;
      delete init_pattern;
      return;
     }
   CBufferType *input_gradient = Net.GetGradient(0);
   CBufferType *weights = Net.GetWeights(1);
   CBufferType *weights_gradient = Net.GetDeltaWeights(1);
   if(UseOpenCL)
     {
      input_gradient.BufferRead();
      weights.BufferRead();
      weights_gradient.BufferRead();
     }
//--- in a loop alternately change the elements of the initial data and compare
//--- empirical result with the value of the analytical method
   for(int k = 0; k < BarsToLine; k++)
     {
      pattern.m_mMatrix.Copy(init_pattern.m_mMatrix);
      pattern.m_mMatrix[0, k] = init_pattern.m_mMatrix[0, k] + delta;
      if(!Net.FeedForward(pattern))
        {
         PrintFormat("Error in FeedForward: %d", GetLastError());
         return;
        }
      if(!Net.GetResults(target))
        {
         PrintFormat("Error in GetResult: %d", GetLastError());
         return;
        }
      TYPE d = target.At(0) - etalon_result.At(0);
      pattern.m_mMatrix[0, k] = init_pattern.m_mMatrix[0, k] - delta;
      if(!Net.FeedForward(pattern))
        {
         PrintFormat("Error in FeedForward: %d", GetLastError());
         return;
        }
      if(!Net.GetResults(target))
        {
         PrintFormat("Error in GetResult: %d", GetLastError());
         return;
        }
      d -= target.At(0) - etalon_result.At(0);
      d /= 2;
      dd += input_gradient.At(k) - d;
     }
   delete pattern;
//--- log the total value of deviations at the input data level
   PrintFormat("Delta at input gradient between methods %.5e", dd / delta);
//--- reset the sum value and repeat the loop for weight gradients
   dd = 0;
   CBufferType *initial_weights = new CBufferType();
   if(!initial_weights)
     { 
      PrintFormat("Error creating benchmark weights buffer: %d", GetLastError());
      return;
     }
   if(!initial_weights.m_mMatrix.Copy(weights.m_mMatrix))
     {
      PrintFormat("Error of copy weights to initial weights buffer: %d", GetLastError());
      return;
     }
   for(uint k = 0; k < weights.Total(); k++)
     {
      if(k > 0)
         weights.Update(k - 1, initial_weights.At(k - 1));
      weights.Update(k, initial_weights.At(k) + delta);
      if(UseOpenCL)
         if(!weights.BufferWrite())
            return;
      if(!Net.FeedForward(init_pattern))
        {
         PrintFormat("Error in FeedForward: %d", GetLastError());
         return;
        }
      if(!Net.GetResults(target))
        {
         PrintFormat("Error in GetResult: %d", GetLastError());
         return;
        }
      TYPE d = target.At(0) - etalon_result.At(0);
      weights.Update(k, initial_weights.At(k) - delta);
      if(UseOpenCL)
         if(!weights.BufferWrite())
            return;
      if(!Net.FeedForward(init_pattern))
        {
         PrintFormat("Error in FeedForward: %d", GetLastError());
         return;
        }
      if(!Net.GetResults(target))
        {
         PrintFormat("Error in GetResult: %d", GetLastError());
         return;
        }
      d -= target.At(0) - etalon_result.At(0);
      d /= 2;
      dd += weights_gradient.At(k) - d;
     }
//--- log the total value of deviations at the weight level
   PrintFormat("Delta at weights gradient between methods %.5e", dd / delta);
//--- clear memory before exiting the script
   delete init_pattern;
   delete etalon_result;
   delete initial_weights;
   delete target;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CreateNet(CNet &net)
  {
   CArrayObj *layers = new CArrayObj();
   if(!layers)
     {
      PrintFormat("Error creating CArrayObj: %d", GetLastError());
      return false;
     }
//--- input data layer
   CLayerDescription *descr = new CLayerDescription();
   if(!descr)
     {
      PrintFormat("Error creating CLayerDescription: %d", GetLastError());
      delete layers;
      return false;
     }
   descr.type = defNeuronBase;
   descr.count = BarsToLine;
   descr.window = 0;
   descr.activation = AF_NONE;
   descr.optimization = None;
   if(!layers.Add(descr))
     {
      PrintFormat("Error adding layer: %d", GetLastError());
      delete layers;
      delete descr;
      return false;
     }
//--- hidden layer
   descr = new CLayerDescription();
   if(!descr)
     {
      PrintFormat("Error creating CLayerDescription: %d", GetLastError());
      delete layers;
      return false;
     }
   descr.type = defNeuronBase;
   descr.count = 10 * BarsToLine;
   descr.activation = HiddenActivation;
   descr.optimization = Adam;
   descr.activation_params[0] = (TYPE)1;
   descr.activation_params[1] = (TYPE)0;
   if(!layers.Add(descr))
     {
      PrintFormat("Error adding layer: %d", GetLastError());
      delete layers;
      delete descr;
      return false;
     }
//--- results layer
   descr = new CLayerDescription();
   if(!descr)
     {
      PrintFormat("Error creating CLayerDescription: %d", GetLastError());
      delete layers;
      return false;
     }
   descr.type = defNeuronBase;
   descr.count = 1;
   descr.activation = AF_LINEAR;
   descr.optimization = Adam;
   descr.activation_params[0] = 1;
   descr.activation_params[1] = 0;
   if(!layers.Add(descr))
     {
      PrintFormat("Error adding layer: %d", GetLastError());
      delete layers;
      delete descr;
      return false;
     }
//--- initialize the neural network
   if(!net.Create(layers, (TYPE)3.0e-4, (TYPE)0.9, (TYPE)0.999, LOSS_MAE, 0, 0))
     {
      PrintFormat("Error of init Net: %d", GetLastError());
      delete layers;
      return false;
     }
   delete layers;
   net.UseOpenCL(UseOpenCL);
   PrintFormat("Use OpenCL %s", (string)net.UseOpenCL());
//---
   return true;
  }
//+------------------------------------------------------------------+
