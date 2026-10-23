//+------------------------------------------------------------------+
//|                                                   DojiArrows.mq5 |
//|                                            Copyright © 2007, NNN | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
//--- copyright
#property copyright "Copyright © 2007, NNN"
//--- a link to the website of the author
#property link       ""
#property description "The indicator finds Doji candlesticks and highlights them on a chart using colored arrows"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//--- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//| Parameters of drawing a bearish indicator    |
//+----------------------------------------------+
//--- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//--- pink is used for the color of the bearish indicator line
#property indicator_color1  clrDeepPink
//--- indicator 1 line width is equal to 4
#property indicator_width1  4
//--- display of the indicator bullish label
#property indicator_label1  "DojiArrows Sell"
//+----------------------------------------------+
//| Parameters of drawing a bullish indicator    |
//+----------------------------------------------+
//--- drawing the indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//--- green color is used as the color of the indicator bullish line
#property indicator_color2  clrLime
//--- indicator 2 line width is equal to 4
#property indicator_width2  4
//--- display of the bearish indicator label
#property indicator_label2 "DojiArrows Buy"
//+----------------------------------------------+
//| declaration of constants                     |
//+----------------------------------------------+
#define RESET 0  // A constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//--- declaration of integer variables for the indicators handles
int ATR_Handle;
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of global variables 
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,3));
//--- Getting the handle of the ATR indicator
   ATR_Handle=iATR(_Symbol,PERIOD_CURRENT,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(INIT_FAILED);
     }
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SellBuffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BuyBuffer,true);
//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- data window name and subwindow label 
   string short_name="DojiArrows";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- initialization end
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
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- declarations of local variables 
   int to_copy,limit,bar,bar1,bar2;
   double ATR[];
   bool uptrend=false,downtrend=false;
   static bool prev_uptrend,prev_downtrend;
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      prev_uptrend=false;
      prev_downtrend=false;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }
   to_copy=limit+1;
//--- copy newly appeared data in the ATR[] arrays
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      bar1=bar+1;
      bar2=bar+2;
      //---
      if(close[bar2]==open[bar2] && close[bar1]>high[bar2]) uptrend=true;
      if(close[bar2]!=open[bar2] && close[bar1]<=high[bar2]) uptrend=false;
      if(uptrend!=prev_uptrend && uptrend) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      //---
      if(close[bar2]==open[bar2] && close[bar1]<low[bar2]) downtrend=true;
      if(close[bar2]!=open[bar2] && close[bar1]>=low[bar2]) downtrend=false;
      if(downtrend!=prev_downtrend && downtrend) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
      //---
      if(bar)
        {
         prev_uptrend=uptrend;
         prev_downtrend=downtrend;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
