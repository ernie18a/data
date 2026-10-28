//+------------------------------------------------------------------+
//|                                             DRAW_COLOR_ARROW.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "This indicator is a demo of DRAW_COLOR_ARROW drawing style"
#property description "It plots arrows on the chart, using the symbols from Windings font"
#property description "The color, char size and shift are changed randomly after N ticks"
#property description "The code parameter is used to specify the base code: code=159 (circle)"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot ColorArrow
#property indicator_label1  "ColorArrow"
#property indicator_type1   DRAW_COLOR_ARROW
//--- set 8 colors
#property indicator_color1  clrRed,clrBlue,clrSeaGreen,clrGold,clrDarkOrange,clrMagenta,clrYellowGreen,clrChocolate
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input int      N=5;         // Ticks to change
input ushort   code=159;    // Symbol code for DRAW_ARROW
int            color_sections;
//--- indicator buffer
double         ColorArrowBuffer[];
//--- color buffer
double         ColorArrowColors[];
//--- color array (14) colors
color colors[]=
  {
   clrRed,clrBlue,clrGreen,clrChocolate,clrMagenta,clrDodgerBlue,clrGoldenrod,
   clrIndigo,clrLightBlue,clrAliceBlue,clrMoccasin,clrWhiteSmoke,clrCyan,clrMediumPurple
  };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ColorArrowBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorArrowColors,INDICATOR_COLOR_INDEX);
//--- set symbol code for PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,code);
//--- set vertical shift (in pixels)
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,5);
//--- set 0 as an empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);   
//---- colors
   color_sections=8;
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
      //--- change arrow properties
      ChangeLineAppearance();
      //--- change colors
      ChangeColors(colors,color_sections);
      //--- set counter to 0
      ticks=0;
     }

//--- indicator calculation
   int start=1;
   if(prev_calculated>0) start=prev_calculated-1;
//--- mail loop
   for(int i=1;i<rates_total;i++)
     {
      //--- if Close>Close[previous], set array
      if(close[i]>close[i-1])
         ColorArrowBuffer[i]=close[i];
      //--- else set empty value
      else
         ColorArrowBuffer[i]=0;
      //--- arrow color
      int index=i%color_sections;
      ColorArrowColors[i]=index;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Changes the colors                                              |
//+------------------------------------------------------------------+
void  ChangeColors(color  &cols[],int plot_colors)
  {
//--- number of colors
   int size=ArraySize(cols);
//--- 
   string comm=ChartGetString(0,CHART_COMMENT)+"\r\n\r\n";

//--- set new color (selected randomly from colors array) for each color index
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
      //--- add color to comment
      comm=comm+StringFormat("ArrowColorIndex[%d]=%s \r\n",plot_color_ind,ColorToString(cols[i],true));
      ChartSetString(0,CHART_COMMENT,comm);
     }
//---
  }
//+------------------------------------------------------------------+
//| Changes the arrow properties                                     |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- comment
   string comm="";
//--- arrow size
   int number=MathRand();
//--- new arrow size
   int width=number%5; // size vary from 0 to 4
//--- set size as PLOT_LINE_WIDTH property
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,width);
//--- add to comment
   comm=comm+" Width="+IntegerToString(width);
   
//--- change code of the symbol (PLOT_ARROW)
   number=MathRand();
//--- new symbol code (from 0 to 19)
   int code_add=number%20;
//--- set new symbol code as a sum code+code_add
   PlotIndexSetInteger(0,PLOT_ARROW,code+code_add);
//--- add to comment
   comm="\r\n"+"PLOT_ARROW="+IntegerToString(code+code_add)+comm;   

//--- shift
   number=MathRand();
//--- calculate new shift
   int shift=20-number%41;
//--- set new shift
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,shift);
//--- add to comment
   comm="\r\n"+"PLOT_ARROW_SHIFT="+IntegerToString(shift)+comm;

//--- print comment
   Comment(comm);
  }
//+------------------------------------------------------------------+
