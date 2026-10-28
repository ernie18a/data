//+------------------------------------------------------------------+
//|                             One Side Gaussian Support Resistance |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfxgmail.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  clrRed
#property indicator_width1  2

//
//
//
//
//

extern int Price      = PRICE_CLOSE;
extern int SmoothType = 5;

//
//
//
//
//

double Average[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#import "OneSideGaussianLibrary.ex4"
void   BuffersInit();
double Smooth(int version,int price,int i);
#import
//
//
//
//
//

int init()
  {
   BuffersInit();
   SetIndexBuffer(0,Average);

   string PriceType;
   switch(Price)
     {
      case PRICE_CLOSE:    PriceType = "Close";    break;  // 0
      case PRICE_OPEN:     PriceType = "Open";     break;  // 1
      case PRICE_HIGH:     PriceType = "High";     break;  // 2
      case PRICE_LOW:      PriceType = "Low";      break;  // 3
      case PRICE_MEDIAN:   PriceType = "Median";   break;  // 4
      case PRICE_TYPICAL:  PriceType = "Typical";  break;  // 5
      case PRICE_WEIGHTED: PriceType = "Weighted"; break;  // 6
     }
   SmoothType=MathMax(MathMin(SmoothType,7),0);
   IndicatorShortName("One side Gaussian MA ("+PriceType+","+SmoothType+")");
   return(0);
  }
//
//
//
//
//

int start()
  {
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit--;

//
//
//
//
//

   for(i=limit; i>=0; i--) Average[i]=Smooth(SmoothType,Price,i);
   return(0);
  }
//+------------------------------------------------------------------+
