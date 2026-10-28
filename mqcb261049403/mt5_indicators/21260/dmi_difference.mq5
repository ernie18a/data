//+------------------------------------------------------------------+
//|                                               DMI_Difference.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "DMI Difference oscillator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot DDMI
#property indicator_label1  "DDMI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDodgerBlue,clrOrangeRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriod   =  14;   // ADX period
//--- indicator buffers
double         BufferDDMI[];
double         BufferColors[];
double         BufferPDI[];
double         BufferMDI[];
//--- global variables
int            period;
int            handle_adx;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDDMI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferPDI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMDI,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"DDMI ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDDMI,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferPDI,true);
   ArraySetAsSeries(BufferMDI,true);
//--- create MA's handles
   ResetLastError();
   handle_adx=iADX(NULL,PERIOD_CURRENT,period);
   if(handle_adx==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period,") object was not created: Error ",GetLastError());
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
      ArrayInitialize(BufferDDMI,EMPTY_VALUE);
      ArrayInitialize(BufferPDI,0);
      ArrayInitialize(BufferMDI,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_adx,PLUSDI_LINE,0,count,BufferPDI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx,MINUSDI_LINE,0,count,BufferMDI);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferDDMI[i]=BufferPDI[i]-BufferMDI[i];
      BufferColors[i]=(BufferDDMI[i]>BufferDDMI[i+1] ? 0 : BufferDDMI[i]<BufferDDMI[i+1] ? 1 : 2);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
