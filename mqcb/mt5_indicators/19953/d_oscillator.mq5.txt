//+------------------------------------------------------------------+
//|                                                 D_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot D1
#property indicator_label1  "D1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot D2
#property indicator_label2  "D2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     InpPeriodRSI   =  13;   // Period RSI
input uint     InpPeriodD     =  8;    // D-period
input uint     InpPeriodCCI   =  8;    // Period CCI
input double   InpCoeffCCI    =  0.4;  // CCI coefficient
input double   InpSmooth      =  4.0;  // Smooth
//--- indicator buffers
double         BufferD1[];
double         BufferD2[];
double         BufferRSI[];
double         BufferCCI[];
//--- global variables
int            period_rsi;
int            period_cci;
int            period_d;
double         coeff_cci;
double         smooth;
double         sk,sk2;
int            handle_rsi;
int            handle_cci;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period_rsi=int(InpPeriodRSI<2 ? 2 : InpPeriodRSI);
   period_cci=int(InpPeriodCCI<1 ? 1 : InpPeriodCCI);
   period_d=int(InpPeriodD<2 ? 2 : InpPeriodD);
   coeff_cci=InpCoeffCCI;
   smooth=InpSmooth;
   sk=2/(smooth+1);
   sk2=2/(smooth*0.8+1);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferD1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferD2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferCCI,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"D Oscillator");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferD1,true);
   ArraySetAsSeries(BufferD2,true);
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferCCI,true);
//--- create MA and StdDev handles
   ResetLastError();
   handle_rsi=iRSI(Symbol(),PERIOD_CURRENT,period_rsi,PRICE_CLOSE);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("The iRSI(",(string)period_rsi,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_cci=iCCI(Symbol(),PERIOD_CURRENT,period_cci,PRICE_TYPICAL);
   if(handle_cci==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_cci,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
   if(rates_total<5) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferD1,0);
      ArrayInitialize(BufferD2,0);
      ArrayInitialize(BufferRSI,0);
      ArrayInitialize(BufferCCI,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   double MaxRSI,MinRSI;
   double StRSI,StCCI;
   for(int i=limit; i>=0; i--)
     {
      if(i!=limit){
         int max=ArrayMaximum(BufferRSI,i,period_d);
         int min=ArrayMinimum(BufferRSI,i,period_d);
         if(max==WRONG_VALUE || min==WRONG_VALUE) continue;
         MaxRSI=BufferRSI[max];
         MinRSI=BufferRSI[min];
         if(MaxRSI!=MinRSI)
           {
            StRSI=(BufferRSI[i]-MinRSI)*200/(MaxRSI-MinRSI)-100;
            StCCI=coeff_cci*BufferCCI[i]+(1-coeff_cci)*StRSI;
            BufferD1[i]=sk*StCCI+(1-sk)*BufferD1[i+1];
            BufferD2[i]=sk2*BufferD1[i+1]+(1-sk2)*BufferD2[i+1];
           }
         else
            BufferD2[i]=BufferD1[i]=0;
         }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
