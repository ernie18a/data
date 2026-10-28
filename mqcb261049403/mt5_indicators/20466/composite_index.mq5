//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Composite index"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "Composite index"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_width1  2
#property indicator_label2  "Composite index 2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_width2  2
#property indicator_label3  "Composite index 3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_width3  2
//--- input parameters
input ENUM_APPLIED_PRICE inpPrice           = PRICE_CLOSE; // Price 
input int                inpRsiSlowPeriod   =  14;         // RSI slow period
input int                inpRsiFastPeriod   =   3;         // RSI fast period
input int                inpMomentumPeriod  =   9;         // Momentum period
input int                inpMaPeriod1       =   3;         // Average period 1
input int                inpMaPeriod2       =  13;         // Average period 2
input int                inpMaPeriod3       =  33;         // Average period 3
//--- buffers declarations
double val1[],val2[],val3[],rsislow[],rsifast[];
//--- indicator handles
int _rsiSlowHandle,_rsiFastHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val1,INDICATOR_DATA);
   SetIndexBuffer(1,val2,INDICATOR_DATA);
   SetIndexBuffer(2,val3,INDICATOR_DATA);
   SetIndexBuffer(3,rsislow,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,rsifast,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   _rsiSlowHandle=iRSI(_Symbol,0,inpRsiSlowPeriod,inpPrice); if(_rsiSlowHandle==INVALID_HANDLE) { return(INIT_FAILED); }
   _rsiFastHandle=iRSI(_Symbol,0,inpRsiFastPeriod,inpPrice); if(_rsiFastHandle==INVALID_HANDLE) { IndicatorRelease(_rsiSlowHandle); return(INIT_FAILED); }
   IndicatorSetString(INDICATOR_SHORTNAME,"Composite index ("+(string)inpRsiSlowPeriod+","+(string)inpRsiFastPeriod+")");
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
   if(BarsCalculated(_rsiFastHandle)<rates_total)  return(prev_calculated);
   if(BarsCalculated(_rsiSlowHandle)<rates_total) return(prev_calculated);
   double _rsiVal[1]; int _rsiCopied;
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      _rsiCopied =CopyBuffer(_rsiSlowHandle,0,time[i],1,_rsiVal); rsislow[i] = (_rsiCopied==1) ? _rsiVal[0] : 0;
      _rsiCopied =CopyBuffer(_rsiFastHandle,0,time[i],1,_rsiVal);
      double RSIDelta  = (i>=inpMomentumPeriod) ? rsislow[i]-rsislow[i-inpMomentumPeriod] : 0;
      double RSIsma    = iSma((_rsiCopied==1?_rsiVal[0]:0),inpMaPeriod1,i,rates_total,0);
      double Composite = RSIDelta+RSIsma;
      val1[i] = Composite;
      val2[i] = iSma(Composite,inpMaPeriod2,i,rates_total,1);
      val3[i] = iSma(Composite,inpMaPeriod3,i,rates_total,1);
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workSma[][3];
//
//---
//
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);
   workSma[r][instanceNo]=price;
   double avg=price; int k=1; for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];
   return(avg/(double)k);
  }
//+------------------------------------------------------------------+
