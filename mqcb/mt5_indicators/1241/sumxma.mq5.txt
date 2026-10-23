//+------------------------------------------------------------------+
//|                                                       SumXMA.mq5 |
//|                                        Copyright © 2008, jax1000 |
//|                                                  jax1000@list.ru |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2008, jax1000"
//---- author of the indicator
#property link      "jax1000@list.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 1
//---- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Cycle indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- SlateBlue color is used as the color of the bullish line of the indicator
#property indicator_color1  clrSlateBlue
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 3
#property indicator_width1  3
//---- displaying of the bullish label of the indicator
#property indicator_label1  "SumXMA"
//+----------------------------------------------+
//|  CXMA class description                      |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA[];
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
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
//+----------------------------------------------+
//|  INDICATOR INPUT PARAMETERS                  |
//+----------------------------------------------+
input Smooth_Method XMA_Method=MODE_SMA; //smoothing method
input uint StartLength=20; //initial smoothing period
input uint EndLength=100; //final smoothing period                  
input int XPhase=15; //smoothing parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input int Shift=0; // horizontal shift of the indicator in bars
input int PriceShift=0; // vertical shift of the indicator in pointsх
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double SumXMABuffer[];

bool Init;
//---- Declaration of integer variables of data starting point
int min_rates_total,xSize;
//---- Declaration of the average vertical shift value variable
double dPriceShift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- setting alerts for invalid values of external parameters
   if(StartLength>EndLength)
     {
      Init=false;
      Print("The initial period of the indicator can not be greater than the final period!");
      return;
     }

//---- memory allocation for arrays of variables
   xSize=int(EndLength-StartLength+1);

   if(ArrayResize(XMA,xSize)<xSize)
     {
      Init=false;
      Print("Failed to distribute the memory for XMA[] object array!");
      return;
     }
   else Init=true;

//---- Initialization of variables of the start of data calculation
   min_rates_total=XMA[0].GetStartBars(XMA_Method,EndLength,XPhase);
//---- setting alerts for invalid values of external parameters
   XMA[0].XMAPhaseCheck("XPhase",XPhase,XMA_Method);
//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SumXMABuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(SumXMABuffer,true);

//---- initializations of variable for indicator short name
   string Smooth=XMA[0].GetString_MA_Method(XMA_Method);
   string shortname;
   StringConcatenate(shortname,"SumXMA(",Smooth,", ",StartLength,", ",EndLength,", ",XPhase,", ",Shift,", ",PriceShift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[]     // price array for calculation of the indicator
                )
  {
//---- checking the number of bars to be enough for calculation
   if(!Init || rates_total+begin<min_rates_total) return(0);

//---- declaration of local variables 
   int MaxBar,limit,bar;
   double Sum;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1-begin; // starting index for calculation of all bars

      //---- shifting the starting point for drawing indicator by min_rates_total+begin
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

   MaxBar=rates_total-min_rates_total-1-begin;

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(price,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Sum=0.0;
      for(int number=0; number<xSize; number++)
         Sum+=XMA[number].XMASeries(MaxBar,prev_calculated,rates_total,XMA_Method,XPhase,StartLength+number,price[bar],bar,true);

      SumXMABuffer[bar]=Sum/(EndLength-StartLength+1)+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
