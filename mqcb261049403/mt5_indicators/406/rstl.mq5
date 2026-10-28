//+------------------------------------------------------------------+
//|                                                         RSTL.mq5 |
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
//---- use dark violet color for the indicator line
#property indicator_color1  DarkViolet
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "RSTL"

//---- indicator input parameters
input int RSTLShift=0; // Horizontal shift of moving average in bars 

//---- declaration and initialization of a variable for storing the number of calculated bars
int RSTLPeriod=99;

//---- declaration of a dynamic array that
// will be used as an indicator buffer
double ExtLineBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- set ExtLineBuffer as indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by RSTLShift
   PlotIndexSetInteger(0,PLOT_SHIFT,RSTLShift);
//---- set the position, from which the indicator drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,RSTLPeriod);
//---- initialization of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"RSTL(",RSTLShift,")");
//---- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determine the accuracy of displaying indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,// number of bars in history at the current tick
                const int prev_calculated, // number of bars calculated at previous call
                const int begin,           // bars reliable counting beginning index
                const double &price[]      // price array for calculation of the indicator
                )
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<RSTLPeriod-1+begin)
      return(0);

//---- declarations of local variables 
   int first,bar;
   double RSTL;

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of the indicator
     {
      first=RSTLPeriod-1+begin;  // starting index for calculation of all bars
      //---- increase the position of the beginning of data by 'begin' bars as a result of calculation using data of another indicator
      if(begin>0)
         PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin+RSTLPeriod);
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- 
      RSTL=-0.00514293*price[bar-0]
           -0.00398417 * price[bar - 1]
           -0.00262594 * price[bar - 2]
           -0.00107121 * price[bar - 3]
           +0.00066887 * price[bar - 4]
           +0.00258172 * price[bar - 5]
           +0.00465269 * price[bar - 6]
           +0.00686394 * price[bar - 7]
           +0.00919334 * price[bar - 8]
           +0.01161720 * price[bar - 9]
           +0.01411056 * price[bar - 10]
           +0.01664635 * price[bar - 11]
           +0.01919533 * price[bar - 12]
           +0.02172747 * price[bar - 13]
           +0.02421320 * price[bar - 14]
           +0.02662203 * price[bar - 15]
           +0.02892446 * price[bar - 16]
           +0.03109071 * price[bar - 17]
           +0.03309496 * price[bar - 18]
           +0.03490921 * price[bar - 19]
           +0.03651145 * price[bar - 20]
           +0.03788045 * price[bar - 21]
           +0.03899804 * price[bar - 22]
           +0.03984915 * price[bar - 23]
           +0.04042329 * price[bar - 24]
           +0.04071263 * price[bar - 25]
           +0.04071263 * price[bar - 26]
           +0.04042329 * price[bar - 27]
           +0.03984915 * price[bar - 28]
           +0.03899804 * price[bar - 29]
           +0.03788045 * price[bar - 30]
           +0.03651145 * price[bar - 31]
           +0.03490921 * price[bar - 32]
           +0.03309496 * price[bar - 33]
           +0.03109071 * price[bar - 34]
           +0.02892446 * price[bar - 35]
           +0.02662203 * price[bar - 36]
           +0.02421320 * price[bar - 37]
           +0.02172747 * price[bar - 38]
           +0.01919533 * price[bar - 39]
           +0.01664635 * price[bar - 40]
           +0.01411056 * price[bar - 41]
           +0.01161720 * price[bar - 42]
           +0.00919334 * price[bar - 43]
           +0.00686394 * price[bar - 44]
           +0.00465269 * price[bar - 45]
           +0.00258172 * price[bar - 46]
           +0.00066887 * price[bar - 47]
           -0.00107121 * price[bar - 48]
           -0.00262594 * price[bar - 49]
           -0.00398417 * price[bar - 50]
           -0.00514293 * price[bar - 51]
           -0.00609634 * price[bar - 52]
           -0.00684602 * price[bar - 53]
           -0.00739452 * price[bar - 54]
           -0.00774847 * price[bar - 55]
           -0.00791630 * price[bar - 56]
           -0.00790940 * price[bar - 57]
           -0.00774085 * price[bar - 58]
           -0.00742482 * price[bar - 59]
           -0.00697718 * price[bar - 60]
           -0.00641613 * price[bar - 61]
           -0.00576108 * price[bar - 62]
           -0.00502957 * price[bar - 63]
           -0.00423873 * price[bar - 64]
           -0.00340812 * price[bar - 65]
           -0.00255923 * price[bar - 66]
           -0.00170217 * price[bar - 67]
           -0.00085902 * price[bar - 68]
           -0.00004113 * price[bar - 69]
           +0.00073700 * price[bar - 70]
           +0.00146422 * price[bar - 71]
           +0.00213007 * price[bar - 72]
           +0.00272649 * price[bar - 73]
           +0.00324752 * price[bar - 74]
           +0.00368922 * price[bar - 75]
           +0.00405000 * price[bar - 76]
           +0.00433024 * price[bar - 77]
           +0.00453068 * price[bar - 78]
           +0.00465046 * price[bar - 79]
           +0.00469058 * price[bar - 80]
           +0.00466041 * price[bar - 81]
           +0.00457855 * price[bar - 82]
           +0.00442491 * price[bar - 83]
           +0.00423019 * price[bar - 84]
           +0.00399201 * price[bar - 85]
           +0.00372169 * price[bar - 86]
           +0.00342736 * price[bar - 87]
           +0.00311822 * price[bar - 88]
           +0.00280309 * price[bar - 89]
           +0.00249088 * price[bar - 90]
           +0.00219089 * price[bar - 91]
           +0.00191283 * price[bar - 92]
           +0.00166683 * price[bar - 93]
           +0.00146419 * price[bar - 94]
           +0.00131867 * price[bar - 95]
           +0.00124645 * price[bar - 96]
           +0.00126836 * price[bar - 97]
           -0.00401854 * price[bar - 98];
      //---- Initialization of a cell of the indicator buffer by the received RSTL value
      ExtLineBuffer[bar]=RSTL;
     }
//----+     
   return(rates_total);
  }
//+------------------------------------------------------------------+
