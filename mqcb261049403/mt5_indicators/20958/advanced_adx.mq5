//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Advanced ADX"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "ADX histogram"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
#property indicator_label2  "ADX"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width2  2
//--- input parameters
input int    inpAdxPeriod  = 32; // ADX period
input double inpAdxLevel   = 20; // ADX significant level
//--- buffers declarations
double val[],valc[],valh[],valhc[];
//--- indicator handles
int _adxHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,valh,INDICATOR_DATA);
   SetIndexBuffer(1,valhc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
//--- indicator levels
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,inpAdxLevel);
//--- indicator short name assignment
   _adxHandle=iADX(_Symbol,0,inpAdxPeriod); if(_adxHandle==INVALID_HANDLE) { return(INIT_FAILED); }
   IndicatorSetString(INDICATOR_SHORTNAME,"Advanced ADX "+(string)inpAdxPeriod+")");
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
   if(BarsCalculated(_adxHandle)<rates_total)  return(prev_calculated);
   double _adxVal[1],_adxpVal[1],_adxmVal[1];
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      int _adxCopied =CopyBuffer(_adxHandle,0,time[i],1,_adxVal);
      int _adxpCopied=CopyBuffer(_adxHandle,1,time[i],1,_adxpVal);
      int _adxmCopied=CopyBuffer(_adxHandle,2,time[i],1,_adxmVal);
      val[i]  = (_adxCopied==1) ? _adxVal[0] : EMPTY_VALUE;
      valc[i] = (_adxmCopied==1 && _adxpCopied==1) ? (_adxmVal[0]<_adxpVal[0]) ? 1 :(_adxmVal[0]>_adxpVal[0]) ? 2 : valc[i-1] : 0;
      valh[i]=val[i];
      valhc[i]=valc[i];
     }
   return (i);
  }
//+------------------------------------------------------------------+
