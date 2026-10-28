//+------------------------------------------------------------------+
//|                                             BarsMaxMinSystem.mq5 |
//|                                            Copyright 2012, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Rone"
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "Indicator for three-bars system of maximums/minimums by Larry Williams"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 12
#property indicator_plots   4
//--- plot Candle
#property indicator_label1  "Candle Open;Candle High;Candle Low;Candle Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGreen,clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot BaseMa
#property indicator_label2  "Up Trend MA;Down Trend MA"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrBlue,clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
//--- plot HighMa
#property indicator_label3  "High MA"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot LowMa
#property indicator_label4  "Low MA"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrTomato
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//--- input parameters
input ENUM_MA_METHOD InpMaMethod=MODE_SMA;   // MA method (for all)
input int            InpTrendMaPeriod=10;    // Trend МА period
input int            InpHighMaPeriod=3;      // High МА period
input int            InpLowMaPeriod=3;       // Low МА period
//--- indicator buffers
double         CandleOpenBuffer[];
double         CandleHighBuffer[];
double         CandleLowBuffer[];
double         CandleCloseBuffer[];
double         CandleColors[];
double         TrendMaBuffer[];
double         TrendMaColors[];
double         HighMaBuffer[];
double         LowMaBuffer[];
double         MaBuffer[];
double         HMaBuffer[];
double         LMaBuffer[];
//--- global variables
int            minRequiredBars;
int            maHandle,highMaHandle,lowMaHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() 
  {
//---
   minRequiredBars=MathMax(InpTrendMaPeriod,MathMax(InpHighMaPeriod,InpLowMaPeriod));
//--- indicator buffers mapping
   SetIndexBuffer(0,CandleOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CandleHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,CandleLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,CandleCloseBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,CandleColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,TrendMaBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,TrendMaColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(7,HighMaBuffer,INDICATOR_DATA);
   SetIndexBuffer(8,LowMaBuffer,INDICATOR_DATA);
   SetIndexBuffer(9,MaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,HMaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,LMaBuffer,INDICATOR_CALCULATIONS);
//---
   for(int i=0; i<9; i++) 
     {
      PlotIndexSetInteger(i,PLOT_DRAW_BEGIN,minRequiredBars);
      PlotIndexSetInteger(i,PLOT_SHIFT,0);
      PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,EMPTY_VALUE);
     }
//---
   string shortname="BarsMaxMinSystem ("+(string)InpTrendMaPeriod+", "+(string)InpHighMaPeriod+", "+
                    (string)InpLowMaPeriod+")";
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
   maHandle=iMA(_Symbol,_Period,InpTrendMaPeriod,0,InpMaMethod,PRICE_CLOSE);
   highMaHandle= iMA(_Symbol,_Period,InpHighMaPeriod,0,InpMaMethod,PRICE_HIGH);
   lowMaHandle = iMA(_Symbol,_Period,InpLowMaPeriod,0,InpMaMethod,PRICE_LOW);
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
//---
   int startBar;
//---
   if(rates_total<minRequiredBars) 
     {
      Print("Not enough bars for the calculation.");
      return(0);
     }
//---
   if(prev_calculated>rates_total || prev_calculated<=0) 
     {
      if(CopyBuffer(maHandle,0,0,rates_total,MaBuffer)<=0
         || CopyBuffer(highMaHandle,0, 0, rates_total, HMaBuffer) <= 0
         || CopyBuffer(lowMaHandle, 0, 0, rates_total, LMaBuffer) <= 0 )
        {
         Print("Indicator data copy error.");
         return(0);
        }
      startBar=minRequiredBars;
        } else {
      int toCopy=rates_total-prev_calculated;

      if(toCopy==0) 
        {
         toCopy= 1;
        }
      if(CopyBuffer(maHandle,0,0,toCopy,MaBuffer)<toCopy
         || CopyBuffer(highMaHandle,0,0,toCopy,HMaBuffer)<toCopy
         || CopyBuffer(lowMaHandle,0,0,toCopy,LMaBuffer)<toCopy)
        {
         Print("Indicator data copy error.");
         return(0);
        }
      startBar=prev_calculated-1;
     }
//---
   for(int bar=startBar; bar<rates_total && !IsStopped(); bar++) 
     {
      double maValue=MaBuffer[bar];

      HighMaBuffer[bar]= HMaBuffer[bar]-maValue;
      LowMaBuffer[bar] = LMaBuffer[bar]-maValue;
      //---
      CandleOpenBuffer[bar] = open[bar] - maValue;
      CandleHighBuffer[bar] = high[bar] - maValue;
      CandleLowBuffer[bar]=low[bar]-maValue;
      CandleCloseBuffer[bar]=close[bar]-maValue;
      CandleColors[bar]=0;
      if(CandleCloseBuffer[bar]<CandleOpenBuffer[bar]) 
        {
         CandleColors[bar]=1;
        }
      //---
      TrendMaBuffer[bar] = 0.0;
      TrendMaColors[bar] = 0;
      if(MaBuffer[bar]<MaBuffer[bar-1]) 
        {
         TrendMaColors[bar]=1;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
