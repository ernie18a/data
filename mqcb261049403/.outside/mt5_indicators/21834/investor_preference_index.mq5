//+------------------------------------------------------------------+
//|                                    Investor_Preference_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Investor preference index indicator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot IPI
#property indicator_label1  "IPref Idx"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSteelBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input string   InpInstrument  =  "USDJPY";   // Instrument
input uint     InpPeriodROC   =  24;         // ROC period
input uint     InpPeriodFast  =  15;         // Fast smoothing period
input uint     InpPeriodSlow  =  38;         // Slow smoothing period
input uint     InpPeriodRes   =  54;         // Result smoothing period
//--- indicator buffers
double         BufferIPI[];
double         BufferMA1[];
double         BufferMA2[];
double         BufferB1[];
double         BufferB2[];
double         BufferCloseI[];
//--- global variables
int            period_roc;
int            period_fast;
int            period_slow;
int            period_res;
int            period_max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- enable timer
   EventSetTimer(90);
//--- set global variables
   if(!SymbolCheck(InpInstrument))
      return INIT_FAILED;
   if(InpInstrument==Symbol())
     {
      Print("Error. The Instrument must not be the same as the current symbol.");
      return INIT_FAILED;
     }
   period_roc=int(InpPeriodROC<1 ? 1 : InpPeriodROC);
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow==period_fast ? period_fast+1 : InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_res=int(InpPeriodRes<1 ? 1 : InpPeriodRes);
   period_max=fmax(period_roc,fmax(period_fast,fmax(period_slow,period_res)));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferIPI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferB1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferB2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferCloseI,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Investor preference index ("+InpInstrument+","+(string)period_roc+","+(string)period_fast+","+(string)period_slow+","+(string)period_res+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetString(0,PLOT_LABEL,"IPIdx("+InpInstrument+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferIPI,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
   ArraySetAsSeries(BufferB1,true);
   ArraySetAsSeries(BufferB2,true);
   ArraySetAsSeries(BufferCloseI,true);
   //---
   Time(InpInstrument,0);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Time(InpInstrument,0);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_roc-1;
      ArrayInitialize(BufferIPI,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMA2,0);
      ArrayInitialize(BufferB1,0);
      ArrayInitialize(BufferB2,0);
      ArrayInitialize(BufferCloseI,0);
     }

//--- Подготовка данных
   int count=(limit>1 ? Bars(InpInstrument,PERIOD_CURRENT) : 1),copied=0;
   copied=CopyClose(InpInstrument,PERIOD_CURRENT,0,count,BufferCloseI);
   if(copied<1) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int index1=BarShift(InpInstrument,PERIOD_CURRENT,time[i]);
      int index2=BarShift(InpInstrument,PERIOD_CURRENT,time[i+period_roc-1]);
      if(index1==WRONG_VALUE || index2==WRONG_VALUE)
         continue;
      double roc1=ROC(Symbol(),i,i+period_roc-1);
      double roc2=ROC(InpInstrument,index1,index2);
      if(roc1==0 || roc2==0)
         continue;
      BufferB1[i]=roc1-roc2;
      BufferB2[i]=GetSMA(rates_total,i,period_fast,BufferB1)-GetSMA(rates_total,i,period_slow,BufferB1);
      BufferIPI[i]=100.0*(period_res*GetSMA(rates_total,i,period_res,BufferB2)+1.0);
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
//| Возвращает Time                                                  |
//+------------------------------------------------------------------+
datetime Time(const string symbol_name,const int shift)
  {
   datetime array[];
   return(CopyTime(symbol_name,PERIOD_CURRENT,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Возвращает Close                                                 |
//+------------------------------------------------------------------+
double Close(const string symbol_name,const int shift)
  {
   double array[];
   return(CopyClose(symbol_name,PERIOD_CURRENT,shift,1,array)==1 ? array[0] : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| ROC                                                              |
//+------------------------------------------------------------------+
double ROC(const string symbol_name,const int index_1,const int index_2)
  {
   double pr1=Close(symbol_name,index_1);
   double pr2=Close(symbol_name,index_2);
   if(pr1==WRONG_VALUE || pr2==WRONG_VALUE)
      return 0;
   double Log2=log(pr2);
   return(Log2!=0 ? 100.0*log(pr1-Log2)/Log2 : 0);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double GetSMA(const int rates_total,const int index,const int period,const double &price[],const bool as_series=true)
  {
//---
   double result=0.0;
//--- check position
   bool check_index=(as_series ? index<=rates_total-period-1 : index>=period-1);
   if(period<1 || !check_index)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
      result=result+(as_series ? price[index+i]: price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+
