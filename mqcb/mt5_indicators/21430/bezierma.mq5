//+------------------------------------------------------------------+
//|                                                     BezierMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Bezier-weighting Moving Average"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot BMA
#property indicator_label1  "Bezier MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSlateBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  8;             // Period
input double               InpSensitivity    =  0.5;           // Sensitivity
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferBMA[];
double         BufferMA[];
//--- global variables
double         Fact[];
double         sensitivity;
int            period;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   sensitivity=(InpSensitivity<0 ? 0 : InpSensitivity);
   ArrayResize(Fact,period+1);
   Fact[0]=1;
   for(int i=1; i<=period; i++)
      Fact[i]=Fact[i-1]*i;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferBMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Bezier MA ("+(string)period+","+DoubleToString(sensitivity,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferBMA,true);
   ArraySetAsSeries(BufferMA,true);
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
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferBMA,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double sum=0;
      for(int j=period; j>=0; j--)
         sum=sum+BufferMA[i+j]*(Fact[period]/(Fact[j]*Fact[period-j]))*pow(sensitivity,j)*pow(1.0-sensitivity,period-j);

      BufferBMA[i]=sum;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
