//+---------------------------------------------------------------------+ 
//|                                                      TrendRange.mq5 | 
//|                                  Copyright © 2012, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- indicator version number
#property version   "1.01"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the four-color histogram are as follows
#property indicator_color1 clrGray,clrBlue,clrMagenta
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "TrendRange"

//+-----------------------------------+
//|  Averaging classes description    |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA and CStdDeviation classes variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
CStdDeviation STD;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
/*enum Smooth_Method - enumeration is declared in SmoothAlgorithms.mqh
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
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  //volume
input Smooth_Method SmoothMethod=MODE_JJMA; //smoothing method
input int Smooth_XMA=9; //smoothing period
input int Smooth_Phase=100;   //moving averages smoothing parameter,
                       // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input double BandsDeviation = 1.0; //deviation
//+-----------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+    
//| TrendRange indicator initialization function                     | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=2+XMA1.GetStartBars(SmoothMethod,Smooth_XMA,Smooth_Phase);

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);

//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("Smooth_XMA",Smooth_XMA);
//---- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("Smooth_Phase",Smooth_Phase,SmoothMethod);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"TrendRange");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| TrendRange iteration function                                    | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- Checking if the number of bars is sufficient for the calculation
   if(rates_total<min_rates_total) return(0);

///---- declaration of local variables 
   int first,bar,clr;
   double res1,res2,Range,XRange,stdev,Max,Flat;
   long Vol;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=1;  // starting number for calculation of all bars
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(VolumeType==VOLUME_TICK) Vol=long(tick_volume[bar]);
      else Vol=long(volume[bar]);
      
      res1=(high[bar]-low[bar])/_Point;
      res2=MathAbs(close[bar-1]-open[bar]);   
      Range=double(MathMax(res1,res2)*Vol);
      
      IndBuffer[bar]=Range;
      XRange=XMA1.XMASeries(1,prev_calculated,rates_total,SmoothMethod,Smooth_Phase,Smooth_XMA,Range,bar,false);     
      stdev=STD.StdDevSeries(Smooth_XMA+1,prev_calculated,rates_total,Smooth_XMA,BandsDeviation,Range,XRange,bar,false);
      Max=XRange+stdev;
      Flat=Max/2; 

      if(Range>Max) clr=2;
      else if(Range>Flat) clr=1;
      else clr=0;
      
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
