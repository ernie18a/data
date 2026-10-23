//+------------------------------------------------------------------+
//|                                               Stochastic_HTF.mq5 |
//|                           Copyright © 2007, Christof Risch (Iya) | 
//|               http://www.forexfactory.com/showthread.php?t=30109 | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Christof Risch (iya)"
#property link "http://www.forexfactory.com/showthread.php?t=30109"
#property description "Stochastic indicator from any timeframe"
//--- Indicator version number
#property version   "1.00"
//--- The indicator is drawn in a separate window
#property indicator_separate_window 
//--- 2 buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//--- 2 graphical constructions are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Parameters for the bearish indicator        |
//+----------------------------------------------+
//--- Indicator 1 is drawn as a line
#property indicator_type1   DRAW_SECTION
//--- Red is used for the indicator color
#property indicator_color1  clrRed
//--- The width of the indicator 1 is 1
#property indicator_width1  1
//--- The indicator label
#property indicator_label1  "Main Stochastic"
//+----------------------------------------------+
//|  Parameters for the bullish indicator        |
//+----------------------------------------------+
//--- Indicator 2 is drawn as a line
#property indicator_type2   DRAW_SECTION
//--- Blue is used for the indicator color
#property indicator_color2  clrBlue
//--- The width of the indicator 2 is 1
#property indicator_width2  1
//--- The indicator label
#property indicator_label2 "Signal Stochastic"
//+----------------------------------------------+
//| Parameters of horizontal lines               |
//+----------------------------------------------+
#property indicator_level1  +75
#property indicator_level2  +50
#property indicator_level3  +25
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Limit on the height of the indicator window  |
//+----------------------------------------------+
#property indicator_minimum 0
#property indicator_maximum 100
//+----------------------------------------------+
//| Declaring constants                          |
//+----------------------------------------------+
#define RESET 0 // A constant for returning an indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H6; // Chart period for the iSAR indicator
input int KPeriod=5;
input int DPeriod=3;
input int Slowing=3;
input ENUM_MA_METHOD MA_Method=MODE_SMA;
input ENUM_STO_PRICE Price_field=STO_LOWHIGH;
//+----------------------------------------------+
//--- declaring dynamic arrays that will further be used as indicator buffers
double Line1Buffer[];
double Line2Buffer[];
//--- declaring a variable for storing the indicator initialization result
bool Init;
string Symbol_;
//--- declaring integer variables for the indicator handles
int STO_Handle;
//--- declaring integer variables of the start of data calculation
int  min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period())
     {
      Print("iSAR chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- initialization of variables    
   min_rates_total=3;
   Symbol_=Symbol();
//--- getting the handle of the iStochastic indicator
   STO_Handle=iStochastic(Symbol_,TimeFrame,KPeriod,DPeriod,Slowing,MA_Method,Price_field);
   if(STO_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the iStochastic indicator");
      Init=false;
      return(INIT_FAILED);
     }
//--- set UpSarBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,Line1Buffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Line1Buffer,true);
//--- setting the indicator values that will not be displayed on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- set DnSarBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,Line2Buffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Line2Buffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- setting the indicator display accuracy format
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- a name for the data window and a label for sub-windows
   string short_name="Stochastic HTF";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//--- сhecking the number of bars to be enough for the calculation
   if(BarsCalculated(STO_Handle)<min_rates_total || rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(STO_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declaration of local variables 
   double iSto[1],iSig[1];
   int limit,bar;
   datetime iTime[1];
   static uint LastCountBar;
//--- сalculations of the necessary number of copied data
//--- and limit starting index for the bars recalculation loop
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
      //--- яero out the contents of the indicator buffers for the calculation
      Line1Buffer[bar]=EMPTY_VALUE;
      Line2Buffer[bar]=EMPTY_VALUE;
      //--- сopy new data to the iTime array
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,iTime)<=0) return(RESET);
      //---
      if(time[bar]>=iTime[0] && time[bar+1]<iTime[0])
        {
         //--- Copy the new data into the array
         if(CopyBuffer(STO_Handle,MAIN_LINE,time[bar],1,iSto)<=0) return(RESET);
         if(CopyBuffer(STO_Handle,SIGNAL_LINE,time[bar],1,iSig)<=0) return(RESET);
         //---
         Line1Buffer[bar]=iSto[0];
         Line2Buffer[bar]=iSig[0];
         LastCountBar=bar;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
