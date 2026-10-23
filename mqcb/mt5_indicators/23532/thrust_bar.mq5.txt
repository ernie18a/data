//+------------------------------------------------------------------+
//|                                                   Thrust_Bar.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Thrust Bar indicator"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   3
//--- plot UP
#property indicator_label1  "Bullish"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Bearish"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Candle
#property indicator_label3  "Open;High;Low;Close"
#property indicator_type3   DRAW_COLOR_CANDLES
#property indicator_color3  clrForestGreen,clrRed,clrLightGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0, // No
  };
//---
enum ENUM_IND_METHOD
  {
   IND_METHOD_ATR,   // ATR
   IND_METHOD_PT     // Points
  };
//--- input parameters
input ENUM_IND_METHOD   InpMethod      =  IND_METHOD_ATR;   // Indicator mode
input uint              InpPeriodATR   =  14;               // ATR period
input double            InpMultiplier  =  2.0;              // ATR multiplier/Size candle in points
input ENUM_INPUT_YES_NO InpUseLong     =  INPUT_YES;        // Use long side
input ENUM_INPUT_YES_NO InpUseShort    =  INPUT_YES;        // Use short side
input ENUM_INPUT_YES_NO InpUseAlerts   =  INPUT_YES;        // Use alerts
input ENUM_INPUT_YES_NO InpSendMail    =  INPUT_NO;         // Send mail
input ENUM_INPUT_YES_NO InpSendPush    =  INPUT_YES;        // Send push-notifications
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferATR[];
double         BufferCandleOpen[];
double         BufferCandleHigh[];
double         BufferCandleLow[];
double         BufferCandleClose[];
double         BufferColors[];
//--- global variables
double         multiplier;
int            period_atr;
int            period_max;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_atr=int(InpPeriodATR<1 ? 1 : InpPeriodATR);
   multiplier=InpMultiplier;
   period_max=(InpMethod==IND_METHOD_ATR ? period_atr : 4);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCandleOpen,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCandleHigh,INDICATOR_DATA);
   SetIndexBuffer(4,BufferCandleLow,INDICATOR_DATA);
   SetIndexBuffer(5,BufferCandleClose,INDICATOR_DATA);
   SetIndexBuffer(6,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(7,BufferATR,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- setting indicator parameters
   string data=(InpMethod==IND_METHOD_ATR ? "(ATR period "+(string)period_atr+","+DoubleToString(multiplier,1)+")" : "("+DoubleToString(multiplier,0)+" Points)");
   IndicatorSetString(INDICATOR_SHORTNAME,"Thrust Bar "+data);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferCandleOpen,true);
   ArraySetAsSeries(BufferCandleHigh,true);
   ArraySetAsSeries(BufferCandleLow,true);
   ArraySetAsSeries(BufferCandleClose,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferATR,true);
//--- create handles
   ResetLastError();
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_atr);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atr,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
   if(rates_total<period_max) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferCandleOpen,EMPTY_VALUE);
      ArrayInitialize(BufferCandleHigh,EMPTY_VALUE);
      ArrayInitialize(BufferCandleLow,EMPTY_VALUE);
      ArrayInitialize(BufferCandleClose,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferATR,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_atr,MAIN_LINE,0,count,BufferATR);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   static datetime last_time=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferCandleOpen[i]=BufferCandleHigh[i]=BufferCandleLow[i]=BufferCandleClose[i]=EMPTY_VALUE;
      BufferColors[i]=2;
      double x=(InpMethod==IND_METHOD_ATR ? multiplier*BufferATR[i]/Point() : multiplier);
      double y=(close[i]-open[i])/Point();
      if(y>x && InpUseLong)
        {
         BufferUP[i]=low[i];
         BufferCandleOpen[i]=open[i];
         BufferCandleHigh[i]=high[i];
         BufferCandleLow[i]=low[i];
         BufferCandleClose[i]=close[i];
         BufferColors[i]=0;
         if(i==0 && last_time!=time[0])
           {
            string message=Symbol()+", "+TimeframeToString(Period())+": Thrust Bullish Bar at "+TimeToString(TimeCurrent());
            if(InpUseAlerts) Alert(message);
            if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Thrust Bar Signal",message);
            if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);
            last_time=time[0];
           }
        }
      if(y<-x && InpUseShort)
        {
         BufferDN[i]=high[i];
         BufferCandleOpen[i]=open[i];
         BufferCandleHigh[i]=high[i];
         BufferCandleLow[i]=low[i];
         BufferCandleClose[i]=close[i];
         BufferColors[i]=1;
         if(i==0 && last_time!=time[0])
           {
            string message=Symbol()+", "+TimeframeToString(Period())+": Thrust Bearish Bar at "+TimeToString(TimeCurrent());
            if(InpUseAlerts) Alert(message);
            if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Thrust Bar Signal",message);
            if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);
            last_time=time[0];
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timeframe to string                                              |
//+------------------------------------------------------------------+
string TimeframeToString(const ENUM_TIMEFRAMES timeframe)
  {
   return StringSubstr(EnumToString(timeframe),7);
  }
//+------------------------------------------------------------------+
