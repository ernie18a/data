//+------------------------------------------------------------------+
//|                                                  The20sv0.20.mq5 |
//|                                    Copyright © 2005, TraderSeven | 
//|                                              TraderSeven@gmx.net | 
//+------------------------------------------------------------------+
/*
 * This EA has 2 main parts.
 * Variation=false
 * If previous bar opens in the lower 20% of its range and closes in the upper 20% of its range then sell on previous high+10pips.
 * If previous bar opens in the upper 20% of its range and closes in the lower 20% of its range then buy on previous low-10pips.

 * Variation=true
 * The previous bar is an inside bar that has a smaller range than the 3 bars before it.
 * If todays bar opens in the lower 20% of yesterdays range then buy.
 * If todays bar opens in the upper 20% of yesterdays range then sell.
 */
#property copyright "Copyright © 2005, TraderSeven"
#property link "TraderSeven@gmx.net"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----two buffers are used for calculation and drawing of the indicator
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|   Bearish indicator drawing parameters       |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- magenta color is used as the color of the bearish indicator line
#property indicator_color1  clrMagenta
//---- indicator 1 line width is equal to 2
#property indicator_width1  2
//---- bullish indicator label display
#property indicator_label1  "The20sv0.20 Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//---- blue color is used for the indicator bullish line
#property indicator_color2  clrBlue
//---- indicator 2 line width is equal to 2
#property indicator_width2  2
//---- bearish indicator label display
#property indicator_label2 "The20sv0.20 Buy"

//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input bool Variation=false;
input double StopLevel=0.20; // level of triggering
input uint Range=10;        // distance in points
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double SellBuffer[];
double BuyBuffer[];

double PRange;
//---- Declaration of integer variables of data starting point
int  min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables   
   min_rates_total=5;
   PRange=Range*_Point;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,181);
//---- indexing elements in the buffer as in time series
   ArraySetAsSeries(SellBuffer,true);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,181);
//---- indexing elements in the buffer as in time series
   ArraySetAsSeries(BuyBuffer,true);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="The20sv0.20";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
//---- checking for the sufficiency of bars for the calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit;

//--- calculations of the necessary amount of data to be copied and
//the limit starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing elements in arrays as in time series  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- main loop of the indicator calculation
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      SellBuffer[bar]=0.0;
      BuyBuffer[bar]=0.0;
      
      double LastBarsRange=high[bar+1]-low[bar+1];
      double Top20=high[bar+1]-LastBarsRange*StopLevel;
      double Bottom20=low[bar+1]+LastBarsRange*StopLevel;

      if(!Variation)
        {
         if(open[bar+1]>=Top20 && close[bar+1]<=Bottom20 && low[bar]<=low[bar+1]+PRange) BuyBuffer[bar]=low[bar];
         if(open[bar+1]<=Bottom20 && close[bar+1]>=Top20 && high[bar]>=high[bar+1]+PRange) SellBuffer[bar]=high[bar];
        }
      else
        {
         if((high[bar+4]-low[bar+4])>LastBarsRange
            && (high[bar+3]-low[bar+3])>LastBarsRange
            && (high[bar+2]-low[bar+2])>LastBarsRange
            && high[bar+2]>high[bar+1]
            && low[bar+2]<low[bar+1])
           {
            if(open[bar]<=Bottom20) BuyBuffer[bar]=low[bar];
            if(open[bar]>=Top20) SellBuffer[bar]=high[bar];
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
