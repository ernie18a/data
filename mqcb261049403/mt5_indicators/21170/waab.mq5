//+------------------------------------------------------------------+
//|                                                         WAAB.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Waddah Attar ADXxBollinger indicator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1
//--- plot WAAB
#property indicator_label1  "WAAB"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpPeriodADX      =  14;            // ADX Period
input uint                 InpPeriodBB       =  20;            // BB Period
input ENUM_APPLIED_PRICE   InpAppliedPriceBB =  PRICE_CLOSE;   // BB Applied price
//--- indicator buffers
double         BufferWAAB[];
double         BufferColors[];
double         BufferADX[];
double         BufferPDI[];
double         BufferMDI[];
double         BufferBBUP[];
double         BufferBBDN[];
//--- global variables
int            period_adx;
int            period_bb;
int            handle_adx;
int            handle_bb;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_adx=int(InpPeriodADX<1 ? 1 : InpPeriodADX);
   period_bb=int(InpPeriodBB<2 ? 2 : InpPeriodBB);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferWAAB,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferADX,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferPDI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMDI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferBBUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferBBDN,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Waddah Attar ADXxBollinger ("+(string)period_adx+","+(string)period_bb+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferWAAB,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferADX,true);
   ArraySetAsSeries(BufferPDI,true);
   ArraySetAsSeries(BufferMDI,true);
   ArraySetAsSeries(BufferBBUP,true);
   ArraySetAsSeries(BufferBBDN,true);
//--- create MA's handles
   ResetLastError();
   handle_adx=iADX(NULL,PERIOD_CURRENT,period_adx);
   if(handle_adx==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period_adx,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_bb=iBands(NULL,PERIOD_CURRENT,period_bb,0,2.0,InpAppliedPriceBB);
   if(handle_bb==INVALID_HANDLE)
     {
      Print("The iBands(",(string)period_bb,") object was not created: Error ",GetLastError());
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
      limit=rates_total-1;
      ArrayInitialize(BufferWAAB,EMPTY_VALUE);
      ArrayInitialize(BufferADX,0);
      ArrayInitialize(BufferPDI,0);
      ArrayInitialize(BufferMDI,0);
      ArrayInitialize(BufferBBUP,0);
      ArrayInitialize(BufferBBDN,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_adx,MAIN_LINE,0,count,BufferADX);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx,PLUSDI_LINE,0,count,BufferPDI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx,MINUSDI_LINE,0,count,BufferMDI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb,UPPER_BAND,0,count,BufferBBUP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb,LOWER_BAND,0,count,BufferBBDN);
   if(copied!=count) return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double mdi=BufferMDI[i];
      double pdi=BufferPDI[i];
      double xxplo=BufferBBUP[i]-BufferBBDN[i];
      
      BufferWAAB[i]=xxplo*BufferADX[i];
      BufferColors[i]=(pdi>mdi ? 0 : pdi<mdi ? 1 : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
