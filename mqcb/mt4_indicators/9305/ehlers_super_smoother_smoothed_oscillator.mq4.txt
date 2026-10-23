//+------------------------------------------------------------------+
//|                                                  Accelerator.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Julien Loutre"
#property link      "http://www.zenhop.com"

#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  LightBlue
#property  indicator_color2  DodgerBlue
#property  indicator_color3  Red

extern int        CuttOff  = 15;
extern double     alpha    = 0.15;
extern int        shift    = 0;

double      EMA[],Osc[],OscUP[],OscDOWN[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init() 
  {
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,2);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,2);
   IndicatorDigits(6);
   SetIndexDrawBegin(0,0);
   SetIndexBuffer(0,EMA);
   SetIndexBuffer(1,OscUP);
   SetIndexBuffer(2,OscDOWN);
   SetIndexShift(0,shift);
   SetIndexLabel(0,NULL);
   SetIndexLabel(0,"Osc");
   SetIndexLabel(1,"Osc UP");
   SetIndexLabel(2,"Osc DOWN");
   IndicatorShortName("Two pole Smoothed Oscillator ("+CuttOff+","+DoubleToStr(alpha,2)+")");

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start() 
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+3;

   for(int i=limit-1; i>=0; i--) 
     {
      EMA[i]=(alpha-((alpha/2)*(alpha/2)))*getValue(i)+((alpha*alpha)/2)*getValue(i+1)-(alpha-(3*(alpha*alpha)/4))*getValue(i+2)+2*(1-alpha)*EMA[i+1]-((1-alpha)*(1-alpha))*EMA[i+2];

      if(EMA[i]>EMA[i+1]) 
        {
         OscUP[i]=EMA[i];
         OscDOWN[i]=EMPTY_VALUE;
        }
      if(EMA[i]<EMA[i+1]) 
        {
         OscUP[i]=EMPTY_VALUE;
         OscDOWN[i]=EMA[i];
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getValue(int i) 
  {
   return(iCustom(NULL,0,"Ehlers Two Pole Super Smoother Filter", CuttOff, 0, i)-iCustom(NULL,0,"Ehlers Two Pole Super Smoother Filter", CuttOff, 0, i+1));
  }
//+------------------------------------------------------------------+
