//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "MACD of average"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "MACD of average"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
#property indicator_label2  "MACD of average"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_DOT
//--- input parameters
enum enColorOn
  {
   color_onSlope, // Change color on MACD slope change
   color_onSignal // Change color on MACD crossing signal line
  };
input int                inpFastPeriod   = 12;          // MACD fast period
input int                inpSlowPeriod   = 26;          // MACD slow period
input int                inpSignalPeriod = 9;           // MACD signal period
input int                inpMaPeriod     = 5;           // Average period
input ENUM_MA_METHOD     inpMaMethod     = MODE_EMA;    // Average method
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price 
input enColorOn          inpColorOn=color_onSignal; // Color change on :
//--- buffers declarations
double val[],valc[],signal[];
//--- indicator handles
int _maHandle,_macdHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,signal,INDICATOR_DATA);
//--- indicator short name assignment
   _maHandle=iMA(_Symbol,0,inpMaPeriod,0,inpMaMethod,inpPrice);
   if(_maHandle==INVALID_HANDLE)
      return(INIT_FAILED);
   _macdHandle=iMACD(_Symbol,0,inpFastPeriod,inpSlowPeriod,inpSignalPeriod,_maHandle); if(_macdHandle==INVALID_HANDLE)
     {
      IndicatorRelease(_maHandle);
      return(INIT_FAILED);
     }
   IndicatorSetString(INDICATOR_SHORTNAME,"MACD of "+StringSubstr(EnumToString(inpMaMethod),5,-1)+" ("+(string)inpFastPeriod+","+(string)inpSlowPeriod+","+(string)inpSignalPeriod+","+(string)inpMaPeriod+")");
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
   if(Bars(_Symbol,_Period)<rates_total)
      return(prev_calculated);
   if(BarsCalculated(_maHandle)<rates_total)
      return(prev_calculated);
   if(BarsCalculated(_macdHandle)<rates_total)
      return(prev_calculated);
//---
   double _macdVal[1],_signVal[1];
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      int _macdCopied=CopyBuffer(_macdHandle,0,time[i],1,_macdVal);
      int _signCopied=CopyBuffer(_macdHandle,1,time[i],1,_signVal);
      val[i]=(_macdCopied==1 && _signCopied) ? _macdVal[0]: EMPTY_VALUE;
      signal[i]=(_macdCopied==1 && _signCopied) ? _signVal[0]: EMPTY_VALUE;
      if(inpColorOn==color_onSlope)
         valc[i]=(i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
      else
         valc[i]=(val[i]>signal[i]) ? 1 :(val[i]<signal[i]) ? 2 :(i>0) ? valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
