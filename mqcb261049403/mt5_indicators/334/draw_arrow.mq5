//+------------------------------------------------------------------+
//|                                                   DRAW_ARROW.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "This indicator is a demo of DRAW_ARROW drawing style"
#property description "It draws arrows, defined by Unicode symbols"
#property description "The color, width, shift and symbol code changed randomly"
#property description "after N ticks"
#property description "Code of the base char : code=159 (circle)"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Arrows
#property indicator_label1  "Arrows"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_width1  1
//--- input parameters
input int      N=5;         // Ticks to change properties
input ushort   code=159;    // Code of the char to draw (DRAW_ARROW style)
//--- indicator buffer
double         ArrowsBuffer[];
//--- colors array
color colors[]={clrRed,clrBlue,clrGreen};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ArrowsBuffer,INDICATOR_DATA);
//--- define the code of the char to plot in PLOT_ARROW drawing style
   PlotIndexSetInteger(0,PLOT_ARROW,code);
//--- set vertical shift (in pixels)
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,5);
//--- set 0 as empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
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
      //--- change indicator properties
      ChangeLineAppearance();
      //--- set ticks to 0
      ticks=0;
     }

//--- calculations
   int start=1;
   if(prev_calculated>0) start=prev_calculated-1;
//--- set indicator values
   for(int i=1;i<rates_total;i++)
     {
      //--- if close>close of the previous bar, set arrow
      if(close[i]>close[i-1])
         ArrowsBuffer[i]=close[i];
      //--- overwise set zero
      else
         ArrowsBuffer[i]=0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Changes the indicator properties                                 |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- comment
   string comm="";
//--- color
   int number=MathRand(); // get random number
//--- get size of colors array
   int size=ArraySize(colors);
//--- select color index
   int color_index=number%size;
//--- set color as PLOT_LINE_COLOR property
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,colors[color_index]);
//--- add to comment
   comm=comm+"\r\n"+(string)colors[color_index];

//--- width
   number=MathRand();
//--- calculate line width
   int width=number%5;   // width vary from 0 to 4
//--- set width as PLOT_LINE_WIDTH property
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,width);
//--- add to comment
   comm=comm+"\r\nWidth="+IntegerToString(width);

//--- arrow code (PLOT_ARROW)
   number=MathRand();
//--- select new arrow code as a random value form 0 to 19
   int code_add=number%20;
//--- set new arrow code as a sum: code+code_add
   PlotIndexSetInteger(0,PLOT_ARROW,code+code_add);
//--- add to comment
   comm="\r\n"+"PLOT_ARROW="+IntegerToString(code+code_add)+comm;

//--- vertical arrow shift (in pixels)
   number=MathRand();
//--- calculate shift
   int shift=20-number%41;
//--- set new shift
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,shift);
//--- add shift to comment
   comm="\r\n"+"PLOT_ARROW_SHIFT="+IntegerToString(shift)+comm;

//--- show comment on the chart window
   Comment(comm);
  }
//+------------------------------------------------------------------+
