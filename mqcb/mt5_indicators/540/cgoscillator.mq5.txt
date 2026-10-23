//+------------------------------------------------------------------+
//| CG Oscillator                                                    |
//|                                                                  |
//| Algorithm taken from book                                        |
//|     "Cybernetics Analysis for Stock and Futures"                 |
//| by John F. Ehlers                                                |
//|                                              contact@mqlsoft.com |
//|                                          http://www.mqlsoft.com/ |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Coded by Witold Wozniak"
//---- author of the indicator
#property link      "www.mqlsoft.com"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  CG indicator drawing parameters             |
//+----------------------------------------------+
//---- drawing the indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- red color is used as the color of the indicator line
#property indicator_color1  Red
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "CG Oscillator"
//+----------------------------------------------+
//|  Trigger indicator drawing parameters        |
//+----------------------------------------------+
//---- dawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- use blue color for the Trigger line
#property indicator_color2  Blue
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator line label
#property indicator_label2  "Trigger"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int Length=10;  // Indicator period 
input int Shift=0;    // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double CGBuffer[];
double TriggerBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of global variables
double CGshift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=Length;

//---- initialization of variables  
   CGshift=(Length+1.0)/2.0;

//---- set CGBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,CGBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by 3
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,3);

//---- set TriggerBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,TriggerBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by 3
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,3);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"CG Oscillator(",Length,", ",Shift,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//----  determine the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declarations of local variables 
   int first,bar;
   double price,Num,Denom;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=min_rates_total;                             // starting index for calculation of all bars
     }
   else first=prev_calculated-1;                         // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      Num=0.0;
      Denom=0.0;

      for(int count=0; count<Length; count++)
        {
         price=(high[bar-count]+low[bar-count])/2.0;
         Num += (1.0 + count) * price;
         Denom+=price;
        }
      if(Denom!=0.0) CGBuffer[bar]=-Num/Denom+CGshift;
      else  CGBuffer[bar]=0.0;

      TriggerBuffer[bar]=CGBuffer[bar-1];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
