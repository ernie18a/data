//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "EMA deviation"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "EMA deviation"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrSkyBlue,clrDodgerBlue
#property indicator_width1  2
//--- input parameters
input int                inpDevPeriod     = 20;           // Deviation period
input ENUM_APPLIED_PRICE inpPrice         =  PRICE_CLOSE; // Price
//--- buffers and global variables declarations
double val[],valc[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignement
   IndicatorSetString(INDICATOR_SHORTNAME,"EMA deviation ("+(string)inpDevPeriod+")");
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
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      val[i]  = iEmaDeviation(getPrice(inpPrice,open,close,high,low,i,rates_total),inpDevPeriod,i,rates_total);
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _edevInstances 1
#define _edevInstancesSize 2
double workEmaDeviation[][_edevInstances*_edevInstancesSize];
#define _ema0 0
#define _ema1 1
//
//---
//
double iEmaDeviation(double price,double period, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workEmaDeviation,0)!=bars) ArrayResize(workEmaDeviation,bars); instanceNo*=_edevInstancesSize;
   
   workEmaDeviation[i][instanceNo+_ema0] = price;
   workEmaDeviation[i][instanceNo+_ema1] = price;
   if (i>0 && period>1)
   {
      double alpha = 2.0/(1.0+period);
         workEmaDeviation[i][instanceNo+_ema0] = workEmaDeviation[i-1][instanceNo+_ema0]+alpha*(price      -workEmaDeviation[i-1][instanceNo+_ema0]);
         workEmaDeviation[i][instanceNo+_ema1] = workEmaDeviation[i-1][instanceNo+_ema1]+alpha*(price*price-workEmaDeviation[i-1][instanceNo+_ema1]);
   }         
   return(MathSqrt(period*(workEmaDeviation[i][instanceNo+_ema1]-workEmaDeviation[i][instanceNo+_ema0]*workEmaDeviation[i][instanceNo+_ema0])/MathMax(period-1,1)));
}
//
//---
//
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
