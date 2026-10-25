/*
* Place the SmoothAlgorithms.mqh 
  and IndicatorsAlgorithms.mqh files to the
  terminal_data_folder\MQL5\Include
*/
//+------------------------------------------------------------------+
//|                                                         LRMA.mq5 |
//|                               Copyright © 2010, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "2010,   Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"

//---- Drawing the indicator in the main window
#property indicator_chart_window
//---- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 1
//---- only one plot is used
#property indicator_plots   1
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use lime green color for the indicator line
#property indicator_color1  LimeGreen

//---- indicator input parameters
input int LRMAPeriod=13; //LRMA period
input int LRMAShift=0; //Horizontal shift of LRMA in bars
input int LRMAPriceShift=0; //Vertical shift of LRMA in points

//---- Indicator buffer
double ExtLineBuffer[];

double dPriceShift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- name for the data window and the label for sub-windows
   string short_name="LRMA";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name+"("+string(LRMAPeriod)+")");
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,LRMAPeriod+1);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- set ExtLineBuffer as indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by LRMAShift
   PlotIndexSetInteger(0,PLOT_SHIFT,LRMAShift);
//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization of the vertical shift
   dPriceShift=_Point*LRMAPriceShift;
//---- declaration of variable of the Moving_Average class from the MASeries_Cls.mqh file
   CMoving_Average LRMA1;
//---- setting up alerts for unacceptable values of external variables
   LRMA1.MALengthCheck("LRMAPeriod",LRMAPeriod);
//----
  }
//+------------------------------------------------------------------+
// Description of the smoothing and indicators classes               |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>
#include <IndicatorsAlgorithms.mqh> 
//+------------------------------------------------------------------+ 
//|  Moving Average                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,     // number of bars in history at the current tick
                const int prev_calculated, // number of bars calculated at previous call
                const int begin,           // bars reliable counting beginning index
                const double &price[]      // price array for calculation of the indicator
                )
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<begin+LRMAPeriod)
      return(0);

//---- declarations of local variables 
   int first,bar;

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=begin; // starting index for calculation of all bars
      for(bar=0; bar<=begin; bar++)
         ExtLineBuffer[bar]=0;
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of variable of the Moving_Average class from the LRMASeries_Cls.mqh file
   static CLRMA LRMA1;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- Getting the average value. One call of the LRMASeries function.  
      ExtLineBuffer[bar]=LRMA1.LRMASeries(begin,prev_calculated,rates_total,LRMAPeriod,price[bar],bar,false)+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
