//+------------------------------------------------------------------+
//|                                                     SVSI_MTF.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Multi timeframe Slow Volume Strength Index oscillator"
#property indicator_separate_window
#property indicator_buffers 15
#property indicator_plots   3
//--- plot SVSI 1
#property indicator_label1  "SVSI 1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SVSI 2
#property indicator_label2  "SVSI 2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot SVSI 3
#property indicator_label3  "SVSI 3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_DRAW_MODE
  {
   DRAW_MODE_STEPS,  // Steps
   DRAW_MODE_SLOPE   // Slope
  };
//--- input parameters
input uint              InpPeriodMA    =  6;                // EMA period
input uint              InpPeriodSm    =  14;               // Smoothing
input double            InpOverbought  =  80.0;             // Overbought
input double            InpMiddle      =  50.0;             // Middle
input double            InpOversold    =  20.0;             // Oversold
input ENUM_DRAW_MODE    InpDrawMode    =  DRAW_MODE_STEPS;  // Drawing mode
input ENUM_TIMEFRAMES   InpTimeframe1  =  PERIOD_H1;        // First SVSI timeframe
input ENUM_TIMEFRAMES   InpTimeframe2  =  PERIOD_H4;        // Second SVSI timeframe
input ENUM_TIMEFRAMES   InpTimeframe3  =  PERIOD_D1;        // Third SVSI timeframe
//--- indicator buffers
double         BufferSVSI1[];
double         BufferSVSI2[];
double         BufferSVSI3[];
double         BufferSVSI1tmp[];
double         BufferSVSI2tmp[];
double         BufferSVSI3tmp[];
double         BufferPos1[];
double         BufferNeg1[];
double         BufferMA1[];
double         BufferPos2[];
double         BufferNeg2[];
double         BufferMA2[];
double         BufferPos3[];
double         BufferNeg3[];
double         BufferMA3[];
//--- global variables
ENUM_TIMEFRAMES   timeframe1;
ENUM_TIMEFRAMES   timeframe2;
ENUM_TIMEFRAMES   timeframe3;
double            overbought;
double            middle;
double            oversold;
int               period_ma;
int               period_sm;
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
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   period_sm=int(InpPeriodSm<1 ? 1 : InpPeriodSm);
   timeframe1=(InpTimeframe1>Period() ? InpTimeframe1 : Period());
   timeframe2=(InpTimeframe2>Period() ? InpTimeframe2 : Period());
   timeframe3=(InpTimeframe3>Period() ? InpTimeframe3 : Period());
   middle=(InpMiddle>99.9 ? 99.9 : InpMiddle<0.1 ? 0.1 : InpMiddle);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<=middle ? middle+0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=middle ? middle-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSVSI1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSVSI2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSVSI3,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSVSI1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferSVSI2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSVSI3tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferPos1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferNeg1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferPos2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferNeg2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,BufferPos3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,BufferNeg3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,BufferMA3,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string label=TimeframeToString(timeframe1)+","+TimeframeToString(timeframe2)+","+TimeframeToString(timeframe3)+" SVSI("+(string)period_ma+","+(string)period_sm+")";
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,middle);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Oversold");
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,TimeframeToString(timeframe1)+" SVSI("+(string)period_ma+","+(string)period_sm+")");
   PlotIndexSetString(1,PLOT_LABEL,TimeframeToString(timeframe2)+" SVSI("+(string)period_ma+","+(string)period_sm+")");
   PlotIndexSetString(2,PLOT_LABEL,TimeframeToString(timeframe3)+" SVSI("+(string)period_ma+","+(string)period_sm+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSVSI1,true);
   ArraySetAsSeries(BufferSVSI2,true);
   ArraySetAsSeries(BufferSVSI3,true);
   ArraySetAsSeries(BufferSVSI1tmp,true);
   ArraySetAsSeries(BufferSVSI2tmp,true);
   ArraySetAsSeries(BufferSVSI3tmp,true);
   ArraySetAsSeries(BufferPos1,true);
   ArraySetAsSeries(BufferNeg1,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferPos2,true);
   ArraySetAsSeries(BufferNeg2,true);
   ArraySetAsSeries(BufferMA2,true);
   ArraySetAsSeries(BufferPos3,true);
   ArraySetAsSeries(BufferNeg3,true);
   ArraySetAsSeries(BufferMA3,true);
//--- create handles
   ResetLastError();
   handle_ma1=iMA(NULL,timeframe1,period_ma,0,MODE_EMA,PRICE_CLOSE);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(NULL,timeframe2,period_ma,0,MODE_EMA,PRICE_CLOSE);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma3=iMA(NULL,timeframe3,period_ma,0,MODE_EMA,PRICE_CLOSE);
   if(handle_ma3==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_sm,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_sm-1;
      ArrayInitialize(BufferSVSI1,EMPTY_VALUE);
      ArrayInitialize(BufferSVSI2,EMPTY_VALUE);
      ArrayInitialize(BufferSVSI3,EMPTY_VALUE);
      ArrayInitialize(BufferSVSI1tmp,0);
      ArrayInitialize(BufferSVSI2tmp,0);
      ArrayInitialize(BufferSVSI3tmp,0);
      ArrayInitialize(BufferPos1,0);
      ArrayInitialize(BufferNeg1,0);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferPos2,0);
      ArrayInitialize(BufferNeg2,0);
      ArrayInitialize(BufferMA2,0);
      ArrayInitialize(BufferPos3,0);
      ArrayInitialize(BufferNeg3,0);
      ArrayInitialize(BufferMA3,0);
     }
//--- Подготовка данных
   if(Time(NULL,timeframe1,1)==0 || Time(NULL,timeframe2,1)==0 || Time(NULL,timeframe3,1)==0)
      return 0;
   
   int bars1=(timeframe1==Period() ? rates_total : Bars(NULL,timeframe1));
   int bars2=(timeframe2==Period() ? rates_total : Bars(NULL,timeframe2));
   int bars3=(timeframe3==Period() ? rates_total : Bars(NULL,timeframe3));
   
   int count1=(limit>1 ? fmin(bars1,rates_total) : 1);
   int copied1=CopyBuffer(handle_ma1,0,0,count1,BufferMA1);
   if(copied1!=count1) return 0;
   
   int count2=(limit>1 ? fmin(bars2,rates_total) : 1);
   int copied2=CopyBuffer(handle_ma2,0,0,count2,BufferMA2);
   if(copied2!=count2) return 0;
   
   int count3=(limit>1 ? fmin(bars3,rates_total) : 1);
   int copied3=CopyBuffer(handle_ma3,0,0,count3,BufferMA3);
   if(copied3!=count3) return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(!DataPreparing(i,timeframe1,BufferMA1,BufferPos1,BufferNeg1)) continue;
      if(!DataPreparing(i,timeframe2,BufferMA2,BufferPos2,BufferNeg2)) continue;
      if(!DataPreparing(i,timeframe3,BufferMA3,BufferPos3,BufferNeg3)) continue;
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      SVSI(rates_total,i,period_sm,BufferPos1,BufferNeg1,BufferSVSI1tmp);
      SVSI(rates_total,i,period_sm,BufferPos2,BufferNeg2,BufferSVSI2tmp);
      SVSI(rates_total,i,period_sm,BufferPos3,BufferNeg3,BufferSVSI3tmp);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      DataConversion(rates_total,NULL,timeframe1,i,BufferSVSI1tmp,BufferSVSI1,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe2,i,BufferSVSI2tmp,BufferSVSI2,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe3,i,BufferSVSI3tmp,BufferSVSI3,InpDrawMode);
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
//| Возвращает Tick Volume                                           |
//+------------------------------------------------------------------+
long TickVolume(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   long array[];
   ArraySetAsSeries(array,true);
   return(CopyTickVolume(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
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
//| Расчёт SVSI                                                      |
//+------------------------------------------------------------------+
void SVSI(const int rates_total,const int shift,const int smoothihg,const double &buffer_pos[],const double &buffer_neg[],double &buffer_svsi[])
  {
   double AvgPosVol=GetSMA(rates_total,shift,smoothihg,buffer_pos);
   double AvgNegVol=GetSMA(rates_total,shift,smoothihg,buffer_neg);
   double svs=(AvgNegVol!=0 ? AvgPosVol/AvgNegVol : 100.0);
   buffer_svsi[shift]=100.0-100.0/(1.0+svs);
  }
//+------------------------------------------------------------------+
//| Подготовка данных                                                |
//+------------------------------------------------------------------+
bool DataPreparing(const int shift,const ENUM_TIMEFRAMES timeframe,const double &buffer_ma[],double &buffer_pos[],double &buffer_neg[])
  {
   double close=Close(NULL,timeframe,shift);
   long volume=TickVolume(NULL,timeframe,shift);
   if(close==0 || volume==0)
      return false;
   if(close>buffer_ma[shift])
     {
      buffer_pos[shift]=volume/1000000.0;
      buffer_neg[shift]=0.0;
     }
   else if(close<buffer_ma[shift])
     {
      buffer_neg[shift]=volume/1000000.0;
      buffer_pos[shift]=0.0;
     }
   else
      buffer_pos[shift]=buffer_neg[shift]=0;
   return true;
  }
//+------------------------------------------------------------------+
