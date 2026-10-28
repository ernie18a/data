//+------------------------------------------------------------------+
//|                                          Stoch_Strike(AM)_SW.mq4 |
//|                                               Andrey Matvievskiy |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Andrey Matvievskiy"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 5

#property indicator_color1 Black
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_color5 Red

//---- input parameters
extern int Period_MA1 = 34;
extern int Period_MA2 = 5;
extern int Price_MA1 = 4;
extern int Price_MA2 = 4;
extern int Method_MA1 = 0;
extern int Method_MA2 = 0;

extern int KPeriod=5;
extern int Slowing=3;
extern int MA_Method=0; // SMA 0, EMA 1, SMMA 2, LWMA 3
extern int PriceField=0; // Low/High 0, Close/Close 1

extern int TF=0;

double ExtBuffer0[];
double ExtBuffer1[];
double ExtBuffer2[];

double CrossUp1[];
double CrossDown1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,ExtBuffer0);

   SetIndexStyle(1,DRAW_HISTOGRAM,0,1);
   SetIndexBuffer(1,ExtBuffer1);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,1);
   SetIndexBuffer(2,ExtBuffer2);

   SetIndexStyle(3,DRAW_ARROW,0,0);
   SetIndexArrow(3,233);
   SetIndexBuffer(3,CrossUp1);
   SetIndexStyle(4,DRAW_ARROW,0,0);
   SetIndexArrow(4,234);
   SetIndexBuffer(4,CrossDown1);

   SetIndexLabel(0,NULL);
   SetIndexLabel(1,"MACD+");
   SetIndexLabel(2,"MACD-");
   SetIndexLabel(3,"Stoch Strike+");
   SetIndexLabel(4,"Stoch Strike-");

   IndicatorShortName("Stoch_Strike(AM)_SW (TF "+TF+")");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
  {
   double prev1,current1;
   
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+2;

   for(int i=0; i<limit; i++)
      ExtBuffer0[i]=iMA(NULL,TF,Period_MA2,0,Method_MA2,Price_MA2,i)-iMA(NULL,TF,Period_MA1,0,Method_MA1,Price_MA1,i);
   bool up1=true;
   for(i=limit-1; i>=0; i--)
     {
      current1=ExtBuffer0[i];
      prev1=ExtBuffer0[i+1];
      if(current1>prev1) up1=true;
      if(current1<prev1) up1=false;
      if(!up1)
        {
         ExtBuffer2[i]=current1;
         ExtBuffer1[i]=0.0;
        }
      else
        {
         ExtBuffer1[i]=current1;
         ExtBuffer2[i]=0.0;
        }

      double X = iStochastic(NULL, TF, KPeriod, 3, Slowing,MA_Method, PriceField, MODE_MAIN, i);
      double Y = iStochastic(NULL, TF, KPeriod, 3, Slowing,MA_Method, PriceField, MODE_MAIN, i+1);
      double Z = iStochastic(NULL, TF, KPeriod, 3, Slowing,MA_Method, PriceField, MODE_MAIN, i+2);

      if((Y<X) && (Z>Y))
        {
         CrossUp1[i]=0;
        }
      else  if((Y>X) && (Z<Y))
        {
         CrossDown1[i]=0;
        }
     }

//----
   return(0);
  }
//+------------------------------------------------------------------+
