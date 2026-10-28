//+------------------------------------------------------------------+
//|                                                  DRAW_ZIGZAG.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "This indicator is a demo of DRAW_ZIGZAG drawing style"
#property description "It plots a \"saw\", using the High/Low of the bar"
#property description "There is a week day with invisible values (defined randomly at the start)"
#property description "The sections color, width and style changed randomly"
#property description "after N ticks"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot ZigZag
#property indicator_label1  "ZigZag"
#property indicator_type1   DRAW_ZIGZAG
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      N=5;              // Ticks to change properties
//--- indicator buffers
double         ZigZagBuffer1[];
double         ZigZagBuffer2[];
//--- invisible day (it doesn't plotted) of the week
int invisible_day;
//--- colors array
color colors[]={clrRed,clrBlue,clrGreen};
//--- line styles
ENUM_LINE_STYLE styles[]={STYLE_SOLID,STYLE_DASH,STYLE_DOT,STYLE_DASHDOT,STYLE_DASHDOTDOT};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set index buffers
   SetIndexBuffer(0,ZigZagBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ZigZagBuffer2,INDICATOR_DATA);
//--- set invisible day
   invisible_day=MathRand()%6;
//--- set the 0 as an "empty" value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- set label
   PlotIndexSetString(0,PLOT_LABEL,"ZigZag1;ZigZag2");
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
      //--- change properties
      ChangeLineAppearance();
      //--- set to zero
      ticks=0;
     }

//--- used to proceed the week day of the bar
   MqlDateTime dt;

//--- initial position
   int start=0;
//--- if it wascalled, start from prev_caluclated
   if(prev_calculated!=0) start=prev_calculated-1;
//--- calculations
   for(int i=start;i<rates_total;i++)
     {
      //--- write open time of the bar to structure
      TimeToStruct(time[i],dt);
      //--- if week day=invisible_day
      if(dt.day_of_week==invisible_day)
        {
         //--- write "empty" values
         ZigZagBuffer1[i]=0;
         ZigZagBuffer2[i]=0;
        }
      //--- else fill the buffers with data
      else
        {
         //--- bar index is even
         if(i%2==0)
           {
            //--- High to 1st buffer, Low to 2nd
            ZigZagBuffer1[i]=high[i];
            ZigZagBuffer2[i]=low[i];
           }
         //--- bar index is odd
         else
           {
            //--- Reverse order
            ZigZagBuffer1[i]=low[i];
            ZigZagBuffer2[i]=high[i];
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Changes the indicator properties                                  |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- comment
   string comm="";
//--- color
   int number=MathRand(); // get random number
//--- get size of colors array
   int size=ArraySize(colors);
//--- select index of the random color
   int color_index=number%size;
//--- set color as PLOT_LINE_COLOR property
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,colors[color_index]);
//--- add to comment
   comm=comm+"\r\n"+(string)colors[color_index];

//--- width
   number=MathRand();
//--- select width
   int width=number%5;   // the width vary from 0 to 4
//--- set width as PLOT_LINE_WIDTH property
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,width);
//--- add tocomment
   comm=comm+"\r\nWidth="+IntegerToString(width);

//--- line style
   number=MathRand();
//--- get size of styles array
   size=ArraySize(styles);
//--- select style
   int style_index=number%size;
//--- set style as a PLOT_LINE_COLOR property
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,styles[style_index]);
//--- add to comment
   comm="\r\n"+EnumToString(styles[style_index])+""+comm;
//--- add info about the invisible day
   comm="\r\nInvisible day - "+EnumToString((ENUM_DAY_OF_WEEK)invisible_day)+comm;
//--- show comment on the chat
   Comment(comm);
  }
//+------------------------------------------------------------------+
