//+------------------------------------------------------------------+
//|                                                       _Fast3.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 clrNONE
#property indicator_color2 clrNONE
#property indicator_color3 clrNONE
#property indicator_color4 Red
#property indicator_color5 Blue
//---- input parameters
extern int       ma1=3;
extern int       ma2=9;
static int prevtime = 0;
extern int       bars=300;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_ARROW,1);
   SetIndexArrow(3,236);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexEmptyValue(3,0.0);
   SetIndexStyle(4,DRAW_ARROW,1);
   SetIndexArrow(4,238);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexEmptyValue(4,0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll();

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+2;

   for(int i=0;i<limit;i++)
     {
      ExtMapBuffer1[i]=((Close[i]-Open[i])+((Close[i+1]-Open[i+1])/MathSqrt(2))+((Close[i+2]-Open[i+2])/MathSqrt(3)))/Point;
     }
   for(i=0;i<bars;i++)
     {
      ExtMapBuffer2[i]=iMAOnArray(ExtMapBuffer1,0,ma1,0,MODE_LWMA,i);
      ExtMapBuffer3[i]=iMAOnArray(ExtMapBuffer1,0,ma2,0,MODE_LWMA,i);
      if(((ExtMapBuffer2[i+2]>ExtMapBuffer3[i+2]) && (ExtMapBuffer2[i+1]<ExtMapBuffer3[i+1]) && (ExtMapBuffer2[i]<ExtMapBuffer3[i]))
         && (ExtMapBuffer1[i+2]>=ExtMapBuffer1[i+1]))
        {  ExtMapBuffer5[i]=(Open[i]); } else { ExtMapBuffer5[1]=0.0; }
      if(((ExtMapBuffer2[i+2]<ExtMapBuffer3[i+2]) && (ExtMapBuffer2[i+1]>ExtMapBuffer3[i+1]) && (ExtMapBuffer2[i]>ExtMapBuffer3[i]))
         && (ExtMapBuffer1[i+2]<=ExtMapBuffer1[i+1]))
        {  ExtMapBuffer4[i]=(Open[i]);  } else {  ExtMapBuffer4[1]=0.0;  }
     }
//----

   return(0);
  }
//+------------------------------------------------------------------+
