//+------------------------------------------------------------------+
//|                                       NLPA_NeuralNetSelfTest.mq5 |
//|                                      Neural Loss-Pattern Auditor |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Neural Loss-Pattern Auditor"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property script_show_inputs

#include "NLPA_NeuralNet.mqh"

//--- inputs: a self-contained sanity check, independent of any account history
input int    InpXorSeed       =7;    // random seed (data + weight init)
input int    InpXorHidden     =6;    // hidden neurons
input int    InpXorTrainCount =160;  // synthetic training examples
input int    InpXorTestCount  =60;   // synthetic held-out test examples
input int    InpXorEpochs     =500;  // training epochs
input double InpXorLearnRate  =0.30; // learning rate
input double InpXorPassBar    =0.75; // minimum test accuracy counted as a pass

//+------------------------------------------------------------------+
//| Fill one XOR-sign example: two coordinates in [-1,+1], labeled 1 |
//| when they have opposite signs and 0 when they share a sign. This |
//| pattern is not linearly separable, so a network that solves it   |
//| well is good evidence the hidden layer and backpropagation in    |
//| NLPA_NeuralNet.mqh are wired correctly, independent of anything  |
//| specific to the main auditor's trade-history features.           |
//+------------------------------------------------------------------+
void MakeXorExample(double &features[],double &label)
  {
   double f0=(MathRand()/32767.0)*2.0-1.0;
   double f1=(MathRand()/32767.0)*2.0-1.0;
   features[0]=f0;
   features[1]=f1;
   label=((f0>0.0)!=(f1>0.0)) ? 1.0 : 0.0;
  }

//+------------------------------------------------------------------+
//| Accuracy of a trained net over a freshly generated batch of      |
//| n_samples XOR-sign examples, using a 0.5 decision threshold.     |
//+------------------------------------------------------------------+
double XorAccuracy(CMlpNet &net,const int n_samples)
  {
   int correct=0;
   double features[2];
   double label;
   for(int k=0; k<n_samples; k++)
     {
      MakeXorExample(features,label);
      double pred=net.Forward(features);
      int predicted_class=(pred>=0.5) ? 1 : 0;
      if(predicted_class==(int)label)
         correct++;
     }
   return (double)correct/(double)n_samples;
  }

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- CMlpNet::Init() seeds MathSrand() itself, so the weight draws and every
//--- MakeXorExample() call that follows are one single reproducible stream
   CMlpNet net;
   net.Init(2,InpXorHidden,InpXorSeed);

//--- build a fixed training batch once, then sweep it InpXorEpochs times
   double train_features[][2];
   double train_labels[];
   ArrayResize(train_features,InpXorTrainCount);
   ArrayResize(train_labels,InpXorTrainCount);
   for(int k=0; k<InpXorTrainCount; k++)
     {
      double f[2];
      double lbl;
      MakeXorExample(f,lbl);
      train_features[k][0]=f[0];
      train_features[k][1]=f[1];
      train_labels[k]     =lbl;
     }

   double first_epoch_loss=0.0;
   double last_epoch_loss =0.0;
   for(int epoch=0; epoch<InpXorEpochs; epoch++)
     {
      double total_loss=0.0;
      for(int k=0; k<InpXorTrainCount; k++)
        {
         double f[2];
         f[0]=train_features[k][0];
         f[1]=train_features[k][1];
         total_loss+=net.TrainStep(f,train_labels[k],InpXorLearnRate);
        }
      double avg_loss=total_loss/InpXorTrainCount;
      if(epoch==0)
         first_epoch_loss=avg_loss;
      if(epoch==InpXorEpochs-1)
         last_epoch_loss=avg_loss;
     }

//--- accuracy on the training batch itself, then on a fresh held-out batch
   int train_correct=0;
   for(int k=0; k<InpXorTrainCount; k++)
     {
      double f[2];
      f[0]=train_features[k][0];
      f[1]=train_features[k][1];
      double pred=net.Forward(f);
      int predicted_class=(pred>=0.5) ? 1 : 0;
      if(predicted_class==(int)train_labels[k])
         train_correct++;
     }
   double train_acc=(double)train_correct/(double)InpXorTrainCount;
   double test_acc =XorAccuracy(net,InpXorTestCount);

   Print("=== NLPA Neural Net Self-Test (XOR-sign sanity check) ===");
   PrintFormat("Architecture: 2 inputs -> %d hidden (tanh) -> 1 output (sigmoid)",InpXorHidden);
   PrintFormat("Training loss: first epoch=%.4f, last epoch=%.4f",first_epoch_loss,last_epoch_loss);
   PrintFormat("Train accuracy (%d examples): %.2f%%",InpXorTrainCount,train_acc*100.0);
   PrintFormat("Held-out test accuracy (%d fresh examples): %.2f%%",InpXorTestCount,test_acc*100.0);
   if(test_acc>=InpXorPassBar)
      PrintFormat("RESULT: PASS -- test accuracy is at or above the %.0f%% bar. A purely linear model "+
                  "cannot separate XOR-sign data much beyond chance, so this result is evidence the "+
                  "hidden layer and the backpropagation update are both implemented correctly.",InpXorPassBar*100.0);
   else
      PrintFormat("RESULT: FAIL -- test accuracy is below the %.0f%% bar. Re-check the backpropagation "+
                  "signs and the learning rate before trusting NLPA_NeuralNet.mqh on real data.",InpXorPassBar*100.0);
  }
//+------------------------------------------------------------------+
