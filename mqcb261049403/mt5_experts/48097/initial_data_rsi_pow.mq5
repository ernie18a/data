//+------------------------------------------------------------------+
//|                                         Initial_Data_RSI_Pow.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                https://www.mql5.com/en/users/dng |
//+------------------------------------------------------------------+
//| Script for calculating Pearson correlation coefficient between   |
//| and a series of power values of the RSI indicator                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#include <Math\Stat\Math.mqh>
//+------------------------------------------------------------------+
//| External parameters                                              |
//+------------------------------------------------------------------+
input datetime Start = D'2015.01.01 00:00:00';  // Period beginning
input datetime End = D'2020.12.31 23:59:00';    // Period end
//+------------------------------------------------------------------+
//| Script program                                                   |
//+------------------------------------------------------------------+
void OnStart(void)
  {
//--- Connect indicators
   int h_ZZ = iCustom(_Symbol, PERIOD_M5, "Examples\\ZigZag.ex5", 48, 1, 47);
   int h_RSI = iRSI(_Symbol, PERIOD_M5, 12, PRICE_TYPICAL);
   double close[];
   if(CopyClose(_Symbol, PERIOD_M5, Start, End, close) <= 0)
      return;
//--- Loading indicator data
   double zz[], rsi[];
   datetime end_zz = End + PeriodSeconds(PERIOD_M5) * (12 * 24 * 5);
   if(CopyBuffer(h_ZZ, 0, Start, end_zz, zz) <= 0  ||
      CopyBuffer(h_RSI, 0, Start, End, rsi) <= 0)
     {
      return;
     }
   int total = ArraySize(close);
   double rsi_pow[];
   double target1[], target2[];
   if(ArrayResize(target1, total)   <= 0 || ArrayResize(target2, total) <= 0 || ArrayResize(rsi_pow, total*15) <= 0)
     {
      return;
     }
//--- Prepare data
   double extremum = -1;
   double min=DBL_MAX;
   for(int i = ArraySize(zz) - 2; i > 0; i--)
     {
      if(zz[i + 1] > 0 && zz[i + 1] != EMPTY_VALUE)
         extremum = zz[i + 1];
      if(i >= total)
         continue;
      target2[i] = extremum - close[i];
      target1[i] = (target2[i] >= 0);
      for(int p = 0; p < 15; p++)
        {
         rsi_pow[i+p*total] = pow(rsi[i], p + 2);
        }
     }
//--- Open the file to write data
   int handle = FileOpen("correlation_rsi_pow.csv", FILE_WRITE | FILE_CSV | FILE_ANSI, "\t", CP_UTF8);
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Error of open file %s: %d", "correlation_rsi_pow.csv", GetLastError());
      return;
     }
   string message = "Pow\tDirection\tDistance\tRSI";
   if(handle != INVALID_HANDLE)
      FileWrite(handle, message);
//--- Determine dependency coefficients
   CorrelationPearson(target1, target2, rsi, rsi_pow, 15, handle);
//--- Close the data file
   FileFlush(handle);
   FileClose(handle);
   PrintFormat("Correlation coefficients saved to file %s\\Files\\%s",
               TerminalInfoString(TERMINAL_DATA_PATH), "correlation_rsi_pow.csv");
  }
//+------------------------------------------------------------------+
//| Correlation determining function                                 |
//+------------------------------------------------------------------+
void CorrelationPearson(double &target1[],      // Target buffer 1
                        double &target2[],      // Buffer 2 of target values
                        double &indicator[],    // Indicator data buffer
                        double &ind_pow[],      // Buffer of indicator power values
                        int dimension,          // Dimension of buffer of power values
                        int handle)             // File handle to write results
  {
//---
   int total=ArraySize(indicator);
   for(int i = 0; i < dimension; i++)
     {
      double correlation = 0;
      string message = "";
      double temp[];
      if(ArrayCopy(temp,ind_pow,0,i*total,total)<total)
         continue;
      if(MathCorrelationPearson(target1,temp, correlation))
        {
         message = StringFormat("%d\t%.5f", i+1, correlation);
        }
      if(MathCorrelationPearson(target2, temp, correlation))
        {
         message = StringFormat("%s\t%.5f", message, correlation);
        }
      if(MathCorrelationPearson(indicator, temp, correlation))
        {
         message = StringFormat("%s\t%.5f", message, correlation);
        }
      if(handle != INVALID_HANDLE)
         FileWrite(handle, message);
     }
  }
//+------------------------------------------------------------------+
