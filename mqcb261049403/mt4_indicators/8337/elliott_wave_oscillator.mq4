//+------------------------------------------------------------------+
//|                                      Elliott Wave Oscillator.mq4 |
//|                                                tonyc2a@yahoo.com |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "tonyc2a@yahoo.com"
#property link      ""

#property indicator_separate_window
#property indicator_color1 DimGray
//---- input parameters
extern int EWOPeriod1 = 5;
extern int EWOPeriod2 = 35;
//---- buffers
double Buffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicators
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexBuffer(0, Buffer1);
//---- name for DataWindow and indicator subwindow label
   short_name = "EWO(" + IntegerToString(EWOPeriod1) + ", " + IntegerToString(EWOPeriod2) + ")";
   IndicatorShortName(short_name);
   SetIndexLabel(0, "EWO");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit--;
   double MA1, MA2;
//---- TODO: add your code here
   for(int i = limit; i >= 0; i--)
     {
       MA1 = iMA(NULL, 0, EWOPeriod1, 0, MODE_SMA, PRICE_MEDIAN, i);
       MA2 = iMA(NULL, 0, EWOPeriod2, 0, MODE_SMA, PRICE_MEDIAN, i);
       Buffer1[i] = MA1-MA2;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+