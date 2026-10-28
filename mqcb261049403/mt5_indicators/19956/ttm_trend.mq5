//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "TTM trend"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "TTM trend"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrSandyBrown
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//
//--- input parameters
//
input int inpPeriod=10; // Look back period
//
//--- buffers and global variables declarations
//
double valu[],vald[],valc[],haOpen[],haClose[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,valu,INDICATOR_DATA);
   SetIndexBuffer(1,vald,INDICATOR_DATA);
   SetIndexBuffer(2,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,haOpen,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,haClose,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"TTP trend ("+(string)inpPeriod+")");
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

   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      haOpen[i]  = (i>0) ? (haOpen[i-1]+haClose[i-1])/2.0 : (open[i]+close[i])/(double)2.0;
      haClose[i] = (open[i]+high[i]+low[i]+close[i])/4.0;
      valu[i]    = high[i];
      vald[i]    = low[i];
      valc[i]    = (haClose[i] > haOpen[i]) ? 1 : (haClose[i] < haOpen[i]) ? 2 : (i>0-1) ? valc[i-1] : 0;
      for(int k=1; k<=inpPeriod && (i-k)>=0; k++)
        {
         if(haOpen[i] <=MathMax(haOpen[i-k],haClose[i-k]) &&
            haOpen[i] >=MathMin(haOpen[i-k],haClose[i-k]) &&
            haClose[i]<=MathMax(haOpen[i-k],haClose[i-k]) &&
            haClose[i]>=MathMin(haOpen[i-k],haClose[i-k]) )
            valc[i]=valc[i-k];
        }
     }
   return (i);
  }
//+------------------------------------------------------------------+
