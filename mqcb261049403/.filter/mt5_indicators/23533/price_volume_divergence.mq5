//+------------------------------------------------------------------+
//|                                      Price_Volume_Divergence.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Price volume divergence indicator"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot DivUP
#property indicator_label1  "Growing Div"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DivDN
#property indicator_label2  "Falling Div"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0, // No
  };
//--- input parameters
input ENUM_INPUT_YES_NO    InpUseAlerts      =  INPUT_YES;     // Use alerts
input ENUM_INPUT_YES_NO    InpSendMail       =  INPUT_NO;      // Send mail
input ENUM_INPUT_YES_NO    InpSendPush       =  INPUT_YES;     // Send push-notifications
input ENUM_APPLIED_VOLUME  InpAppliedVolume  =  VOLUME_TICK;   // Applied volume
input ENUM_INPUT_YES_NO    InpShowVolume     =  INPUT_YES;     // Show volumes bars
//--- indicator buffers
double         BufferDivUP[];
double         BufferDivDN[];
double         BufferVolume[];
//--- global variables
ENUM_CHART_VOLUME_MODE  prev_volume;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   prev_volume=(ENUM_CHART_VOLUME_MODE)ChartGetInteger(0,CHART_SHOW_VOLUMES);
   if(InpShowVolume)
     {
      ChartSetInteger(0,CHART_SHOW_VOLUMES,(InpAppliedVolume==VOLUME_TICK ? CHART_VOLUME_TICK : CHART_VOLUME_REAL));
      ChartRedraw(0);
     }
   else
     {
      ChartSetInteger(0,CHART_SHOW_VOLUMES,CHART_VOLUME_HIDE);
      ChartRedraw(0);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDivUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDivDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferVolume,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,225);
   PlotIndexSetInteger(1,PLOT_ARROW,226);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Price volume divergence");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDivUP,true);
   ArraySetAsSeries(BufferDivDN,true);
   ArraySetAsSeries(BufferVolume,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ChartSetInteger(0,CHART_SHOW_VOLUMES,prev_volume);
   ChartRedraw(0);
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(tick_volume,true);
   ArraySetAsSeries(volume,true);
//--- Проверка количества доступных баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferDivUP,EMPTY_VALUE);
      ArrayInitialize(BufferDivDN,EMPTY_VALUE);
      ArrayInitialize(BufferVolume,0);
     }
//--- Подготовка данных
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferVolume[i]=double(InpAppliedVolume==VOLUME_TICK ? tick_volume[i] : volume[i]);

//--- Расчёт индикатора
   static datetime last_time=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Range0=high[i]-low[i];
      double Range1=high[i+1]-low[i+1];

      if(Range1>Range0 && BufferVolume[i+1]<BufferVolume[i])
        {
         BufferDivDN[i]=low[i];
         if(i==0)
           {
            if(last_time!=time[0])
              {
               string message=Symbol()+", "+TimeframeToString(Period())+": Falling Price/Volume divergence at "+TimeToString(TimeCurrent());
               if(InpUseAlerts) Alert(message);
               if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Price volume divergence Signal",message);
               if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);
               last_time=time[0];
              }
           }
        }
      else
         BufferDivDN[i]=EMPTY_VALUE;

      if(Range1<Range0 && BufferVolume[i+1]>BufferVolume[i])
        {
         BufferDivUP[i]=high[i];
         if(i==0)
           {
            if(last_time!=time[0])
              {
               string message=Symbol()+", "+TimeframeToString(Period())+": Growing Price/Volume divergence at "+TimeToString(TimeCurrent());
               if(InpUseAlerts) Alert(message);
               if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Price volume divergence Signal",message);
               if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);
               last_time=time[0];
              }
           }
        }
      else
         BufferDivUP[i]=EMPTY_VALUE;
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
