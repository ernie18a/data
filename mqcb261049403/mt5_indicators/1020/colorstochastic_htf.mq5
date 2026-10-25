//+------------------------------------------------------------------+
//|                                          ColorStochastic_HTF.mq5 | 
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Stochastic oscillator with a choice of a fixed timeframe"
//--- indicator version number
#property version   "1.00"
//--- drawing indicator in a separate window
#property indicator_separate_window
//--- number of indicator buffers 4
#property indicator_buffers 4
//--- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1  70.0
#property indicator_level2  50.0
#property indicator_level3  30.0
#property indicator_levelcolor Violet
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//--- drawing the indicator 1 as a cloud
#property indicator_type1   DRAW_FILLING
//--- the following colors are used in the histogram
#property indicator_color1 Teal,MediumVioletRed
//--- displaying the indicator label
#property indicator_label1  "Stochastic HTF"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//--- drawing indicator as a three-colored line
#property indicator_type2   DRAW_COLOR_LINE
//--- the following colors are used for the indicator line
#property indicator_color2 Gray,Lime,Magenta
//--- the indicator line is a stroke
#property indicator_style2  STYLE_SOLID
//--- indicator line width is equal to 5
#property indicator_width2  5
//--- displaying the indicator label
#property indicator_label2  "Signal line"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;    // Chart period
input int InpKPeriod=5;                       // K period
input int InpDPeriod=3;                       // D period
input int InpSlowing=3;                       // Slowing
input ENUM_MA_METHOD ma_method=MODE_SMA;      // Smoothing type
input ENUM_STO_PRICE price_field=STO_LOWHIGH; // Stochastic calculation method
//+-----------------------------------+
//--- declaration of dynamic arrays that further 
//--- will be used as indicator buffers
double UpStochastic[],DnStochastic[];
double StochSignal[],ColorStochSignal[];
//--- declaration of a variable for storing the indicator initialization result
bool Init;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int Stochastic_Handle;
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
//| Stochastic indicator initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=3;
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Stochastic indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- obtaining the indicators handles  
   Stochastic_Handle=iStochastic(NULL,TimeFrame,InpKPeriod,InpDPeriod,InpSlowing,ma_method,price_field);
   if(Stochastic_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the Stochastic indicator");
      Init=false;
      return(INIT_FAILED);
     }
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpStochastic,INDICATOR_DATA);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpStochastic,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnStochastic,INDICATOR_DATA);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnStochastic,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(2,StochSignal,INDICATOR_DATA);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(StochSignal,true);
//--- set dynamic array as a color index buffer   
   SetIndexBuffer(3,ColorStochSignal,INDICATOR_COLOR_INDEX);
//--- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorStochSignal,true);
//--- creating name for displaying in a separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"Stoch("+GetStringTimeframe(TimeFrame)+", "
                      +(string)InpKPeriod+","+(string)InpDPeriod+","+(string)InpSlowing+")");
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- end of initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Stochastic iteration function                                    | 
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
   if(BarsCalculated(Stochastic_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declaration of integer variables
   int limit,bar;
//--- declaration of variables with a floating point  
   double Stoch[2],Signal[2];
   datetime StochasticTime[1];
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
//--- Main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for calculation
      UpStochastic[bar]=EMPTY_VALUE;
      DnStochastic[bar]=EMPTY_VALUE;
      StochSignal[bar]=EMPTY_VALUE;
      ColorStochSignal[bar]=0;
      //--- copy newly appeared data in the array
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,StochasticTime)<=0) return(RESET);
      if(time[bar]>=StochasticTime[0] && time[bar+1]<StochasticTime[0])
        {
         LastCountBar=bar;
         //--- copy newly appeared data into the arrays
         if(CopyBuffer(Stochastic_Handle,MAIN_LINE,time[bar],2,Stoch)<=0) return(RESET);
         if(CopyBuffer(Stochastic_Handle,SIGNAL_LINE,time[bar],2,Signal)<=0) return(RESET);
         //--- Loading the obtained values in the indicator buffers
         StochSignal[bar]=Signal[1];
         //---
         UpStochastic[bar]=50;
         DnStochastic[bar]=50;
         //---    
         if(Stoch[1]>50) UpStochastic[bar]=Stoch[1];
         if(Stoch[1]<50) UpStochastic[bar]=Stoch[1];
         //---
         if(Stoch[1]>StochSignal[bar]) ColorStochSignal[bar]=1;
         if(Stoch[1]<StochSignal[bar]) ColorStochSignal[bar]=2;
        }
      //---
      if(UpStochastic[bar+1]!=EMPTY_VALUE && UpStochastic[bar]==EMPTY_VALUE)
        {
         UpStochastic[bar]=UpStochastic[bar+1];
         DnStochastic[bar]=DnStochastic[bar+1];
         StochSignal[bar]=StochSignal[bar+1];
         ColorStochSignal[bar]=ColorStochSignal[bar+1];
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
