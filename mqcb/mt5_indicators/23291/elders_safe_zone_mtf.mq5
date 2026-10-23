//+------------------------------------------------------------------+
//|                                         Elders_Safe_Zone_MTF.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Multi timeframe Elder's Safe Zone indicator"
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   3
//--- plot ESZ
#property indicator_label1  "ESZ 1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot ESZ
#property indicator_label2  "ESZ 2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot ESZ
#property indicator_label3  "ESZ 3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- enums
enum ENUM_DRAW_MODE
  {
   DRAW_MODE_STEPS,  // Steps
   DRAW_MODE_SLOPE   // Slope
  };
//--- input parameters
input uint              InpPeriod      =  10;               // ESZ Period
input uint              InpStopFactor  =  3;                // Stop factor
input uint              InpPeriodEMA   =  13;               // EMA period
input ENUM_DRAW_MODE    InpDrawMode    =  DRAW_MODE_STEPS;  // Drawing mode
input ENUM_TIMEFRAMES   InpTimeframe1  =  PERIOD_H1;        // First ESZ timeframe
input ENUM_TIMEFRAMES   InpTimeframe2  =  PERIOD_H4;        // Second ESZ timeframe
input ENUM_TIMEFRAMES   InpTimeframe3  =  PERIOD_D1;        // Third ESZ timeframe
//--- indicator buffers
double         BufferESZ1[];
double         BufferESZ2[];
double         BufferESZ3[];
double         BufferESZ1tmp[];
double         BufferESZ2tmp[];
double         BufferESZ3tmp[];
double         BufferEMA1[];
double         BufferEMA2[];
double         BufferEMA3[];
//--- global variables
ENUM_TIMEFRAMES   timeframe1;
ENUM_TIMEFRAMES   timeframe2;
ENUM_TIMEFRAMES   timeframe3;
int               period_esz;
int               period_ema;
int               stop_factor;
int               handle_ma1;
int               handle_ma2;
int               handle_ma3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetTimer(90);
//--- set global variables
   period_esz=int(InpPeriod<1 ? 1 : InpPeriod);
   period_ema=int(InpPeriodEMA<1 ? 1 : InpPeriodEMA);
   stop_factor=int(InpStopFactor<1 ? 1 : InpStopFactor);
   timeframe1=(InpTimeframe1>Period() ? InpTimeframe1 : Period());
   timeframe2=(InpTimeframe2>Period() ? InpTimeframe2 : Period());
   timeframe3=(InpTimeframe3>Period() ? InpTimeframe3 : Period());
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferESZ1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferESZ2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferESZ3,INDICATOR_DATA);
   SetIndexBuffer(3,BufferESZ1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferESZ2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferESZ3tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferEMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferEMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferEMA3,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string label=TimeframeToString(timeframe1)+","+TimeframeToString(timeframe2)+","+TimeframeToString(timeframe3)+" Elder's Safe Zone ("+(string)period_esz+","+(string)stop_factor+","+(string)period_ema+")";
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,TimeframeToString(timeframe1)+" ESZ("+(string)period_esz+","+(string)stop_factor+","+(string)period_ema+")");
   PlotIndexSetString(1,PLOT_LABEL,TimeframeToString(timeframe2)+" ESZ("+(string)period_esz+","+(string)stop_factor+","+(string)period_ema+")");
   PlotIndexSetString(2,PLOT_LABEL,TimeframeToString(timeframe3)+" ESZ("+(string)period_esz+","+(string)stop_factor+","+(string)period_ema+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferESZ1,true);
   ArraySetAsSeries(BufferESZ2,true);
   ArraySetAsSeries(BufferESZ3,true);
   ArraySetAsSeries(BufferESZ1tmp,true);
   ArraySetAsSeries(BufferESZ2tmp,true);
   ArraySetAsSeries(BufferESZ3tmp,true);
   ArraySetAsSeries(BufferEMA1,true);
   ArraySetAsSeries(BufferEMA2,true);
   ArraySetAsSeries(BufferEMA3,true);
//--- create MA's handles
   ResetLastError();
   handle_ma1=iMA(NULL,timeframe1,period_ema,0,MODE_EMA,PRICE_CLOSE);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(",(string)period_ema,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(NULL,timeframe2,period_ema,0,MODE_EMA,PRICE_CLOSE);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(",(string)period_ema,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma3=iMA(NULL,timeframe3,period_ema,0,MODE_EMA,PRICE_CLOSE);
   if(handle_ma3==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(",(string)period_ema,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- get timeframe
   Time(NULL,timeframe1,1);
   Time(NULL,timeframe2,1);
   Time(NULL,timeframe3,1);
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
   if(rates_total<fmax(period_esz,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров на текущем графике
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_esz-3;
      ArrayInitialize(BufferESZ1,EMPTY_VALUE);
      ArrayInitialize(BufferESZ2,EMPTY_VALUE);
      ArrayInitialize(BufferESZ3,EMPTY_VALUE);
      ArrayInitialize(BufferESZ1tmp,0);
      ArrayInitialize(BufferESZ2tmp,0);
      ArrayInitialize(BufferESZ3tmp,0);
      ArrayInitialize(BufferEMA1,0);
      ArrayInitialize(BufferEMA2,0);
      ArrayInitialize(BufferEMA3,0);
     }
//--- Подготовка данных
   if(Time(NULL,timeframe1,1)==0 || Time(NULL,timeframe2,1)==0 || Time(NULL,timeframe3,1)==0)
      return 0;
   
   int bars1=(timeframe1==Period() ? rates_total : Bars(NULL,timeframe1));
   int bars2=(timeframe2==Period() ? rates_total : Bars(NULL,timeframe2));
   int bars3=(timeframe3==Period() ? rates_total : Bars(NULL,timeframe3));
   
   int count1=(limit>1 ? fmin(bars1,rates_total) : 1);
   int copied1=CopyBuffer(handle_ma1,0,0,count1,BufferEMA1);
   if(copied1!=count1) return 0;
   
   int count2=(limit>1 ? fmin(bars2,rates_total) : 1);
   int copied2=CopyBuffer(handle_ma2,0,0,count2,BufferEMA2);
   if(copied2!=count2) return 0;
   
   int count3=(limit>1 ? fmin(bars3,rates_total) : 1);
   int copied3=CopyBuffer(handle_ma3,0,0,count3,BufferEMA3);
   if(copied3!=count3) return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      ESZ(NULL,timeframe1,count1,i,period_esz,BufferEMA1,BufferESZ1tmp);
      ESZ(NULL,timeframe2,count2,i,period_esz,BufferEMA2,BufferESZ2tmp);
      ESZ(NULL,timeframe3,count3,i,period_esz,BufferEMA3,BufferESZ3tmp);
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      DataConversion(rates_total,NULL,timeframe1,i,BufferESZ1tmp,BufferESZ1,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe2,i,BufferESZ2tmp,BufferESZ2,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe3,i,BufferESZ3tmp,BufferESZ3,InpDrawMode);
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
   Time(NULL,timeframe2,1);
   Time(NULL,timeframe3,1);
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
//| Возвращает High                                                  |
//+------------------------------------------------------------------+
double High(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyHigh(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Возвращает Low                                                   |
//+------------------------------------------------------------------+
double Low(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyLow(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
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
//| Расчёт Elder's Safe Zone                                         |
//+------------------------------------------------------------------+
void ESZ(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int rates_total,const int shift,const int period,const double &buffer_ema[],double &buffer_esz[])
  {
   if(shift>rates_total-period-3)
      return;
   double PreSafeStop=buffer_esz[shift+1];
   double Pen=0;
   double Counter=0;
   double SafeStop=0;
   
   double low=Low(symbol_name,timeframe,shift);
   if(low==0)
      return;
   double high=High(symbol_name,timeframe,shift);
   if(high==0)
      return;
   double close=Close(symbol_name,timeframe,shift);
   if(close==0)
      return;
      
   if(buffer_ema[shift]>buffer_ema[shift+1])
     {
      for(int j=0; j<period; j++)
        {
         double pl0=Low(symbol_name,timeframe,shift+j);
         double pl1=Low(symbol_name,timeframe,shift+j+1);
         if(pl0==0 || pl1==0)
            continue;
         if(pl0<pl1)
           {
            Pen=pl1-pl0+Pen;
            Counter++;
           }
        }
      if(Counter>0)
         SafeStop=close-(stop_factor*(Pen/Counter));
      else
         SafeStop=close-(stop_factor*Pen);
      if(SafeStop<PreSafeStop && buffer_ema[shift+1]>buffer_ema[shift+2])
         SafeStop=PreSafeStop;
     }
   else if(buffer_ema[shift]<buffer_ema[shift+1])
     {
      for(int j=0; j<period; j++)
        {
         double ph0=High(symbol_name,timeframe,shift+j);
         double ph1=High(symbol_name,timeframe,shift+j+1);
         if(ph0>ph1)
           {
            Pen=ph0-ph1+Pen;
            Counter++;
           }
        }
      if(Counter>0)
         SafeStop=close+(stop_factor*(Pen/Counter));
      else
         SafeStop=close+(stop_factor*Pen);
      if(SafeStop>PreSafeStop && buffer_ema[shift+1]<buffer_ema[shift+2])
         SafeStop=PreSafeStop;
     }
   PreSafeStop=SafeStop;
   buffer_esz[shift]=SafeStop;
  }
//+------------------------------------------------------------------+
