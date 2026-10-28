//+------------------------------------------------------------------+
//|                                                Didi_Index_CR.mq4 |
//|                    Copyright 2021, Manuel Alejandro Cercós Pérez |
//|                         https://www.mql5.com/en/users/alexcercos |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Manuel Alejandro Cercós Pérez"
#property link      "https://www.mql5.com/en/users/alexcercos"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
//--- plot Slow Line
#property indicator_label1  "Didi Index"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCadetBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_level1  1

//--- input parameters
input ENUM_MA_METHOD     Method       = MODE_SMA;       // Smoothing Method
input ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE;    // Price Values
input int                MeanPeriod   =8;               // Mean MA Period
input int                SlowPeriod   =20;              // Slow MA Period

//--- indicator buffers
double FinalBuffer[];

//--- indicator handlers

int max_period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0,FinalBuffer,INDICATOR_DATA);
   
   IndicatorSetInteger(INDICATOR_DIGITS, Digits+1);

   max_period=MathMax(MeanPeriod,SlowPeriod);

   IndicatorSetString(INDICATOR_SHORTNAME,"DidiIndex("+IntegerToString(MeanPeriod)+", "+IntegerToString(SlowPeriod)+")");
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
   int limit = MathMin(rates_total-prev_calculated, rates_total-max_period);

   for(int i=limit; i>=0; i--)
   {
      FinalBuffer[i] = 2.0-iMA(Symbol(), PERIOD_CURRENT, SlowPeriod, 0, Method, AppliedPrice, i)/
                           iMA(Symbol(), PERIOD_CURRENT, MeanPeriod, 0, Method, AppliedPrice, i);
   }
   
   return(rates_total);
}
