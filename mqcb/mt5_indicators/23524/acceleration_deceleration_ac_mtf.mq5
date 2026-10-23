//+------------------------------------------------------------------+
//|                             Acceleration_Deceleration_AC_MTF.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Multi timeframes Bill Williams Accelerator Oscillator"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   1
//--- plot ADAC
#property indicator_label1  "MTF AC"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  8
//--- enums
enum ENUM_DRAW_MODE
  {
   DRAW_MODE_STEPS,  // Steps
   DRAW_MODE_SLOPE   // Slope
  };
//--- input parameters
input uint              InpPeriodFast  =  5;                // AO Fast MA period
input uint              InpPeriodSlow  =  34;               // AO Slow MA period
input uint              InpPeriodACMA  =  5;                // AC MA period
input ENUM_TIMEFRAMES   InpTimeframe   =  0;                // AC timeframe
input ENUM_DRAW_MODE    InpDrawMode    =  DRAW_MODE_STEPS;  // Drawing mode
//--- indicator buffers
double         BufferADAC[];
double         BufferColors[];
double         BufferADACtmp[];
double         BufferColorsTmp[];
double         BufferMedian[];
double         BufferAC[];
double         BufferAvgAC[];
double         BufferMAH[];
double         BufferMAL[];
//--- global variables
ENUM_TIMEFRAMES   timeframe1;
int               period_fast;
int               period_slow;
int               period_acma;
int               handle_maH;
int               handle_maL;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetTimer(90);
//--- set global variables
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_acma=int(InpPeriodACMA<1 ? 1 : InpPeriodACMA);
   timeframe1=(InpTimeframe>Period() ? InpTimeframe : Period());
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferADAC,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferADACtmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferColorsTmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMedian,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferAC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferAvgAC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferMAH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferMAL,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string label=TimeframeToString(timeframe1)+" AC("+(string)period_fast+","+(string)period_slow+","+(string)period_acma+")";
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,TimeframeToString(timeframe1)+" AC");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferADAC,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferADACtmp,true);
   ArraySetAsSeries(BufferColorsTmp,true);
   ArraySetAsSeries(BufferMedian,true);
   ArraySetAsSeries(BufferAC,true);
   ArraySetAsSeries(BufferAvgAC,true);
   ArraySetAsSeries(BufferMAH,true);
   ArraySetAsSeries(BufferMAL,true);
//--- create handles
   ResetLastError();
   handle_maH=iMA(NULL,timeframe1,1,0,MODE_SMA,PRICE_HIGH);
   if(handle_maH==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maL=iMA(NULL,timeframe1,1,0,MODE_SMA,PRICE_LOW);
   if(handle_maL==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(1) object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferADAC,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferADACtmp,0);
      ArrayInitialize(BufferColorsTmp,2);
      ArrayInitialize(BufferMedian,0);
      ArrayInitialize(BufferAC,0);
      ArrayInitialize(BufferAvgAC,0);
      ArrayInitialize(BufferMAH,0);
      ArrayInitialize(BufferMAL,0);
     }
//--- Подготовка данных
   if(Time(NULL,timeframe1,1)==0)
      return 0;
   int bars=(timeframe1==Period() ? rates_total : Bars(NULL,timeframe1));
   int count=(limit>1 ? fmin(bars,rates_total) : 1),copied=0;
   copied=CopyBuffer(handle_maH,0,0,count,BufferMAH);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maL,0,0,count,BufferMAL);
   if(copied!=count) return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferMedian[i]=(BufferMAH[i]+BufferMAL[i])/2.0;
      double avg_median_fast=GetSMA(rates_total,i,period_fast,BufferMedian);
      double avg_median_slow=GetSMA(rates_total,i,period_slow,BufferMedian);
      BufferAC[i]=avg_median_fast-avg_median_slow;
      BufferAvgAC[i]=GetSMA(rates_total,i,period_acma,BufferAC);
      BufferADACtmp[i]=BufferAC[i]-BufferAvgAC[i];
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferColorsTmp[i]=(BufferADACtmp[i]>BufferADACtmp[i+1] ? 0 : BufferADACtmp[i]<BufferADACtmp[i+1] ? 1 : 2);
     
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      DataConversion(rates_total,NULL,timeframe1,i,BufferADACtmp,BufferADAC,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe1,i,BufferColorsTmp,BufferColors,InpDrawMode);
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
//| Возвращает Close                                                 |
//+------------------------------------------------------------------+
double Close(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyClose(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
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
