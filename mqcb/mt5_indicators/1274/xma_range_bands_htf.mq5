/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                          XMA_Range_Bands_HTF.mq4 |
//|                               Copyright © 2012, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
#property description "XMA Range Bands HTF"
//--- indicator version number
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- number of indicator buffers 3
#property indicator_buffers 3 
//--- only 5 graphical plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//--- SlateBlue color is used for indicator line
#property indicator_color1 clrSlateBlue
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator line width is equal to 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "XMA Range Bands HTF"
//+--------------------------------------------+
//|  Levels indicator drawing parameters       |
//+--------------------------------------------+
//--- drawing the levels as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//--- selection of levels colors
#property indicator_color2  clrLimeGreen
#property indicator_color3  clrDeepPink
//--- levels are continuous curves
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//--- levels width is equal to 1
#property indicator_width2  1
#property indicator_width3  1
//--- display levels labels
#property indicator_label2  "Upper XMA Range Bands HTF"
#property indicator_label3  "Lower XMA Range Bands HTF"

//+-----------------------------------+
//|  Averaging classes description    |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//--- declaration of the CXMA classes variables from the SmoothAlgorithms.mqh file
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
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; // Chart period
input Smooth_Method MA_Method1=MODE_SMA;   // Smoothing method of moving average
input int Length1=100;                     // Smoothing depth of moving average                  
input int Phase1=15;                       // Moving average smoothing parameter,
//--- Phase1: for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
//--- Phase1: for VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Smooth_Method MA_Method2=MODE_JJMA;  // Candles size smoothing method
input int Length2=20;                      // Smoothing depth of candles size 
input int Phase2=100;                      // Candles size smoothing parameter,
//--- Phase2: for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
//--- Phase2: For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input double Deviation = 2.0;              // Channel expansion ratio
input Applied_price_ IPC=PRICE_CLOSE;      // Price constant
input int Shift=0;                         // Horizontal shift of the indicator in bars
input int PriceShift=0;                    // Vertical shift of the indicator in pointsх
input bool ReDraw=true;                    // Repeat of information show on the empty bars
//+-----------------------------------+
//--- declaration of dynamic arrays that will further be will be used as Bollinger Bands indicator buffers
double ExtLineBuffer0[],ExtLineBuffer1[],ExtLineBuffer2[];
//--- declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of the average vertical shift value variable
double dPriceShift;
//--- declaration of integer variables of data starting point
int min_rates_total;
//--- declaration of integer variables for the indicator handles
int Ind_Handle;
//+------------------------------------------------------------------+
//|  Getting string timeframe                                        |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+   
//| XMA_Range_Bands_HTF initialization function                      | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=3;
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("XMA_Range_Bands indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- getting the XMA_Range_Bands indicator handle 
   Ind_Handle=iCustom(Symbol(),TimeFrame,"XMA_Range_Bands",MA_Method1,Length1,Phase1,MA_Method2,Length2,Phase2,Deviation,IPC,0,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the XMA_Range_Bands indicator");
      Init=false;
      return(INIT_FAILED);
     }
//--- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer0,INDICATOR_DATA);
//--- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtLineBuffer0,true);
//--- setting dynamic arrays as indicator buffers
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
//--- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"XMA Range Bands"+"( "+GetStringTimeframe(TimeFrame)+" )");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- end of initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| XMA_Range_Bands_HTF iteration function                           | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declaration of integer variables
   int limit,bar;
//--- declaration of variables with a floating point  
   double XMA[2],Upper[2],Lower[2];
   datetime XMATime[1];
   static uint LastCountBar;
//--- calculations of the necessary amount of data to be copied and
//--- the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for the calculation of new bars 
//--- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
//--- main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for the calculation
      ExtLineBuffer0[bar]=EMPTY_VALUE;
      ExtLineBuffer1[bar]=EMPTY_VALUE;
      ExtLineBuffer2[bar]=EMPTY_VALUE;
      //--- copy newly appeared data in the array
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,XMATime)<=0) return(RESET);
      if(time[bar]>=XMATime[0] && time[bar+1]<XMATime[0])
        {
         LastCountBar=bar;
         //--- copy newly appeared data into the arrays
         if(CopyBuffer(Ind_Handle,0,time[bar],2,XMA)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,1,time[bar],2,Upper)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,2,time[bar],2,Lower)<=0) return(RESET);
         //--- loading the obtained values in the indicator buffers
         ExtLineBuffer0[bar]=XMA[1];
         ExtLineBuffer1[bar]=Upper[1];
         ExtLineBuffer2[bar]=Lower[1];
        }
      if(ReDraw)
        {
         if(ExtLineBuffer0[bar+1]!=EMPTY_VALUE && ExtLineBuffer0[bar]==EMPTY_VALUE)
           {
            ExtLineBuffer0[bar]=ExtLineBuffer0[bar+1];
            ExtLineBuffer1[bar]=ExtLineBuffer1[bar+1];
            ExtLineBuffer2[bar]=ExtLineBuffer2[bar+1];
           }
        }
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
