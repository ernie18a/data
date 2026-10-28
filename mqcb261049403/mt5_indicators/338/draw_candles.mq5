//+------------------------------------------------------------------+
//|                                                 DRAW_CANDLES.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property description "This indicator is a demo of DRAW_CANDLES drawing style."
#property description "It plots the candles of two different symbols in the separate window"
#property description " "
#property description "The candles color and symbol"
#property description "changed randomly each N ticks."

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot Bars
#property indicator_label1  "DRAW_CANDLES1"
#property indicator_type1   DRAW_CANDLES
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input int      N=5;              // Ticks to change properties
input int      bars=500;         // Bars to show
input bool     messages=false;   // Log messages
//--- indicator buffers
double         Candle1Buffer1[];
double         Candle1Buffer2[];
double         Candle1Buffer3[];
double         Candle1Buffer4[];
//--- symbols
string symbol;
//--- colors array
color colors[]={clrRed,clrBlue,clrGreen,clrPurple,clrBrown,clrIndianRed};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- if bars<50 exit
   if(bars<50)
     {
      Comment("Error: The bars must be > 50!");
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,Candle1Buffer1,INDICATOR_DATA);
   SetIndexBuffer(1,Candle1Buffer2,INDICATOR_DATA);
   SetIndexBuffer(2,Candle1Buffer3,INDICATOR_DATA);
   SetIndexBuffer(3,Candle1Buffer4,INDICATOR_DATA);
//--- set 0 as an empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- symbol name
   symbol=_Symbol;
//--- set symbol setting
   PlotIndexSetString(0,PLOT_LABEL,symbol+" Open;"+symbol+" High;"+symbol+" Low;"+symbol+" Close");
   IndicatorSetString(INDICATOR_SHORTNAME,"DRAW_CANDLES("+symbol+")");
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
//--- count the ticks
   ticks++;
//--- if ticks>N
   if(ticks>=N)
     {
      //--- change properties
      ChangeLineAppearance();
      //--- choose new symbol from "Market Watch"
      symbol=GetRandomSymbolName();
      //--- tries counter
      int tries=0;
      //--- try 5 times to copy symbol prices to the indicator buffer
      while(!CopyFromSymbolToBuffers(symbol,rates_total,0,
            Candle1Buffer1,Candle1Buffer2,Candle1Buffer3,Candle1Buffer4)
            && tries<5)
        {
         //--- increase the counter of CopyFromSymbolToBuffers() calls
         tries++;
        }
      //--- set tick counter to 0
      ticks=0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Sets the values of the indicator                                |
//+------------------------------------------------------------------+
bool CopyFromSymbolToBuffers(string name,
                             int total,
                             int plot_index,
                             double &buff1[],
                             double &buff2[],
                             double &buff3[],
                             double &buff4[]
                             )
  {
//--- used for Open, High, Low and Close prices 
   MqlRates rates[];
//--- attempts
   int attempts=0;
//--- bars copied
   int copied=0;
//--- try 25 attempts to get the data on symbol
   while(attempts<25 && (copied=CopyRates(name,_Period,0,bars,rates))<0)
     {
      Sleep(100);
      attempts++;
      if(messages) PrintFormat("%s CopyRates(%s) attempts=%d",__FUNCTION__,name,attempts);
     }
//--- if error in copying of bars data
   if(copied!=bars)
     {
      //--- prepare comment
      string comm=StringFormat("Copied only %d bars for the symbol %s from %d needed",
                               name,
                               copied,
                               bars
                               );
      //--- print comment on the chart window
      Comment(comm);
      //--- print comment to "Experts" log
      if(messages) Print(comm);
      return(false);
     }
   else
     {
      //--- set info
      PlotIndexSetString(plot_index,PLOT_LABEL,name+" Open;"+name+" High;"+name+" Low;"+name+" Close");
     }
//--- fill buffers with "empty" values
   ArrayInitialize(buff1,0.0);
   ArrayInitialize(buff2,0.0);
   ArrayInitialize(buff3,0.0);
   ArrayInitialize(buff4,0.0);
//--- copy prices to buffers
   for(int i=0;i<copied;i++)
     {
      //--- calc buffer index
      int buffer_index=total-copied+i;
      //--- copy prices
      buff1[buffer_index]=rates[i].open;
      buff2[buffer_index]=rates[i].high;
      buff3[buffer_index]=rates[i].low;
      buff4[buffer_index]=rates[i].close;
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Returns random symbol name from Market Watch                     |
//+------------------------------------------------------------------+
string GetRandomSymbolName()
  {
//--- number of symbols in "Market Watch" window
   int symbols=SymbolsTotal(true);
//--- calc symbol position - random number from 0 до symbols-1
   int number=MathRand()%symbols;
//--- return symbol name
   return SymbolName(number,true);
  }
//+------------------------------------------------------------------+
//| Changes the indicator properties                                 |
//+------------------------------------------------------------------+
void ChangeLineAppearance()
  {
//--- comment
   string comm="";
//--- color
   int number=MathRand(); // get random number
//--- get size
   int size=ArraySize(colors);
//--- select random color
   int color_index=number%size;
//--- set color as PLOT_LINE_COLOR property
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,colors[color_index]);
//--- add color to comment
   comm=comm+"\r\n"+(string)colors[color_index];
//--- add symbols to comment
   comm="\r\n"+symbol+comm;
//--- show comment
   Comment(comm);
  }
//+------------------------------------------------------------------+
