//+------------------------------------------------------------------+
//|                                       Ultitimate Oscillator.mq4  |
//|                                       Ramdass - Conversion only  |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green
//---- input parameters
extern int nMAPeriod1 = 7;
extern int nMAPeriod2 = 14;
extern int nMAPeriod3 = 28;
extern int CountBars=300;
//---- buffers
double WUO[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(1);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, WUO);
//---- name for DataWindow and indicator subwindow label
   short_name = "UltOsc(" + nMAPeriod1 + ", " + nMAPeriod2 + ", " + nMAPeriod3 + ")";
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);   
//----
   if(CountBars >= Bars) 
       CountBars = Bars;
   SetIndexDrawBegin(0, Bars - CountBars + 28 + 1);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Ultitimate Oscillator                                            |
//+------------------------------------------------------------------+
int start()
  {
   int i, counted_bars = IndicatorCounted();
//----
   if(Bars <= 28) 
       return(0);
//---- initial zero
   if(counted_bars < 28)
     {
       for(i = 1;i <= 28; i++) 
           WUO[CountBars-i] = 0.0;
     }
//----
   i = CountBars - 28 - 1;
//----
   while(i >= 0)
     {
       WUO[i] = (iMA(NULL, 0, nMAPeriod1, 0, MODE_LWMA, MODE_CLOSE, i)+
                 iMA(NULL, 0, nMAPeriod2, 0, MODE_LWMA, MODE_CLOSE, i)+
                 iMA(NULL, 0, nMAPeriod3, 0, MODE_LWMA, MODE_CLOSE, i));
       i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+