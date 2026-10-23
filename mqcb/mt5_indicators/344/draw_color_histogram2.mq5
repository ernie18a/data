//+------------------------------------------------------------------+
//|                                        DRAW_COLOR_HISTOGRAM2.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "This indicator is a demo of DRAW_COLOR_HISTOGRAM2 drawing style"
#property description "For each bar it plots a section between the Open and Close prices"
#property description "The colors, width and line style are changed randomly after N ticks"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot ColorHistogram_2
#property indicator_label1  "ColorHistogram_2"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---  5 colors
#property indicator_color1  clrRed,clrBlue,clrGreen,clrYellow,clrMagenta
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameter
input int      N=5;              // Number of ticks to change histogram properties
int            color_sections;
//--- indicator buffers
double         ColorHistogram_2Buffer1[];
double         ColorHistogram_2Buffer2[];
//--- color buffer
double         ColorHistogram_2Colors[];
//--- colors array (14 colors)
color colors[]=
  {
   clrRed,clrBlue,clrGreen,clrChocolate,clrMagenta,clrDodgerBlue,clrGoldenrod,
   clrIndigo,clrLightBlue,clrAliceBlue,clrMoccasin,clrWhiteSmoke,clrCyan,clrMediumPurple
  };
//--- styles array
ENUM_LINE_STYLE styles[]={STYLE_SOLID,STYLE_DASH,STYLE_DOT,STYLE_DASHDOT,STYLE_DASHDOTDOT};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ColorHistogram_2Buffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ColorHistogram_2Buffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ColorHistogram_2Colors,INDICATOR_COLOR_INDEX);
//--- set empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- colors
   color_sections=8;   //
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
//--- count ticks to change histogram properties
   ticks++;
//--- if ticks>=N
   if(ticks>=N)
     {
      //--- change histogram properties
      ChangeLineAppearance();
      //--- change colors
      ChangeColors(colors,color_sections);      
      //--- set counter to 0
      ticks=0;
     }

//--- indicator calculations
   int start=0;
//--- used to determine the week day of the bar
   MqlDateTime dt;
//--- set starting index
   if(prev_calculated>0) start=prev_calculated-1; // from the previous bar
//--- fill indicator buffers with values
   for(int i=start;i<rates_total;i++)
     {
      TimeToStruct(time[i],dt);
      //--- set values
      ColorHistogram_2Buffer1[i]=high[i];
      ColorHistogram_2Buffer2[i]=low[i];
      //--- set color index as a day of the week
      int day=dt.day_of_week;
      ColorHistogram_2Colors[i]=day;
     }
//--- return prev_calculated for the next call of the function
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Changes the colors                                              |
//+------------------------------------------------------------------+
void  ChangeColors(color  &cols[],int plot_colors)
  {
//--- colors
   int size=ArraySize(cols);
//--- 
   string comm=ChartGetString(0,CHART_COMMENT)+"\r\n\r\n";

//--- set new color for each color index
   for(int plot_color_ind=0;plot_color_ind<plot_colors;plot_color_ind++)
     {
      //--- get random number
      int number=MathRand();
      //--- select index
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
//| Changes the properties                                           |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- comment
   string comm="";
//--- line width
   int number=MathRand();
//--- calc width 
   int width=number%5; // width vary from 0 to 4
//--- set width as PLOT_LINE_WIDTH property
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,width);
//--- add to comment
   comm=comm+" Width="+IntegerToString(width);

//--- line style
   number=MathRand();
//--- styles
   int size=ArraySize(styles);
//--- select style
   int style_index=number%size;
//--- set style as PLOT_LINE_STYLE property
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,styles[style_index]);
//--- add to comment
   comm=EnumToString(styles[style_index])+", "+comm;
//--- print comment
   Comment(comm);
  }
//+------------------------------------------------------------------+
