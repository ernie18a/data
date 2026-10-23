//+------------------------------------------------------------------+
//|                                                   LeManTrend.mq5 |
//|                                         Copyright © 2009, LeMan. | 
//|                                                 b-market@mail.ru | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2009, LeMan."
//---- link to the website of the author
#property link "b-market@mail.ru"
//---- indicator version
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- 4 buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//---- 3 plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Filling drawing parameters       |
//+-----------------------------------+
//---- drawing indicator as a filling between two lines
#property indicator_type1   DRAW_FILLING
//---- blue and red colors are used as the indicator filling colors
#property indicator_color1  Teal, Magenta
//---- displaying the indicator label
#property indicator_label1 "LeManTrend"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- BlueViolet color is used as the color of the bullish indicator line
#property indicator_color2  BlueViolet
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator line label
#property indicator_label2  "LeManTrend Bulls"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 3 as a line
#property indicator_type3   DRAW_LINE
//---- BlueViolet color is used for the indicator bearish line
#property indicator_color3  BlueViolet
//---- the indicator 3 line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- indicator 3 line width is equal to 1
#property indicator_width3  1
//---- displaying the indicator line label
#property indicator_label3  "LeManTrend Bears"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int Min       = 13;
input int Midle     = 21;
input int Max       = 34;
input int PeriodEMA = 3; // Indicator period 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double BullsBuffer[];
double BearsBuffer[];
double BullsBuffer_[];
double BearsBuffer_[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,start;
//+------------------------------------------------------------------+
//| CMoving_Average class description                                | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   start=MathMax(MathMax(Min,Midle),Max);
   min_rates_total=start+PeriodEMA; 
  
//---- set BullsBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,BullsBuffer,INDICATOR_DATA);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(BullsBuffer,true);

//---- set BearsBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,BearsBuffer,INDICATOR_DATA);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(BearsBuffer,true);
   
//---- set BullsBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,BullsBuffer_,INDICATOR_DATA);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(BullsBuffer_,true);

//---- set BearsBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(3,BearsBuffer_,INDICATOR_DATA);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(BearsBuffer_,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"LeManTrend(",Min,", ",Midle,", ",Max,", ",PeriodEMA,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
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
   int limit,bar,maxbar;
   double High,Low,HH,LL,Bulls,Bears;

//---- calculation of maxbar starting index for the MASeries() function
   maxbar=rates_total-1-start;
   
//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
        limit=maxbar; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);   

//---- declaration of the CMoving_Average class variables from the SmoothAlgorithms.mqh file
   static CMoving_Average BULLS,BEARS;

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      High=0.0;
      High+=high[ArrayMaximum(high,bar+1,Min)];
      High+=high[ArrayMaximum(high,bar+1,Midle)];
      High+=high[ArrayMaximum(high,bar+1,Max)];     
      HH=3*high[bar]-High;
      
      Low=0.0;
      Low+=low[ArrayMinimum(low,bar+1,Min)];
      Low+=low[ArrayMinimum(low,bar+1,Midle)];
      Low+=low[ArrayMinimum(low,bar+1,Max)];
      LL=Low-3*low[bar];
      
      Bulls=BULLS.MASeries(maxbar,prev_calculated,rates_total,PeriodEMA,MODE_EMA,HH,bar,true);
      Bears=BEARS.MASeries(maxbar,prev_calculated,rates_total,PeriodEMA,MODE_EMA,LL,bar,true);
      
      BullsBuffer[bar]=Bulls;
      BearsBuffer[bar]=Bears;
      
      BullsBuffer_[bar]=Bulls;
      BearsBuffer_[bar]=Bears;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
