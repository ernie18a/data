//+------------------------------------------------------------------+
//|                                              MovingPriceLine.mq5 |
//|            Copyright 2003-2025, Opengates Success International. |
//|               https://www.mql5.com/en/users/opengates2012/seller |
//+------------------------------------------------------------------+
#property copyright   "2003-2025, Opengates Success International Org."
#property link        "https://www.mql5.com/en/users/opengates2012/seller"
#property version   "1.1"
#property description "MovingPriceLine - To show current server time on the last candle"
#property indicator_chart_window
#property indicator_plots   0
#property strict
//+------------------------------------------------------------------+
input color     LineColor  = clrDarkSlateGray;//Color for the line
input color     TextColor  = clrLightSteelBlue;//Color for the time text
input int       LineWidth  = 1;//The width of the line
input ENUM_LINE_STYLE LineStyle = STYLE_SOLID;//The style of the line
input int    BufferPips    = 3;  // Distance above candle high in pips

string    LineName   = "MovingPriceLine_Timer";
string    TextName   = "MovingPriceLine_Name";
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Create the vertical line object
   if(!ObjectCreate(0, LineName, OBJ_VLINE, 0, TimeCurrent(), 0))
     {
      Print("Failed to create vertical line. Error: ", GetLastError());
      return(INIT_FAILED);
     }
   ObjectSetInteger(0, LineName, OBJPROP_COLOR, LineColor);
   ObjectSetInteger(0, LineName, OBJPROP_WIDTH, LineWidth);
   ObjectSetInteger(0, LineName, OBJPROP_STYLE, LineStyle);
   ObjectSetInteger(0, LineName, OBJPROP_BACK, true);
   ObjectSetInteger(0, LineName, OBJPROP_SELECTABLE, false);

   ObjectCreate(0, TextName, OBJ_TEXT, 0, TimeCurrent(), 0);
   ObjectSetInteger(0, TextName, OBJPROP_COLOR, TextColor);
   ObjectSetInteger(0, TextName, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, TextName, OBJPROP_SELECTABLE, false);

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0, LineName);
   ObjectDelete(0, TextName);
  }

//+------------------------------------------------------------------+
//| Update logic                                                     |
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
   datetime now = TimeCurrent();
// Time calculations
   datetime currentTime = TimeCurrent();
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   int secondsLeft = (int)(PeriodSeconds(_Period) - (currentTime - currentBarTime));

// Determine display components
   bool showDays = (_Period == PERIOD_W1) || (_Period == PERIOD_MN1);
   bool showHours = (_Period >= PERIOD_H4) || (_Period == PERIOD_D1);

// Current candle index (rightmost)
   int currentCandleIndex = rates_total - 1;
   datetime candleTime = time[currentCandleIndex];
   double candleHigh = high[currentCandleIndex];

// Calculate time components
   int days = 0, hours = 0, minutes = 0, seconds = 0;
   int remaining = secondsLeft;

   if(showDays) {
      days = remaining / 86400;
      remaining %= 86400;
   }
   if(showHours) {     hours = remaining / 3600;
      remaining %= 3600;
   }
   minutes = remaining / 60;
   seconds = remaining % 60;

// Calculate buffer in price terms
   double pipSize = _Point * 10 * (Digits() == 3 || Digits() == 5 ? 10 : 1);
   double bufferPrice = BufferPips * pipSize;
   double textY = candleHigh + bufferPrice;

// Move the vertical line to current time
   string add;
   ObjectMove(0, LineName, 0, now, 0);
   if(now < 12.00)
      add = "AM";
   else
      add = "PM";

// Move the text above the candle
   string label = TimeToString(now, TIME_SECONDS)+" "+add+" - "+GetDayOfWeek();
   ObjectMove(0, TextName, 0, now, textY);
   ObjectSetString(0, TextName, OBJPROP_TEXT, label);

   return rates_total;
  }
//+------------------------------------------------------------------+
int TimeDayOfWeek(const datetime time)
  {
   MqlDateTime tm;
   if(!TimeToStruct(time,tm)) return WRONG_VALUE;
   return tm.day_of_week;
  }
//+------------------------------------------------------------------+
string GetDayOfWeek(datetime time = 0)

{
   // Use current time if no time is passed
   if(time == 0)
      time = TimeCurrent();
 
   int dayNumber = TimeDayOfWeek(time);  // 0 = Sunday, 1 = Monday, ..., 6 = Saturday

   string days[] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
   return days[dayNumber];
}
//+------------------------------------------------------------------+