//+------------------------------------------------------------------+
//|                             BBMA ZoneZeroLoss (ZZL) Oma Ally.mq5 |
//|                            Copyright © 2025, Alexander Piechotta |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2025, Alexander Piechotta"
#property link      "alepie@outlook.de"
#property version   "1.0"

#include <MovingAverages.mqh>

#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   2

//--- Histogram
#property indicator_label1  "Zero Loss Zone UP"
#property indicator_type1   DRAW_COLOR_HISTOGRAM

#property indicator_label2  "Zero Loss Zone DOWN"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
//---
#property indicator_color1  clrNONE,clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  5

#property indicator_color2  clrNONE,clrGreen,clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  5

int     InpBandsPeriod=20;  // Period
int     InpEMA50Period=50;
int     InpMa5Period=5; // Period
int     InpMa10Period=10;

//--- buffer of values
double         HistogramBufferUp[];
double         HistogramColorsUp[];

double         HistogramBufferDown[];
double         HistogramColorDown[];

double         Mahi5Buffer[];
double         Mahi10Buffer[];

double         Malo5Buffer[];
double         Malo10Buffer[];

double         MidBBBuffer[];
double         EMA50Buffer[];
//---
int m_digits=-1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_digits=Digits();
   if(m_digits<0)
      m_digits=0;

//--- indicator buffers mapping

   SetIndexBuffer(0,HistogramBufferUp,INDICATOR_DATA);
   SetIndexBuffer(1,HistogramColorsUp,INDICATOR_COLOR_INDEX);

   SetIndexBuffer(2,HistogramBufferDown,INDICATOR_DATA);
   SetIndexBuffer(3,HistogramColorDown,INDICATOR_COLOR_INDEX);

   SetIndexBuffer(4,MidBBBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,EMA50Buffer,INDICATOR_CALCULATIONS);

   SetIndexBuffer(6,Mahi10Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,Mahi5Buffer,INDICATOR_CALCULATIONS);

   SetIndexBuffer(8,Malo10Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,Malo5Buffer,INDICATOR_CALCULATIONS);

//---
   IndicatorSetDouble(INDICATOR_MINIMUM,0.0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,1.0);
//---
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   IndicatorSetString(INDICATOR_SHORTNAME,"BBMA ZoneZeroLoss (ZZL) Oma Ally");
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
//---
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
//---
   SimpleMAOnBuffer(rates_total, prev_calculated, 0, InpBandsPeriod, close, MidBBBuffer);
   ExponentialMAOnBuffer(rates_total, prev_calculated, 0, InpEMA50Period, close, EMA50Buffer);

   LinearWeightedMAOnBuffer(rates_total, prev_calculated, 0, InpMa10Period, high, Mahi10Buffer);
   LinearWeightedMAOnBuffer(rates_total, prev_calculated, 0, InpMa5Period, high, Mahi5Buffer);

   LinearWeightedMAOnBuffer(rates_total, prev_calculated, 0, InpMa10Period, low, Malo10Buffer);
   LinearWeightedMAOnBuffer(rates_total, prev_calculated, 0, InpMa5Period, low, Malo5Buffer);

   for(int i=limit;i<rates_total;i++)
     {
      HistogramBufferDown[i]=0;
      HistogramColorDown[i]=0;
      HistogramBufferUp[i]=0;
      HistogramColorsUp[i]=0;

      //---
      if(EMA50Buffer[i]>=MidBBBuffer[i] && Mahi10Buffer[i]<=MidBBBuffer[i] && Mahi5Buffer[i]<=MidBBBuffer[i] && Malo10Buffer[i]<=MidBBBuffer[i] && Malo5Buffer[i]<=MidBBBuffer[i])
        {
         HistogramBufferDown[i]=1;
         HistogramColorDown[i]=2;
        }

      if(EMA50Buffer[i]<=MidBBBuffer[i] && Mahi10Buffer[i]>=MidBBBuffer[i] && Mahi5Buffer[i]>=MidBBBuffer[i] && Malo10Buffer[i]>=MidBBBuffer[i] && Malo5Buffer[i]>=MidBBBuffer[i])
        {
         HistogramBufferUp[i]=1;
         HistogramColorsUp[i]=1;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
