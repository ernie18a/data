//+---------------------------------------------------------------------+
//|                                                            QQEA.mq5 | 
//|                                     Copyright © 2006, Roman Ignatov | 
//|                                      mailto:roman.ignatov@gmail.com | 
//+---------------------------------------------------------------------+ 
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2006, Roman Ignatov"
#property link "mailto:roman.ignatov@gmail.com"
#property description "Qualitative Quantitative Estimation"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- blue-violet color is used as the color of the indicator line
#property indicator_color1 clrBlueViolet
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Qualitative Quantitative Estimation"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 60.0
#property indicator_level2 50.0
#property indicator_level3 40.0
#property indicator_levelcolor clrMagenta
#property indicator_levelstyle STYLE_DASHDOTDOT

//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//|  CXMA class description                      |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2,XMA3;
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
input uint RSI_Period=14;
input uint SF=5;
input double DARFACTOR=4.236;
input Smooth_Method XMA_Method=MODE_SMA; //first smoothing averaging method                  
input int XPhase=15; //smoothing parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input int Shift=0; // horizontal shift of the indicator in bars
//+----------------------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double IndBuffer[];
//---- Declaration of integer variables for the indicator handles
int RSI_Handle;
//---- Declaration of integer variables of data starting point
int min_rates_total,min_rates_1,min_rates_2,min_rates_3,Wilders_Period;
//+------------------------------------------------------------------+   
//| QQEA indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   Wilders_Period=int(RSI_Period*2-1);
   min_rates_1=int(RSI_Period+1);
   min_rates_2=min_rates_1+XMA1.GetStartBars(XMA_Method,SF,XPhase);
   min_rates_3=min_rates_2+XMA1.GetStartBars(XMA_Method,Wilders_Period,XPhase);
   min_rates_total=min_rates_3+XMA1.GetStartBars(XMA_Method,Wilders_Period,XPhase);

//---- getting handle of the MA indicator
   RSI_Handle=iRSI(NULL,0,RSI_Period,PRICE_CLOSE);
   if(RSI_Handle==INVALID_HANDLE) Print(" Failed to get handle of the RSI indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of variable for indicator short name
   string shortname="Qualitative Quantitative Estimation";
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| QQEA iteration function                                          | 
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
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(RSI_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of variables with a floating point  
   double RSI[1],xrsi,momxrsi,xmomxrsi,xxmomxrsi,dar,tr,dv;
//---- Declaration of integer variables and getting the bars already calculated
   int first,bar;
   static double prev_xrsi;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=min_rates_1; // starting number for calculation of all bars
      prev_xrsi=50;
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(CopyBuffer(RSI_Handle,0,rates_total-1-bar,1,RSI)<=0) return(RESET);
      xrsi=XMA1.XMASeries(min_rates_1,prev_calculated,rates_total,XMA_Method,XPhase,SF,RSI[0],bar,false);
      momxrsi=MathAbs(prev_xrsi-xrsi);
      xmomxrsi=XMA2.XMASeries(min_rates_2,prev_calculated,rates_total,XMA_Method,XPhase,Wilders_Period,momxrsi,bar,false);
      xxmomxrsi=XMA3.XMASeries(min_rates_3,prev_calculated,rates_total,XMA_Method,XPhase,Wilders_Period,xmomxrsi,bar,false);
      dar=xxmomxrsi*DARFACTOR;
      //----       
      tr=IndBuffer[bar-1];
      dv=tr;

      if(xrsi<tr)
        {
         tr=xrsi+dar;
         if(prev_xrsi<dv && tr>dv) tr=dv;
        }
      else if(xrsi>tr)
        {
         tr=xrsi-dar;
         if(prev_xrsi>dv && tr<dv) tr=dv;
        }

      IndBuffer[bar]=tr;
      if(bar<rates_total-1) prev_xrsi=xrsi;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
