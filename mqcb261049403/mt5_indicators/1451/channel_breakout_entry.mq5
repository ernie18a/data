//+------------------------------------------------------------------+
//|                                       channel_breakout_entry.mq5 | 
//|                                       Copyright © 2009, darmasdt | 
//|                                          http://indotraders.org/ | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, darmasdt"
#property link "http://indotraders.org/"
#property description ""
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 8
#property indicator_buffers 8 
//---- only 8 graphical plots are used
#property indicator_plots   8

//+--------------------------------------------+
//|  BB levels indicator drawing parameters    |
//+--------------------------------------------+
//---- drawing the levels as lines
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
//---- selection of levels colors
#property indicator_color1 clrDarkGray
#property indicator_color2 clrDarkGray
#property indicator_color3 clrDodgerBlue
#property indicator_color4 clrDodgerBlue
#property indicator_color5 clrTomato
#property indicator_color6 clrTomato
#property indicator_color7 clrLightSkyBlue
#property indicator_color8 clrPlum
//---- Bollinger Bands are continuous curves
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_SOLID
#property indicator_style7 STYLE_SOLID
#property indicator_style8 STYLE_SOLID
//---- Bollinger Bands width is equal to 1
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  1
//---- display the labels of Bollinger Bands levels
#property indicator_label1  "trailing_Up"
#property indicator_label2  "trailing_Dn"
#property indicator_label3  "sys1_Up"
#property indicator_label4  "sys1_Dn"
#property indicator_label5  "failsafe_Up"
#property indicator_label6  "failsafe_Dn"
#property indicator_label7  "Sys 1 Stp"
#property indicator_label8  "Sys 2 Stp"

//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint Range1=10;
input uint Range2=20;
input uint Range3=55;
input double atr_factor=2;
input int atr_range=14;
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of dynamic arrays that will further be 
//---- will be used as channel_breakout_entry indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[];
double ExtLineBuffer5[],ExtLineBuffer6[],ExtLineBuffer7[],ExtLineBuffer8[];

//---- Declaration of integer variables for the indicator handles
int ATR_Handle;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+   
//| channel_breakout_entry indicator initialization function         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(MathMax(MathMax(Range1,atr_factor),Range2),Range3));

//---- getting the ATR indicator handle
   ATR_Handle=iATR(NULL,0,atr_range);
   if(ATR_Handle==INVALID_HANDLE)Print(" Failed to get handle of the ATR indicator");

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer6,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer7,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer8,INDICATOR_DATA);
//---- set the position, from which the levels drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(ExtLineBuffer3,true);
   ArraySetAsSeries(ExtLineBuffer4,true);
   ArraySetAsSeries(ExtLineBuffer5,true);
   ArraySetAsSeries(ExtLineBuffer6,true);
   ArraySetAsSeries(ExtLineBuffer7,true);
   ArraySetAsSeries(ExtLineBuffer8,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"channel_breakout_entry(",Range1,",",Range2,",",Range3,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| channel_breakout_entry iteration function                        | 
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of variables with a floating point  
   double ATR[];
//---- declaration of local variables 
   int limit,to_copy,bar;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-2; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars 
   to_copy=limit+2;

//---- copy newly appeared data in the SAR array
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtLineBuffer1[bar]=high[ArrayMaximum(high,bar,Range1)];
      ExtLineBuffer2[bar]=low[ArrayMinimum(low,bar,Range1)];
      ExtLineBuffer3[bar]=high[ArrayMaximum(high,bar,Range2)];
      ExtLineBuffer4[bar]=low[ArrayMinimum(low,bar,Range2)];
      ExtLineBuffer5[bar]=high[ArrayMaximum(high,bar,Range3)];
      ExtLineBuffer6[bar]=low[ArrayMinimum(low,bar,Range3)];

      if(high[bar+1]<=ExtLineBuffer3[bar+1] && high[bar]>ExtLineBuffer3[bar])
        {
         ExtLineBuffer7[bar]=ExtLineBuffer3[bar]-(ATR[bar+1]*atr_factor);
        }
      if(high[bar+1]<=ExtLineBuffer5[bar+1] && high[bar]>ExtLineBuffer5[bar])
        {
         ExtLineBuffer8[bar]=ExtLineBuffer5[bar]-(ATR[bar+1]*atr_factor);
        }
      if(low[bar+1]>=ExtLineBuffer4[bar+1] && low[bar]<ExtLineBuffer4[bar])
        {
         ExtLineBuffer7[bar]=ExtLineBuffer4[bar]+(ATR[bar+1]*atr_factor);
        }
      if(low[bar+1]>=ExtLineBuffer6[bar+1] && ExtLineBuffer6[bar])
        {
         ExtLineBuffer8[bar]=ExtLineBuffer6[bar]+(ATR[bar+1]*atr_factor);
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
