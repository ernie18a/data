//+------------------------------------------------------------------+
//|                                                      Coppock.mq5 |
//|                              Based on Coppock.mq4 by Robert Hill |
//|                                  Copyright © 2010, EarnForex.com |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, EarnForex.com"
#property link      "http://www.earnforex.com"
#property version   "1.0"
#property strict
#property description "Classical Coppock indicator. Should be applied on monthly timeframe."
#property description "Periods shouldn't be changed. Change timeframe and parameters for"
#property description "experimental Coppock usage. Works only with Weighted MA."
//---- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_color1  Red
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_style1  STYLE_SOLID
//---- indicator parameters
input int ROC1Period = 14;
input int ROC2Period = 11;
input int MAPeriod   = 10;
//---- indicator buffers
double Coppock[];
double ROCSum[];
//---- variables
int  DrawBegin;
bool FirstTime=true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- The longest period
   DrawBegin=MathMax(ROC1Period,ROC2Period)+MAPeriod;
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,DrawBegin);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- indicator buffers mapping
   SetIndexBuffer(0,Coppock,INDICATOR_DATA);
   SetIndexBuffer(1,ROCSum,INDICATOR_CALCULATIONS);
//----
   ArraySetAsSeries(Coppock,true);
   ArraySetAsSeries(ROCSum,true);
//----
   IndicatorSetString(INDICATOR_SHORTNAME,"Coppock("+(string)ROC1Period+", "+(string)ROC2Period+")");
   PlotIndexSetString(0,PLOT_LABEL,"Coppock");
  }
//+------------------------------------------------------------------+
//| Coppock                                                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &Close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   ArraySetAsSeries(Close,true);
//----
   int limit,i;
//----
   int counted_bars=prev_calculated;
//---- check for possible errors
   if(counted_bars < 0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=rates_total-counted_bars;
   if(limit-rates_total<DrawBegin) limit=rates_total-DrawBegin;
//---- Rate of Change calculation
   for(i=0; i<limit; i++)
      ROCSum[i]=(Close[i]-Close[i+ROC1Period])/Close[i+ROC1Period]+(Close[i]-Close[i+ROC2Period])/Close[i+ROC2Period];
//----
   CalculateLWMA(0,MAPeriod,ROCSum,limit);
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateLWMA(int begin,int period,const double &price[],int big_limit)
  {
   int        i,limit;
   static int weightsum;
   double     sum;
//--- first calculation or number of bars was changed
   limit=period+begin;
   if(FirstTime)
     {
      weightsum=0;
      //--- set empty value for first limit bars
      for(i=begin; i<limit; i++) Coppock[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin; i<limit; i++)
        {
         int k=limit-i;
         weightsum+=k;
         firstValue+=k*price[i];
        }
      firstValue/=(double)weightsum;
      Coppock[limit]=firstValue;
      FirstTime=false;
     }
//--- main loop
   for(i=begin; i<big_limit; i++)
     {
      sum=0;
      for(int j=0; j<period; j++)
         sum+=(period-j)*price[i+j];
      Coppock[i]=sum/weightsum;
     }
  }
//+------------------------------------------------------------------+
