//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Fractals chaos oscillator"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrLimeGreen,clrOrchid
#property indicator_width1  2
#property indicator_minimum -1
#property indicator_maximum  1
double  val[],valc[];
int _fractalHandle;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   _fractalHandle=iFractals(_Symbol,0);
   if(_fractalHandle==INVALID_HANDLE) return(INIT_FAILED);
   IndicatorSetString(INDICATOR_SHORTNAME,"Fractals chaos oscillator");
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   if(BarsCalculated(_fractalHandle)<rates_total) return(prev_calculated);
   double _fruVal[1],_frdVal[1];
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      valc[i]=0;
      int _fruCopied = CopyBuffer(_fractalHandle,0,time[i],1,_fruVal);
      int _frdCopied = CopyBuffer(_fractalHandle,1,time[i],1,_frdVal);
      if(_fruCopied==1 && _frdCopied==1)
         valc[i] = (_fruVal[0]!=EMPTY_VALUE) ? 1 : (_frdVal[0]!=EMPTY_VALUE) ? 2 : 0;
      val[i]  = (valc[i]==1) ? 1 : (valc[i]==2) ? -1 : 0;
     }
   return(MathMax(i-3,0));
  }
//+------------------------------------------------------------------+
