//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Fractal dimension index Sevcik/Matulich"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Fractal dimension index"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
//--- input parameters
input int                inpFdiPeriod    =  30;         // Fractal dimension period
input double             inpFdiThreshold =  1.5;        // Fractal dimension threshold
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price 
//--- buffers declarations
double val[],valc[],prices[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,prices,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,inpFdiThreshold);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Fractal dimension index (Sevcik/Matulich) ("+(string)inpFdiPeriod+","+(string)inpFdiThreshold+")");
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
   double dx2=MathPow(1.0/inpFdiPeriod,2);
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      prices[i]=getPrice(inpPrice,open,close,high,low,i,rates_total);
      int _start=(int)MathMax(i-inpFdiPeriod+1,0);
      double priceMax = prices[ArrayMaximum(prices,_start,inpFdiPeriod)];
      double priceMin = prices[ArrayMinimum(prices,_start,inpFdiPeriod)];
      double length   = 0.00;

      if(priceMax==priceMin) length=1;
      else
        {
         double pdi=priceMax-priceMin;
         for(int k=1; k<=inpFdiPeriod && (i-k)>=0; k++)
           {
            double dy=(prices[i-k]-prices[i-k+1])/pdi;
            length+=MathSqrt(dx2+dy*dy);
           }
        }
      val[i]=1+(MathLog(length)+MathLog(2))/MathLog(2*inpFdiPeriod);
      valc[i]=(val[i]>inpFdiThreshold) ? 1 : 2;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
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
