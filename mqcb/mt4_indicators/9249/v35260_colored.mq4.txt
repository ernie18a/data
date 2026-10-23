//+------------------------------------------------------------------+
//|                                                       v35260.mq4 |
//|                                                            IgorS |
//|                                            igor.senych@gmail.com |
//+------------------------------------------------------------------+
#property copyright "IgorS"
#property link      "igor.senych@gmail.com"


extern int MaMetod  = 3;
extern int MaPeriod = 5;
extern int MaMetod2  = 3;
extern int MaPeriod2 = 8;

extern int Signal=2;

extern bool main=true;

int bufer=0;
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  Black
#property  indicator_color2  Purple
#property  indicator_color3  DarkOrange
#property  indicator_color4  Red
#property  indicator_width2  2
#property  indicator_width3  2

//---- indicator buffers
double     ExtBuffer0[];
double     ExtBuffer1[];
double     ExtBuffer2[];
double     ExtBuffer3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_LINE);
   IndicatorDigits(Digits+1);
//---- 4 indicator buffers mapping
   SetIndexBuffer(0,ExtBuffer0);
   SetIndexBuffer(1,ExtBuffer1);
   SetIndexBuffer(2,ExtBuffer2);
   SetIndexBuffer(3,ExtBuffer3);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("v35260");
   SetIndexLabel(1,"sdo");
   SetIndexLabel(2,"sdo");
   SetIndexLabel(3,"Signal");

   if(main==true) bufer=3;
   else bufer=1;
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Awesome Oscillator                                               |
//+------------------------------------------------------------------+
int start()
  {
   int    limit;
   double prev,current;

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=2;

//---- macd
   for(int i=0; i<limit; i++)
      ExtBuffer0[i]=iCustom(Symbol(),0,"Heiken_Ashi_Smoothed",MaMetod,MaPeriod,MaMetod2,MaPeriod2,bufer,i)-iCustom(Symbol(),0,"Heiken_Ashi_Smoothed",MaMetod,MaPeriod,MaMetod2,MaPeriod2,bufer-1,i);
//---- dispatch values between 2 buffers
   bool up=true;
   for(i=limit-1; i>=0; i--)
     {
      current=ExtBuffer0[i];
      prev=ExtBuffer0[i+1];
      if(current>prev) up=true;
      if(current<prev) up=false;
      if(!up)
        {
         ExtBuffer2[i]=current;
         ExtBuffer1[i]=0.0;
        }
      else
        {
         ExtBuffer1[i]=current;
         ExtBuffer2[i]=0.0;
        }
     }
//---- signal line 
   for(i=0; i<limit; i++)
      ExtBuffer3[i]=iMAOnArray(ExtBuffer0,Bars,Signal,0,MODE_SMA,i);
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
