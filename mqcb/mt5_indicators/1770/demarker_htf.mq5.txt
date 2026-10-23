//+------------------------------------------------------------------+ 
//|                                                 DeMarker_HTF.mq5 | 
//|                                          Copyright © 2006, ycomp | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2006, ycomp"
#property link ""
//--- Indicator version number
#property version   "1.00"
#property description "DeMarker"
//--- drawing indicator in a separate window
#property indicator_separate_window
//--- number of indicator buffers is 1
#property indicator_buffers 1 
//--- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 0.7
#property indicator_level2 0.5
#property indicator_level3 0.3
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Parameters of displaying window borders      |
//+----------------------------------------------+
#property indicator_maximum   +1.0
#property indicator_minimum    0.0
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0                    // The constant for returning the indicator recalculation command to the terminal
#define INDICATOR_NAME "iDeMarker" // The constant for the indicator name
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//--- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_SECTION
//--- the following colors are used as the indicator colors
#property indicator_color1  clrDeepPink
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  INDICATOR_NAME
//+-------------------------------------+
//| Indicator input parameters          |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; // Chart period
input uint DeMarker_Period=14;             // Averaging period
input int Shift=0;                         // Horizontal shift of the indicator in bars
//+-------------------------------------+
//--- declaration of dynamic arrays that further will be used as indicator buffers
double IndBuffer[];
//--- declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of strings
string Symbol_;
//--- declaration of integer variables for indicators handles
int Ind_Handle;
//--- declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//|  Getting the string timeframe                                    |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
   Init=true;
//--- Checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Chart period for iDeMarker cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- getting handle of the iDeMarker indicator
   Ind_Handle=iDeMarker(NULL,TimeFrame,DeMarker_Period);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of iDeMarker");
      return(INIT_FAILED);
     }
//--- Initialization of variables 
   min_rates_total=int((PeriodSeconds(TimeFrame)/PeriodSeconds(PERIOD_CURRENT))*(DeMarker_Period+3));
   Symbol_=Symbol();
   string Word=INDICATOR_NAME+"("+Symbol_+","+GetStringTimeframe(TimeFrame)+","+string(DeMarker_Period)+")";

//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,Word);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
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
   if(BarsCalculated(Ind_Handle)<2 || rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declaration of local variables 
   double iOsc[1];
   int limit,bar;
   datetime iTime[1];
   static uint LastCountBar;
//--- calculations of the necessary amount of data to be copied and
//--- the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-2; // starting index for the calculation of all bars
      LastCountBar=limit;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for the calculation of new bars 
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
//--- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for the calculation
      IndBuffer[bar+1]=EMPTY_VALUE;
      //--- copy new data to the iTime array
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,iTime)<=0) return(RESET);
      if(time[bar]>=iTime[0] && time[bar+1]<iTime[0])
        {
         //--- copy the new data into the array
         if(CopyBuffer(Ind_Handle,0,time[bar+1],1,iOsc)<=0) return(RESET);
         LastCountBar=bar;
         IndBuffer[bar+1]=iOsc[0];
        }
     }
//--- copy the new data into the array
   if(CopyBuffer(Ind_Handle,0,time[0],1,iOsc)<=0) return(RESET);
   IndBuffer[0]=iOsc[0];
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
