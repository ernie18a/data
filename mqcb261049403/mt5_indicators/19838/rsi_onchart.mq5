//+------------------------------------------------------------------+
//|                                                  RSI_OnChart.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4
//--- plot Middle
#property indicator_label3  "Middle"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Upper
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Lower
#property indicator_label2  "Lower"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot RSI
#property indicator_label4  "RSI"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDodgerBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input uint                 InpPeriodRSI         =  14;            // Period RSI
input ENUM_APPLIED_PRICE   InpAppliedPriceRSI   =  PRICE_CLOSE;   // Applied price RSI
input uint                 InpOverBought        =  70;            // Level of overbought
input uint                 InpOverSold          =  30;            // Level of oversold
input double               InpCoeffATR          =  5.0;           // Coefficient of ATR
input uint                 InpPeriodMA          =  20;            // Period MA
input ENUM_MA_METHOD       InpMethodMA          =  MODE_SMA;      // Calculation method MA
input ENUM_APPLIED_PRICE   InpAppliedPriceMA    =  PRICE_CLOSE;   // Applied price MA
//--- indicator buffers
double         BufferMiddle[];
double         BufferUpper[];
double         BufferLower[];
double         BufferRSI[];
double         BufferATR[];
double         BufferTempRSI[];
//--- global variables
double         coeff;
int            period_rsi;
int            period_ma;
int            handle_ma;
int            handle_rsi;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMiddle,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUpper,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLower,INDICATOR_DATA);
   SetIndexBuffer(3,BufferRSI,INDICATOR_DATA);
   SetIndexBuffer(4,BufferATR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferTempRSI,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI on chart");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMiddle,true);
   ArraySetAsSeries(BufferUpper,true);
   ArraySetAsSeries(BufferLower,true);
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferATR,true);
   ArraySetAsSeries(BufferTempRSI,true);
//--- set global variables
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   period_rsi=int(InpPeriodRSI<1 ? 1 : InpPeriodRSI);
   coeff=(InpCoeffATR<0.1 ? 0.1 : InpCoeffATR);
//--- creating handles of MA, ATR and RSI
   ResetLastError();
   handle_atr=iATR(Symbol(),PERIOD_CURRENT,period_ma);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("Error creating ATR's handle: ",GetLastError());
     }
   ResetLastError();
   handle_ma=iMA(Symbol(),PERIOD_CURRENT,period_ma,0,InpMethodMA,InpAppliedPriceMA);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("Error creating MA's handle: ",GetLastError());
     }
   ResetLastError();
   handle_rsi=iRSI(Symbol(),PERIOD_CURRENT,period_rsi,InpAppliedPriceRSI);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("Error creating RSI's handle: ",GetLastError());
     }

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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferMiddle,EMPTY_VALUE);
      ArrayInitialize(BufferUpper,EMPTY_VALUE);
      ArrayInitialize(BufferLower,EMPTY_VALUE);
      ArrayInitialize(BufferRSI,EMPTY_VALUE);
      ArrayInitialize(BufferATR,EMPTY_VALUE);
      ArrayInitialize(BufferTempRSI,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=(limit>1 ? rates_total : 1);
   int copied_ma=CopyBuffer(handle_ma,0,0,copied,BufferMiddle);
   if(copied_ma!=copied) return 0;
   int copied_atr=CopyBuffer(handle_atr,0,0,copied,BufferATR);
   if(copied_atr!=copied) return 0;
   int copied_rsi=CopyBuffer(handle_rsi,0,0,copied,BufferTempRSI);
   if(copied_rsi!=copied) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      double atr=BufferATR[i]*coeff;
      BufferUpper[i]=BufferMiddle[i]+atr*(InpOverBought-50)/100.0;
      BufferLower[i]=BufferMiddle[i]-atr*(50-InpOverSold)/100.0;
      BufferRSI[i]=BufferMiddle[i]+atr*(BufferTempRSI[i]-50)/100.0;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
