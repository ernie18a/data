//+------------------------------------------------------------------+
//|                                                  XRSX_BB_HTF.mq5 | 
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
/* For the indicator to work, place the SmoothAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 * XRSX_BB.mq5 in the directory: MetaTrader\\MQL5\Indicators      
 */
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Relative Strength Index"
//--- indicator version number
#property version   "1.00"
//--- drawing indicator in a separate window
#property indicator_separate_window
//--- number of indicator buffers
#property indicator_buffers 9
//--- Only 7 graphical plots are used
#property indicator_plots   7
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//--- drawing the indicator as a color histogram
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//--- the following colors are used in the histogram
#property indicator_color1 Gray,Lime,Blue,Red,Magenta
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator line width is equal to 5
#property indicator_width1  5
//--- displaying the indicator label
#property indicator_label1  "XRSX HTF"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//--- drawing indicator as a three-colored line
#property indicator_type2   DRAW_COLOR_LINE
//--- the following colors are used for the indicator line
#property indicator_color2 Gray,Teal,DeepPink
//--- the indicator line is a stroke
#property indicator_style2  STYLE_SOLID
//--- indicator line width is equal to 5
#property indicator_width2  5
//--- displaying the indicator label
#property indicator_label2  "Signal line"
//+--------------------------------------------+
//|  BB levels indicator drawing parameters    |
//+--------------------------------------------+
//--- drawing Bollinger Bands as lines
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
//--- selection of Bollinger Bands colors
#property indicator_color3  Blue
#property indicator_color4  Red
#property indicator_color5  Gray
#property indicator_color6  Red
#property indicator_color7  Blue
//--- Bollinger Bands are dott-dash curves
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_DASHDOTDOT
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
//--- Bollinger Bands width is equal to 1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
//--- display the labels of Bollinger Bands levels
#property indicator_label3  "+2Sigma"
#property indicator_label4  "+Sigma"
#property indicator_label5  "Middle"
#property indicator_label6  "-Sigma"
#property indicator_label7  "-2Sigma"
//+-----------------------------------+
//|  Averagings classes description   |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
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
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
/*enum Smooth_Method is declared in the SmoothAlgorithms.mqh file
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
//|  Input parameters of the indicator|
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;    // Chart period
input Smooth_Method DSmoothMethod=MODE_JurX;  // Price smoothing method
input int DPeriod=15;                         // Moving average period
input int DPhase=100;                         // Moving average smoothing parameter
//--- DPhase: for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
//--- DPhase: for VIDIA it is a CMO period, for AMA it is a slow average period
input Smooth_Method SSmoothMethod=MODE_JJMA;  // Signal line smoothing method
input int SPeriod=7;                          // Signal line period
input int SPhase=100;                         // Signal line parameter
//--- SPhase: for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
//--- SPhase: for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ IPC=PRICE_CLOSE;         // Price constant
input int Shift=0;                            // Horizontal shift of the indicator in bars
input int BBPeriod=100;                       // Bollinger bands period
input double BBDeviation1 = 1.0;              // Small deviation
input double BBDeviation2 = 1.6;              // Big deviation
//+-----------------------------------+
//--- declaration of dynamic arrays that further will be used as indicator buffers
double XRSX[],XXRSX[];
double ColorXRSX[],ColorXXRSX[];
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[],ExtLineBuffer5[];
//--- declaration of the Bollinger Bands proportion variable
double quotient;
//--- declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int XRSX_Handle;
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
   CXMA XMA;
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
//| XRSX indicator initialization function                           | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=3;
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("XRSX_BB indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- getting handle of the XRSX_BB indicator
   XRSX_Handle=iCustom(Symbol(),TimeFrame,"XRSX_BB",
                       DSmoothMethod,DPeriod,DPhase,SSmoothMethod,SPeriod,SPhase,IPC,0,1,BBPeriod,BBDeviation1,BBDeviation2);
   if(XRSX_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the XRSX_BB indicator");
      Init=false;
      return(INIT_FAILED);
     }
//--- initialization of the Bollinger Bands proportion variable
   quotient=BBDeviation2/BBDeviation1;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,XRSX,INDICATOR_DATA);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(XRSX,true);
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorXRSX,INDICATOR_COLOR_INDEX);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorXRSX,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(2,XXRSX,INDICATOR_DATA);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(XXRSX,true);
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(3,ColorXXRSX,INDICATOR_COLOR_INDEX);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorXXRSX,true);
//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(4,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(8,ExtLineBuffer5,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(ExtLineBuffer3,true);
   ArraySetAsSeries(ExtLineBuffer4,true);
   ArraySetAsSeries(ExtLineBuffer5,true);
//--- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(8,PLOT_DRAW_BEGIN,min_rates_total);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- initializations of variable for indicator short name
   string shortname,Smooth;
   Smooth=XMA.GetString_MA_Method(DSmoothMethod);
   StringConcatenate(shortname,"Relative Strength Index(",GetStringTimeframe(TimeFrame),", ",string(DPeriod),",",Smooth,")");
//--- creating name for displaying in a separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- end of initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| XRSX iteration function                                          | 
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
   if(BarsCalculated(XRSX_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declaration of integer variables
   int limit,bar;
//--- declaration of variables with a floating point  
   double Xrsx[2],Xxrsx[2],BB2[1],BB3[1];
   datetime XRSXTime[1];
   static uint LastCountBar;
//--- calculations of the necessary amount of data to be copied and
//--- the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for calculation of new bars 
//--- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
//--- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for calculation
      XRSX[bar]=EMPTY_VALUE;
      XXRSX[bar]=EMPTY_VALUE;
      ColorXRSX[bar]=0;
      ColorXXRSX[bar]=0;
      ExtLineBuffer1[bar]=EMPTY_VALUE;
      ExtLineBuffer2[bar]=EMPTY_VALUE;
      ExtLineBuffer3[bar]=EMPTY_VALUE;
      ExtLineBuffer4[bar]=EMPTY_VALUE;
      ExtLineBuffer5[bar]=EMPTY_VALUE;
      //--- copy newly appeared data in the array
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,XRSXTime)<=0) return(RESET);
      if(time[bar]>=XRSXTime[0] && time[bar+1]<XRSXTime[0])
        {
         LastCountBar=bar;
         //--- copy newly appeared data into the arrays
         if(CopyBuffer(XRSX_Handle,0,time[bar],2,Xrsx)<=0) return(RESET);
         if(CopyBuffer(XRSX_Handle,2,time[bar],2,Xxrsx)<=0) return(RESET);
         if(CopyBuffer(XRSX_Handle,5,time[bar],1,BB2)<=0) return(RESET);
         if(CopyBuffer(XRSX_Handle,6,time[bar],1,BB3)<=0) return(RESET);
         //--- loading the obtained values in the indicator buffers
         XRSX[bar]=Xrsx[1];
         XXRSX[bar]=Xxrsx[1];
         //---
         ExtLineBuffer2[bar]=BB2[0];
         ExtLineBuffer3[bar]=BB3[0];
         //---
         double dBB=BB2[0]-BB3[0];
         //---
         ExtLineBuffer1[bar]=BB3[0]+dBB*quotient;
         ExtLineBuffer4[bar]=BB3[0]-dBB;
         ExtLineBuffer5[bar]=BB3[0]-dBB*quotient;
         //---
         if(XRSX[bar]>0)
           {
            if(Xrsx[1]>Xrsx[0]) ColorXRSX[bar]=1;
            if(Xrsx[1]<Xrsx[0]) ColorXRSX[bar]=2;
           }
         if(XRSX[bar]<0)
           {
            if(Xrsx[1]<Xrsx[0]) ColorXRSX[bar]=3;
            if(Xrsx[1]>Xrsx[0]) ColorXRSX[bar]=4;
           }
         if(XRSX[bar]>XXRSX[bar]) ColorXXRSX[bar]=1;
         if(XRSX[bar]<XXRSX[bar]) ColorXXRSX[bar]=2;
        }
//---
      if(XRSX[bar+1]!=EMPTY_VALUE && XRSX[bar]==EMPTY_VALUE)
        {
         XRSX[bar]=XRSX[bar+1];
         ColorXRSX[bar]=ColorXRSX[bar+1];
         XXRSX[bar]=XXRSX[bar+1];
         ColorXXRSX[bar]=ColorXXRSX[bar+1];
         ExtLineBuffer1[bar]=ExtLineBuffer1[bar+1];
         ExtLineBuffer2[bar]=ExtLineBuffer2[bar+1];
         ExtLineBuffer3[bar]=ExtLineBuffer3[bar+1];
         ExtLineBuffer4[bar]=ExtLineBuffer4[bar+1];
         ExtLineBuffer5[bar]=ExtLineBuffer5[bar+1];
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
