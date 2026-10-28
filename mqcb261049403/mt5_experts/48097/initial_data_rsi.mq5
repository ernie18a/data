//+------------------------------------------------------------------+
//|                                             Initial_Data_RSI.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                https://www.mql5.com/en/users/dng |
//+------------------------------------------------------------------+
//| Script for finding Pearson correlation coefficient between the   |
//| values of RSI and some other indicators                          |
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
   int h_CCI = iCCI(_Symbol, PERIOD_M5, 12, PRICE_TYPICAL);
   int h_RSI = iRSI(_Symbol, PERIOD_M5, 12, PRICE_TYPICAL);
   int h_Stoh = iStochastic(_Symbol, PERIOD_M5, 12, 8, 3, MODE_LWMA, STO_LOWHIGH);
   int h_MACD = iMACD(_Symbol, PERIOD_M5, 12, 48, 12, PRICE_TYPICAL);
   int h_BB = iBands(_Symbol, PERIOD_M5, 48, 0, 3, PRICE_TYPICAL);
   int h_SAR = iSAR(_Symbol, PERIOD_M5, 0.02, 0.2);
   int h_MFI = iMFI(_Symbol, PERIOD_M5, 12, VOLUME_TICK);
   double close[], open[];
   if(CopyClose(_Symbol, PERIOD_M5, Start, End, close) <= 0 ||
      CopyOpen(_Symbol, PERIOD_M5, Start, End, open) <= 0)
      return;
//--- Loading indicator data
   double cci[], macd_main[], macd_signal[], rsi[], bands_medium[];
   double bands_up[], bands_low[], sar[], stoch[], ssig[], mfi[];
   datetime end_zz = End + PeriodSeconds(PERIOD_M5) * (12 * 24 * 5);
   if(CopyBuffer(h_CCI, 0, Start, End, cci) <= 0   ||
      CopyBuffer(h_RSI, 0, Start, End, rsi) <= 0   ||
      CopyBuffer(h_MACD, MAIN_LINE, Start, End, macd_main) <= 0      ||
      CopyBuffer(h_MACD, SIGNAL_LINE, Start, End, macd_signal) <= 0  ||
      CopyBuffer(h_BB, BASE_LINE, Start, End, bands_medium) <= 0     ||
      CopyBuffer(h_BB, UPPER_BAND, Start, End, bands_up) <= 0        ||
      CopyBuffer(h_BB, LOWER_BAND, Start, End, bands_low) <= 0       ||
      CopyBuffer(h_SAR, 0, Start, End, sar) <= 0   ||
      CopyBuffer(h_Stoh, MAIN_LINE, Start, End, stoch) <= 0    ||
      CopyBuffer(h_Stoh, SIGNAL_LINE, Start, End, ssig) <= 0   ||
      CopyBuffer(h_MFI, 0, Start, End, mfi) <= 0)
      return;
   int total = ArraySize(close);
   double oc[], bmc[], buc[], blc[], macd_delta[];
   if(ArrayResize(oc, total)        <= 0 || ArrayResize(bmc, total)     <= 0 ||
      ArrayResize(buc, total)       <= 0 || ArrayResize(blc, total)     <= 0 ||
      ArrayResize(macd_delta, total) <= 0)
      return;
//--- Prepare data
   for(int i = total - 1; i >= 0; i--)
     {
      oc[i] = close[i] - open[i];
      sar[i] -= close[i];
      bands_low[i] = close[i] - bands_low[i];
      bands_up[i] -= close[i];
      bands_medium[i] -= close[i];
      macd_delta[i] = macd_main[i] - macd_signal[i];
     }
//--- Open the file to write data
   int handle = FileOpen("correlation_rsi.csv", FILE_WRITE | FILE_CSV | FILE_ANSI, "\t", CP_UTF8);
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Error of open file %s: %d", "correlation_rsi.csv", GetLastError());
      return;
     }
   string message = "Indicator\tRSI";
   FileWrite(handle, message);
//--- Determine correlation coefficients
   CorrelationPearson(rsi, oc, "Close - Open", handle);
   CorrelationPearson(rsi, cci, "CCI %.5f", handle);
   CorrelationPearson(rsi, sar, "SAR", handle);
   CorrelationPearson(rsi, macd_main, "MACD Main", handle);
   CorrelationPearson(rsi, macd_signal, "MACD Signal", handle);
   CorrelationPearson(rsi, macd_delta, "MACD Main-Signal", handle);
   CorrelationPearson(rsi, bands_medium, "BB Main", handle);
   CorrelationPearson(rsi, bands_low, "BB Low", handle);
   CorrelationPearson(rsi, bands_up, "BB Up", handle);
   CorrelationPearson(rsi, stoch, "Stohastic Main", handle);
   CorrelationPearson(rsi, ssig, "Stochastic Signal", handle);
   CorrelationPearson(rsi, mfi, "MFI", handle);
//--- Close the data file
   FileFlush(handle);
   FileClose(handle);
   PrintFormat("Correlation coefficients saved to file %s\\Files\\%s",
               TerminalInfoString(TERMINAL_DATA_PATH), "correlation_rsi.csv");
  }
//+------------------------------------------------------------------+
//| Function for determining correlation coefficients                |
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
