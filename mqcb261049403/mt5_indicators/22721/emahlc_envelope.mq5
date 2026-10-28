//+------------------------------------------------------------------+
//|                                              EMAHLC_Envelope.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "EMA HLC Envelope indicator"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5
//--- plot ArrowTop
#property indicator_label1  "High broken"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot ArrowBottom
#property indicator_label2  "Low broken"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDarkOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot EMAH
#property indicator_label3  "EMA High Env"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLime
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot EMAC
#property indicator_label4  "EMA Close Env"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkGray
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot EMAL
#property indicator_label5  "EMA Low Env"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- input parameters
input uint     InpPeriod   =  14;   // Period
//--- indicator buffers
double         BufferArrowTop[];
double         BufferArrowBottom[];
double         BufferMAH[];
double         BufferMAC[];
double         BufferMAL[];
//--- global variables
int            period;
int            handle_mah;
int            handle_mal;
int            handle_mac;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferArrowTop,INDICATOR_DATA);
   SetIndexBuffer(1,BufferArrowBottom,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMAH,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMAC,INDICATOR_DATA);
   SetIndexBuffer(4,BufferMAL,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,158);
   PlotIndexSetInteger(1,PLOT_ARROW,158);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"EMA HLC Envelope ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferArrowTop,true);
   ArraySetAsSeries(BufferArrowBottom,true);
   ArraySetAsSeries(BufferMAH,true);
   ArraySetAsSeries(BufferMAC,true);
   ArraySetAsSeries(BufferMAL,true);
//--- create MA's handles
   ResetLastError();
   handle_mah=iMA(NULL,PERIOD_CURRENT,period,0,MODE_EMA,PRICE_HIGH);
   if(handle_mah==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mac=iMA(NULL,PERIOD_CURRENT,period,0,MODE_EMA,PRICE_CLOSE);
   if(handle_mac==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_CLOSE object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mal=iMA(NULL,PERIOD_CURRENT,period,0,MODE_EMA,PRICE_LOW);
   if(handle_mal==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_LOW object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferArrowTop,EMPTY_VALUE);
      ArrayInitialize(BufferArrowBottom,EMPTY_VALUE);
      ArrayInitialize(BufferMAH,EMPTY_VALUE);
      ArrayInitialize(BufferMAC,EMPTY_VALUE);
      ArrayInitialize(BufferMAL,EMPTY_VALUE);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_mah,0,0,count,BufferMAH);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mac,0,0,count,BufferMAC);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mal,0,0,count,BufferMAL);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferArrowTop[i]=BufferArrowBottom[i]=EMPTY_VALUE;
      if(high[i]>BufferMAH[i]) BufferArrowTop[i]=high[i];
      if(low[i]<BufferMAL[i])  BufferArrowBottom[i]=low[i];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
