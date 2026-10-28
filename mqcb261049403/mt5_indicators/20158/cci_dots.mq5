//+------------------------------------------------------------------+
//|                                                     CCI_Dots.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "UP"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "DN"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriodCCI      =  14;            // CCI period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // CCI applied price
input uint                 InpPeriodMA       =  10;            // MA period
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferCCI[];
double         BufferMAH[];
double         BufferMAL[];
//--- global variables
int            period_cci;
int            period_ma;
int            handle_cci;
int            handle_mah;
int            handle_mal;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_cci=int(InpPeriodCCI<1 ? 1 : InpPeriodCCI);
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCCI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMAH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMAL,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,119);
   PlotIndexSetInteger(1,PLOT_ARROW,119);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI dots("+(string)period_cci+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferCCI,true);
   ArraySetAsSeries(BufferMAH,true);
   ArraySetAsSeries(BufferMAL,true);
//--- create handle CCI
   ResetLastError();
   handle_cci=iCCI(NULL,PERIOD_CURRENT,period_cci,InpAppliedPrice);
   if(handle_cci==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_cci,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_mah=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_SMA,PRICE_HIGH);
   if(handle_mah==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_mal=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_SMA,PRICE_LOW);
   if(handle_mal==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") by PRICE_LOW object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное колиество баров для расчёта
   int max=fmax(period_cci,period_ma);
   if(rates_total<max) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferCCI,EMPTY_VALUE);
      ArrayInitialize(BufferMAH,EMPTY_VALUE);
      ArrayInitialize(BufferMAL,EMPTY_VALUE);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mah,0,0,count,BufferMAH);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mal,0,0,count,BufferMAL);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double range=(BufferMAH[i]-BufferMAL[i])/2;
      double cci0=BufferCCI[i];
      double cci1=BufferCCI[i+1];
      if(cci1>=0 && cci0<0)
        {
         BufferUP[i]=high[i]+range;
         BufferDN[i]=EMPTY_VALUE;
        }
      else if(cci1<=0 && cci0>0)
        {
         BufferUP[i]=EMPTY_VALUE;
         BufferDN[i]=low[i]-range;
        }
      else
        {
         BufferUP[i]=EMPTY_VALUE;
         BufferDN[i]=EMPTY_VALUE;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
