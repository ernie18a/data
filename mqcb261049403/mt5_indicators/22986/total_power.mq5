//+------------------------------------------------------------------+
//|                                                  Total_Power.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Total Power indicator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot Power
#property indicator_label1  "Total Power"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot BearPower
#property indicator_label2  "Bear Power"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot BullPower
#property indicator_label3  "Bull Power"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriodPW =  40;   // Power period
input uint     InpPeriodMA =  10;   // EMA period
//--- indicator buffers
double         BufferPower[];
double         BufferPowerBear[];
double         BufferPowerBull[];
double         BufferEMA[];
//--- global variables
int            period_pw;
int            period_ma;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_pw=int(InpPeriodPW<1 ? 1 : InpPeriodPW);
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPower,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPowerBear,INDICATOR_DATA);
   SetIndexBuffer(2,BufferPowerBull,INDICATOR_DATA);
   SetIndexBuffer(3,BufferEMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Total Power ("+(string)period_pw+","+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPower,true);
   ArraySetAsSeries(BufferPowerBear,true);
   ArraySetAsSeries(BufferPowerBull,true);
   ArraySetAsSeries(BufferEMA,true);
//--- create handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_EMA,PRICE_CLOSE);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
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
//--- Проверка количества доступных баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_pw-1;
      ArrayInitialize(BufferPower,EMPTY_VALUE);
      ArrayInitialize(BufferPowerBear,EMPTY_VALUE);
      ArrayInitialize(BufferPowerBull,EMPTY_VALUE);
      ArrayInitialize(BufferEMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferEMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double BullCount=0;
      double BearCount=0;
      for(int j=0; j<=period_pw-1; j++)
        {
         if(high[i+j]>BufferEMA[i+j]) BullCount++;
         if(low[i+j]<BufferEMA[i+j]) BearCount++;
        }
      BufferPowerBull[i]=BullCount*100/period_pw;
      BufferPowerBear[i]=BearCount*100/period_pw;
      BufferPower[i]=fabs(BearCount-BullCount)*100/period_pw;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
