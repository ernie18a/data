//+------------------------------------------------------------------+
//|                                                   MA_Candles.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   1
//--- plot CandleMA
#property indicator_label1  "CandleMA"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrMediumSeaGreen,clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  10;                  // MA period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;            // MA method
input int                  InpShiftMA        =  0;                   // MA shift
input color                InpBullishColor   =  clrMediumSeaGreen;   // Bullish candles color
input color                InpBearishColor   =  clrOrange;           // Bearish candles color
//--- indicator buffers
double         BufferCandleOpen[];
double         BufferCandleHigh[];
double         BufferCandleLow[];
double         BufferCandleClose[];
double         BufferColors[];
double         BufferOpen[];
double         BufferHigh[];
double         BufferLow[];
double         BufferClose[];
//--- global variables
int            handle_open;
int            handle_high;
int            handle_low;
int            handle_close;
int            period;
int            shift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCandleOpen,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCandleHigh,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCandleLow,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCandleClose,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,BufferOpen,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferHigh,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferLow,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferClose,INDICATOR_CALCULATIONS);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCandleOpen,true);
   ArraySetAsSeries(BufferCandleHigh,true);
   ArraySetAsSeries(BufferCandleLow,true);
   ArraySetAsSeries(BufferCandleClose,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferOpen,true);
   ArraySetAsSeries(BufferHigh,true);
   ArraySetAsSeries(BufferLow,true);
   ArraySetAsSeries(BufferClose,true);
//--- settings plot and color buffers and indicators parameters
   for(uchar i=0; i<4; i++)
     {
      PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,0);
      PlotIndexSetInteger(i,PLOT_LINE_COLOR,0,InpBullishColor);
      PlotIndexSetInteger(i,PLOT_LINE_COLOR,1,InpBearishColor);
      PlotIndexSetInteger(i,PLOT_SHIFT,InpShiftMA);
     }
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Moving averages candles("+(string)period+")");
//--- create MA's handle
   ResetLastError();
   handle_open=iMA(Symbol(),PERIOD_CURRENT,period,0,InpMethod,PRICE_OPEN);
   if(handle_open==INVALID_HANDLE)
     {
      Print("The iMAbyOpen(",(string)period,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_high=iMA(Symbol(),PERIOD_CURRENT,period,0,InpMethod,PRICE_HIGH);
   if(handle_high==INVALID_HANDLE)
     {
      Print("The iMAbyHigh(",(string)period,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_low=iMA(Symbol(),PERIOD_CURRENT,period,0,InpMethod,PRICE_LOW);
   if(handle_low==INVALID_HANDLE)
     {
      Print("The iMAbyLow(",(string)period,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_close=iMA(Symbol(),PERIOD_CURRENT,period,0,InpMethod,PRICE_CLOSE);
   if(handle_close==INVALID_HANDLE)
     {
      Print("The iMAbyClose(",(string)period,") object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<period) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferCandleOpen,EMPTY_VALUE);
      ArrayInitialize(BufferCandleHigh,EMPTY_VALUE);
      ArrayInitialize(BufferCandleLow,EMPTY_VALUE);
      ArrayInitialize(BufferCandleClose,EMPTY_VALUE);
      ArrayInitialize(BufferColors,0);
      ArrayInitialize(BufferOpen,EMPTY_VALUE);
      ArrayInitialize(BufferHigh,EMPTY_VALUE);
      ArrayInitialize(BufferLow,EMPTY_VALUE);
      ArrayInitialize(BufferClose,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_open,0,0,count,BufferOpen);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_high,0,0,count,BufferHigh);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_low,0,0,count,BufferLow);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_close,0,0,count,BufferClose);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      BufferCandleOpen[i]=BufferOpen[i];
      BufferCandleHigh[i]=BufferHigh[i];
      BufferCandleLow[i]=BufferLow[i];
      BufferCandleClose[i]=BufferClose[i];
      if(BufferClose[i]<BufferOpen[i])
         BufferColors[i]=1;
      else
         BufferColors[i]=0;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
