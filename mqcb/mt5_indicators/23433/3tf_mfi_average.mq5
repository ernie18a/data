//+------------------------------------------------------------------+
//|                                              3TF_MFI_Average.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Three timeframes Money Flow Index with Average oscillator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   4
//--- plot MFI1
#property indicator_label1  "MFI 1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MFI2
#property indicator_label2  "MFI 2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot MFI3
#property indicator_label3  "MFI 3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot AVG
#property indicator_label4  "Average"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//--- enums
enum ENUM_DRAW_MODE
  {
   DRAW_MODE_STEPS,     // Steps
   DRAW_MODE_SLOPE      // Slope
  };
//---
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,    // Yes
   INPUT_NO    =  0     // No
  };
//--- input parameters
input uint                 InpPeriod         =  14;               // Period
input ENUM_APPLIED_VOLUME  InpAppliedVolume  =  VOLUME_TICK;      // Applied volume
input double               InpOverbought     =  80.0;             // Overbought
input double               InpMiddle         =  50.0;             // Median
input double               InpOversold       =  20.0;             // Oversold
input ENUM_DRAW_MODE       InpDrawMode       =  DRAW_MODE_STEPS;  // Drawing mode
input ENUM_TIMEFRAMES      InpTimeframe1     =  PERIOD_H1;        // First MFI timeframe
input ENUM_TIMEFRAMES      InpTimeframe2     =  PERIOD_H4;        // Second MFI timeframe
input ENUM_TIMEFRAMES      InpTimeframe3     =  PERIOD_D1;        // Third MFI timeframe
input ENUM_INPUT_YES_NO    InpShowMFI1       =  INPUT_YES;        // Show first MFI
input ENUM_INPUT_YES_NO    InpShowMFI2       =  INPUT_YES;        // Show second MFI
input ENUM_INPUT_YES_NO    InpShowMFI3       =  INPUT_YES;        // Show third MFI
//--- indicator buffers
double            BufferMFI1[];
double            BufferMFI2[];
double            BufferMFI3[];
double            BufferMFI1tmp[];
double            BufferMFI2tmp[];
double            BufferMFI3tmp[];
double            BufferAVG[];
//--- global variables
ENUM_TIMEFRAMES   timeframe1;
ENUM_TIMEFRAMES   timeframe2;
ENUM_TIMEFRAMES   timeframe3;
double            overbought;
double            middle;
double            oversold;
int               period;
int               handle_mfi1;
int               handle_mfi2;
int               handle_mfi3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetTimer(90);
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   timeframe1=(InpTimeframe1>Period() ? InpTimeframe1 : Period());
   timeframe2=(InpTimeframe2>Period() ? InpTimeframe2 : Period());
   timeframe3=(InpTimeframe3>Period() ? InpTimeframe3 : Period());
   middle=(InpMiddle>99.9 ? 99.9 : InpMiddle<0.1 ? 0.1 : InpMiddle);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<=middle ? middle+0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=middle ? middle-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMFI1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMFI2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMFI3,INDICATOR_DATA);
   SetIndexBuffer(3,BufferAVG,INDICATOR_DATA);
   SetIndexBuffer(4,BufferMFI1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMFI2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferMFI3tmp,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string label=TimeframeToString(timeframe1)+","+TimeframeToString(timeframe2)+","+TimeframeToString(timeframe3)+" MFI Average("+(string)period+")";
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,middle);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Oversold");
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,TimeframeToString(timeframe1)+" MFI("+(string)period+")");
   PlotIndexSetString(1,PLOT_LABEL,TimeframeToString(timeframe2)+" MFI("+(string)period+")");
   PlotIndexSetString(2,PLOT_LABEL,TimeframeToString(timeframe3)+" MFI("+(string)period+")");
   PlotIndexSetString(3,PLOT_LABEL,"Avg("+TimeframeToString(timeframe1)+","+TimeframeToString(timeframe2)+","+TimeframeToString(timeframe3)+")");
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,InpShowMFI1);
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,InpShowMFI2);
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,InpShowMFI3);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMFI1,true);
   ArraySetAsSeries(BufferMFI2,true);
   ArraySetAsSeries(BufferMFI3,true);
   ArraySetAsSeries(BufferAVG,true);
   ArraySetAsSeries(BufferMFI1tmp,true);
   ArraySetAsSeries(BufferMFI2tmp,true);
   ArraySetAsSeries(BufferMFI3tmp,true);
//--- create handles
   ResetLastError();
   handle_mfi1=iMFI(NULL,timeframe1,period,InpAppliedVolume);
   if(handle_mfi1==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe1)," iMFI("+(string)period+") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mfi2=iMFI(NULL,timeframe2,period,InpAppliedVolume);
   if(handle_mfi2==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe2)," iMFI("+(string)period+") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mfi3=iMFI(NULL,timeframe3,period,InpAppliedVolume);
   if(handle_mfi3==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe3)," iMFI("+(string)period+") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferMFI1,0);
      ArrayInitialize(BufferMFI2,0);
      ArrayInitialize(BufferMFI3,0);
      ArrayInitialize(BufferAVG,0);
      ArrayInitialize(BufferMFI1tmp,0);
      ArrayInitialize(BufferMFI2tmp,0);
      ArrayInitialize(BufferMFI3tmp,0);
     }
//--- Подготовка данных
   if(Time(NULL,timeframe1,1)==0 || Time(NULL,timeframe2,1)==0 || Time(NULL,timeframe3,1)==0)
      return 0;
   
   int bars1=(timeframe1==Period() ? rates_total : Bars(NULL,timeframe1));
   int bars2=(timeframe2==Period() ? rates_total : Bars(NULL,timeframe2));
   int bars3=(timeframe3==Period() ? rates_total : Bars(NULL,timeframe3));
   
   int count1=(limit>1 ? fmin(bars1,rates_total) : 1);
   int copied1=CopyBuffer(handle_mfi1,0,0,count1,BufferMFI1tmp);
   if(copied1!=count1) return 0;
   
   int count2=(limit>1 ? fmin(bars2,rates_total) : 1);
   int copied2=CopyBuffer(handle_mfi2,0,0,count2,BufferMFI2tmp);
   if(copied2!=count2) return 0;
   
   int count3=(limit>1 ? fmin(bars3,rates_total) : 1);
   int copied3=CopyBuffer(handle_mfi3,0,0,count3,BufferMFI3tmp);
   if(copied3!=count3) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      DataConversion(rates_total,NULL,timeframe1,i,BufferMFI1tmp,BufferMFI1,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe2,i,BufferMFI2tmp,BufferMFI2,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe3,i,BufferMFI3tmp,BufferMFI3,InpDrawMode);
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferAVG[i]=(BufferMFI1[i]+BufferMFI2[i]+BufferMFI3[i])/3.0;
   
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
