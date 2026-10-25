//+------------------------------------------------------------------+
//|                                                         GHLA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Gann HiLo Activator indicator"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot GHLA
#property indicator_label1  "GHLA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriod   =  10;   // Period
//--- indicator buffers
double         BufferGHLA[];
double         BufferColors[];
double         BufferMAH[];
double         BufferMAL[];
double         BufferDir[];
//--- global variables
int            period;
int            handle_mah;
int            handle_mal;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferGHLA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMAH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMAL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferDir,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Gann HiLo Activator ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferGHLA,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMAH,true);
   ArraySetAsSeries(BufferMAL,true);
   ArraySetAsSeries(BufferDir,true);
//--- create MA's handles
   ResetLastError();
   handle_mah=iMA(NULL,PERIOD_CURRENT,period,0,MODE_SMA,PRICE_HIGH);
   if(handle_mah==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mal=iMA(NULL,PERIOD_CURRENT,period,0,MODE_SMA,PRICE_LOW);
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
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferGHLA,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferMAH,0);
      ArrayInitialize(BufferMAL,0);
      ArrayInitialize(BufferDir,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_mah,0,0,count,BufferMAH);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mal,0,0,count,BufferMAL);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double avgH=BufferMAH[i];
      double avgL=BufferMAL[i];
      int sw=(close[i]>avgH ? 1 : close[i]<avgL ? -1 : 0);
      BufferDir[i]=(sw!=0 ? sw : BufferDir[i+1]);
      if(BufferDir[i]<0)
        {
         BufferGHLA[i]=avgH;
         BufferColors[i]=1;
        }
      else
        {
         BufferGHLA[i]=avgL;
         BufferColors[i]=0;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
