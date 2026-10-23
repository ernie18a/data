//+------------------------------------------------------------------+
//|                                              DRAW_HISTOGRAM2.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "This indicator is a demo of DRAW_HISTOGRAM2 drawing style"
#property description "It draws a line from Open to Close"
#property description "The color, width and style changed randomly"
#property description "every N ticks"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot Histogram_2
#property indicator_label1  "Histogram_2"
#property indicator_type1   DRAW_HISTOGRAM2
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input int      N=5;    // Number of ticks to change histogram properties
//--- indicator buffers
double         Histogram_2Buffer1[];
double         Histogram_2Buffer2[];
//--- invisible day
int invisible_day;
//--- colors array
color colors[]={clrRed,clrBlue,clrGreen};
//--- line styles array
ENUM_LINE_STYLE styles[]={STYLE_SOLID,STYLE_DASH,STYLE_DOT,STYLE_DASHDOT,STYLE_DASHDOTDOT};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set index buffers
   SetIndexBuffer(0,Histogram_2Buffer1,INDICATOR_DATA);
   SetIndexBuffer(1,Histogram_2Buffer2,INDICATOR_DATA);
//--- set empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- define invisible day randomly
   invisible_day=MathRand()%6;
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
//--- if ticks>N
   if(ticks>=N)
     {
      //--- change properties
      ChangeLineAppearance();
      //--- set ticks counter to 0
      ticks=0;
     }

//--- calculation
   int start=0;
//--- used to determine weekday of the bar
   MqlDateTime dt;
//--- start from 
   if(prev_calculated>0) start=prev_calculated-1; // starting from the previous bar
//--- filling the indicator buffer with values
   for(int i=start;i<rates_total;i++)
     {
      TimeToStruct(time[i],dt);
      if(dt.day_of_week==invisible_day)
        {
         Histogram_2Buffer1[i]=0;
         Histogram_2Buffer2[i]=0;
        }
      else
        {
         Histogram_2Buffer1[i]=open[i];
         Histogram_2Buffer2[i]=close[i];
        }
     }
//--- return prev_calculated for the next call of the function
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Changes the properties                                           |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- comment
   string comm="";
//--- color
   int number=MathRand(); // get random number
//--- get array size
   int size=ArraySize(colors);
//--- select color
   int color_index=number%size;
//--- set color
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,colors[color_index]);
//--- add to comment
   comm=comm+"\r\n"+(string)colors[color_index];

//--- width
   number=MathRand();
//--- define width
   int width=number%5;   // width vary from 0 to 4
//--- set width
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,width);
//--- add to comment
   comm=comm+"\r\nWidth="+IntegerToString(width);

//--- style
   number=MathRand();
//--- get array size
   size=ArraySize(styles);
//--- define style index
   int style_index=number%size;
//--- set style
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,styles[style_index]);
//--- add to comment
   comm="\r\n"+EnumToString(styles[style_index])+""+comm;
//--- add information about the 
   comm="\r\n Invisible day - "+EnumToString((ENUM_DAY_OF_WEEK)invisible_day)+comm;
//--- show comment
   Comment(comm);
  }
//+------------------------------------------------------------------+
