//+------------------------------------------------------------------+
//|                                                MTF_MACD_Bars.mq5 | 
//|                                     Copyright © 2008, Kirk Sloan | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Kirk Sloan"
#property link ""
#property description ""
//---- The indicator version
#property version   "1.00"
//---- The indicator is drawn in a separate window
#property indicator_separate_window
//---- 4 indicator buffers
#property indicator_buffers 4
//---- 4 graphical constructions are used
#property indicator_plots   4
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- The indicator is drawn as a three color line
#property indicator_type1   DRAW_HISTOGRAM
//---- Color of the histogram
#property indicator_color1 clrMagenta
//---- The indicator is drawn as a solid line
#property indicator_style1  STYLE_SOLID
//---- The width of the indicator line is 3
#property indicator_width1  3
//---- The indicator label
#property indicator_label1  "Sig above MACD"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- The indicator is drawn as a three color line
#property indicator_type2   DRAW_HISTOGRAM
//---- Color of the histogram
#property indicator_color2 clrBlue
//---- The indicator is drawn as a solid line
#property indicator_style2  STYLE_SOLID
//---- The width of the indicator line is 3
#property indicator_width2  3
//---- The indicator label
#property indicator_label2  "Sig below MACD"
//+-----------------------------------+
//|  Indicator 3 drawing parameters   |
//+-----------------------------------+
//---- The indicator is drawn as a three color line
#property indicator_type3   DRAW_HISTOGRAM
//---- Color of the histogram
#property indicator_color3 clrGreen
//---- The indicator is drawn as a solid line
#property indicator_style3  STYLE_SOLID
//---- The width of the indicator line is 3
#property indicator_width3  3
//---- The indicator label
#property indicator_label3  "Sig below MACD & Above 0"
//+-----------------------------------+
//|  Indicator 4 drawing parameters   |
//+-----------------------------------+
//---- The indicator is drawn as a three color line
#property indicator_type4   DRAW_HISTOGRAM
//---- Color of the histogram
#property indicator_color4 clrRed
//---- The indicator is drawn as a solid line
#property indicator_style4  STYLE_SOLID
//---- The width of the indicator line is 3
#property indicator_width4  3
//---- The indicator label
#property indicator_label4  "Sig above MACD & Below 0"
//+-----------------------------------+
//|  Declaring constants              |
//+-----------------------------------+
#define RESET 0 // A constant for returning indicator recalculation command to the terminal
//+-----------------------------------+
//|  INPUT PARAMETERS OF THE INDICATOR|
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//Chart period
//+-----------------------------------+
//|  INPUT PARAMETERS OF THE INDICATOR|
//+-----------------------------------+
input int MACD_Fast=8;
input int MACD_Slow=17;
input int MACD_Signal=9;
//+-----------------------------------+
//---- Declaring dynamic arrays that will
// further be used as indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//---- Declaring a variable for storing the results of indicator initialization
bool Init;
//---- Declaring integer variables of data calculation start
int min_rates_total;
//---- Declaring integer variables for the indicator handles
int MACD_Handle;
//+------------------------------------------------------------------+
//|  Getting a string timeframe                                      |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+   
//| Stochastic indicator initialization function                     | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=3;
   Init=true;

//---- Checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Chart period for Stochastic cannot be less than the period of the current chart");
      Init=false;
      return;
     }

//---- Getting indicator handles  
   MACD_Handle=iMACD(NULL,TimeFrame,MACD_Fast,MACD_Slow,MACD_Signal,PRICE_CLOSE);

   if(MACD_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the Stochastic indicator");
      Init=false;
      return;
     }

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtMapBuffer1,INDICATOR_DATA);
//---- Shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtMapBuffer1,true);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtMapBuffer2,INDICATOR_DATA);
//---- Shifting the start of drawing of the indicator
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtMapBuffer2,true);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtMapBuffer3,INDICATOR_DATA);
//---- Shifting the start of drawing of the indicator
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtMapBuffer3,true);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(3,ExtMapBuffer4,INDICATOR_DATA);
//---- Shifting the start of drawing of the indicator
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtMapBuffer4,true);

//---- Creating a name for displaying in a separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"MTF_MACD_Bars("+GetStringTimeframe(TimeFrame)+", "
                      +(string)MACD_Fast+","+(string)MACD_Slow+","+(string)MACD_Signal+")");

//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- End of initialization
  }
//+------------------------------------------------------------------+ 
//| Stochastic iteration function                                    | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- Checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total || !Init) return(RESET);
//---- Declaring integer variables
   int limit,bar;
//---- Declaring floating point variables  
   double Main[1],Signal[1];
   datetime iTime[1];
   static uint LastCountBar;

//---- Calculations of the necessary number of copied data
//and limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for the calculation of new bars 

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- Zero out the contents of the indicator buffers for the calculation
      ExtMapBuffer1[bar]=EMPTY_VALUE;
      ExtMapBuffer2[bar]=EMPTY_VALUE;
      ExtMapBuffer3[bar]=EMPTY_VALUE;
      ExtMapBuffer4[bar]=EMPTY_VALUE;

      //---- Copy the new data into the array
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,iTime)<=0) return(RESET);

      if(time[bar]>=iTime[0] && time[bar+1]<iTime[0]) LastCountBar=bar;

      //---- copy newly appeared data into the arrays
      if(CopyBuffer(MACD_Handle,MAIN_LINE,time[bar],1,Main)<=0) return(RESET);
      if(CopyBuffer(MACD_Handle,SIGNAL_LINE,time[bar],1,Signal)<=0) return(RESET);

      if(Signal[0]<Main[0]) ExtMapBuffer2[bar]=-1;//Sig Below MACD 
      if(Signal[0]>Main[0]) ExtMapBuffer1[bar]=+1;//Sig above MACD

      if(Signal[0]<Main[0] && Main[0]>0) ExtMapBuffer3[bar]=+1;//Sig below MACD & Above 0
      if(Signal[0]>Main[0] && Main[0]<0) ExtMapBuffer4[bar]=-1;//Sig above MACD & Below 0
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
