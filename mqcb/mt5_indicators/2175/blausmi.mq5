//+---------------------------------------------------------------------+
//|                                                         BlauSMI.mq5 |
//|                                              Copyright © 2006, Rosh |
//|                                         https://www.metaquotes.net/ |
//+---------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
//--- copyright
#property copyright "Copyright © 2006, Rosh"
//--- a link to the website of the author
#property link "https://www.metaquotes.net/" 
#property description "SMI Oscillator"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window
//--- four buffers are used for indicator calculation and drawing
#property indicator_buffers 4
//--- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used as the indicator colors
#property indicator_color1  clrLime,clrMagenta
//--- displaying the indicator label
#property indicator_label1  "Blau SMI Signal"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator as a four-color histogram
#property indicator_type2 DRAW_COLOR_HISTOGRAM
//--- colors of the five-color histogram are as follows
#property indicator_color2 clrDarkOrange,clrYellow,clrGray,clrDeepSkyBlue,clrBlue
//--- Indicator line is a solid one
#property indicator_style2 STYLE_SOLID
//--- indicator line width is 2
#property indicator_width2 2
//--- displaying the indicator label
#property indicator_label2  "Blau SMI"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 +40
#property indicator_level2   0
#property indicator_level3 -40
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| CXMA class description                       |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2,XMA3,XMA4,XMA5;
//+----------------------------------------------+
//| declaration of enumerations                  |
//+----------------------------------------------+
enum Applied_price_      // type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE_,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price
  };
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input Smooth_Method XMA_Method=MODE_EMA; // Averaging method
input uint XLength=2;                    // Period of stochastic momentum
input uint XLength1=8;                   // Depth of the first averaging
input uint XLength2=5;                   // Depth of the second averaging
input uint XLength3=5;                   // Depth of the third averaging
input int XPhase=15;                     // Smoothing parameter
//--- XPhase: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- XPhase: for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ IPC=PRICE_CLOSE;    // Price constant
//+----------------------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
double UpBuffer[],DnBuffer[];
int Count[];
double iHigh[],iLow[];
//--- declaration of integer variables for the start of data calculation
int min_rates_total,min_rates_1,min_rates_2,min_rates_3;
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Return the current value of the price series by reference
                          int Size)
  {
//---
   int numb,Max1,Max2;
   static int count=1;
//---
   Max2=Size;
   Max1=Max2-1;
//---
   count--;
   if(count<0) count=Max1;
//---
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of data calculation start
   min_rates_1=int(XLength);
   min_rates_2=min_rates_1+XMA1.GetStartBars(XMA_Method,XLength1,XPhase);
   min_rates_3=min_rates_2+XMA1.GetStartBars(XMA_Method,XLength2,XPhase);
   min_rates_total=min_rates_3+XMA1.GetStartBars(XMA_Method,XLength3,XPhase);
//---- memory distribution for variables' arrays  
   ArrayResize(Count,XLength);
   ArrayResize(iHigh,XLength);
   ArrayResize(iLow,XLength);
//--- 
   ArrayInitialize(Count,0);
   ArrayInitialize(iHigh,0.0);
   ArrayInitialize(iLow,0.0);
//---  
   ArraySetAsSeries(iHigh,true);
   ArraySetAsSeries(iLow,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(2,IndBuffer,INDICATOR_DATA);
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(3,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"BlauSMI");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declarations of local variables 
   double LL,HH,price,sm,xsm,xxsm,half,xhalf,xxhalf;
   int first,bar;
//--- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=0; // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting number for calculation of new bars
//--- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      iLow[Count[0]]=low[bar];
      iHigh[Count[0]]=high[bar];
      LL=iLow[ArrayMinimum(iLow,0,XLength)];
      HH=iHigh[ArrayMaximum(iHigh,0,XLength)];
      price=PriceSeries(IPC,bar,open,low,high,close);
      //---
      half=0.5*(HH-LL);
      xhalf=XMA1.XMASeries(min_rates_1,prev_calculated,rates_total,XMA_Method,XPhase,XLength1,half,bar,false);
      xxhalf=XMA2.XMASeries(min_rates_2,prev_calculated,rates_total,XMA_Method,XPhase,XLength2,xhalf,bar,false);
      //---       
      sm=price-0.5*(LL+HH);
      xsm=XMA3.XMASeries(min_rates_1,prev_calculated,rates_total,XMA_Method,XPhase,XLength1,sm,bar,false);
      xxsm=XMA4.XMASeries(min_rates_2,prev_calculated,rates_total,XMA_Method,XPhase,XLength2,xsm,bar,false);
      //---
      if(xxhalf) IndBuffer[bar]=100*xxsm/xxhalf;
      else IndBuffer[bar]=0.0;
      //---
      UpBuffer[bar]=IndBuffer[bar];
      DnBuffer[bar]=XMA5.XMASeries(min_rates_3,prev_calculated,rates_total,XMA_Method,XPhase,XLength3,IndBuffer[bar],bar,false);
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,XLength);
     }
   if(prev_calculated>rates_total || prev_calculated<=0) first++;
//--- Main loop of the Ind indicator coloring
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int clr=2;

      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=4;
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=3;
        }
      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=0;
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=1;
        }
      ColorIndBuffer[bar]=clr;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+

   