//+------------------------------------------------------------------+
//|                                              DRAW_COLOR_BARS.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "DRAW_COLOR_BARS Indicator Demo"
#property description "Draws colored bars for the specified symbol in a separate window"
#property description "Symbol, and bars color and thickness are changing "
#property description "at random every N ticks"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot ColorBars
#property indicator_label1  "ColorBars"
#property indicator_type1   DRAW_COLOR_BARS
//--- Define 8 colors to color the bars (stored in separate array)
#property indicator_color1  clrRed,clrBlue,clrGreen,clrYellow,clrMagenta,clrCyan,clrLime,clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      N=5;              // Number of ticks to change view
input int      bars=500;         // Bars to display
input bool     messages=false;   // Print messages into "Experts" log
//--- Indicator buffers
double         ColorBarsBuffer1[];
double         ColorBarsBuffer2[];
double         ColorBarsBuffer3[];
double         ColorBarsBuffer4[];
double         ColorBarsColors[];
//--- Symbol name
string symbol;
int    bars_colors;
//--- Array of 14 elements to store colors
color colors[]=
  {
   clrRed,clrBlue,clrGreen,clrChocolate,clrMagenta,clrDodgerBlue,clrGoldenrod,
   clrIndigo,clrLightBlue,clrAliceBlue,clrMoccasin,clrMagenta,clrCyan,clrMediumPurple
  };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ColorBarsBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ColorBarsBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ColorBarsBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,ColorBarsBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,ColorBarsColors,INDICATOR_COLOR_INDEX);
//---- Number of colors to color bars
   bars_colors=8;   //  See comment to the #property indicator_color1
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
//--- Calculate ticks to change style, color and thickness of bar
   ticks++;
//--- If we have accumulated enough ticks
   if(ticks>=N)
     {
      //--- Select new symbol from the "Market Watch" window
      symbol=GetRandomSymbolName();
      //--- Change line properties
      ChangeLineAppearance();
      //--- Change colors to color the bars
      ChangeColors(colors,bars_colors);
      int tries=0;
      //--- Make 5 attempts to fill buffer with prices from symbol
      while(!CopyFromSymbolToBuffers(symbol,rates_total,bars_colors) && tries<5)
        {
         //--- Counter of the CopyFromSymbolToBuffers() function calls
         tries++;
        }
      //--- Reset the ticks counter to zero
      ticks=0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Fill indicator buffers with prices                               |
//+------------------------------------------------------------------+
bool CopyFromSymbolToBuffers(string name,int total,int bar_colors)
  {
//--- copy the Open, High, Low and Close prices to the rates[] array 
   MqlRates rates[];
//--- Attempts counter
   int attempts=0;
//--- Amount of copied
   int copied=0;
//--- Make 25 attempts to get timeseries for desired symbol
   while(attempts<25 && (copied=CopyRates(name,_Period,0,bars,rates))<0)
     {
      Sleep(100);
      attempts++;
      if(messages) PrintFormat("%s CopyRates(%s) attempts=%d",__FUNCTION__,name,attempts);
     }
//--- If unable to copy sufficient number of bars
   if(copied!=bars)
     {
      //--- Form the message string
      string comm=StringFormat("Для символа %s удалось получить только %d баров из %d затребованных",
                               name,
                               copied,
                               bars
                               );
      //--- Print message to comment on the main chart window
      Comment(comm);
      //--- Print messages
      if(messages) Print(comm);
      return(false);
     }
   else
     {
      //--- Set symbol display 
      PlotIndexSetString(0,PLOT_LABEL,name+" Open;"+name+" High;"+name+" Low;"+name+" Close");
      IndicatorSetString(INDICATOR_SHORTNAME,"DRAW_BARS("+name+")");
     }
//--- Initialize buffers with empty values
   ArrayInitialize(ColorBarsBuffer1,0.0);
   ArrayInitialize(ColorBarsBuffer2,0.0);
   ArrayInitialize(ColorBarsBuffer3,0.0);
   ArrayInitialize(ColorBarsBuffer4,0.0);

//--- Copy prices to buffers
   for(int i=0;i<copied;i++)
     {
      //--- Calculate the corresponding index for buffers
      int buffer_index=total-copied+i;
      //--- Write prices to buffers
      ColorBarsBuffer1[buffer_index]=rates[i].open;
      ColorBarsBuffer2[buffer_index]=rates[i].high;
      ColorBarsBuffer3[buffer_index]=rates[i].low;
      ColorBarsBuffer4[buffer_index]=rates[i].close;
      //---
      ColorBarsColors[buffer_index]=i%bar_colors;
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Returns random symbol from Market Watch                          |
//+------------------------------------------------------------------+
string GetRandomSymbolName()
  {
//--- Number of symbols displayed in "Market Watch" window
   int symbols=SymbolsTotal(true);
//--- Position of symbol in the list - random number between 0 and symbols
   int number=MathRand()%symbols;
//--- Return symbol name by specified position
   return SymbolName(number,true);
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
//| Changes the appearance of bars                                   |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- String to form information about bars properties
   string comm="";

//--- Changing the thickness of bars
   int number=MathRand();
//--- Get the thickness as a remainder of integer division
   int width=number%5;   // Set thickness from 0 to 4
//--- Set color as the PLOT_LINE_WIDTH property
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,width);
//--- Write thickness of line
   comm=comm+"\r\nWidth="+IntegerToString(width);

//--- Write symbol name
   comm="\r\n"+symbol+comm;

//--- Print information on the chart as comment
   Comment(comm);
  }
//+------------------------------------------------------------------+
