//+------------------------------------------------------------------+
//|                                                 DRAW_SECTION.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "This indicator is a demo of DRAW_SECTION drawing style"
#property description "It draws a sections"
#property description "The color, width and style of the sections changes"
#property description "every N ticks"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Section
#property indicator_label1  "Section"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      bars=5;     // Section length in bars
input int      N=5;        // Number of ticks to change color/width/style of the section
//--- indicator buffer
double         SectionBuffer[];
//--- additional variable
int            divider;
//--- colors array
color colors[]={clrRed,clrBlue,clrGreen};
//--- styles array
ENUM_LINE_STYLE styles[]={STYLE_SOLID,STYLE_DASH,STYLE_DOT,STYLE_DASHDOT,STYLE_DASHDOTDOT};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set index buffer
   SetIndexBuffer(0,SectionBuffer,INDICATOR_DATA);
//--- set empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- check input parameter
   if(bars<=0)
     {
      PrintFormat("Invalid input parameter bar=%d",bars);
      return(INIT_PARAMETERS_INCORRECT);
     }
   else divider=2*bars;
//---+
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
//--- if ticks>N, change section color/width/style
   if(ticks>=N)
     {
      //--- change line properties
      ChangeLineAppearance();
      //--- set ticks counter to 0
      ticks=0;
     }

//--- starting bar
   int start=0;
//--- set start to the previous bar
   if(prev_calculated>0) start=prev_calculated-1;
//--- calculations
   for(int i=start;i<rates_total;i++)
     {
      //--- calc remainder
      int rest=i%divider;
      //--- if remainder=0
      if(rest==0)
        {
         //--- set end of the section to High
         SectionBuffer[i]=high[i];
        }
      //--- if remainder=bars, 
      else
        {
         //--- set end of the section to High
         if(rest==bars) SectionBuffer[i]=low[i];
         //--- else set 0
         else SectionBuffer[i]=0;
        }
     }
//--- return prev_calculated for the next call of the function
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Change section color/width/style                                 |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- comment
   string comm="";
//--- section color
   int number=MathRand(); // get random
//--- get size of colors array
   int size=ArraySize(colors);
//--- calc color index
   int color_index=number%size;
//--- set color
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,colors[color_index]);
//--- add to comment
   comm=comm+"\r\n"+(string)colors[color_index];

//--- section width
   number=MathRand();
//--- calc width
   int width=number%5;   // width vary from 0 to 4
//--- set width
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,width);
//--- add to comment
   comm=comm+"\r\nWidth="+IntegerToString(width);

//--- section style
   number=MathRand();
//--- get size of the styles array
   size=ArraySize(styles);
//--- calc style index
   int style_index=number%size;
//--- set style index
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,styles[style_index]);
//--- add to comment
   comm="\r\n"+EnumToString(styles[style_index])+""+comm;
//--- show comment on the chart
   Comment(comm);
  }
//+------------------------------------------------------------------+
