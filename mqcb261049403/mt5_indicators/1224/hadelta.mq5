//+---------------------------------------------------------------------+ 
//|                                                         HaDelta.mq5 | 
//|                                         Copyright © 2010, Dan Valcu | 
//|                                                   www.forex-tsd.com | 
//+---------------------------------------------------------------------+
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2010, Dan Valcu"
#property link "www.forex-tsd.com" 
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers is 4
#property indicator_buffers 4 
//---- only three plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the four-color histogram are as follows
#property indicator_color1 clrOrange,clrLimeGreen
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "HaDelta histogram"

//---- drawing the indicator as a line
#property indicator_type2 DRAW_LINE
//---- as the color of the line used
#property indicator_color2 clrDimGray
//---- the indicator line is a continuous curve
#property indicator_style2 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width2 2
//---- displaying label of the signal line
#property indicator_label2  "HaDelta"

//---- drawing the indicator as a line
#property indicator_type3 DRAW_LINE
//---- as the color of the line used
#property indicator_color3 clrPaleVioletRed
//---- the indicator line is a continuous curve
#property indicator_style3 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width3 2
//---- displaying label of the signal line
#property indicator_label3  "Signal Line"
//+-----------------------------------+
//|  Averaging classes description    |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA;
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
input bool BetterFormula=false; // BetterFormula
input Smooth_Method Signal_Method=MODE_SMA; //signal line smoothing method
input int Signal_XMA=3; //signal line period 
input int Signal_Phase=100; // signal line parameter,
                            //that changes within the range -100 ... +100,
//depends of the quality of the transitional prices;
//+-----------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double HaDeltaBuffer[],SignBuffer[],HistBuffer[],ColorHistBuffer[];
//+------------------------------------------------------------------+    
//| HaDelta indicator initialization function                        | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=2+XMA.GetStartBars(Signal_Method,Signal_XMA,Signal_Phase);

//---- set HaDeltaBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,HistBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorHistBuffer,INDICATOR_COLOR_INDEX);

//---- set HaDeltaBuffer dynamic array as an indicator buffer
   SetIndexBuffer(2,HaDeltaBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(3,SignBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- setting alerts for invalid values of external parameters
   XMA.XMALengthCheck("Signal_XMA",Signal_XMA);
//---- setting alerts for invalid values of external parameters
   XMA.XMAPhaseCheck("Signal_Phase",Signal_Phase,Signal_Method);

//---- initializations of variable for indicator short name
   string shortname;
   string Smooth=XMA.GetString_MA_Method(Signal_Method);
   StringConcatenate(shortname,"HaDelta( ",BetterFormula,", ",Signal_XMA,", ",Smooth," )");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| HaDelta iteration function                                       | 
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

//---- Declaration of integer variables
   int first,bar;
//---- declaration of variables with a floating point  
   double prOpen,prClose,prLow,prHigh,haClose,haOpen;
   static double haClose1,haOpen1;

//---- Initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      first=1; // starting number for the calculation of all bars in the first loop
      haOpen1=open[first];
      haClose1=close[first];
     }
   else // starting number for the calculation of new bars
     {
      first=prev_calculated-1;
     }

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      prOpen=open[bar];
      prClose=close[bar];
      prLow=low[bar];
      prHigh=high[bar];

      if(BetterFormula)
        {
         if(prHigh!=prLow)haClose=(prOpen+prClose)/2.0+(((prClose-prOpen)/(prHigh-prLow))*MathAbs((prClose-prOpen)/2.0));
         else   haClose=(prOpen+prClose)/2.0;
        }
      else haClose=(prOpen+prHigh+prLow+prClose)/4;

      haOpen=(haOpen1+haClose1)/2.0;
      HaDeltaBuffer[bar]=haClose-haOpen;
      HistBuffer[bar]=HaDeltaBuffer[bar];
      if(HaDeltaBuffer[bar]>0) ColorHistBuffer[bar]=1;
      if(HaDeltaBuffer[bar]<0) ColorHistBuffer[bar]=0;
      SignBuffer[bar]=XMA.XMASeries(1,prev_calculated,rates_total,Signal_Method,Signal_Phase,Signal_XMA,HaDeltaBuffer[bar],bar,false);

      if(bar<rates_total-1)
        {
         haOpen1=haOpen;
         haClose1=haClose;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
