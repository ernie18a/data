//+------------------------------------------------------------------+
//|                                                     PWMA_MTF.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Multi Time Frame Power Weighted Moving Average"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
//--- plot PWMA1
#property indicator_label1  "PWMA1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot PWMA2
#property indicator_label2  "PWMA2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot PWMA3
#property indicator_label3  "PWMA3"
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
input uint              InpPeriod      =  14;               // Period
input double            InpPower       =  2.0;              // Power
input ENUM_DRAW_MODE    InpDrawMode    =  DRAW_MODE_STEPS;  // Drawing mode
input ENUM_TIMEFRAMES   InpTimeframe1  =  PERIOD_H1;        // First PWMA timeframe
input ENUM_TIMEFRAMES   InpTimeframe2  =  PERIOD_H4;        // Second PWMA timeframe
input ENUM_TIMEFRAMES   InpTimeframe3  =  PERIOD_D1;        // Third PWMA timeframe
//--- indicator buffers
double            BufferPWMA1[];
double            BufferPWMA2[];
double            BufferPWMA3[];
double            BufferPWMA1tmp[];
double            BufferPWMA2tmp[];
double            BufferPWMA3tmp[];
//--- global variables
ENUM_TIMEFRAMES   timeframe1;
ENUM_TIMEFRAMES   timeframe2;
ENUM_TIMEFRAMES   timeframe3;
double            power;
int               period_pw;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetTimer(90);
//--- set global variables
   period_pw=int(InpPeriod<1 ? 1 : InpPeriod);
   power=InpPower;
   timeframe1=(InpTimeframe1>Period() ? InpTimeframe1 : Period());
   timeframe2=(InpTimeframe2>Period() ? InpTimeframe2 : Period());
   timeframe3=(InpTimeframe3>Period() ? InpTimeframe3 : Period());
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPWMA1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferPWMA2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferPWMA3,INDICATOR_DATA);
   SetIndexBuffer(3,BufferPWMA1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferPWMA2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferPWMA3tmp,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string label=TimeframeToString(timeframe1)+","+TimeframeToString(timeframe2)+","+TimeframeToString(timeframe3)+" Power weighted MA("+(string)period_pw+","+DoubleToString(power,1)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,TimeframeToString(timeframe1)+" PWMA("+(string)period_pw+")");
   PlotIndexSetString(1,PLOT_LABEL,TimeframeToString(timeframe2)+" PWMA("+(string)period_pw+")");
   PlotIndexSetString(2,PLOT_LABEL,TimeframeToString(timeframe3)+" PWMA("+(string)period_pw+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPWMA1,true);
   ArraySetAsSeries(BufferPWMA2,true);
   ArraySetAsSeries(BufferPWMA3,true);
   ArraySetAsSeries(BufferPWMA1tmp,true);
   ArraySetAsSeries(BufferPWMA2tmp,true);
   ArraySetAsSeries(BufferPWMA3tmp,true);
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
   if(rates_total<fmax(period_pw,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_pw-2;
      ArrayInitialize(BufferPWMA1,EMPTY_VALUE);
      ArrayInitialize(BufferPWMA2,EMPTY_VALUE);
      ArrayInitialize(BufferPWMA3,EMPTY_VALUE);
      ArrayInitialize(BufferPWMA1tmp,0);
      ArrayInitialize(BufferPWMA2tmp,0);
      ArrayInitialize(BufferPWMA3tmp,0);
     }
//--- Подготовка данных
   if(Time(NULL,timeframe1,1)==0 || Time(NULL,timeframe2,1)==0 || Time(NULL,timeframe3,1)==0)
      return 0;
   
   int bars1=(timeframe1==Period() ? rates_total : Bars(NULL,timeframe1));
   int bars2=(timeframe2==Period() ? rates_total : Bars(NULL,timeframe2));
   int bars3=(timeframe3==Period() ? rates_total : Bars(NULL,timeframe3));
   int count1=(limit>1 ? fmin(bars1,rates_total) : 1);
   int count2=(limit>1 ? fmin(bars2,rates_total) : 1);
   int count3=(limit>1 ? fmin(bars3,rates_total) : 1);

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      PWMA(NULL,timeframe1,count1,i,period_pw,BufferPWMA1tmp);
      PWMA(NULL,timeframe2,count2,i,period_pw,BufferPWMA2tmp);
      PWMA(NULL,timeframe3,count3,i,period_pw,BufferPWMA3tmp);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      DataConversion(rates_total,NULL,timeframe1,i,BufferPWMA1tmp,BufferPWMA1,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe2,i,BufferPWMA2tmp,BufferPWMA2,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe3,i,BufferPWMA3tmp,BufferPWMA3,InpDrawMode);
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
//| Расчёт PWMA                                                      |
//+------------------------------------------------------------------+
void PWMA(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int rates_total,const int shift,const int period,double &buffer_pwma[])
  {
   if(shift>rates_total-1-period)
      return;
   double sum1=0,sum2=0;

   for(int j=0; j<=period-1; j++)
     {
      double close=Close(symbol_name,timeframe,shift+j);
      if(close==0)
         continue;
      sum1+=close*pow(period-j,power);
      sum2+=pow(period-j,power);
     }
   buffer_pwma[shift]=sum1/sum2;
  }
//+------------------------------------------------------------------+
