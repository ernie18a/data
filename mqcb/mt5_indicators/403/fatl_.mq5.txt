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
#property version   "2.00"
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
int FATLPeriod;

//---- declaration of a dynamic array that 
// will be used as an indicator buffer
double ExtLineBuffer[];

//---- declaration and initialization of an array for the coefficient of the digital filter
double FATLTable[]=
  {
   +0.4360409450, +0.3658689069, +0.2460452079, +0.1104506886, -0.0054034585, -0.0760367731,
   -0.0933058722, -0.0670110374, -0.0190795053, +0.0259609206, +0.0502044896, +0.0477818607,
   +0.0249252327, -0.0047706151, -0.0272432537, -0.0338917071, -0.0244141482, -0.0055774838,
   +0.0128149838, +0.0226522218, +0.0208778257, +0.0100299086, -0.0036771622, -0.0136744850,
   -0.0160483392, -0.0108597376, -0.0016060704, +0.0069480557, +0.0110573605, +0.0095711419,
   +0.0040444064, -0.0023824623, -0.0067093714, -0.0072003400, -0.0047717710, +0.0005541115,
   +0.0007860160, +0.0130129076, +0.0040364019
  };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- set ExtLineBuffer dynamic array as indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- performing the horizontal shift of FATL by FATLShift
   PlotIndexSetInteger(0,PLOT_SHIFT,FATLShift);
//---- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,FATLPeriod);
//---- initializations of a variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"FATL(",FATLShift,")");
//--- creating a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- getting the length of the digital filter
   FATLPeriod=ArraySize(FATLTable);
//---- shifting the start of drawing of the indicator 
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,FATLPeriod);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[]     // price array for calculation of the indicator
                )
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<FATLPeriod-1+begin)
      return(0);

//---- declarations of local variables 
   int first,bar,iii;
   double FATL;

//---- calculation of the 'first' starting index for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=FATLPeriod-1+begin; // starting index for calculation of all bars
      //--- increase the position of the beginning of data by 'begin' bars as a result of calculation using data of another indicator
      if(begin>0)
         PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin+FATLPeriod);
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main loop of the indicator calculation
   for(bar=first; bar<rates_total; bar++)
     {
      //---- formula for calculation of the digital filter
      FATL=0.0;
      for(iii=0; iii<FATLPeriod; iii++)
         FATL+=FATLTable[iii]*price[bar-iii];

      //---- Initialization of the cell of indicator buffer by the obtained value of FATL
      ExtLineBuffer[bar]=FATL;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
