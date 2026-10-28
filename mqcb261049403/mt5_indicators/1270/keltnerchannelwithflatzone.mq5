//+------------------------------------------------------------------+
//|                                   KeltnerChannelWithFlatZone.mq5 |
//|                                            Copyright 2012, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Rone."
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "Keltner Channel With Flat Zone indicator"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots   8
//--- plot BullFill
#property indicator_label1  "BullFill"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrMediumTurquoise
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot BearFill
#property indicator_label2  "BearFill"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  clrDarkSalmon
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot FlatFill
#property indicator_label3  "FlatFill"
#property indicator_type3   DRAW_FILLING
#property indicator_color3  clrGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Ma
#property indicator_label4  "MA"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkGray
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot FlatUp
#property indicator_label5  "FlatUp"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrBlue
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot FlatDown
#property indicator_label6  "FlatDown"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot Bull
#property indicator_label7  "Bull"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrBlue
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot Bear
#property indicator_label8  "Bear"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrRed
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- input parameters
input int            InpMaPeriod = 10;          // МА period
input ENUM_MA_METHOD InpMaMethod = MODE_EMA;    // МА method
input int            InpAtrPeriod = 10;         // Period 
input double         InpFlatMultiplier = 0.3;   // Ratio of flat
input double         InpBandMultiplier = 2.0;   // Ratio of channel boundaries
//--- indicator buffers
double         BullFillBuffer1[];
double         BullFillBuffer2[];
double         BearFillBuffer1[];
double         BearFillBuffer2[];
double         FlatFillBuffer1[];
double         FlatFillBuffer2[];
double         MaBuffer[];
double         FlatUpBuffer[];
double         FlatDownBuffer[];
double         BullBuffer[];
double         BearBuffer[];
double         AtrBuffer[];
//---
int            minRequiredBars;
int            maHandle;
int            atrHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//---
   minRequiredBars = MathMax(InpMaPeriod, InpAtrPeriod);
//---
   maHandle = iMA(_Symbol, _Period, InpMaPeriod, 0, InpMaMethod, PRICE_CLOSE);
   if ( maHandle < 0 ) {
      Print("Failed to create the МА indicator");
      return(-1);
   }
   atrHandle = iATR(_Symbol, _Period, InpAtrPeriod);
   if ( atrHandle < 0 ) {
      Print("Failed to create the ATR indicator");
      return(-1);
   }
//--- indicator buffers mapping
   SetIndexBuffer(0,BullFillBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,BullFillBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,BearFillBuffer1,INDICATOR_DATA);
   SetIndexBuffer(3,BearFillBuffer2,INDICATOR_DATA);
   SetIndexBuffer(4,FlatFillBuffer1,INDICATOR_DATA);
   SetIndexBuffer(5,FlatFillBuffer2,INDICATOR_DATA);
   SetIndexBuffer(6,MaBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,FlatUpBuffer,INDICATOR_DATA);
   SetIndexBuffer(8,FlatDownBuffer,INDICATOR_DATA);
   SetIndexBuffer(9,BullBuffer,INDICATOR_DATA);
   SetIndexBuffer(10,BearBuffer,INDICATOR_DATA);
   SetIndexBuffer(11, AtrBuffer, INDICATOR_CALCULATIONS);
//---
   for ( int i = 0; i < 8; i++ ) {
      PlotIndexSetInteger(i, PLOT_DRAW_BEGIN, minRequiredBars);
      PlotIndexSetInteger(i, PLOT_SHIFT, 0);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0);
   }
//---
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits+1);
//---
   IndicatorSetString(INDICATOR_SHORTNAME, "Keltner Channel with Flat Zone ("+(string)InpMaPeriod+", "+(string)InpAtrPeriod+", "+
      DoubleToString(InpFlatMultiplier, 2)+", "+DoubleToString(InpBandMultiplier, 2)+")");   
//---
   return(0);
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
//---
   int startBar, calculated, toCopy;
//---
   if ( rates_total < minRequiredBars ) {
      Print("Not enough data to calculate");
      return(0);
   }
//---
   calculated = BarsCalculated(maHandle);
   if ( calculated < rates_total ) {
      Print("Not all data of the МА are calculated. Error #", GetLastError());
      return(0);
   }
   calculated = BarsCalculated(atrHandle);
   if ( calculated < rates_total ) {
      Print("Not all data of the ATR are calculated. Error #", GetLastError());
      return(0);
   }
//---
   if ( prev_calculated > rates_total || prev_calculated <= 0 ) {
      toCopy = rates_total;
      startBar = minRequiredBars;
   } else {
      toCopy = rates_total - prev_calculated;
      if ( prev_calculated > 0 ) {
         toCopy += 1;
      }
      startBar = prev_calculated - 1;
   }
//---
   if ( CopyBuffer(maHandle, 0, 0, toCopy, MaBuffer) < toCopy 
      || CopyBuffer(atrHandle, 0, 0, toCopy, AtrBuffer) < toCopy )
   {
      Print("Indicator data copy error");
      return(0);
   }
//---
   for ( int bar = startBar; bar < rates_total && !IsStopped(); bar++ ) {
      double maValue = MaBuffer[bar];
      double atrValue = AtrBuffer[bar];
      //---
      BullBuffer[bar] = maValue + atrValue * InpBandMultiplier;
      BearBuffer[bar] = maValue - atrValue * InpBandMultiplier;
      FlatUpBuffer[bar] = maValue + atrValue * InpFlatMultiplier;
      FlatDownBuffer[bar] = maValue - atrValue * InpFlatMultiplier;
      FlatFillBuffer1[bar] = FlatUpBuffer[bar];
      FlatFillBuffer2[bar] = FlatDownBuffer[bar];
      BullFillBuffer1[bar] = BullBuffer[bar];
      BullFillBuffer2[bar] = FlatUpBuffer[bar];
      BearFillBuffer1[bar] = FlatDownBuffer[bar];
      BearFillBuffer2[bar] = BearBuffer[bar];
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
