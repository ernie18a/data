//+------------------------------------------------------------------+ 
//|                                                SmoothCandleS.mq5 | 
//|                                 Copyright © 2005, Varus Henschke | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, Varus Henschke"
#property link ""
//--- Indicator version
#property version   "1.00"
#property description "Averaging price timeseries using four MAs"
//--- drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers 4
#property indicator_buffers 4 
//--- four plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0                         // A constant for returning the indicator recalculation command to the terminal
#define INDICATOR_NAME "SmoothCandleS"  // A constant for the indicator name
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- the color of the indicator
#property indicator_color1  clrMagenta
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "Open"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- the color of the indicator
#property indicator_color2  clrDodgerBlue
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//--- indicator 2 line width is equal to 2
#property indicator_width2  2
//--- displaying the indicator label
#property indicator_label2  "Low"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 3 as a line
#property indicator_type3   DRAW_LINE
//--- the color of the indicator
#property indicator_color3  clrLime
//---- the indicator line is a continuous curve
#property indicator_style3  STYLE_SOLID
//--- indicator 3 line width is equal to 2
#property indicator_width3  2
//--- displaying the indicator label
#property indicator_label3  "High"
//+----------------------------------------------+
//|  Indicator 4 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator 4 as a line
#property indicator_type4   DRAW_LINE
//--- the color of the indicator
#property indicator_color4  clrBlueViolet
//---- the indicator line is a continuous curve
#property indicator_style4  STYLE_SOLID
//--- indicator 4 line width is equal to 2
#property indicator_width4  2
//--- displaying the indicator label
#property indicator_label4  "Close"
//+----------------------------------------------+
//|  Description of averaging classes            |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMAO,XMAL,XMAH,XMAC;
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input Smooth_Method XMA_Method=MODE_SMA;  // Method of averaging
input int XLength=5;                      // Averaging depth                    
input int XPhase=100;                     // Averaging parameter
//--- XPhase: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- XPhase: for VIDIA it is a CMO period, for AMA it is a slow average period
input int Shift=0;                        // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double HBuffer[];
double LBuffer[];
double OBuffer[];
double CBuffer[];
//--- declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- initialization of global variables 
   min_rates_total=GetStartBars(XMA_Method,XLength,XPhase)+1;
//--- Initialize indicator buffers
   IndInit(0,OBuffer,0.0,min_rates_total,Shift);
   IndInit(1,LBuffer,0.0,min_rates_total,Shift);
   IndInit(2,HBuffer,0.0,min_rates_total,Shift);
   IndInit(3,CBuffer,0.0,min_rates_total,Shift);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",XLength,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
   if(rates_total<min_rates_total) return(RESET);
//--- declarations of local variables 
   int first,bar;
//--- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=0; // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // Starting index for the calculation of new bars
//--- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //--- Four calls of the XMASeries functions.  
      OBuffer[bar]=XMAO.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,open [bar],bar,false);
      CBuffer[bar]=XMAC.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,close[bar],bar,false);
      HBuffer[bar]=XMAH.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,high [bar],bar,false);
      LBuffer[bar]=XMAL.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,low  [bar],bar,false);
     }
//---         
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Indicator buffer initialization                                  |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---
  }
//+------------------------------------------------------------------+
