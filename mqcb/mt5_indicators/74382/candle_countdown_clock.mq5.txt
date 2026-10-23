//+------------------------------------------------------------------+
//|                                              Countdown clock.mq5 |
//|        Copyright 2003-2026, Opengates Success International Org. |
//|                            https://www.ffxmvdashboards.com/store |
//+------------------------------------------------------------------+
#property copyright   "2003-2026, Opengates Success International Org."
#property link        "https://www.ffxmvdashboards.com/store"
#property description "Countdown clock"
#property indicator_chart_window
#property indicator_plots   0
//+------------------------------------------------------------------+
input color       textColor = clrLime;//Font color
input int         fontSize  = 14;//Font size
input int         x_offset  = 160;//Left-Right shift
input int         y_offset  = 50;//Up-Down shift

string labelName = "CandleCountdownClock";

// ENUM_CORNER manual definition
enum MyCorner
  {
   TopLeft     = 0,//Top lftt corner
   BottomLeft  = 1,//Bottom left corner
   BottomRight = 2,//Bottom right corner
   TopRight    = 3//Top right corner
  };
input MyCorner corner = TopRight;//Candle clock placement

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   CreateLabel();
   EventSetTimer(1); // refresh every second
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Dummy calculation function required for custom indicators        |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Clean up on deinit                                               |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(0, labelName);
   EventKillTimer();
}

//+------------------------------------------------------------------+
//| Timer Event - Updates countdown every second                     |
//+------------------------------------------------------------------+
void OnTimer()
{
   datetime candleClose = iTime(_Symbol, _Period, 0) + PeriodSeconds(_Period);
   int timeLeft = (int)(candleClose - TimeCurrent());

   if (timeLeft < 0)
      timeLeft = 0;

   int hours   = timeLeft / 3600;
   int minutes = (timeLeft % 3600) / 60;
   int seconds = timeLeft % 60;

   string countdownText = StringFormat("%02dh %02dm %02ds", hours, minutes, seconds);
   ObjectSetString(0, labelName, OBJPROP_TEXT, countdownText);
}

//+------------------------------------------------------------------+
//| Creates the countdown label on the chart                         |
//+------------------------------------------------------------------+
void CreateLabel()
{
   if (!ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0))
      return;

   ObjectSetInteger(0, labelName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, x_offset);
   ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, y_offset);
   ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, labelName, OBJPROP_COLOR, textColor);
   ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, labelName, OBJPROP_HIDDEN, true);
   ObjectSetString(0, labelName, OBJPROP_FONT, "Arial");
}
//+------------------------------------------------------------------+