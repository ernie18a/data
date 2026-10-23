//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Range oscillator"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Range oscillator"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrSkyBlue,clrDodgerBlue
#property indicator_width1  2
#property indicator_minimum 0
#property indicator_maximum 100
//--- input parameters
input int  inpRngPeriod = 40; // Range oscillator period
//--- buffers declarations
double val[],valc[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Range oscillator ("+(string)inpRngPeriod+")");
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
      int    _start = MathMax(i-inpRngPeriod+1,0);
      double _max   = high[ArrayMaximum(high,_start,inpRngPeriod)];
      double _min   = low [ArrayMinimum(low ,_start,inpRngPeriod)];
      double _med   = (high[i]+low[i])/2;
      val[i]  = (_max!=_min) ? 100*(_med-_min)/(_max-_min) : 0;
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
     }
   return (i);
  }