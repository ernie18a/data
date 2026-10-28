//+------------------------------------------------------------------+
//|                                               Ind-Fractals-1.mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
#property description "Fractals of different time periods on one chart"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- number of indicator buffers is 8
#property indicator_buffers 8 
//--- 8 graphical plots are used
#property indicator_plots   8
//+--------------------------------------------+
//|  Parameters of indicator drawing   |
//+--------------------------------------------+
//--- drawing the fractals as symbols
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_type3   DRAW_ARROW
#property indicator_type4   DRAW_ARROW
#property indicator_type5   DRAW_ARROW
#property indicator_type6   DRAW_ARROW
#property indicator_type7   DRAW_ARROW
#property indicator_type8   DRAW_ARROW
//--- select the colors of the fractals
#property indicator_color1  clrLime
#property indicator_color2  clrLime
#property indicator_color3  clrRed
#property indicator_color4  clrRed
#property indicator_color5  clrBlue
#property indicator_color6  clrBlue
#property indicator_color7  clrMagenta
#property indicator_color8  clrMagenta
//--- the width of fractals
#property indicator_width1  5
#property indicator_width2  5
#property indicator_width3  3
#property indicator_width4  3
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  1
#property indicator_width8  1
//+--------------------------------------------+
//| declaration of constants                   |
//+--------------------------------------------+
#define RESET 0     // A constant for returning the indicator recalculation command to the terminal
//+--------------------------------------------+
//| Indicator input parameters                 |
//+--------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame4=PERIOD_H4;        // 4 indicator chart period
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_H1;        // 3 indicator chart period
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_M30;       // 2 indicator chart period
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_M15;       // 1 indicator chart period
input int Shift=0;                                 // Horizontal shift of the indicator in bars
//+--------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as Bollinger Bands indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[];
double ExtLineBuffer5[],ExtLineBuffer6[],ExtLineBuffer7[],ExtLineBuffer8[];
//--- declaration of integer variables for the indicators handles
int ATR_Handle;
//--- declaration of integer variables for the start of data calculation
int min_rates_total,min_rates_;
//+------------------------------------------------------------------+
//|  Getting string timeframe                                |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- initialization of global variables    
   ENUM_TIMEFRAMES MaxTimeFrame=MathMax(MathMax(MathMax(TimeFrame1,TimeFrame2),TimeFrame3),TimeFrame4);  
   int res=PeriodSeconds(MaxTimeFrame)/PeriodSeconds(PERIOD_CURRENT);
   min_rates_=int(res*2+MathCeil(res/2));
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,min_rates_));
//--- Getting the handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(INIT_FAILED);
     }
//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer6,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer7,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer8,INDICATOR_DATA);
//--- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
//--- create labels to display in Data Window
   PlotIndexSetString(0,PLOT_LABEL,"Up Fractals("+GetStringTimeframe(TimeFrame4)+")");
   PlotIndexSetString(1,PLOT_LABEL,"Dn Fractals("+GetStringTimeframe(TimeFrame4)+")");
   PlotIndexSetString(2,PLOT_LABEL,"Up Fractals("+GetStringTimeframe(TimeFrame3)+")");
   PlotIndexSetString(3,PLOT_LABEL,"Dn Fractals("+GetStringTimeframe(TimeFrame3)+")");
   PlotIndexSetString(4,PLOT_LABEL,"Up Fractals("+GetStringTimeframe(TimeFrame2)+")");
   PlotIndexSetString(5,PLOT_LABEL,"Dn Fractals("+GetStringTimeframe(TimeFrame2)+")");
   PlotIndexSetString(6,PLOT_LABEL,"Up Fractals("+GetStringTimeframe(TimeFrame1)+")");
   PlotIndexSetString(7,PLOT_LABEL,"Dn Fractals("+GetStringTimeframe(TimeFrame1)+")");
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(2,PLOT_ARROW,159);
   PlotIndexSetInteger(3,PLOT_ARROW,159);
   PlotIndexSetInteger(4,PLOT_ARROW,159);
   PlotIndexSetInteger(5,PLOT_ARROW,159);
   PlotIndexSetInteger(6,PLOT_ARROW,159);
   PlotIndexSetInteger(7,PLOT_ARROW,159);
//---- Indexing buffer elements as timeseries
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(ExtLineBuffer3,true);
   ArraySetAsSeries(ExtLineBuffer4,true);
   ArraySetAsSeries(ExtLineBuffer5,true);
   ArraySetAsSeries(ExtLineBuffer6,true);
   ArraySetAsSeries(ExtLineBuffer7,true);
   ArraySetAsSeries(ExtLineBuffer8,true);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Ind-Fractals-1");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator function                                        | 
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- declarations of local variables 
   int to_copy,limit,bar;
   double ATR[];
//--- Calculating the required amount of data to copy
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated+min_rates_; // starting index for the calculation of new bars
     }
   to_copy=limit+1;
//---- copy newly appeared data in the ATR[] array
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtLineBuffer1[bar]=EMPTY_VALUE;
      ExtLineBuffer2[bar]=EMPTY_VALUE;
      ExtLineBuffer3[bar]=EMPTY_VALUE;
      ExtLineBuffer4[bar]=EMPTY_VALUE;
      ExtLineBuffer5[bar]=EMPTY_VALUE;
      ExtLineBuffer6[bar]=EMPTY_VALUE;
      ExtLineBuffer7[bar]=EMPTY_VALUE;
      ExtLineBuffer8[bar]=EMPTY_VALUE;
      //---
      if(FindUpFractal(rates_total,TimeFrame1,high,bar)) ExtLineBuffer1[bar]=high[bar]+ATR[bar]*3/8;
      if(FindDnFractal(rates_total,TimeFrame1,low,bar)) ExtLineBuffer2[bar]=low[bar]-ATR[bar]*3/8;
      //---
      if(FindUpFractal(rates_total,TimeFrame2,high,bar)) ExtLineBuffer3[bar]=high[bar]+ATR[bar]*3/8;
      if(FindDnFractal(rates_total,TimeFrame2,low,bar)) ExtLineBuffer4[bar]=low[bar]-ATR[bar]*3/8;
      //---
      if(FindUpFractal(rates_total,TimeFrame3,high,bar)) ExtLineBuffer5[bar]=high[bar]+ATR[bar]*3/8;
      if(FindDnFractal(rates_total,TimeFrame3,low,bar)) ExtLineBuffer6[bar]=low[bar]-ATR[bar]*3/8;
      //---
      if(FindUpFractal(rates_total,TimeFrame4,high,bar)) ExtLineBuffer7[bar]=high[bar]+ATR[bar]*3/8;
      if(FindDnFractal(rates_total,TimeFrame4,low,bar)) ExtLineBuffer8[bar]=low[bar]-ATR[bar]*3/8;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
//| FindUpFractal                                                    | 
//+------------------------------------------------------------------+  
bool FindUpFractal(int Bars_,ENUM_TIMEFRAMES period,const double &High[],int index)
  {
//--- 
   int res=PeriodSeconds(period)/PeriodSeconds(PERIOD_CURRENT);
   int Per=int(res*2+MathCeil(res/2));
   if(index<Per || index>Bars_-Per) return(false);

   for(int iii=1; iii<=Per; iii++)
     {
      if(index+iii>=Bars_ || index-iii<0) return(false);
      if(High[index+iii]>High[index]) return(false);
      if(High[index-iii]>=High[index]) return(false);
     }
//--- 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| FindDnFractal                                                    | 
//+------------------------------------------------------------------+  
bool FindDnFractal(int Bars_,ENUM_TIMEFRAMES period,const double &Low[],int index)
  {
//--- 
   int res=PeriodSeconds(period)/PeriodSeconds(PERIOD_CURRENT);
   int Per=int(res*2+MathCeil(res/2));
   if(index<Per || index>Bars_-Per) return(false);

   for(int iii=1; iii<=Per; iii++)
     {
      if(index+iii>=Bars_ || index-iii<0) return(false);
      if(Low[index+iii]<Low[index]) return(false);
      if(Low[index-iii]<=Low[index]) return(false);
     }
//--- 
   return(true);
  }
//+------------------------------------------------------------------+
