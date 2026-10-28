//+------------------------------------------------------------------+
//|                                                BidAskChannel.mq5 | 
//|                             Copyright © 2012,                    | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012,"
#property link ""
#property description "High and Low level indicator taking spread into account"

//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers is 2
#property indicator_buffers 2
//---- only 1 plot is used
#property indicator_plots   1

//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal

//+--------------------------------------------+
//|  Indicator levels drawing parameters    |
//+--------------------------------------------+
//---- drawing the levels as lines
#property indicator_type1   DRAW_HISTOGRAM2
//---- indicator width is 1
#property indicator_width1 1
//---- selecting colors for the levels
#property indicator_color1  clrBlue
//---- displaying labels of the levels
#property indicator_label1  "BidAskChannel"

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[];

//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+   
//| SL_ATR indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of data starting point
   min_rates_total=1;

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);

//---- setting a position from which the drawing of Bollinger bands begins
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

//---- restriction on drawing empty values by the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- indexing buffer elements as time series   
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);

//--- creating a name to be displayed in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"BidAskChannel");

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| SL_ATR iteration function                                        | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // history in bars at the current tick
                const int prev_calculated,// history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaring local variables 
   int limit,bar;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total; // starting index for the calculation of all bars
      for(bar=rates_total-1; bar>limit && !IsStopped(); bar--)
        {
         ExtLineBuffer1[bar]=0.0;
         ExtLineBuffer2[bar]=0.0;
        }

     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

//---- indexing array elements as time series  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(spread,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtLineBuffer2[bar]=high[bar]+_Point*spread[bar];
      ExtLineBuffer1[bar]=low[bar];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
