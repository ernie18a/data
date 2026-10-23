//+------------------------------------------------------------------+
//|                                                  DynamicRS_C.mq5 |
//|                                 Copyright © 2007, Nick A. Zhilin |
//|                                                  rebus58@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Nick A. Zhilin"
#property link "rebus58@mail.ru"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a multicolored line
#property indicator_type1   DRAW_COLOR_LINE
//---- the following colors are used in a three-color line
#property indicator_color1  clrMagenta,clrYellow,clrBlueViolet
//--- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "DynamicRS_C"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint Length=5;     // Depth of the first smoothing
input int Shift=0;       // Horizontal shift of the indicator in bars
input int PriceShift=0;  // Vertical shift of the indicator in points
//+-----------------------------------+
//--- declaration of dynamic arrays that 
//--- will be used as indicator buffers
double IndBuffer[];
double ColorIndBuffer[];
//--- declaration of the average vertical shift value variable
double dPriceShift;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- initialization of variables of data calculation start
   min_rates_total=int(Length+1);
//--- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   string shortname;
//--- initializations of a variable for the indicator short name
   StringConcatenate(shortname,"DynamicRS_C(",Length,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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
   if(rates_total<min_rates_total) return(0);
//--- declaration of integer variables and getting already calculated bars
   int first,bar;
//--- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=min_rates_total-1; // starting index for calculation of all bars
      IndBuffer[first-1]=close[first-1];
      ColorIndBuffer[first-1]=1;
     }
   else first=prev_calculated-1; // starting number for calculation of new bars
//--- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      ColorIndBuffer[bar]=1;
      if(high[bar]<high[bar-1] && high[bar]<high[bar-Length] && high[bar]<IndBuffer[bar-1])
        {
         IndBuffer[bar]=high[bar]+PriceShift;
         if(ColorIndBuffer[bar-1]==2) ColorIndBuffer[bar]=1; else ColorIndBuffer[bar]=0;
        }
      else if(low[bar]>low[bar-1] && low[bar]>low[bar-Length] && low[bar]>IndBuffer[bar-1])
        {
         IndBuffer[bar]=low[bar]+PriceShift;
         if(ColorIndBuffer[bar-1]==0) ColorIndBuffer[bar]=1; else ColorIndBuffer[bar]=2;
        }
      else
        {
         IndBuffer[bar]=IndBuffer[bar-1];
         ColorIndBuffer[bar]=ColorIndBuffer[bar-1];
         if(ColorIndBuffer[bar]==1)
           {
            if(ColorIndBuffer[bar-2]==0) ColorIndBuffer[bar]=2;
            if(ColorIndBuffer[bar-2]==2) ColorIndBuffer[bar]=0;
           }
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
