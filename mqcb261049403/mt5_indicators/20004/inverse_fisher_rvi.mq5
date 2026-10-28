//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Inverse Fisher RVI"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "Inverse Fisher"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_width2  1
//--- input parameters
input int inpRviPeriod=10; // RVI period
//--- buffers declarations
double val[],valc[],signal[],rvi[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,signal,INDICATOR_DATA);
   SetIndexBuffer(3,rvi,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Inverse Fisher RVI ("+(string)inpRviPeriod+")");
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

   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      double num   = 0.0;
      double denom = 0.0;
      for(int k=0; k<inpRviPeriod && (i-k-3)>=0; k++)
        {
         num   += close[i-k]-open[i-k]+2*(close[i-k-1]-open[i-k-1])+2*(close[i-k-2]-open[i-k-2])+close[i-k-3]-open[i-k-3];
         denom += high[i-k]-low[i-k]+2*(high[i-k-1]-low[i-k-1])+2*(high[i-k-2]-low[i-k-2])+high[i-k-3]-low[i-k-3];
        }
      rvi[i]=(denom!=0.0) ? num/denom : 0;
      int    _start = (int)MathMax(i-inpRviPeriod+1,0);
      double _lo    = rvi[ArrayMinimum(rvi,_start,inpRviPeriod)];
      double _hi    = rvi[ArrayMaximum(rvi,_start,inpRviPeriod)];
      double stoRvi = (_hi!=_lo) ? MathMax(MathMin(2.0*((rvi[i]-_lo)/(_hi-_lo)-0.5),0.99999),-0.99999) : 0;
      //---------------
      val[i]    = (MathExp(2*stoRvi)-1)/(MathExp(2*stoRvi)+1);
      signal[i] = (i>0) ? val[i-1] : val[i];
      valc[i]   = (val[i]>signal[i]) ? 1 :(val[i]<signal[i]) ? 2 :(i>0) ? valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
