//+------------------------------------------------------------------+
//|                                       Initial_Data_RSI_Shift.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                https://www.mql5.com/en/users/dng |
//+------------------------------------------------------------------+
//| Script for finding correlation between RSI values and target     |
//| values when the indicator is shifted in time                     |
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
//--- Load indicator data
   double zz[], rsi[];
   datetime end_zz = End + PeriodSeconds(PERIOD_M5) * (12 * 24 * 5);
   if(CopyBuffer(h_ZZ, 0, Start, end_zz, zz) <= 0 || CopyBuffer(h_RSI, 0, Start, End, rsi) <= 0)
     {
      return;
     }
   int total = ArraySize(close);
   double target1[], target2[];
   if(ArrayResize(target1, total) <= 0 || ArrayResize(target2, total) <= 0)
     {
      return;
     }
//--- Prepare values
   double extremum = -1;
   for(int i = ArraySize(zz) - 2; i >= 0; i--)
     {
      if(zz[i + 1] > 0 && zz[i + 1] != EMPTY_VALUE)
         extremum = zz[i + 1];
      if(i >= total)
         continue;
      target2[i] = extremum - close[i];
      target1[i] = (target2[i] >= 0);
     }
//--- Open the file to write data
   int handle = FileOpen("correlation_rsi_shift.csv", FILE_WRITE | FILE_CSV | FILE_ANSI, "\t", CP_UTF8);
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Error of open file %s: %d", "correlation_rsi_shift.csv", GetLastError());
      return;
     }
   string message = "Shift\tTarget 1\tTarget 2";
   if(handle != INVALID_HANDLE)
      FileWrite(handle, message);
//--- Determine correlation coefficient
   ShiftCorrelationPearson(target1, target2, rsi, "RSI", 200, handle);
//--- Close the data file
   FileFlush(handle);
   FileClose(handle);
   PrintFormat("Correlation coefficients saved to file %s\\Files\\%s",
               TerminalInfoString(TERMINAL_DATA_PATH), "correlation_rsi_shift.csv");
  }
//+------------------------------------------------------------------+
//| Function calculating Pearson correlation                         |
//+------------------------------------------------------------------+
void ShiftCorrelationPearson(double &targ1[],   // Target buffer 1
                             double &targ2[],   // Target buffer 2
                             double &signal[],  // Indicator data buffer
                             string name,       // Indicator name
                             int max_shift,     // Maximum time shift
                             int handle)        // File handle to write data
  {
   int total = ArraySize(targ1);
   if(max_shift > total)
      max_shift = total - 10;
   if(max_shift < 10)
      return;
   double correlation = 0;
   for(int i = 0; i < max_shift; i++)
     {
      double t1[], t2[], s[];
      if(ArrayCopy(t1, targ1, 0, i, total - i) <= 0 || ArrayCopy(t2, targ2, 0, i, total - i) <= 0 || ArrayCopy(s, signal, 0, 0, total - i) <= 0)
        {
         continue;
        }
      //---
      string message;
      if(MathCorrelationPearson(s, t1, correlation))
         message = StringFormat("%d\t%.5f", i, correlation);
      if(MathCorrelationPearson(s, t2, correlation))
         message = StringFormat("%s\t%.5f", message, correlation);
      if(handle != INVALID_HANDLE)
         FileWrite(handle, message);
     }
//---
   return;
  }
//+------------------------------------------------------------------+
