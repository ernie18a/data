//+------------------------------------------------------------------+
//|                                            DRAW_COLOR_ZIGZAG.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "DRAW_COLOR_ZIGZAG Indicator Demo"
#property description "Draws colored zigzag line. Color depends on number of day in a week."
#property description "Symbol, and lines color and thickness are changing "
#property description "at random every N ticks"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot Color_Zigzag
#property indicator_label1  "Color_Zigzag"
#property indicator_type1   DRAW_COLOR_ZIGZAG
//--- Define 8 colors to color the sections (stored in separate array)
#property indicator_color1  clrRed,clrBlue,clrGreen,clrYellow,clrMagenta,clrCyan,clrLime,clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameter
input int      N=5;              // Number of ticks to make changes 
int            color_sections;
//--- Buffers for values of line ends
double         Color_ZigzagBuffer1[];
double         Color_ZigzagBuffer2[];
//--- Buffer for color indices of line ends
double         Color_ZigzagColors[];
//--- Array of 14 elements to store colors
color colors[]=
  {
   clrRed,clrBlue,clrGreen,clrChocolate,clrMagenta,clrDodgerBlue,clrGoldenrod,
   clrIndigo,clrLightBlue,clrAliceBlue,clrMoccasin,clrWhiteSmoke,clrCyan,clrMediumPurple
  };
//--- Array to store lines drawing styles
ENUM_LINE_STYLE styles[]={STYLE_SOLID,STYLE_DASH,STYLE_DOT,STYLE_DASHDOT,STYLE_DASHDOTDOT};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Color_ZigzagBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,Color_ZigzagBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,Color_ZigzagColors,INDICATOR_COLOR_INDEX);
//---- Number of colors to color zigzag sections
   color_sections=8;   //  See comment to the #property indicator_color1
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
//--- Calculate ticks to change style, color and thickness of line
   ticks++;
//--- If we have accumulated enough ticks
   if(ticks>=N)
     {
      //--- Change line properties
      ChangeLineAppearance();
      //--- Change colors to color the sections
      ChangeColors(colors,color_sections);
      //--- Reset the ticks counter to zero
      ticks=0;
     }

//--- The time structure is needed to get the weekday of each bar
   MqlDateTime dt;
      
//--- Start calculations
   int start=0;
//--- If indicator was calculated on the previous tick, start calculation from the penultimate
   if(prev_calculated!=0) start=prev_calculated-1;
//--- Calculations loop
   for(int i=start;i<rates_total;i++)
     {
      //--- Write the time of bars opening into structure
      TimeToStruct(time[i],dt);

      //--- If bar number is even
      if(i%2==0)
        {
         //---  Write High to 1st buffer, Low to 2nd
         Color_ZigzagBuffer1[i]=high[i];
         Color_ZigzagBuffer2[i]=low[i];
         //--- Line color
         Color_ZigzagColors[i]=dt.day_of_year%color_sections;
        }
      //--- If bar number is odd
      else
        {
         //--- Fill bar in reverse order
         Color_ZigzagBuffer1[i]=low[i];
         Color_ZigzagBuffer2[i]=high[i];
         //--- Line color
         Color_ZigzagColors[i]=dt.day_of_year%color_sections;         
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Changes color of zigzag lines
//+------------------------------------------------------------------+
void  ChangeColors(color  &cols[],int plot_colors)
  {
//--- Number of colors 
   int size=ArraySize(cols);
//--- 
   string comm=ChartGetString(0,CHART_COMMENT)+"\r\n\r\n";

//--- For each color index define new random color
   for(int plot_color_ind=0;plot_color_ind<plot_colors;plot_color_ind++)
     {
      //--- Get random number
      int number=MathRand();
      //--- Get index in the col[] array as the remainder of integer division
      int i=number%size;
      //--- Set color for each index as the PLOT_LINE_COLOR property
      PlotIndexSetInteger(0,                    //  Number of graphical style
                          PLOT_LINE_COLOR,      //  Property ID
                          plot_color_ind,       //  Color index to write color
                          cols[i]);             //  New color
      //--- Write colors
      comm=comm+StringFormat("SectionColorIndex[%d]=%s \r\n",plot_color_ind,ColorToString(cols[i],true));
      ChartSetString(0,CHART_COMMENT,comm);
     }
//---
  }
//+------------------------------------------------------------------+
//| Changes the appearance of zigzag sections                        |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- String to form information about Color_ZigZag properties
   string comm="";
//--- Changing the thickness of line
   int number=MathRand();
//--- Get the thickness as a remainder of integer division
   int width=number%5;   // Set thickness from 0 to 4
//--- Set color as the PLOT_LINE_WIDTH property
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,width);
//--- Write thickness of line
   comm=comm+"\r\nWidth="+IntegerToString(width);

//--- Changing the style of line
   number=MathRand();
//--- Divisor is equal to size of the styles array
   int size=ArraySize(styles);
//--- Get index to select new style as the remainder of integer division
   int style_index=number%size;
//--- Set color as the PLOT_LINE_COLOR property
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,styles[style_index]);
//--- Write style of line
   comm="\r\n"+EnumToString(styles[style_index])+""+comm;
//--- Print information on the chart as comment
   Comment(comm);
  }
//+------------------------------------------------------------------+
