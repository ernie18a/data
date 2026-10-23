//+------------------------------------------------------------------+
//|                                             Demo_DRAW_ZIGZAG.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot ZigZag
#property indicator_label1  "ZigZag"
#property indicator_type1   DRAW_ZIGZAG
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers
double         ZigZagBuffer1[];
double         ZigZagBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ZigZagBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ZigZagBuffer2,INDICATOR_DATA);

//--- set zero as an empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- fill arrays with 0 when first call of the function
   if(prev_calculated==0)
     {
      ArrayInitialize(ZigZagBuffer1,0);
      ArrayInitialize(ZigZagBuffer2,0);
     }
//--- calc start
   int start=prev_calculated;
   if(start!=0) start--;
   for(int i=start;i<rates_total;i++)
     {
      //--- calc buffer index
      int buff_index=i%2;
      //--- write value to the buffer
      switch(buff_index)
        {
         //--- bar index is even - write to the first buffer
         case  0: ZigZagBuffer1[i]=high[i]; //PrintFormat("i=%d  tick=%G",i,ZigZagBuffer1[i]);
         break;
         //--- bar index is odd - write to the second buffer
         case  1: ZigZagBuffer2[i]=low[i]; //PrintFormat("i=%d  tick=%G",i,ZigZagBuffer2[i]);
         break;
        }

     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
