//+------------------------------------------------------------------+
//|                                         DRAW_COLOR_HISTOGRAM.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "This indicator is a demo of DRAW_COLOR_HISTOGRAM drawing style"
#property description "It plots a sin(x) function as a color histogram in a separate window"
#property description "The color and width are changed randomly after N ticks"
#property description "The bars parameter sets the period (in bars) of the sin(x) function"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- input parameters
input int      bars=30;          // Sin(x) period in bars
input int      N=5;              // Ticks to change properties
//--- plot Color_Histogram
#property indicator_label1  "Color_Histogram"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//--- set 8 colors
#property indicator_color1  clrRed,clrGreen,clrBlue,clrYellow,clrMagenta,clrCyan,clrMediumSeaGreen,clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator data buffer
double         Color_HistogramBuffer[];
//--- color buffer
double         Color_HistogramColors[];
//--- additional variables
double         multiplier;
int            color_sections;
//--- colors array
color colors[]=
  {
   clrRed,clrBlue,clrGreen,clrChocolate,clrMagenta,clrDodgerBlue,clrGoldenrod,
   clrIndigo,clrLightBlue,clrAliceBlue,clrMoccasin,clrWhiteSmoke,clrCyan,clrMediumPurple
  };
//--- line styles array
ENUM_LINE_STYLE styles[]={STYLE_SOLID,STYLE_DASH,STYLE_DOT,STYLE_DASHDOT,STYLE_DASHDOTDOT};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Color_HistogramBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,Color_HistogramColors,INDICATOR_COLOR_INDEX);
//---- colors
   color_sections=8;   //
//--- calc multiplier
   if(bars>1)multiplier=2.*M_PI/bars;
   else
     {
      PrintFormat("The bars should be greater than 1. bars=%d",bars);
      //--- exit
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
      //--- change colors
      ChangeColors(colors,color_sections);
      //--- set ticks counter to 0
      ticks=0;
     }

//--- calculate indicator values
   int start=0;
//--- if not first call, set starting index
   if(prev_calculated>0) start=prev_calculated-1; // set starting bar
//--- filling the buffer with values
   for(int i=start;i<rates_total;i++)
     {
      //--- set value
      Color_HistogramBuffer[i]=sin(i*multiplier);
      //--- set color index
      int color_index=i%(bars*color_sections);
      color_index/=bars;
      Color_HistogramColors[i]=color_index;
     }
//--- return prev_calculated for the next call of the function
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Changes the colors                                              |
//+------------------------------------------------------------------+
void  ChangeColors(color  &cols[],int plot_colors)
  {
//--- total colors
   int size=ArraySize(cols);
//--- 
   string comm=ChartGetString(0,CHART_COMMENT)+"\r\n\r\n";

//--- set new color for each color index
   for(int plot_color_ind=0;plot_color_ind<plot_colors;plot_color_ind++)
     {
      //--- get random number
      int number=MathRand();
      //--- get color index
      int i=number%size;
      //--- set color as PLOT_LINE_COLOR property
      PlotIndexSetInteger(0,                    //  plotting style index
                          PLOT_LINE_COLOR,      //  property identifier
                          plot_color_ind,       //  color index
                          cols[i]);             //  new color
      //--- add to comment
      comm=comm+StringFormat("HistogramColorIndex[%d]=%s \r\n",plot_color_ind,ColorToString(cols[i],true));
      ChartSetString(0,CHART_COMMENT,comm);
     }
//---
  }
//+------------------------------------------------------------------+
//| Change properties of the histogram                               |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- comment
   string comm="";
//--- line width
   int number=MathRand();
//--- define width
   int width=number%5; // width vary from 0 to 4
//--- set width as PLOT_LINE_WIDTH property
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,width);
//--- add to comment
   comm=comm+" Width="+IntegerToString(width);

//--- line styles
   number=MathRand();
//--- total styles
   int size=ArraySize(styles);
//--- select style index
   int style_index=number%size;
//--- set line style as PLOT_LINE_STYLE property
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,styles[style_index]);
//--- add to comment
   comm=EnumToString(styles[style_index])+", "+comm;
//--- print comment
   Comment(comm);
  }
//+------------------------------------------------------------------+
