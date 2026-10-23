//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Double smoothed EMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
//--- input parameters
input ENUM_APPLIED_PRICE inpPrice  = PRICE_MEDIAN; // Price
input double             inpPeriod = 14;           // Period
//--- indicator buffers
double val[],valc[],work[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,work,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Double smoothed EMA ("+(string)inpPeriod+")");
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
   double _alpha=2.0/(1.0+MathSqrt(MathMax(inpPeriod,1)));

   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      double price=getPrice(inpPrice,open,close,high,low,i,rates_total);
      work[i] = (i>0) ? work[i-1] + _alpha*(price-work[i-1]) : price;
      val[i]  = (i>0) ? val[i-1] + _alpha*(work[i]-val[i-1]) : work[i];
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 2 : (val[i]<val[i-1]) ? 1 : valc[i-1] : 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
      switch(tprice)
        {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
        }
   return(0);
  }
//+------------------------------------------------------------------+
