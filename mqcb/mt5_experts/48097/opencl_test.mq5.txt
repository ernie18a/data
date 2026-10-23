//+------------------------------------------------------------------+
//|                                                  OpenCL_Test.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                https://www.mql5.com/en/users/dng |
//+------------------------------------------------------------------+
//| Script for comparing speed of computing the product of a matrix |
//| by vectors using CPU and OpenCL                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/dng"
#property version   "1.00"
#property script_show_inputs
//+------------------------------------------------------------------+
//| External parameters                                              |
//+------------------------------------------------------------------+
sinput int Rows = 100000; // Rows in matrix
sinput int Colms = 100; // Columns in matrix
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#include <NeuroNetworksBook\algotrading\mult_vect_ocl.mqh>
//+------------------------------------------------------------------+
//| Script program                                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
   matrix<TYPE> X = matrix<TYPE>::Zeros(Rows, Colms);
   vector<TYPE> Y = vector<TYPE>::Zeros(Colms);
   vector<TYPE> Z;
   for(int i = 0; i < Colms; i++)
     {
      for(int r = 0; r < Rows; r++)
         X[r, i] = MathRand() / (TYPE)32767;
      Y[i] = MathRand() / (TYPE)32767;
     }
   uint start = GetTickCount();
   if(!OpenCL_Init(X, Y))
      return;
   if(!MultOCL(Rows, Colms, Z))
      Print("Error OCL function");
   uint end = GetTickCount();
   PrintFormat("%.1e OCL duration %0 000d msec, result %.5e", Rows * Colms, end - start, Z.Sum());
   OpenCL_Deinit();
   start = GetTickCount();
   if(!MultCPU(X, Y, Z))
      Print("Error CPU function");
   end = GetTickCount();
   PrintFormat("%.1e CPU duration %0 000d msec, result %.5e", Rows * Colms, end - start, Z.Sum());
   start = GetTickCount();
   Z = X.MatMul(Y);
   end = GetTickCount();
   PrintFormat("%.1e matrix operation duration %0 000d msec, result %.5e", Rows * Colms, end - start, Z.Sum());
  }
//+------------------------------------------------------------------+
//|  Vector multiplication function on CPU                           |
//+------------------------------------------------------------------+
bool MultCPU(matrix<TYPE> &source1, vector<TYPE> &source2, vector<TYPE> &result)
  {
//---
   ulong rows = source1.Rows();
   ulong cols = source1.Cols();
   if(cols != source2.Size())
     {
      PrintFormat("Size of vectors not equal: %d != %d", cols, source2.Size());
      return false;
     }
//---
   result = vector<TYPE>::Zeros(rows);
   for(ulong r = 0; r < rows; r++)
     {
      result[r] = 0;
      for(ulong c = 0; c < cols; c++)
         result[r] += source1[r, c] * source2[c];
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
