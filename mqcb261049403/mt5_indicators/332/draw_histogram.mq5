//+------------------------------------------------------------------+
//|                                               DRAW_HISTOGRAM.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "This indicator is a demo of DRAW_HISTOGRAM drawing style"
#property description "It plots a graph of the sin(x) function in the separate window"
#property description "The color and width of the histogram changes randomly"
#property description "each N ticks"
#property description "The period of sin(x) is defined by bars input parameter"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Histogram
#property indicator_label1  "Histogram"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      bars=30;          // Period of Sin(x) in bars
input int      N=5;              // Number of ticks to change color/style
//--- indicator buffers
double         HistogramBuffer[];
//--- used for the calculations
double    multiplier;
//--- colors array
color colors[]={clrRed,clrBlue,clrGreen};
//--- line styles array
ENUM_LINE_STYLE styles[]={STYLE_SOLID,STYLE_DASH,STYLE_DOT,STYLE_DASHDOT,STYLE_DASHDOTDOT};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,HistogramBuffer,INDICATOR_DATA);
//--- calculate multiplier
   if(bars>1)multiplier=2.*M_PI/bars;
   else
     {
      PrintFormat("Invalid value: bars=%d. It must be >1",bars);
      //--- return
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   return(INIT_SUCCEEDED);
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
   static int ticks=0;
//--- count the ticks
   ticks++;
//--- if ticks>=N
   if(ticks>=N)
     {
      //--- change histogram properties
      ChangeLineAppearance();
      //--- set tick counter to 0
      ticks=0;
     }

//--- calc indicator values
   int start=0;
//--- if not first call, start from the prevous bar
   if(prev_calculated>0) start=prev_calculated-1;
//--- fill the indicator buffer with values
   for(int i=start;i<rates_total;i++)
     {
      HistogramBuffer[i]=sin(i*multiplier);
     }
//--- return as prev_calculated in the next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Changes histogram color/style                                    |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- comment
   string comm="";
//--- histogram color
   int number=MathRand(); // get random number
//--- get size of the colors array
   int size=ArraySize(colors);
//--- calc color index
   int color_index=number%size;
//--- set color
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,colors[color_index]);
//--- add to comment
   comm=comm+"\r\n"+(string)colors[color_index];

//--- histogram width
   number=MathRand();
//--- calc width
   int width=number%5;   // width vary from 0 to 4
//--- set width
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,width);
//--- add to comment
   comm=comm+"\r\nWidth="+IntegerToString(width);

//--- histogram line style
   number=MathRand();
//--- get size of the styles array
   size=ArraySize(styles);
//--- calc index
   int style_index=number%size;
//--- set line style
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,styles[style_index]);
//--- add to comment
   comm="\r\n"+EnumToString(styles[style_index])+""+comm;
//--- show comment on the chart
   Comment(comm);
  }
//+------------------------------------------------------------------+
