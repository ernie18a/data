//+------------------------------------------------------------------+
//|                                         Trend_Risk_Indicator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trend Risk indicator"
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   4
//--- plot Top
#property indicator_label1  "Top"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCadetBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Bottom
#property indicator_label2  "Bottom"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCadetBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Candles
#property indicator_label3  "Open;High;Low;Close"
#property indicator_type3   DRAW_COLOR_CANDLES
#property indicator_color3  clrGreen,clrRed,clrYellowGreen,clrOrangeRed,clrDarkGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Signal
#property indicator_label4  "Signal"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrNONE
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input uint     InpPeriodBands =  28;   // Bands range
input double   InpDeviation   =  3.5;  // Deviation
//--- indicator buffers
double         BufferTop[];
double         BufferBottom[];
double         BufferCandleOpen[];
double         BufferCandleHigh[];
double         BufferCandleLow[];
double         BufferCandleClose[];
double         BufferColors[];
double         BufferSmoothPrice[];
double         BufferSmoothRange[];
double         BufferNoTrade[];
//--- global variables
int            period_bands;
double         deviation;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_bands=int(InpPeriodBands<1 ? 1 : InpPeriodBands);
   deviation=InpDeviation;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCandleOpen,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCandleHigh,INDICATOR_DATA);
   SetIndexBuffer(4,BufferCandleLow,INDICATOR_DATA);
   SetIndexBuffer(5,BufferCandleClose,INDICATOR_DATA);
   SetIndexBuffer(6,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(7,BufferNoTrade,INDICATOR_DATA);
   SetIndexBuffer(8,BufferSmoothPrice,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferSmoothRange,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend Risk Indicator ("+(string)period_bands+","+DoubleToString(deviation,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferCandleOpen,true);
   ArraySetAsSeries(BufferCandleHigh,true);
   ArraySetAsSeries(BufferCandleLow,true);
   ArraySetAsSeries(BufferCandleClose,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferNoTrade,true);
   ArraySetAsSeries(BufferSmoothPrice,true);
   ArraySetAsSeries(BufferSmoothRange,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferCandleOpen,EMPTY_VALUE);
      ArrayInitialize(BufferCandleHigh,EMPTY_VALUE);
      ArrayInitialize(BufferCandleLow,EMPTY_VALUE);
      ArrayInitialize(BufferCandleClose,EMPTY_VALUE);
      ArrayInitialize(BufferColors,4);
      ArrayInitialize(BufferNoTrade,EMPTY_VALUE);
      ArrayInitialize(BufferSmoothPrice,0);
      ArrayInitialize(BufferSmoothRange,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-1)
        {
         BufferSmoothPrice[i]=close[i];
         BufferSmoothRange[i]=high[i]-low[i];
        }
      else
        {
         BufferSmoothPrice[i]=(BufferSmoothPrice[i+1]*(period_bands-1)+close[i])/period_bands;
         BufferSmoothRange[i]=(BufferSmoothRange[i+1]*(period_bands-1)+high[i]-low[i])/period_bands;
        }

      BufferTop[i]=BufferSmoothPrice[i]+BufferSmoothRange[i]*deviation;
      BufferBottom[i]=BufferSmoothPrice[i]-BufferSmoothRange[i]*deviation;
      
      BufferCandleOpen[i]=open[i];
      BufferCandleHigh[i]=high[i];
      BufferCandleLow[i]=low[i];
      BufferCandleClose[i]=close[i];
      
      BufferNoTrade[i]=EMPTY_VALUE;
      BufferColors[i]=(BufferCandleClose[i]>BufferCandleOpen[i] ? 0 : BufferCandleClose[i]<BufferCandleOpen[i] ? 1 : 4);
      if(close[i]>BufferTop[i])
        {
         BufferColors[i]=4;
         BufferNoTrade[i]=BufferTop[i];
         PlotIndexSetString(3,PLOT_LABEL,"Do not trade");   // Можно вписать "Do not Buy" при торговле по тренду (вероятно замедление восходящего тренда)
        }
      else if(close[i]<BufferBottom[i])
        {
         BufferColors[i]=4;
         BufferNoTrade[i]=BufferBottom[i];
         PlotIndexSetString(3,PLOT_LABEL,"Do not trade");   // Можно вписать "Do not Sell" при торговле по тренду (вероятно замедление нисходящего тренда)
        }
      else
         PlotIndexSetString(3,PLOT_LABEL,"Trade allowed");
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
