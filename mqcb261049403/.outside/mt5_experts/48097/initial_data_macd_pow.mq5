//+------------------------------------------------------------------+
//|                                        Initial_Data_MACD_Pow.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                https://www.mql5.com/en/users/dng |
//+------------------------------------------------------------------+
//| Script for calculating Pearson correlation coefficient between   |
//| target values and a series of power values of the MACD indicator |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#include <Math\Stat\Math.mqh>
//+------------------------------------------------------------------+
//| External script parameters                                       |
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
   int h_MACD = iMACD(_Symbol, PERIOD_M5, 12, 48, 12, PRICE_TYPICAL);
   double close[], open[];
   if(CopyClose(_Symbol, PERIOD_M5, Start, End, close) <= 0)
      return;
//--- Loading indicator data
   double zz[], macd_main[], macd_signal[], sar[];
   datetime end_zz = End + PeriodSeconds(PERIOD_M5) * (12 * 24 * 5);
   if(CopyBuffer(h_ZZ, 0, Start, end_zz, zz)                   <= 0  ||
      CopyBuffer(h_MACD, MAIN_LINE, Start, End, macd_main)     <= 0  ||
      CopyBuffer(h_MACD, SIGNAL_LINE, Start, End, macd_signal) <= 0)
     {
      return;
     }
   int total = ArraySize(close);
   double macd_delta[], main[], signal[], delta[];
   double target1[], target2[];
   if(ArrayResize(target1, total)      <= 0 || ArrayResize(target2, total)    <= 0 ||
      ArrayResize(macd_delta, total)   <= 0 || ArrayResize(main, total * 15)  <= 0 ||
      ArrayResize(signal, total * 15)  <= 0 || ArrayResize(delta, total * 15) <= 0)
     {
      return;
     }
//--- Prepare data
   double extremum = -1;
   for(int i = ArraySize(zz) - 2; i >= 0; i--)
     {
      if(zz[i + 1] > 0 && zz[i + 1] != EMPTY_VALUE)
         extremum = zz[i + 1];
      if(i >= total)
         continue;
      target2[i] = extremum - close[i];
      target1[i] = (target2[i] >= 0);
      macd_delta[i] = macd_main[i] - macd_signal[i];
      for(int p = 0; p < 15; p++)
        {
         main[i + p * total] = pow(macd_main[i], p + 2);
         signal[i + p * total] = pow(macd_signal[i], p + 2);
         delta[i + p * total] = pow(macd_delta[i], p + 2);
        }
     }
//--- Open file to write results
   int handle = FileOpen("correlation_main_pow.csv", FILE_WRITE | FILE_CSV | FILE_ANSI, "\t", CP_UTF8);
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Error opening file %s: %d", "correlation_main_pow.csv", GetLastError());
      return;
     }
   string message = "Pow\tDirection\tDistance\tMACD Main";
   if(handle != INVALID_HANDLE)
      FileWrite(handle, message);
//--- Correlation calculation
   CorrelationPearson(target1, target2, macd_main, main, 15, handle);
//--- Close the data file
   FileFlush(handle);
   FileClose(handle);
//--- Open file to write results
   handle = FileOpen("correlation_signal_pow.csv", FILE_WRITE | FILE_CSV | FILE_ANSI, "\t", CP_UTF8);
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Error opening file %s: %d", "correlation_signal_pow.csv", GetLastError());
      return;
     }
   message = "Pow\tDirection\tDistance\tMACD Signal";
   if(handle != INVALID_HANDLE)
      FileWrite(handle, message);
//--- Correlation calculation
   CorrelationPearson(target1, target2, macd_signal, signal, 15, handle);
//--- Close the data file
   FileFlush(handle);
   FileClose(handle);
//--- Open file to write results
   handle = FileOpen("correlation_delta_pow.csv", FILE_WRITE | FILE_CSV | FILE_ANSI, "\t", CP_UTF8);
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Error opening file %s: %d", "correlation_delta_pow.csv", GetLastError());
      return;
     }
   message = "Pow\tDirection\tDistance\tMACD Main-Signal";
   if(handle != INVALID_HANDLE)
      FileWrite(handle, message);
//--- Correlation calculation
   CorrelationPearson(target1, target2, macd_delta, delta, 15, handle);
//--- Close the data file
   FileFlush(handle);
   FileClose(handle);
   PrintFormat("Correlation coefficients saved to files %s\\Files\\%s",
               TerminalInfoString(TERMINAL_DATA_PATH), "correlation_*.csv");
  }
//+------------------------------------------------------------------+
//| Function calculating Pearson correlation                         |
//+------------------------------------------------------------------+
void CorrelationPearson(double &target1[],      // Target buffer 1
                        double &target2[],      // Buffer 2 of target values
                        double &indicator[],    // Indicator data buffer
                        double &ind_pow[],      // Buffer of indicator power values
                        int dimension,          // Dimension of buffer of power values
                        int handle)             // File handle to write results
  {
//---
   int total = ArraySize(indicator);
   for(int i = 0; i < dimension; i++)
     {
      double correlation = 0;
      string message = "";
      double temp[];
      if(ArrayCopy(temp, ind_pow, 0, i * total, total) < total)
         continue;
      if(MathCorrelationPearson(target1, temp, correlation))
        {
         message = StringFormat("%d\t%.5f", i + 2, correlation);
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