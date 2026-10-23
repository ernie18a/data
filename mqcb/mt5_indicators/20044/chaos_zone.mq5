//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Chaos zone"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrSilver,clrLimeGreen,clrOrchid
#property indicator_width1  2
#property indicator_minimum 0
#property indicator_maximum 1

double  val[],valc[];
int _aoHandle,_acHandle;
//------------------------------------------------------------------
//
//------------------------------------------------------------------
int OnInit()
  {
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   
      _aoHandle = iAO(_Symbol,0); if (_aoHandle==INVALID_HANDLE) {                              return(INIT_FAILED); }
      _acHandle = iAC(_Symbol,0); if (_acHandle==INVALID_HANDLE) { IndicatorRelease(_aoHandle); return(INIT_FAILED); }
   IndicatorSetString(INDICATOR_SHORTNAME,"Chaos zone");
   return(INIT_SUCCEEDED);
  }
//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   if (BarsCalculated(_aoHandle)<rates_total) return(prev_calculated);
   if (BarsCalculated(_acHandle)<rates_total) return(prev_calculated);
   double _aoVal[2],_acVal[2];
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
        valc[i] = 0;
        int _aoCopied = CopyBuffer(_aoHandle,0,time[i],2,_aoVal);
        int _acCopied = CopyBuffer(_acHandle,0,time[i],2,_acVal);
        if (_aoCopied==2 && _acCopied==2)  
         valc[i] = (_aoVal[1]>_aoVal[0] && _acVal[1]>_acVal[0]) ? 1 : (_aoVal[1]<_aoVal[0] && _acVal[1]<_acVal[0]) ? 2 : 0;
         val[i] = (valc[i]==0) ? 0.5 : 1;
     }
   return(i);
  }