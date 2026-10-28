//+------------------------------------------------------------------+
//|                                                     MTF_LRMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Multi Timeframe Linear Regression Moving Average with signal line"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot LWMA
#property indicator_label1  "LRMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_DRAW_MODE
  {
   DRAW_MODE_STEPS,  // Steps
   DRAW_MODE_SLOPE   // Slope
  };
//--- input parameters
input uint              InpPeriod      =  34;               // LRMA period
input uint              InpSignal      =  5;                // Signal period
input ENUM_TIMEFRAMES   InpTimeframe   =  PERIOD_H1;        // LRMA timeframe
input ENUM_DRAW_MODE    InpDrawMode    =  DRAW_MODE_STEPS;  // Drawing mode
//--- indicator buffers
double         BufferLRMA[];
double         BufferSignal[];
double         BufferLRMATmp[];
double         BufferSignalTmp[];
double         BufferLWMA[];
double         BufferSMA[];
//--- global variables
ENUM_TIMEFRAMES   timeframe1;
int               period_lrma;
int               signal;
int               handle_lwma;
int               handle_sma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetTimer(90);
//--- set global variables
   period_lrma=int(InpPeriod<1 ? 1 : InpPeriod);
   signal=int(InpSignal<1 ? 1 : InpSignal);
   timeframe1=(InpTimeframe>Period() ? InpTimeframe : Period());
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferLRMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLRMATmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferSignalTmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferLWMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string label=TimeframeToString(timeframe1)+" LRMA("+(string)period_lrma+","+(string)signal+")";
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,TimeframeToString(timeframe1)+" LRMA("+(string)period_lrma+")");
   PlotIndexSetString(1,PLOT_LABEL,TimeframeToString(timeframe1)+" Signal("+(string)signal+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferLRMA,true);
   ArraySetAsSeries(BufferSignal,true);
   ArraySetAsSeries(BufferLRMATmp,true);
   ArraySetAsSeries(BufferSignalTmp,true);
   ArraySetAsSeries(BufferLWMA,true);
   ArraySetAsSeries(BufferSMA,true);
//--- create handles
   ResetLastError();
   handle_lwma=iMA(NULL,timeframe1,period_lrma,0,MODE_LWMA,PRICE_CLOSE);
   if(handle_lwma==INVALID_HANDLE)
     {
      Print(__LINE__,": The ",TimeframeToString(timeframe1)," iMA(",(string)period_lrma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,timeframe1,period_lrma,0,MODE_SMA,PRICE_CLOSE);
   if(handle_sma==INVALID_HANDLE)
     {
      Print(__LINE__,": The ",TimeframeToString(timeframe1)," iMA(",(string)period_lrma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- get timeframe
   Time(NULL,timeframe1,1);
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
   if(rates_total<fmax(signal,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-signal-2;
      ArrayInitialize(BufferLRMA,0);
      ArrayInitialize(BufferSignal,0);
      ArrayInitialize(BufferLRMATmp,0);
      ArrayInitialize(BufferSignalTmp,0);
      ArrayInitialize(BufferLWMA,0);
      ArrayInitialize(BufferSMA,0);
     }
//--- Подготовка данных
   if(Time(NULL,timeframe1,1)==0)
      return 0;
   int bars=(timeframe1==Period() ? rates_total : Bars(NULL,timeframe1));
   int count=(limit>1 ? fmin(bars,rates_total) : 1),copied=0;
   copied=CopyBuffer(handle_lwma,0,0,count,BufferLWMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
      
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferLRMATmp[i]=3.0*BufferLWMA[i]-2.0*BufferSMA[i];
      BufferSignalTmp[i]=GetSMA(bars,i,signal,BufferLRMATmp);
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      DataConversion(rates_total,NULL,timeframe1,i,BufferLRMATmp,BufferLRMA,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe1,i,BufferSignalTmp,BufferSignal,InpDrawMode);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Time(NULL,timeframe1,1);
  }
//+------------------------------------------------------------------+
//| Transfering data from the source timeframe to current timeframe  |
//+------------------------------------------------------------------+
void DataConversion(const int rates_total,
                    const string symbol_name,
                    const ENUM_TIMEFRAMES timeframe_src,
                    const int shift,
                    const double &buffer_src[],
                    double &buffer_dest[],
                    ENUM_DRAW_MODE mode=DRAW_MODE_STEPS
                   )
  {
   if(timeframe_src==Period())
     {
      buffer_dest[shift]=buffer_src[shift];
      return;
     }
   int bar_curr=BarToCurrent(symbol_name,timeframe_src,shift);
   if(bar_curr>rates_total-1)
      return;
   int bar_prev=BarToCurrent(symbol_name,timeframe_src,shift+1);
   int bar_next=(shift>0 ? BarToCurrent(symbol_name,timeframe_src,shift-1) : 0);
   if(bar_prev==WRONG_VALUE || bar_curr==WRONG_VALUE || bar_next==WRONG_VALUE)
      return;
   buffer_dest[bar_curr]=buffer_src[shift];
   if(mode==DRAW_MODE_STEPS)
      for(int j=bar_curr; j>=bar_next; j--)
         buffer_dest[j]=buffer_dest[bar_curr];
   else
     {
      if(bar_prev>rates_total-1) return;
      for(int j=bar_prev; j>=bar_curr; j--)
         buffer_dest[j]=EquationDirect(bar_prev,buffer_dest[bar_prev],bar_curr,buffer_dest[bar_curr],j);
      if(shift==0)
         for(int j=bar_curr; j>=0; j--)
            buffer_dest[j]=buffer_dest[bar_curr];
     }
  }
//+------------------------------------------------------------------+
//| Возвращает бар заданного таймфрейма как бар текущего таймфрейма  |
//+------------------------------------------------------------------+
int BarToCurrent(const string symbol_name,const ENUM_TIMEFRAMES timeframe_src,const int shift,bool exact=false)
  {
   datetime time=Time(symbol_name,timeframe_src,shift);
   return(time!=0 ? BarShift(symbol_name,Period(),time,exact) : WRONG_VALUE);
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
datetime Time(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   datetime array[];
   ArraySetAsSeries(array,true);
   return(CopyTime(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Уравнение прямой                                                 |
//+------------------------------------------------------------------+
double EquationDirect(const int left_bar,const double left_price,const int right_bar,const double right_price,const int bar_to_search)
  {
   return(right_bar==left_bar ? left_price : (right_price-left_price)/(right_bar-left_bar)*(bar_to_search-left_bar)+left_price);
  }
//+------------------------------------------------------------------+
//| Timeframe to string                                              |
//+------------------------------------------------------------------+
string TimeframeToString(const ENUM_TIMEFRAMES timeframe)
  {
   return StringSubstr(EnumToString(timeframe),7);
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
      result+=(as_series ? price[index+i]: price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+
