//+------------------------------------------------------------------+
//|                                              NxDRangeSwitch.mq5  |
//|                                       Copyright © 2009, Vic2008  |
//|                                                                  |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2009, Vic2008"
//---- link to the website of the author
#property link ""
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- five buffers are used for calculation and drawing the indicator
#property indicator_buffers 5
//---- 4 plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- LightSeaGreen color is used for the indicator line
#property indicator_color1  LightSeaGreen
//---- the indicator 1 line is a dot-dash one
#property indicator_style1  STYLE_DASHDOTDOT
//---- indicator 1 line width is equal to 2
#property indicator_width1  2
//---- displaying of the indicator line label
#property indicator_label1  "Upper NxDRangeSwitch"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- dawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- medium violet red color is used for the indicator line
#property indicator_color2  MediumVioletRed
//---- the indicator 2 line is a dot-dash one
#property indicator_style2  STYLE_DASHDOTDOT
//---- indicator 2 line width is equal to 2
#property indicator_width2  2
//---- displaying of the indicator line label
#property indicator_label2  "Lower NxDRangeSwitch"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 3 as a label
#property indicator_type3   DRAW_ARROW
//---- SeaGreen color is used for the indicator
#property indicator_color3  SeaGreen
//---- indicator 3 width is equal to 4
#property indicator_width3  4
//---- displaying the indicator label
#property indicator_label3  "Buy NxDRangeSwitch"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 4 as a label
#property indicator_type4   DRAW_ARROW
//---- deep pink color is used for the indicator
#property indicator_color4  DeepPink
//---- indicator 4 width is equal to 4
#property indicator_width4  4
//---- displaying the indicator label
#property indicator_label4  "Sell NxDRangeSwitch"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input uint   period=4;           // calculation period (not less than two)
input int    Shift=0;            // horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that
// will be used as indicator buffers
double ExtMapBufferUp[];
double ExtMapBufferDown[];
double ExtMapBufferUp1[];
double ExtMapBufferDown1[];
double ExtCalcBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,period0,period1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- initialization of variables of the start of data calculation
   period0=int(MathMax(2,period));
   min_rates_total=period0+1;
   period1=period0-1;

//---- set ExtMapBufferUp[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtMapBufferUp,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferUp,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set ExtMapBufferDown[] dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtMapBufferDown,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferDown,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set ExtMapBufferUp1[] dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtMapBufferUp1,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferUp1,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,167);

//---- set ExtMapBufferDown1[] dynamic array as an indicator buffer
   SetIndexBuffer(3,ExtMapBufferDown1,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferDown1,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,167);

//---- set ExtCalcBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(4,ExtCalcBuffer,INDICATOR_CALCULATIONS);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtCalcBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"NxDRangeSwitch(",period,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   double HHp1,HHp0,LLp1,LLp0,Val,Val1;
   int limit,bar;

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1;               // starting index for calculation of all bars
   else limit=rates_total-prev_calculated;               // starting index for calculation of new bars

//---- main loop of the indicator calculation
   for(bar=limit; bar>=0; bar--)
     {
      HHp0=high[ArrayMaximum(high,bar+1,period0)];
      LLp0=low [ArrayMinimum(low, bar+1,period0)];
      HHp1=high[ArrayMaximum(high,bar+1,period1)];
      LLp1=low [ArrayMinimum(low, bar+1,period1)];


      ExtCalcBuffer[bar]=ExtCalcBuffer[bar+1];
      ExtMapBufferDown1[bar]=0;
      ExtMapBufferUp1[bar]=0;

      if(close[bar]>HHp0) ExtCalcBuffer[bar]=LLp1;
      if(close[bar]<LLp0) ExtCalcBuffer[bar]=HHp1;
      Val=ExtCalcBuffer[bar];

      if(close[bar]>Val)
        {
         Val1=ExtMapBufferUp[bar+1];
         if(Val1 && Val1<=Val || !Val1) ExtMapBufferUp[bar]=Val;
         if(Val1 && Val1>Val) ExtMapBufferUp[bar]=Val1;
         ExtMapBufferDown[bar]=0;
        }

      if(close[bar]<Val)
        {
         Val1=ExtMapBufferDown[bar+1];
         if(Val1 && Val1>=Val || !Val1) ExtMapBufferDown[bar]=Val;
         if(Val1 && Val1<Val) ExtMapBufferDown[bar]=Val1;
         ExtMapBufferUp[bar]=0;
        }

      if(!ExtMapBufferUp[bar+1] && ExtMapBufferUp[bar]) ExtMapBufferUp1[bar]=Val;
      if(!ExtMapBufferDown[bar+1] && ExtMapBufferDown[bar]) ExtMapBufferDown1[bar]=Val;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
