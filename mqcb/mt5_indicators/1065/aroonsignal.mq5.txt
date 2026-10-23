//+------------------------------------------------------------------+
//|                                                  AroonSignal.mq5 |
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2012, Nikolay Kositsin"
//---- link to the author's website
#property link "farria@mail.redcom.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Bullish indicator drawing parameters       |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- green color is used as the color of the bullish line of the indicator
#property indicator_color1  Lime
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is 1
#property indicator_width1  1
//---- displaying the bullish label of the indicator
#property indicator_label1  "Bulls Aroon Signal"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters   |
//+----------------------------------------------+
//---- drawing indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//---- red color is used as the color of the bearish line of the indicator
#property indicator_color2  Red
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is 1
#property indicator_width2  1
//---- displaying the bearish label of the indicator
#property indicator_label2  "Bears Aroon Signal"
//+----------------------------------------------+
//| Indicator input parameters                 |
//+----------------------------------------------+
input int HighLevel=85;   // overbought level
input int LowLevel=15;    // oversold level
input int AroonPeriod=9;   // indicator period
input int AroonShift =0;   // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double BullsAroonBuffer[];
double BearsAroonBuffer[];
//---- declaration of integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(AroonPeriod,10));

//---- transformation of the dynamic array BullsAroonBuffer into an indicator buffer
   SetIndexBuffer(0,BullsAroonBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,AroonShift);
//---- shifting the starting point for drawing indicator 1 by AroonPeriod
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,AroonPeriod);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,117);
//---- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(BullsAroonBuffer,true);

//---- transformation of the dynamic array BearsAroonBuffer into an indicator buffer
   SetIndexBuffer(1,BearsAroonBuffer,INDICATOR_DATA);
//---- shifting indicator 2 horizontally by AroonShift
   PlotIndexSetInteger(1,PLOT_SHIFT,AroonShift);
//---- shifting the starting point for drawing indicator 2 by AroonPeriod
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,AroonPeriod);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,117);
//---- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(BearsAroonBuffer,true);

//---- initialization of a variable for a short name of the indicator
   string shortname;
   StringConcatenate(shortname,"AroonSignal(",AroonPeriod,", ",AroonShift,")");
//--- creating a name to be displayed in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);

//---- values of the horizontal levels of the indicator   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,LowLevel);
//---- gray and magenta colors are used for horizontal level lines  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,Magenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,Magenta);
//---- horizontal level line is a short dash-and-dot line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // history in bars at the current tick
                const int prev_calculated,// history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price highs for the calculation of the indicator
                const double& low[],      // price array of price lows for the calculation of the indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declaring local variables 
   int limit;
   double BULLS,BEARS,Range;
   static int LastTrend;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      LastTrend=0;
     }
   else limit=rates_total-prev_calculated;  // starting index for the calculation of the new bars only

//---- indexing array elements as time series  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   
//---- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BullsAroonBuffer[bar] = EMPTY_VALUE;
      BearsAroonBuffer[bar] = EMPTY_VALUE;

      //---- calculation of indicator values
      BULLS = 100-(ArrayMaximum(high,bar,AroonPeriod)-bar+0.5)*100/AroonPeriod;
      BEARS = 100-(ArrayMinimum(low,bar,AroonPeriod)-bar+0.5)*100/AroonPeriod;

      if(BULLS>HighLevel && BEARS<LowLevel)
        {
         if(LastTrend==-1)
           {
            Range=0.0;
            for(int count=bar; count<bar+10; count++) Range+=MathAbs(high[count]-low[count]);
            Range*=0.5/10;
            BullsAroonBuffer[bar]=low[bar]-Range;
           }

         LastTrend=+1;
         continue;
        }

      if(BULLS<LowLevel && BEARS>HighLevel)
        {
         if(LastTrend==+1)
           {
            Range=0.0;
            for(int count=bar; count<bar+10; count++) Range+=MathAbs(high[count]-low[count]);
            Range*=0.5/10;
            BearsAroonBuffer[bar]=high[bar]+Range;
           }

         LastTrend=-1;
         continue;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
