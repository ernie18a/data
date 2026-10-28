/*
 *  << Chande Momentum Oscillator >>
 *
 * It used a library of smothing algorithms,
 * SmoothAlgorithms.mqh must be placed to 
 * terminal_data_folder\MQL5\Include
 *
 * Usage:
 *
 * 1) The simple interpretation of CMO is the "overbought/oversold" states of the market. 
 * "Overbought" - when it has values +70 and higher, "oversold" when its values +30 and lowеr.
 * 2) Tremd indicator. Buy when slow CMO has crossed the fast CMO, sell when fast CMO has crossed the slow CMO.
 */
//+------------------------------------------------------------------+
//|                                   Chande Momentum Oscillator.mq5 |
//|              MQL5 Code:     Copyright © 2010,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- copyright
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- version
#property version   "1.00"
//---- plot in a separate window
#property indicator_separate_window
//---- one buffer is used
#property indicator_buffers 1
//---- one graphic plot is used
#property indicator_plots   1
//---- draw as a line
#property indicator_type1   DRAW_LINE
//---- line color (Gold)
#property indicator_color1  Gold
//---- line style
#property indicator_style1  STYLE_SOLID
//---- line width
#property indicator_width1  2
//---- indicator label
#property indicator_label1  "CMO"
//---- horizontal levels
#property indicator_level1  +50
#property indicator_level2    0
#property indicator_level3  -50
#property indicator_levelcolor Magenta
#property indicator_levelstyle STYLE_DASHDOTDOT

//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input int CMO_period= 9; // CMO period
input int CMO_Shift = 0; // CMO shift
//+----------------------------------------------+
//---- declaration of dynamic array, used as an indicator buffer
double ExtLineBuffer[];
//+------------------------------------------------------------------+
// CCMO class
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- set ExtLineBuffer[] as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- set horizontal shift
   PlotIndexSetInteger(0,PLOT_SHIFT,CMO_Shift);
//---- set plot draw begin
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,CMO_period);
//---- indicator short name
   string shortname;
   StringConcatenate(shortname,"CMO(",CMO_period,")");
//--- indicator plot label
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//--- set indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- set precision
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- set empty values
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // rates total
                const int prev_calculated,// bars, calculated at previous call
                const int begin,          // starting index
                const double &price[]     // price array
                )
  {
//---- checking of bars
   if(rates_total<CMO_period+1+begin)
      return(0);

//---- declaration of local variables
   int first,bar;

//---- set starting bar index (first)
   if(prev_calculated>rates_total || prev_calculated<=0) // at first call
     {
      first=0+begin; // starting index
      //--- increase position
      if(begin>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,CMO_period+2+begin);
     }
   else
     {
      first=prev_calculated-1; // starting bar index
     }

//---- declaration of CCMO class object
   static CCMO CMO;

//---- main loop
   for(bar=first; bar<rates_total; bar++)
      ExtLineBuffer[bar]=CMO.CMOSeries(begin,prev_calculated,rates_total,CMO_period,price[bar],bar,false)*200-100;
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
