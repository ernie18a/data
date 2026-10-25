//KurlFX 2009.01.31
//+------------------------------------------------------------------+
//|	*** MTFPI-sub4 ***			HeikinAshi-line							|
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2009,Kurl FX"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 MediumSeaGreen

double O[];
double C[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0,O);
   SetIndexBuffer(1,C);
   SetIndexLabel(0,"HA/h/l");
   SetIndexLabel(1,"HA/l/h");
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
   if(counted_bar==0)
     {
      limit-=2;int i=limit;
      O[i]=(Open[i+1]+High[i+1]+Low[i+1]+Close[i+1])/4;
      C[i]=(Open[i]+High[i]+Low[i]+Close[i])/4;
     }
   for(i=limit-1;i>=0;i--)
     {
      O[i]=(O[i+1]+C[i+1])/2;
      C[i]=(Open[i]+High[i]+Low[i]+Close[i])/4;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
