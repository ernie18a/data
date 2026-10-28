//+------------------------------------------------------------------+
//|                                            Bollinger Colored.mq5 |
//|                                        Copyright 2025, Swordless |
//|                                      https://www.xj-ventures.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Swordless"
#property link      "https://www.mql5.com/zh/users/xwj-ventures"
#property version   "1.1"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3

//--- drawing setup
#property indicator_label1  "MiddleBand"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrRed,clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "UpperBand"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrRed,clrLimeGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "LowerBand"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrRed,clrLimeGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//--- inputs
input int      BandsPeriod=20;     // period
input double   Deviation=2.0;      // deviation
input int      BandsShift=0;       // shift

//--- buffers
double MiddleBuffer[];
double UpperBuffer[];
double LowerBuffer[];
double ColorMiddle[];
double ColorUpper[];
double ColorLower[];
int    handleBands;

//+------------------------------------------------------------------+
//| Oninit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setup buffers
   SetIndexBuffer(0,MiddleBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorMiddle,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,UpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ColorUpper,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,LowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ColorLower,INDICATOR_COLOR_INDEX);
//--- setup plots
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,BandsPeriod);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,BandsPeriod);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,BandsPeriod);
//--- get handle
   handleBands=iBands(_Symbol,_Period,BandsPeriod,BandsShift,Deviation,PRICE_CLOSE);
   if(handleBands==INVALID_HANDLE)
     {
      Print("Failed to create Bollinger Bands!");
      return(INIT_FAILED);
     }
//--- set arrays
   ArraySetAsSeries(UpperBuffer,true);
   ArraySetAsSeries(MiddleBuffer,true);
   ArraySetAsSeries(LowerBuffer,true);
   ArraySetAsSeries(ColorUpper,true);
   ArraySetAsSeries(ColorMiddle,true);
   ArraySetAsSeries(ColorLower,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| OnCalculate                                                      |
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
//--- copy data
   if(CopyBuffer(handleBands,0,0,rates_total,MiddleBuffer)<=0)
      return(0);
   if(CopyBuffer(handleBands,1,0,rates_total,UpperBuffer)<=0)
      return(0);
   if(CopyBuffer(handleBands,2,0,rates_total,LowerBuffer)<=0)
      return(0);

//--- calculate colors
   int limit = rates_total - prev_calculated;
   if(prev_calculated > 0)
      limit++;

   for(int i=limit-1; i>=0; i--)
     {
      if(i>=rates_total-1)
        {
         // use same color for new bars
         ColorUpper[i] = 0;
         ColorMiddle[i] = 0;
         ColorLower[i] = 0;
         continue;
        }
      double currentWidth = UpperBuffer[i] - LowerBuffer[i];
      double prevWidth = UpperBuffer[i+1] - LowerBuffer[i+1];

      // set color index（0=red，1=green）
      int colorIndex= (currentWidth >= prevWidth) ? 1:0;

      ColorUpper[i]=colorIndex;
      ColorMiddle[i]=colorIndex;
      ColorLower[i]=colorIndex;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
