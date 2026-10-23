//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Stochastic DeMarker"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "Stochastic DeMarker"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_width2  1
#property indicator_maximum 1
#property indicator_minimum 0
#property indicator_level1  0.7
#property indicator_level2  0.3
//--- input parameters
input int inpDemPeriod=14; // DeMarker period
//--- buffers declarations
double val[],valc[],signal[],dem[],work[];
//--- indicator(s) handles
int _demHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,signal,INDICATOR_DATA);
   SetIndexBuffer(3,dem,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,work,INDICATOR_CALCULATIONS);
//--- indicator handle creation  
   _demHandle=iDeMarker(_Symbol,0,inpDemPeriod);
   if(_demHandle==INVALID_HANDLE) return(INIT_FAILED);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic DeMarker ("+(string)inpDemPeriod+")");
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
   if (Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   if (BarsCalculated(_demHandle)<rates_total) return(prev_calculated);
   double _demVal[1];
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      int _demCopied= CopyBuffer(_demHandle,0,time[i],1,_demVal);
      if(_demCopied!=1) return(prev_calculated);
      dem[i]=_demVal[0];
      int    _start = (int)MathMax(i-inpDemPeriod+1,0);
      double _lo    = dem[ArrayMinimum(dem,_start,inpDemPeriod)];
      double _hi    = dem[ArrayMaximum(dem,_start,inpDemPeriod)];
      //---------------
      work[i]   = (_hi!=_lo) ? (dem[i]-_lo)/(_hi-_lo) : 0;
      val[i]    = (i>3) ? (4*work[i]+3*work[i-1]+2*work[i-2]+work[i-3])/10 : 0;
      signal[i] = (i>0) ? 0.96*val[i-1]+0.02 : val[i];
      valc[i]   = (val[i]>signal[i]) ? 1 :(val[i]<signal[i]) ? 2 :(i>0) ? valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
