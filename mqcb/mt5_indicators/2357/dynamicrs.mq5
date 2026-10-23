//+------------------------------------------------------------------+
//|                                                    DynamicRS.mq5 |
//|                                 Copyright © 2007, Nick A. Zhilin |
//|                                                  rebus58@mail.ru |
//+------------------------------------------------------------------+
//--- copyright
#property copyright "Copyright © 2007, Nick A. Zhilin"
//--- a link to the website of the author
#property link      "rebus58@mail.ru"
//--- indicator version
#property version   "1.00"
#property description "A moving drawn without averaging" 
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- number of indicator buffers
#property indicator_buffers 1 
//--- one plot is used
#property indicator_plots   1
//+----------------------------------------------+ 
//| Indicator 1 drawing parameters               |
//+----------------------------------------------+
//--- a line is used for the indicator
#property indicator_type1   DRAW_LINE
//--- displaying the indicator label
#property indicator_label1  "DynamicRS"
//--- the color of the indicator
#property indicator_color1 clrDodgerBlue
//--- indicator line is a solid one
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1  2
//+----------------------------------------------+ 
//| declaration of constants                     |
//+----------------------------------------------+ 
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+ 
//| Indicator input parameters                   |
//+----------------------------------------------+ 
input uint Filter=15; // Width
//+----------------------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double IndBuffer[];
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
   min_rates_total=2;
   dFilter=Filter*_Point;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- indexing buffer elements as timeseries   
   ArraySetAsSeries(IndBuffer,true);
//--- set the position, from which the drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows 
   string shortname;
   StringConcatenate(shortname,"DynamicRS(",Filter,")");
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
//--- Calculate the limit starting number for loop of bars recalculation and start initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }
//--- apply timeseries indexing to array elements 
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- the first large indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(high[bar]<high[bar+1] && high[bar]<IndBuffer[bar+1]-dFilter) IndBuffer[bar]=high[bar];
      else if(low[bar]>low[bar+1] && low[bar]>IndBuffer[bar+1]+dFilter) IndBuffer[bar]=low[bar];
      else IndBuffer[bar]=IndBuffer[bar+1];
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
