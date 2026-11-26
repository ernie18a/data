//+------------------------------------------------------------------+
//|                                            Initial_Data_MACD.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                https://www.mql5.com/en/users/dng |
//+------------------------------------------------------------------+
//| Script to calculate correlation of MACD indicator with values    |
//| of a number of other indicators                                  |
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
   int h_MACD = iMACD(_Symbol, PERIOD_M5, 12, 48, 12, PRICE_TYPICAL);
   int h_SAR = iSAR(_Symbol, PERIOD_M5, 0.02, 0.2);
   int h_BB = iBands(_Symbol, PERIOD_M5, 48, 0, 3, PRICE_TYPICAL);
   double close[], open[];
   if(CopyClose(_Symbol, PERIOD_M5, Start, End, close) <= 0 ||
      CopyOpen(_Symbol, PERIOD_M5, Start, End, open) <= 0)
      return;
//--- Loading indicator data
   double macd_main[], macd_signal[], bands_medium[];
   double bands_up[], bands_low[], sar[];
   datetime end_zz = End + PeriodSeconds(PERIOD_M5) * (12 * 24 * 5);
   if(CopyBuffer(h_MACD, MAIN_LINE, Start, End, macd_main) <= 0      ||
      CopyBuffer(h_MACD, SIGNAL_LINE, Start, End, macd_signal) <= 0  ||
      CopyBuffer(h_BB, BASE_LINE, Start, End, bands_medium) <= 0     ||
      CopyBuffer(h_BB, UPPER_BAND, Start, End, bands_up) <= 0        ||
      CopyBuffer(h_BB, LOWER_BAND, Start, End, bands_low) <= 0       ||
      CopyBuffer(h_SAR, 0, Start, End, sar) <= 0)
     {
      return;
     }
   int total = ArraySize(close);
   double oc[], macd_delta[];
   if(ArrayResize(oc, total)        <= 0 || ArrayResize(macd_delta, total) <= 0)
     {
      return;
     }
//--- Prepare data
   double extremum = -1;
   for(int i = ArraySize(macd_main) - 1; i >= 0; i--)
     {
      if(i >= total)
         continue;
      oc[i] = close[i] - open[i];
      sar[i] -= close[i];
      bands_low[i] = close[i] - bands_low[i];
      bands_up[i] -= close[i];
      bands_medium[i] -= close[i];
      macd_delta[i] = macd_main[i] - macd_signal[i];
     }
//--- Open file to write results
   int handle = FileOpen("correlation_macd.csv", FILE_WRITE | FILE_CSV | FILE_ANSI, "\t", CP_UTF8);
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Error opening file %s: %d", "correlation_macd.csv", GetLastError());
      return;
     }
   string message = "Indicator\tMACD Main-Signal";
   FileWrite(handle, message);
//--- Correlation calculation block
   CorrelationPearson(macd_delta, oc, "Close - Open", handle);
   CorrelationPearson(macd_delta, sar, "SAR", handle);
   CorrelationPearson(macd_delta, macd_main, "MACD Main", handle);
   CorrelationPearson(macd_delta, macd_signal, "MACD Signal", handle);
   CorrelationPearson(macd_delta, bands_medium, "BB Main", handle);
   CorrelationPearson(macd_delta, bands_low, "BB Low", handle);
   CorrelationPearson(macd_delta, bands_up, "BB Up", handle);
//--- Close the data file
   FileFlush(handle);
   FileClose(handle);
   PrintFormat("Correlation coefficients saved to file %s\\Files\\%s",
               TerminalInfoString(TERMINAL_DATA_PATH), "correlation_macd.csv");
  }
//+------------------------------------------------------------------+
//| Correlation calculation function                                 |
//+------------------------------------------------------------------+
void CorrelationPearson(double &target1[],      // Target buffer
                        double &indicator[],    // Indicator data buffer
                        string name,            // Indicator name
                        int handle)             // File handle to write data
  {
//---
   double correlation = 0;
   string message = "";
   if(MathCorrelationPearson(target1, indicator, correlation))
     {
      message = StringFormat("%s\t%.5f", name, correlation);
     }
   if(handle != INVALID_HANDLE)
      FileWrite(handle, message);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
