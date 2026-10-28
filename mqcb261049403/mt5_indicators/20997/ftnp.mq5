//+------------------------------------------------------------------+
//|                                                         FTNP.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Fisher Transform of Normalized Prices indicator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot Fisher
#property indicator_label1  "Fisher"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Trigger
#property indicator_label2  "Trigger"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriod         =  10;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferFisher[];
double         BufferTrigger[];
double         BufferMA[];
double         BufferV[];
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
   SetIndexBuffer(0,BufferFisher,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTrigger,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferV,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Fisher Transform of Normalized Prices ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferFisher,true);
   ArraySetAsSeries(BufferTrigger,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferV,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferFisher,0);
      ArrayInitialize(BufferTrigger,0);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferV,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bl=ArrayMinimum(BufferMA,i,period);
      int bh=ArrayMaximum(BufferMA,i,period);
      if(bl==WRONG_VALUE || bh==WRONG_VALUE)
         continue;
      double MinPr=BufferMA[bl];
      double MaxPr=BufferMA[bh];
      if(MaxPr!=MinPr)
        {
         BufferV[i]=0.667*((BufferMA[i]-MinPr)/(MaxPr-MinPr)-0.5+BufferV[i+1]);
         BufferV[i]=fmin(BufferV[i], 0.999);
         BufferV[i]=fmax(BufferV[i],-0.999);
         BufferFisher[i]=0.5*(log((1.0+BufferV[i])/(1.0-BufferV[i]))+BufferFisher[i+1]);
         BufferTrigger[i]=BufferFisher[i+1];
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
