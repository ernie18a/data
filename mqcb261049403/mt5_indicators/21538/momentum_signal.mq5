//+------------------------------------------------------------------+
//|                                              Momentum_Signal.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Momentum Signal oscillator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   2
//--- plot Mom
#property indicator_label1  "Momentum"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriodCCI   =  6;    // CCI period
input uint     InpPeriodATR   =  12;   // ATR period
input uint     InpPeriodMom   =  7;    // Momentum period
input uint     InpPeriodRSI   =  7;    // RSI period
input uint     InpPeriodADX   =  7;    // ADX period
input double   InpSubstrSig   = -5.0;  // Signal line offset
input double   InpSubstrInd   = -1.0;  // Momentum line offset
//--- indicator buffers
double         BufferMomentum[];
double         BufferSignal[];
double         BufferCCI[];
double         BufferATR[];
double         BufferMom[];
double         BufferRSI[];
double         BufferADX[];
//--- global variables
double         offset_mom;
double         offset_sig;
int            period_cci;
int            period_atr;
int            period_mom;
int            period_rsi;
int            period_adx;
int            period_max;
int            handle_cci;
int            handle_atr;
int            handle_mom;
int            handle_rsi;
int            handle_adx;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_cci=int(InpPeriodCCI<1 ? 1 : InpPeriodCCI);
   period_atr=int(InpPeriodATR<1 ? 1 : InpPeriodATR);
   period_mom=int(InpPeriodMom<1 ? 1 : InpPeriodMom);
   period_rsi=int(InpPeriodRSI<1 ? 1 : InpPeriodRSI);
   period_adx=int(InpPeriodADX<1 ? 1 : InpPeriodADX);
   period_max=fmax(period_adx,fmax(period_cci,fmax(period_atr,fmax(period_mom,period_rsi))));
   offset_mom=InpSubstrInd;
   offset_sig=InpSubstrSig;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMomentum,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCCI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferATR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMom,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferADX,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Momentum Signal (CCI:"+(string)period_cci+", ATR:"+(string)period_atr+", Mom:"+(string)period_mom+", RSI:"+(string)period_rsi+", ADX:"+(string)period_adx+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMomentum,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferCCI,true);
   ArraySetAsSeries(BufferATR,true);
   ArraySetAsSeries(BufferMom,true);
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferADX,true);
//--- create MA's handles
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_atr);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atr,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_adx=iADX(NULL,PERIOD_CURRENT,period_adx);
   if(handle_adx==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period_adx,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_cci=iCCI(NULL,PERIOD_CURRENT,period_cci,PRICE_TYPICAL);
   if(handle_cci==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_cci,") by PRICE_TYPICAL object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mom=iMomentum(NULL,PERIOD_CURRENT,period_mom,PRICE_TYPICAL);
   if(handle_mom==INVALID_HANDLE)
     {
      Print("The iMomentum(",(string)period_mom,") by PRICE_TYPICAL object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_rsi=iRSI(NULL,PERIOD_CURRENT,period_rsi,PRICE_TYPICAL);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("The iRSI(",(string)period_rsi,") by PRICE_TYPICAL object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-1;
      ArrayInitialize(BufferMomentum,0);
      ArrayInitialize(BufferSignal,0);
      ArrayInitialize(BufferCCI,0);
      ArrayInitialize(BufferATR,0);
      ArrayInitialize(BufferMom,0);
      ArrayInitialize(BufferRSI,0);
      ArrayInitialize(BufferADX,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mom,0,0,count,BufferMom);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx,MAIN_LINE,0,count,BufferADX);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double ATR=BufferATR[i];
      double ADX=BufferADX[i];

      BufferSignal[i]=(ATR+ADX!=0 ? BufferMom[i]/(ATR+ADX)-offset_sig : 0);
      BufferMomentum[i]=(ADX!=0 ? (ATR+BufferCCI[i]+BufferRSI[i])/ADX-offset_mom : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
