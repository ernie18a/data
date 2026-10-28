//+------------------------------------------------------------------+
//|                                      Volatility Step Channel.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+

#property copyright "Copyright 2025, phade, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   4

//--- movement from resistance
#property indicator_label1  "Price shift from resistance"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_width1  1
//--- movement from support
#property indicator_label2 "Price shift from support"
#property indicator_type2   DRAW_LINE
#property indicator_color2 clrGray
#property indicator_style2 STYLE_DOT
#property indicator_width2  1
//--- plot High
#property indicator_label3 "High"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Low
#property indicator_label4  "Low"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

//--- input parameters
input int InpATRPeriod = 14;         // ATR Period
input double InpATRMultiplier = 0.5; // ATR Multiplier
input int length = 10;               // Length
input bool rigid_channel = false; // Rigid channel lines

//--- indicator buffers
double         HighBuffer[];         // Raw highest high
double         LowBuffer[];          // Raw lowest low
double         PriceShiftHigh[];     // Adjusted upper band (shift from resistance)
double         PriceShiftLow[];      // Adjusted lower band (shift from support)
// Get ATR values
double atr[];

int atrHandle = INVALID_HANDLE;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, PriceShiftHigh, INDICATOR_DATA);
   SetIndexBuffer(1, PriceShiftLow, INDICATOR_DATA);
   SetIndexBuffer(2, HighBuffer, INDICATOR_DATA);  // sell stop loss location
   SetIndexBuffer(3, LowBuffer, INDICATOR_DATA);  // buy stop loss location
   SetIndexBuffer(4, atr, INDICATOR_CALCULATIONS);

   atrHandle = iATR(_Symbol, _Period, InpATRPeriod);
   if(atrHandle == INVALID_HANDLE)
     {
      Print("Error: Failed to create ATR handle");
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   int to_copy = (prev_calculated <= 0) ? rates_total : rates_total - prev_calculated + 1;

   if(CopyBuffer(atrHandle, 0, 0, to_copy, atr) <= 0)
     {
      Print("Error: Failed to copy ATR data, error code: ", GetLastError());
      return(0);
     }

   int start = (prev_calculated == 0) ? length - 1 : prev_calculated - 1;

   for(int i = start; i < rates_total; i++)
     {
      double highestHigh = -DBL_MAX;
      double lowestLow = DBL_MAX;
      int j_high = -1;
      int j_low = -1;

      for(int j = 0; j < length; j++)
        {
         if(i - j < 0)
            continue;

         if(high[i - j] > highestHigh)
           {
            highestHigh = high[i - j];
            j_high = j;
           }

         if(low[i - j] < lowestLow)
           {
            lowestLow = low[i - j];
            j_low = j;
           }
        }

      if(j_high == -1 || j_low == -1)
         continue;

      double atr_high_offset = atr[i - j_high] * InpATRMultiplier;
      double atr_low_offset = atr[i - j_low] * InpATRMultiplier;

      HighBuffer[i] = highestHigh + atr_high_offset;
      LowBuffer[i] = lowestLow - atr_low_offset;
      PriceShiftHigh[i] = HighBuffer[i];
      PriceShiftLow[i] = LowBuffer[i];

      if(HighBuffer[i] != HighBuffer[i-1])
        {
         HighBuffer[i-1] = EMPTY_VALUE;
         
         if(rigid_channel)
            PriceShiftHigh[i-1] = PriceShiftHigh[i-2];
        }
      if(LowBuffer[i] != LowBuffer[i-1])
        {
         LowBuffer[i-1] = EMPTY_VALUE;
         
         if(rigid_channel)
            PriceShiftLow[i-1] = PriceShiftLow[i-2];
        }
     }

   return (rates_total);
  }
