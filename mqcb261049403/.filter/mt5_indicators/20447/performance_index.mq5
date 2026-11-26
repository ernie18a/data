//+------------------------------------------------------------------+
//|                                            Performance_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Performance Index"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot PI
#property indicator_label1  "Performance Idx"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod         =  14;            // Period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input string               InpSymbol         =  "GBPUSD";      // Instrument
//--- indicator buffers
double         BufferPI[];
double         BufferMA1[];
double         BufferMA2[];
double         BufferPr1[];
double         BufferPr2[];
//--- global variables
int            period;
int            handle_ma1;
int            handle_ma2;
int            handle_pr1;
int            handle_pr2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferPr1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferPr2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"PIndex/"+InpSymbol+"("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPI,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
   ArraySetAsSeries(BufferPr1,true);
   ArraySetAsSeries(BufferPr2,true);
//--- check symbol name
   if(!SymbolCheck(InpSymbol))
      return INIT_FAILED;
//--- create MA's handle
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The ",Symbol()," iMA(",(string)period,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(InpSymbol,PERIOD_CURRENT,period,0,InpMethod,InpAppliedPrice);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print("The ",InpSymbol," iMA(",(string)period,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_pr1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_pr1==INVALID_HANDLE)
     {
      Print("The ",Symbol()," iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_pr2=iMA(InpSymbol,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_pr2==INVALID_HANDLE)
     {
      Print("The ",InpSymbol," iMA(1) object was not created: Error ",GetLastError());
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
   int bars2=(InpSymbol==Symbol() ? rates_total : Bars(InpSymbol,PERIOD_CURRENT));
   if(rates_total<4 || bars2<4) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferPI,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMA2,0);
      ArrayInitialize(BufferPr1,0);
      ArrayInitialize(BufferPr2,0);
     }
   int limit_min=fmin(rates_total,bars2)-1;
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : limit_min);
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma2,0,0,count,BufferMA2);
   if(copied!=count) return 0;
//---
   copied=CopyBuffer(handle_pr1,0,0,count,BufferPr1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_pr2,0,0,count,BufferPr2);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   count=(limit==0 ? limit : limit_min);
   for(int i=count; i>=0 && !IsStopped(); i--)
     {
      int index=BarShift(InpSymbol,PERIOD_CURRENT,time[i],false);
      if(index==WRONG_VALUE) continue;
      double MA1=BufferMA1[i];
      double MA2=BufferMA2[i];
      double Pr1=BufferPr1[i];
      double Pr2=BufferPr2[i];
      BufferPI[i]=(MA2!=0 && Pr2!=0 ? Pr1*MA2/(Pr2*MA1) : EMPTY_VALUE);
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
//| Возвращает смещение бара по времени                              |
//| https://www.mql5.com/ru/forum/743/page11#comment_7010041         |
//+------------------------------------------------------------------+
int BarShift(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const datetime time,bool exact=false)
  {
   int res=Bars(symbol_name,timeframe,time+1,UINT_MAX);
   if(exact) if((timeframe!=PERIOD_MN1 || time>TimeCurrent()) && res==Bars(symbol_name,timeframe,time-PeriodSeconds(timeframe)+1,UINT_MAX)) return(WRONG_VALUE);
   return res;
  } 
//+------------------------------------------------------------------+
