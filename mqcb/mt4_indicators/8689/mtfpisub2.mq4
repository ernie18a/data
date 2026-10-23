//KurlFX 2009.01.31
//+------------------------------------------------------------------+
//|	*** MTFPI-sub2 ***				dMACD										|
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2009,Kurl FX"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_level1 0.0

double dMACD[];

extern int FastEMA = 5;
extern int SlowEMA = 100;
extern int SignalSMA=3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0,dMACD);
   string label="dMACD("+FastEMA+","+SlowEMA+","+SignalSMA+")";
   IndicatorShortName(label);
   SetIndexLabel(0,"dMACD");
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
   int counted_bar=IndicatorCounted();
   int limit=Bars-counted_bar;
   if(counted_bar==0)limit-=SlowEMA+SignalSMA-1;
   for(int i=limit-1; i>=0; i--)
     {
      dMACD[i]=iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)
               -iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i+1);
     }
   return(0);
  }
//+------------------------------------------------------------------+
