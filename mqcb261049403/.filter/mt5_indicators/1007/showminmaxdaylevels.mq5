//+------------------------------------------------------------------+ 
//|                                          ShowMinMaxDayLevels.mq5 | 
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 2 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used as the color of a bullish candlestick
#property indicator_color1 Blue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- the width of indicator line is 3
#property indicator_width1  3
//---- displaying the indicator label
#property indicator_label1  "MaxDayLevel"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- red color is used as the color of the bullish line of the indicator
#property indicator_color2 Red
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- the width of indicator line is 3
#property indicator_width2  3
//---- displaying the indicator label
#property indicator_label2  "MinDayLevel"
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input uint DayShift=0; // shift of counting start in days 
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+
//---- indicator buffers
double MaxBuffer[],MinBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+    
//| ShowMinMaxDayLevels indicator initialization function            | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(3 + DayShift*PeriodSeconds(PERIOD_D1)/(PeriodSeconds()));
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,MaxBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(MaxBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,MinBuffer,INDICATOR_DATA);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(MinBuffer,true);
   
//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"ShowMinMaxDayLevels( Shift = ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| ShowMinMaxDayLevels iteration function                           | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total||Period()>PERIOD_H12) return(RESET);

//---- Declaration of integer variables
   int limit,bar;
//---- declaration of variables with a floating point  
   double DHigh[1],DLow[1];
   datetime DTime[1];
   static uint LastCountBar;

//--- calculations of the necessary amount of data to be copied and
//----the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for calculation of new bars 

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);

//---- Main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      LastCountBar=bar;
      //---- zero out the contents of the indicator buffers for calculation
      MaxBuffer[bar]=EMPTY_VALUE;
      MinBuffer[bar]=EMPTY_VALUE;

      //--- copy newly appeared data in the array
      if(CopyTime(Symbol(),PERIOD_D1,time[bar],1,DTime)<=0) return(RESET);

      if(time[bar]>=DTime[0] && time[bar+1]<DTime[0])
        {
         //---- copy newly appeared data into the arrays
         if(CopyHigh(Symbol(),PERIOD_D1,time[bar+DayShift],1,DHigh)<=0) return(RESET);
         if(CopyLow(Symbol(),PERIOD_D1,time[bar+DayShift],1,DLow)<=0) return(RESET);
         //---- Loading the obtained values in the indicator buffers
         MaxBuffer[bar]=DHigh[0];
         MinBuffer[bar]=DLow[0];
        }

      if(MaxBuffer[bar+1]!=EMPTY_VALUE && MaxBuffer[bar]==EMPTY_VALUE) 
        {
         MaxBuffer[bar]=MaxBuffer[bar+1];
         MinBuffer[bar]=MinBuffer[bar+1];
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
