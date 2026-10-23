//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Zone trade histogram"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDeepSkyBlue,clrSandyBrown,clrSilver,clrSilver
#property indicator_width1  2
#property indicator_minimum 0
#property indicator_maximum 1
//
//--- buffers and global variables declarations
//
double histo[],cancl[];
int _acHandle,_aoHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,histo,INDICATOR_DATA);
   SetIndexBuffer(1,cancl,INDICATOR_COLOR_INDEX);
   _acHandle=iAC(_Symbol,0); if(_acHandle==INVALID_HANDLE) { return(INIT_FAILED); }
   _aoHandle=iAO(_Symbol,0); if(_aoHandle==INVALID_HANDLE) { return(INIT_FAILED); }
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Zone trade histogram");
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
#define displayLine   0
#define displayBars   1
#define displayCandle 2
//+------------------------------------------------------------------+
//|                                                                  |
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
   if(BarsCalculated(_acHandle)<rates_total)  return(prev_calculated);
   if(BarsCalculated(_aoHandle)<rates_total)  return(prev_calculated);

//
//---
//

   double _acValues[2],_aoValues[2];
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      int _acValuesCopied = CopyBuffer(_acHandle,0,time[i],2,_acValues); if(_acValuesCopied!=2) break;
      int _aoValuesCopied = CopyBuffer(_aoHandle,0,time[i],2,_aoValues); if(_aoValuesCopied!=2) break;
      int acD = 0; if(_acValues[1]>_acValues[0]) acD=1; if(_acValues[1]<_acValues[0]) acD=2;
      int aoD = 0; if(_aoValues[1]>_aoValues[0]) aoD=1; if(_aoValues[1]<_aoValues[0]) aoD=2;

      histo[i] = 1;
      cancl[i] = (acD==1 && aoD==1) ? 0 : (acD==2 && aoD==2) ? 1 : (acD==1 && aoD==2)? 2 : 3;
     }
   return (i);
  }
//+------------------------------------------------------------------+
