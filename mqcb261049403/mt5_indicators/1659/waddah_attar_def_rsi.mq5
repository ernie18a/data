//+---------------------------------------------------------------------+
//|                                            Waddah_Attar_Def_RSI.mq5 |
//|                                 Copyright © 2007, Eng. Waddah Attar |
//|                                             waddahattar@hotmail.com |
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property  copyright "Copyright © 2007, Eng. Waddah Attar"
#property  link      "waddahattar@hotmail.com"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the four-color histogram are as follows
#property indicator_color1 clrDeepPink,clrMagenta,clrGray,clrDodgerBlue,clrOliveDrab
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "2pbIdealXOSMA"
//+-----------------------------------+
//|  declaration of constants         |
//+-----------------------------------+
#define RESET  0 // The constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint RSIPeriod1=14; //fast RSI period
input uint RSIPeriod2=28; //slow  RSI period
input Smooth_Method SmoothMethod=MODE_JJMA; // smoothing method
input uint Smooth_XMA=9; //smoothing period
input int Smooth_Phase=100;   //smoothing parameter,
                       //for JJMA, it varies within the range -100 ... +100 and influences on the quality of the transient period;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
//+-----------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_,min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//---- Declaration of integer variables for the indicator handles
int FRSI_Handle,SRSI_Handle;
//+------------------------------------------------------------------+    
//| Waddah_Attar_Def_RSI indicator initialization function           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_=int(MathMax(RSIPeriod1,RSIPeriod2));
   min_rates_total=min_rates_+XMA1.GetStartBars(SmoothMethod,Smooth_XMA,Smooth_Phase);
   
//---- getting handle of the iRSI indicator
   FRSI_Handle=iRSI(NULL,0,RSIPeriod1,PRICE_WEIGHTED);
   if(FRSI_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iRSI indicator");
   
//---- getting handle of the iRSI indicator
   SRSI_Handle=iRSI(NULL,0,RSIPeriod2,PRICE_WEIGHTED);
   if(SRSI_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iRSI indicator");

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Ind");
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);

//---- set dynamic array as as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorIndBuffer,true);

//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("Smooth_XMA",Smooth_XMA);
//---- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("Smooth_Phase",Smooth_Phase,SmoothMethod);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Waddah_Attar_Def_RSI");
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| Waddah_Attar_Def_RSI iteration function                          | 
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
//---- checking for the sufficiency of the number of bars for the calculation
   if(BarsCalculated(FRSI_Handle)<rates_total
      || BarsCalculated(SRSI_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar,maxbar;
   double drsi,FRSI[],SRSI[];
   
   maxbar=rates_total-1-min_rates_;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=maxbar;  // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(FRSI_Handle,0,0,to_copy,FRSI)<=0) return(RESET);
   if(CopyBuffer(SRSI_Handle,0,0,to_copy,SRSI)<=0) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(FRSI,true);
   ArraySetAsSeries(SRSI,true);

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      drsi=FRSI[bar]-SRSI[bar];
      IndBuffer[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,SmoothMethod,Smooth_Phase,Smooth_XMA,drsi,bar,true);
     }

   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//---- Main loop of the Ind indicator coloring
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorIndBuffer[bar]=2;

      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar+1]) ColorIndBuffer[bar]=4;
         if(IndBuffer[bar]<IndBuffer[bar+1]) ColorIndBuffer[bar]=3;
        }

      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar+1]) ColorIndBuffer[bar]=0;
         if(IndBuffer[bar]>IndBuffer[bar+1]) ColorIndBuffer[bar]=1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
