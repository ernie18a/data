//+------------------------------------------------------------------+
//|                                                Adaptable_CCI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Adaptable CCI oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot ACCI
#property indicator_label1  "ACCI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCadetBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriodAvg      =  14;            // Period (CCI period)
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price (CCI apply to)
input uint                 InpPeriodDev      =  14;            // Deviation period
input double               InpCorrection     =  0.015;         // Correction factor
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Method
input double               InpOverbought     =  100;           // Overbought
input double               InpOversold       = -100;           // Oversold
//--- indicator buffers
double         BufferACCI[];
double         BufferMA[];
double         BufferMAAvg[];
double         BufferMADev[];
//--- global variables
double         correction;
double         overbought;
double         oversold;
int            period_avg;
int            period_dev;
int            handle_ma;
int            handle_maavg;
int            handle_madev;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_avg=int(InpPeriodAvg<2 ? 2 : InpPeriodAvg);
   period_dev=int(InpPeriodDev<3 ? 3 : InpPeriodDev);
   correction=(InpCorrection==0 ? 0.001 : InpCorrection);
   overbought=(InpOverbought<=0 ? 0 : InpOverbought);
   oversold=(InpOversold>=0 ? 0 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferACCI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMAAvg,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMADev,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Adaptable CCI ("+(string)period_avg+","+(string)period_dev+","+DoubleToString(correction,3)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferACCI,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferMAAvg,true);
   ArraySetAsSeries(BufferMADev,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maavg=iMA(NULL,PERIOD_CURRENT,period_avg,0,InpMethod,InpAppliedPrice);
   if(handle_maavg==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_avg,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_madev=iMA(NULL,PERIOD_CURRENT,period_dev,0,MODE_SMA,InpAppliedPrice);
   if(handle_madev==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_dev,") object was not created: Error ",GetLastError());
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
      limit=rates_total-period_dev-1;
      ArrayInitialize(BufferACCI,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferMAAvg,0);
      ArrayInitialize(BufferMADev,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maavg,0,0,count,BufferMAAvg);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_madev,0,0,count,BufferMADev);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double sum=0;
      for(int j=0; j<period_dev; j++)
         sum+=fabs(BufferMA[i+j]-BufferMADev[i]);
      double meandev=sum/period_dev;
      BufferACCI[i]=(meandev!=0 ? (BufferMA[i]-BufferMAAvg[i])/(meandev*correction) : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
