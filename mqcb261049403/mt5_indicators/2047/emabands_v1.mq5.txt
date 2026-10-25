//+------------------------------------------------------------------+
//|                                                  EMABands_v1.mq5 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
//--- indicator version
#property version   "1.00"
#property description "MACD_Cloud"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- number of indicator buffers 4
#property indicator_buffers 4 
//--- two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0 // a constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//--- the following colors are used as the indicator colors
#property indicator_color1  clrPaleGreen
//--- displaying the indicator label
#property indicator_label1  "Upper Cloud"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type2   DRAW_FILLING
//--- the following colors are used as the indicator colors
#property indicator_color2  clrPink
//--- displaying the indicator label
#property indicator_label2  "Lower Cloud"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int   MAPeriod=13;
input  ENUM_MA_METHOD   MAType=MODE_EMA;
input uint Delta=150;
//+-----------------------------------+
//--- declaration of integer variables for the start of data calculation
int  min_rates_total;
//--- declaration of dynamic arrays that will be used as indicator buffers
double ExtHHBuffer[];
double ExtHLBuffer[];
double ExtLHBuffer[];
double ExtLLBuffer[];
//---
double dDelta;
//--- declaration of integer variables for the indicators handles
int MAh_Handle,MAl_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(MAPeriod);
   dDelta=Delta*_Point;
//--- getting the handle of the iMA h indicator
   MAh_Handle=iMA(NULL,0,MAPeriod,0,MAType,PRICE_HIGH);
   if(MAh_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of iMA h");
      return(INIT_FAILED);
     }
//--- getting the handle of the iMA indicator l
   MAl_Handle=iMA(NULL,0,MAPeriod,0,MAType,PRICE_LOW);
   if(MAl_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of iMA l");
      return(INIT_FAILED);
     }
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtHHBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtHHBuffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtHLBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtHLBuffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtLHBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtLHBuffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(3,ExtLLBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtLLBuffer,true);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"EMABands_v1");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(MAh_Handle)<rates_total
    || BarsCalculated(MAl_Handle)<rates_total
    || rates_total<min_rates_total) return(RESET);
//--- declarations of local variables 
   int to_copy,limit;
//--- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
        limit=rates_total-min_rates_total-1; // Starting index for calculation of all bars
   else limit=rates_total-prev_calculated;  // starting index for calculation of new bars only
   to_copy=limit+1;
//--- copy newly appeared data in the arrays
   if(CopyBuffer(MAh_Handle,MAIN_LINE,0,to_copy,ExtHLBuffer)<=0) return(RESET);
   if(CopyBuffer(MAl_Handle,MAIN_LINE,0,to_copy,ExtLHBuffer)<=0) return(RESET);  
//--- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtHHBuffer[bar]=ExtHLBuffer[bar]+dDelta;
      ExtLLBuffer[bar]=ExtLHBuffer[bar]-dDelta;
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
