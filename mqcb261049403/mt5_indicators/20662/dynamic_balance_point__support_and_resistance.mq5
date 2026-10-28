//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Dynamic balance point support & resistance"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDodgerBlue,clrSandyBrown
#property indicator_width1  2
//--- input parameters
input int             inpDbpPeriod   =5;          // Dynamic balance point period
input ENUM_TIMEFRAMES inpDbpTimeFrame=PERIOD_D1;  // Dynamic balance point time frame
//--- indicator buffers
double val[],valc[],dpb[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
   if(inpDbpTimeFrame<=_Period)
     {
      Alert("Or set the time frame parameter to a time frame higher than "+timeFrameToString(_Period));
      Alert("Indicator must be used on time frame lower than "+timeFrameToString(inpDbpTimeFrame));
      return(INIT_FAILED);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,val ,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,dpb ,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Dynamic balance point S/R ("+(string)inpDbpPeriod+")");
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
   int _start=0,i=(int)MathMax(prev_calculated-1,0);
   for(; i<rates_total && !_StopFlag; i++)
     {
      datetime _times[];
      int      _timesCopied= CopyTime(_Symbol,inpDbpTimeFrame,time[i],inpDbpPeriod,_times);
      if(_timesCopied!=inpDbpPeriod) break;
      //
      //---
      //           
      if(time[_start]<_times[0])
        {
         _start=i; for(; _start>1; _start--) if(time[_start]==_times[0] || time[_start-1]<_times[0]) break;
        }
      double hi = high[ArrayMaximum(high,_start,i-_start+1)];
      double lo = low [ArrayMinimum(low ,_start,i-_start+1)];
      dpb[i] = (hi+lo+close[i])/3.0;
      val[i] = (close[i]>dpb[i]) ? MathMax((i>0) ? val[i-1] : dpb[i], dpb[i]) : MathMin((i>0) ? val[i-1] : dpb[i], dpb[i]);
      valc[i] = (close[i]>dpb[i]) ? 0 : 1;
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string          _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};
//
//---
//
string timeFrameToString(int period)
  {
   if(period==PERIOD_CURRENT)
      period=_Period;
   int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);
  }
//+------------------------------------------------------------------+
