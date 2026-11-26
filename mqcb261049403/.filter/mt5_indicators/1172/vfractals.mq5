//+------------------------------------------------------------------+
//|                                                    VFractals.mq5 |
//|                                  Copyright © 2010,   sanyooooook | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
//---- author of the indicator
#property copyright "Copyright © 2010, sanyooooook"
//---- link to the website of the author
#property link "" 
#property description "indicator marks the level of the fractal which formed on the bar with the volume," 
#property description "which larger than the average volume of the last 3 bars before fractal." 
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----two buffers are used for calculation of drawing of the indicator
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- magenta color is used as the color of the bearish indicator line
#property indicator_color1  Magenta
//---- thickness of line of the indicator 1 is equal to 4
#property indicator_width1  4
//---- bullish indicator label display
#property indicator_label1  "Down VFractals"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- blue color is used for the indicator bullish line
#property indicator_color2  Blue
//---- thickness of the indicator line 2 is equal to 4
#property indicator_width2  4
//---- bearish indicator label display
#property indicator_label2 "Up VFractals"

#define RESET 0 // The constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  //volume
input int Shift=0; // horizontal shift of the indicator in bars
input uint Lable=158; //Lable for icon
//+----------------------------------------------+

//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double DnBuffer[];
double UpBuffer[];
//----
int  min_rates_total;
//---- declaration of integer variables for the indicators handles
int Fra_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables of the start of data calculation    
   min_rates_total=6;

//---- getting handle of the iFractals indicator
   Fra_Handle=iFractals(Symbol(),PERIOD_CURRENT);
   if(Fra_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iFractals indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,DnBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,Lable);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,UpBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,Lable);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="VFractals("+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(Fra_Handle)<min_rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,bar,to_copy;
   double UpFractals[],DnFractals[];
   long Vol2,SVol;

//--- calculations of the necessary amount of data to be copied and
//the "limit" starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
      UpBuffer[limit]=EMPTY_VALUE;
      DnBuffer[limit]=EMPTY_VALUE;
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

   to_copy=limit+1;

//---- indexing elements in arrays as time series
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(volume,true);
   ArraySetAsSeries(tick_volume,true);
   ArraySetAsSeries(spread,true);
   ArraySetAsSeries(UpFractals,true);
   ArraySetAsSeries(DnFractals,true);

//---- copy newly appeared data into the arrays
   if(CopyBuffer(Fra_Handle,UPPER_LINE,2,to_copy,UpFractals)<=0) return(RESET);
   if(CopyBuffer(Fra_Handle,LOWER_LINE,2,to_copy,DnFractals)<=0) return(RESET);

//---- main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      UpBuffer[bar]=EMPTY_VALUE;
      DnBuffer[bar]=EMPTY_VALUE;

      if(VolumeType==VOLUME_TICK)
        {
         Vol2=tick_volume[bar+2];
         SVol=(tick_volume[bar+3]+tick_volume[bar+4]+tick_volume[bar+5])/3;
        }
      else
        {
         Vol2=volume[bar+2];
         SVol=(volume[bar+3]+volume[bar+4]+volume[bar+5])/3;
        }

      if(Vol2>SVol && UpFractals[bar]!=EMPTY_VALUE) UpBuffer[bar]=UpFractals[bar]+_Point+spread[bar]*_Point;
      else UpBuffer[bar]=UpBuffer[bar+1];

      if(Vol2>SVol && DnFractals[bar]!=EMPTY_VALUE) DnBuffer[bar]=DnFractals[bar]-_Point;
      else DnBuffer[bar]=DnBuffer[bar+1];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
