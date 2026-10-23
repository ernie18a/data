//+------------------------------------------------------------------+
//|                                            FX_Sniper_Ergodic_CCI |
//|                                      Copyright © 2004, Fx Sniper |
//|                                                                  |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2004, Fx Sniper"
//---- author of the indicator
#property link      ""
//---- indicator version number
#property version   "1.00"
#property description "Louw Coetzer aka FX Sniper"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  CCI indicator drawing parameters            |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- red color is used as the color of the bullish line of the indicator
#property indicator_color1  clrRed
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "CCI"
//+----------------------------------------------+
//|  ErgoCCI indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- DarkOrchid color is used for the indicator bearish line
#property indicator_color2  clrDarkOrchid
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying of the bearish label of the indicator
#property indicator_label2  "FX Sniper Ergo/CCI"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//|  Описание класса CMoving_Average             |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- declaration of the CEMA class variables from the SmoothAlgorithms.mqh file
CMoving_Average EMA1,EMA2,EMA3,EMA4,EMA5,EMA6;
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint pq=2;
input uint pr=14;
input uint ps=5;
input uint CCI_period=14;
input int  Shift=0;       // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double CCIBuffer[];
double ErgoCCIBuffer[];
//---- Declaration of integer variables for the indicator handles
int CCI_Handle;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(CCI_period+1+pr+pq+ps);

//---- getting handle of the CCI indicator
   CCI_Handle=iCCI(NULL,0,CCI_period,PRICE_TYPICAL);
   if(CCI_Handle==INVALID_HANDLE) Print(" Failed to get handle of the CCI indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,CCIBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(CCIBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,ErgoCCIBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ErgoCCIBuffer,true);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"FX Sniper Ergo/CCI");
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
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(CCI_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar,MaxBarA,MaxBarB,MaxBarC;
   double dc,absdc,e1dc,e1absdc,e2dc,e2absdc,e3dc,e3absdc;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=int(rates_total-CCI_period-1); // starting number for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars
   
   to_copy=limit+1;

   MaxBarA=int(rates_total-min_rates_total-CCI_period-1);
   MaxBarB=int(MaxBarA-pq);
   MaxBarC=int(MaxBarB-pr);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(close,true);

//--- copy newly appeared data in the array
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCIBuffer)<=0) return(RESET);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      dc=close[bar]- close[bar+1];
      absdc=MathAbs(dc);
      
      e1dc=EMA1.EMASeries(MaxBarA,prev_calculated,rates_total,pq,dc,bar,true);
      e1absdc=EMA2.EMASeries(MaxBarA,prev_calculated,rates_total,pq,absdc,bar,true);
      
      e2dc=EMA3.EMASeries(MaxBarB,prev_calculated,rates_total,pr,e1dc,bar,true);
      e2absdc=EMA4.EMASeries(MaxBarB,prev_calculated,rates_total,pr,e1absdc,bar,true);
      
      e3dc=EMA3.EMASeries(MaxBarC,prev_calculated,rates_total,ps,e2dc,bar,true);
      e3absdc=EMA4.EMASeries(MaxBarC,prev_calculated,rates_total,ps,e2absdc,bar,true);
      
      if(e3absdc) ErgoCCIBuffer[bar]=450*e3dc/e3absdc;
      else ErgoCCIBuffer[bar]=50;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
