//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrDeepPink,clrLimeGreen
#property indicator_label2  "Instantaneous trend line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_width2  2
#property indicator_label3  "Signal line"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_width3  1
//--- input parameters
input ENUM_APPLIED_PRICE inpPrice = PRICE_MEDIAN; // Price
input double             inpAlpha = 0.07;         // Alpha
//--- indicator buffers
double fillu[],filld[],itrend[],signal[],prices[],smooth[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0,fillu  ,INDICATOR_DATA);
   SetIndexBuffer(1,filld  ,INDICATOR_DATA);
   SetIndexBuffer(2,itrend ,INDICATOR_DATA); 
   SetIndexBuffer(3,signal ,INDICATOR_DATA); 
   SetIndexBuffer(4,prices ,INDICATOR_CALCULATIONS); 
   SetIndexBuffer(5,smooth ,INDICATOR_CALCULATIONS); 
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Instantaneous trend line ("+(string)inpAlpha+")");
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
   if (Bars(_Symbol,_Period)<rates_total) return(prev_calculated);

   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
   {
      prices[i] = getPrice(inpPrice,open,close,high,low,i,rates_total);
      smooth[i] = (i>2) ? (prices[i] + 2*prices[i-1] + 2*prices[i-2] + prices[i-3])/6 : prices[i];    
      itrend[i] = (i>1) ? (inpAlpha-inpAlpha*inpAlpha/4)*smooth[i]+ 0.5*inpAlpha*inpAlpha*smooth[i-1] - (inpAlpha-0.75*inpAlpha*inpAlpha)*smooth[i-2] + 2*(1 - inpAlpha)*itrend[i-1] - (1-inpAlpha)*(1-inpAlpha)*itrend[i-2] : itrend[i];
      signal[i] = (i>1) ? 2*itrend[i]-itrend[i-2] : itrend[i];
      fillu[i]  = itrend[i];
      filld[i]  = signal[i];
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
  if (i>=0)
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
