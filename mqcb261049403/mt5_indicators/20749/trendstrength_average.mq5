//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "TrendStrength average"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "average"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_label2  "trend up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_width2  2
#property indicator_label3  "trend down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSandyBrown
#property indicator_width3  2
//--- input parameters
input int                inpMaPeriod    = 14;          // Average period
input ENUM_MA_METHOD     inpMaMethod    = MODE_SMA;    // Average method
input double             inpStrength    = 4.236;       // Strength
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE; // Price

//--- indicator buffers
double avg[],valu[],vald[],smin[],smax[],trend[];
int _maHandle;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,avg,INDICATOR_DATA);
   SetIndexBuffer(1,valu,INDICATOR_DATA);
   SetIndexBuffer(2,vald,INDICATOR_DATA);
   SetIndexBuffer(3,smin,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,smax,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,trend,INDICATOR_CALCULATIONS);
//--- handle allocation
   _maHandle=iMA(_Symbol,0,inpMaPeriod,0,inpMaMethod,inpPrice); if(_maHandle==INVALID_HANDLE) { return(INIT_FAILED); }
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"TrendStrength average ("+(string)inpMaPeriod+","+(string)inpStrength+")");
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
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      double _maVal[1];
      int    _maValCopied=CopyBuffer(_maHandle,0,time[i],1,_maVal);
      avg[i]   = (_maValCopied==1) ? _maVal[0] : 0;
      valu[i]  = EMPTY_VALUE;
      vald[i]  = EMPTY_VALUE;
      trend[i] = 0;
      if(i>0)
        {
         double havg = avg[i];
         double lavg = avg[i];
         if(avg[i] > avg[i-1]) { havg = avg[i];   lavg = avg[i-1]; }
         if(avg[i] < avg[i-1]) { havg = avg[i-1]; lavg = avg[i];   }

         double delta=havg-lavg;
         smin[i]   = avg[i] - inpStrength*delta;
         smax[i]   = avg[i] + inpStrength*delta;
         trend[i]  = trend[i-1];
         if(avg[i]>smax[i-1]) trend[i]= 1;
         if(avg[i]<smin[i-1]) trend[i]=-1;
         if(trend[i]>0) { if(smin[i]<smin[i-1]) smin[i]=smin[i-1]; valu[i]=smin[i]; }
         if(trend[i]<0) { if(smax[i]>smax[i-1]) smax[i]=smax[i-1]; vald[i]=smax[i]; }
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
