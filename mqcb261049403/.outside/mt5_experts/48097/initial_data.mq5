//+------------------------------------------------------------------+
//|                                                 Initial_Data.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                https://www.mql5.com/en/users/dng |
//+------------------------------------------------------------------+
//| Script for calculating Pearson correlation coefficient between   |
//| historical price fluctuations, indicator data and extremes       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com/en/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#include <Math\Stat\Math.mqh>
//---
#define FileName  "correlation.csv"
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
   int h_CCI = iCCI(_Symbol, PERIOD_M5, 12, PRICE_TYPICAL);
   int h_RSI = iRSI(_Symbol, PERIOD_M5, 12, PRICE_TYPICAL);
   int h_Stoh = iStochastic(_Symbol, PERIOD_M5, 12, 8, 3, MODE_LWMA, STO_LOWHIGH);
   int h_MACD = iMACD(_Symbol, PERIOD_M5, 12, 48, 12, PRICE_TYPICAL);
   int h_ATR = iATR(_Symbol, PERIOD_M5, 12);
   int h_BB = iBands(_Symbol, PERIOD_M5, 48, 0, 3, PRICE_TYPICAL);
   int h_SAR = iSAR(_Symbol, PERIOD_M5, 0.02, 0.2);
   int h_MFI = iMFI(_Symbol, PERIOD_M5, 12, VOLUME_TICK);
   double close[], open[], high[], low[];
   if(CopyClose(_Symbol, PERIOD_M5, Start, End, close) <= 0 ||
      CopyOpen(_Symbol, PERIOD_M5, Start, End, open) <= 0 ||
      CopyHigh(_Symbol, PERIOD_M5, Start, End, high) <= 0 ||
      CopyLow(_Symbol, PERIOD_M5, Start, End, low) <= 0)
      return;
//--- Load indicator data
   double zz[], cci[], macd_main[], macd_signal[], rsi[], atr[], bands_medium[],
          bands_up[], bands_low[], sar[], stoch[], ssig[], mfi[];
   datetime end_zz = End + PeriodSeconds(PERIOD_M5) * (12 * 24 * 5);
   if(h_ZZ == INVALID_HANDLE || CopyBuffer(h_ZZ, 0, Start, end_zz, zz) <= 0)
     {
      PrintFormat("Error loading indicator %s data", "ZigZag");
      return;
     }
   if(h_CCI == INVALID_HANDLE || CopyBuffer(h_CCI, 0, Start, End, cci) <= 0)
     {
      PrintFormat("Error of load indicator %s data", "CCI");
      return;
     }
   if(h_RSI == INVALID_HANDLE || CopyBuffer(h_RSI, 0, Start, End, rsi) <= 0)
     {
      PrintFormat("Error loading indicator %s data", "RSI");
      return;
     }
   if(h_MACD == INVALID_HANDLE || CopyBuffer(h_MACD, MAIN_LINE, Start, End, macd_main) <= 0 ||
      CopyBuffer(h_MACD, SIGNAL_LINE, Start, End, macd_signal) <= 0)
     {
      PrintFormat("Error loading indicator %s data", "MACD");
      return;
     }
   if(h_ATR == INVALID_HANDLE || CopyBuffer(h_ATR, 0, Start, End, atr) <= 0)
     {
      PrintFormat("Error loading indicator %s data", "ATR");
      return;
     }
   if(h_BB == INVALID_HANDLE || CopyBuffer(h_BB, BASE_LINE, Start, End, bands_medium) <= 0 ||
      CopyBuffer(h_BB, UPPER_BAND, Start, End, bands_up) <= 0 ||
      CopyBuffer(h_BB, LOWER_BAND, Start, End, bands_low) <= 0)
     {
      PrintFormat("Error loading indicator %s data", "Bollinger Bands®");
      return;
     }
   if(h_SAR == INVALID_HANDLE || CopyBuffer(h_SAR, 0, Start, End, sar) <= 0)
     {
      PrintFormat("Error loading indicator %s data", "SAR");
      return;
     }
   if(h_Stoh == INVALID_HANDLE || CopyBuffer(h_Stoh, MAIN_LINE, Start, End, stoch) <= 0 ||
      CopyBuffer(h_Stoh, SIGNAL_LINE, Start, End, ssig) <= 0)
     {
      PrintFormat("Error loading indicator %s data", "Stochastic");
      return;
     }
   if(h_MFI == INVALID_HANDLE || CopyBuffer(h_MFI, 0, Start, End, mfi) <= 0)
     {
      PrintFormat("Error loading indicator %s data", "MFI");
      return;
     }
   int total = ArraySize(close);
   double target1[], target2[], oc[], hc[], lc[], bmc[], buc[], blc[], macd_delta[];
   if(ArrayResize(target1, total) <= 0 || ArrayResize(target2, total) <= 0 || ArrayResize(oc, total) <= 0 ||
      ArrayResize(hc, total) <= 0 || ArrayResize(lc, total) <= 0 || ArrayResize(bmc, total) <= 0 ||
      ArrayResize(buc, total) <= 0 || ArrayResize(blc, total) <= 0 || ArrayResize(macd_delta, total) <= 0)
      return;
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
      oc[i] = close[i] - open[i];
      hc[i] = high[i] - close[i];
      lc[i] = close[i] - low[i];
      sar[i] -= close[i];
      bands_low[i] = close[i] - bands_low[i];
      bands_up[i] -= close[i];
      bands_medium[i] -= close[i];
      macd_delta[i] = macd_main[i] - macd_signal[i];
     }
//--- Open the file to write data
   int handle = FileOpen(FileName, FILE_WRITE | FILE_CSV | FILE_ANSI, "\t", CP_UTF8);
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Error opening file %s: %d", FileName, GetLastError());
      return;
     }
//--- Calculate correlation coefficients
   string message = "Indicator\t Target 1\t Target 2";
   FileWrite(handle, message);
   CorrelationPearson(target1, target2, oc, "Close - Open", handle);
   CorrelationPearson(target1, target2, hc, "High - Close", handle);
   CorrelationPearson(target1, target2, lc, "Close - Low", handle);
   CorrelationPearson(target1, target2, cci, "CCI", handle);
   CorrelationPearson(target1, target2, rsi, "RSI", handle);
   CorrelationPearson(target1, target2, atr, "ATR", handle);
   CorrelationPearson(target1, target2, sar, "SAR", handle);
   CorrelationPearson(target1, target2, macd_main, "MACD Main", handle);
   CorrelationPearson(target1, target2, macd_signal, "MACD Signal", handle);
   CorrelationPearson(target1, target2, macd_delta, "MACD Main-Signal", handle);
   CorrelationPearson(target1, target2, bands_medium, "BB Main", handle);
   CorrelationPearson(target1, target2, bands_low, "BB Low", handle);
   CorrelationPearson(target1, target2, bands_up, "BB Up", handle);
   CorrelationPearson(target1, target2, stoch, "Stohastic Main", handle);
   CorrelationPearson(target1, target2, ssig, "Stochastic Signal", handle);
   CorrelationPearson(target1, target2, mfi, "MFI", handle);
//--- Close the data file
   FileFlush(handle);
   FileClose(handle);
   PrintFormat("Correlation coefficients saved to file %s\\Files\\%s",
               TerminalInfoString(TERMINAL_DATA_PATH), FileName);
  }
//+------------------------------------------------------------------+
//| Function for calculating correlation coefficients                |
//+------------------------------------------------------------------+
void CorrelationPearson(double &target1[],      // Target data buffer 1 
                        double &target2[],      // Target data buffer 2
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
   if(MathCorrelationPearson(target2, indicator, correlation))
     {
      message = StringFormat("%s\t%.5f", message, correlation);
     }
   if(handle != INVALID_HANDLE)
      FileWrite(handle, message);
  }
//+------------------------------------------------------------------+