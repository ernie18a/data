//+------------------------------------------------------------------+ 
//|                                                  Ticker_FATL.mq5 | 
//|                             Copyright © 20107, mandorr@gmail.com | 
//|                                                mandorr@gmail.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2007, mandorr@gmail.com"
#property link "mandorr@gmail.com"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers is 2
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters   |
//+-----------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used as the indicator colors
#property indicator_color1  clrAqua,clrMediumOrchid
//--- displaying the indicator label
#property indicator_label1  "Ticker_FATL"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
//--- declaration of integer variables of data starting point
int  min_rates_total,FATLPeriod;
//--- declaration of dynamic arrays that 
//--- will be used as indicator buffers
double ExtABuffer[];
double ExtBBuffer[];
//--- declaration and initialization of an array for the coefficient of the digital filter
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
//--- initialization of variables of the start of data calculation
   FATLPeriod=ArraySize(FATLTable);
   min_rates_total=FATLPeriod;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtABuffer,INDICATOR_DATA);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtBBuffer,INDICATOR_DATA);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Ticker_FATL");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
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
   if(rates_total<FATLPeriod-1+begin) return(0);
//--- declarations of local variables 
   int first,bar,iii;
   double FATL;
//--- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=FATLPeriod-1+begin; // starting index for the calculation of all bars
      //--- increase the position of the data start by 'begin' bars as a result of the calculation using data of another indicator
      if(begin>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin+FATLPeriod);
     }
   else first=prev_calculated-1; // Starting index for the calculation of new bars
//--- main calculation loop of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      ExtABuffer[bar]=price[bar];
      //--- formula for calculation of the digital filter
      FATL=0.0;
      for(iii=0; iii<FATLPeriod; iii++) FATL+=FATLTable[iii]*price[bar-iii];
      //--- initialization of the cell of the indicator buffer by the obtained value of FATL
      ExtBBuffer[bar]=FATL;
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
