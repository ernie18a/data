//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "WPR support/resistance"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "Support"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLimeGreen
#property indicator_label2  "Resistance"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrOrangeRed
//--- input parameters
input int    inpWprPeriod =  14;   // WPR period
input double inpLevelUp   = -20;   // Level up
input double inpLevelDown = -80;   // Level down
//--- buffers declarations
double sup[],res[],trend[];
//--- indicator handles
int _wprHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,sup,INDICATOR_DATA); PlotIndexSetInteger(0,PLOT_ARROW,158);
   SetIndexBuffer(1,res,INDICATOR_DATA); PlotIndexSetInteger(1,PLOT_ARROW,158);
   SetIndexBuffer(2,trend,INDICATOR_CALCULATIONS);
//--- indicators handles allocation
   _wprHandle=iWPR(_Symbol,0,inpWprPeriod); if(_wprHandle==INVALID_HANDLE) { return(INIT_FAILED); }
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"WPR support/resistance ("+(string)inpWprPeriod+")");
//---
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
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   if(BarsCalculated(_wprHandle)<rates_total) return(prev_calculated);
   double _wprVal[1];
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      trend[i]=(i>0) ? trend[i-1]: 0;
      int _wprCopied=CopyBuffer(_wprHandle,0,time[i],1,_wprVal);
      if(_wprCopied== 1 && _wprVal[0]>inpLevelUp)    trend[i] =  1;
      if(_wprCopied== 1 && _wprVal[0]<inpLevelDown)  trend[i] = -1;
      sup[i] = (i>0) ? sup[i-1] : close[i];
      res[i] = (i>0) ? res[i-1] : close[i];
      if(i>0 && trend[i]!=trend[i-1])
        {
         if(trend[i] ==  1) res[i] = high[i];
         if(trend[i] == -1) sup[i] = low[i];
        }
     }
   return (i);
  }
//+------------------------------------------------------------------+
