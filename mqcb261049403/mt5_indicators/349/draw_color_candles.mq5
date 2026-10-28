//+------------------------------------------------------------------+
//|                                           DRAW_COLOR_CANDLES.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "DRAW_COLOR_CANDLES Indicator Demo"
#property description "Draws colored candlesticks for the specified symbol in a separate window"
#property description " "
#property description "Symbol, and candlesticks color and thickness are changing "
#property description "at random every N ticks"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot ColorCandles
#property indicator_label1  "ColorCandles"
#property indicator_type1   DRAW_COLOR_CANDLES
//--- Define 8 colors to color the candlesticks (stored in separate array)
#property indicator_color1  clrRed,clrBlue,clrGreen,clrYellow,clrMagenta,clrCyan,clrLime,clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input int      N=5;              // number of ticks to change view
input int      bars=500;         // bars to display
input bool     messages=false;   // print messages into "Experts" log
//--- Indicator buffers
double         ColorCandlesBuffer1[];
double         ColorCandlesBuffer2[];
double         ColorCandlesBuffer3[];
double         ColorCandlesBuffer4[];
double         ColorCandlesColors[];
int            candles_colors;
//--- Symbol name
string symbol;
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
//--- If there are not enough bars - abort ahead of time
   if(bars<50)
     {
      Comment("Please, specify more bars! Indicator stopped");
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,ColorCandlesBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ColorCandlesBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ColorCandlesBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,ColorCandlesBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,ColorCandlesColors,INDICATOR_COLOR_INDEX);
//--- Empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- Name of symbol to draw bars
   symbol=_Symbol;
//--- Set symbol display 
   PlotIndexSetString(0,PLOT_LABEL,symbol+" Open;"+symbol+" High;"+symbol+" Low;"+symbol+" Close");
   IndicatorSetString(INDICATOR_SHORTNAME,"DRAW_COLOR_CANDLES("+symbol+")");
//---- Number of colors to color candlesticks
   candles_colors=8;     //  See comment to the #property indicator_color1
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
   static int ticks=INT_MAX-100;
//--- Calculate ticks to change style and color
   ticks++;
//--- If we have accumulated enough ticks
   if(ticks>=N)
     {
      //--- Change view
      ChangeLineAppearance();
      //--- Change colors to color the bars
      ChangeColors(colors,candles_colors);
      //--- Select new symbol from the "Market Watch" window
      symbol=GetRandomSymbolName();
      //--- Select new symbol from the "Market Watch" window
      int tries=0;
      //--- Make 5 attempts to fill plot1 buffer with prices from symbol
      while(!CopyFromSymbolToBuffers(symbol,rates_total,0,
            ColorCandlesBuffer1,ColorCandlesBuffer2,ColorCandlesBuffer3,
            ColorCandlesBuffer4,ColorCandlesColors,candles_colors)
            && tries<5)
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
//|  Fills the specified candlestick                                 |
//+------------------------------------------------------------------+
bool CopyFromSymbolToBuffers(string name,
                             int total,
                             int plot_index,
                             double &buff1[],
                             double &buff2[],
                             double &buff3[],
                             double &buff4[],
                             double &col_buffer[],
                             int    cndl_colors
                             )
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
      PlotIndexSetString(plot_index,PLOT_LABEL,name+" Open;"+name+" High;"+name+" Low;"+name+" Close");
      IndicatorSetString(INDICATOR_SHORTNAME,"DRAW_COLOR_CANDLES("+symbol+")");
     }
//--- Initialize buffers with empty values
   ArrayInitialize(buff1,0.0);
   ArrayInitialize(buff2,0.0);
   ArrayInitialize(buff3,0.0);
   ArrayInitialize(buff4,0.0);
//--- Copy prices to buffers on every tick
   for(int i=0;i<copied;i++)
     {
      //--- Calculate the corresponding index for buffers
      int buffer_index=total-copied+i;
      //--- Write prices to buffers
      buff1[buffer_index]=rates[i].open;
      buff2[buffer_index]=rates[i].high;
      buff3[buffer_index]=rates[i].low;
      buff4[buffer_index]=rates[i].close;
      //--- Set candlestick color
      int color_index=i%cndl_colors;
      col_buffer[buffer_index]=color_index;
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
//|  Changes color of candlesticks
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
//| Changes the appearance of candlesticks                           |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- String to form information about candlesticks properties
   string comm="";
//--- Write symbol name
   comm="\r\n"+symbol+comm;
//--- Print information on the chart as comment
   Comment(comm);
  }
//+------------------------------------------------------------------+
