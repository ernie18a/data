//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh 
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+ 
//|                                                 ColorRSI_HTF.mq5 | 
//|                               Copyright © 2011, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//--- indicator version number
#property version   "1.00"
//--- drawing indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers 2
#property indicator_buffers 2 
//--- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//--- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_ARROW
//--- the following colors are used in the four color histogram
#property indicator_color1 Gray,Teal,BlueViolet,IndianRed,Magenta
//--- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//--- indicator line width is equal to 5
#property indicator_width1 5
//--- displaying the indicator label
#property indicator_label1 "RSI HTF"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1  70
#property indicator_level2  50
#property indicator_level3  30
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;         // Chart period
input int RSI_Period=12;                           // RSI period
input ENUM_APPLIED_PRICE AppliedPrice=PRICE_CLOSE; // Price constant
input bool ReDraw=true;                            // Repeat display of information in the empty bars
//+----------------------------------------------+
//--- declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int RSI_Handle;
//--- declaration of dynamic arrays that further will be used as indicator buffers
double RSIBuffer[],ColorRSIBuffer[];
//+------------------------------------------------------------------+
//|  Getting timeframe as string                                     |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+    
//| RSI indicator initialization function                            | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=3;
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("RSI indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- getting handle of the ColorRSI indicator
   RSI_Handle=iRSI(Symbol(),TimeFrame,RSI_Period,AppliedPrice);
   if(RSI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the RSI indicator");
      Init=false;
      return(INIT_FAILED);
     }
//--- set RSIBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,RSIBuffer,INDICATOR_DATA);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(RSIBuffer,true);
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorRSIBuffer,INDICATOR_COLOR_INDEX);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorRSIBuffer,true);

//--- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"RSI HTF( ",GetStringTimeframe(TimeFrame),", ",RSI_Period,", ",AppliedPrice," )");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- end of initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| RSI iteration function                                           | 
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
   if(rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(RSI_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declaration of integer variables
   int limit,bar;
//--- declaration of variables with a floating point  
   double RSI[2];
   datetime RSITime[1];
   static uint LastCountBar;
//--- calculations of the necessary amount of data to be copied
//--- and the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for calculation of new bars 
//--- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
//--- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for calculation
      RSIBuffer[bar]=EMPTY_VALUE;
      ColorRSIBuffer[bar]=0;
      //--- copy newly appeared data in the array
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,RSITime)<=0) return(RESET);
      if(time[bar]>=RSITime[0] && time[bar+1]<RSITime[0])
        {
         LastCountBar=bar;
         //--- copy newly appeared data into the arrays
         if(CopyBuffer(RSI_Handle,0,time[bar],2,RSI)<=0) return(RESET);
         //--- Loading the obtained values in the indicator buffers
         RSIBuffer[bar]=RSI[1];
         //---    
         if(RSIBuffer[bar]>50)
           {
            if(RSI[1]>RSI[0]) ColorRSIBuffer[bar]=1;
            if(RSI[1]<RSI[0]) ColorRSIBuffer[bar]=2;
           }
         //---
         if(RSIBuffer[bar]<50)
           {
            if(RSI[1]<RSI[0]) ColorRSIBuffer[bar]=3;
            if(RSI[1]>RSI[0]) ColorRSIBuffer[bar]=4;
           }
        }
      //--- 
      if(ReDraw)
        {
         if(RSIBuffer[bar+1]!=EMPTY_VALUE && RSIBuffer[bar]==EMPTY_VALUE)
           {
            RSIBuffer[bar]=RSIBuffer[bar+1];
            ColorRSIBuffer[bar]=ColorRSIBuffer[bar+1];
           }
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
