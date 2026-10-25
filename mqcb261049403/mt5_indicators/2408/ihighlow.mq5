//+------------------------------------------------------------------+
//|                                                    i-HighLow.mq5 |
//|                                          Copyright © 2007, RickD |
//|                                            http://www.e2e-fx.net |
//+------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2007, RickD"
//--- a link to the website of the author
#property link      "http://www.e2e-fx.net"
//--- indicator version
#property version   "1.00"
#property description "" 
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- three buffers are used for the indicator calculation and drawing
#property indicator_buffers 3
//--- three plots are used
#property indicator_plots   3
//+----------------------------------------------+ 
//| Indicator 1 drawing parameters               |
//+----------------------------------------------+
//--- a line is used for the indicator
#property indicator_type1   DRAW_LINE
//--- displaying the indicator label
#property indicator_label1  "i-HighLow Middle"
//--- the color of the indicator
#property indicator_color1 clrSlateGray
//--- Indicator line is a solid one
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1  2
//+----------------------------------------------+ 
//| Indicator 2 drawing parameters               |
//+----------------------------------------------+
//--- a line is used for the indicator
#property indicator_type2   DRAW_LINE
//--- displaying the indicator label
#property indicator_label2  "i-HighLow Upper"
//--- colors used for the indicator line
#property indicator_color2 clrDodgerBlue
//--- Indicator line is a solid one
#property indicator_style2  STYLE_SOLID
//--- indicator line width is 2
#property indicator_width2  2
//+----------------------------------------------+ 
//| Indicator 3 drawing parameters               |
//+----------------------------------------------+
//--- a line is used for the indicator
#property indicator_type3   DRAW_LINE
//--- displaying the indicator label
#property indicator_label3  "i-HighLow Lower"
//--- colors used for the indicator line
#property indicator_color3 clrMagenta
//--- Indicator line is a solid one
#property indicator_style3  STYLE_SOLID
//--- indicator line width is 2
#property indicator_width3  2
//+----------------------------------------------+ 
//| declaration of constants                     |
//+----------------------------------------------+ 
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+ 
//| Indicator input parameters                   |
//+----------------------------------------------+ 
input uint period=20;   // The number of candlesticks for determining extremum
input uint Filter=50;   // Width of the offset from the candlestick in points
input int Shift=0;      // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double LowestBuffer[];
double HighestBuffer[];
double MiddleBuffer[];
//---
double dFilter;
//--- declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(period);
   dFilter=Filter*_Point;
//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,MiddleBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighestBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LowestBuffer,INDICATOR_DATA);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//---- set indexing buffer elements as timeseries   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(MiddleBuffer,true);
//--- set the position, from which the drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows 
   string shortname;
   StringConcatenate(shortname,"i-HighLow_Channel(",Filter,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---   
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
   if(rates_total<min_rates_total)return(RESET);
//--- declarations of local variables 
   int limit,bar;
   double HH,LL;
//--- calculate the limit starting number for loop of bars recalculation and start initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars
//--- apply timeseries indexing to array elements 
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- the first large indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HH=high[ArrayMaximum(high,bar,period)];
      LL=low[ArrayMinimum(low,bar,period)];
      //---
      HighestBuffer[bar]=HH+dFilter;
      LowestBuffer[bar]=LL-dFilter;
      MiddleBuffer[bar]=(HH+LL)/2.0;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
