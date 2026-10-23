//+------------------------------------------------------------------+
//|                                              InsideBarAlerts.mq5 |
//|                                                 ezequielhenrique |
//|                         https://www.mql5.com/en/users/ezhenrique |
//+------------------------------------------------------------------+
#property copyright "2026, @ezhenrique"
#property link      "https://www.mql5.com/en/users/ezhenrique"
#property version   "1.00"
#property description "Detects Inside Bar candlestick patterns and provides real time alerts when they occur."
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1

#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_label1  "InsideBar"
#property indicator_color1  clrNONE, clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//+------------------------------------------------------------------+
//|                         Input Parameters                         |
//+------------------------------------------------------------------+
input color InsideBarColor           = clrLimeGreen;  // Inside Bar color
input bool  FireAlerts               = true;          // Enable alerts
input bool  EnablePushNotification   = true;          // Enable push notification
input bool  EnablePopupAlert         = true;          // Enable popup alert

//+------------------------------------------------------------------+
//|                              Enums                               |
//+------------------------------------------------------------------+
enum CANDLE_MOVEMENT
  {
   UP = 1,
   DOWN = 0
  };

//+------------------------------------------------------------------+
//|                             Structures                           |
//+------------------------------------------------------------------+
struct CANDLE_STRUCTURE
  {
   double            open;
   double            high;
   double            low;
   double            close;
   long              volume;
   datetime          time;
   CANDLE_MOVEMENT   move;
  };

//+------------------------------------------------------------------+
//|                       Global Variables                           |
//+------------------------------------------------------------------+
double OpenBuffer[];
double HighBuffer[];
double LowBuffer[];
double CloseBuffer[];
double ColorBuffer[];

datetime lastAlertTime = 0;

//+------------------------------------------------------------------+
//|                        Inside Bar Function                       |
//+------------------------------------------------------------------+
bool isInsideBar(CANDLE_STRUCTURE &prevCandle, CANDLE_STRUCTURE &currentCandle)
  {
   bool insideBarCondition = (prevCandle.low < currentCandle.low) && (prevCandle.high > currentCandle.high);

   return insideBarCondition;
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit()
  {
   SetIndexBuffer(0,OpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,CloseBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ColorBuffer,INDICATOR_COLOR_INDEX);

   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, InsideBarColor);

   IndicatorSetString(INDICATOR_SHORTNAME,"Inside Bar Detector");


   if(!TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))
     {
      Print("Alert. The client terminal does not have permission to send notifications");
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[])
  {
   if(rates_total < 2)
      return 0;
   
   int start = (prev_calculated > 1) ? prev_calculated - 1 : 1;
   
   CANDLE_STRUCTURE candles[];
   ArrayResize(candles, rates_total);

   for(int i=start; i < rates_total; i++)
     {
      candles[i].open   = open[i];
      candles[i].high   = high[i];
      candles[i].low    = low[i];
      candles[i].close  = close[i];
      candles[i].volume = tick_volume[i];
      candles[i].time   = time[i];
      candles[i].move   = (close[i] > open[i] ? UP : DOWN);

      OpenBuffer[i]  = open[i];
      HighBuffer[i]  = high[i];
      LowBuffer[i]   = low[i];
      CloseBuffer[i] = close[i];

      ColorBuffer[i] = 0;
      
      bool pattern = isInsideBar(candles[i - 1], candles[i]);

      if(pattern)
        {

         ColorBuffer[i] = 1;


         if(FireAlerts && i == rates_total - 2 && candles[i].time != lastAlertTime)
           {
            string message=_Symbol+" "+ EnumToString(_Period) + " Inside Bar detected";

            if(EnablePopupAlert)
               Alert(message);

            if(EnablePushNotification)
               SendNotification(message);
            
            lastAlertTime = candles[i].time;
           }

        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
