//+------------------------------------------------------------------+
//|                                                Keltner_Cloud.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   5
//--- plot UpperCloud
#property indicator_label1  "UpperCloud"
#property indicator_type1   DRAW_HISTOGRAM2
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot LowerCloud
#property indicator_label2  "LowerCloud"
#property indicator_type2   DRAW_HISTOGRAM2
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Upper
#property indicator_label3  "Upper"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMagenta
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Middle
#property indicator_label4  "Middle"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrCyan
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Lower
#property indicator_label5  "Lower"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrYellow
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- input parameters
input uint                 InpPeriodMA       =  50;            // Number of the periods to smooth the center line
input uint                 InpPeriodDev      =  50;            // Number of periods to smooth deviation
input double               InpF              =  1.0;           // Factor which is used to apply the deviation
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // The center line applied price:
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // The center line smoothing method
//--- indicator buffers
double         BufferUpperCloud1[];
double         BufferUpperCloud2[];
double         BufferLowerCloud1[];
double         BufferLowerCloud2[];
double         BufferUpper[];
double         BufferMiddle[];
double         BufferLower[];
double         BufferATR[];
//--- global variables
int            period_ma;
int            period_dev;
int            handle_ma;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUpperCloud1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUpperCloud2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLowerCloud1,INDICATOR_DATA);
   SetIndexBuffer(3,BufferLowerCloud2,INDICATOR_DATA);
   SetIndexBuffer(4,BufferUpper,INDICATOR_DATA);
   SetIndexBuffer(5,BufferMiddle,INDICATOR_DATA);
   SetIndexBuffer(6,BufferLower,INDICATOR_DATA);
   SetIndexBuffer(7,BufferATR,INDICATOR_CALCULATIONS);
//--- setings indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Keltner with color zones");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- Set the direction of array indexing as in timeseries
   ArraySetAsSeries(BufferLower,true);
   ArraySetAsSeries(BufferLowerCloud1,true);
   ArraySetAsSeries(BufferLowerCloud2,true);
   ArraySetAsSeries(BufferMiddle,true);
   ArraySetAsSeries(BufferUpper,true);
   ArraySetAsSeries(BufferUpperCloud1,true);
   ArraySetAsSeries(BufferUpperCloud2,true);
   ArraySetAsSeries(BufferATR,true);
//--- setings parameters
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   period_dev=int(InpPeriodDev<1 ? 1 : InpPeriodDev);
//--- MA and ATR handles
   ResetLastError();
   handle_ma=iMA(Symbol(),PERIOD_CURRENT,period_ma,0,InpMethod,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_atr=iATR(Symbol(),PERIOD_CURRENT,period_dev);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int copied_ma=0,copied_atr=0,limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferLower,EMPTY_VALUE);
      ArrayInitialize(BufferLowerCloud1,EMPTY_VALUE);
      ArrayInitialize(BufferLowerCloud2,EMPTY_VALUE);
      ArrayInitialize(BufferMiddle,EMPTY_VALUE);
      ArrayInitialize(BufferUpper,EMPTY_VALUE);
      ArrayInitialize(BufferUpperCloud1,EMPTY_VALUE);
      ArrayInitialize(BufferUpperCloud2,EMPTY_VALUE);
      ArrayInitialize(BufferATR,EMPTY_VALUE);
      copied_ma=CopyBuffer(handle_ma,0,0,rates_total,BufferMiddle);
      if(copied_ma!=rates_total) return 0;
      copied_atr=CopyBuffer(handle_atr,0,0,rates_total,BufferATR);
      if(copied_atr!=rates_total) return 0;
     }
//--- Подготовка данных
   int copied=(limit>1 ? rates_total : 1);
   copied_ma=CopyBuffer(handle_ma,0,0,copied,BufferMiddle);
   if(copied_ma!=copied) return 0;
   copied_atr=CopyBuffer(handle_atr,0,0,copied,BufferATR);
   if(copied_atr!=copied) return 0;
//--- Цикл расчёта индикатора
   for(int i=limit; i>=0; i--)
     {
      BufferUpperCloud1[i]=BufferUpper[i]=BufferMiddle[i]+BufferATR[i]*InpF;
      BufferUpperCloud2[i]=BufferLowerCloud1[i]=BufferMiddle[i];
      BufferLowerCloud2[i]=BufferLower[i]=BufferMiddle[i]-BufferATR[i]*InpF;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
