//+------------------------------------------------------------------+
//|                                                        Vegas.mq5 | 
//|                                         Copyright © 2007, Mr.Bah | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Mr.Bah"
#property link ""
#property description ""
//--- Indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- number of indicator buffers is 8
#property indicator_buffers 8 
//--- 8 graphical plots are used
#property indicator_plots   8
//+--------------------------------------------+
//|  Indicator level drawing parameters        |
//+--------------------------------------------+
//--- drawing the levels as lines
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
//--- selection of level colors
#property indicator_color1  clrDarkSlateGray
#property indicator_color2  clrPurple
#property indicator_color3  clrRed
#property indicator_color4  clrBlue
#property indicator_color5  clrMagenta
#property indicator_color6  clrRed
#property indicator_color7  clrPurple
#property indicator_color8  clrDarkSlateGray
//--- levels are dott-dash curves
#property indicator_style1 STYLE_DASHDOTDOT
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
//--- levels are solid curves
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
//--- levels are dott-dash curves
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
#property indicator_style8 STYLE_DASHDOTDOT
//--- levels width is equal to 1
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
//--- levels width is equal to 2
#property indicator_width4  2
#property indicator_width5  2
//--- levels width is equal to 1
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  1
//--- displaying labels of the levels
#property indicator_label1  "+Level 3"
#property indicator_label2  "+Level 2"
#property indicator_label3  "+Level 1"
#property indicator_label4  "Fast MA"
#property indicator_label5  "Slow MA"
#property indicator_label6  "-Level 1"
#property indicator_label7  "-Level 2"
#property indicator_label8  "-Level 3"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0 // a constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Mode //Type of constant
  {
   Mode_1 = 1,     //1
   Mode_2,         //2
   Mode_3,         //3
   Mode_4          //4
  };
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint Step=10;
input Mode RiskModel=Mode_1;
input uint FastPeriod=100;
input uint SlowPeriod=169;
input ENUM_MA_METHOD   MAType=MODE_EMA;
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE;
input int Shift=0;                          // Horizontal shift of the indicator in bars
//+-----------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as Bollinger Bands indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[];
double ExtLineBuffer5[],ExtLineBuffer6[],ExtLineBuffer7[],ExtLineBuffer8[];
//--- declaration of the average vertical shift value variable
double dRange;
//--- declaration of integer variables of data starting point
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int fMA_Handle,sMA_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(FastPeriod,SlowPeriod));
   dRange=Step*_Point;
//--- getting the handle of the iMA 1 indicator
   fMA_Handle=iMA(NULL,0,FastPeriod,0,MAType,MAPrice);
   if(fMA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of iMA 1");
      return(INIT_FAILED);
     }
//--- getting the handle of the iMA 2 indicator
   sMA_Handle=iMA(NULL,0,SlowPeriod,0,MAType,MAPrice);
   if(sMA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of iMA 2");
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
//--- set the position, from which the levels drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(ExtLineBuffer3,true);
   ArraySetAsSeries(ExtLineBuffer4,true);
   ArraySetAsSeries(ExtLineBuffer5,true);
   ArraySetAsSeries(ExtLineBuffer6,true);
   ArraySetAsSeries(ExtLineBuffer7,true);
   ArraySetAsSeries(ExtLineBuffer8,true);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Vegas");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(fMA_Handle)<rates_total
      || BarsCalculated(sMA_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//--- declaration of variables with a floating point  
   double;
//--- declaration of integer variables
   int to_copy,limit,bar;
//--- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated;  // starting index for the calculation of the new bars only
//--- copy newly appeared data in the arrays
   to_copy=limit+1;
   if(CopyBuffer(fMA_Handle,0,0,to_copy,ExtLineBuffer4)<=0) return(RESET);
   if(CopyBuffer(sMA_Handle,0,0,to_copy,ExtLineBuffer5)<=0) return(RESET);
//--- main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      switch(RiskModel)
        {
         case  Mode_1:
            ExtLineBuffer3[bar]=ExtLineBuffer5[bar]+34*dRange;
            ExtLineBuffer2[bar]=ExtLineBuffer5[bar]+55*dRange;
            ExtLineBuffer1[bar]=ExtLineBuffer5[bar]+89*dRange;
            ExtLineBuffer6[bar]=ExtLineBuffer5[bar]-34*dRange;
            ExtLineBuffer7[bar]=ExtLineBuffer5[bar]-55*dRange;
            ExtLineBuffer8[bar]=ExtLineBuffer5[bar]-89*dRange;
            break;
         case  Mode_2:
            ExtLineBuffer3[bar]=ExtLineBuffer5[bar]+55*dRange;
            ExtLineBuffer2[bar]=ExtLineBuffer5[bar]+89*dRange;
            ExtLineBuffer1[bar]=ExtLineBuffer5[bar]+144*dRange;
            ExtLineBuffer6[bar]=ExtLineBuffer5[bar]-55*dRange;
            ExtLineBuffer7[bar]=ExtLineBuffer5[bar]-88*dRange;
            ExtLineBuffer8[bar]=ExtLineBuffer5[bar]-144*dRange;
            break;
         case  Mode_3:
            ExtLineBuffer3[bar]=ExtLineBuffer5[bar]+89*dRange;
            ExtLineBuffer2[bar]=ExtLineBuffer5[bar]+144*dRange;
            ExtLineBuffer1[bar]=ExtLineBuffer5[bar]+233*dRange;
            ExtLineBuffer6[bar]=ExtLineBuffer5[bar]-89*dRange;
            ExtLineBuffer7[bar]=ExtLineBuffer5[bar]-144*dRange;
            ExtLineBuffer8[bar]=ExtLineBuffer5[bar]-233*dRange;
            break;
         case  Mode_4:
            ExtLineBuffer3[bar]=ExtLineBuffer5[bar]+144*dRange;
            ExtLineBuffer2[bar]=ExtLineBuffer5[bar]+233*dRange;
            ExtLineBuffer1[bar]=ExtLineBuffer5[bar]+377*dRange;
            ExtLineBuffer6[bar]=ExtLineBuffer5[bar]-144*dRange;
            ExtLineBuffer7[bar]=ExtLineBuffer5[bar]-233*dRange;
            ExtLineBuffer8[bar]=ExtLineBuffer5[bar]-377*dRange;
            break;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
