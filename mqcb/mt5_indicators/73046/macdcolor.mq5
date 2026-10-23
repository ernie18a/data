//+------------------------------------------------------------------+
//|                                                      Macd Colore |
//|                  Copyright 2025, algotradeacademy Software Corp. |
//|                                    https://algotradeacademy.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, AlgoTradeAcademy Ltd."
#property link      "https://algotradeacademy.com/"
#property version   "1.02"

#include <MovingAverages.mqh>

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3

//--- Plot 1: Colored Histogram
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrLightSalmon
#property indicator_width1  3
#property indicator_label1  "Histo"

//--- Plot 2: Main MACD Line
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlack
#property indicator_width2  1
#property indicator_label2  "Main"

//--- Plot 3: Signal Line
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_width3  2
#property indicator_label3  "Signal"

//--- Input Parameters
input int                  InpFastEMA = 12;
input int                  InpSlowEMA = 26;
input int                  InpSignalMA = 9;
input ENUM_MA_METHOD       InpAppliedSignalMA = MODE_EMA;
input ENUM_APPLIED_PRICE   InpAppliedPrice = PRICE_MEDIAN;

//--- Global buffers
double                     ExtMacdBuffer[];
double                     ExtSignalBuffer[];
double                     ExtHistogramBuffer[];
double                     ExtHistogramColorBuffer[];
double                     ExtFastMaBuffer[];
double                     ExtSlowMaBuffer[];
int                        ExtFastMaHandle, ExtSlowMaHandle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Indicator buffer mapping
   SetIndexBuffer(0, ExtHistogramBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtHistogramColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, ExtMacdBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, ExtSignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, ExtFastMaBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, ExtSlowMaBuffer, INDICATOR_CALCULATIONS);
//--- Set indexing as time series (0 is the latest bar)
   ArraySetAsSeries(ExtHistogramBuffer, true);
   ArraySetAsSeries(ExtHistogramColorBuffer, true);
   ArraySetAsSeries(ExtMacdBuffer, true);
   ArraySetAsSeries(ExtSignalBuffer, true);
   ArraySetAsSeries(ExtFastMaBuffer, true);
   ArraySetAsSeries(ExtSlowMaBuffer, true);
//--- Create handles for internal MAs
   ExtFastMaHandle = iMA(_Symbol, _Period, InpFastEMA, 0, MODE_EMA, InpAppliedPrice);
   ExtSlowMaHandle = iMA(_Symbol, _Period, InpSlowEMA, 0, MODE_EMA, InpAppliedPrice);
//if(ExtFastMaHandle == INVALID_HANDLE || ExtSlowMaHandle == INVALID_HANDLE)
//  {
//   Print("Failed to create handles for iMA");
//   return(INIT_FAILED);
//  }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Main calculation function                                        |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- Check for minimum data requirements
   if(rates_total < InpSlowEMA)
      return(0);
   int calculated = BarsCalculated(ExtFastMaHandle);
   if(calculated < rates_total)
     {
      Print("Not all data of ExtFastMaHandle is calculated (", calculated, "bars ). Error", GetLastError());
      return(0);
     }
   calculated = BarsCalculated(ExtSlowMaHandle);
   if(calculated < rates_total)
     {
      Print("Not all data of ExtSlowMaHandle is calculated (", calculated, " bars). Error ", GetLastError());
      return(0);
     }
//--- Copy MA data from handles to calculation buffers
   if(CopyBuffer(ExtFastMaHandle, 0, 0, rates_total, ExtFastMaBuffer) < rates_total)
      return(0);
   if(CopyBuffer(ExtSlowMaHandle, 0, 0, rates_total, ExtSlowMaBuffer) < rates_total)
      return(0);
//--- Determine calculation limit
   int limit = rates_total - prev_calculated;
   if(limit > 1)
      limit = rates_total - 1;
//--- Calculate MACD Line
   for(int i = limit; i >= 0; i--)
      ExtMacdBuffer[i] = ExtFastMaBuffer[i] - ExtSlowMaBuffer[i];
//--- Calculate Signal Line using built-in buffer functions
   int weightsum = 0;
   if(InpAppliedSignalMA == MODE_SMA)
      SimpleMAOnBuffer(rates_total, prev_calculated, 0, InpSignalMA, ExtMacdBuffer, ExtSignalBuffer);
   else
      if(InpAppliedSignalMA == MODE_EMA)
         ExponentialMAOnBuffer(rates_total, prev_calculated, 0, InpSignalMA, ExtMacdBuffer, ExtSignalBuffer);
      else
         if(InpAppliedSignalMA == MODE_LWMA)
            LinearWeightedMAOnBuffer(rates_total, prev_calculated, 0, InpSignalMA, ExtMacdBuffer, ExtSignalBuffer, weightsum);
         else
            if(InpAppliedSignalMA == MODE_SMMA)
               SmoothedMAOnBuffer(rates_total, prev_calculated, 0, InpSignalMA, ExtMacdBuffer, ExtSignalBuffer);
//--- Update Histogram and Color Index
   for(int i = limit; i >= 0; i--)
     {
      ExtHistogramBuffer[i] = ExtMacdBuffer[i];
      // 0 = Green (Positive), 1 = Salmon (Negative)
      ExtHistogramColorBuffer[i] = (ExtHistogramBuffer[i] >= 0) ? 0.0 : 1.0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
