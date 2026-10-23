//+---------------------------------------------------------------------+
//|                                                      B&WImp-T01.mq5 | 
//|                             Copyright © 2006, HomeSoft-Tartan Corp. | 
//|                        spiky@transkeino.ru - http:\\www.fxexpert.ru | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2006, HomeSoft-Tartan Corp."
#property link      "spiky@transkeino.ru - http:\\www.fxexpert.ru"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 1 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//--- DodgerBlue color is used for the indicator line color
#property indicator_color1 clrDodgerBlue
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "BxWImp-T01"
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint Period1=96;                   // Period 1
input uint Period2=3;                    // Period 2
input Smooth_Method XMA_Method=MODE_T3;  // Smoothing method
input uint XLength=8;                    // Smoothing depth                    
input int XPhase=70;                     // Smoothing parameter
//--- XPhase: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- XPhase: for VIDIA it is a CMO period, for AMA it is a slow average period
input int Shift=0;                       // Horizontal shift of the indicator in bars
//+-----------------------------------+
//--- declaration of a dynamic array that further
//---- will be used as an indicator buffer
double IndBuffer[];
double Point10;
//--- declaration of integer variables of data starting point
int min_rates_1,min_rates_total;
//--- declaration of global variables
int Count[];
double impr[],impb[];
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Return the current value of the price series by reference
                          int Size)
  {
//---
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//---
  }
//+------------------------------------------------------------------+
//| Getting the difference of the price time series values           |
//+------------------------------------------------------------------+   
double Get_dPrice(const double  &Price1[],const double  &Price2[],int index)
  {
//---
   return(Price1[index]-Price2[index]);
  }
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_1=int(Period1+Period2);
   min_rates_total=min_rates_1+XMA1.GetStartBars(XMA_Method,XLength,XPhase);
   Point10=_Point/10;
//--- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("XLength",XLength);
   XMA1.XMAPhaseCheck("XPhase",XPhase,XMA_Method);
//---- memory distribution for variables' arrays  
   ArrayResize(Count,Period2);
   ArrayResize(impr,Period2);
   ArrayResize(impb,Period2);
//--- initializing  
   ArrayInitialize(Count,0);
   ArrayInitialize(impr,0.0);
   ArrayInitialize(impb,0.0);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"BxWImp-T01(",XLength,", ",Smooth1,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- initialization end
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
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
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declaration of variables with a floating point  
   double imppr,imppb,sipr,sipb,sum;
//--- declaration of integer variables and getting already calculated bars
   int first,bar;
//--- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=int(Period1); // starting index for calculation of all bars
   else first=prev_calculated-1; // Starting index for the calculation of new bars
//--- main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      imppr=0;
      imppb=0;
      for(int kkk=0; kkk<int(Period1); kkk++)
        {
         double diff=Get_dPrice(close,open,bar-kkk);
         if(diff>0) imppr+=diff;
         if(diff<0) imppb+=diff;
        }
      imppr=MathRound(imppr/_Point);
      imppb=MathRound(imppb/_Point);     
      if(!imppr) imppr=Point10;
      if(!imppb) imppb=Point10;
      impr[Count[0]]=imppr;
      impb[Count[0]]=imppb;     
      sipr=0;
      sipb=0;
      for(int kkk=0; kkk<int(Period2); kkk++)
        {
         sipr+=impr[kkk];
         sipb+=impb[kkk];
        }
      sipr=MathRound((sipr/Period2));
      sipb=MathRound((sipb/Period2));
      sum=sipr+sipb;
      IndBuffer[bar]=XMA1.XMASeries(min_rates_1,prev_calculated,rates_total,XMA_Method,XPhase,XLength,sum,bar,false);     
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,Period2);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
