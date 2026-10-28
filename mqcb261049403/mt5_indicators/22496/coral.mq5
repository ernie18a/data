//+------------------------------------------------------------------+
//|                                                        Coral.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Coral indicator"
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   1
//--- plot C
#property indicator_label1  "Coral"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input double               InpCoeff          =  0.063492063492;   // Coefficient
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;      // Applied price
//--- indicator buffers
double         BufferC[];
double         BufferColors[];
double         BufferB1[];
double         BufferB2[];
double         BufferB3[];
double         BufferB4[];
double         BufferB5[];
double         BufferB6[];
double         BufferMA[];
//--- global variables
double         coeff1;
double         coeff2;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   coeff1=(InpCoeff<=0.0086 ? 0.0086 : InpCoeff>1 ? 1: InpCoeff);
   coeff2=1.0-coeff1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferB1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferB2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferB3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferB4,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferB5,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferB6,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Coral");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferC,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferB1,true);
   ArraySetAsSeries(BufferB2,true);
   ArraySetAsSeries(BufferB3,true);
   ArraySetAsSeries(BufferB4,true);
   ArraySetAsSeries(BufferB5,true);
   ArraySetAsSeries(BufferB6,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA handle
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
      ArrayInitialize(BufferC,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferB1,0);
      ArrayInitialize(BufferB2,0);
      ArrayInitialize(BufferB3,0);
      ArrayInitialize(BufferB4,0);
      ArrayInitialize(BufferB5,0);
      ArrayInitialize(BufferB6,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-2)
         BufferB1[i]=BufferB2[i]=BufferB3[i]=BufferB4[i]=BufferB5[i]=BufferB6[i]=BufferMA[i];
      else
        {
         BufferB1[i]=coeff1*BufferMA[i]+coeff2*BufferB1[i+1];
         BufferB2[i]=coeff1*BufferB1[i]+coeff2*BufferB2[i+1];
         BufferB3[i]=coeff1*BufferB2[i]+coeff2*BufferB3[i+1];
         BufferB4[i]=coeff1*BufferB3[i]+coeff2*BufferB4[i+1];
         BufferB5[i]=coeff1*BufferB4[i]+coeff2*BufferB5[i+1];
         BufferB6[i]=coeff1*BufferB5[i]+coeff2*BufferB6[i+1];
         BufferC[i]=(-0.064)*BufferB6[i]+0.672*BufferB5[i]-2.352*BufferB4[i]+2.744*BufferB3[i];
         BufferColors[i]=(BufferC[i]>BufferC[i+1] ? 0 : BufferC[i]<BufferC[i+1] ? 1 : 2);
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
