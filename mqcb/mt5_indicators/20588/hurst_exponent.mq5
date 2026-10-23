//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Hurst exponent"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Hurst exponent"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_width1  2
//--- input parameters
input int                inpHurstPeriod    =  30;         // Hurst exponent period
input ENUM_APPLIED_PRICE inpPrice          = PRICE_CLOSE; // Price 
//--- buffers declarations
double val[],prices[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,prices,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Hurst exponent ("+(string)inpHurstPeriod+")");
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
#define koef 1.253314
double x[];
double y[];
//
//---
//
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
   if(ArraySize(x)!=inpHurstPeriod)
     {
      ArrayResize(x,inpHurstPeriod); ArrayInitialize(x,0); ArraySetAsSeries(x,true);
      ArrayResize(y,inpHurstPeriod); ArrayInitialize(y,0); ArraySetAsSeries(y,true);
     }
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      prices[i]=getPrice(inpPrice,open,close,high,low,i,rates_total);
      double mean = iSma(prices[i],inpHurstPeriod,i,rates_total);
      double sums = 0;
      for(int k=0; k<inpHurstPeriod && (i-k)>=0; k++)
        {
         x[k]=prices[i-k]-mean;  sums+=x[k]*x[k];
        }
      double maxY = x[0];
      double minY = x[0];
      y[0] = x[0];

      for(int k=1; k<inpHurstPeriod; k++)
        {
         y[k] = y[k-1] + x[k];
         maxY = MathMax(y[k],maxY);
         minY = MathMin(y[k],minY);
        }
      double iValue = 0; if(sums   !=0) iValue = (maxY - minY)/(koef * MathSqrt(sums/inpHurstPeriod));
      double hurst  = 0; if(iValue > 0) hurst  = MathLog(iValue)/ MathLog(inpHurstPeriod);
      val[i] = hurst;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workSma[][1];
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
