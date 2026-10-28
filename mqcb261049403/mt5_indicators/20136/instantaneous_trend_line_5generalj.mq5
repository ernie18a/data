//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "Instantaneous trend line"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDeepPink,clrLimeGreen
#property indicator_width1  2
//--- input parameters
input ENUM_APPLIED_PRICE inpPrice  = PRICE_MEDIAN; // Price
input double             inpPeriod = 27;           // Period
//--- indicator buffers
double itrend[],itrendc[],prices[],smooth[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,itrend,INDICATOR_DATA);
   SetIndexBuffer(1,itrendc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,prices,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,smooth,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Instantaneous trend line ("+(string)inpPeriod+")");
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
   double alpha=2/(1+inpPeriod);
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      prices[i]  = getPrice(inpPrice,open,close,high,low,i,rates_total);
      smooth[i]  = (i>2) ? (prices[i] + 2*prices[i-1] + 2*prices[i-2] + prices[i-3])/6 : prices[i];
      itrend[i]  = (i>1) ? (alpha-alpha*alpha/4)*smooth[i]+ 0.5*alpha*alpha*smooth[i-1] - (alpha-0.75*alpha*alpha)*smooth[i-2] + 2*(1 - alpha)*itrend[i-1] - (1-alpha)*(1-alpha)*itrend[i-2] : itrend[i];
      itrendc[i] = (i>1) ? (itrend[i]>itrend[i-1]) ? 1 : 0 : 0;
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
