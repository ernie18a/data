//+------------------------------------------------------------------+
//|                                           OnChart_Stochastic.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   5
//--- plot K
#property indicator_label1  "Main line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot D
#property indicator_label2  "Signal line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot Overbought
#property indicator_label3  "Overbought"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkSeaGreen
#property indicator_style3  STYLE_DOT
#property indicator_width3  1
//--- plot Oversold
#property indicator_label4  "Oversold"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkSeaGreen
#property indicator_style4  STYLE_DOT
#property indicator_width4  1
//--- plot Middle
#property indicator_label5  "Middle"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGray
#property indicator_style5  STYLE_DOT
#property indicator_width5  1
//--- input parameters
input uint           InpPeriodK        =  5;             // %K period
input uint           InpPeriodD        =  3;             // %D period
input uint           InpSlowing        =  3;             // Slowing
input ENUM_MA_METHOD InpMethodSmoothK  =  MODE_SMA;      // Smoothing method
input ENUM_STO_PRICE InpPriceField     =  STO_LOWHIGH;   // Price field
input double         InpOverbought     =  80.0;          // Overbought
input double         InpOversold       =  20.0;          // Oversold
input uint           InpPeriodATR      =  14;            // ATR period
//--- indicator buffers
double               BufferK[];
double               BufferD[];
double               BufferOB[];
double               BufferOS[];
double               BufferMA[];
double               BufferKTMP[];
double               BufferDTMP[];
double               BufferATR[];
//--- global variables
double               overbought;
double               oversold;
int                  period_k;
int                  period_s;
int                  period_d;
int                  period_atr;
int                  handle_sto;
int                  handle_ma;
int                  handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_k=int(InpPeriodK<1 ? 1 : InpPeriodK);
   period_d=int(InpPeriodD<1 ? 1 : InpPeriodD);
   period_s=int(InpSlowing<1 ? 1 : InpSlowing);
   period_atr=int(InpPeriodATR<1 ? 1 : InpPeriodATR);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.2 ? 0.2 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>99.9 ? 99.9 : InpOversold);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferK,INDICATOR_DATA);
   SetIndexBuffer(1,BufferD,INDICATOR_DATA);
   SetIndexBuffer(2,BufferOB,INDICATOR_DATA);
   SetIndexBuffer(3,BufferOS,INDICATOR_DATA);
   SetIndexBuffer(4,BufferMA,INDICATOR_DATA);
   SetIndexBuffer(5,BufferDTMP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferKTMP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferATR,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"OnChart stochastic("+(string)period_k+","+(string)period_d+","+(string)period_s+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferK,true);
   ArraySetAsSeries(BufferD,true);
   ArraySetAsSeries(BufferOB,true);
   ArraySetAsSeries(BufferOS,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferDTMP,true);
   ArraySetAsSeries(BufferKTMP,true);
   ArraySetAsSeries(BufferATR,true);
//--- create handles
   ResetLastError();
   handle_sto=iStochastic(NULL,PERIOD_CURRENT,period_k,period_d,period_s,InpMethodSmoothK,InpPriceField);
   if(handle_sto==INVALID_HANDLE)
     {
      Print("The Fast iStochastic(",(string)period_k,",",(string)period_d,",",(string)period_s,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_atr,0,InpMethodSmoothK,PRICE_CLOSE);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_atr,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_atr);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atr,") object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferK,EMPTY_VALUE);
      ArrayInitialize(BufferD,EMPTY_VALUE);
      ArrayInitialize(BufferOB,EMPTY_VALUE);
      ArrayInitialize(BufferOS,EMPTY_VALUE);
      ArrayInitialize(BufferMA,EMPTY_VALUE);
      ArrayInitialize(BufferDTMP,EMPTY_VALUE);
      ArrayInitialize(BufferKTMP,EMPTY_VALUE);
      ArrayInitialize(BufferATR,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_sto,MAIN_LINE,0,count,BufferKTMP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sto,SIGNAL_LINE,0,count,BufferDTMP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      BufferOB[i]=BufferMA[i]+BufferATR[i]*(overbought-50)/100;
      BufferOS[i]=BufferMA[i]-BufferATR[i]*(50-oversold)/100;
      BufferK[i]=BufferMA[i]+(BufferKTMP[i]-50)*BufferATR[i]/100;
      BufferD[i]=BufferMA[i]+(BufferDTMP[i]-50)*BufferATR[i]/100;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
