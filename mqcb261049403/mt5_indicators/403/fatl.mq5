//+------------------------------------------------------------------+
//|                                                         Fatl.mq5 |
//|                                  Copyright 2002, Finware.ru Ltd. |
//|                                           http://www.finware.ru/ |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright 2002, Finware.ru Ltd."
//---- link to the author's website
#property link      "http://www.finware.ru/"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 1
//---- only one plot is used
#property indicator_plots   1
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used as the color of the indicator line
#property indicator_color1  Blue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator line label
#property indicator_label1  "FATL"

//---- indicator input parameters
input int FATLShift=0; // Horizontal shift of moving average in bars 

//---- declaration and initialization of a variable for storing the number of calculated bars
int FATLPeriod=39;

//---- declaration of a dynamic array that 
// will be used as an indicator buffer
double ExtLineBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- set ExtLineBuffer dynamic array as indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by FATLShift
   PlotIndexSetInteger(0,PLOT_SHIFT,FATLShift);
//---- setting the indicator drawing initial position
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,FATLPeriod);
//---- initializations of a variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"FATL(",FATLShift,")");
//--- create label to display in Data Window
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- creating name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,     // number of bars in history at the current tick
                const int prev_calculated, // number of bars calculated at previous call
                const int begin,           // number of beginning of reliable counting of bars
                const double &price[]      // price array for calculation of the indicator
                )
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<FATLPeriod-1+begin)
      return(0);

//---- declarations of local variables 
   int first,bar;
   double FATL;

//---- calculation of the 'first' starting index for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=FATLPeriod-1+begin;  // starting number for calculation of all bars
      //---- increase the position of the beginning of data by 'begin' bars as a result of calculation using data of another indicator
      if(begin>0)
         PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin+FATLPeriod);
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main loop of the indicator calculation
   for(bar=first; bar<rates_total; bar++)
     {
      //---- 
      FATL=0.4360409450*price[bar-0]
           + 0.3658689069 * price[bar - 1]
           + 0.2460452079 * price[bar - 2]
           + 0.1104506886 * price[bar - 3]
           - 0.0054034585 * price[bar - 4]
           - 0.0760367731 * price[bar - 5]
           - 0.0933058722 * price[bar - 6]
           - 0.0670110374 * price[bar - 7]
           - 0.0190795053 * price[bar - 8]
           + 0.0259609206 * price[bar - 9]
           + 0.0502044896 * price[bar - 10]
           + 0.0477818607 * price[bar - 11]
           + 0.0249252327 * price[bar - 12]
           - 0.0047706151 * price[bar - 13]
           - 0.0272432537 * price[bar - 14]
           - 0.0338917071 * price[bar - 15]
           - 0.0244141482 * price[bar - 16]
           - 0.0055774838 * price[bar - 17]
           + 0.0128149838 * price[bar - 18]
           + 0.0226522218 * price[bar - 19]
           + 0.0208778257 * price[bar - 20]
           + 0.0100299086 * price[bar - 21]
           - 0.0036771622 * price[bar - 22]
           - 0.0136744850 * price[bar - 23]
           - 0.0160483392 * price[bar - 24]
           - 0.0108597376 * price[bar - 25]
           - 0.0016060704 * price[bar - 26]
           + 0.0069480557 * price[bar - 27]
           + 0.0110573605 * price[bar - 28]
           + 0.0095711419 * price[bar - 29]
           + 0.0040444064 * price[bar - 30]
           - 0.0023824623 * price[bar - 31]
           - 0.0067093714 * price[bar - 32]
           - 0.0072003400 * price[bar - 33]
           - 0.0047717710 * price[bar - 34]
           + 0.0005541115 * price[bar - 35]
           + 0.0007860160 * price[bar - 36]
           + 0.0130129076 * price[bar - 37]
           + 0.0040364019 * price[bar - 38];

      //---- Initialization of the cell of indicator buffer by the obtained value of FATL
      ExtLineBuffer[bar]=FATL;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
