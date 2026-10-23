//+------------------------------------------------------------------+
//|                                                RSI_Rendiment.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "RSI Rendiment oscillator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot RSI
#property indicator_label1  "RRSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0, // No
  };
//--- input parameters
input uint              InpPeriodRSI   =  14;         // RSI period
input ENUM_INPUT_YES_NO InpNormalized  =  INPUT_YES;  // Normalized
input uint              InpPeriod      =  5;          // Normalization range
input uint              InpMultiplier  =  1;          // Rendiment X
input double            InpOverbought  =  70.0;       // Overbought
input double            InpOversold    =  30.0;       // Oversold
//--- indicator buffers
double         BufferRRSI[];
double         BufferRSI[];
double         BufferRAW[];
//--- global variables
double         overbought;
double         oversold;
int            multiplier;
int            period_rsi;
int            range;
int            handle_rsi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_rsi=int(InpPeriodRSI<1 ? 1 : InpPeriodRSI);
   range=int(InpPeriod<2 ? 2 : InpPeriod);
   multiplier=int(InpMultiplier<1 ? 1 : InpMultiplier);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRRSI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferRAW,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI Rendiment ("+(string)period_rsi+","+(string)range+","+(string)multiplier+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,(InpNormalized ? "Overbought" : ""));
   IndicatorSetString(INDICATOR_LEVELTEXT,1,(InpNormalized ? "Oversold" : ""));
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRRSI,true);
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferRAW,true);
//--- create handle
   ResetLastError();
   handle_rsi=iRSI(NULL,PERIOD_CURRENT,period_rsi,PRICE_CLOSE);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("The iRSI (",(string)period_rsi,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(range,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-range-1;
      ArrayInitialize(BufferRRSI,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferRSI,0);
     }

//--- Подготовка данных
   int count=(limit>0 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRAW[i]=(close[i+range-1]!=0 ? multiplier*log(close[i]/close[i+range-1]) : 0);
      double Rendiment=0;
      if(InpNormalized)
        {
         int min_idx=ArrayMinimum(BufferRAW,i,range);
         int max_idx=ArrayMaximum(BufferRAW,i,range);
         if(min_idx==WRONG_VALUE || max_idx==WRONG_VALUE)
            continue;
         double min=BufferRAW[min_idx];
         double max=BufferRAW[max_idx];
         if((max-min)!=0)
            Rendiment=((BufferRAW[i]-min)/(max-min))*100;
         else
            Rendiment=0;
        }
      else
         Rendiment=BufferRAW[i];
      BufferRRSI[i]=(BufferRSI[i]+Rendiment)/2.0;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
