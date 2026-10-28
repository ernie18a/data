//+------------------------------------------------------------------+
//| CoreWinTT желает Вам успехов и удачи! :)                           
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Aqua
#property indicator_width1 2
#property indicator_color2 Aqua
#property indicator_width2 2
#property indicator_color3 Magenta
#property indicator_width3 2
#property indicator_color4 Magenta
#property indicator_width4 2 
#property indicator_color5 MediumPurple
#property indicator_width5 2
#property indicator_color6 MediumPurple
#property indicator_width6 2
extern int FastEMA = 12;
extern int SlowEMA = 29;
extern int SignalEMA=9;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexStyle(5,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(5,ExtMapBuffer6);
//----
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
   if(counted_bars==0) limit--;

   int i=limit;
   while(i>=0)
     {
      double L_1 = iCustom(NULL,0,"b_v2_macd_osmax",FastEMA,SlowEMA,SignalEMA,1,2,i); //buy 
      double L_2 = iCustom(NULL,0,"b_v2_macd_osmax",FastEMA,SlowEMA,SignalEMA,1,1,i); //sell

      if(L_1!=0.0){ExtMapBuffer1[i]=High[i];ExtMapBuffer2[i]=Low[i];}
      else
        {
         if(L_2!=0.0){ExtMapBuffer3[i]=High[i];ExtMapBuffer4[i]=Low[i];}
         else{ExtMapBuffer5[i]=High[i];ExtMapBuffer6[i]=Low[i];}
        }
      i--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
