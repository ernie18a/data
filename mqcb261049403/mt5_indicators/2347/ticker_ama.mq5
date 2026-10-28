//+------------------------------------------------------------------+ 
//|                                                   Ticker_AMA.mq5 | 
//|              MQL4 Code:  Copyright © 2004, GOODMAN & Mstera и AF |
//|              MQL5 Code:     Copyright © 2010,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//--- copyright
#property copyright "Copyright © 2004, by GOODMAN & Mstera и AF"
//--- a link to the website of the author
#property link      "http://forum.viac.ru/viewforum.php?f=7"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers is 2
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//--- the following colors are used as the indicator colors
#property indicator_color1  clrTeal,clrHotPink
//--- displaying the indicator label
#property indicator_label1  "Ticker_AMA"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint ama_period=9;       // AMA period
input uint fast_ma_period=2;   // Fast MA period
input uint slow_ma_period=30;  // Slow MA period
input double G=2.0;            // A power the smoothing constant is raised to 
input int AMAShift = 0;        // Horizontal shift of the indicator in bars
//+-----------------------------------+
//--- declaration of integer variables of data starting point
int  min_rates_total;
//--- declaration of dynamic arrays that will be used as indicator buffers
double ExtABuffer[];
double ExtBBuffer[];
//--- declaration of the variables with the floating point for constants
double dSC,slowSC,fastSC; 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(ama_period+1);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtABuffer,INDICATOR_DATA);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtBBuffer,INDICATOR_DATA);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- performing the horizontal shift of the indicator 1 by ama_shift
   PlotIndexSetInteger(0,PLOT_SHIFT,AMAShift);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Ticker_AMA( ",ama_period,", ",fast_ma_period,", ",slow_ma_period," )");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization of constants 
   slowSC = (2.0 / (slow_ma_period + 1));
   fastSC = (2.0 / (fast_ma_period + 1));
   dSC=fastSC-slowSC;
//--- initialization end
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[])    // a price array for indicator calculation
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total+begin) return(min_rates_total);
//--- declarations of local variables 
   int first,bar,iii;
   double noise,signal,price0,price1;
//--- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=min_rates_total-1+begin; // starting index for the calculation of all bars
      ExtBBuffer[first-1]=price[first-1];
      //--- increase the position of the data start by 'begin' bars as a result of the calculation using data of another indicator
      if(begin) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin+min_rates_total);
     }
   else first=prev_calculated-1; // Starting index for the calculation of new bars
//--- main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      ExtABuffer[bar]=price[bar];     
      //--- 
      noise=_Point/10000;
      for(iii=0; iii<int(ama_period); iii++)
        {
         price0=price[bar-iii];
         price1=price[bar-iii-1];
         noise+=MathAbs(price0 - price1);
        }
      price0 = price[bar];
      price1 = price[bar-ama_period];
      signal = MathAbs(price0-price1);
      ExtBBuffer[bar]=ExtBBuffer[bar-1]+MathPow(dSC*signal/noise+slowSC,G)*(price0-ExtBBuffer[bar-1]);
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
