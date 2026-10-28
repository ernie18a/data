/*
* Place the SmoothAlgorithms.mqh file
* to the terminal_data_folder\MQL5\Include
*/
//+------------------------------------------------------------------+
//|                                                         XCHO.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Chaikin Oscillator"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use orange color for the indicator line
#property indicator_color1 Orange
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "XCHO"

//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  enumerations declaration         |
//+-----------------------------------+
/*enum Smooth_Method is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int FastMA=3;                // Fast average period
input int SlowMA=10;               // Slow average period
input int Phase_=15;               // Smoothing parameter,
                                   // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// for VIDIA it is a CMO period, for AMA it is a slow average period
input Smooth_Method SmoothMethod=MODE_T3;          // Smoothing method
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Volume
input int Shift=0;                                 // Horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of a dynamic array that
//---- will be used as an indicator buffer
double XCHO[];

//---- Declaration of the integer variables for the start of data calculation
int StartBars;
//+------------------------------------------------------------------+
//| calculate AD                                                     |
//+------------------------------------------------------------------+
double GetAD(const double &high[],
             const double &low[],
             const double &close[],
             const long &tick_volume[],
             const long &volume[],
             uint bar)

  {
   long vol;
   double res=0;
//----
   if(VolumeType==VOLUME_TICK)
      vol=tick_volume[bar];
   else vol=volume[bar];

   if(high[bar]!=low[bar])
      res=(2*close[bar]-high[bar]-low[bar])/(high[bar]-low[bar])*vol;
//----
   return(res);
  }
//+------------------------------------------------------------------+   
//| XCHO indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBars=MathMax(XMA1.GetStartBars(SmoothMethod,FastMA,Phase_),
                     XMA2.GetStartBars(SmoothMethod,SlowMA,Phase_));

//---- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("FastMA", FastMA);
   XMA2.XMALengthCheck("SlowMA", SlowMA);
//---- setting up alerts for unacceptable values of external variables
   XMA1.XMAPhaseCheck("Phase_",Phase_,SmoothMethod);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,XCHO,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"XCHO");
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname,Smooth=XMA1.GetString_MA_Method(SmoothMethod);
   StringConcatenate(shortname,"Chaikin Oscillator(",string(SlowMA),",",string(FastMA),",",Smooth,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| XCHO iteration function                                          | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<StartBars) return(0);

//---- Declaration of variables with a floating point  
   double ad=0,slowma,fastma;
//---- Declaration of integer variables
   int first,bar;
//---- Declaration of static variables  
   static double ad_;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=0; // starting index for calculation of all bars
      ad_=GetAD(high,low,close,tick_volume,volume,0);
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- restore values of the variables
   ad=ad_;

//---- Main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==rates_total-1)
        {
         ad_=ad;
        }

      //---- getting the Accumulation Distribution indicator values
      ad+=GetAD(high,low,close,tick_volume,volume,bar);

      //---- two calls of the XMASeries function  
      fastma = XMA1.XMASeries(0, prev_calculated, rates_total, SmoothMethod, Phase_, FastMA, ad, bar, false);
      slowma = XMA2.XMASeries(0, prev_calculated, rates_total, SmoothMethod, Phase_, SlowMA, ad, bar, false);

      //---- indicator buffer initialization
      if(bar<StartBars)
        {
         XCHO[bar]=EMPTY_VALUE;
         continue;
        }
      XCHO[bar]=fastma-slowma;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
