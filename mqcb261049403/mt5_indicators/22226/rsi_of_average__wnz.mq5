//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "RSI of average - with normalized zones"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "Normalized zones"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrLightBlue,clrPeachPuff
#property indicator_label2  "Normalized rsi"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "RSI of average"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepSkyBlue,clrSandyBrown
#property indicator_width3  3
//--- input parameters
input int                inpRsiPeriod  =  14;         // RSI period
input int                inpMaPeriod   =  32;         // Average period
input ENUM_MA_METHOD     inpMaMethod   = MODE_EMA;    // Average method
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price 
input int                inpNormPeriod = 20;          // Normalization period
//--- buffers declarations
double val[],valc[],valn[],valfu[],valfd[];
//--- indicator handles
int _maHandle,_rsiHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,valfu,INDICATOR_DATA);
   SetIndexBuffer(1,valfd,INDICATOR_DATA);
   SetIndexBuffer(2,valn,INDICATOR_DATA);
   SetIndexBuffer(3,val,INDICATOR_DATA);
   SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   _maHandle=iMA(_Symbol,0,inpMaPeriod,0,inpMaMethod,inpPrice); if(_maHandle==INVALID_HANDLE) { return(INIT_FAILED); }
   _rsiHandle=iRSI(_Symbol,0,inpRsiPeriod,_maHandle); if(_rsiHandle==INVALID_HANDLE) { IndicatorRelease(_maHandle); return(INIT_FAILED); }
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI of "+StringSubstr(EnumToString(inpMaMethod),5,-1)+" ("+(string)inpRsiPeriod+","+(string)inpMaPeriod+")");
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
   double _rsiVal[1];
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      int _rsiCopied=CopyBuffer(_rsiHandle,0,time[i],1,_rsiVal);
      val[i]  = (_rsiCopied==1) ? _rsiVal[0]-50 : EMPTY_VALUE;
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
      valn[i] = 0;
         int _start = MathMax(i-inpNormPeriod+1,0);
         if (val[i]>0)
         {         
            double hi = val[ArrayMaximum(val,_start,inpNormPeriod)];
               if (hi!=0)
                        valn[i] = 50*val[i]/hi;
         }
         if (val[i]<0)
         {         
            double lo = val[ArrayMinimum(val,_start,inpNormPeriod)];
               if (lo!=0)
                        valn[i] = 50*val[i]/(-lo);
         }
         valfu[i] = valn[i];
         valfd[i] = val[i];
     }
   return (i);
  }
//+------------------------------------------------------------------+
