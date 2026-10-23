//+------------------------------------------------------------------+
//|                                                wd.Range_MACD.mq5 |
//|                  Copyright 2023, Karya Prima Rajasa Mediavestama |
//|                        Programmed/Modified by widhie75@yahoo.com |
//|                                                                  |
//|   Basic idea/Source code: built-in 'MACD.mq5' by MetaQuotes Ltd. |
//+------------------------------------------------------------------+
#property copyright   "Copyright © 2023, Karya Prima Rajasa Mediavestama."
#property link        "https://www.mql5.com/en/code/47143"
#property version     "2.23"
#property strict
#property description "This Moving Average Convergence/Divergence is enhanced with additional range information."
#property description "It calculates the range difference between the MACD and Signal lines, as well as the range distance between the last MACD bar and the current one."
#property description "This range information helps in measuring price cross-points, resistance/support levels, and trend changes more efficiently."
#property description ""
#property description "Labels for reference:"
#property description "Label 1: MACD"
#property description "Label 2: Signal"
#property description "Label 3: Range between Signal and MACD"
#property description "Label 4: Range between the last two MACD bars"

#include <MovingAverages.mqh>

//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_type2   DRAW_LINE
#property indicator_color1  Silver
#property indicator_color2  Red
#property indicator_width1  2
#property indicator_width2  1
#property indicator_label1  "MACD"
#property indicator_label2  "Signal"
#property indicator_label3  "Range Signal to MACD"
#property indicator_label4  "Range Last two MACD Bar"

//--- input parameters
input int                InpFastEMA=12;               // Fast EMA period
input int                InpSlowEMA=26;               // Slow EMA period
input int                InpSignalSMA=9;              // Signal SMA period
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Applied price

//--- indicator buffers
double ExtMacdBuffer[];
double ExtSignalBuffer[];
double ExtFastMaBuffer[];
double ExtSlowMaBuffer[];
double RangeSignalMACDBuffer[];
double Range2LastBarMACDBuffer[];

int    ExtFastMaHandle;
int    ExtSlowMaHandle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMacdBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtSignalBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,RangeSignalMACDBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,Range2LastBarMACDBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ExtFastMaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ExtSlowMaBuffer,INDICATOR_CALCULATIONS);
   
//--- name for indicator subwindow label
   string short_name=StringFormat("MACD(%d,%d,%d)",InpFastEMA,InpSlowEMA,InpSignalSMA);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   
//--- get MA handles
   ExtFastMaHandle=iMA(NULL,0,InpFastEMA,0,MODE_EMA,InpAppliedPrice);
   ExtSlowMaHandle=iMA(NULL,0,InpSlowEMA,0,MODE_EMA,InpAppliedPrice);
  }
  
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total<InpSignalSMA)
      return(0);
      
   //--- Ensure the buffers are set as series
   ArraySetAsSeries(ExtMacdBuffer, true);
   ArraySetAsSeries(ExtSignalBuffer, true);
   ArraySetAsSeries(RangeSignalMACDBuffer, true);
   ArraySetAsSeries(Range2LastBarMACDBuffer, true);
   ArraySetAsSeries(ExtFastMaBuffer, true);
   ArraySetAsSeries(ExtSlowMaBuffer, true);

   // Copy the indicator buffers with the 'CopyBuffer' function
   if (CopyBuffer(ExtFastMaHandle, 0, 0, rates_total, ExtFastMaBuffer) != rates_total)
   {
      Print("Copying ExtFastMaBuffer failed! Error ", GetLastError());
      return(0);
   }

   if (CopyBuffer(ExtSlowMaHandle, 0, 0, rates_total, ExtSlowMaBuffer) != rates_total)
   {
      Print("Copying ExtSlowMaBuffer failed! Error ", GetLastError());
      return(0);
   }

   // Calculate MACD
   for (int i = 0; i < rates_total; i++)
      ExtMacdBuffer[i] = ExtFastMaBuffer[i] - ExtSlowMaBuffer[i];

   // Calculate Signal
   SimpleMAOnBuffer(rates_total, prev_calculated, 0, InpSignalSMA, ExtMacdBuffer, ExtSignalBuffer);

   // Calculate Range Signal to MACD and convert to integer
   for (int i = 0; i < rates_total; i++)
   {
      double rangeValue = RangeSignalMACDBuffer[i] = (ExtMacdBuffer[i] - ExtSignalBuffer[i]) / _Point;
      RangeSignalMACDBuffer[i] = int(MathRound(rangeValue * 10));
   }

   // Calculate Range for last 2 Bar MACD and convert to integer
   for (int i = 0; i < rates_total; i++)
   {
      if (i == 0)
      {
         double rangeValue = Range2LastBarMACDBuffer[i] = (ExtMacdBuffer[i] - ExtMacdBuffer[i + 1]) / _Point;
         Range2LastBarMACDBuffer[i] = int(MathRound(rangeValue * 10));
      }
      else if (i == rates_total - 1)
      {
         double rangeValue = Range2LastBarMACDBuffer[i] = (ExtMacdBuffer[i - 1] - ExtMacdBuffer[i]) / _Point;
         Range2LastBarMACDBuffer[i] = int(MathRound(rangeValue * 10));
      }
   }

   // OnCalculate done. Return new prev_calculated.
   return rates_total;
}