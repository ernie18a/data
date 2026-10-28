//+------------------------------------------------------------------+
//|                                                      WAVE_PM.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Whistler's Active Volatility Energy - Price Mass indicator"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   2
//--- plot OscFast
#property indicator_label1  "Fast Osc"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot OscSlow
#property indicator_label2  "Slow Osc"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriodFast  =  14;   // Fast bands period
input uint     InpShiftFast   =  0;    // Fast bands shift
input double   InpDevFast     =  2.2;  // Fast bands deviation
input uint     InpPeriodSlow  =  55;   // Slow bands period
input uint     InpShiftSlow   =  0;    // Slow bands shift
input double   InpDevSlow     =  2.2;  // Slow bands deviation
input uint     InpChars       =  100;  // Chars
input double   InpOverbought  =  0.8;  // Extreme top level
input double   InpLevelTop    =  0.7;  // Top level
input double   InpCentral     =  0.5;  // Central level
input double   InpLevelBottom =  0.3;  // Bottom level
input double   InpOversold    =  0.2;  // Extreme bottom level
//--- indicator buffers
double         BufferFastOsc[];
double         BufferSlowOsc[];
double         BufferFastDev[];
double         BufferFastDev1[];
double         BufferSlowDev[];
double         BufferSlowDev1[];
double         BufferFMA[];
double         BufferSMA[];
//--- global variables
double         lev_highest;
double         lev_top;
double         central;
double         lev_bottom;
double         lev_lowest;
double         dev_fast;
double         dev_slow;
int            period_fast;
int            shift_fast;
int            period_slow;
int            shift_slow;
int            chars;
int            period_max;
int            handle_fma;
int            handle_sma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   shift_fast=int(InpShiftFast);
   shift_slow=int(InpShiftSlow);
   dev_fast=InpDevFast;
   dev_slow=InpDevSlow;
   chars=int(InpChars<2 ? 2 : InpChars);
   period_max=fmax(chars,fmax(period_fast,fmax(period_slow,fmax(shift_fast,shift_slow))));
   lev_highest=(InpOverbought>1 ? 1 : InpOverbought<0.04 ? 0.04 : InpOverbought);
   lev_top=(InpLevelTop>=lev_highest ? lev_highest-0.01 : InpLevelTop<0.03 ? 0.03 : InpLevelTop);
   central=(InpCentral>=lev_top ? lev_top-0.01 : InpCentral<0.02 ? 0.02 : InpCentral);
   lev_bottom=(InpLevelBottom>=central ? central-0.01 : InpLevelBottom<0.01 ? 0.01 : InpLevelBottom);
   lev_lowest=(InpOversold<0 ? 0 : InpOversold>=lev_bottom ? lev_bottom-0.01 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferFastOsc,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSlowOsc,INDICATOR_DATA);
   SetIndexBuffer(2,BufferFastDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferFastDev1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSlowDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSlowDev1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferSMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"WAVE-PM");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,5);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,lev_highest);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,lev_top);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,central);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,lev_bottom);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,4,lev_lowest);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferFastOsc,true);
   ArraySetAsSeries(BufferSlowOsc,true);
   ArraySetAsSeries(BufferFastDev,true);
   ArraySetAsSeries(BufferFastDev1,true);
   ArraySetAsSeries(BufferSlowDev,true);
   ArraySetAsSeries(BufferSlowDev1,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
//--- create handles
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fast,0,MODE_SMA,PRICE_CLOSE);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_fast,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_slow,0,MODE_SMA,PRICE_CLOSE);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_slow,") object was not created: Error ",GetLastError());
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-1;
      ArrayInitialize(BufferFastOsc,EMPTY_VALUE);
      ArrayInitialize(BufferSlowOsc,EMPTY_VALUE);
      ArrayInitialize(BufferFastDev,0);
      ArrayInitialize(BufferFastDev1,0);
      ArrayInitialize(BufferSlowDev,0);
      ArrayInitialize(BufferSlowDev1,0);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferSMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double avg=BufferFMA[i+shift_fast];
      double sum=0,temp=0;
      for(int j=period_fast-1; j>=0; j--)
        {
         temp=close[i+j]-avg;
         sum+=temp*temp;
        }
      BufferFastDev[i]=dev_fast*sqrt(sum/period_fast);
      BufferFastDev1[i]=pow((BufferFastDev[i]/Point()),2);
      temp=0;
      for(int j=chars-1; j>=0; j--)
         temp+=BufferFastDev1[i+j];
      temp=sqrt(temp/chars)*Point();
      if(temp!=0)
         temp=BufferFastDev[i]/temp;
      BufferFastOsc[i]=tanh(temp);
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double avg=BufferSMA[i+shift_slow];
      double sum=0,temp=0;
      for(int j=period_slow-1; j>=0; j--)
        {
         temp=close[i+j]-avg;
         sum+=temp*temp;
        }
      BufferSlowDev[i]=dev_slow*sqrt(sum/period_slow);
      BufferSlowDev1[i]=pow((BufferSlowDev[i]/Point()),2);
      temp=0;
      for(int j=chars-1; j>=0; j--)
         temp+=BufferSlowDev1[i+j];
      temp=sqrt(temp/chars)*Point();
      if(temp!=0)
         temp=BufferSlowDev[i]/temp;
      BufferSlowOsc[i]=tanh(temp);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
