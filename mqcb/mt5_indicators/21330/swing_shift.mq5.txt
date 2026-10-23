//+------------------------------------------------------------------+
//|                                                  Swing_Shift.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Swing Shift oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot SS
#property indicator_label1  "Swing Shift"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpPeriod         =  14;            // Period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpThreshold      =  0.0;           // Threshold
//--- indicator buffers
double         BufferSS[];
double         BufferColors[];
double         BufferMA[];
double         BufferAnchor[];
double         BufferTrend[];
//--- global variables
double         threshold;
int            period;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   threshold=InpThreshold;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSS,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAnchor,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferTrend,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Swing Shift ("+(string)period+","+DoubleToString(threshold,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSS,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferAnchor,true);
   ArraySetAsSeries(BufferTrend,true);
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferSS,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferAnchor,0);
      ArrayInitialize(BufferTrend,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double ma=BufferMA[i];
      double Slope=(ma-BufferMA[i+1])/Point();
      if(i==rates_total-2)
        {
         BufferAnchor[i]=ma;
         BufferTrend[i]=0;
         BufferSS[i]=0;
         continue;
        }
      if(Slope>threshold && BufferTrend[i+1]<1)
        {
         BufferAnchor[i]=ma;
         BufferTrend[i]=1;
        }
      else
        {
         if(Slope<-threshold && BufferTrend[i+1]>0)
           {
            BufferAnchor[i]=ma;
            BufferTrend[i]=0;
           }
         else
           {
            BufferAnchor[i]=BufferAnchor[i+1];
            BufferTrend[i]=BufferTrend[i+1];
           }
        }
      BufferSS[i]=(BufferAnchor[i]!=0 ? 100.0*(ma-BufferAnchor[i])/BufferAnchor[i] : 0);
      BufferColors[i]=(BufferSS[i]>BufferSS[i+1] ? 0 : BufferSS[i]<BufferSS[i+1] ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
