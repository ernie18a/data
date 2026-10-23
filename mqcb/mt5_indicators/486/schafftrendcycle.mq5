/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                             SchaffTrendCycle.mq5 |
//|                                  Copyright © 2011, EarnForex.com |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, EarnForex.com"
#property link      "http://www.earnforex.com"
#property description "Schaff Trend Cycle - Cyclical Stoch over Stoch over XMACD."
#property description "The code adapted by Nikolay Kositsin."
//---- indicator version
#property version   "2.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 1
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1

//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1 DRAW_LINE
//---- dark orchid color is used as the color of the line
#property indicator_color1 DarkOrchid
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "Schaff Trend Cycle"

//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 80.0
#property indicator_level2 50.0
#property indicator_level3 20.0
#property indicator_levelcolor Red
#property indicator_levelstyle STYLE_DASHDOTDOT

//---- setting lower and upper borders of the indicator window
#property indicator_minimum -10
#property indicator_maximum +110

//+-----------------------------------+
//|  Smoothings classes description   |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type od constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPLE_,//Simple Price (OC/2)
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
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input Smooth_Method MA_SMethod=MODE_EMA; //Histogram smoothing method
input int Fast_XMA = 23; //Fast moving average period
input int Slow_XMA = 50; //Slow moving average period
input int SmPhase= 100;  //Moving averages smoothing parameter
                         //for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ AppliedPrice=PRICE_CLOSE_;//Price constant
/*---- used for the indicator calculation (1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
//---- 5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Cycle=10; //Stochastic oscillator period
//+-----------------------------------+

//---- declaration of a dynamic array that further 
//---- will be used an indicator buffer
double STC_Buffer[];
int Count[];
bool st1_pass,st2_pass;
double XMACD[],ST[],Factor;
int StartBars,StartBars1,StartBars2;
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Return the current value of the price series by the link
                          int Rates_total,
                          int Bar)
  {
//----
   if(Bar>=Rates_total-1) return;

   int numb;
   static int count=1;
   count--;

   if(count<0) count=Cycle-1;

   for(int iii=0; iii<Cycle; iii++)
     {
      numb=iii+count;
      if(numb>Cycle-1) numb-=Cycle;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   StartBars1=MathMax(XMA1.GetStartBars(MA_SMethod,Fast_XMA,SmPhase),
                      XMA1.GetStartBars(MA_SMethod,Slow_XMA,SmPhase));
   StartBars2=StartBars1+Cycle;
   StartBars=StartBars2+Cycle;

//---- memory distribution for variables' arrays
   if(ArrayResize(ST,Cycle)<Cycle) Print("Failed to distribute the memory for ST array");
   if(ArrayResize(XMACD,Cycle)<Cycle) Print("Failed to distribute the memory for XMACD array");
   if(ArrayResize(Count,Cycle)<Cycle) Print("Failed to distribute the memory for Count array");

//---- initialization of constants  
   Factor=0.5;
   st1_pass = false;
   st2_pass = false;

//---- set MACDBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,STC_Buffer,INDICATOR_DATA);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(MA_SMethod);
   StringConcatenate(shortname,"Schaff Trend Cycle( ",
                     Smooth,", ",Fast_XMA,", ",Slow_XMA,", ",Cycle," )");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);

//---- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("Fast_XMA", Fast_XMA);
   XMA1.XMALengthCheck("Slow_XMA", Slow_XMA);
//---- setting up alerts for unacceptable values of external variables
   XMA1.XMAPhaseCheck("Phase",SmPhase,MA_SMethod);
//---- initialization end
  }
//+------------------------------------------------------------------+
//| Schaff Trend Cycle                                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- 
   if(rates_total<=StartBars) return(0);

//---- Declaration of variables with a floating point  
   double price_,fastxma,slowxma,LLV,HHV;
//---- Declaration of integer variables
   int first,bar,Bar0,Bar1;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- Main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      Bar0=Count[0];
      Bar1=Count[1];
      price_=PriceSeries(AppliedPrice,bar,open,low,high,close);;

      fastxma = XMA1.XMASeries(0, prev_calculated, rates_total, MA_SMethod, SmPhase, Fast_XMA, price_, bar, false);
      slowxma = XMA2.XMASeries(0, prev_calculated, rates_total, MA_SMethod, SmPhase, Slow_XMA, price_, bar, false);

      XMACD[Bar0]=fastxma-slowxma;

      if(bar<=StartBars2)
        {
         Recount_ArrayZeroPos(Count,rates_total,bar);
         continue;
        }

      LLV=XMACD[ArrayMinimum(XMACD)];
      HHV=XMACD[ArrayMaximum(XMACD)];

      //---- first stochastic calculation
      if(HHV-LLV!=0) ST[Bar0]=((XMACD[Bar0]-LLV)/(HHV-LLV))*100;
      else           ST[Bar0]=ST[Bar1];

      if(st1_pass) ST[Bar0]=Factor *(ST[Bar0]-ST[Bar1])+ST[Bar1];
      st1_pass=true;

      if(bar<=StartBars2)
        {
         Recount_ArrayZeroPos(Count,rates_total,bar);
         continue;
        }

      LLV=ST[ArrayMinimum(ST)];
      HHV=ST[ArrayMaximum(ST)];

      //---- second stochastic calculation
      if(HHV-LLV!=0) STC_Buffer[bar]=((ST[Bar0]-LLV)/(HHV-LLV))*100;
      else           STC_Buffer[bar]=STC_Buffer[bar-1];

      //---- second stochastic smoothing
      if(st2_pass) STC_Buffer[bar]=Factor *(STC_Buffer[bar]-STC_Buffer[bar-1])+STC_Buffer[bar-1];
      st2_pass=true;

      //---- recalculation of the elements position in ring buffers during a bar change
      Recount_ArrayZeroPos(Count,rates_total,bar);

     }

   return(rates_total);
  }
//+----------------------------------------------------
