//+------------------------------------------------------------------+
//|                                            Spread_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Spread Oscillator"
#property description "Shows the spread between two instruments"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot SpreadOsc
#property indicator_label1  "Spread Osc"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input string   InpSymbol1     =  "EURUSD";   // First symbol
input string   InpSymbol2     =  "GBPUSD";   // Second symbol
input uint     InpPeriodFast  =  5;          // Fast MA period
input uint     InpPeriodSlow  =  15;         // Slow MA period
//--- indicator buffers
double         BufferSO[];
double         BufferRatio[];
double         BufferAvgFMA[];
double         BufferAvgSMA[];
double         BufferSymbol1[];
double         BufferSymbol2[];
//--- global variables
int            period_fast;
int            period_slow;
int            period_max;
int            handle_ma1;
int            handle_ma2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fast=int(InpPeriodFast<2 ? 2 : InpPeriodFast);
   period_slow=int(InpPeriodSlow==period_fast ? period_fast+1 : InpPeriodSlow<2 ? 2 : InpPeriodSlow);
   period_max=fmax(period_fast,period_slow);
//--- check symbols and get its datas
   if(!SymbolCheck(InpSymbol1)) return INIT_FAILED;
   if(!SymbolCheck(InpSymbol2)) return INIT_FAILED;
   Time(InpSymbol1,PERIOD_CURRENT,1);
   Time(InpSymbol2,PERIOD_CURRENT,1);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRatio,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferAvgFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferAvgSMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSymbol1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSymbol2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,InpSymbol1+"/"+InpSymbol2+" spread ("+(string)period_fast+", "+(string)period_slow+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSO,true);
   ArraySetAsSeries(BufferRatio,true);
   ArraySetAsSeries(BufferAvgFMA,true);
   ArraySetAsSeries(BufferAvgSMA,true);
   ArraySetAsSeries(BufferSymbol1,true);
   ArraySetAsSeries(BufferSymbol2,true);
//--- create MA's handles
   ResetLastError();
   handle_ma1=iMA(InpSymbol1,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_CLOSE);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The ",InpSymbol1," iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(InpSymbol2,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_CLOSE);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print("The ",InpSymbol2," iMA(1) object was not created: Error ",GetLastError());
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
//--- Проверка количества доступных баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferSO,0);
      ArrayInitialize(BufferRatio,0);
      ArrayInitialize(BufferAvgFMA,0);
      ArrayInitialize(BufferAvgSMA,0);
      ArrayInitialize(BufferSymbol1,0);
      ArrayInitialize(BufferSymbol2,0);
     }
//--- Подготовка данных
   if(Time(InpSymbol1,PERIOD_CURRENT,1)==0) return 0;
   if(Time(InpSymbol2,PERIOD_CURRENT,1)==0) return 0;
   
   int bars1=(InpSymbol1==Symbol() ? rates_total : Bars(InpSymbol1,PERIOD_CURRENT));
   int bars2=(InpSymbol2==Symbol() ? rates_total : Bars(InpSymbol2,PERIOD_CURRENT));
   if(bars1==0 || bars2==0) return 0;
   
   int count1=(limit>1 ? fmin(bars1,rates_total) : 1),copied=0;
   int count2=(limit>1 ? fmin(bars2,rates_total) : 1);
   
   copied=CopyBuffer(handle_ma1,0,0,count1,BufferSymbol1);
   if(copied!=count1) return 0;
   copied=CopyBuffer(handle_ma2,0,0,count2,BufferSymbol2);
   if(copied!=count2) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(BufferSymbol1[i]==0 || BufferSymbol2[i]==0) continue;
      double res=(BufferSymbol1[i]>BufferSymbol2[i] ? BufferSymbol1[i]/BufferSymbol2[i] : BufferSymbol2[i]/BufferSymbol1[i]);
      BufferRatio[i]=res*100.0;
      BufferAvgFMA[i]=EMA(bars1,BufferRatio[i],BufferAvgFMA[i+1],period_fast,i);
      BufferAvgSMA[i]=EMA(bars2,BufferRatio[i],BufferAvgSMA[i+1],period_slow,i);
      BufferSO[i]=(BufferSymbol1[i]>BufferSymbol2[i] ? BufferAvgSMA[i]-BufferAvgFMA[i] : BufferAvgFMA[i]-BufferAvgSMA[i]);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Проверка символа                                                 |
//+------------------------------------------------------------------+
bool SymbolCheck(const string symbol_name)
  {
   long select=0;
   ResetLastError();
   if(!SymbolInfoInteger(symbol_name,SYMBOL_SELECT,select))
     {
      int err=GetLastError();
      Print("Error: ",err," Symbol ",symbol_name," does not exist");
      return false;
     }
   else
     {
      if(select) return true;
      ResetLastError();
      if(!SymbolSelect(symbol_name,true))
        {
         int err=GetLastError();
         Print("Error selected ",symbol_name,": ",err);
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Возвращает Time                                                  |
//+------------------------------------------------------------------+
datetime Time(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   datetime array[];
   ArraySetAsSeries(array,true);
   return(CopyTime(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
double EMA(const int rates_total,const double price,const double prev,const int period,const int shift)
  {
   return(shift>=rates_total-2 || period<1 ? price : prev+2.0/(1+period)*(price-prev));
  }
//+------------------------------------------------------------------+
