//+------------------------------------------------------------------+
//|                                                  EveningStar.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.005"
#property description "An \"Evening Star\" is a bearish candlestick pattern" 

#property indicator_chart_window 
#property indicator_buffers 1 
#property indicator_plots   1 
//--- plot Arrows 
#property indicator_label1  "Evening Star" 
#property indicator_type1   DRAW_ARROW 
#property indicator_color1  clrGreen 
#property indicator_width1  1 
//--- input parameters 
input bool     InpGap         = true;  // Gap. true -> gap is taken into account
input bool     InpCandle2Type = true;  // Candle 2 type. true -> type of candle 2 is taken into account
input bool     InpCandleSizes = true;  // Candle sizes. true -> candle sizes is taken into account
input uchar    code           = 74;    // Symbol code to draw in DRAW_ARROW 
//--- An indicator buffer for the plot 
double         ArrowsBuffer[];
double         ExtDistance=0.0;        // minimum size of gap
double         m_adjusted_point;       // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping 
   SetIndexBuffer(0,ArrowsBuffer,INDICATOR_DATA);
//--- Define the symbol code for drawing in PLOT_ARROW 
   PlotIndexSetInteger(0,PLOT_ARROW,code);
//--- Set the vertical shift of arrows in pixels 
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-5);
//--- Set as an empty value 0 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- revert access to array ArrowsBuffer[] - do it like in timeseries 
   ArraySetAsSeries(ArrowsBuffer,true);
   ArrayInitialize(ArrowsBuffer,0.0);
//---
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(Digits()==3 || Digits()==5)
      digits_adjust=10;
   m_adjusted_point=Point()*digits_adjust;

   ExtDistance=1*m_adjusted_point;                                      // minimum size of gap
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
//--- revert access to arrays - do it like in timeseries 
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
/*
   "2"    "1"    "0"
   
           |
        C --- 
          | |
          | |     |
    |   O ---  O --- 
 C ---     |     ||| 
   | |           |||
   | |           |||
   | |           |||
   | |         C ---
   | |            |
   | | 
 O ---
    |
*/
   if(rates_total<10) // it isn't enough data: exit
      return(0);
   int limit=rates_total-1-3;
   if(prev_calculated==0)
      ArrayInitialize(ArrowsBuffer,0.0);
   else
      limit=rates_total-prev_calculated;
//---
   for(int i=limit;i>0;i--)
     {
      //--- OHLC
      //--- rough check: bar with the index "0" - bearish and bar with the index "2" - bullish
      if(open[i+0]>close[i+0] && open[i+2]<close[i+2]) // 
        {
         if(InpCandleSizes) // Candle sizes 
            if(MathAbs(open[i+0]-close[i+0])<MathAbs(open[i+1]-close[i+1]) || 
               MathAbs(open[i+2]-close[i+2])<MathAbs(open[i+1]-close[i+1]))
              {
               ArrowsBuffer[i+1]=0.0;
               continue;
              }
         if(InpCandle2Type) // Candle 2 type
           {
            if(open[i+1]>close[i+1])
              {
               ArrowsBuffer[i+1]=0.0;
               continue;
              }
           }
         else
           {
            if(close[i+1]>open[i+1])
              {
               ArrowsBuffer[i+1]=0.0;
               continue;
              }
           }
         if(InpGap) // Gap
            if(open[i+0]>=close[i+1]-ExtDistance || open[i+1]<=close[i+2]+ExtDistance)
              {
               ArrowsBuffer[i+1]=0.0;
               continue;
              }
         ArrowsBuffer[i+1]=high[i+1];
        }
     }
//--- return value of prev_calculated for next call 
   return(rates_total);
  }
//+------------------------------------------------------------------+
