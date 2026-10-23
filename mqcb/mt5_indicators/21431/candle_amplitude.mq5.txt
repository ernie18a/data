//+------------------------------------------------------------------+
//|                                             Candle_Amplitude.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Candle Amplitude oscillator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot Main
#property indicator_label1  "Amplitude"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_MODE
  {
   MODE_HL,    // High/Low
   MODE_OC     // Open/Close
  };
//--- input parameters
input ENUM_MODE   InpMode     =  MODE_HL; // Calculation mode
input uint        InpPeriodSm =  10;      // Signal period
//--- indicator buffers
double         BufferMain[];
double         BufferColors[];
double         BufferSignal[];
//--- global variables
int            period_sm;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_sm=int(InpPeriodSm<1 ? 1 : InpPeriodSm);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMain,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferSignal,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Candle Amplitude ("+"Mode "+ModeToString()+", period "+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   //IndicatorSetDouble(INDICATOR_MINIMUM,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMain,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferSignal,true);
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
   if(rates_total<fmax(period_sm,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_sm-2;
      ArrayInitialize(BufferMain,EMPTY_VALUE);
      ArrayInitialize(BufferSignal,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferMain[i]=(InpMode==MODE_HL ? high[i]-low[i] : close[i]-open[i])/Point();
      double c0=(InpMode==MODE_HL ? high[i]-low[i] : fabs(close[i]-open[i]));
      double c1=(InpMode==MODE_HL ? high[i+1]-low[i+1] : fabs(close[i+1]-open[i+1]));
      BufferColors[i]=(c0>c1 ? 0 : c0<c1 ? 1 : 2);
      BufferSignal[i]=GetSMA(rates_total,i,period_sm,BufferMain);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double GetSMA(const int rates_total,const int index,const int period,const double &price[],const bool as_series=true)
  {
//---
   double result=0.0;
//--- check position
   bool check_index=(as_series ? index<=rates_total-period-1 : index>=period-1);
   if(period<1 || !check_index)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
      result=result+(as_series ? price[index+i]: price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+
//| Описание метода                                                  |
//+------------------------------------------------------------------+
string ModeToString(void)
  {
   return(InpMode==MODE_HL ? "High/Low" : "Open/Close");
  }
//+------------------------------------------------------------------+
