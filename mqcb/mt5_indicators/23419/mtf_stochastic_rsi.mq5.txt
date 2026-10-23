//+------------------------------------------------------------------+
//|                                           MTF_Stochastic_RSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Multi timeframes Stochastic RSI oscillator"
#property indicator_separate_window
#property indicator_buffers 18
#property indicator_plots   6
//--- plot SK1
#property indicator_label1  "SK1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SD1
#property indicator_label2  "SD1"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot SK2
#property indicator_label3  "SK2"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot SD2
#property indicator_label4  "SD2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrLimeGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot SK3
#property indicator_label5  "SK3"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrBlue
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot SD3
#property indicator_label6  "SD3"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrMediumTurquoise
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- enums
enum ENUM_DRAW_MODE
  {
   DRAW_MODE_STEPS,  // Steps
   DRAW_MODE_SLOPE   // Slope
  };
//--- input parameters
input uint              InpPeriodK     =  14;               // Stochastic %K period
input uint              InpPeriodD     =  3;                // Stochastic %D period
input uint              InpSlowing     =  5;                // Stochastic slowing
input uint              InpPeriodRSI   =  14;               // RSI period
input double            InpOverbought  =  80.0;             // Overbought
input double            InpOversold    =  20.0;             // Oversold
input ENUM_DRAW_MODE    InpDrawMode    =  DRAW_MODE_STEPS;  // Drawing mode
input ENUM_TIMEFRAMES   InpTimeframe1  =  PERIOD_H1;        // First Stochastic RSI timeframe
input ENUM_TIMEFRAMES   InpTimeframe2  =  PERIOD_H4;        // Second Stochastic RSI timeframe
input ENUM_TIMEFRAMES   InpTimeframe3  =  PERIOD_D1;        // Third Stochastic RSI timeframe
//--- indicator buffers
double         BufferSK1[];
double         BufferSD1[];
double         BufferSK2[];
double         BufferSD2[];
double         BufferSK3[];
double         BufferSD3[];
double         BufferSK1tmp[];
double         BufferSD1tmp[];
double         BufferSK2tmp[];
double         BufferSD2tmp[];
double         BufferSK3tmp[];
double         BufferSD3tmp[];
double         BufferRSI1[];
double         BufferRSI2[];
double         BufferRSI3[];
double         BufferSKI1[];
double         BufferSKI2[];
double         BufferSKI3[];
//--- global variables
ENUM_TIMEFRAMES   timeframe1;
ENUM_TIMEFRAMES   timeframe2;
ENUM_TIMEFRAMES   timeframe3;
double            overbought;
double            oversold;
int               periodRSI;
int               periodK;
int               periodD;
int               slowing;
int               handle_rsi1;
int               handle_rsi2;
int               handle_rsi3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetTimer(90);
//--- set global variables
   periodRSI=int(InpPeriodRSI<1 ? 1 : InpPeriodRSI);
   periodK=int(InpPeriodK<1 ? 1 : InpPeriodK);
   periodD=int(InpPeriodD<1 ? 1 : InpPeriodD);
   slowing=int(InpSlowing<1 ? 1 : InpSlowing);
   timeframe1=(InpTimeframe1>Period() ? InpTimeframe1 : Period());
   timeframe2=(InpTimeframe2>Period() ? InpTimeframe2 : Period());
   timeframe3=(InpTimeframe3>Period() ? InpTimeframe3 : Period());
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSK1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSD1,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSK2,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSD2,INDICATOR_DATA);
   SetIndexBuffer(4,BufferSK3,INDICATOR_DATA);
   SetIndexBuffer(5,BufferSD3,INDICATOR_DATA);
   SetIndexBuffer(6,BufferSK1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferSD1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferSK2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferSD2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferSK3tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferSD3tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,BufferRSI1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,BufferRSI2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,BufferRSI3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,BufferSKI1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(16,BufferSKI2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(17,BufferSKI3,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string label=TimeframeToString(timeframe1)+","+TimeframeToString(timeframe2)+","+TimeframeToString(timeframe3)+" Stochastic RSI("+(string)periodK+","+(string)periodD+","+(string)slowing+","+(string)periodRSI+")";
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"Oversold");
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,TimeframeToString(timeframe1)+" Sto%K("+(string)periodK+","+(string)periodD+","+(string)slowing+","+(string)periodRSI+")");
   PlotIndexSetString(1,PLOT_LABEL,TimeframeToString(timeframe1)+" Sto%D("+(string)periodK+","+(string)periodD+","+(string)slowing+","+(string)periodRSI+")");
   PlotIndexSetString(2,PLOT_LABEL,TimeframeToString(timeframe2)+" Sto%K("+(string)periodK+","+(string)periodD+","+(string)slowing+","+(string)periodRSI+")");
   PlotIndexSetString(3,PLOT_LABEL,TimeframeToString(timeframe2)+" Sto%D("+(string)periodK+","+(string)periodD+","+(string)slowing+","+(string)periodRSI+")");
   PlotIndexSetString(4,PLOT_LABEL,TimeframeToString(timeframe3)+" Sto%K("+(string)periodK+","+(string)periodD+","+(string)slowing+","+(string)periodRSI+")");
   PlotIndexSetString(5,PLOT_LABEL,TimeframeToString(timeframe3)+" Sto%D("+(string)periodK+","+(string)periodD+","+(string)slowing+","+(string)periodRSI+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSK1,true);
   ArraySetAsSeries(BufferSD1,true);
   ArraySetAsSeries(BufferSK2,true);
   ArraySetAsSeries(BufferSD2,true);
   ArraySetAsSeries(BufferSK3,true);
   ArraySetAsSeries(BufferSD3,true);
   ArraySetAsSeries(BufferSK1tmp,true);
   ArraySetAsSeries(BufferSD1tmp,true);
   ArraySetAsSeries(BufferSK2tmp,true);
   ArraySetAsSeries(BufferSD2tmp,true);
   ArraySetAsSeries(BufferSK3tmp,true);
   ArraySetAsSeries(BufferSD3tmp,true);
   ArraySetAsSeries(BufferRSI1,true);
   ArraySetAsSeries(BufferRSI2,true);
   ArraySetAsSeries(BufferRSI3,true);
   ArraySetAsSeries(BufferSKI1,true);
   ArraySetAsSeries(BufferSKI2,true);
   ArraySetAsSeries(BufferSKI3,true);
//--- create handles
   ResetLastError();
   handle_rsi1=iRSI(NULL,timeframe1,periodRSI,PRICE_CLOSE);
   if(handle_rsi1==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe1)," iRSI("+(string)periodRSI+") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_rsi2=iRSI(NULL,timeframe2,periodRSI,PRICE_CLOSE);
   if(handle_rsi2==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe2)," iRSI("+(string)periodRSI+") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_rsi3=iRSI(NULL,timeframe3,periodRSI,PRICE_CLOSE);
   if(handle_rsi3==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe3)," iRSI("+(string)periodRSI+") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(slowing,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferSK1,EMPTY_VALUE);
      ArrayInitialize(BufferSD1,EMPTY_VALUE);
      ArrayInitialize(BufferSK2,EMPTY_VALUE);
      ArrayInitialize(BufferSD2,EMPTY_VALUE);
      ArrayInitialize(BufferSK3,EMPTY_VALUE);
      ArrayInitialize(BufferSD3,EMPTY_VALUE);
      ArrayInitialize(BufferSK1tmp,0);
      ArrayInitialize(BufferSD1tmp,0);
      ArrayInitialize(BufferSK2tmp,0);
      ArrayInitialize(BufferSD2tmp,0);
      ArrayInitialize(BufferSK3tmp,0);
      ArrayInitialize(BufferSD3tmp,0);
      ArrayInitialize(BufferRSI1,0);
      ArrayInitialize(BufferRSI2,0);
      ArrayInitialize(BufferRSI3,0);
      ArrayInitialize(BufferSKI1,0);
      ArrayInitialize(BufferSKI2,0);
      ArrayInitialize(BufferSKI3,0);
     }
//--- Подготовка данных
   if(Time(NULL,timeframe1,1)==0 || Time(NULL,timeframe2,1)==0 || Time(NULL,timeframe3,1)==0)
      return 0;
   
   int bars1=(timeframe1==Period() ? rates_total : Bars(NULL,timeframe1));
   int bars2=(timeframe2==Period() ? rates_total : Bars(NULL,timeframe2));
   int bars3=(timeframe3==Period() ? rates_total : Bars(NULL,timeframe3));
   
   int count1=(limit>1 ? fmin(bars1,rates_total) : 1);
   int copied1=CopyBuffer(handle_rsi1,0,0,count1,BufferRSI1);
   if(copied1!=count1) return 0;
   
   int count2=(limit>1 ? fmin(bars2,rates_total) : 1);
   int copied2=CopyBuffer(handle_rsi2,0,0,count2,BufferRSI2);
   if(copied2!=count2) return 0;
   
   int count3=(limit>1 ? fmin(bars3,rates_total) : 1);
   int copied3=CopyBuffer(handle_rsi3,0,0,count3,BufferRSI3);
   if(copied3!=count3) return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      DataPreparing(count1,i,periodK,BufferRSI1,BufferSKI1);
      DataPreparing(count2,i,periodK,BufferRSI2,BufferSKI2);
      DataPreparing(count3,i,periodK,BufferRSI3,BufferSKI3);
     }
      
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferSK1tmp[i]=GetSMA(count1,i,slowing,BufferSKI1);
      BufferSK2tmp[i]=GetSMA(count2,i,slowing,BufferSKI2);
      BufferSK3tmp[i]=GetSMA(count3,i,slowing,BufferSKI3);
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferSD1tmp[i]=GetSMA(count1,i,periodD,BufferSK1tmp);
      BufferSD2tmp[i]=GetSMA(count2,i,periodD,BufferSK2tmp);
      BufferSD3tmp[i]=GetSMA(count3,i,periodD,BufferSK3tmp);
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      DataConversion(rates_total,NULL,timeframe1,i,BufferSK1tmp,BufferSK1,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe2,i,BufferSK2tmp,BufferSK2,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe3,i,BufferSK3tmp,BufferSK3,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe1,i,BufferSD1tmp,BufferSD1,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe2,i,BufferSD2tmp,BufferSD2,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe3,i,BufferSD3tmp,BufferSD3,InpDrawMode);
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
//| Подготовка данных                                                |
//+------------------------------------------------------------------+
void DataPreparing(const int rates_total,const int shift,const int period_k,const double &buffer_rsi[],double &buffer_ski[])
  {
   if(shift>rates_total-period_k-1)
      return;
   double max=0,min=0;
   for(int j=(shift+period_k-1); j>=shift; j--)
     {
      if(j==(shift+period_k-1))
         max=min=buffer_rsi[j];
      else
        {
         if(buffer_rsi[j]>max) max=buffer_rsi[j];
         if(buffer_rsi[j]<min) min=buffer_rsi[j];
        }
     }
   buffer_ski[shift]=(max!=min ? (buffer_rsi[shift]-min)/(max-min)*100.0 : 100.0);
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
