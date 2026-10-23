//+------------------------------------------------------------------+ 
//|                                                           XO.mq5 | 
//|                                 Copyright © 2008, SHARIPOV AINUR | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2008, SHARIPOV AINUR"
#property link "" 
//---- The version of the indicator
#property version   "1.00"
//---- The indicatris drawn in a separate window
#property indicator_separate_window 
//---- 2 indicator buffers are used
#property indicator_buffers 2 
//---- One graphical construction is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- The indicator is drawn as a our-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- The following colors are used for the histogram
#property indicator_color1 clrDeepPink,clrGray,clrLime
//---- The indicator is drawn as a solid line
#property indicator_style1 STYLE_SOLID
//---- The line width is 2
#property indicator_width1 2
//---- The label of the indicator
#property indicator_label1 "XO"

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint Range=10; //Range
//+-----------------------------------+
//---- Declaring integer variables of data calculation start
int min_rates_total;
//---- Declaring dynamic arrays that will be further 
// used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//---- Declaring variables
double dRange;
//+------------------------------------------------------------------+    
//| XO indicator initialization function                             | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=2;

//---- Initializations of variables
   dRange=Range*_Point;

//---- Set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- Shifting the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);

//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"XO");
//--- Determining the accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- End of initialization
  }
//+------------------------------------------------------------------+  
//| XO iteration function                                            | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,     // amount of history in bars at the current tick
                const int prev_calculated, // number of bars calculated at previous call
                const int begin,           // number of beginning of reliable counting of bars
                const double &price[]      // price array for calculation of the indicator
                )
  {
//---- Checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total+begin) return(0);

//---- Declaration of local variables 
   int first,bar,kr,no;
   double Hi,Lo;
   static double Hi_,Lo_;
   static int kr_,no_;

//---- Calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=1+begin;  // starting number for calculation of all bars
      //---- Increase the position of the beginning of data by 'begin' bars as a result of calculation using data of another indicator
      if(begin>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);

      //---- The starting initialization
      Hi_=price[first-1];
      Lo_=Hi_;
      kr=0;
      no=0;
     }
   else first=prev_calculated-1; // Starting index for the calculation of new bars

//---- Restore values of the variables
   Hi=Hi_;
   Lo=Lo_;
   kr=kr_;
   no=no_;

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(price[bar]>Hi+dRange)
        {
         Hi=price[bar];
         Lo=Hi-dRange;
         kr++;
         no=0;
        }

      if(price[bar]<Lo-dRange)
        {
         Lo=price[bar];
         Hi=Lo+dRange;
         no++;
         kr=0;
        }

      //----
      int clr=1;
      if(kr>0) clr=2;
      if(no>0) clr=0;
      ColorIndBuffer[bar]=clr;
      IndBuffer[bar]=clr-1;

      //---- Save the values of the variables
      if(bar<rates_total-1)
        {
         Hi_=Hi;
         Lo_=Lo;
         kr_=kr;
         no_=no;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
