//+------------------------------------------------------------------+
//|                                            ytg_Japan_Candles.mq5 |
//|                                   Copyright © 2009, Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Yuriy Tokman"
#property link      "yuriytokman@gmail.com"
#property description "Indicator of candle combinations"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- 9 buffers are used for calculation and drawing the indicator
#property indicator_buffers 9
//---- 9 plots are used
#property indicator_plots   9
//+----------------------------------------------+
//| Indicators drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicators as labels
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_type3   DRAW_ARROW
#property indicator_type4   DRAW_ARROW
#property indicator_type5   DRAW_ARROW
#property indicator_type6   DRAW_ARROW
#property indicator_type7   DRAW_ARROW
#property indicator_type8   DRAW_ARROW
#property indicator_type9   DRAW_ARROW
//---- the following colors are used for the indicators
#property indicator_color1  clrLime
#property indicator_color2  clrLime
#property indicator_color3  clrLime
#property indicator_color4  clrLime
#property indicator_color5  clrBlue
#property indicator_color6  clrMagenta
#property indicator_color7  clrMagenta
#property indicator_color8  clrMagenta
#property indicator_color9  clrMagenta
//---- width of the indicator lines
#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  3
#property indicator_width4  3
#property indicator_width5  3
#property indicator_width6  3
#property indicator_width7  3
#property indicator_width8  3
#property indicator_width9  3
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Bull's hammer"
#property indicator_label2  "Bull's absorbtion"
#property indicator_label3  "Bull's curtain of dark clouds"
#property indicator_label4  "Bull's clearance in the clouds"
#property indicator_label5  "Dodge"
#property indicator_label6  "Bear's clearance in the clouds"
#property indicator_label7  "Bear's curtain of dark clouds"
#property indicator_label8  "Bear's absorbtion"
#property indicator_label9  "Bear's hammer"

//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//|  INDICATOR INPUT PARAMETERS                  |
//+----------------------------------------------+
input int Shift=0; // horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer1[];
double IndBuffer2[];
double IndBuffer3[];
double IndBuffer4[];
double IndBuffer5[];
double IndBuffer6[];
double IndBuffer7[];
double IndBuffer8[];
double IndBuffer9[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=2;

//---- initialization of indicators
   IndicatorInit(0,Shift,min_rates_total,EMPTY_VALUE,170,IndBuffer1);
   IndicatorInit(1,Shift,min_rates_total,EMPTY_VALUE,110,IndBuffer2);
   IndicatorInit(2,Shift,min_rates_total,EMPTY_VALUE,116,IndBuffer3);
   IndicatorInit(3,Shift,min_rates_total,EMPTY_VALUE,163,IndBuffer4);
   IndicatorInit(4,Shift,min_rates_total,EMPTY_VALUE,174,IndBuffer5);
   IndicatorInit(5,Shift,min_rates_total,EMPTY_VALUE,163,IndBuffer6);
   IndicatorInit(6,Shift,min_rates_total,EMPTY_VALUE,116,IndBuffer7);
   IndicatorInit(7,Shift,min_rates_total,EMPTY_VALUE,110,IndBuffer8);
   IndicatorInit(8,Shift,min_rates_total,EMPTY_VALUE,170,IndBuffer9);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"ytg_Japan_Candles");

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//|  Indicator initialization                                        |
//+------------------------------------------------------------------+
void IndicatorInit
(
 uint   number,
 int    shift,
 uint   drawbegin,
 double empty_value,
 uint   arrow,
 double &Arrow[]
 )
//---- 
  {
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(number,Arrow,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(number,PLOT_SHIFT,shift);
//---- shifting the starting point for drawing indicator by min_rates_total
   PlotIndexSetInteger(number,PLOT_DRAW_BEGIN,drawbegin);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(number,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indicator symbol
   PlotIndexSetInteger(number,PLOT_ARROW,arrow);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double& High[],     // price array of maximums of price for the calculation of indicator
                const double& Low[],      // price array of minimums of price for the calculation of indicator
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int first,bar;
   double k;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=min_rates_total-1; // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      IndBuffer1[bar]=EMPTY_VALUE;
      IndBuffer2[bar]=EMPTY_VALUE;
      IndBuffer3[bar]=EMPTY_VALUE;
      IndBuffer4[bar]=EMPTY_VALUE;
      IndBuffer5[bar]=EMPTY_VALUE;
      IndBuffer6[bar]=EMPTY_VALUE;
      IndBuffer7[bar]=EMPTY_VALUE;
      IndBuffer8[bar]=EMPTY_VALUE;
      IndBuffer9[bar]=EMPTY_VALUE;

      k=(High[bar]-Low[bar])/3;

      if(Open[bar]>Low[bar]+2*k && Close[bar]>Low[bar]+2*k) IndBuffer9[bar]=High[bar]+10*_Point;
      if(Open[bar]<High[bar]-2*k && Close[bar]<High[bar]+2*k) IndBuffer1[bar]=Low[bar]-10*_Point;

      if(Open[bar-1]>Close[bar-1] && Close[bar-1]>Open[bar] && Close[bar]>Open[bar-1]) IndBuffer2[bar]=Low[bar]-15*_Point;
      if(Close[bar-1]>Open[bar-1] && Open[bar]>Close[bar-1] && Open[bar-1]>Close[bar]) IndBuffer8[bar]=High[bar]+15*_Point;

      if(Open[bar-1]<Close[bar-1] && Open[bar]>High[bar-1] && Close[bar]<Open[bar-1]+(Close[bar-1]-Open[bar-1])/2)
         IndBuffer3[bar]=Low[bar]-25*_Point;

      if(Open[bar-1]>Close[bar-1] && Open[bar]<Low[bar-1] && Close[bar]<Open[bar-1]+(Close[bar-1]-Open[bar-1])/2)
         IndBuffer7[bar]=High[bar]+25*_Point;

      if(Open[bar-1]>Close[bar-1] && High[bar-1]>Open[bar] && Close[bar]>Close[bar-1]+(Open[bar-1]-Close[bar-1])/2)
         IndBuffer4[bar]=Low[bar]-25*_Point;

      if(Open[bar-1]<Close[bar-1] && Low[bar-1]<Open[bar] && Close[bar]<Close[bar-1]+(Open[bar-1]-Close[bar-1])/2)
         IndBuffer6[bar]=High[bar]+25*_Point;

      if(Open[bar]==Close[bar]) IndBuffer5[bar]=High[bar]+30*_Point;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
