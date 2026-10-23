//+------------------------------------------------------------------+
//|                                                         HWMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Holt-Winter Moving Averege"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot HVMA
#property indicator_label1  "HWMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input double               InpValueA         =  0.2;           // nA (from 0 to 1)
input double               InpValueB         =  0.1;           // nB (from 0 to 1)
input double               InpValueC         =  0.1;           // nC (from 0 to 1)
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferHVMA[];
double         BufferMA[];
double         BufferF[];
double         BufferV[];
double         BufferA[];
//--- global variables
double         a;
double         b;
double         c;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   a=(InpValueA<0 ? 0 : InpValueA>1 ? 1 : InpValueA);
   b=(InpValueB<0 ? 0 : InpValueB>1 ? 1 : InpValueB);
   c=(InpValueC<0 ? 0 : InpValueC>1 ? 1 : InpValueC);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHVMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferF,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferV,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Holt-Winter MA ("+DoubleToString(a,2)+","+DoubleToString(b,2)+","+DoubleToString(c,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHVMA,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferF,true);
   ArraySetAsSeries(BufferV,true);
   ArraySetAsSeries(BufferA,true);
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
      ArrayInitialize(BufferHVMA,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferF,0);
      ArrayInitialize(BufferV,0);
      ArrayInitialize(BufferA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferF[i]=(1.0-a)*(BufferF[i+1]+BufferV[i+1]+0.5*BufferA[i+1])+a*BufferMA[i];
      BufferV[i]=(1.0-b)*(BufferV[i+1]+BufferA[i+1])+b*(BufferF[i]-BufferF[i+1]);
      BufferA[i]=(1.0-c)*BufferA[i+1]+c*(BufferV[i]-BufferV[i+1]);

      BufferHVMA[i]=BufferF[i]+BufferV[i]+0.5*BufferA[i];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
