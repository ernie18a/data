//+------------------------------------------------------------------+ 
//|                                                i-AMA-Optimum.mq5 | 
//|                                          Copyright © 2007, RickD |
//|                                                   www.e2e-fx.net |
//+------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2007, RickD"
//--- a link to the website of the author
#property link      "www.e2e-fx.net"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//--- MediumOrchid color is used as the color of the bullish line of the indicator
#property indicator_color1 clrMediumOrchid
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "i-AMA-Optimum"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint P=1000;              // Depth of smoothing                   
input double fast_ma_period=2;  // Fast MA period
input double slow_ma_period=10; // period of slow MA
input double G=2.0;             // A power the smoothing constant is raised to
input int Shift=0;              // Horizontal shift of the indicator in bars
input int PriceShift=0;         // Vertical shift of the indicator in points
//+-----------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double IndBuffer[];
//---
double dPriceShift,SlowSC,FastSC;
//--- declaration of integer variables of data starting point
int  min_rates_total;
//+------------------------------------------------------------------+    
//| i-AMA-Optimum indicator initialization function                  | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(P+1);
//--- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//--- calculating smoothing constants
   SlowSC = 2 / (1 + slow_ma_period);
   FastSC = 2 / (1 + fast_ma_period);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"i-AMA-Optimum(",P,", ",fast_ma_period,", ",slow_ma_period,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
  }
//+------------------------------------------------------------------+  
//| i-AMA-Optimum iteration function                                 | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[])    // a price array for indicator calculation
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total+begin) return(0);
//--- declaration of local variables
   int first,bar;
   double Noise,Signal,ER,SSC,AMA;
   static double Noise_;
//---
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      first=min_rates_total+begin; // starting index for the calculation of all bars
      //--- shift the beginning of indicator drawing
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
      Noise_=0.0;
      for(bar=1+begin; bar<first && !IsStopped(); bar++)
        {
         Noise_+=MathAbs(price[bar]-price[bar-1]);
         IndBuffer[bar]=price[bar];
        }
     }
   else first=prev_calculated-1; // Starting index for the calculation of new bars
//---
   Noise=Noise_;
//--- main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      Signal=MathAbs(price[bar]-price[bar-P]);
      Noise += MathAbs(price[bar]-price[bar-1]);
      Noise -= MathAbs(price[bar-P]-price[bar-1-P]);
      ER=1;
      if(Noise) ER=Signal/Noise;
      SSC=MathPow(SlowSC+ER*(FastSC-SlowSC),G);
      AMA=SSC*price[bar]+(1-SSC)*(IndBuffer[bar-1]-dPriceShift);
      IndBuffer[bar]=AMA+dPriceShift;
      if(bar==rates_total-2) Noise_=Noise;
     }
//---+     
   return(rates_total);
  }
//+------------------------------------------------------------------+
