//+------------------------------------------------------------------+
//|                                                 Key_Reversal.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Key Reversal indicator"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "Top KR"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Bottom KR"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriod      =  2;          // Trend detection period
input ENUM_INPUT_YES_NO InpUseFilter   =  INPUT_YES;  // Use trend detection filter
input ENUM_INPUT_YES_NO InpUseAlert    =  INPUT_YES;  // Show alerts
input ENUM_INPUT_YES_NO InpSendMail    =  INPUT_NO;   // Send mails
input ENUM_INPUT_YES_NO InpSendPush    =  INPUT_YES;  // Send push-notifications
//--- indicator buffers
double         BufferTKR[];
double         BufferBKR[];
//--- global variables
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTKR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBKR,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Key Reversal"+(InpUseFilter ? " ("+(string)period+" bars trend)" : ""));
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTKR,true);
   ArraySetAsSeries(BufferBKR,true);
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-2;
      ArrayInitialize(BufferTKR,EMPTY_VALUE);
      ArrayInitialize(BufferBKR,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   static datetime last_time=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferBKR[i]=(Verification(i,open,high,low,close)== 1 ? low[i]  : EMPTY_VALUE);
      BufferTKR[i]=(Verification(i,open,high,low,close)==-1 ? high[i] : EMPTY_VALUE);
     }
     
//--- Сигналы
   string Alerts="";
   if(time[0]>last_time && (BufferTKR[1]!=EMPTY_VALUE || BufferBKR[1]!=EMPTY_VALUE))
     {
      string dir=(BufferBKR[1]!=EMPTY_VALUE ? "Up" : BufferTKR[1]!=EMPTY_VALUE ? "Down" : "");
      string message=Symbol()+", "+TimeframeToString(Period())+": Key Reversal "+dir+" Signal.";
      if(InpUseAlert) Alert(message);
      if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Key Reversal indicator Signal",message);
      if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);
      last_time=TimeCurrent();
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Поиск паттернов                                                  |
//+------------------------------------------------------------------+
int Verification(const int shift,const double &open[],const double &high[],const double &low[],const double &close[])
  {
   int signal=(close[shift]>high[shift+1] ? 1 : close[shift]<low[shift+1] ? -1 : 0);
   if(!InpUseFilter)
      return signal;
   for(int i=1; i<=period; i++)
     {
      int check=(close[shift+i]>open[shift+i] ? 1 : close[shift+i]<open[shift+i] ? -1 : 0);
      if((signal==1 && check==1) || (signal==-1 && check==-1))
         return 0;
     }
   return signal;
  }
//+------------------------------------------------------------------+
//| Timeframe to string                                              |
//+------------------------------------------------------------------+
string TimeframeToString(const ENUM_TIMEFRAMES timeframe)
  { 
   return StringSubstr(EnumToString(timeframe),7);
  }
//+------------------------------------------------------------------+
