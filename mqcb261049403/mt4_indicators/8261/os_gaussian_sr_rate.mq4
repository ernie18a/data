//+------------------------------------------------------------------+
//|                        One Side Gaussian Support Resistance Rate |
//|                                                           mladen |
//|                                                                  |
//| original idea and first implementation by : Tinytjan             |
//| (http://codebase.mql4.com/ru/2735)                               |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfxgmail.com"

#property indicator_separate_window
#property indicator_buffers    1
#property indicator_color1     clrRed
#property indicator_minimum    0
#property indicator_maximum    1
#property indicator_level1     0.5
#property indicator_levelcolor clrDarkSlateGray

//
//
//
//
//

extern int SRPeriod   = 40;
extern int SmoothType = 3;

//
//
//
//
//

double SmoothHigh[];
double SmoothLow[];
double Rate[];

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
   IndicatorBuffers(3);
   SetIndexBuffer(0,Rate);
   SetIndexBuffer(1,SmoothHigh);
   SetIndexBuffer(2,SmoothLow);
   SmoothType=MathMax(MathMin(SmoothType,7),0);
   IndicatorShortName("One side Gaussian SR rate("+SRPeriod+","+SmoothType+")");
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

   for(i=limit; i>=0; i--)
     {
      SmoothLow[i]  = Smooth(SmoothType,PRICE_LOW, i);
      SmoothHigh[i] = Smooth(SmoothType,PRICE_HIGH,i);

      double Min = SmoothLow [ArrayMinimum(SmoothLow ,SRPeriod,i)];
      double Max = SmoothHigh[ArrayMaximum(SmoothHigh,SRPeriod,i)];
      if(Min==Max)
         Rate[i] = 0;
      else  Rate[i] = (Smooth(SmoothType,PRICE_WEIGHTED,i)-Min)/(Max - Min);
     }
   return(0);
  }
//+------------------------------------------------------------------+
