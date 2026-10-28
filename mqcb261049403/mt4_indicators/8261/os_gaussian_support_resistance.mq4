//+------------------------------------------------------------------+
//|                             One Side Gaussian Support Resistance |
//|                                                           mladen |
//|                                                                  |
//| original idea and first implementation by : Tinytjan             |
//| (http://codebase.mql4.com/ru/2735)                               |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfxgmail.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrRed
#property indicator_color2 clrGreen
#property indicator_color3 clrDimGray
#property indicator_style3 STYLE_DOT

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

double Resistance[];
double Support[];
double Average[];
double SmoothHigh[];
double SmoothLow[];

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
   IndicatorBuffers(5);
   SetIndexBuffer(0,Resistance); SetIndexLabel(0,"OS Gaussian resistance");
   SetIndexBuffer(1,Support);    SetIndexLabel(1,"OS Gaussian support");
   SetIndexBuffer(2,Average);    SetIndexLabel(2,"OS Gaussian average");
   SetIndexBuffer(3,SmoothHigh);
   SetIndexBuffer(4,SmoothLow);
   SmoothType=MathMax(MathMin(SmoothType,7),0);
   IndicatorShortName("One side Gaussian ("+SRPeriod+","+SmoothType+")");
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
      Support[i]    = SmoothLow [ArrayMinimum(SmoothLow,SRPeriod,i)];
      Resistance[i] = SmoothHigh[ArrayMaximum(SmoothHigh,SRPeriod,i)];
      Average[i]    = (Support[i] + Resistance[i])/2;
     }
   return(0);
  }
//+------------------------------------------------------------------+
