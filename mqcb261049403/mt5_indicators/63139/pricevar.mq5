//+------------------------------------------------------------------+
//|                                                     PriceVar.mq5 |
//|                                                  Henrique Araújo |
//+------------------------------------------------------------------+
#property copyright "Henrique Araújo"
#property version   "1.01"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot Var
#property indicator_label1  "Var"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrRed,clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- indicator buffers
double         VarBuffer[];
double         VarColors[];
double         ma[];

input    uint iPeriod = 25;      //Period

#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,VarBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,VarColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,ma,INDICATOR_CALCULATIONS);
   IndicatorSetString(INDICATOR_SHORTNAME,"PriceVar %");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[])
  {
   int start = (prev_calculated > 1) ? prev_calculated - 1 : 0;

   SimpleMAOnBuffer(rates_total, prev_calculated, 0, iPeriod, close, ma);

   for(int i=start; i<rates_total && !IsStopped(); i++)
     {
      if(ma[i] <= 0) continue;

      if(close[i] > ma[i])
         VarBuffer[i] = ((high[i] - ma[i]) / ma[i]) * 100.0;  // %
      else if(close[i] < ma[i])
         VarBuffer[i] = ((low[i] - ma[i]) / ma[i]) * 100.0;   // %
      else
         VarBuffer[i] = 0;

      if(VarBuffer[i] >= 0)
         VarColors[i] = 1; //green
      else
         VarColors[i] = 0; //red
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
