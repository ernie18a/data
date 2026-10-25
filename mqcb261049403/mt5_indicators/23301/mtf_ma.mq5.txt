//+------------------------------------------------------------------+
//|                                                       MTF_MA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Multitimeframe Moving Average"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot MA
#property indicator_label1  "MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- enums
enum ENUM_DRAW_MODE
  {
   DRAW_MODE_STEPS,  // Steps
   DRAW_MODE_SLOPE   // Slope
  };
//--- input parameters
input uint                 InpPeriod         =  14;               // Period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;         // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;      // Applied price
input ENUM_TIMEFRAMES      InpTimeframe      =  PERIOD_H4;        // Timeframe
input ENUM_DRAW_MODE       InpDrawMode       =  DRAW_MODE_STEPS;  // Drawing mode
//--- indicator buffers
double            BufferTFMA[];
double            BufferMA[];
//--- global variables
ENUM_TIMEFRAMES   timeframe_g;
int               period_ma;
int               handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetTimer(90);
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
   timeframe_g=(InpTimeframe>Period() ? InpTimeframe : Period());
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTFMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_DATA);
//--- setting indicator parameters
   string label=MethodToString(InpMethod)+" ("+(string)period_ma+","+TimeframeToString(timeframe_g)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,label);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTFMA,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,timeframe_g,period_ma,0,InpMethod,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA("+(string)period_ma+") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- get timeframe
   Time(NULL,timeframe_g,1);
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
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ma-2;
      ArrayInitialize(BufferTFMA,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   if(Time(NULL,timeframe_g,1)==0)
      return 0;
   
   int bars=(timeframe_g==Period() ? rates_total : Bars(NULL,timeframe_g));
   
   int count=(limit>1 ? fmin(bars,rates_total) : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
      
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      datetime time_g=Time(NULL,timeframe_g,i);
      if(time_g==0)
         continue;
      int bar_curr=BarShift(NULL,PERIOD_CURRENT,time_g);
      if(bar_curr==WRONG_VALUE || bar_curr>rates_total-period_ma-2)
         continue;
      int shift=(i>0 ? 1 : 0);
      datetime time_next=Time(NULL,timeframe_g,i-shift);
      if(time_next==0)
         continue;
      int bar_next=(i>0 ? BarShift(NULL,PERIOD_CURRENT,time_next) : 0);   
      if(bar_next==WRONG_VALUE || bar_next>rates_total-period_ma-2)
         continue;
      BufferTFMA[bar_curr]=BufferMA[i];
      if(InpDrawMode==DRAW_MODE_STEPS)
         for(int j=bar_curr; j>=bar_next; j--)
            BufferTFMA[j]=BufferTFMA[bar_curr];
      else
        {
         datetime time_prev=Time(NULL,timeframe_g,i+1);
         if(time_prev==0)
            continue;
         int bar_prev=BarShift(NULL,PERIOD_CURRENT,time_prev);   
         if(bar_prev==WRONG_VALUE)
            continue;
         for(int j=bar_prev; j>=bar_curr; j--)
            BufferTFMA[j]=EquationDirect(bar_prev,BufferTFMA[bar_prev],bar_curr,BufferTFMA[bar_curr],j);
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Time(NULL,timeframe_g,1);
  }  
//+------------------------------------------------------------------+
//| Timeframe to string                                              |
//+------------------------------------------------------------------+
string TimeframeToString(const ENUM_TIMEFRAMES timeframe)
  {
   return StringSubstr(EnumToString(timeframe),7);
  }
//+------------------------------------------------------------------+
//| Возвращает наименование метода МА                                |
//+------------------------------------------------------------------+
string MethodToString(ENUM_MA_METHOD method)
  {
   return StringSubstr(EnumToString(method),5);
  }
//+------------------------------------------------------------------+
//| Уравнение прямой                                                 |
//+------------------------------------------------------------------+
double EquationDirect(const int left_bar,const double left_price,const int right_bar,const double right_price,const int bar_to_search) 
  {
   return(right_bar==left_bar ? left_price : (right_price-left_price)/(right_bar-left_bar)*(bar_to_search-left_bar)+left_price);
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
