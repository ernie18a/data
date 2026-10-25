//+------------------------------------------------------------------+
//|                                                    DRAW_BARS.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "This indicator is a demo of DRAW_BARS drawing style"
#property description "It plots the bars of the specified symbol in the separate window"
#property description "The bars color, width and symbol changed randomly"
#property description "after N ticks"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot Bars
#property indicator_label1  "Bars"
#property indicator_type1   DRAW_BARS
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      N=5;              // Ticks to change properties
input int      bars=500;         // Bars to show
input bool     messages=false;   // Log messages to "Experts" tab
//--- indicator buffers
double         BarsBuffer1[];
double         BarsBuffer2[];
double         BarsBuffer3[];
double         BarsBuffer4[];
//--- symbol
string symbol;
//--- colors array
color colors[]={clrRed,clrBlue,clrGreen,clrPurple,clrBrown,clrIndianRed};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- if bars<50, exit
   if(bars<50)
     {
      Comment("Increase the bars input variable to 50!");
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BarsBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,BarsBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,BarsBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,BarsBuffer4,INDICATOR_DATA);
//--- symbol
   symbol=_Symbol;
//--- indicator name in "Data" window
   PlotIndexSetString(0,PLOT_LABEL,symbol+" Open;"+symbol+" High;"+symbol+" Low;"+symbol+" Close");
   IndicatorSetString(INDICATOR_SHORTNAME,"DRAW_BARS("+symbol+")");
//--- set "empty" value as 0.0
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
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
//--- if ticks>=M
   if(ticks>=N)
     {
      //--- select new symbol from "Market Watch" window
      symbol=GetRandomSymbolName();
      //--- change properties
      ChangeLineAppearance();

      int tries=0;
      //--- 5 attempts
      while(!CopyFromSymbolToBuffers(symbol,rates_total) && tries<5)
        {
         //--- count the calls of CopyFromSymbolToBuffers()
         tries++;
        }
      //--- set ticks counter to 0
      ticks=0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Fills the indicator buffers with prices                         |
//+------------------------------------------------------------------+
bool CopyFromSymbolToBuffers(string name,int total)
  {
//--- used to Open, High, Low and Close prices
   MqlRates rates[];
//--- attempts
   int attempts=0;
//--- bars copied
   int copied=0;
//--- try 25 times to get the data
   while(attempts<25 && (copied=CopyRates(name,_Period,0,bars,rates))<0)
     {
      Sleep(100);
      attempts++;
      if(messages) PrintFormat("%s CopyRates(%s) attempts=%d",__FUNCTION__,name,attempts);
     }
//--- error in copying
   if(copied!=bars)
     {
      //--- prepare comment
      string comm=StringFormat("Error: Copied only %d bars of %d needed for the %s symbol ",
                               name,
                               copied,
                               bars
                               );
      //--- print comment on the chart window
      Comment(comm);
      //--- pring comment to "Experts" tab
      if(messages) Print(comm);
      return(false);
     }
   else
     {
      //--- show symbol
      PlotIndexSetString(0,PLOT_LABEL,name+" Open;"+name+" High;"+name+" Low;"+name+" Close");
      IndicatorSetString(INDICATOR_SHORTNAME,"DRAW_BARS("+name+")");
     }
//--- initialize the indicator buffers with "empty" values
   ArrayInitialize(BarsBuffer1,0.0);
   ArrayInitialize(BarsBuffer2,0.0);
   ArrayInitialize(BarsBuffer3,0.0);
   ArrayInitialize(BarsBuffer4,0.0);

//--- copy prices to buffers
   for(int i=0;i<copied;i++)
     {
      //--- calc index
      int buffer_index=total-copied+i;
      //--- copy the prices
      BarsBuffer1[buffer_index]=rates[i].open;
      BarsBuffer2[buffer_index]=rates[i].high;
      BarsBuffer3[buffer_index]=rates[i].low;
      BarsBuffer4[buffer_index]=rates[i].close;
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Returns the name of random symbol from Market Watch              |
//+------------------------------------------------------------------+
string GetRandomSymbolName()
  {
//--- get total symbols from "Market Watch" window
   int symbols=SymbolsTotal(true);
//--- select symbols
   int number=MathRand()%symbols;
//--- return symbol name
   return SymbolName(number,true);
  }
//+------------------------------------------------------------------+
//| Changes the properties of the indicator bars                     |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- comment
   string comm="";
//--- bars color
   int number=MathRand(); // get random color
//--- get size of colors array
   int size=ArraySize(colors);
//--- select index of random color
   int color_index=number%size;
//--- set color as a PLOT_LINE_COLOR property
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,colors[color_index]);
//--- add to comment
   comm=comm+"\r\n"+(string)colors[color_index];

//--- bars width
   number=MathRand();
//--- calculate width
   int width=number%5;   // width vary from 0 to 4
//--- set width as PLOT_LINE_WIDTH property
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,width);
//--- add to comment
   comm=comm+"\r\nWidth="+IntegerToString(width);

//--- add symbol name
   comm="\r\n"+symbol+comm;

//--- print comment on the chart window
   Comment(comm);
  }
//+------------------------------------------------------------------+
