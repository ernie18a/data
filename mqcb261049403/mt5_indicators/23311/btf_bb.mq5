//+------------------------------------------------------------------+
//|                                                       BTF_BB.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Bigger Time Frame Bollinger Bands"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
//--- plot Top
#property indicator_label1  "BB Top"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Middle
#property indicator_label2  "BB Middle"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Bottom
#property indicator_label3  "BB Bottom"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_DRAW_MODE
  {
   DRAW_MODE_STEPS,  // Steps
   DRAW_MODE_SLOPE   // Slope
  };
//---
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint                 InpPeriod         =  14;               // BB period
input double               InpDeviation      =  2.0;              // BB deviation
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;      // BB applied price
input ENUM_TIMEFRAMES      InpTimeframe      =  PERIOD_H1;        // BB timeframe
input ENUM_DRAW_MODE       InpDrawMode       =  DRAW_MODE_STEPS;  // Drawing mode
input ENUM_INPUT_YES_NO    InpShowMiddle     =  INPUT_YES;        // Show middle lines
input ENUM_INPUT_YES_NO    InpUseAlerts      =  INPUT_YES;        // Show alerts
input ENUM_INPUT_YES_NO    InpSendMail       =  INPUT_NO;         // Send mails
input ENUM_INPUT_YES_NO    InpSendPush       =  INPUT_YES;        // Send push-notifications
//--- indicator buffers
double         BufferTop[];
double         BufferMiddle[];
double         BufferBottom[];
double         BufferTopBB[];
double         BufferMiddleBB[];
double         BufferBottomBB[];
//--- global variables
ENUM_TIMEFRAMES   timeframeBB;
double            deviation;
int               period;
int               handle_bb;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetTimer(90);
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   deviation=InpDeviation;
   timeframeBB=(InpTimeframe>Period() ? InpTimeframe : Period());
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMiddle,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(3,BufferTopBB,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMiddleBB,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferBottomBB,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string label=TimeframeToString(timeframeBB)+" Bollinger Bands ("+(string)period+")";
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,TimeframeToString(timeframeBB)+" BB Top("+(string)period+")");
   PlotIndexSetString(1,PLOT_LABEL,TimeframeToString(timeframeBB)+" BB Middle("+(string)period+")");
   PlotIndexSetString(2,PLOT_LABEL,TimeframeToString(timeframeBB)+" BB Bottom("+(string)period+")");
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,InpShowMiddle);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferMiddle,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferTopBB,true);
   ArraySetAsSeries(BufferMiddleBB,true);
   ArraySetAsSeries(BufferBottomBB,true);
//--- create MA's handles
   ResetLastError();
   handle_bb=iBands(NULL,timeframeBB,period,0,deviation,InpAppliedPrice);
   if(handle_bb==INVALID_HANDLE)
     {
      Print("The ",TimeframeToString(timeframeBB)," iBands("+(string)period+","+DoubleToString(deviation,1)+") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//--- get timeframe
   Time(NULL,timeframeBB,1);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period,4) || Bars(NULL,timeframeBB)<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferMiddle,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferTopBB,0);
      ArrayInitialize(BufferMiddleBB,0);
      ArrayInitialize(BufferBottomBB,0);
     }
//--- Подготовка данных
   if(Time(NULL,timeframeBB,1)==0)
      return 0;
   int bars=(timeframeBB==Period() ? rates_total : Bars(NULL,timeframeBB));
   int count=(limit>1 ? fmin(bars,rates_total) : 1),copied=0;
   copied=CopyBuffer(handle_bb,UPPER_BAND,0,count,BufferTopBB);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb,BASE_LINE,0,count,BufferMiddleBB);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_bb,LOWER_BAND,0,count,BufferBottomBB);
   if(copied!=count) return 0;
      
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      DataConversion(rates_total,NULL,timeframeBB,i,BufferTopBB,BufferTop,InpDrawMode);
      DataConversion(rates_total,NULL,timeframeBB,i,BufferMiddleBB,BufferMiddle,InpDrawMode);
      DataConversion(rates_total,NULL,timeframeBB,i,BufferBottomBB,BufferBottom,InpDrawMode);
     }
//--- Сигналы
   static datetime last_time=0;
   string Alerts="";
   if(time[0]>last_time && (close[0]>BufferTop[0] || (close[0]<BufferBottom[0] && BufferBottom[0]!=EMPTY_VALUE)))
     {
      string pos=(close[0]>BufferTop[0] ? "above the Upper" : "below the Lower");
      string message=Symbol()+", "+TimeframeToString(Period())+": Price is "+pos+" "+TimeframeToString(timeframeBB)+" Bollinger Band";
      if(InpUseAlerts) Alert(message);
      if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Bigger Time Frame Bollinger Bands Signal",message);
      if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);
      last_time=TimeCurrent();
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Time(NULL,timeframeBB,1);
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
