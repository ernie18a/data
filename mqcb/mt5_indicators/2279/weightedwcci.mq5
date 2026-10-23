//+------------------------------------------------------------------+
//|                                                 WeightedWCCI.mq5 |
//|                         Copyright © 2005, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//+------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2005, Luis Guilherme Damiani"
//--- a link to the website of the author
#property link "http://www.damianifx.com.br" 
#property description "The indicator draws the slow and fast ССI and colors bars for determining patterns and trends"
//--- indicator version
#property version   "1.01"
//--- drawing the indicator in a separate window
#property indicator_separate_window
//--- four buffers are used for indicator calculation and drawing
#property indicator_buffers 4
//--- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used as the indicator colors
#property indicator_color1  clrLime,clrRed
//--- displaying the indicator label
#property indicator_label1  "WeightedWCCI Signal"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator as a four-color histogram
#property indicator_type2 DRAW_COLOR_HISTOGRAM
//--- colors of the five-color histogram are as follows
#property indicator_color2 clrMagenta,clrViolet,clrGray,clrDeepSkyBlue,clrBlue
//--- Indicator line is a solid one
#property indicator_style2 STYLE_SOLID
//--- indicator line width is 2
#property indicator_width2 2
//--- displaying the indicator label
#property indicator_label2  "WeightedWCCI Stochastic"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint      FastCCI_Period=7;                 // Fast CCI period
input uint      SlowCCI_Period=13;                // Slow CCI period
input ENUM_APPLIED_PRICE   CCIPrice=PRICE_MEDIAN; // Price
input double    weight=1.0;                       // Weight
input uint      overbslevel=200.0;                // Extreme level
input uint      triglevel=50.0;                   // Trigger level
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
double UpBuffer[],DnBuffer[];
//--- declaration of integer variables for the start of data calculation
int min_rates_total,overbslevel50;
//--- declaration of integer variables for the indicators handles
int FsCCI_Handle,SlCCI_Handle,FsATR_Handle,SlATR_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- initialization of variables of data calculation start
   if(weight)
     {
      int FsATRPeriod=7;
      int SlATRPeriod=49;
      min_rates_total=int(MathMax(FsATRPeriod,SlATRPeriod));
      //--- Getting the handle of the ATR indicator
      FsATR_Handle=iATR(Symbol(),PERIOD_CURRENT,FsATRPeriod);
      if(FsATR_Handle==INVALID_HANDLE)
        {
         Print(" Failed to get handle of the ATR indicator");
         return(INIT_FAILED);
        }
//--- Getting the handle of the ATR indicator
      SlATR_Handle=iATR(Symbol(),PERIOD_CURRENT,SlATRPeriod);
      if(SlATR_Handle==INVALID_HANDLE)
        {
         Print(" Failed to get handle of the ATR indicator");
         return(INIT_FAILED);
        }
     }
   else min_rates_total=0;
   min_rates_total=int(MathMax(min_rates_total,MathMax(FastCCI_Period,SlowCCI_Period)));
   overbslevel50=int(overbslevel+50);
//--- getting the handle of the Fast iCCI indicator
   FsCCI_Handle=iCCI(Symbol(),PERIOD_CURRENT,FastCCI_Period,CCIPrice);
   if(FsCCI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the Fast iCCI indicator");
      return(INIT_FAILED);
     }
//--- getting the handle of the Slow iCCI indicator
   SlCCI_Handle=iCCI(Symbol(),PERIOD_CURRENT,SlowCCI_Period,CCIPrice);
   if(SlCCI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the Slow iCCI indicator");
      return(INIT_FAILED);
     }
//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,IndBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- Indexing buffer elements as timeseries
   ArraySetAsSeries(UpBuffer,true);
   ArraySetAsSeries(DnBuffer,true);
   ArraySetAsSeries(IndBuffer,true);
   ArraySetAsSeries(ColorIndBuffer,true);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"WeightedWCCI");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- the number of the horizontal levels of the indicator 4   
   IndicatorSetInteger(INDICATOR_LEVELS,5);
//--- values of the indicator horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+overbslevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,+triglevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,0.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,-triglevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,4,-overbslevel);
//--- select line colors
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrLime);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,4,clrRed);
//--- setting line styles
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASH);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,3,STYLE_DASH);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,4,STYLE_SOLID);
//--- selecting line width
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,4);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,1);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,2,1);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,3,1);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,4,4);
//--- initialization end
   return(INIT_SUCCEEDED);
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
//--- checking if the number of bars is enough for the calculation
   if((BarsCalculated(FsATR_Handle)<rates_total && weight)
      || (BarsCalculated(SlATR_Handle)<rates_total && weight)
      || BarsCalculated(FsCCI_Handle)<rates_total
      || BarsCalculated(SlCCI_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//--- declarations of local variables 
   int to_copy,limit,bar;
   double Kw,FsCCI[],SlCCI[],FsATR[],SlATR[];
//--- Calculations of the necessary number of copied data and limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars
   to_copy=limit+1;
//--- copy newly appeared data in the arrays
   if(CopyBuffer(FsATR_Handle,0,0,to_copy,FsATR)<=0) return(RESET);
   if(CopyBuffer(SlATR_Handle,0,0,to_copy,SlATR)<=0) return(RESET);
   if(CopyBuffer(FsCCI_Handle,0,0,to_copy,FsCCI)<=0) return(RESET);
   if(CopyBuffer(SlCCI_Handle,0,0,to_copy,SlCCI)<=0) return(RESET);
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(FsATR,true);
   ArraySetAsSeries(SlATR,true);
   ArraySetAsSeries(FsCCI,true);
   ArraySetAsSeries(SlCCI,true);
//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(weight)
        {
         if(!SlATR[bar]) continue;
         Kw=weight*FsATR[bar]/SlATR[bar];
         FsCCI[bar]*=Kw;
         SlCCI[bar]*=Kw;
        }
      //---
      FsCCI[bar]=MathMin(FsCCI[bar],+overbslevel50);
      SlCCI[bar]=MathMin(SlCCI[bar],+overbslevel50);
      FsCCI[bar]=MathMax(FsCCI[bar],-overbslevel50);
      SlCCI[bar]=MathMax(SlCCI[bar],-overbslevel50);
      //---
      IndBuffer[bar]=FsCCI[bar];
      UpBuffer[bar]=IndBuffer[bar];
      DnBuffer[bar]=SlCCI[bar];
     }
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//--- main cycle of the indicator coloring
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int clr=2;
      //---
      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar+1]) clr=4;
         if(IndBuffer[bar]<IndBuffer[bar+1]) clr=3;
        }
      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar+1]) clr=0;
         if(IndBuffer[bar]>IndBuffer[bar+1]) clr=1;
        }
      ColorIndBuffer[bar]=clr;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
