//+------------------------------------------------------------------+
//|                                               TSI-Oscillator.mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//|                                                                  |
//|                                   Modified from TSI-Osc by Toshi |
//|                                  http://toshi52583.blogspot.com/ |
//+------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                              |
//| to the directory: terminal_data_folder\MQL5\Include              |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
//---- indicator version
#property version   "1.01"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- dark orchid color is used for the indicator line
#property indicator_color1 clrDarkOrchid
//---- the indicator line is a solid line
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- indicator label
#property indicator_label1  "TSI-Oscillator line"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- deep pink color is used for the indicator line
#property indicator_color2 clrDeepPink
//---- the indicator line is a solid line
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- indicator label
#property indicator_label2  "Trigger line"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 +50.0
#property indicator_level2   0.0
#property indicator_level3 -50.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  CMTM class description           |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- declaration of the CMTM class variables from the SmoothAlgorithms.mqh file
CXMA MTM1,MTM2,ABSMTM1,ABSMTM2;
//+----------------------------------------------+
//|  Declaration of enumerations      |
//+----------------------------------------------+
enum Applied_price_      //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
/*enum Smooth_Method - enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input Smooth_Method First_Method=MODE_SMA;  // Smoothing method 1
input int First_Length=12;                  // Smoothing depth 1
input int First_Phase=15;                   // Smoothing parameter 1
input Smooth_Method Second_Method=MODE_SMA; // Smoothing method 2
input int Second_Length=12;                 // Smoothing depth 2
input int Second_Phase=15;                  // Smoothing parameter 2
input Applied_price_ IPC=PRICE_CLOSE;       // Applied price
input int Shift=0;                          // Horizontal shift of the indicator in bars
input uint TriggerShift=1;                  // Bar shift for the trigger 
//+----------------------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,min_rates_total1,min_rates_total2;
//---- declaration of dynamic arrays which will be used as indicator buffers
double TSIBuffer[],TriggerBuffer[];
//+------------------------------------------------------------------+   
//| TSI indicator initialization function                            | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total1=MTM1.GetStartBars(First_Method,First_Length,First_Phase)+1;
   min_rates_total2=min_rates_total1+MTM1.GetStartBars(First_Method,First_Length,First_Phase);
   min_rates_total=int(min_rates_total1+MTM1.GetStartBars(Second_Method,Second_Length,Second_Phase)+TriggerShift);
//---- setting up alerts for invalid values of external variables
   MTM1.XMALengthCheck("First_Length",First_Length);
   MTM1.XMAPhaseCheck("First_Phase",First_Phase, First_Method);
   MTM1.XMALengthCheck("Second_Length",Second_Length);
   MTM1.XMAPhaseCheck("Second_Phase",Second_Phase,Second_Method);
//---- set TSIBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,TSIBuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- set TriggerBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,TriggerBuffer,INDICATOR_DATA);
//---- moving the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=MTM1.GetString_MA_Method(First_Method);
   string Smooth2=MTM1.GetString_MA_Method(Second_Method);
   StringConcatenate(shortname,"TSI-Oscillator(",Smooth1,", ",First_Length,", ",Smooth2,", ",Second_Length,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| TSI iteration function                                           | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const int begin,          // bars reliable counting beginning index
                const double &price[])    // price array for the indicator calculation
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total+begin) return(0);
//---- declaration of variables with a floating point  
   double dprice,absdprice,mtm1,absmtm1,mtm2,absmtm2;
//---- declaration of integer variables and getting already calculated bars
   int first,bar;
//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=1;                   // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars
//--- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      dprice=price[bar]-price[bar-1];
      absdprice=MathAbs(dprice);
      //---
      mtm1=MTM1.XMASeries(1,prev_calculated,rates_total,First_Method,First_Phase,First_Length,dprice,bar,false);
      absmtm1=ABSMTM1.XMASeries(1,prev_calculated,rates_total,First_Method,First_Phase,First_Length,absdprice,bar,false);
      //---
      mtm2=MTM2.XMASeries(min_rates_total1,prev_calculated,rates_total,Second_Method,Second_Phase,Second_Length,mtm1,bar,false);
      absmtm2=ABSMTM2.XMASeries(min_rates_total1,prev_calculated,rates_total,Second_Method,Second_Phase,Second_Length,absmtm1,bar,false);
      //---
      if(bar>min_rates_total2) TSIBuffer[bar]=100.0*mtm2/absmtm2;
      else TSIBuffer[bar]=EMPTY_VALUE;
      //---
      if(bar>min_rates_total) TriggerBuffer[bar]=TSIBuffer[bar-TriggerShift];
      else                    TriggerBuffer[bar]=EMPTY_VALUE;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
