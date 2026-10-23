//+------------------------------------------------------------------+
//| HeikenAshiHistogram.mq4
//| Copyright http://www.pointzero-indicator.com
//+------------------------------------------------------------------+

#property copyright "Copyright © Pointzero-indicator.com"
#property link      "http://www.pointzero-indicator.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 Red
#property indicator_color3 Teal
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 1
#define MaMetod 2

//-------------------------------
// External variables
//-------------------------------
extern int AvPeriod = 6;

//-------------------------------
// Buffers
//-------------------------------

double FextMapBuffer1[];
double FextMapBuffer2[];
double FextMapBuffer3[];
double FextMapBuffer4[];
double FextMapBuffer5[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
{
   // Total buffers
   IndicatorBuffers(5);
   
   // Visible buffers
   SetIndexStyle(0,DRAW_HISTOGRAM, 0);
   SetIndexBuffer(0, FextMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM, 0);
   SetIndexBuffer(1, FextMapBuffer2);
   SetIndexStyle(3,DRAW_LINE, 0);
   SetIndexBuffer(2,FextMapBuffer3);    
   
   // Internal
   SetIndexBuffer(3,FextMapBuffer4);  
   SetIndexBuffer(4,FextMapBuffer5);     
   
   // My name
   IndicatorShortName("Heiken Ashi Histogram");
   Comment("Copyright © http://www.pointzero-indicator.com");
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   // Start, limit, etc..
   int start = 0;
   int limit;
   int counted_bars = IndicatorCounted();
   if(Bars<=10) return(0);
   
   // nothing else to do?
   if(counted_bars < 0) 
       return(-1);

   // do not check repeated bars
   limit = Bars - 1 - counted_bars;
   if(counted_bars==0) limit-=1+1;
   
   // 1) Check heiken ashi for past to present
   for(int pos = limit; pos >= start; pos--)
   {  
      // Open and close 
      double open = iCustom(Symbol(), 0, "Heiken Ashi", 2, pos);
      double close = iCustom(Symbol(), 0, "Heiken Ashi", 3, pos);
      
      // Median
      FextMapBuffer4[pos] = (open + close) / 2;
      
      // Difference
      FextMapBuffer5[pos] = MathAbs(FextMapBuffer4[pos] - FextMapBuffer4[pos+1]);

      // If bearish
      if(open > close)
      {
         FextMapBuffer2[pos] = FextMapBuffer5[pos];
         FextMapBuffer1[pos] = 0;
         
      // If bullish
      } else {
         
         FextMapBuffer1[pos] = FextMapBuffer5[pos];
         FextMapBuffer2[pos] = 0;
      }
   }
   
   // Apply average
   for(int i=0; i < Bars; i++) FextMapBuffer3[i] = iMAOnArray(FextMapBuffer5, Bars, AvPeriod, 0, MaMetod, i);
   return(0);
}