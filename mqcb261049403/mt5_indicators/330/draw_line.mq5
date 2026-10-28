//+------------------------------------------------------------------+
//|                                                    DRAW_LINE.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "This indicator is a demo of DRAW_LINE drawing style"
#property description "It plots a line using the close prices of the bars"
#property description "The line color, width and style changes"
#property description "every N ticks"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- the line properties is defined using the compiler directives
#property indicator_label1  "Line"      // indicator label (in "Data Window")
#property indicator_type1   DRAW_LINE   // drawing style as a line
#property indicator_color1  clrRed      // line color
#property indicator_style1  STYLE_SOLID // line style
#property indicator_width1  1           // line width
//--- input parameters
input int      N=5;         // Number of ticks to change line properties
//--- indicator buffer
double         LineBuffer[];
//--- colors array
color colors[]={clrRed,clrBlue,clrGreen};
//--- line styles array
ENUM_LINE_STYLE styles[]={STYLE_SOLID,STYLE_DASH,STYLE_DOT,STYLE_DASHDOT,STYLE_DASHDOTDOT};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set index buffer
   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
//--- initialization of random numbers generator
   MathSrand(GetTickCount());
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
//--- count the ticks (used to change the style, color and width of the line)
   ticks++;
//--- if ticks>N
   if(ticks>=N)
     {
      //--- change line properties
      ChangeLineAppearance();
      //--- set ticks counter to zero
      ticks=0;
     }

//--- calculating indicator values
   for(int i=0;i<rates_total;i++)
     {
      LineBuffer[i]=close[i];
     }

//--- return prev_calculated for the next call of the function
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Changes the line properties                                      |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- comment
   string comm="";
//--- line color
//--- get random number
   int number=MathRand();
//--- size of colors array
   int size=ArraySize(colors);
//--- new color index
   int color_index=number%size;
//--- set line color
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,colors[color_index]);
//--- add line color
   comm=comm+(string)colors[color_index];

//--- line width
   number=MathRand();
//--- new line width
   int width=number%5; // line with vary fromn 0 to 4
//--- set PLOT_LINE_WIDTH property
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,width);
//--- add line width
   comm=comm+", Width="+IntegerToString(width);

//--- line style
   number=MathRand();
//--- size of styles array
   size=ArraySize(styles);
//--- new style index
   int style_index=number%size;
//--- set line style as PLOT_LINE_STYLE property
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,styles[style_index]);
//--- add to comment
   comm=EnumToString(styles[style_index])+", "+comm;
//--- show comment
   Comment(comm);
  }
//+------------------------------------------------------------------+
