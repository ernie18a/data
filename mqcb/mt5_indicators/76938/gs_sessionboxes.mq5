//+------------------------------------------------------------------+
//|                                              GS_SessionBoxes.mq5 |
//|                        Gold Session Boxes - Sydney, Tokyo, London,|
//|                        New York and the London/New York overlap   |
//|                                   Ihsan Ullah, Gold Scalpers      |
//+------------------------------------------------------------------+
#property copyright   "Ihsan Ullah"
#property link        "https://www.mql5.com/en/users/sanikhan444"
#property version     "1.00"
#property description "Draws the four trading sessions as high/low boxes on the chart, with the"
#property description "London-New York overlap highlighted and the daily rollover hour shaded."
#property description "Session times are entered in GMT; the broker's server offset is detected"
#property description "automatically, so the boxes stay correct across daylight-saving changes."
#property description "Each box shows the session range and the average range of the last N"
#property description "sessions. Optional alert when a session opens. Built for XAUUSD, works"
#property description "on any symbol and any timeframe up to H1."
#property indicator_chart_window
#property indicator_plots 0

//--- session definition
struct SessionDef
  {
   string            name;
   bool              enabled;
   int               startGmt;     // hour 0-23
   int               endGmt;       // hour 0-23 (may be < start when it crosses midnight)
   color             clr;
   datetime          lastAlertKey; // start time of the last session we alerted on
  };

//--- inputs
input group "Sessions (hours in GMT, 0-23)"
input bool     InpShowSydney     = true;        // Show Sydney
input int      InpSydneyStart    = 21;          // Sydney start (GMT)
input int      InpSydneyEnd      = 6;           // Sydney end (GMT)
input bool     InpShowTokyo      = true;        // Show Tokyo
input int      InpTokyoStart     = 0;           // Tokyo start (GMT)
input int      InpTokyoEnd       = 9;           // Tokyo end (GMT)
input bool     InpShowLondon     = true;        // Show London
input int      InpLondonStart    = 7;           // London start (GMT)
input int      InpLondonEnd      = 16;          // London end (GMT)
input bool     InpShowNewYork    = true;        // Show New York
input int      InpNewYorkStart   = 13;          // New York start (GMT)
input int      InpNewYorkEnd     = 22;          // New York end (GMT)

input group "Overlap and rollover"
input bool     InpShowOverlap    = true;        // Highlight London-New York overlap
input int      InpOverlapStart   = 13;          // Overlap start (GMT)
input int      InpOverlapEnd     = 16;          // Overlap end (GMT)
input bool     InpShowRollover   = true;        // Shade the daily rollover hour
input int      InpRolloverHour   = 22;          // Rollover hour (GMT)

input group "Appearance"
input int      InpDaysBack       = 10;          // Days to draw
input bool     InpFillBoxes      = true;        // Fill boxes
input bool     InpShowLabels     = true;        // Show session labels with range
input int      InpAvgSessions    = 10;          // Sessions for the average range
input color    InpSydneyColor    = C'70,80,110';    // Sydney colour
input color    InpTokyoColor     = C'60,100,120';   // Tokyo colour
input color    InpLondonColor    = C'120,90,40';    // London colour
input color    InpNewYorkColor   = C'60,110,80';    // New York colour
input color    InpOverlapColor   = clrGoldenrod;    // Overlap colour
input color    InpRolloverColor  = C'110,50,50';    // Rollover colour
input color    InpLabelColor     = clrSilver;       // Label colour
input int      InpLabelFontSize  = 8;              // Label font size

input group "Alerts"
input bool     InpAlertOnOpen    = false;       // Alert when a session opens
input bool     InpAlertPopup     = true;        // Pop-up alert
input bool     InpAlertPush      = false;       // Push notification
input bool     InpAlertSound     = false;       // Sound
input string   InpAlertSoundFile = "alert.wav"; // Sound file

//--- globals
#define PREFIX "GSSB_"
SessionDef  g_sessions[4];
int         g_offsetSec   = 0;      // server time minus GMT, seconds
datetime    g_lastBarTime = 0;

//+------------------------------------------------------------------+
//| Helpers                                                          |
//+------------------------------------------------------------------+
int ClampHour(const int h) { return (h < 0 ? 0 : (h > 23 ? 23 : h)); }

//--- server offset from GMT, recomputed so DST changes are picked up
void RefreshOffset()
  {
   g_offsetSec = (int)(TimeTradeServer() - TimeGMT());
   // round to the nearest 15 minutes to remove clock jitter
   g_offsetSec = (int)MathRound(g_offsetSec / 900.0) * 900;
  }

//--- midnight (server time) of the day that contains t
datetime ServerDayStart(const datetime t)
  {
   return (datetime)((long)t - ((long)t % 86400));
  }

//--- start/end of a GMT-defined session for a given server-time day.
//    Sessions that cross midnight (e.g. Sydney 21-06) start the day before.
void SessionWindow(const datetime dayStart, const int startGmt, const int endGmt,
                   datetime &from, datetime &to)
  {
   datetime dayStartGmt = dayStart - g_offsetSec;          // this server day, in GMT
   from = dayStartGmt + startGmt * 3600;
   to   = dayStartGmt + endGmt   * 3600;
   if(endGmt <= startGmt) from -= 86400;                    // crosses midnight
   from += g_offsetSec;                                     // back to server time
   to   += g_offsetSec;
  }

//--- high/low of the bars inside [from, to). Returns false when no bars.
bool RangeOfWindow(const datetime from, const datetime to, double &hi, double &lo)
  {
   datetime tm[];
   double   h[], l[];
   int n = CopyTime(_Symbol, _Period, from, to - 1, tm);
   if(n <= 0) return false;
   if(CopyHigh(_Symbol, _Period, from, to - 1, h) != n) return false;
   if(CopyLow(_Symbol, _Period, from, to - 1, l) != n) return false;
   hi = h[0]; lo = l[0];
   for(int i = 1; i < n; i++)
     {
      if(h[i] > hi) hi = h[i];
      if(l[i] < lo) lo = l[i];
     }
   return true;
  }

//--- object creation, tolerant of re-runs
void DrawBox(const string name, const datetime from, const datetime to,
             const double hi, const double lo, const color clr, const bool fill, const int width = 1)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, from, hi, to, lo);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
     }
   else
     {
      ObjectMove(0, name, 0, from, hi);
      ObjectMove(0, name, 1, to, lo);
     }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FILL, fill);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
  }

void DrawLabel(const string name, const datetime at, const double price, const string text, const color clr)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TEXT, 0, at, price);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetString(0, name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpLabelFontSize);
     }
   else
      ObjectMove(0, name, 0, at, price);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }

string RangeText(const double range)
  {
   // gold and indices read better in price units; FX pairs in points
   if(_Digits <= 3) return DoubleToString(range, _Digits);
   return IntegerToString((int)MathRound(range / _Point)) + " pts";
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(PeriodSeconds() > PeriodSeconds(PERIOD_H1))
     {
      Print("GS Session Boxes: use a timeframe of H1 or lower. Nothing drawn on ", EnumToString(_Period));
      return(INIT_SUCCEEDED);   // stay attached, draw nothing
     }

   g_sessions[0].name = "Sydney";   g_sessions[0].enabled = InpShowSydney;
   g_sessions[0].startGmt = ClampHour(InpSydneyStart);  g_sessions[0].endGmt = ClampHour(InpSydneyEnd);
   g_sessions[0].clr = InpSydneyColor;

   g_sessions[1].name = "Tokyo";    g_sessions[1].enabled = InpShowTokyo;
   g_sessions[1].startGmt = ClampHour(InpTokyoStart);   g_sessions[1].endGmt = ClampHour(InpTokyoEnd);
   g_sessions[1].clr = InpTokyoColor;

   g_sessions[2].name = "London";   g_sessions[2].enabled = InpShowLondon;
   g_sessions[2].startGmt = ClampHour(InpLondonStart);  g_sessions[2].endGmt = ClampHour(InpLondonEnd);
   g_sessions[2].clr = InpLondonColor;

   g_sessions[3].name = "New York"; g_sessions[3].enabled = InpShowNewYork;
   g_sessions[3].startGmt = ClampHour(InpNewYorkStart); g_sessions[3].endGmt = ClampHour(InpNewYorkEnd);
   g_sessions[3].clr = InpNewYorkColor;

   for(int i = 0; i < 4; i++) g_sessions[i].lastAlertKey = 0;

   RefreshOffset();
   g_lastBarTime = 0;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, PREFIX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Draw every session for the last InpDaysBack days                 |
//+------------------------------------------------------------------+
void Redraw()
  {
   ObjectsDeleteAll(0, PREFIX);

   datetime today = ServerDayStart(TimeTradeServer());
   double   avgSum[4] = {0, 0, 0, 0};
   int      avgCnt[4] = {0, 0, 0, 0};

   //--- pass 1: collect ranges newest-first so the average covers the last N sessions
   double   ranges[4][64];
   for(int d = 0; d < InpDaysBack && d < 64; d++)
     {
      datetime dayStart = today - d * 86400;
      for(int s = 0; s < 4; s++)
        {
         ranges[s][d] = -1;
         if(!g_sessions[s].enabled) continue;
         datetime from, to;
         SessionWindow(dayStart, g_sessions[s].startGmt, g_sessions[s].endGmt, from, to);
         if(from > TimeTradeServer()) continue;            // session not started yet
         double hi, lo;
         if(!RangeOfWindow(from, to, hi, lo)) continue;
         ranges[s][d] = hi - lo;
         if(to <= TimeTradeServer() && avgCnt[s] < InpAvgSessions)   // completed sessions only
           {
            avgSum[s] += hi - lo;
            avgCnt[s]++;
           }
        }
     }

   //--- pass 2: draw
   for(int d = 0; d < InpDaysBack && d < 64; d++)
     {
      datetime dayStart = today - d * 86400;
      string   dayTag   = TimeToString(dayStart, TIME_DATE);

      for(int s = 0; s < 4; s++)
        {
         if(!g_sessions[s].enabled || ranges[s][d] < 0) continue;
         datetime from, to;
         SessionWindow(dayStart, g_sessions[s].startGmt, g_sessions[s].endGmt, from, to);
         double hi, lo;
         if(!RangeOfWindow(from, to, hi, lo)) continue;

         string box = PREFIX + g_sessions[s].name + "_" + dayTag;
         DrawBox(box, from, to, hi, lo, g_sessions[s].clr, InpFillBoxes);

         if(InpShowLabels)
           {
            string txt = g_sessions[s].name + "  " + RangeText(hi - lo);
            if(avgCnt[s] > 0)
               txt += "  (avg " + RangeText(avgSum[s] / avgCnt[s]) + ")";
            DrawLabel(box + "_L", from, hi, txt, InpLabelColor);
           }
        }

      //--- overlap: drawn last so its outline sits on top of the session fills
      if(InpShowOverlap)
        {
         datetime from, to;
         SessionWindow(dayStart, ClampHour(InpOverlapStart), ClampHour(InpOverlapEnd), from, to);
         double hi, lo;
         if(from <= TimeTradeServer() && RangeOfWindow(from, to, hi, lo))
           {
            string box = PREFIX + "Overlap_" + dayTag;
            DrawBox(box, from, to, hi, lo, InpOverlapColor, false, 2);
            if(InpShowLabels)
               DrawLabel(box + "_L", from, lo, "London/NY overlap  " + RangeText(hi - lo), InpOverlapColor);
           }
        }

      //--- rollover hour: the spread trap, shaded across the day's low-high
      if(InpShowRollover)
        {
         datetime from, to;
         int rh = ClampHour(InpRolloverHour);
         SessionWindow(dayStart, rh, (rh + 1) % 24, from, to);
         double hi, lo;
         if(from <= TimeTradeServer() && RangeOfWindow(from, to, hi, lo))
            DrawBox(PREFIX + "Rollover_" + dayTag, from, to, hi, lo, InpRolloverColor, true);
        }
     }
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Session-open alerts                                              |
//+------------------------------------------------------------------+
void CheckAlerts()
  {
   if(!InpAlertOnOpen) return;
   datetime now      = TimeTradeServer();
   datetime dayStart = ServerDayStart(now);

   for(int s = 0; s < 4; s++)
     {
      if(!g_sessions[s].enabled) continue;
      datetime from, to;
      SessionWindow(dayStart, g_sessions[s].startGmt, g_sessions[s].endGmt, from, to);
      // a session that crossed midnight may have started yesterday; also look at tomorrow's start
      datetime candidates[2] = {from, from + 86400};
      for(int k = 0; k < 2; k++)
        {
         datetime st = candidates[k];
         if(now >= st && now < st + PeriodSeconds() * 2 && g_sessions[s].lastAlertKey != st)
           {
            g_sessions[s].lastAlertKey = st;
            string msg = _Symbol + ": " + g_sessions[s].name + " session open (" +
                         IntegerToString(g_sessions[s].startGmt) + ":00 GMT)";
            if(InpAlertPopup) Alert(msg);
            if(InpAlertPush)  SendNotification(msg);
            if(InpAlertSound) PlaySound(InpAlertSoundFile);
           }
        }
     }
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
   if(rates_total < 2) return(0);
   if(PeriodSeconds() > PeriodSeconds(PERIOD_H1)) return(rates_total);

   //--- redraw once per bar (the current session's box grows with each new bar),
   //    and on the first call after attach or a history reload
   datetime lastBar = time[rates_total - 1];
   if(lastBar != g_lastBarTime || prev_calculated == 0)
     {
      RefreshOffset();
      Redraw();
      g_lastBarTime = lastBar;
     }
   CheckAlerts();
   return(rates_total);
  }
//+------------------------------------------------------------------+
