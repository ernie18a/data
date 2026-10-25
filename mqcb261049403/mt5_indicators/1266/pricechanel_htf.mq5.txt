//+------------------------------------------------------------------+ 
//|                                              PriceChanel_HTF.mq5 | 
//|                                         Copyright © 2009, MaxxMT |
//|                                                                  |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2009, MaxxMT"
//---- link to the website of the author
#property link      ""
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 2 
//---- three plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- DarkViolet color is used for indicator line
#property indicator_color1 clrDarkViolet
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Upper Price Chanel"
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- DarkOrange color is used as the color of the line of the indicator
#property indicator_color2 clrDarkOrange
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Lower Price Chanel"

//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//Chart period
input uint UpPeriod=12; //Maximums searching period
input uint DnPeriod=12; //Minimums searching period
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double UpperBuffer[];
double LowerBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- Declaration of a variable for storing the indicator initialization result
bool Init;
//----
double iHigh[],iLow[];
//+------------------------------------------------------------------+
//|  Getting string timeframe                                        |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+    
//| Price Chanel HTF indicator initialization function               | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initializing constants
   int min_rates_=int(MathMax(UpPeriod,DnPeriod));
   min_rates_total=int(min_rates_*PeriodSeconds(TimeFrame)/PeriodSeconds(PERIOD_CURRENT));
   Init=true;

//---- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Price Chanel HTF indicator chart period cannot be less than the current chart period");
      Init=false;
      return;
     }

//---- memory distribution for variables' arrays  
   ArrayResize(iHigh,UpPeriod);
   ArrayResize(iLow,DnPeriod);
//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(iHigh,true);
   ArraySetAsSeries(iLow,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(UpperBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,LowerBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(LowerBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Price Chanel HTF(",GetStringTimeframe(TimeFrame),",",UpPeriod,",",DnPeriod,",",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| Price Chanel HTF iteration function                              | 
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
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total || !Init) return(RESET);

//---- Declaration of local variables
   int limit,bar;
   datetime iTime[1];
   static uint LastCountBar;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for the calculation of new bars 

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- zero out the contents of the indicator buffers for the calculation
      LowerBuffer[bar]=EMPTY_VALUE;
      UpperBuffer[bar]=EMPTY_VALUE;

      //--- copy newly appeared data in the array
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,iTime)<=0) return(RESET);

      if(time[bar]>=iTime[0] && time[bar+1]<iTime[0])
        {
         LastCountBar=bar;

         //---- copy newly appeared data into the arrays
         if(CopyLow(Symbol(),TimeFrame,time[bar],DnPeriod,iLow)<=0) return(RESET);
         if(CopyHigh(Symbol(),TimeFrame,time[bar],UpPeriod,iHigh)<=0) return(RESET);

         //---- Loading the obtained values in the indicator buffers
         LowerBuffer[bar]=iLow[ArrayMinimum(iLow,0,DnPeriod)];
         UpperBuffer[bar]=iHigh[ArrayMaximum(iHigh,0,UpPeriod)];
        }

      if(LowerBuffer[bar+1]!=EMPTY_VALUE && LowerBuffer[bar]==EMPTY_VALUE)
        {
         LowerBuffer[bar]=LowerBuffer[bar+1];
         UpperBuffer[bar]=UpperBuffer[bar+1];
        }
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
