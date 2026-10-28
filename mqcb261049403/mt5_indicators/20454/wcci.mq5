//+------------------------------------------------------------------+
//|                                                         WCCI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Weighted CCI"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot Fast
#property indicator_label1  "WCCI Fast"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Slow
#property indicator_label2  "WCCI Slow"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriodFastCCI  =  7;             // CCI Fast period
input uint                 InpPeriodSlowCCI  =  14;            // CCI Slow period
input int                  InpWeight         =  1;             // Weight
input uint                 InpPeriodFastATR  =  7;             // ATR Fast period
input uint                 InpPeriodSlowATR  =  50;            // ATR Slow period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input int                  InpOverboughtMajor=200;             // Overbought max
input int                  InpOverboughtMinor=50;              // Overbought
input int                  InpOversoldMinor=-50;               // Oversold
input int                  InpOversoldMajor=-200;              // Oversold min
//--- indicator buffers
double         BufferFast[];
double         BufferSlow[];
double         BufferCCIF[];
double         BufferCCIS[];
double         BufferATRF[];
double         BufferATRS[];
//--- global variables
int            period_ccif;
int            period_ccis;
int            period_atrf;
int            period_atrs;
//---
int            overbought_major;
int            overbought_minor;
int            oversold_major;
int            oversold_minor;
//---
int            handle_ccif;
int            handle_ccis;
int            handle_atrf;
int            handle_atrs;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_atrf=int(InpPeriodFastATR<1 ? 1 : InpPeriodFastATR);
   period_atrs=int(InpPeriodSlowATR<1 ? 1 : InpPeriodSlowATR);
   period_ccif=int(InpPeriodFastCCI<1 ? 1 : InpPeriodFastCCI);
   period_ccis=int(InpPeriodSlowCCI<1 ? 1 : InpPeriodSlowCCI);
//---
   overbought_major=InpOverboughtMajor;
   oversold_major=InpOversoldMajor;
   overbought_minor=(InpOverboughtMinor>=overbought_major ? overbought_major-1 : InpOverboughtMinor);
   oversold_minor=(InpOversoldMinor<=oversold_major ? oversold_major+1 : InpOversoldMinor);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferFast,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSlow,INDICATOR_DATA);
   SetIndexBuffer(2,BufferATRF,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferATRS,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferCCIF,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferCCIS,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Weighted CCI");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,4);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought_major);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,overbought_minor);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold_major);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,oversold_minor);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferFast,true);
   ArraySetAsSeries(BufferSlow,true);
   ArraySetAsSeries(BufferATRF,true);
   ArraySetAsSeries(BufferATRS,true);
   ArraySetAsSeries(BufferCCIF,true);
   ArraySetAsSeries(BufferCCIS,true);
//--- create handles
   ResetLastError();
   handle_atrf=iATR(NULL,PERIOD_CURRENT,period_atrf);
   if(handle_atrf==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atrf,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_atrs=iATR(NULL,PERIOD_CURRENT,period_atrs);
   if(handle_atrs==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atrs,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ccif=iCCI(NULL,PERIOD_CURRENT,period_ccif,InpAppliedPrice);
   if(handle_ccif==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_ccif,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ccis=iCCI(NULL,PERIOD_CURRENT,period_ccis,InpAppliedPrice);
   if(handle_ccis==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_ccis,") object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferFast,EMPTY_VALUE);
      ArrayInitialize(BufferSlow,EMPTY_VALUE);
      ArrayInitialize(BufferATRF,0);
      ArrayInitialize(BufferATRS,0);
      ArrayInitialize(BufferCCIF,0);
      ArrayInitialize(BufferCCIS,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_atrf,0,0,count,BufferATRF);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atrs,0,0,count,BufferATRS);
   if(copied!=count) return 0;
//---
   copied=CopyBuffer(handle_ccif,0,0,count,BufferCCIF);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ccis,0,0,count,BufferCCIS);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   double Kw=0,F=0,S=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(InpWeight!=0)
        {
         double ATR1=BufferATRF[i];
         double ATR2=BufferATRS[i];
         if(ATR2!=0)
           {
            Kw=InpWeight*ATR1/ATR2;
            F=Kw*BufferCCIF[i];
            S=Kw*BufferCCIS[i];
           }
         else
           {
            F=0;
            S=0;
           }
        }
      else
        {
         F=BufferCCIF[i];
         S=BufferCCIS[i];
        }
      BufferFast[i]=fmax(fmin(F,overbought_major+50),oversold_major-50);
      BufferSlow[i]=fmax(fmin(S,overbought_major+50),oversold_major-50);

     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
