//+------------------------------------------------------------------+
//|                                                         HiLo.mq5 |
//|                                  Copyright 2010, Charly King Her |
//|                                   www.bussinessclubworldwide.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, Charly King Her"
#property link      "www.bussinessclubworldwide.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
//+------------------------------------------------------------------+
#property indicator_label1  "SmoothLine"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Blue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//+------------------------------------------------------------------+
input int      PreferPeriod=10;
//+------------------------------------------------------------------+
double         SmoothLineBuffer[],HMABuffer[],LMABuffer[];
int HighMA,LowMA;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,SmoothLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HMABuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LMABuffer,INDICATOR_DATA);
   HighMA= iMA(Symbol(),0,PreferPeriod,0,MODE_SMA,PRICE_HIGH);
   LowMA = iMA(Symbol(),0,PreferPeriod,0,MODE_SMA,PRICE_LOW);
   return(0);
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
   int buffer_status=CopyBuffer(HighMA,0,0,rates_total,HMABuffer);
   buffer_status*=CopyBuffer(LowMA,0,0,rates_total,LMABuffer);
   int bars=BarsCalculated(HighMA);
   bars=MathMax(bars,BarsCalculated(LowMA));
   if(buffer_status>0 && bars>=rates_total)
     {
      int start_idx=1; if(prev_calculated>0) { start_idx=prev_calculated-1; }
      for(int idx=start_idx; idx<rates_total; idx++)
        {
         if(close[idx]<LMABuffer[idx-1]) { SmoothLineBuffer[idx]=HMABuffer[idx-1]; }
         else { SmoothLineBuffer[idx]=LMABuffer[idx-1]; }
        }
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
