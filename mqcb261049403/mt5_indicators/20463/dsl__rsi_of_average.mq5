//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Dsl - RSI of average"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "Dsl zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'230,230,230'
#property indicator_label2  "RSI of average"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width2  2
//--- input parameters
input int                inpRsiPeriod       =  14;         // RSI period
input int                inpRsiSignalPeriod =  9;          // Dsl signal period
input int                inpMaPeriod        =  32;         // Average period
input ENUM_MA_METHOD     inpMaMethod        = MODE_EMA;    // Average method
input ENUM_APPLIED_PRICE inpPrice           = PRICE_CLOSE; // Price 
//--- buffers declarations
double val[],valc[],dslup[],dsldn[];
//--- indicator handles
int _maHandle,_rsiHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,dslup,INDICATOR_DATA);
   SetIndexBuffer(1,dsldn,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   _maHandle=iMA(_Symbol,0,inpMaPeriod,0,inpMaMethod,inpPrice); if(_maHandle==INVALID_HANDLE) { return(INIT_FAILED); }
   _rsiHandle=iRSI(_Symbol,0,inpRsiPeriod,_maHandle); if(_rsiHandle==INVALID_HANDLE) { IndicatorRelease(_maHandle); return(INIT_FAILED); }
   IndicatorSetString(INDICATOR_SHORTNAME,"Dsl - RSI of "+StringSubstr(EnumToString(inpMaMethod),5,-1)+" ("+(string)inpRsiPeriod+","+(string)inpMaPeriod+")");
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
   if(BarsCalculated(_maHandle)<rates_total)  return(prev_calculated);
   if(BarsCalculated(_rsiHandle)<rates_total) return(prev_calculated);
   double _alpha=2.0/(1+inpRsiSignalPeriod);
   double _rsiVal[1];
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      int _rsiCopied=CopyBuffer(_rsiHandle,0,time[i],1,_rsiVal);
      val[i]   = (_rsiCopied==1) ? _rsiVal[0] : EMPTY_VALUE;
      dslup[i] = (i>0) ? (val[i]>50) ? dslup[i-1]+_alpha*(val[i]-dslup[i-1]) : dslup[i-1] : 0;
      dsldn[i] = (i>0) ? (val[i]<50) ? dsldn[i-1]+_alpha*(val[i]-dsldn[i-1]) : dsldn[i-1] : 0;
      valc[i]  = (val[i]>dslup[i]) ? 1 :(val[i]<dsldn[i]) ? 2 : 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
