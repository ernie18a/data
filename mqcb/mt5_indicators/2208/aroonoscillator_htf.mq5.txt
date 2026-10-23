//+------------------------------------------------------------------+ 
//|                                          AroonOscillator_HTF.mq5 | 
//|                               Copyright © 2014, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2014, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//--- indicator version
#property version   "1.60"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers is 2
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//| Indicator drawing parameters                 |
//+----------------------------------------------+
//--- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- colors of the four-color histogram are as follows
#property indicator_color1 clrRed,clrMediumVioletRed,clrGray,clrTeal,clrLime
//--- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//--- indicator line width is 5
#property indicator_width1 5
//--- displaying the indicator label
#property indicator_label1 "Aroon Oscillator HTF"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 +50
#property indicator_level2   0
#property indicator_level3 -50
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| declaration of constants                     |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; // Chart period
input uint AroonPeriod=9;                  // Indicator period 
input bool ReDraw=true;                    // repeat information display on empty bars
//+----------------------------------------------+
//--- declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of integer variables of data starting point
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int Ind_Handle;
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+
//|  Getting a timeframe as a line                                   |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| Aroon oscillator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=3;
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Chart period for Aroon oscillator cannot be less than the period of the current chart");
      return(INIT_FAILED);
     }
//--- getting the handle of Aroon Oscillator
   Ind_Handle=iCustom(Symbol(),TimeFrame,"AroonOscillator",AroonPeriod,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of Aroon Oscillator");
      return(INIT_FAILED);
     }
//--- Set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//--- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorIndBuffer,true);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Aroon oscillator HTF( ",GetStringTimeframe(TimeFrame)," )");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Aroon oscillator function                                        | 
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
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declaration of integer variables
   int limit,bar;
//--- declaration of variables with a floating point  
   double Ind[2];
   datetime IndTime[1];
   static uint LastCountBar;
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for the calculation of new bars 
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(time,true);
//--- main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- Zero out the contents of the indicator buffers for the calculation
      IndBuffer[bar]=EMPTY_VALUE;
      ColorIndBuffer[bar]=2;
      //--- copy newly appeared data in the array
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,IndTime)<=0) return(RESET);
      //---
      if(time[bar]>=IndTime[0] && time[bar+1]<IndTime[0])
        {
         LastCountBar=bar;
         //--- copy newly appeared data in the arrays
         if(CopyBuffer(Ind_Handle,0,time[bar],2,Ind)<=0) return(RESET);
         //--- Loading the obtained values in the indicator buffers
         IndBuffer[bar]=Ind[1];
         int clr=2;
         //---
         if(IndBuffer[bar]>0)
           {
            if(Ind[1]>Ind[0]) clr=4;
            if(Ind[1]<Ind[0]) clr=3;
           }
         //---
         if(IndBuffer[bar]<0)
           {
            if(Ind[1]<Ind[0]) clr=0;
            if(Ind[1]>Ind[0]) clr=1;
           }
         ColorIndBuffer[bar]=clr;
        }
      //---
      if(ReDraw)
        {
         if(IndBuffer[bar+1]!=EMPTY_VALUE && IndBuffer[bar]==EMPTY_VALUE)
           {
            IndBuffer[bar]=IndBuffer[bar+1];
            ColorIndBuffer[bar]=ColorIndBuffer[bar+1];
           }
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
