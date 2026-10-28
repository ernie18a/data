//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Trend direction and force"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "No trend zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro
#property indicator_label2  "Trend direction and force"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrSandyBrown,clrDeepSkyBlue
#property indicator_width2  2
//
//--- input parameters
//
input int    trendPeriod  = 20;      // Trend period
input double TriggerUp    =  0.05;   // Trigger up level
input double TriggerDown  = -0.05;   // Trigger down level
//
//--- buffers and global variables declarations
//
double val[],valc[],levup[],levdn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,levup,INDICATOR_DATA);
   SetIndexBuffer(1,levdn,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend direction and force ("+(string)trendPeriod+")");
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
double workTrend[][3];
#define _MMA   0
#define _SMMA  1
#define _TDF   2
//
//---
//
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   if(ArrayRange(workTrend,0)!=rates_total) ArrayResize(workTrend,rates_total);
   double _alpha=2.0/(1+trendPeriod);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
         workTrend[i][_MMA]  = (i>0) ? workTrend[i-1][_MMA]+_alpha*(close[i]-workTrend[i-1][_MMA]) : close[i];
         workTrend[i][_SMMA] = (i>0) ? workTrend[i-1][_SMMA]+_alpha*(workTrend[i][_MMA]-workTrend[i-1][_SMMA]) : workTrend[i][_MMA];
            double impetmma  = (i>0) ? workTrend[i][_MMA]  - workTrend[i-1][_MMA]  : 0;
            double impetsmma = (i>0) ? workTrend[i][_SMMA] - workTrend[i-1][_SMMA] : 0;
            double divma     = MathAbs(workTrend[i][_MMA]-workTrend[i][_SMMA])/_Point;
            double averimpet = (impetmma+impetsmma)/(2*_Point);
         workTrend[i][_TDF]  = divma*MathPow(averimpet,3);

         //
         //---
         //
               
         double absValue = 0;  for (int k=0; k<trendPeriod*3 && (i-k)>=0; k++)  absValue = MathMax(absValue,MathAbs(workTrend[i-k][_TDF]));
         val[i] = (absValue > 0) ? workTrend[i][_TDF]/absValue : 0;
         levup[i] = TriggerUp;
         levdn[i] = TriggerDown;
         valc[i]  = (val[i] > levup[i]) ? 2 : (val[i] < levdn[i]) ? 1 : 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
