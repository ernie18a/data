//+------------------------------------------------------------------+
//|                                       3TF_Stochastic_Average.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Three timeframes Stochastic Average oscillator"
#property indicator_separate_window
#property indicator_buffers 14
#property indicator_plots   8
//--- plot Stoch1
#property indicator_label1  "Stoch1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal1
#property indicator_label2  "Signal1"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_DOT
#property indicator_width2  1
//--- plot Stoch2
#property indicator_label3  "Stoch2"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Signal2
#property indicator_label4  "Signal2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_DOT
#property indicator_width4  1
//--- plot Stoch3
#property indicator_label5  "Stoch3"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGray
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot Signal3
#property indicator_label6  "Signal3"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrGray
#property indicator_style6  STYLE_DOT
#property indicator_width6  1
//--- plot AvgSto
#property indicator_label7  "AvgSto"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrBlue
#property indicator_style7  STYLE_SOLID
#property indicator_width7  2
//--- plot AvgSig
#property indicator_label8  "AvgSig"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrBlue
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- enums
enum ENUM_DRAW_MODE
  {
   DRAW_MODE_STEPS,  // Steps
   DRAW_MODE_SLOPE   // Slope
  };
//---
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,    // Yes
   INPUT_NO    =  0     // No
  };
//--- input parameters
input uint              InpPeriodK     =  5;                // Stochastic %K period
input uint              InpPeriodD     =  3;                // Stochastic %D period
input uint              InpSlowing     =  3;                // Stochastic Slowing
input double            InpOverbought  =  80.0;             // Overbought
input double            InpOversold    =  20.0;             // Oversold
input ENUM_DRAW_MODE    InpDrawMode    =  DRAW_MODE_STEPS;  // Drawing mode
input ENUM_TIMEFRAMES   InpTimeframe1  =  PERIOD_H1;        // First Stochastic timeframe
input ENUM_TIMEFRAMES   InpTimeframe2  =  PERIOD_H4;        // Second Stochastic timeframe
input ENUM_TIMEFRAMES   InpTimeframe3  =  PERIOD_D1;        // Third Stochastic timeframe
input ENUM_INPUT_YES_NO InpShowSto1    =  INPUT_YES;        // Show first Stochastic
input ENUM_INPUT_YES_NO InpShowSto2    =  INPUT_YES;        // Show second Stochastic
input ENUM_INPUT_YES_NO InpShowSto3    =  INPUT_YES;        // Show third Stochastic
//--- indicator buffers
double         BufferStoch1[];
double         BufferSignal1[];
double         BufferStoch2[];
double         BufferSignal2[];
double         BufferStoch3[];
double         BufferSignal3[];
double         BufferAvgSto[];
double         BufferAvgSig[];
double         BufferStoch1tmp[];
double         BufferSignal1tmp[];
double         BufferStoch2tmp[];
double         BufferSignal2tmp[];
double         BufferStoch3tmp[];
double         BufferSignal3tmp[];
//--- global variables
ENUM_TIMEFRAMES   timeframe1;
ENUM_TIMEFRAMES   timeframe2;
ENUM_TIMEFRAMES   timeframe3;
double            overbought;
double            oversold;
int               periodK;
int               periodD;
int               slowing;
int               handle_sto1;
int               handle_sto2;
int               handle_sto3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetTimer(90);
//--- set global variables
   periodK=int(InpPeriodK<1 ? 1 : InpPeriodK);
   periodD=int(InpPeriodD<1 ? 1 : InpPeriodD);
   slowing=int(InpSlowing<1 ? 1 : InpSlowing);
   timeframe1=(InpTimeframe1>Period() ? InpTimeframe1 : Period());
   timeframe2=(InpTimeframe2>Period() ? InpTimeframe2 : Period());
   timeframe3=(InpTimeframe3>Period() ? InpTimeframe3 : Period());
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferStoch1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal1,INDICATOR_DATA);
   SetIndexBuffer(2,BufferStoch2,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSignal2,INDICATOR_DATA);
   SetIndexBuffer(4,BufferStoch3,INDICATOR_DATA);
   SetIndexBuffer(5,BufferSignal3,INDICATOR_DATA);
   SetIndexBuffer(6,BufferAvgSto,INDICATOR_DATA);
   SetIndexBuffer(7,BufferAvgSig,INDICATOR_DATA);
   SetIndexBuffer(8,BufferStoch1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferSignal1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferStoch2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferSignal2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,BufferStoch3tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,BufferSignal3tmp,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string label=TimeframeToString(timeframe1)+","+TimeframeToString(timeframe2)+","+TimeframeToString(timeframe3)+" Stochastic("+(string)periodK+","+(string)periodD+","+(string)slowing+")";
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,TimeframeToString(timeframe1)+" Stochastic");
   PlotIndexSetString(1,PLOT_LABEL,TimeframeToString(timeframe1)+" Signal");
   PlotIndexSetString(2,PLOT_LABEL,TimeframeToString(timeframe2)+" Stochastic");
   PlotIndexSetString(3,PLOT_LABEL,TimeframeToString(timeframe2)+" Signal");
   PlotIndexSetString(4,PLOT_LABEL,TimeframeToString(timeframe3)+" Stochastic");
   PlotIndexSetString(5,PLOT_LABEL,TimeframeToString(timeframe3)+" Signal");
   PlotIndexSetString(6,PLOT_LABEL,"AvgSto("+TimeframeToString(timeframe1)+","+TimeframeToString(timeframe2)+","+TimeframeToString(timeframe3)+")");
   PlotIndexSetString(7,PLOT_LABEL,"AvgSig("+TimeframeToString(timeframe1)+","+TimeframeToString(timeframe2)+","+TimeframeToString(timeframe3)+")");
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,InpShowSto1);
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,InpShowSto1);
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,InpShowSto2);
   PlotIndexSetInteger(3,PLOT_DRAW_TYPE,InpShowSto2);
   PlotIndexSetInteger(4,PLOT_DRAW_TYPE,InpShowSto3);
   PlotIndexSetInteger(5,PLOT_DRAW_TYPE,InpShowSto3);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferStoch1,true);
   ArraySetAsSeries(BufferSignal1,true);
   ArraySetAsSeries(BufferStoch2,true);
   ArraySetAsSeries(BufferSignal2,true);
   ArraySetAsSeries(BufferStoch3,true);
   ArraySetAsSeries(BufferSignal3,true);
   ArraySetAsSeries(BufferAvgSto,true);
   ArraySetAsSeries(BufferAvgSig,true);
   ArraySetAsSeries(BufferStoch1tmp,true);
   ArraySetAsSeries(BufferSignal1tmp,true);
   ArraySetAsSeries(BufferStoch2tmp,true);
   ArraySetAsSeries(BufferSignal2tmp,true);
   ArraySetAsSeries(BufferStoch3tmp,true);
   ArraySetAsSeries(BufferSignal3tmp,true);
//--- create handles
   ResetLastError();
   handle_sto1=iStochastic(NULL,timeframe1,periodK,periodD,slowing,MODE_SMA,STO_LOWHIGH);
   if(handle_sto1==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe1)," iStochastic(",(string)periodK,",",(string)periodD,",",(string)slowing,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sto2=iStochastic(NULL,timeframe2,periodK,periodD,slowing,MODE_SMA,STO_LOWHIGH);
   if(handle_sto2==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe2)," iStochastic(",(string)periodK,",",(string)periodD,",",(string)slowing,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sto3=iStochastic(NULL,timeframe3,periodK,periodD,slowing,MODE_SMA,STO_LOWHIGH);
   if(handle_sto3==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe3)," iStochastic(",(string)periodK,",",(string)periodD,",",(string)slowing,") object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferStoch1,0);
      ArrayInitialize(BufferSignal1,0);
      ArrayInitialize(BufferStoch2,0);
      ArrayInitialize(BufferSignal2,0);
      ArrayInitialize(BufferStoch3,0);
      ArrayInitialize(BufferSignal3,0);
      ArrayInitialize(BufferAvgSto,0);
      ArrayInitialize(BufferAvgSig,0);
      ArrayInitialize(BufferStoch1tmp,0);
      ArrayInitialize(BufferSignal1tmp,0);
      ArrayInitialize(BufferStoch2tmp,0);
      ArrayInitialize(BufferSignal2tmp,0);
      ArrayInitialize(BufferStoch3tmp,0);
      ArrayInitialize(BufferSignal3tmp,0);
     }
//--- Подготовка данных
   if(Time(NULL,timeframe1,1)==0 || Time(NULL,timeframe2,1)==0 || Time(NULL,timeframe3,1)==0)
      return 0;
   
   int bars1=(timeframe1==Period() ? rates_total : Bars(NULL,timeframe1));
   int bars2=(timeframe2==Period() ? rates_total : Bars(NULL,timeframe2));
   int bars3=(timeframe3==Period() ? rates_total : Bars(NULL,timeframe3));
   
   int count1=(limit>1 ? fmin(bars1,rates_total) : 1),copied=0;
   copied=CopyBuffer(handle_sto1,MAIN_LINE,0,count1,BufferStoch1tmp);
   if(copied!=count1) return 0;
   copied=CopyBuffer(handle_sto1,SIGNAL_LINE,0,count1,BufferSignal1tmp);
   if(copied!=count1) return 0;
   
   int count2=(limit>1 ? fmin(bars2,rates_total) : 1);
   copied=CopyBuffer(handle_sto2,MAIN_LINE,0,count2,BufferStoch2tmp);
   if(copied!=count2) return 0;
   copied=CopyBuffer(handle_sto2,SIGNAL_LINE,0,count2,BufferSignal2tmp);
   if(copied!=count2) return 0;
   
   int count3=(limit>1 ? fmin(bars3,rates_total) : 1);
   copied=CopyBuffer(handle_sto3,MAIN_LINE,0,count3,BufferStoch3tmp);
   if(copied!=count3) return 0;
   copied=CopyBuffer(handle_sto3,SIGNAL_LINE,0,count3,BufferSignal3tmp);
   if(copied!=count3) return 0;
      
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      DataConversion(rates_total,NULL,timeframe1,i,BufferStoch1tmp,BufferStoch1,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe1,i,BufferSignal1tmp,BufferSignal1,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe2,i,BufferStoch2tmp,BufferStoch2,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe2,i,BufferSignal2tmp,BufferSignal2,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe3,i,BufferStoch3tmp,BufferStoch3,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe3,i,BufferSignal3tmp,BufferSignal3,InpDrawMode);
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferAvgSto[i]  = (BufferStoch1[i]+BufferStoch2[i]+BufferStoch3[i])/3.0;
      BufferAvgSig[i] = (BufferSignal1[i]+BufferSignal2[i]+BufferSignal3[i])/3.0;
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
