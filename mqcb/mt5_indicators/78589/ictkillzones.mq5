//+------------------------------------------------------------------+
//|                                                 ICTKillZones.mq5 |
//|   ICT Kill Zones: Asian, London, New York, London Close           |
//|                                       Muhammad Muqeem Korejo      |
//+------------------------------------------------------------------+
//
// Kill zones are the hours in which ICT (Inner Circle Trader) traders
// expect the moves of the day. They are defined in New York local time:
//   Asian kill zone         20:00 - 00:00
//   London kill zone        02:00 - 05:00
//   New York kill zone      07:00 - 10:00
//   London Close kill zone  10:00 - 12:00
// Every time can be changed (HH:MM-HH:MM, New York time).
// The chart shows the broker's server time, so every candle is converted
// to New York time, summer time (DST) included:
//   Auto  - the server's GMT offset is read from the terminal;
//           GMT+2 / GMT+3 servers are taken as New York + 7 h (the usual
//           forex server clock), other offsets as a fixed offset.
//           The Strategy Tester has no real clock: New York + 7 h there.
//   NY+7  - the server clock is always New York + 7 h
//   EU    - GMT+2 in winter, GMT+3 in European summer time
//   Fixed - a fixed GMT offset, for example GMT+0
// US summer time: second Sunday of March - first Sunday of November.
// Every kill zone gets a box from its high to its low.
// Optional: the high and low of each finished kill zone are extended
// until price trades through them (liquidity that is taken later), and
// the midnight open line (00:00 New York opening price).
// Kill zones are a few hours long, so they are drawn on M1 - H1 charts.
// Buffers for Expert Advisors (iCustom, not drawn). They hold the LAST
// FINISHED kill zone of each kind, so they never repaint:
//   0 / 1 = Asian high / low,     2 / 3 = London high / low,
//   4 / 5 = New York high / low,  6 / 7 = London Close high / low,
//   EMPTY_VALUE when there is none (and on charts above H1).
// Read-only: the indicator never trades.
//
#property copyright   "Muhammad Muqeem Korejo"
#property link        "https://www.mql5.com/en/users/korejo123"
#property version     "1.00"
#property description "ICT Kill Zones: Asian, London, New York and London Close in New York time, converted"
#property description "from the broker's server time with summer time (auto, NY + 7, EU or fixed GMT offset)."
#property description "High / low boxes, highs and lows extended until price takes them, midnight open line."
#property description "Alerts and buffers for EAs. Read-only: never trades."
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8
#property indicator_type1   DRAW_NONE
#property indicator_label1  "Asian high"
#property indicator_type2   DRAW_NONE
#property indicator_label2  "Asian low"
#property indicator_type3   DRAW_NONE
#property indicator_label3  "London high"
#property indicator_type4   DRAW_NONE
#property indicator_label4  "London low"
#property indicator_type5   DRAW_NONE
#property indicator_label5  "New York high"
#property indicator_type6   DRAW_NONE
#property indicator_label6  "New York low"
#property indicator_type7   DRAW_NONE
#property indicator_label7  "London Close high"
#property indicator_type8   DRAW_NONE
#property indicator_label8  "London Close low"

enum ENUM_KZ_CLOCK
  {
   CLOCK_AUTO  = 0, // Auto (read from the terminal)
   CLOCK_NY7   = 1, // New York + 7 h (GMT+2 / GMT+3, US dates)
   CLOCK_EU    = 2, // GMT+2 / GMT+3 with European dates
   CLOCK_FIXED = 3  // Fixed GMT offset (next input)
  };

input ENUM_KZ_CLOCK InpClock         = CLOCK_AUTO;      // Broker server clock
input int           InpGMTOffset     = 0;               // Fixed clock: server GMT offset (hours)
input int           InpDays          = 5;               // Trading days shown
input bool          InpAsia          = true;            // Asian kill zone
input string        InpAsiaTime      = "20:00-00:00";   // Asian time (New York)
input color         InpAsiaColor     = C'206,224,250';  // Asian colour
input bool          InpLondon        = true;            // London kill zone
input string        InpLondonTime    = "02:00-05:00";   // London time (New York)
input color         InpLondonColor   = C'253,226,190';  // London colour
input bool          InpNewYork       = true;            // New York kill zone
input string        InpNewYorkTime   = "07:00-10:00";   // New York time (New York)
input color         InpNewYorkColor  = C'204,236,204';  // New York colour
input bool          InpClose         = true;            // London Close kill zone
input string        InpCloseTime     = "10:00-12:00";   // London Close time (New York)
input color         InpCloseColor    = C'232,214,242';  // London Close colour
input bool          InpLevels        = true;            // Extend highs / lows until price takes them
input bool          InpMidnight      = true;            // Midnight open line (00:00 New York)
input color         InpMidnightColor = clrGray;         // Midnight open colour
input bool          InpLabels        = true;            // Kill zone names on the boxes
input bool          InpInfo          = true;            // Clock info in the chart corner
input bool          InpAlertStart    = false;           // Alert when a kill zone starts
input bool          InpAlertTaken    = false;           // Alert when price takes a kill zone high / low
input bool          InpPush          = false;           // Alerts also as push notification
input bool          InpEmail         = false;           // Alerts also by e-mail

#define PREFIX "ICTKZ_"
#define KINDS  4
#define HOUR   3600
#define DAY    86400

struct Zone
  {
   int               kind;       // 0 Asia, 1 London, 2 New York, 3 London Close
   long              start;      // New York time in seconds (also the id)
   long              end;
   long              tday;       // trading day (17:00 - 17:00 New York)
   datetime          t1;         // first and last candle (server time)
   datetime          t2;
   double            hi;
   double            lo;
   datetime          hiTaken;    // candle that traded through the high after the zone (0 = not yet)
   datetime          loTaken;
  };

struct DayOpen
  {
   long              day;        // New York date (00:00) in seconds
   datetime          t1;         // first and last candle of that date
   datetime          t2;
   double            price;
  };

double   g_b0[], g_b1[], g_b2[], g_b3[], g_b4[], g_b5[], g_b6[], g_b7[];
Zone     g_z[];
int      g_zn = 0;
DayOpen  g_d[];
int      g_dn = 0;
long     g_days[];                       // trading days in the window, oldest first
int      g_tn = 0;
int      g_from[KINDS], g_to[KINDS];     // minutes after New York midnight (g_to > g_from)
bool     g_on[KINDS];
color    g_clr[KINDS];
string   g_name[KINDS] = {"Asia", "London", "New York", "London Close"};
int      g_clock    = CLOCK_NY7;
long     g_offset   = 0;                 // fixed clock: server time - GMT in seconds
int      g_last     = -1;                // last calculated candle (the forming one)
datetime g_lastTime = 0;                 // its time (another time there = the history has changed)
datetime g_lastBar  = 0;
bool     g_live     = false;             // false while the history is calculated (no alerts)
bool     g_dirty    = true;
long     g_nyNow    = 0;
string   g_drawn[];
//--- summer time dates of one year (GMT, cached)
long     g_yFrom = 0, g_yTo = 0, g_usOn = 0, g_usOff = 0, g_euOn = 0, g_euOff = 0;

//+------------------------------------------------------------------+
//| Inputs and buffers                                               |
//+------------------------------------------------------------------+
int OnInit()
  {
   string times[KINDS];
   times[0] = InpAsiaTime;
   times[1] = InpLondonTime;
   times[2] = InpNewYorkTime;
   times[3] = InpCloseTime;
   g_on[0]  = InpAsia;
   g_on[1]  = InpLondon;
   g_on[2]  = InpNewYork;
   g_on[3]  = InpClose;
   g_clr[0] = InpAsiaColor;
   g_clr[1] = InpLondonColor;
   g_clr[2] = InpNewYorkColor;
   g_clr[3] = InpCloseColor;
   for(int k = 0; k < KINDS; k++)
      if(!ParseRange(times[k], g_from[k], g_to[k]))
        {
         PrintFormat("ICT Kill Zones: \"%s\" is not a time range, use HH:MM-HH:MM in New York time, for example 02:00-05:00", times[k]);
         return INIT_PARAMETERS_INCORRECT;
        }
   if(InpDays < 1 || InpDays > 60 || InpGMTOffset < -12 || InpGMTOffset > 14)
     {
      Print("ICT Kill Zones: trading days 1 - 60, GMT offset -12 - 14");
      return INIT_PARAMETERS_INCORRECT;
     }
   g_clock  = (InpClock == CLOCK_AUTO ? CLOCK_NY7 : (int)InpClock);
   g_offset = (long)InpGMTOffset * HOUR;
   SetIndexBuffer(0, g_b0, INDICATOR_DATA);
   SetIndexBuffer(1, g_b1, INDICATOR_DATA);
   SetIndexBuffer(2, g_b2, INDICATOR_DATA);
   SetIndexBuffer(3, g_b3, INDICATOR_DATA);
   SetIndexBuffer(4, g_b4, INDICATOR_DATA);
   SetIndexBuffer(5, g_b5, INDICATOR_DATA);
   SetIndexBuffer(6, g_b6, INDICATOR_DATA);
   SetIndexBuffer(7, g_b7, INDICATOR_DATA);
   for(int b = 0; b < 2 * KINDS; b++)
      PlotIndexSetDouble(b, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "ICT Kill Zones");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Remove the drawings                                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, PREFIX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| The last InpDays trading days; the forming candle is calculated   |
//| again on every tick (its high can only grow, its low only fall)   |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
  {
   if(rates_total < 2)
      return 0;
   bool full   = (prev_calculated == 0 || g_last < 0 || g_last > rates_total - 1 || time[g_last] != g_lastTime);
   bool newBar = (time[rates_total - 1] != g_lastBar);
   //--- auto clock: measured again on every new candle, a change draws everything again
   if(InpClock == CLOCK_AUTO && (full || newBar))
     {
      int  clock;
      long offset;
      DetectClock(clock, offset);
      if(clock != g_clock || offset != g_offset)
         full = true;
      g_clock  = clock;
      g_offset = offset;
     }
   bool small = (PeriodSeconds() <= HOUR);
   if(full)
     {
      ArrayInitialize(g_b0, EMPTY_VALUE);
      ArrayInitialize(g_b1, EMPTY_VALUE);
      ArrayInitialize(g_b2, EMPTY_VALUE);
      ArrayInitialize(g_b3, EMPTY_VALUE);
      ArrayInitialize(g_b4, EMPTY_VALUE);
      ArrayInitialize(g_b5, EMPTY_VALUE);
      ArrayInitialize(g_b6, EMPTY_VALUE);
      ArrayInitialize(g_b7, EMPTY_VALUE);
      g_zn    = 0;
      g_dn    = 0;
      g_tn    = 0;
      g_last  = (small ? WindowStart(rates_total, time) : rates_total - 1);
      g_live  = false;
      g_dirty = true;
     }
   if(!small)
     {
      //--- kill zones are a few hours long: nothing is drawn above H1, the buffers stay empty
      for(int k = g_last + 1; k < rates_total; k++)
         for(int b = 0; b < 2 * KINDS; b++)
            SetBuf(b, k, EMPTY_VALUE);
      g_last     = rates_total - 1;
      g_lastTime = time[g_last];
      g_lastBar  = time[g_last];
      if(full)
        {
         Info("ICT Kill Zones: kill zones are drawn on M1 - H1 charts");
         ChartRedraw();
        }
      return rates_total;
     }
   bool alerts = (g_live && !full);
   for(int k = g_last; k < rates_total; k++)
      AddCandle(k, time[k], open[k], high[k], low[k], alerts);
   g_last     = rates_total - 1;
   g_lastTime = time[g_last];
   g_nyNow    = ToNY(time[g_last]);
   if(newBar)
     {
      g_lastBar = time[g_last];
      g_dirty   = true;
     }
   if(g_dirty)
     {
      Draw(time[g_last]);
      g_dirty = false;
     }
   g_live = true;
   return rates_total;
  }

//+------------------------------------------------------------------+
//| First candle of the last InpDays trading days                    |
//+------------------------------------------------------------------+
int WindowStart(const int rates_total, const datetime &time[])
  {
   int  start = rates_total - 1;
   long day   = TradingDay(ToNY(time[start]));
   int  days  = 1;
   for(int i = rates_total - 2; i >= 0; i--)
     {
      long d = TradingDay(ToNY(time[i]));
      if(d != day)
        {
         day = d;
         if(++days > InpDays)
            break;
        }
      start = i;
     }
   return start;
  }

//+------------------------------------------------------------------+
//| One candle: midnight open, kill zones, highs / lows taken, buffers|
//+------------------------------------------------------------------+
void AddCandle(const int k, const datetime t, const double o, const double h, const double l, const bool alert)
  {
   long ny  = ToNY(t);
   long day = ny - ny % DAY;
   AddTradingDay(TradingDay(ny));
   //--- midnight open: the first candle of the New York date (none on Sunday, the week opens at 17:00)
   if(g_dn > 0 && g_d[g_dn - 1].day == day)
     {
      if(t > g_d[g_dn - 1].t2)
        {
         g_d[g_dn - 1].t2 = t;
         g_dirty = true;
        }
     }
   else
      if(ny - day < HOUR)
        {
         if(g_dn >= ArraySize(g_d))
            ArrayResize(g_d, g_dn + 16, 16);
         g_d[g_dn].day   = day;
         g_d[g_dn].t1    = t;
         g_d[g_dn].t2    = t;
         g_d[g_dn].price = o;
         g_dn++;
         g_dirty = true;
        }
   //--- the kill zones this candle belongs to
   for(int kind = 0; kind < KINDS; kind++)
     {
      long st, en;
      if(!InZone(kind, ny, st, en))
         continue;
      int i = Newest(kind);
      if(i >= 0 && g_z[i].start == st)
        {
         if(h > g_z[i].hi)
           {
            g_z[i].hi = h;
            g_dirty   = true;
           }
         if(l < g_z[i].lo)
           {
            g_z[i].lo = l;
            g_dirty   = true;
           }
         if(t > g_z[i].t2)
           {
            g_z[i].t2 = t;
            g_dirty   = true;
           }
         continue;
        }
      if(g_zn >= ArraySize(g_z))
         ArrayResize(g_z, g_zn + 32, 32);
      g_z[g_zn].kind    = kind;
      g_z[g_zn].start   = st;
      g_z[g_zn].end     = en;
      g_z[g_zn].tday    = TradingDay(st);
      g_z[g_zn].t1      = t;
      g_z[g_zn].t2      = t;
      g_z[g_zn].hi      = h;
      g_z[g_zn].lo      = l;
      g_z[g_zn].hiTaken = 0;
      g_z[g_zn].loTaken = 0;
      g_zn++;
      g_dirty = true;
      if(alert && InpAlertStart && g_on[kind])
         Notify(g_name[kind] + " kill zone has started");
     }
   //--- highs and lows of finished kill zones that this candle trades through
   for(int i = 0; i < g_zn; i++)
     {
      if(g_z[i].end > ny)
         continue;
      int kind = g_z[i].kind;
      if(g_z[i].hiTaken == 0 && h > g_z[i].hi)
        {
         g_z[i].hiTaken = t;
         g_dirty        = true;
         if(alert && InpAlertTaken && g_on[kind])
            Notify("price took the " + g_name[kind] + " high " + DoubleToString(g_z[i].hi, _Digits));
        }
      if(g_z[i].loTaken == 0 && l < g_z[i].lo)
        {
         g_z[i].loTaken = t;
         g_dirty        = true;
         if(alert && InpAlertTaken && g_on[kind])
            Notify("price took the " + g_name[kind] + " low " + DoubleToString(g_z[i].lo, _Digits));
        }
     }
   //--- buffers: the last finished kill zone of each kind
   for(int kind = 0; kind < KINDS; kind++)
     {
      double hi = EMPTY_VALUE, lo = EMPTY_VALUE;
      for(int i = g_zn - 1; i >= 0; i--)
         if(g_z[i].kind == kind && g_z[i].end <= ny)
           {
            hi = g_z[i].hi;
            lo = g_z[i].lo;
            break;
           }
      SetBuf(2 * kind, k, hi);
      SetBuf(2 * kind + 1, k, lo);
     }
  }

//+------------------------------------------------------------------+
//| A new trading day: forget the oldest one beyond InpDays          |
//+------------------------------------------------------------------+
void AddTradingDay(const long td)
  {
   if(g_tn > 0 && g_days[g_tn - 1] == td)
      return;
   if(g_tn >= ArraySize(g_days))
      ArrayResize(g_days, g_tn + 16, 16);
   g_days[g_tn++] = td;
   if(g_tn <= InpDays)
      return;
   int  drop  = g_tn - InpDays;
   long first = g_days[drop];
   for(int i = 0; i < InpDays; i++)
      g_days[i] = g_days[i + drop];
   g_tn = InpDays;
   int w = 0;
   for(int i = 0; i < g_zn; i++)
      if(g_z[i].tday >= first)
         g_z[w++] = g_z[i];
   g_zn = w;
   w = 0;
   for(int i = 0; i < g_dn; i++)
      if(TradingDay(g_d[i].day) >= first)
         g_d[w++] = g_d[i];
   g_dn    = w;
   g_dirty = true;
  }

//+------------------------------------------------------------------+
//| Does a candle opening at New York time ny overlap kill zone kind? |
//| st / en = that kill zone in New York time                        |
//+------------------------------------------------------------------+
bool InZone(const int kind, const long ny, long &st, long &en)
  {
   long day = ny - ny % DAY;
   long len = PeriodSeconds();
   for(int back = 0; back <= 1; back++)       // today's zone, or yesterday's one that crosses midnight
     {
      st = day - back * DAY + (long)g_from[kind] * 60;
      en = day - back * DAY + (long)g_to[kind] * 60;
      if(ny < en && ny + len > st)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Index of the newest kill zone of one kind (-1 = none)            |
//+------------------------------------------------------------------+
int Newest(const int kind)
  {
   for(int i = g_zn - 1; i >= 0; i--)
      if(g_z[i].kind == kind)
         return i;
   return -1;
  }

//+------------------------------------------------------------------+
//| Trading day number: the day starts at 17:00 New York             |
//+------------------------------------------------------------------+
long TradingDay(const long ny)
  {
   return (ny + 7 * HOUR) / DAY;
  }

//+------------------------------------------------------------------+
//| Server time -> New York time (seconds), summer time included     |
//+------------------------------------------------------------------+
long ToNY(const datetime server)
  {
   long s = (long)server;
   if(g_clock == CLOCK_NY7)
      return s - 7 * HOUR;
   long gmt;
   if(g_clock == CLOCK_EU)
     {
      Rules(s - 2 * HOUR);
      gmt = (s - 3 * HOUR >= g_euOn && s - 3 * HOUR < g_euOff) ? s - 3 * HOUR : s - 2 * HOUR;
     }
   else
      gmt = s - g_offset;
   Rules(gmt);
   return (gmt >= g_usOn && gmt < g_usOff) ? gmt - 4 * HOUR : gmt - 5 * HOUR;
  }

//+------------------------------------------------------------------+
//| US and EU summer time of the year of t (GMT)                     |
//+------------------------------------------------------------------+
void Rules(const long t)
  {
   if(t >= g_yFrom && t < g_yTo)
      return;
   MqlDateTime d;
   TimeToStruct((datetime)t, d);
   int y   = d.year;
   g_yFrom = MakeDate(y, 1, 1);
   g_yTo   = MakeDate(y + 1, 1, 1);
   g_usOn  = NthSunday(y, 3, 2) + 7 * HOUR;    // 2nd Sunday of March, 02:00 New York winter time
   g_usOff = NthSunday(y, 11, 1) + 6 * HOUR;   // 1st Sunday of November, 02:00 New York summer time
   g_euOn  = LastSunday(y, 3) + HOUR;          // last Sunday of March, 01:00 GMT
   g_euOff = LastSunday(y, 10) + HOUR;         // last Sunday of October, 01:00 GMT
  }

//+------------------------------------------------------------------+
//| Date helpers (GMT seconds)                                       |
//+------------------------------------------------------------------+
long MakeDate(const int y, const int m, const int d)
  {
   MqlDateTime s;
   ZeroMemory(s);
   s.year = y;
   s.mon  = m;
   s.day  = d;
   return (long)StructToTime(s);
  }

int WeekDay(const long t)
  {
   return (int)((t / DAY + 4) % 7);            // 1 January 1970 was a Thursday; 0 = Sunday
  }

long NthSunday(const int y, const int m, const int n)
  {
   long first = MakeDate(y, m, 1);
   return first + (long)((7 - WeekDay(first)) % 7 + 7 * (n - 1)) * DAY;
  }

long LastSunday(const int y, const int m)
  {
   long last = (m == 12 ? MakeDate(y + 1, 1, 1) : MakeDate(y, m + 1, 1)) - DAY;
   return last - (long)WeekDay(last) * DAY;
  }

//+------------------------------------------------------------------+
//| Auto clock: server - GMT, rounded to 30 minutes                  |
//+------------------------------------------------------------------+
void DetectClock(int &clock, long &offset)
  {
   clock  = CLOCK_NY7;
   offset = 0;
   //--- the Strategy Tester has no real GMT clock: the usual server clock is used
   if(MQLInfoInteger(MQL_TESTER))
      return;
   long diff = (long)TimeTradeServer() - (long)TimeGMT();
   long off  = (long)MathRound(diff / 1800.0) * 1800;
   if(off == 2 * HOUR || off == 3 * HOUR || off < -12 * HOUR || off > 14 * HOUR)
      return;
   clock  = CLOCK_FIXED;
   offset = off;
  }

//+------------------------------------------------------------------+
//| "HH:MM-HH:MM" -> minutes after midnight (to > from)               |
//+------------------------------------------------------------------+
bool ParseRange(const string text, int &from, int &to)
  {
   string s = text;
   string parts[];
   StringReplace(s, " ", "");
   if(StringSplit(s, '-', parts) != 2)
      return false;
   from = Minutes(parts[0]);
   to   = Minutes(parts[1]);
   if(from < 0 || to < 0 || from == to)
      return false;
   if(to < from)
      to += 1440;                              // the kill zone crosses midnight
   return true;
  }

int Minutes(const string hhmm)
  {
   string p[];
   if(StringSplit(hhmm, ':', p) != 2 || StringLen(p[0]) < 1 || StringLen(p[0]) > 2 || StringLen(p[1]) != 2)
      return -1;
   for(int i = 0; i < 2; i++)
      for(int c = 0; c < StringLen(p[i]); c++)
        {
         ushort ch = StringGetCharacter(p[i], c);
         if(ch < '0' || ch > '9')
            return -1;
        }
   int h = (int)StringToInteger(p[0]);
   int m = (int)StringToInteger(p[1]);
   if(h == 24 && m == 0)
      return 0;
   if(h > 23 || m > 59)
      return -1;
   return h * 60 + m;
  }

//+------------------------------------------------------------------+
//| Buffer b, candle k                                               |
//+------------------------------------------------------------------+
void SetBuf(const int b, const int k, const double v)
  {
   switch(b)
     {
      case 0:
         g_b0[k] = v;
         break;
      case 1:
         g_b1[k] = v;
         break;
      case 2:
         g_b2[k] = v;
         break;
      case 3:
         g_b3[k] = v;
         break;
      case 4:
         g_b4[k] = v;
         break;
      case 5:
         g_b5[k] = v;
         break;
      case 6:
         g_b6[k] = v;
         break;
      default:
         g_b7[k] = v;
         break;
     }
  }

//+------------------------------------------------------------------+
//| Boxes, names, highs / lows until taken, midnight open lines      |
//+------------------------------------------------------------------+
void Draw(const datetime now)
  {
   string keep[];
   int    cnt = 0;
   for(int i = 0; i < g_zn; i++)
     {
      int kind = g_z[i].kind;
      if(!g_on[kind])
         continue;
      string id   = IntegerToString(kind) + "_" + IntegerToString(g_z[i].start);
      color  dark = Strong(g_clr[kind]);
      string hi   = DoubleToString(g_z[i].hi, _Digits), lo = DoubleToString(g_z[i].lo, _Digits);
      Box(PREFIX + "B" + id, g_z[i].t1, g_z[i].hi, g_z[i].t2, g_z[i].lo, g_clr[kind],
          g_name[kind] + " kill zone: high " + hi + ", low " + lo);
      Keep(keep, cnt, PREFIX + "B" + id);
      if(InpLabels)
        {
         Text(PREFIX + "T" + id, g_z[i].t1, g_z[i].hi, g_name[kind], dark);
         Keep(keep, cnt, PREFIX + "T" + id);
        }
      if(InpLevels && g_z[i].end <= g_nyNow)
        {
         Line(PREFIX + "H" + id, g_z[i].t2, g_z[i].hiTaken > 0 ? g_z[i].hiTaken : now, g_z[i].hi, dark, STYLE_DOT,
              g_name[kind] + " high " + hi + (g_z[i].hiTaken > 0 ? " (taken)" : " (not taken yet)"));
         Keep(keep, cnt, PREFIX + "H" + id);
         Line(PREFIX + "L" + id, g_z[i].t2, g_z[i].loTaken > 0 ? g_z[i].loTaken : now, g_z[i].lo, dark, STYLE_DOT,
              g_name[kind] + " low " + lo + (g_z[i].loTaken > 0 ? " (taken)" : " (not taken yet)"));
         Keep(keep, cnt, PREFIX + "L" + id);
        }
     }
   if(InpMidnight)
      for(int i = 0; i < g_dn; i++)
        {
         string id = IntegerToString(g_d[i].day);
         Line(PREFIX + "M" + id, g_d[i].t1, g_d[i].t2, g_d[i].price, InpMidnightColor, STYLE_DASH,
              "Midnight open (00:00 New York) " + DoubleToString(g_d[i].price, _Digits));
         Keep(keep, cnt, PREFIX + "M" + id);
        }
   for(int i = 0; i < ArraySize(g_drawn); i++)
     {
      bool still = false;
      for(int j = 0; j < cnt && !still; j++)
         still = (keep[j] == g_drawn[i]);
      if(!still)
         ObjectDelete(0, g_drawn[i]);
     }
   ArrayResize(g_drawn, cnt);
   for(int j = 0; j < cnt; j++)
      g_drawn[j] = keep[j];
   Info(ClockText());
   ChartRedraw();
  }

void Keep(string &list[], int &cnt, const string name)
  {
   if(cnt >= ArraySize(list))
      ArrayResize(list, cnt + 64);
   list[cnt++] = name;
  }

//+------------------------------------------------------------------+
//| A stronger shade of a light colour (names and lines)             |
//+------------------------------------------------------------------+
color Strong(const color c)
  {
   uint v = (uint)c;
   int  r = 255 - (255 - (int)(v & 0xFF)) * 3;
   int  g = 255 - (255 - (int)((v >> 8) & 0xFF)) * 3;
   int  b = 255 - (255 - (int)((v >> 16) & 0xFF)) * 3;
   r = (int)((r < 0 ? 0 : r) * 0.8);
   g = (int)((g < 0 ? 0 : g) * 0.8);
   b = (int)((b < 0 ? 0 : b) * 0.8);
   return (color)(r | (g << 8) | (b << 16));
  }

//+------------------------------------------------------------------+
//| Chart objects                                                    |
//+------------------------------------------------------------------+
void Box(const string name, const datetime t1, const double p1, const datetime t2, const double p2, const color clr,
         const string tip)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p1);
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 1, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tip);
  }

void Line(const string name, const datetime t1, const datetime t2, const double price, const color clr,
          const ENUM_LINE_STYLE style, const string tip)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price);
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 1, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tip);
  }

void Text(const string name, const datetime t, const double price, const string text, const color clr)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
      ObjectSetString(0, name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//| Info in the lower left corner (a label holds 63 characters)      |
//+------------------------------------------------------------------+
void Info(const string text)
  {
   InfoLine(PREFIX + "INFO", InpInfo ? text : "", 8);
   bool dashed = (InpInfo && InpMidnight && PeriodSeconds() <= HOUR);
   InfoLine(PREFIX + "INFO2", dashed ? "Dashed line: midnight open (00:00 New York)" : "", 22);
  }

void InfoLine(const string name, const string text, const int y)
  {
   if(text == "")
     {
      ObjectDelete(0, name);
      return;
     }
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 8);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrGray);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
  }

string ClockText()
  {
   string text;
   if(g_clock == CLOCK_NY7)
      text = "server = New York + 7 h";
   else
      if(g_clock == CLOCK_EU)
         text = "server = GMT+2/+3 (EU DST)";
      else
        {
         long a = (g_offset < 0 ? -g_offset : g_offset);
         text = StringFormat("server = GMT%s%d", g_offset < 0 ? "-" : "+", (int)(a / HOUR));
         if(a % HOUR != 0)
            text += StringFormat(":%02d", (int)(a % HOUR / 60));
        }
   return "Kill zones in New York time, " + text + (InpClock == CLOCK_AUTO ? " (auto)" : "");
  }

//+------------------------------------------------------------------+
//| Popup, push and e-mail alerts                                    |
//+------------------------------------------------------------------+
void Notify(const string what)
  {
   string text = "ICT Kill Zones " + _Symbol + " " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period), 7) + ": " + what;
   Alert(text);
   if(InpPush)
      SendNotification(text);
   if(InpEmail)
      SendMail("ICT Kill Zones " + _Symbol, text);
  }
//+------------------------------------------------------------------+
