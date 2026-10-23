//+------------------------------------------------------------------+
//|                                         Directional_Breakout.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Directional Breakout indicator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "UP"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrOrange,clrSilver
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot DN
#property indicator_label2  "DN"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrRed,clrGold,clrSilver
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input uint                 InpPeriod         =  20;            // MA Period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // MA Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferUP[];
double         BufferColorsUP[];
double         BufferDN[];
double         BufferColorsDN[];
double         BufferMA[];
//--- global variables
int            period;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColorsUP,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(3,BufferColorsDN,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferMA,INDICATOR_COLOR_INDEX);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Directional Breakout ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferColorsUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferColorsDN,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") object was not created: Error ",GetLastError());
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
//ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double MA=BufferMA[i];
      BufferUP[i]=EMPTY_VALUE;
      BufferDN[i]=EMPTY_VALUE;
      BufferColorsUP[i]=BufferColorsDN[i]=2;
      BufferUP[i]=BufferMA[i];

      if(low[i]>MA)
        {
         BufferUP[i]=2;
         BufferColorsUP[i]=0;
         BufferDN[i]=0;
        }
      else
        {
         if(high[i]<MA)
           {
            BufferDN[i]=-2;
            BufferColorsDN[i]=0;
         BufferUP[i]=0;
           }
         else
           {
            BufferUP[i]=1.0;
            BufferDN[i]=-1.0;
            BufferColorsUP[i]=1;
            BufferColorsDN[i]=1;
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
