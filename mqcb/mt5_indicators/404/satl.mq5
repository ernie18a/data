//+------------------------------------------------------------------+
//|                                                         Satl.mq5 |
//|                                  Copyright 2002, Finware.ru Ltd. |
//|                                           http://www.finware.ru/ |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright 2002, Finware.ru Ltd."
//---- link to the website of the author
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
//---- red color is used as the color of the indicator line
#property indicator_color1  Red
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "SATL"

//---- indicator input parameters
input int SATLShift=0;   //Horizontal shift of the average in bars 

//---- declaration and initialization of a variable for storing the number of calculated bars
int SATLPeriod=65;

//---- declaration of a dynamic array that
//will be used as an indicator buffer
double ExtLineBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//----+
//---- set ExtLineBuffer dynamic array as indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by SATLShift
   PlotIndexSetInteger(0,PLOT_SHIFT,SATLShift);
//---- set the position, from which the indicator drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,SATLPeriod);
//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"SATL(",SATLShift,")");
//---- create label to display in Data Window
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//----+
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,     // number of bars in history at the current tick
                const int prev_calculated, // number of bars calculated at previous call
                const int begin,           // bars reliable counting beginning index
                const double &price[]      // price array for calculation of the indicator
                )
  {
//----+   
//---- checking the number of bars to be enough for the calculation
   if(rates_total<SATLPeriod-1+begin)
      return(0);

//---- declarations of local variables 
   int first,bar;
   double SATL;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=SATLPeriod-1+begin;  // starting index for calculation of all bars
      //---- increase the position of the beginning of data by 'begin' bars as a result of calculation using data of another indicator
      if(begin>0)
         PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin+SATLPeriod);
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- 
      SATL=0.0982862174*price[bar-0]
           +0.0975682269 * price[bar - 1]
           +0.0961401078 * price[bar - 2]
           +0.0940230544 * price[bar - 3]
           +0.0912437090 * price[bar - 4]
           +0.0878391006 * price[bar - 5]
           +0.0838544303 * price[bar - 6]
           +0.0793406350 * price[bar - 7]
           +0.0743569346 * price[bar - 8]
           +0.0689666682 * price[bar - 9]
           +0.0632381578 * price[bar - 10]
           +0.0572428925 * price[bar - 11]
           +0.0510534242 * price[bar - 12]
           +0.0447468229 * price[bar - 13]
           +0.0383959950 * price[bar - 14]
           +0.0320735368 * price[bar - 15]
           +0.0258537721 * price[bar - 16]
           +0.0198005183 * price[bar - 17]
           +0.0139807863 * price[bar - 18]
           +0.0084512448 * price[bar - 19]
           +0.0032639979 * price[bar - 20]
           -0.0015350359 * price[bar - 21]
           -0.0059060082 * price[bar - 22]
           -0.0098190256 * price[bar - 23]
           -0.0132507215 * price[bar - 24]
           -0.0161875265 * price[bar - 25]
           -0.0186164872 * price[bar - 26]
           -0.0205446727 * price[bar - 27]
           -0.0219739146 * price[bar - 28]
           -0.0229204861 * price[bar - 29]
           -0.0234080863 * price[bar - 30]
           -0.0234566315 * price[bar - 31]
           -0.0231017777 * price[bar - 32]
           -0.0223796900 * price[bar - 33]
           -0.0213300463 * price[bar - 34]
           -0.0199924534 * price[bar - 35]
           -0.0184126992 * price[bar - 36]
           -0.0166377699 * price[bar - 37]
           -0.0147139428 * price[bar - 38]
           -0.0126796776 * price[bar - 39]
           -0.0105938331 * price[bar - 40]
           -0.0084736770 * price[bar - 41]
           -0.0063841850 * price[bar - 42]
           -0.0043466731 * price[bar - 43]
           -0.0023956944 * price[bar - 44]
           -0.0005535180 * price[bar - 45]
           +0.0011421469 * price[bar - 46]
           +0.0026845693 * price[bar - 47]
           +0.0040471369 * price[bar - 48]
           +0.0052380201 * price[bar - 49]
           +0.0062194591 * price[bar - 50]
           +0.0070340085 * price[bar - 51]
           +0.0076266453 * price[bar - 52]
           +0.0080376628 * price[bar - 53]
           +0.0083037666 * price[bar - 54]
           +0.0083694798 * price[bar - 55]
           +0.0082901022 * price[bar - 56]
           +0.0080741359 * price[bar - 57]
           +0.0077543820 * price[bar - 58]
           +0.0073260526 * price[bar - 59]
           +0.0068163569 * price[bar - 60]
           +0.0062325477 * price[bar - 61]
           +0.0056078229 * price[bar - 62]
           +0.0049516078 * price[bar - 63]
           +0.0161380976 * price[bar - 64];

      //---- initialization of a cell of the indicator buffer with the received value of SATL
      ExtLineBuffer[bar]=SATL;
     }
//----+     
   return(rates_total);
  }
//+------------------------------------------------------------------+
