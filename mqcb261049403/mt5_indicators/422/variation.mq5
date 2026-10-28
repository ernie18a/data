/*
* The indicator uses the SmoothAlgorithms.mqh library
* it must be placed to  terminal_data_folder\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                    Variation.mq5 | 
//|                                         Copyright © 2010, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, LeMan."
#property link      "b-market@mail.ru"
//---- version
#property version   "1.00"
//---- plot in a separate window
#property indicator_separate_window
//---- number of buffers used
#property indicator_buffers 1 
//---- number of graphic plots used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator plot settings          |
//+-----------------------------------+
//---- draw as a line
#property indicator_type1   DRAW_LINE
//---- line color (Salmon)
#property indicator_color1 Salmon
//---- line style (solid line)
#property indicator_style1  STYLE_SOLID
//---- line width
#property indicator_width1  2
//---- line label
#property indicator_label1  "Variation"
//+----------------------------------------------+
//| Horizontal levels                            |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor Blue
#property indicator_levelstyle STYLE_SOLID
//+-----------------------------------+
//|  Input parameters                 |
//+-----------------------------------+
input int Period_=12;                     //Averaging period
input ENUM_MA_METHOD MA_Method_=MODE_SMA; //Averaging method
input int Shift=0;                        //Horizontal shift in bars
//+-----------------------------------+
//---- indicator buffer
double ExtMapBuffer[];

int start=0;
double dPriceShift;
//+------------------------------------------------------------------+
// the Moving_Average class is used                                  | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+   
//| Variation indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- set ExtMapBuffer[] array as indicator buffer
   SetIndexBuffer(0,ExtMapBuffer,INDICATOR_DATA);
//---- set horizontal shift 
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- set plot draw begin
   if(MA_Method_!=MODE_EMA) start=2*Period_;
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
//---- set empty values
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- set indicator plot label
   PlotIndexSetString(0,PLOT_LABEL,"Variation");
//---- initialization of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Variation( Period_ = ",Period_,", MA_Method_ = ",MA_Method_,")");
//---- set indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- set precision
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| Variation iteration function                                     | 
//+------------------------------------------------------------------+ 
int OnCalculate (const int rates_total,      // rates total
                 const int prev_calculated,  // bars, calculated at previous call
                 const int begin,            // starting index
                 const double &price[]       // price array
                 )
  {
//----
   start+=begin;
//---- checking of bars
   if(rates_total<start) return(0);

//---- declaration of variables of integer type
   int first,bar;
//---- declaration of variables of double type
   double ma1,ma2,ma3;
//---- declaration of static variables
   static int start1,start2,start3;

//---- starting indexes
   if(prev_calculated>rates_total || prev_calculated<=0) // at first call
     {
      first=begin; // for all bars

      //---- initialization of indexes
      start1=begin;
      if(MA_Method_!=MODE_EMA)
        {
         start2 = Period_ + begin;
         start3 = start2 + Period_;
        }
      else
        {
         start2 = begin;
         start3 = begin;
        }

      //--- increase the starting position
      if(begin>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
     }
   else first=prev_calculated-1; // starting index

//---- declaraton of Moving_Average class objects
   static CMoving_Average MA1,MA2,MA3;

//---- indicator main loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- 3 call of MASeries method
      ma1 = MA1.MASeries(start1, prev_calculated, rates_total, Period_, MA_Method_, price[bar], bar, false);
      ma2 = MA2.MASeries(start2, prev_calculated, rates_total, Period_, MA_Method_, price[bar]-ma1, bar, false);
      ma3 = MA3.MASeries(start3, prev_calculated, rates_total, Period_, MA_Method_, price[bar]-ma2-ma1, bar, false);
      //----       
      ExtMapBuffer[bar]=ma3;
     }
//----     
   return(rates_total);
  }
//+-----------------------------------------------------------------+