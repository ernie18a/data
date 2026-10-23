//+------------------------------------------------------------------+
//|                                           DRAW_COLOR_SECTION.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "This indicator is a demo of DRAW_COLOR_SECTION drawing style"
#property description "It plots color sections with specified number of bars"
#property description "The section color, width and line style"
#property description "are changed randomly after N ticks"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot ColorSection
#property indicator_label1  "ColorSection"
#property indicator_type1   DRAW_COLOR_SECTION
//--- 8 colors
#property indicator_color1  clrRed,clrGold,clrMediumBlue,clrLime,clrMagenta,clrBrown,clrTan,clrMediumVioletRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      N=5;                      // Ticks to change properties
input int      bars_in_section=5;        // Section width in bars
//--- additional variables
int            divider;
int            color_sections;
//--- plotting buffer
double         ColorSectionBuffer[];
//--- color buffer
double         ColorSectionColors[];
//--- color array (14 colors)
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
   SetIndexBuffer(0,ColorSectionBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorSectionColors,INDICATOR_COLOR_INDEX);
//--- set empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- colors
   color_sections=8;
//--- check bars in section
   if(bars_in_section<=0)
     {
      PrintFormat("Invalid section width=%d",bars_in_section);
      return(INIT_PARAMETERS_INCORRECT);
     }
   else divider=color_sections*bars_in_section;
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
//--- count the ticks to change properties
   ticks++;
//--- if ticks>=N
   if(ticks>=N)
     {
      //--- change properties
      ChangeLineAppearance();
      //--- change colors
      ChangeColors(colors,color_sections);
      //--- set counter to 0
      ticks=0;
     }

//--- starting bar index
   int start=0;
//--- if not first call, set start to the previous bar
   if(prev_calculated>0) start=prev_calculated-1;
//--- calculations
   for(int i=start;i<rates_total;i++)
     {
      //--- if remainder=0, the end of the section
      if(i%bars_in_section==0)
        {
         //--- set High for the end of the section
         ColorSectionBuffer[i]=high[i];
         //--- the remainder = section_width*number_of_colors
         int rest=i%divider;
         // color index vary from 0 to number_of_colors-1
         int color_indext=rest/bars_in_section;
         ColorSectionColors[i]=color_indext;
        }
      //--- remainder<>0
      else
        {
         //--- skip bar (set empty value)
         ColorSectionBuffer[i]=0;
        }
     }
//--- return prev_calculated for the next call of the function
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

//--- set new color for each color index 
   for(int plot_color_ind=0;plot_color_ind<plot_colors;plot_color_ind++)
     {
      //--- get random number
      int number=MathRand();
      //--- get color index as remainder of division
      int i=number%size;
      //--- set color as PLOT_LINE_COLOR property
      PlotIndexSetInteger(0,                    //  plotting style index
                          PLOT_LINE_COLOR,      //  property identifier
                          plot_color_ind,       //  color index
                          cols[i]);             //  new color
      //--- add color to comment
      comm=comm+StringFormat("SectionColorIndex[%d]=%s \r\n",plot_color_ind,ColorToString(cols[i],true));
      ChartSetString(0,CHART_COMMENT,comm);
     }
//---
  }
//+------------------------------------------------------------------+
//| Changes the properties of the sections                           |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- comment
   string comm="";
//--- line width
   int number=MathRand();
//--- new line width
   int width=number%5; // line width vary from 0 to 4
//--- set line width as PLOT_LINE_WIDTH property
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,width);
//--- add line width to comment
   comm=comm+" Width="+IntegerToString(width);

//--- style
   number=MathRand();
//--- total styles
   int size=ArraySize(styles);
//--- select style index
   int style_index=number%size;
//--- set line style as PLOT_LINE_STYLE propery
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,styles[style_index]);
//--- add line style to comment
   comm=EnumToString(styles[style_index])+", "+comm;
//--- print comment
   Comment(comm);
  }
//+------------------------------------------------------------------+
