//+------------------------------------------------------------------+
//|                                               LBR_Paint_Bars.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "LBR Paint Bars indicator"
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_plots   4
//--- plot Cloud
#property indicator_label1  "Cloud edge1;Cloud edge2"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrMediumSeaGreen,clrCoral,clrDarkGray
#property indicator_style1  STYLE_DOT
#property indicator_width1  1
//--- plot Candle
#property indicator_label2  "Open;High;Low;Close"
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  clrGreen,clrRed,C'143,188,139',clrPeachPuff,clrDarkGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Line1
#property indicator_label3  "Line1"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkSeaGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Line2
#property indicator_label4  "Line2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrTan
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
enum ENUM_CANDLE_TYPE
  {
   CANDLE_TYPE_BULLISH, // Бычья свеча
   CANDLE_TYPE_BEARISH, // Медвежья свеча
   CANDLE_TYPE_DOJI     // Доджи
  };
//--- input parameters
input double            InpFactor      =  2.5;        // Factor
input uint              InpPeriodATR   =  9;          // ATR period
input uint              InpPeriodHL    =  16;         // HL period
input ENUM_INPUT_YES_NO InpShowCandles =  INPUT_YES;  // Color Candles
//--- indicator buffers
double         BufferCloud1[];
double         BufferCloud2[];
double         BufferColorsCloud[];
double         BufferCandleOpen[];
double         BufferCandleHigh[];
double         BufferCandleLow[];
double         BufferCandleClose[];
double         BufferColorsCandle[];
double         BufferLine1[];
double         BufferLine2[];
double         BufferATR[];
//--- global variables
double         factor;
int            period_atr;
int            period_hl;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_atr=int(InpPeriodATR<1 ? 1 : InpPeriodATR);
   period_hl=int(InpPeriodHL<1 ? 1 : InpPeriodHL);
   factor=fabs(InpFactor);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCloud1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCloud2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferColorsCloud,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,BufferCandleOpen,INDICATOR_DATA);
   SetIndexBuffer(4,BufferCandleHigh,INDICATOR_DATA);
   SetIndexBuffer(5,BufferCandleLow,INDICATOR_DATA);
   SetIndexBuffer(6,BufferCandleClose,INDICATOR_DATA);
   SetIndexBuffer(7,BufferColorsCandle,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(8,BufferLine1,INDICATOR_DATA);
   SetIndexBuffer(9,BufferLine2,INDICATOR_DATA);
   SetIndexBuffer(10,BufferATR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"LBR Paint Bars ("+DoubleToString(factor,1)+","+(string)period_atr+","+(string)period_hl+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCloud1,true);
   ArraySetAsSeries(BufferCloud2,true);
   ArraySetAsSeries(BufferColorsCloud,true);
   ArraySetAsSeries(BufferCandleOpen,true);
   ArraySetAsSeries(BufferCandleHigh,true);
   ArraySetAsSeries(BufferCandleLow,true);
   ArraySetAsSeries(BufferCandleClose,true);
   ArraySetAsSeries(BufferColorsCandle,true);
   ArraySetAsSeries(BufferLine1,true);
   ArraySetAsSeries(BufferLine2,true);
   ArraySetAsSeries(BufferATR,true);
//--- create MA's handles
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_atr);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atr,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
   if(rates_total<fmax(period_hl,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_hl-1;
      ArrayInitialize(BufferCloud1,EMPTY_VALUE);
      ArrayInitialize(BufferCloud2,EMPTY_VALUE);
      ArrayInitialize(BufferColorsCloud,2);
      ArrayInitialize(BufferCandleOpen,EMPTY_VALUE);
      ArrayInitialize(BufferCandleHigh,EMPTY_VALUE);
      ArrayInitialize(BufferCandleLow,EMPTY_VALUE);
      ArrayInitialize(BufferCandleClose,EMPTY_VALUE);
      ArrayInitialize(BufferColorsCandle,4);
      ArrayInitialize(BufferLine1,EMPTY_VALUE);
      ArrayInitialize(BufferLine2,EMPTY_VALUE);
      ArrayInitialize(BufferATR,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double ATR=BufferATR[i];
      double delta=factor*ATR;
      int bl=Lowest(period_hl,i);
      int bh=Highest(period_hl,i);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         return 0;
      double min=low[bl];
      double max=high[bh];

      BufferLine1[i]=BufferCloud1[i]=min+delta;
      BufferLine2[i]=BufferCloud2[i]=max-delta;
      BufferColorsCloud[i]=(BufferCloud1[i]>BufferCloud2[i] ? 0 : BufferCloud1[i]<BufferCloud2[i] ? 1 : 2);
      
      bool UpperVolatility=(close[i]>BufferCloud1[i] && close[i]>BufferCloud2[i] ? true : false);
      bool LowerVolatility=(close[i]<BufferCloud1[i] && close[i]<BufferCloud2[i] ? true : false);

      if(InpShowCandles)
        {
         ENUM_CANDLE_TYPE type=CandleType(i,open,close);
         BufferCandleOpen[i]=open[i];
         BufferCandleHigh[i]=high[i];
         BufferCandleLow[i]=low[i];
         BufferCandleClose[i]=close[i];
         if(UpperVolatility)
            BufferColorsCandle[i]=(type==CANDLE_TYPE_BULLISH ? 0 : type==CANDLE_TYPE_BEARISH ? 2 : 4);
         else
           {
            if(LowerVolatility)
               BufferColorsCandle[i]=(type==CANDLE_TYPE_BEARISH ? 1 : type==CANDLE_TYPE_BULLISH ? 3 : 4);
            else
               BufferColorsCandle[i]=(4);
           }
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start,const bool as_series=true)
  {
   double array[];
   ArraySetAsSeries(array,as_series);
   return(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start,const bool as_series=true)
  {
   double array[];
   ArraySetAsSeries(array,as_series);
   return(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает тип свечи                                             |
//+------------------------------------------------------------------+
ENUM_CANDLE_TYPE CandleType(const int index,const double &open[],const double &close[])
  {
   return(close[index]>open[index] ? CANDLE_TYPE_BULLISH : close[index]<open[index] ? CANDLE_TYPE_BEARISH : CANDLE_TYPE_DOJI);
  }
//+------------------------------------------------------------------+
