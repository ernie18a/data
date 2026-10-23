//+------------------------------------------------------------------+
//|                                                         RFTL.mq5 |
//|                                  Copyright 2002, Finware.ru Ltd. |
//|                                           http://www.finware.ru/ |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright 2002, Finware.ru Ltd."
//---- link to the website of the author
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
//---- use aquamarine color for the indicator line
#property indicator_color1  Aquamarine
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1  2
//---- display the indicator label
#property indicator_label1  "RFTL"

//---- indicator input parameters
input int RFTLShift=0; // Horizontal shift of moving average in bars 

//---- declaration and initialization of a variable for storing the number of calculated bars
int RFTLPeriod;

//---- declaration of a dynamic array that 
//---- will be used as an indicator buffer
double ExtLineBuffer[];

//---- declaration and initialization of an array for the coefficient of the digital filter
double RFTLTable[]=
  {
   -0.0025097319, +0.0513007762, +0.1142800493, +0.1699342860, +0.2025269304,
   +0.2025269304, +0.1699342860, +0.1142800493, +0.0513007762, -0.0025097319,
   -0.0353166244, -0.0433375629, -0.0311244617, -0.0088618137, +0.0120580088,
   +0.0233183633, +0.0221931304, +0.0115769653, -0.0022157966, -0.0126536111,
   -0.0157416029, -0.0113395830, -0.0025905610, +0.0059521459, +0.0105212252,
   +0.0096970755, +0.0046585685, -0.0017079230, -0.0063513565, -0.0074539350,
   -0.0050439973, -0.0007459678, +0.0032271474, +0.0051357867, +0.0044454862,
   +0.0018784961, -0.0011065767, -0.0031162862, -0.0033443253, -0.0022163335,
   +0.0002573669, +0.0003650790, +0.0060440751, +0.0018747783
  };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- set ExtLineBuffer as indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- performing the horizontal shift of FATL by RFTLShift
   PlotIndexSetInteger(0,PLOT_SHIFT,RFTLShift);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,RFTLPeriod);
//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"RFTL(",RFTLShift,")");
//---- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- getting the length of the digital filter
   RFTLPeriod=ArraySize(RFTLTable);
//---- performing the shift of beginning of the indicator drawing 
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,RFTLPeriod);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const int begin,// bars reliable counting index
                const double &price[]// price array for the indicator calculation
                )
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<RFTLPeriod-1+begin)
      return(0);

//---- declarations of local variables 
   int first,bar,iii;
   double RFTL;

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=RFTLPeriod-1+begin; // starting index for calculation of all bars
      //--- increase the position of the beginning of data by 'begin' bars as a result of calculation using data of another indicator
      if(begin>0)
         PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin+RFTLPeriod);
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- formula for the digital filter calculation
      RFTL=0.0;
      for(iii=0; iii<RFTLPeriod; iii++)
         RFTL+=RFTLTable[iii]*price[bar-iii];

      //---- Initialization of a cell of the indicator buffer with the RFTL received value
      ExtLineBuffer[bar]=RFTL;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
