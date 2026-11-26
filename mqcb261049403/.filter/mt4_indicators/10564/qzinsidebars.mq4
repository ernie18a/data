//+------------------------------------------------------------------+
//|                                                 #!InsideBars.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1  Blue
#property indicator_color2  Red
#property indicator_color3  Aqua
#property indicator_color4  DeepPink
#property indicator_color5  Blue
#property indicator_color6  Aqua
#property indicator_color7  Red
#property indicator_color8  DarkViolet

#property indicator_width1 0
#property indicator_width2 0
#property indicator_width3 0
#property indicator_width4 0
#property indicator_width5 0
extern int Barss = 500;
double upline[],downline[];
double upstopline[],downstopline[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0,upline);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,241);
   SetIndexLabel(0,"upline");
   
   SetIndexBuffer(1,downline);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,242);
   SetIndexLabel(1,"downline");
   
   SetIndexBuffer(2,upstopline);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,251);
   SetIndexLabel(2,"upstopline");
   
   SetIndexBuffer(3,downstopline);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,251);
   SetIndexLabel(3,"downstopline");
   

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit;
   limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+2;
//----
   for(int i =0; i <=limit; i++)
      {
      if((High[i+1] < High[i+2])&&(Low[i+1] > Low[i+2]))  
         {
         upline[i] = High[i+1];
         downline[i] = Low[i+1];
         upstopline[i] = (High[i+1] + Low[i+1])/2;
         //upstopline[i] = High[iHighest(NULL,0,MODE_HIGH,10,i)];
         downstopline[i] = Low[iLowest(NULL,0,MODE_LOW,10,i)];
         }
      }
      /*
      for(   i =0; i <=Barss; i++)
         {
         if(upline[i]==EMPTY_VALUE) upline[i] = upline[i+1];
         if(downline[i]==EMPTY_VALUE) downline[i] = downline[i+1];
         if(upstopline[i]==EMPTY_VALUE) upstopline[i] = upstopline[i+1];
         if(downstopline[i]==EMPTY_VALUE) downstopline[i] = downstopline[i+1];
         }
       */
//----
   return(0);
  }
//+------------------------------------------------------------------+