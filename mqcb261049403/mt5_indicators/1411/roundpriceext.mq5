//+------------------------------------------------------------------+
//|                                               RoundPrice-Ext.mq5 |
//|                                         Copyright © 2004, Tartan |
//|                http://forum.alpari-idc.ru/viewtopic.php?t=48186/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, Tartan"
#property link      "http://forum.alpari-idc.ru/viewtopic.php?t=48186/"
#property description ""
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 6
#property indicator_buffers 7
//---- seven plots are used
#property indicator_plots   7
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- gold color is used for the indicator line
#property indicator_color1 clrGold
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Line 1"
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- Red color is used for indicator line
#property indicator_color2 clrRed
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Line 2"
//+-----------------------------------+
//|  Indicator 3 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type3   DRAW_LINE
//---- Lime color is used as the color of the indicator line
#property indicator_color3 clrLime
//---- the indicator line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "Line 3"
//+-----------------------------------+
//|  Indicator 4 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type4   DRAW_LINE
//---- Aqua color is used as the color of the indicator line
#property indicator_color4 clrAqua
//---- the indicator line is a continuous curve
#property indicator_style4  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width4  1
//---- displaying the indicator label
#property indicator_label4  "Line 4"
//+-----------------------------------+
//| Indicator 5 drawing parameters    |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type5   DRAW_LINE
//---- blue color is used for the indicator line
#property indicator_color5 clrBlue
//---- the indicator line is a continuous curve
#property indicator_style5  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width5  1
//---- displaying the indicator label
#property indicator_label5  "Line 5"
//+-----------------------------------+
//|  Indicator 6 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type6   DRAW_LINE
//---- Magenta color is used for the indicator line
#property indicator_color6 clrMagenta
//---- the indicator line is a continuous curve
#property indicator_style6  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width6  1
//---- displaying the indicator label
#property indicator_label6  "Line 6"
//+-----------------------------------+
//|  Indicator 7 drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type7   DRAW_LINE
//---- Purple color is used as the color of the indicator line
#property indicator_color7 clrPurple
//---- the indicator line is a continuous curve
#property indicator_style7  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width7  1
//---- displaying the indicator label
#property indicator_label7  "Line 7"

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input double t3_period=8.0;
input double b=0.7;
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of dynamic arrays that further will be used as an indicator buffers
double e0Buffer[];
double e1Buffer[];
double e2Buffer[];
double e3Buffer[];
double e4Buffer[];
double e5Buffer[];
double e6Buffer[];
double c1,c2,c3,c4,n,w1,w2,b2,b3;
double dpo,t3;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//|  Indicator initialization                                        |
//+------------------------------------------------------------------+
void IndicatorInit
(
 uint   number,
 int    shift,
 uint   drawbegin,
 double empty_value,
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
   PlotIndexSetDouble(number,PLOT_EMPTY_VALUE,empty_value);
  }
//+------------------------------------------------------------------+   
//| RoundPrice-Ext indicator initialization function                 | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=2;
//----
   b2=b*b;
   b3=b2*b;
   c1=-b3;
   c2=(3*(b2+b3));
   c3=-3*(2*b2+b+b3);
   c4=(1+3*b+b3+3*b2);
   n=t3_period;
//----
   if(n<1) n=1;
   n=1+0.5*(n-1);
   w1=2/(n + 1);
   w2=1 - w1;

//---- Initialization of indicators
   IndicatorInit(0,Shift,min_rates_total,0,e0Buffer);
   IndicatorInit(1,Shift,min_rates_total,0,e1Buffer);
   IndicatorInit(2,Shift,min_rates_total,0,e2Buffer);
   IndicatorInit(3,Shift,min_rates_total,0,e3Buffer);
   IndicatorInit(4,Shift,min_rates_total,0,e4Buffer);
   IndicatorInit(5,Shift,min_rates_total,0,e5Buffer);
   IndicatorInit(6,Shift,min_rates_total,0,e6Buffer);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"RoundPrice-Ext");

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| RoundPrice-Ext iteration function                                | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[]     // price array for calculation of the indicator
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total+begin) return(0);

//---- Declaration of integer variables and getting the bars already calculated
   int first,bar;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=1+begin; // starting number for calculation of all bars
      //---- performing shift of the beginning of counting of drawing the indicators
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,first);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,first);
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,first);
      PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,first);
      PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,first);
      PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,first);
      PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,first);
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      dpo=price[bar];
      e1Buffer[bar]=w1*dpo + w2*e1Buffer[bar-1];
      e2Buffer[bar]=w1*e1Buffer[bar] + w2*e2Buffer[bar-1];
      e3Buffer[bar]=w1*e2Buffer[bar] + w2*e3Buffer[bar-1];
      e4Buffer[bar]=w1*e3Buffer[bar] + w2*e4Buffer[bar-1];
      e5Buffer[bar]=w1*e4Buffer[bar] + w2*e5Buffer[bar-1];
      e6Buffer[bar]=w1*e5Buffer[bar] + w2*e6Buffer[bar-1];
      //----
      t3=c1*e6Buffer[bar]+c2*e5Buffer[bar]+c3*e4Buffer[bar]+c4*e3Buffer[bar];
      //----
      if(!t3) t3=dpo;
      //----
      e0Buffer[bar]=t3;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
