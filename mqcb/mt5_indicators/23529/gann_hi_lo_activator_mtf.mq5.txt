//+------------------------------------------------------------------+
//|                                     Gann_Hi_Lo_Activator_MTF.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Multi timeframe Gann Hi Lo Activator indicator"
#property indicator_chart_window
#property indicator_buffers 18
#property indicator_plots   3
//--- plot GHLA1
#property indicator_label1  "GHLA1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot GHLA2
#property indicator_label2  "GHLA2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDeepSkyBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot GHLA3
#property indicator_label3  "GHLA3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_DRAW_MODE
  {
   DRAW_MODE_STEPS,  // Steps
   DRAW_MODE_SLOPE   // Slope
  };
//--- input parameters
input uint              InpPeriod      =  10;               // GHLA period
input ENUM_DRAW_MODE    InpDrawMode    =  DRAW_MODE_STEPS;  // Drawing mode
input ENUM_TIMEFRAMES   InpTimeframe1  =  PERIOD_H1;        // First GHLA timeframe
input ENUM_TIMEFRAMES   InpTimeframe2  =  PERIOD_H4;        // Second GHLA timeframe
input ENUM_TIMEFRAMES   InpTimeframe3  =  PERIOD_D1;        // Third GHLA timeframe
//--- indicator buffers
double            BufferGHLA1[];
double            BufferGHLA2[];
double            BufferGHLA3[];
double            BufferGHLA1tmp[];
double            BufferGHLA2tmp[];
double            BufferGHLA3tmp[];
double            BufferDir1[];
double            BufferDir2[];
double            BufferDir3[];
double            BufferMAH1[];
double            BufferMAL1[];
double            BufferMAH2[];
double            BufferMAL2[];
double            BufferMAH3[];
double            BufferMAL3[];
double            BufferClose1[];
double            BufferClose2[];
double            BufferClose3[];
//--- global variables
ENUM_TIMEFRAMES   timeframe1;
ENUM_TIMEFRAMES   timeframe2;
ENUM_TIMEFRAMES   timeframe3;
int               period_ghla;
int               handle_mah1;
int               handle_mal1;
int               handle_mah2;
int               handle_mal2;
int               handle_mah3;
int               handle_mal3;
int               handle_cls1;
int               handle_cls2;
int               handle_cls3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetTimer(90);
//--- set global variables
   period_ghla=int(InpPeriod<1 ? 1 : InpPeriod);
   timeframe1=(InpTimeframe1>Period() ? InpTimeframe1 : Period());
   timeframe2=(InpTimeframe2>Period() ? InpTimeframe2 : Period());
   timeframe3=(InpTimeframe3>Period() ? InpTimeframe3 : Period());
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferGHLA1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferGHLA2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferGHLA3,INDICATOR_DATA);
   SetIndexBuffer(3,BufferGHLA1tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferGHLA2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferGHLA3tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferMAH1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferMAL1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferMAH2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferMAL2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferMAH3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferMAL3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,BufferDir1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,BufferDir2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,BufferDir3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,BufferClose1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(16,BufferClose2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(17,BufferClose3,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string label=TimeframeToString(timeframe1)+","+TimeframeToString(timeframe2)+","+TimeframeToString(timeframe3)+" Gann Hi Lo Activator("+(string)period_ghla+")";
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,TimeframeToString(timeframe1)+" GHLA("+(string)period_ghla+")");
   PlotIndexSetString(1,PLOT_LABEL,TimeframeToString(timeframe2)+" GHLA("+(string)period_ghla+")");
   PlotIndexSetString(2,PLOT_LABEL,TimeframeToString(timeframe3)+" GHLA("+(string)period_ghla+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferGHLA1,true);
   ArraySetAsSeries(BufferGHLA2,true);
   ArraySetAsSeries(BufferGHLA3,true);
   ArraySetAsSeries(BufferGHLA1tmp,true);
   ArraySetAsSeries(BufferGHLA2tmp,true);
   ArraySetAsSeries(BufferGHLA3tmp,true);
   ArraySetAsSeries(BufferMAH1,true);
   ArraySetAsSeries(BufferMAL1,true);
   ArraySetAsSeries(BufferMAH2,true);
   ArraySetAsSeries(BufferMAL2,true);
   ArraySetAsSeries(BufferMAH3,true);
   ArraySetAsSeries(BufferMAL3,true);
   ArraySetAsSeries(BufferDir1,true);
   ArraySetAsSeries(BufferDir2,true);
   ArraySetAsSeries(BufferDir3,true);
   ArraySetAsSeries(BufferClose1,true);
   ArraySetAsSeries(BufferClose2,true);
   ArraySetAsSeries(BufferClose3,true);
//--- create handles
   ResetLastError();
   handle_mah1=iMA(NULL,timeframe1,period_ghla,0,MODE_SMA,PRICE_HIGH);
   if(handle_mah1==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe1)," iMA("+(string)period_ghla+") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mal1=iMA(NULL,timeframe1,period_ghla,0,MODE_SMA,PRICE_LOW);
   if(handle_mal1==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe1)," iMA("+(string)period_ghla+") by PRICE_LOW object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mah2=iMA(NULL,timeframe2,period_ghla,0,MODE_SMA,PRICE_HIGH);
   if(handle_mah2==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe2)," iMA("+(string)period_ghla+") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mal2=iMA(NULL,timeframe2,period_ghla,0,MODE_SMA,PRICE_LOW);
   if(handle_mal2==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe2)," iMA("+(string)period_ghla+") by PRICE_LOW object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mah3=iMA(NULL,timeframe3,period_ghla,0,MODE_SMA,PRICE_HIGH);
   if(handle_mah3==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe3)," iMA("+(string)period_ghla+") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mal3=iMA(NULL,timeframe3,period_ghla,0,MODE_SMA,PRICE_LOW);
   if(handle_mal3==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe3)," iMA("+(string)period_ghla+") by PRICE_LOW object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_cls1=iMA(NULL,timeframe1,1,0,MODE_SMA,PRICE_CLOSE);
   if(handle_cls1==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe1)," iMA(1) by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_cls2=iMA(NULL,timeframe2,1,0,MODE_SMA,PRICE_CLOSE);
   if(handle_cls2==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe2)," iMA(1) by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_cls3=iMA(NULL,timeframe3,1,0,MODE_SMA,PRICE_CLOSE);
   if(handle_cls3==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframe3)," iMA(1) by PRICE_HIGH object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_ghla,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferGHLA1,EMPTY_VALUE);
      ArrayInitialize(BufferGHLA2,EMPTY_VALUE);
      ArrayInitialize(BufferGHLA3,EMPTY_VALUE);
      ArrayInitialize(BufferGHLA1tmp,0);
      ArrayInitialize(BufferGHLA2tmp,0);
      ArrayInitialize(BufferGHLA3tmp,0);
      ArrayInitialize(BufferMAH1,0);
      ArrayInitialize(BufferMAL1,0);
      ArrayInitialize(BufferMAH2,0);
      ArrayInitialize(BufferMAL2,0);
      ArrayInitialize(BufferMAH3,0);
      ArrayInitialize(BufferMAL3,0);
      ArrayInitialize(BufferDir1,0);
      ArrayInitialize(BufferDir2,0);
      ArrayInitialize(BufferDir3,0);
      ArrayInitialize(BufferClose1,0);
      ArrayInitialize(BufferClose2,0);
      ArrayInitialize(BufferClose3,0);
     }
//--- Подготовка данных
   if(Time(NULL,timeframe1,1)==0 || Time(NULL,timeframe2,1)==0 || Time(NULL,timeframe3,1)==0)
      return 0;
   
   int bars1=(timeframe1==Period() ? rates_total : Bars(NULL,timeframe1));
   int bars2=(timeframe2==Period() ? rates_total : Bars(NULL,timeframe2));
   int bars3=(timeframe3==Period() ? rates_total : Bars(NULL,timeframe3));
   
   int count1=(limit>1 ? fmin(bars1,rates_total) : 1),copied=0;
   copied=CopyBuffer(handle_mah1,0,0,count1,BufferMAH1);
   if(copied!=count1) return 0;
   copied=CopyBuffer(handle_mal1,0,0,count1,BufferMAL1);
   if(copied!=count1) return 0;
   copied=CopyBuffer(handle_cls1,0,0,count1,BufferClose1);
   if(copied!=count1) return 0;
   
   int count2=(limit>1 ? fmin(bars2,rates_total) : 1);
   copied=CopyBuffer(handle_mah2,0,0,count2,BufferMAH2);
   if(copied!=count2) return 0;
   copied=CopyBuffer(handle_mal2,0,0,count2,BufferMAL2);
   if(copied!=count2) return 0;
   copied=CopyBuffer(handle_cls2,0,0,count2,BufferClose2);
   if(copied!=count2) return 0;
   
   int count3=(limit>1 ? fmin(bars3,rates_total) : 1);
   copied=CopyBuffer(handle_mah3,0,0,count3,BufferMAH3);
   if(copied!=count3) return 0;
   copied=CopyBuffer(handle_mal3,0,0,count3,BufferMAL3);
   if(copied!=count3) return 0;
   copied=CopyBuffer(handle_cls3,0,0,count3,BufferClose3);
   if(copied!=count3) return 0;
   
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      GHLA(rates_total,i,period_ghla,BufferClose1,BufferDir1,BufferMAH1,BufferMAL1,BufferGHLA1tmp);
      GHLA(rates_total,i,period_ghla,BufferClose2,BufferDir2,BufferMAH2,BufferMAL2,BufferGHLA2tmp);
      GHLA(rates_total,i,period_ghla,BufferClose3,BufferDir3,BufferMAH3,BufferMAL3,BufferGHLA3tmp);
     }
      
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      DataConversion(rates_total,NULL,timeframe1,i,BufferGHLA1tmp,BufferGHLA1,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe2,i,BufferGHLA2tmp,BufferGHLA2,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe3,i,BufferGHLA3tmp,BufferGHLA3,InpDrawMode);
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
void GHLA(const int rates_total,const int shift,const int period,const double &buffer_close[],double &buffer_dir[],double &buffer_mah[],double &buffer_mal[],double &buffer_ghla[])
  {
   if(shift>rates_total)
      return;
   double avgH=buffer_mah[shift];
   double avgL=buffer_mal[shift];
   double close=buffer_close[shift];
   if(avgH==0 || avgL==0 || close==0)
      return;
   int sw=(close>avgH ? 1 : close<avgL ? -1 : 0);
   buffer_dir[shift]=(sw!=0 ? sw : buffer_dir[shift+1]);
   buffer_ghla[shift]=(buffer_dir[shift]<0 ? avgH : avgL);
  }
//+------------------------------------------------------------------+
