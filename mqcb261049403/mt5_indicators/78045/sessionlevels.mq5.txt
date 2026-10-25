//+------------------------------------------------------------------+
//|                                                SessionLevels.mq5 |
//|                                  Copyright 2026, Marco Casadidio |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//| Draws the levels intraday traders watch most:                    |
//|  - Asian session range (box + extension lines)                   |
//|  - optional London / New York session boxes                      |
//|  - previous day high/low and previous week high/low              |
//|  - daily VWAP (resets every day, tick-volume weighted)           |
//|  - confirmed swing highs/lows (fractals of configurable length)  |
//|  - round numbers around the current price                        |
//| Hover any object to read what the level is and why it matters.   |
//| Optional alerts (popup / push) when price breaks the Asian range |
//| or the previous day high/low.                                    |
//| All session hours are in BROKER SERVER TIME.                     |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Marco Casadidio"
#property link        "https://www.mql5.com"
#property version     "1.04"
#property description "Session Levels: Asian range, London/NY sessions, previous day & week high/low,"
#property description "daily VWAP, swing points and round numbers. Hover any object for an explanation."
#property description "Optional alerts on range breaks. Session hours are in broker server time."

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3

#property indicator_label1  "Daily VWAP"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGoldenrod
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Swing High"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrTomato
#property indicator_width2  1

#property indicator_label3  "Swing Low"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDeepSkyBlue
#property indicator_width3  1

//--- input parameters
input group "=== Sessions (broker server time) ==="
input int    InpDays          = 5;              // Days to draw
input bool   InpShowAsia      = true;           // Show Asian range
input int    InpAsiaStart     = 1;              // Asian range: start hour
input int    InpAsiaEnd       = 9;              // Asian range: end hour
input int    InpExtendTo      = 22;             // Extend Asian high/low until hour
input color  InpAsiaColor     = clrNONE;        // Asian box color (None = automatic)
input bool   InpShowLondon    = false;          // Show London session box
input int    InpLonStart      = 10;             // London: start hour
input int    InpLonEnd        = 13;             // London: end hour
input color  InpLonColor      = clrNONE;        // London box color (None = automatic)
input bool   InpShowNY        = false;          // Show New York session box
input int    InpNYStart       = 15;             // New York: start hour
input int    InpNYEnd         = 18;             // New York: end hour
input color  InpNYColor       = clrNONE;        // New York box color (None = automatic)

input group "=== Key levels ==="
input bool   InpShowPrevDay   = true;           // Show previous day high/low
input color  InpPDColor       = clrNONE;        // Previous day color (None = automatic)
input bool   InpShowPrevWeek  = true;           // Show previous week high/low
input color  InpPWColor       = clrNONE;        // Previous week color (None = automatic)
input bool   InpShowRound     = true;           // Show round numbers
input double InpRoundStep     = 0.0;            // Round number step (0 = automatic)
input int    InpRoundCount    = 3;              // Round numbers above/below price
input color  InpRoundColor    = clrNONE;        // Round numbers color (None = automatic)

input group "=== VWAP & swings ==="
input bool   InpShowVWAP      = true;           // Show daily VWAP
input bool   InpShowSwings    = true;           // Show swing highs/lows
input int    InpSwingLen      = 3;              // Swing strength (bars on each side)

input group "=== Alerts ==="
input bool   InpAlertAsia     = false;          // Alert on Asian range break
input bool   InpAlertPrevDay  = false;          // Alert on previous day high/low break
input bool   InpAlertPopup    = true;           // Popup alert
input bool   InpAlertPush     = false;          // Push notification to phone

input group "=== Info panel ==="
input bool   InpShowPanel     = true;           // Show info panel (top right)

//--- indicator buffers
double ExtVWAPBuffer[];       // daily VWAP
double ExtSwingHighBuffer[];  // confirmed swing highs
double ExtSwingLowBuffer[];   // confirmed swing lows
double ExtSumPVBuffer[];      // cumulative price*volume (calculation)
double ExtSumVolBuffer[];     // cumulative volume (calculation)

//--- global variables
#define PREFIX "SLV_"
datetime ExtLastBar      = 0;
double   ExtAsiaHigh     = 0;
double   ExtAsiaLow      = 0;
bool     ExtAsiaDone     = false;
double   ExtPrevDayHigh  = 0;
double   ExtPrevDayLow   = 0;
double   ExtPrevWeekHigh = 0;
double   ExtPrevWeekLow  = 0;
bool     ExtLightTheme   = false;   // chart background is light
bool     ExtNeedRedraw   = false;   // some history was missing: retry from the timer
double   ExtLastPrice    = 0;
double   ExtLastVWAP     = 0;

//+------------------------------------------------------------------+
//| Detect whether the chart background is light or dark             |
//+------------------------------------------------------------------+
void DetectTheme()
  {
   uint bg = (uint)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   int  r  = (int)(bg & 0xFF);
   int  g  = (int)((bg >> 8) & 0xFF);
   int  b  = (int)((bg >> 16) & 0xFF);
   ExtLightTheme = (0.299 * r + 0.587 * g + 0.114 * b) > 128;
  }

//+------------------------------------------------------------------+
//| User color, or the automatic color for the current theme         |
//+------------------------------------------------------------------+
color AutoColor(color user_color, color dark_color, color light_color)
  {
   if(user_color != clrNONE)
      return user_color;
   return ExtLightTheme ? light_color : dark_color;
  }

//+------------------------------------------------------------------+
//| Day number of a time (days since 1970)                           |
//+------------------------------------------------------------------+
int DayIndex(datetime t)
  {
   return (int)(t / 86400);
  }

//+------------------------------------------------------------------+
//| Price formatted with the symbol digits                           |
//+------------------------------------------------------------------+
string FormatPrice(double value)
  {
   return DoubleToString(value, _Digits);
  }

//+------------------------------------------------------------------+
//| Highest high between two times (0 if no data)                    |
//+------------------------------------------------------------------+
double RangeHigh(datetime from, datetime to)
  {
   if(to < from)
      return 0;
   double values[];
   int    copied = CopyHigh(_Symbol, _Period, from, to, values);
   if(copied <= 0)
      return 0;
   return values[ArrayMaximum(values)];
  }

//+------------------------------------------------------------------+
//| Lowest low between two times (DBL_MAX if no data)                |
//+------------------------------------------------------------------+
double RangeLow(datetime from, datetime to)
  {
   if(to < from)
      return DBL_MAX;
   double values[];
   int    copied = CopyLow(_Symbol, _Period, from, to, values);
   if(copied <= 0)
      return DBL_MAX;
   return values[ArrayMinimum(values)];
  }

//+------------------------------------------------------------------+
//| Step between round numbers (input value or automatic)            |
//+------------------------------------------------------------------+
double RoundStep()
  {
   if(InpRoundStep > 0)
      return InpRoundStep;
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(price <= 0)
      return 0;
//--- gold ~5, EURUSD 0.005, BTC 500
   return 5.0 * MathPow(10.0, MathFloor(MathLog10(price)) - 3.0);
  }

//+------------------------------------------------------------------+
//| Horizontal segment between two times, with a tooltip             |
//+------------------------------------------------------------------+
void DrawSegment(string obj_name, datetime t1, datetime t2, double price, color clr,
                 ENUM_LINE_STYLE line_style, int width, string tip)
  {
   if(price <= 0 || price >= DBL_MAX)
      return;
   ObjectCreate(0, obj_name, OBJ_TREND, 0, t1, price, t2, price);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, obj_name, OBJPROP_STYLE, line_style);
   ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, obj_name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
   ObjectSetString(0, obj_name, OBJPROP_TOOLTIP, tip);
  }

//+------------------------------------------------------------------+
//| Filled box between two times and two prices, with a tooltip      |
//+------------------------------------------------------------------+
void DrawBox(string obj_name, datetime t1, double price1, datetime t2, double price2,
             color clr, string tip)
  {
   ObjectCreate(0, obj_name, OBJ_RECTANGLE, 0, t1, price1, t2, price2);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, obj_name, OBJPROP_FILL, true);
   ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
   ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, true);
   ObjectSetString(0, obj_name, OBJPROP_TOOLTIP, tip);
  }

//+------------------------------------------------------------------+
//| Small text label on the chart (e.g. PDH, PDL)                    |
//+------------------------------------------------------------------+
void DrawText(string obj_name, datetime t, double price, string text, color clr)
  {
   if(price <= 0 || price >= DBL_MAX)
      return;
   ObjectCreate(0, obj_name, OBJ_TEXT, 0, t, price);
   ObjectSetString(0, obj_name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, 7);
   ObjectSetInteger(0, obj_name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| One line of the info panel (top right corner)                    |
//+------------------------------------------------------------------+
void SetPanelLabel(string obj_name, int y, string text, color clr, int font_size = 8)
  {
   if(ObjectFind(0, obj_name) < 0)
     {
      ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, obj_name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, true);
      ObjectSetString(0, obj_name, OBJPROP_FONT, "Consolas");
     }
   ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
   ObjectSetString(0, obj_name, OBJPROP_TEXT, (text == "" ? " " : text));
  }

//+------------------------------------------------------------------+
//| Session box with optional extension of its high/low              |
//+------------------------------------------------------------------+
bool SessionBox(string obj_name, datetime day_start, int hour_from, int hour_to,
                color clr, string session_name, bool extend, int extend_hour,
                double &sess_high, double &sess_low, bool &done)
  {
   sess_high = 0;
   sess_low  = 0;
   done      = false;
   if(hour_to <= hour_from)
      return false;
   datetime now  = TimeCurrent();
   datetime from = day_start + hour_from * 3600;
   datetime to   = day_start + hour_to * 3600 - 1;
   if(from > now)
      return false;
   double high_price = RangeHigh(from, to);
   double low_price  = RangeLow(from, to);
   if(high_price <= 0 || low_price >= DBL_MAX)
      return false;
   sess_high = high_price;
   sess_low  = low_price;
   done      = (now > to);
   datetime box_end = done ? to : now;
   string   tip     = StringFormat("%s session %02d:00-%02d:00 (server time)\nHigh %s  Low %s  Range %s",
                                   session_name, hour_from, hour_to, FormatPrice(high_price),
                                   FormatPrice(low_price), FormatPrice(high_price - low_price));
   DrawBox(obj_name, from, high_price, box_end, low_price, clr, tip);
   if(extend && done && extend_hour > hour_to)
     {
      datetime ext_end = day_start + extend_hour * 3600;
      DrawSegment(obj_name + "_H", to, ext_end, high_price, clrMediumPurple, STYLE_DOT, 1,
                  session_name + " high " + FormatPrice(high_price) +
                  "\nStops of short sellers rest above it: a break or a sweep (break and fast return) is often decisive.");
      DrawSegment(obj_name + "_L", to, ext_end, low_price, clrMediumPurple, STYLE_DOT, 1,
                  session_name + " low " + FormatPrice(low_price) +
                  "\nStops of buyers rest below it: a break or a sweep (break and fast return) is often decisive.");
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Start (00:00) of the day that contains a time                    |
//+------------------------------------------------------------------+
datetime DayStart(datetime t)
  {
   return (datetime)(((long)t / 86400) * 86400);
  }

//+------------------------------------------------------------------+
//| Trading days present on the chart, most recent first.            |
//| Built from the chart's own bars (no dependency on D1/W1 data),   |
//| so it works immediately and also during the weekend.             |
//+------------------------------------------------------------------+
int TradingDays(datetime &trade_days[], int need)
  {
   ArrayResize(trade_days, 0);
   int period_sec = PeriodSeconds(_Period);
   if(period_sec <= 0)
      period_sec = 60;
   long want = (long)(need + 10) * 86400 / period_sec + 10;
   int  bars = (int)MathMin((long)Bars(_Symbol, _Period), want);
   if(bars <= 0)
      return 0;
   datetime times[];
   ArraySetAsSeries(times, true);
   int copied = CopyTime(_Symbol, _Period, 0, bars, times);
   for(int i = 0; i < copied; i++)
     {
      datetime day_start = DayStart(times[i]);
      int      count     = ArraySize(trade_days);
      if(count == 0 || trade_days[count - 1] != day_start)
        {
         ArrayResize(trade_days, count + 1);
         trade_days[count] = day_start;
         if(count + 1 >= need)
            break;
        }
     }
   return ArraySize(trade_days);
  }

//+------------------------------------------------------------------+
//| Draw all levels (called on every new bar)                        |
//+------------------------------------------------------------------+
void DrawLevels()
  {
   ObjectsDeleteAll(0, PREFIX + "D_");
   ObjectsDeleteAll(0, PREFIX + "R_");
   ObjectsDeleteAll(0, PREFIX + "W_");
   DetectTheme();
   color clr_asia  = AutoColor(InpAsiaColor,  C'30,35,62',  C'226,229,246');
   color clr_lon   = AutoColor(InpLonColor,   C'24,48,38',  C'223,241,229');
   color clr_ny    = AutoColor(InpNYColor,    C'56,34,34',  C'246,227,227');
   color clr_pd    = AutoColor(InpPDColor,    clrSilver,    clrDimGray);
   color clr_pw    = AutoColor(InpPWColor,    clrOrange,    clrDarkOrange);
   color clr_round = AutoColor(InpRoundColor, C'95,95,105', C'175,175,185');
   int   days      = MathMax(1, InpDays);
//--- one extra day for the "previous day" of the oldest one
   datetime trade_days[];
   int  days_found = TradingDays(trade_days, days + 1);
   bool missing    = (days_found < 2);
//--- sessions and previous day levels, day by day
   for(int d = 0; d < days && d < days_found; d++)
     {
      datetime day_start = trade_days[d];
      datetime day_end   = (d == 0) ? day_start + 86400 : trade_days[d - 1];
      string   id        = IntegerToString(d);
      double   sess_high = 0;
      double   sess_low  = 0;
      bool     done      = false;

      if(InpShowAsia)
        {
         bool ok = SessionBox(PREFIX + "D_ASIA" + id, day_start, InpAsiaStart, InpAsiaEnd, clr_asia, "Asian",
                              true, InpExtendTo, sess_high, sess_low, done);
         if(d == 0)
           {
            ExtAsiaHigh = ok ? sess_high : 0;
            ExtAsiaLow  = ok ? sess_low  : 0;
            ExtAsiaDone = ok ? done      : false;
           }
        }
      if(InpShowLondon)
         SessionBox(PREFIX + "D_LON" + id, day_start, InpLonStart, InpLonEnd, clr_lon, "London",
                    false, 0, sess_high, sess_low, done);
      if(InpShowNY)
         SessionBox(PREFIX + "D_NY" + id, day_start, InpNYStart, InpNYEnd, clr_ny, "New York",
                    false, 0, sess_high, sess_low, done);

      if(InpShowPrevDay && d + 1 < days_found)
        {
         datetime prev_start = trade_days[d + 1];
         double   prev_high  = RangeHigh(prev_start, day_start - 1);
         double   prev_low   = RangeLow(prev_start, day_start - 1);
         if(prev_high <= 0 || prev_low >= DBL_MAX)
           {
            missing = true;
            continue;
           }
         if(d == 0)
           {
            ExtPrevDayHigh = prev_high;
            ExtPrevDayLow  = prev_low;
           }
         DrawSegment(PREFIX + "D_PDH" + id, day_start, day_end, prev_high, clr_pd, STYLE_DASH, 1,
                     "Previous day high " + FormatPrice(prev_high) +
                     "\nKey reference: buy stops (liquidity) often rest above it.");
         DrawSegment(PREFIX + "D_PDL" + id, day_start, day_end, prev_low, clr_pd, STYLE_DASH, 1,
                     "Previous day low " + FormatPrice(prev_low) +
                     "\nKey reference: sell stops (liquidity) often rest below it.");
         if(d == 0)
           {
            DrawText(PREFIX + "D_PDHt", day_start, prev_high, "PDH", clr_pd);
            DrawText(PREFIX + "D_PDLt", day_start, prev_low, "PDL", clr_pd);
           }
        }
     }
//--- previous week high/low
   if(InpShowPrevWeek && days_found > 0)
     {
      MqlDateTime dt;
      TimeToStruct(trade_days[0], dt);
      int      days_since_monday = (dt.day_of_week + 6) % 7;
      datetime week_start        = trade_days[0] - days_since_monday * 86400;   // this week's Monday 00:00
      double   week_high         = RangeHigh(week_start - 7 * 86400, week_start - 1);
      double   week_low          = RangeLow(week_start - 7 * 86400, week_start - 1);
      if(week_high <= 0 || week_low >= DBL_MAX)
         missing = true;
      else
        {
         ExtPrevWeekHigh = week_high;
         ExtPrevWeekLow  = week_low;
         DrawSegment(PREFIX + "W_PWH", week_start, week_start + 7 * 86400, ExtPrevWeekHigh, clr_pw, STYLE_DASHDOT, 1,
                     "Previous week high " + FormatPrice(ExtPrevWeekHigh) +
                     "\nHigher-timeframe level: strong reactions are common here.");
         DrawSegment(PREFIX + "W_PWL", week_start, week_start + 7 * 86400, ExtPrevWeekLow, clr_pw, STYLE_DASHDOT, 1,
                     "Previous week low " + FormatPrice(ExtPrevWeekLow) +
                     "\nHigher-timeframe level: strong reactions are common here.");
         DrawText(PREFIX + "W_PWHt", week_start, ExtPrevWeekHigh, "PWH", clr_pw);
         DrawText(PREFIX + "W_PWLt", week_start, ExtPrevWeekLow, "PWL", clr_pw);
        }
     }
//--- history not loaded yet: the timer will try again
   ExtNeedRedraw = missing;
//--- round numbers around the current price
   if(InpShowRound)
     {
      double step  = RoundStep();
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(step > 0 && price > 0)
        {
         double base = MathFloor(price / step) * step;
         for(int k = -InpRoundCount + 1; k <= InpRoundCount; k++)
           {
            double level    = base + k * step;
            string obj_name = PREFIX + "R_" + IntegerToString(k + 100);
            ObjectCreate(0, obj_name, OBJ_HLINE, 0, 0, level);
            ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr_round);
            ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_DOT);
            ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
            ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, true);
            ObjectSetString(0, obj_name, OBJPROP_TOOLTIP, "Round number " + FormatPrice(level) +
                            "\nMany orders and take profits cluster on round prices.");
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Info panel                                                       |
//+------------------------------------------------------------------+
void UpdatePanel(double price, double vwap)
  {
   if(!InpShowPanel)
      return;
   DetectTheme();
   color clr_text  = ExtLightTheme ? C'40,45,55'       : C'200,205,215';
   color clr_dim   = ExtLightTheme ? C'100,105,120'    : C'140,145,160';
   color clr_title = ExtLightTheme ? clrDarkGoldenrod  : clrGoldenrod;
   int   y         = 20;
   int   step      = 14;
//--- panel background
   string bg_name = PREFIX + "PBG";
   if(ObjectFind(0, bg_name) < 0)
     {
      ObjectCreate(0, bg_name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, bg_name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, bg_name, OBJPROP_XDISTANCE, 316);   // right corner: distance to the left edge
      ObjectSetInteger(0, bg_name, OBJPROP_YDISTANCE, 14);
      ObjectSetInteger(0, bg_name, OBJPROP_XSIZE, 310);
      ObjectSetInteger(0, bg_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, bg_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, bg_name, OBJPROP_HIDDEN, true);
     }
   ObjectSetInteger(0, bg_name, OBJPROP_BGCOLOR, ExtLightTheme ? C'246,247,251' : C'18,20,28');
   ObjectSetInteger(0, bg_name, OBJPROP_COLOR,   ExtLightTheme ? C'190,195,210' : C'55,60,80');
   int lines = 3 + (InpShowPrevDay ? 1 : 0) + (InpShowPrevWeek ? 1 : 0) + (InpShowVWAP ? 1 : 0);
   ObjectSetInteger(0, bg_name, OBJPROP_YSIZE, lines * step + 12);
//--- title
   SetPanelLabel(PREFIX + "P0", y, "SESSION LEVELS  " + _Symbol, clr_title, 9);
   y += step + 2;
//--- Asian range
   string asia_text = "n/a";
   if(ExtAsiaHigh > 0)
     {
      asia_text = FormatPrice(ExtAsiaLow) + " - " + FormatPrice(ExtAsiaHigh) +
                  "  (" + FormatPrice(ExtAsiaHigh - ExtAsiaLow) + ")";
      if(!ExtAsiaDone)
         asia_text += " forming";
     }
   SetPanelLabel(PREFIX + "P1", y, "Asia  " + asia_text, clr_text);
   y += step;
//--- previous day and previous week
   if(InpShowPrevDay)
     {
      SetPanelLabel(PREFIX + "P2", y, "PDH " + FormatPrice(ExtPrevDayHigh) + "   PDL " + FormatPrice(ExtPrevDayLow), clr_text);
      y += step;
     }
   if(InpShowPrevWeek)
     {
      SetPanelLabel(PREFIX + "P3", y, "PWH " + FormatPrice(ExtPrevWeekHigh) + "   PWL " + FormatPrice(ExtPrevWeekLow), clr_text);
      y += step;
     }
//--- VWAP
   if(InpShowVWAP && vwap > 0 && vwap != EMPTY_VALUE)
     {
      bool  above    = (price > vwap);
      color clr_vwap = above ? (ExtLightTheme ? clrRoyalBlue : clrDeepSkyBlue) :
                       (ExtLightTheme ? clrFireBrick : clrTomato);
      SetPanelLabel(PREFIX + "P4", y, "VWAP " + FormatPrice(vwap) + (above ? "  price above" : "  price below"), clr_vwap);
      y += step;
     }
//--- price position against the Asian range
   string position = "inside Asian range";
   if(ExtAsiaHigh > 0 && price > ExtAsiaHigh)
      position = "above Asian range";
   if(ExtAsiaHigh > 0 && price < ExtAsiaLow)
      position = "below Asian range";
   SetPanelLabel(PREFIX + "P5", y, "Price " + FormatPrice(price) + "  " + position, clr_dim);
  }

//+------------------------------------------------------------------+
//| Send an alert (journal, popup, push)                             |
//+------------------------------------------------------------------+
void Notify(string message, double price)
  {
   string text = _Symbol + " " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period), 7) + ": " +
                 message + " @ " + FormatPrice(price);
   Print(text);
   if(InpAlertPopup)
      Alert(text);
   if(InpAlertPush)
      SendNotification(text);
  }

//+------------------------------------------------------------------+
//| Check breaks of the Asian range and of the previous day levels   |
//+------------------------------------------------------------------+
void CheckAlerts(double price)
  {
   if(!InpAlertAsia && !InpAlertPrevDay)
      return;
   static int  last_day  = -1;
   static bool armed     = false;
   static bool asia_up   = false;
   static bool asia_down = false;
   static bool pd_up     = false;
   static bool pd_down   = false;
   int today = DayIndex(TimeCurrent());
   if(today != last_day)
     {
      last_day = today;
      armed    = false;
     }
   bool now_asia_up   = (ExtAsiaDone && ExtAsiaHigh > 0 && price > ExtAsiaHigh);
   bool now_asia_down = (ExtAsiaDone && ExtAsiaLow > 0 && price < ExtAsiaLow);
   bool now_pd_up     = (ExtPrevDayHigh > 0 && price > ExtPrevDayHigh);
   bool now_pd_down   = (ExtPrevDayLow > 0 && price < ExtPrevDayLow);
//--- first check of the day or after attach: no alert for levels already broken
   if(!armed)
     {
      asia_up   = now_asia_up;
      asia_down = now_asia_down;
      pd_up     = now_pd_up;
      pd_down   = now_pd_down;
      armed     = true;
      return;
     }
   if(InpAlertAsia)
     {
      if(now_asia_up && !asia_up)
        {
         asia_up = true;
         Notify("price broke ABOVE the Asian high " + FormatPrice(ExtAsiaHigh), price);
        }
      if(now_asia_down && !asia_down)
        {
         asia_down = true;
         Notify("price broke BELOW the Asian low " + FormatPrice(ExtAsiaLow), price);
        }
     }
   if(InpAlertPrevDay)
     {
      if(now_pd_up && !pd_up)
        {
         pd_up = true;
         Notify("price broke ABOVE the previous day high " + FormatPrice(ExtPrevDayHigh), price);
        }
      if(now_pd_down && !pd_down)
        {
         pd_down = true;
         Notify("price broke BELOW the previous day low " + FormatPrice(ExtPrevDayLow), price);
        }
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check inputs
   if(InpAsiaEnd <= InpAsiaStart || InpAsiaStart < 0 || InpAsiaEnd > 24)
     {
      Print("Asian range hours are not valid (start must be lower than end, 0-24)");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(InpSwingLen < 1)
     {
      Print("Swing strength must be at least 1");
      return INIT_PARAMETERS_INCORRECT;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0, ExtVWAPBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtSwingHighBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ExtSwingLowBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, ExtSumPVBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, ExtSumVolBuffer, INDICATOR_CALCULATIONS);
//--- arrows for the swing points
   PlotIndexSetInteger(1, PLOT_ARROW, 234);
   PlotIndexSetInteger(2, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 10);
   for(int k = 0; k < 3; k++)
      PlotIndexSetDouble(k, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   if(!InpShowVWAP)
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
   if(!InpShowSwings)
     {
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
     }
//--- name and digits
   IndicatorSetString(INDICATOR_SHORTNAME, "Session Levels");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//--- timer used to retry drawing when history is not ready
   ExtLastBar = 0;
   EventSetTimer(2);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PREFIX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Timer: retries drawing when history was not ready (e.g. weekend) |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(!ExtNeedRedraw)
      return;
   DrawLevels();
   if(ExtLastPrice > 0)
      UpdatePanel(ExtLastPrice, ExtLastVWAP);
   ChartRedraw();
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
   int swing_len = MathMax(1, InpSwingLen);
   if(rates_total < 2 * swing_len + 3)
      return 0;
   int start = (prev_calculated > 0) ? prev_calculated - 1 : 0;
//--- daily VWAP (the first bar of each day is left empty so days are not joined)
   for(int i = start; i < rates_total; i++)
     {
      double typical = (high[i] + low[i] + close[i]) / 3.0;
      double vol     = (double)tick_volume[i];
      if(vol <= 0)
         vol = 1;
      bool new_day = (i == 0) || (DayIndex(time[i]) != DayIndex(time[i - 1]));
      ExtSumPVBuffer[i]  = new_day ? typical * vol : ExtSumPVBuffer[i - 1] + typical * vol;
      ExtSumVolBuffer[i] = new_day ? vol : ExtSumVolBuffer[i - 1] + vol;
      ExtVWAPBuffer[i]   = (InpShowVWAP && !new_day && ExtSumVolBuffer[i] > 0) ?
                           ExtSumPVBuffer[i] / ExtSumVolBuffer[i] : EMPTY_VALUE;
     }
//--- swings: a swing at bar k is confirmed only after swing_len more bars have closed
   for(int i = start; i < rates_total; i++)
     {
      ExtSwingHighBuffer[i] = EMPTY_VALUE;
      ExtSwingLowBuffer[i]  = EMPTY_VALUE;
     }
   int k_from = MathMax(swing_len, start - swing_len - 1);
   for(int k = k_from; k <= rates_total - 1 - swing_len; k++)
     {
      ExtSwingHighBuffer[k] = EMPTY_VALUE;
      ExtSwingLowBuffer[k]  = EMPTY_VALUE;
      if(!InpShowSwings)
         continue;
      bool is_high = true;
      bool is_low  = true;
      for(int j = 1; j <= swing_len && (is_high || is_low); j++)
        {
         if(high[k - j] >= high[k] || high[k + j] > high[k])
            is_high = false;
         if(low[k - j] <= low[k] || low[k + j] < low[k])
            is_low = false;
        }
      if(is_high)
         ExtSwingHighBuffer[k] = high[k];
      if(is_low)
         ExtSwingLowBuffer[k] = low[k];
     }
//--- objects: redraw on every new bar
   if(time[rates_total - 1] != ExtLastBar || prev_calculated == 0)
     {
      ExtLastBar = time[rates_total - 1];
      DrawLevels();
     }
//--- panel and alerts on every tick
   double price = close[rates_total - 1];
   double vwap  = (ExtSumVolBuffer[rates_total - 1] > 0) ?
                  ExtSumPVBuffer[rates_total - 1] / ExtSumVolBuffer[rates_total - 1] : 0;
   ExtLastPrice = price;
   ExtLastVWAP  = vwap;
   UpdatePanel(price, vwap);
   CheckAlerts(price);
   ChartRedraw();
   return rates_total;
  }
//+------------------------------------------------------------------+
