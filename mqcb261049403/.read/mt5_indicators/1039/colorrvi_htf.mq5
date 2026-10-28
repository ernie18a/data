//+------------------------------------------------------------------+
//|                                                 ColorRVI_HTF.mq5 | 
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "The RVI indicator with the option to select a fixed time frame"
//--- indicator version number
#property version   "1.00"
//--- drawing indicator in a separate window
#property indicator_separate_window
//--- number of indicator buffers is 4
#property indicator_buffers 4
//--- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level3  0.0
#property indicator_levelcolor Violet
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//--- drawing the indicator 1 as a cloud
#property indicator_type1   DRAW_FILLING
//---colors used as histogram colors are
#property indicator_color1 DarkGreen,Maroon
//--- displaying the indicator label
#property indicator_label1  "RVI HTF"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//--- drawing the indicator as labels
#property indicator_type2   DRAW_COLOR_ARROW
//--- the following colors are used as the indicator line color
#property indicator_color2 Gray,Lime,Magenta
//--- the indicator line is dashed
//#property indicator_style2  STYLE_SOLID
//--- the indicator line width is 5
#property indicator_width2  5
//--- displaying the indicator label
#property indicator_label2  "Signal line"
//+-----------------------------------+
//| declaration of constants          |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; // Chart period
input uint RVIPeriod=5;                    // RVI period
//+-----------------------------------+
//--- declaration of dynamic arrays that will further be used as indicator buffers
double UpRVI[],DnRVI[];
double RVISignal[],ColorRVISignal[];
//--- declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of integer variables of data starting point
int min_rates_total;
//--- declaration of integer variables for the indicator handles
int RVI_Handle;
//+------------------------------------------------------------------+
//| Getting timeframe as string                                      |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+   
//| RVI indicator initialization function                            | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- initialization of variables of data starting point
   min_rates_total=3;
   Init=true;
//--- checking the chart periods for correctness
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("The RVI indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- getting indicator handles  
   RVI_Handle=iRVI(NULL,TimeFrame,RVIPeriod);
   if(RVI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the RVI indicator handle");
      Init=false;
      return(INIT_FAILED);
     }
//--- setting dynamic array as indicator buffer
   SetIndexBuffer(0,UpRVI,INDICATOR_DATA);
//--- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(UpRVI,true);
//--- setting dynamic array as indicator buffer
   SetIndexBuffer(1,DnRVI,INDICATOR_DATA);
//--- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(DnRVI,true);
//--- setting dynamic array as indicator buffer
   SetIndexBuffer(2,RVISignal,INDICATOR_DATA);
//--- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(RVISignal,true);
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(3,ColorRVISignal,INDICATOR_COLOR_INDEX);
//--- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing elements in the buffer as time series
   ArraySetAsSeries(ColorRVISignal,true);
//--- creating a name for displaying in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"RVI("+GetStringTimeframe(TimeFrame)+", "+(string)RVIPeriod+")");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,3);
//--- end of initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| RVI iteration function                                           | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // history in bars at the current tick
                const int prev_calculated,// history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(RVI_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declaration of integer variables
   int limit,bar;
//--- declaration of variables with a floating point  
   double RVI[2],Signal[2];
   datetime RVITime[1];
   static uint LastCountBar;

//--- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for the calculation of new bars 
//--- indexing array elements as time series  
   ArraySetAsSeries(time,true);
//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for the calculation
      UpRVI[bar]=EMPTY_VALUE;
      DnRVI[bar]=EMPTY_VALUE;
      RVISignal[bar]=EMPTY_VALUE;
      ColorRVISignal[bar]=0;
      //--- copy the new data into the array
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,RVITime)<=0) return(RESET);
      if(time[bar]>=RVITime[0] && time[bar+1]<RVITime[0])
        {
         LastCountBar=bar;
         //--- copy new data into the arrays
         if(CopyBuffer(RVI_Handle,MAIN_LINE,time[bar],2,RVI)<=0) return(RESET);
         if(CopyBuffer(RVI_Handle,SIGNAL_LINE,time[bar],2,Signal)<=0) return(RESET);
         //--- Loading the obtained values in the indicator buffers
         RVISignal[bar]=Signal[1];
         UpRVI[bar]=0.0;
         DnRVI[bar]=0.0;
         //---
         if(RVI[1]>0.0) UpRVI[bar]=RVI[1];
         if(RVI[1]<0.0) UpRVI[bar]=RVI[1];
         //---
         if(RVI[1]>RVISignal[bar]) ColorRVISignal[bar]=1;
         if(RVI[1]<RVISignal[bar]) ColorRVISignal[bar]=2;
        }
      //---
      if(UpRVI[bar+1]!=EMPTY_VALUE && UpRVI[bar]==EMPTY_VALUE)
        {
         UpRVI[bar]=UpRVI[bar+1];
         DnRVI[bar]=DnRVI[bar+1];
         RVISignal[bar]=RVISignal[bar+1];
         ColorRVISignal[bar]=ColorRVISignal[bar+1];
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
