//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Super trend - CCI based"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "Super trend"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
//--- input parameters
input int                inpPeriod    = 50;            // Cci Period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_TYPICAL; // Cci Price
input int                inpAtrPeriod = 5;             // Atr period
//--- indicator buffers
double val[],valc[],prices[],trend[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,prices,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,trend,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Super trend ("+(string)inpPeriod+")");
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
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      prices[i]  = getPrice(inpPrice,open,close,high,low,i,rates_total);
      double avg = 0; for(int k=0; k<inpPeriod    && (i-k)>=0;   k++) avg +=         prices[i-k];                                            avg /= inpPeriod;
      double dev = 0; for(int k=0; k<inpPeriod    && (i-k)>=0;   k++) dev += MathAbs(prices[i-k]-avg);                                       dev /= inpPeriod;
      double atr = 0; for(int k=0; k<inpAtrPeriod && (i-k-1)>=0; k++) atr += MathMax(high[i-k],close[i-k-1])-MathMin(low[i-k],close[i-k-1]); atr /= inpAtrPeriod;
      double cci = (dev!=0) ?(prices[i]-avg)/(0.015*dev) : 0;
         trend[i] = (cci>0) ? 1 : (cci<0) ? -1 : (i>0) ? trend[i-1] : 0;
         val[i]  = (i>0) ? (trend[i]==1) ? MathMax(low[i]-atr,val[i-1]) : MathMin(high[i]+atr,val[i-1]) : close[i];
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
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
