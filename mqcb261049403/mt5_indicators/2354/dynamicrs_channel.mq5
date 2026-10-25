//+------------------------------------------------------------------+
//|                                            DynamicRS_Channel.mq5 |
//|                                 Copyright © 2007, Nick A. Zhilin |
//|                                                  rebus58@mail.ru |
//+------------------------------------------------------------------+
//--- copyright
#property copyright "Copyright © 2007, Nick A. Zhilin"
//--- a link to the website of the author
#property link      "rebus58@mail.ru"
//--- indicator version
#property version   "1.00"
#property description "A channel drawn without averaging" 
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
#property indicator_label1  "DynamicRS Middle"
//--- the color of the indicator
#property indicator_color1 clrDodgerBlue
//--- indicator line is a solid one
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1  2
//+----------------------------------------------+ 
//| Indicator 2 drawing parameters               |
//+----------------------------------------------+
//--- a line is used for the indicator
#property indicator_type2   DRAW_LINE
//--- displaying the indicator label
#property indicator_label2  "DynamicRS Upper"
//--- colors used for the indicator line
#property indicator_color2 clrRed
//--- indicator line is a solid one
#property indicator_style2  STYLE_SOLID
//--- indicator line width is 2
#property indicator_width2  2
//+----------------------------------------------+ 
//| Indicator 3 drawing parameters               |
//+----------------------------------------------+
//--- a line is used for the indicator
#property indicator_type3   DRAW_LINE
//--- displaying the indicator label
#property indicator_label3  "DynamicRS Lower"
//--- colors used for the indicator line
#property indicator_color3 clrMediumSeaGreen
//--- indicator line is a solid one
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
input uint Filter=150; // Width
//+----------------------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double LowestBuffer[];
double HighestBuffer[];
double MiddleBuffer[];
//---
double dFilter;
//--- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=2;
   dFilter=Filter*_Point;
//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,MiddleBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,HighestBuffer,INDICATOR_DATA);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//--- Indexing buffer elements as timeseries   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(MiddleBuffer,true);
//--- set the position, from which the drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows 
   string shortname;
   StringConcatenate(shortname,"DynamicRS_Channel(",Filter,")");
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
   double;
//--- calculate the limit starting number for loop of bars recalculation and start initialization of variables
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
      if(high[bar]<high[bar+1] &&  high[bar]<MiddleBuffer[bar+1]-dFilter) MiddleBuffer[bar]=high[bar];
      else if(low[bar]>low[bar+1]&& low[bar]>MiddleBuffer[bar+1]+dFilter) MiddleBuffer[bar]=low[bar];
      else MiddleBuffer[bar]=MiddleBuffer[bar+1];
      //---
      HighestBuffer[bar]=MiddleBuffer[bar]+dFilter;
      LowestBuffer[bar]=MiddleBuffer[bar]-dFilter;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
