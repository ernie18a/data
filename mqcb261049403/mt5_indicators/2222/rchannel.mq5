//+------------------------------------------------------------------+ 
//|                                                     RChannel.mq5 | 
//|                                    Copyright © 2005, Gosha Shmel |
//|                                           http://www.system32.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, Gosha Shmel"
#property link      "http://www.system32.ru"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 3 
//---- three plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//--- Lime color is used as the color of the indicator line
#property indicator_color1 clrLime
//--- Indicator line is a solid one
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "Upper RChannel"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used for the indicator line
#property indicator_color2 clrBlue
//--- the indicator line is a solid one
#property indicator_style2  STYLE_SOLID
//--- indicator line width is 1
#property indicator_width2  1
//--- displaying the indicator label
#property indicator_label2  "Middle RChannel"
//+-----------------------------------+
//|  Indicator 3 drawing parameters   |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type3   DRAW_LINE
//--- red color is used as the color of the indicator line
#property indicator_color3 clrRed
//--- the indicator line is a solid one
#property indicator_style3  STYLE_SOLID
//--- indicator line width is 1
#property indicator_width3  1
//--- displaying the indicator label
#property indicator_label3  "Lower RChannel"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int Shift=0; // Horizontal shift of the indicator in bars
//+-----------------------------------+
//--- indicator buffers
double UpperBuffer[];
double MiddleBuffer[];
double LowerBuffer[];
//--- declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+    
//| FractalChannel initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=2;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
//--- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Upper RChannel");
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpperBuffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,MiddleBuffer,INDICATOR_DATA);
//--- shifting the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- create a label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Middle RChannel");
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(MiddleBuffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(2,LowerBuffer,INDICATOR_DATA);
//--- shifting the indicator 3 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- shifting the starting point of the indicator 3 drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- create a label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Lower RChannel");
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(LowerBuffer,true);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"RChannel(",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//---
   Comment("");
//---
  }
//+------------------------------------------------------------------+  
//| FractalChannel iteration function                                | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
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
   if(rates_total<min_rates_total) return(0);
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- declaration of variables with a floating point  
   static double LowLine,HighLine,AverLine;
//--- declaration of integer variables
   int limit;
   static bool ww;
//--- calculations of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total; // starting index for the calculation of all bars
      ww=false;
      LowLine=999999.0;
      HighLine=0.0;
      AverLine=EMPTY_VALUE;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }
//--- main calculation loop of the indicator
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      MqlDateTime tm;
      TimeToStruct(time[bar],tm);
      if((tm.hour==23 && tm.min<59) || (tm.day_of_week==5 && tm.hour==22 && tm.min<59)) ww=false;
      if(tm.hour==0 && tm.min>=0 && tm.min<=30 && !ww)
        {
         LowLine=low[bar];
         HighLine=high[bar];
         ww=true;
        }
      else
        {
         LowLine=MathMin(low[bar],LowLine);
         HighLine=MathMax(high[bar],HighLine);
        }
      AverLine=LowLine+(HighLine-LowLine)/2;
      //---
      UpperBuffer[bar]=HighLine;
      LowerBuffer[bar]=LowLine;
      MiddleBuffer[bar]=AverLine;
     }
   Comment("High - ",HighLine,"; Low - ",LowLine,"; Average - ",AverLine,"; Channel width=",int((HighLine-LowLine)/_Point));
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
