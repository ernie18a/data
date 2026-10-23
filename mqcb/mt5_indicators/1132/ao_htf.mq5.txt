//+------------------------------------------------------------------+ 
//|                                                       AO_HTF.mq5 | 
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
//+-----------------------------------+
//| Parameters of indicator drawing   |
//+-----------------------------------+
//--- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- the following colors are used in the four color histogram
#property indicator_color1 Gray,Lime,MediumVioletRed,Red,Teal
//--- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//--- indicator line width is equal to 5
#property indicator_width1 5
//--- displaying the indicator label
#property indicator_label1 "AO HTF"
//+-----------------------------------+
//| Declaration of constants          |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; // Chart period
input bool ReDraw=true;                    // Repeat display of information in the empty bars
//+-----------------------------------+
//--- declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int AO_Handle;
//--- declaration of dynamic arrays that further will be used as indicator buffers
double AOBuffer[],ColorAOBuffer[];
//+------------------------------------------------------------------+
//|  Getting string timeframe                                        |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+    
//| AO indicator initialization function                             | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=3;
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Awesome Oscillator indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- getting handle of the Awesome oscillator indicator 
   AO_Handle=iAO(Symbol(),TimeFrame);
   if(AO_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the Awesome Oscillator indicator");
      Init=false;
      return(INIT_FAILED);
     }
//--- set AOBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,AOBuffer,INDICATOR_DATA);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Awesome oscillator  HTF");
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(AOBuffer,true);
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorAOBuffer,INDICATOR_COLOR_INDEX);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorAOBuffer,true);
//--- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Awesome oscillator HTF( ",GetStringTimeframe(TimeFrame)," )");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- end of initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| AO iteration function                                            | 
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
//--- declaration of integer variables
   int limit,bar;
//--- declaration of variables with a floating point  
   double AO[2];
   datetime AOTime[1];
   static uint LastCountBar;
//--- calculations of the necessary amount of data to be copied and
//--- the limit starting number for loop of bars recalculation
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
      AOBuffer[bar]=EMPTY_VALUE;
      ColorAOBuffer[bar]=0;
      //--- copy newly appeared data in the array
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,AOTime)<=0) return(RESET);
      if(time[bar]>=AOTime[0] && time[bar+1]<AOTime[0])
        {
         LastCountBar=bar;
         //--- copy newly appeared data into the arrays
         if(CopyBuffer(AO_Handle,0,time[bar],2,AO)<=0) return(RESET);
         //--- loading the obtained values in the indicator buffers
         AOBuffer[bar]=AO[1];
         if(AOBuffer[bar]>0)
           {
            if(AO[1]>AO[0]) ColorAOBuffer[bar]=1;
            if(AO[1]<AO[0]) ColorAOBuffer[bar]=2;
           }
         if(AOBuffer[bar]<0)
           {
            if(AO[1]<AO[0]) ColorAOBuffer[bar]=3;
            if(AO[1]>AO[0]) ColorAOBuffer[bar]=4;
           }
        }
      if(ReDraw)
        {
         if(AOBuffer[bar+1]!=EMPTY_VALUE && AOBuffer[bar]==EMPTY_VALUE)
           {
            AOBuffer[bar]=AOBuffer[bar+1];
            ColorAOBuffer[bar]=ColorAOBuffer[bar+1];
           }
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
