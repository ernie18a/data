//+------------------------------------------------------------------+
//|                                  ColorCandles_SeparateWindow.mq5 |
//+------------------------------------------------------------------+
#property copyright "2012, Karlson."
#property link      "https://www.mql5.com/en/users/karlson"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
#property indicator_width1  2
//--- inputs
int      bars=500;                            // Bars
input string symbol="GBPUSD";                 // Symbol
input ENUM_DRAW_TYPE type=DRAW_COLOR_CANDLES; // Type  
//--- indicators buffers
double         ColorCandlesBuffer1[];
double         ColorCandlesBuffer2[];
double         ColorCandlesBuffer3[];
double         ColorCandlesBuffer4[];
double         ColorCandlesColors[];
//--- web colors
color col[56]=
  {
   clrBlack,clrDarkGreen,clrDarkSlateGray,clrOlive,clrGreen,
   clrTeal,clrNavy,clrPurple,clrMaroon,clrIndigo,clrDarkBlue,
   clrDarkOliveGreen,clrSaddleBrown,clrForestGreen,clrOliveDrab,
   clrSeaGreen,clrDarkGoldenrod,clrDarkSlateBlue,clrSienna,clrMediumBlue,
   clrBrown,clrDarkTurquoise,clrDimGray,clrLightSeaGreen,clrDarkViolet,
   clrFireBrick,clrMediumVioletRed,clrMediumSeaGreen,clrChocolate,clrCrimson,
   clrSteelBlue,clrGoldenrod,clrMediumSpringGreen,clrLawnGreen,clrCadetBlue,
   clrDarkOrchid,clrYellowGreen,clrLimeGreen,clrOrangeRed,clrDarkOrange,
   clrOrange,clrChartreuse,clrLime,clrDeepSkyBlue,clrBlue,clrMagenta,clrRed,
   clrSlateGray,clrPeru,clrBlueViolet,clrDeepPink,clrMediumTurquoise,
   clrDodgerBlue,clrTurquoise,clrRoyalBlue,clrSlateBlue
  };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ColorCandlesBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ColorCandlesBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ColorCandlesBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,ColorCandlesBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,ColorCandlesColors,INDICATOR_COLOR_INDEX);
//---
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,3);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,col[GetNumber()]);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,col[GetNumber()+28]);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,clrBlack);
//---
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,type);
   PlotIndexSetString(0,PLOT_LABEL,symbol+" Open;"+symbol+" High;"+symbol+" Low;"+symbol+" Close");
   IndicatorSetString(INDICATOR_SHORTNAME,"DCC("+symbol+")");
//---
   return(0);
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
   int tries=0;
//--- 5 attempts to fill plot buffers with prices of symbol
   while(!CopyFromSymbolToBuffers(symbol,rates_total,
         ColorCandlesBuffer1,ColorCandlesBuffer2,ColorCandlesBuffer3,
         ColorCandlesBuffer4,ColorCandlesColors)
         && tries<5)
     {
      //--- tries counter (calls of CopyFromSymbolToBuffers())
      Print("tries=",tries);
      tries++;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Fills buffers with data                                          |
//+------------------------------------------------------------------+
bool CopyFromSymbolToBuffers(string name,
                             int total,
                             double &buff1[],
                             double &buff2[],
                             double &buff3[],
                             double &buff4[],
                             double &col_buffer[])
  {
//--- Open, High, Low and Close are copied to rates[] array
   MqlRates rates[];
//--- attempts
   int attempts=0;
//--- data copied
   int copied=0;

//--- perform 25 attempts попыток to get timeseries on specified symbol
   while(attempts<25 && (copied=CopyRates(name,_Period,0,bars,rates))<bars)
     {
      Sleep(100);
      attempts++;
      //Print("attempts=",attempts);
     }

//--- initialize buffers
   ArrayInitialize(buff1,0.0);
   ArrayInitialize(buff2,0.0);
   ArrayInitialize(buff3,0.0);
   ArrayInitialize(buff4,0.0);
//--- copy data at each tick
   for(int i=0;i<copied;i++)
     {
      //--- calc index
      int buffer_index=total-copied+i;
      //--- fill buffers data
      buff1[buffer_index]=rates[i].open;
      buff2[buffer_index]=rates[i].high;
      buff3[buffer_index]=rates[i].low;
      buff4[buffer_index]=rates[i].close;

      if(buff1[buffer_index]<buff4[buffer_index]) {col_buffer[buffer_index]=0.0;} else {col_buffer[buffer_index]=2.0;}
      if(buff1[buffer_index]>buff4[buffer_index]) {col_buffer[buffer_index]=1.0;}
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| GetNumber                                                        |
//+------------------------------------------------------------------+
int GetNumber()
  {
   MathSrand(GetTickCount());
   int col_index=(int)MathRand()/1220;
   if(GetLastError()>0) {Print("Error(CustomColor)=",GetLastError());}
   return(col_index);
  }
//+------------------------------------------------------------------+
