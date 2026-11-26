//+------------------------------------------------------------------+
//|                                     SessionRangeBreakout.mq5     |
//|                                              Blue Fish Quant      |
//|                    https://www.mql5.com/en/users/232737818        |
//+------------------------------------------------------------------+
#property copyright   "Blue Fish Quant"
#property link        "https://www.mql5.com/en/users/232737818"
#property version     "1.00"
#property description "Draws the high and low range of up to three intraday sessions and extends"
#property description "each level to the right. Optional popup, sound and push alerts on a breakout."
#property indicator_chart_window
#property indicator_plots 0

//--- session inputs -------------------------------------------------
input group "Session 1"
input bool   InpS1On       = true;
input string InpS1Name     = "ASIA";
input int    InpS1FromHour = 0;    // start hour (server time)
input int    InpS1ToHour   = 8;    // end hour (server time, exclusive)
input color  InpS1Color    = clrDodgerBlue;

input group "Session 2"
input bool   InpS2On       = true;
input string InpS2Name     = "LONDON";
input int    InpS2FromHour = 8;
input int    InpS2ToHour   = 16;
input color  InpS2Color    = clrOrange;

input group "Session 3"
input bool   InpS3On       = true;
input string InpS3Name     = "NEW YORK";
input int    InpS3FromHour = 13;
input int    InpS3ToHour   = 21;
input color  InpS3Color    = clrTomato;

//--- display inputs -------------------------------------------------
input group "Display"
input int    InpMaxBars    = 3000;   // bars to scan (0 = all)
input int    InpExtendBars = 12;     // how far to extend each level, in bars
input int    InpLineWidth  = 1;
input bool   InpShowLabels = true;   // show high/low text at the level
input bool   InpShowRange  = true;   // fill the session range with a thin rectangle
input bool   InpAutoZoom   = true;   // zoom the chart out on load so older ranges stay visible

//--- alert inputs ---------------------------------------------------
input group "Alerts"
input bool   InpAlertBreakout = false; // alert when price closes outside a session range
input bool   InpAlertPopup    = true;
input bool   InpAlertSound    = false;
input bool   InpAlertPush     = false;

//--- internal -------------------------------------------------------
#define SRB_PREFIX "SRB_"

struct SessionCfg
  {
   bool     on;
   string   name;
   int      fromH;
   int      toH;
   color    clr;
  };

struct SessionState
  {
   bool     active;
   datetime tStart;
   double   hi;
   double   lo;
   int      seq;
  };

SessionCfg    g_cfg[3];
SessionState  g_state[3];
int           g_scannedBars = -1;
int           g_seq         = 0;
datetime      g_lastAlertTime = 0;
int           g_lastAlertSide = 0;

//+------------------------------------------------------------------+
//| Fill the configuration array from the inputs.                     |
//+------------------------------------------------------------------+
void InitConfig()
  {
   g_cfg[0].on    = InpS1On;
   g_cfg[0].name  = InpS1Name;
   g_cfg[0].fromH = InpS1FromHour;
   g_cfg[0].toH   = InpS1ToHour;
   g_cfg[0].clr   = InpS1Color;

   g_cfg[1].on    = InpS2On;
   g_cfg[1].name  = InpS2Name;
   g_cfg[1].fromH = InpS2FromHour;
   g_cfg[1].toH   = InpS2ToHour;
   g_cfg[1].clr   = InpS2Color;

   g_cfg[2].on    = InpS3On;
   g_cfg[2].name  = InpS3Name;
   g_cfg[2].fromH = InpS3FromHour;
   g_cfg[2].toH   = InpS3ToHour;
   g_cfg[2].clr   = InpS3Color;
  }

//+------------------------------------------------------------------+
//| True when the given server time falls inside the session.         |
//| Handles sessions that cross midnight (from > to).                 |
//+------------------------------------------------------------------+
bool InSession(const datetime t, const int fromH, const int toH)
  {
   if(fromH == toH)
      return(false);

   MqlDateTime dt;
   TimeToStruct(t, dt);
   int h = dt.hour;

   if(fromH < toH)
      return(h >= fromH && h < toH);

   return(h >= fromH || h < toH);
  }

//+------------------------------------------------------------------+
//| Delete every object this indicator created.                       |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--)
     {
      string nm = ObjectName(0, i, -1, -1);
      if(StringFind(nm, SRB_PREFIX) == 0)
         ObjectDelete(0, nm);
     }
  }

//+------------------------------------------------------------------+
//| Create or move a horizontal trend line.                           |
//+------------------------------------------------------------------+
void PutLine(const string nm, const datetime t1, const datetime t2,
             const double price, const color clr, const int width)
  {
   if(ObjectFind(0, nm) < 0)
     {
      ObjectCreate(0, nm, OBJ_TREND, 0, t1, price, t2, price);
      ObjectSetInteger(0, nm, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, nm, OBJPROP_RAY_LEFT, false);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, nm, OBJPROP_BACK, true);
     }

   ObjectSetInteger(0, nm, OBJPROP_TIME, 0, t1);
   ObjectSetInteger(0, nm, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, nm, OBJPROP_PRICE, 0, price);
   ObjectSetDouble(0, nm, OBJPROP_PRICE, 1, price);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, nm, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, nm, OBJPROP_STYLE, STYLE_SOLID);
  }

//+------------------------------------------------------------------+
//| Create or move a text label.                                      |
//+------------------------------------------------------------------+
void PutLabel(const string nm, const datetime t, const double price,
              const string text, const color clr)
  {
   if(ObjectFind(0, nm) < 0)
     {
      ObjectCreate(0, nm, OBJ_TEXT, 0, t, price);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, nm, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, 8);
     }

   ObjectSetInteger(0, nm, OBJPROP_TIME, 0, t);
   ObjectSetDouble(0, nm, OBJPROP_PRICE, 0, price);
   ObjectSetString(0, nm, OBJPROP_TEXT, text);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//| Create or move the range rectangle.                               |
//+------------------------------------------------------------------+
void PutRect(const string nm, const datetime t1, const datetime t2,
             const double hi, const double lo, const color clr)
  {
   if(ObjectFind(0, nm) < 0)
     {
      ObjectCreate(0, nm, OBJ_RECTANGLE, 0, t1, hi, t2, lo);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, nm, OBJPROP_BACK, true);
      ObjectSetInteger(0, nm, OBJPROP_FILL, true);
     }

   ObjectSetInteger(0, nm, OBJPROP_TIME, 0, t1);
   ObjectSetInteger(0, nm, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, nm, OBJPROP_PRICE, 0, hi);
   ObjectSetDouble(0, nm, OBJPROP_PRICE, 1, lo);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, nm, OBJPROP_STYLE, STYLE_DOT);
  }

//+------------------------------------------------------------------+
//| Draw one finished (or still running) session block.                |
//+------------------------------------------------------------------+
void DrawSession(const int s, const datetime t1, const datetime t2, const int seq)
  {
   if(!g_cfg[s].on)
      return;

   string base = SRB_PREFIX + IntegerToString(s) + "_" + IntegerToString(seq);

   PutLine(base + "_H", t1, t2, g_state[s].hi, g_cfg[s].clr, InpLineWidth);
   PutLine(base + "_L", t1, t2, g_state[s].lo, g_cfg[s].clr, InpLineWidth);

   if(InpShowRange)
     {
      string rn = base + "_R";
      //--- lighter version of the session colour for the fill
      color fill = g_cfg[s].clr;
      PutRect(rn, t1, t2, g_state[s].hi, g_state[s].lo, fill);
      ObjectSetInteger(0, rn, OBJPROP_BACK, true);
      ObjectSetInteger(0, rn, OBJPROP_FILL, false);
     }

   if(InpShowLabels)
     {
      PutLabel(base + "_TH", t1, g_state[s].hi,
               g_cfg[s].name + " H", g_cfg[s].clr);
      PutLabel(base + "_TL", t1, g_state[s].lo,
               g_cfg[s].name + " L", g_cfg[s].clr);
     }
  }

//+------------------------------------------------------------------+
//| Format a price with the symbol digits.                            |
//+------------------------------------------------------------------+
string PriceToStr(const double price)
  {
   return(DoubleToString(price, _Digits));
  }

//+------------------------------------------------------------------+
//| Map a "series" index (0 = newest bar) onto a physical position    |
//| inside the arrays handed to OnCalculate.                          |
//|                                                                   |
//| OnCalculate's price arrays are declared const, so ArraySetAsSeries |
//| cannot be relied on there: when the flag silently fails time[0]    |
//| is the OLDEST bar and every level lands years in the past.         |
//| Always resolve the index explicitly instead.                       |
//+------------------------------------------------------------------+
int RawIdx(const int rates_total, const int seriesIdx, const bool asSeries)
  {
   if(asSeries)
      return(MathMin(MathMax(seriesIdx, 0), rates_total - 1));

   return(rates_total - 1 - MathMin(MathMax(seriesIdx, 0), rates_total - 1));
  }

//+------------------------------------------------------------------+
//| Rebuild every session block on the chart.                         |
//+------------------------------------------------------------------+
void RebuildAll(const datetime &time[], const double &high[],
                const double &low[], const int rates_total,
                const bool asSeries)
  {
   DeleteAllObjects();

   for(int s = 0; s < 3; s++)
     {
      g_state[s].active = false;
      g_state[s].hi     = 0.0;
      g_state[s].lo     = 0.0;
      g_state[s].seq    = 0;
      g_state[s].tStart = 0;
     }

   g_seq = 0;

   //--- how far back to look: keep only the newest InpMaxBars bars
   int lastBar = rates_total - 1;
   if(InpMaxBars > 0 && rates_total - 1 > InpMaxBars)
      lastBar = InpMaxBars;

   //--- walk from the oldest of those bars towards the newest (i is a series index)
   for(int i = lastBar; i >= 0; i--)
     {
      int      ri = RawIdx(rates_total, i, asSeries);
      datetime t  = time[ri];
      double   bHi = high[ri];
      double   bLo = low[ri];

      for(int s = 0; s < 3; s++)
        {
         if(!g_cfg[s].on)
            continue;

         bool inside = InSession(t, g_cfg[s].fromH, g_cfg[s].toH);

         if(inside)
           {
            if(!g_state[s].active)
              {
               g_state[s].active = true;
               g_state[s].tStart = t;
               g_state[s].hi     = bHi;
               g_state[s].lo     = bLo;
               g_state[s].seq    = g_seq++;
              }
            else
              {
               if(bHi > g_state[s].hi)
                  g_state[s].hi = bHi;
               if(bLo < g_state[s].lo)
                  g_state[s].lo = bLo;
              }
           }
         else
           {
            if(g_state[s].active)
              {
               //--- session finished on the previous (newer) bar
               int      riEnd = (i + 1 < rates_total) ? RawIdx(rates_total, i + 1, asSeries) : ri;
               datetime tEnd  = time[riEnd];
               int shiftBars = InpExtendBars;
               datetime tExt = tEnd + PeriodSeconds() * shiftBars;

               DrawSession(s, g_state[s].tStart, tExt, g_state[s].seq);

               g_state[s].active = false;
               g_state[s].hi     = 0.0;
               g_state[s].lo     = 0.0;
              }
           }
        }
     }

   //--- still open session: draw it up to the current bar plus the extension
   for(int s = 0; s < 3; s++)
     {
      if(!g_cfg[s].on || !g_state[s].active)
         continue;

      datetime tExt = time[RawIdx(rates_total, 0, asSeries)] + PeriodSeconds() * InpExtendBars;
      DrawSession(s, g_state[s].tStart, tExt, g_state[s].seq);
     }

#ifdef SRB_DEBUG
   Print("SRB done: objects=", ObjectsTotal(0), " active1=", g_state[0].active,
         " hi1=", DoubleToString(g_state[0].hi, _Digits));

   //--- temporary diagnostics: are our objects real, and are they on screen?
   int      srbCount = 0;
   int      srbShown = 0;
   datetime srbMinT  = 0;
   datetime srbMaxT  = 0;
   for(int k = ObjectsTotal(0) - 1; k >= 0; k--)
     {
      string on = ObjectName(0, k);
      if(StringFind(on, SRB_PREFIX) != 0)
         continue;
      srbCount++;
      datetime o1 = (datetime)ObjectGetInteger(0, on, OBJPROP_TIME, 0);
      if(srbMinT == 0 || o1 < srbMinT)
         srbMinT = o1;
      if(o1 > srbMaxT)
         srbMaxT = o1;
      if(srbShown < 2)
        {
         datetime o2 = (datetime)ObjectGetInteger(0, on, OBJPROP_TIME, 1);
         double   p0 = ObjectGetDouble(0, on, OBJPROP_PRICE, 0);
         Print("SRB obj ", on,
               " type=", (int)ObjectGetInteger(0, on, OBJPROP_TYPE, 0),
               " t1=", TimeToString(o1, TIME_DATE | TIME_MINUTES),
               " t2=", TimeToString(o2, TIME_DATE | TIME_MINUTES),
               " p0=", DoubleToString(p0, _Digits),
               " clr=", (color)ObjectGetInteger(0, on, OBJPROP_COLOR, 0),
               " w=", (int)ObjectGetInteger(0, on, OBJPROP_WIDTH, 0));
         srbShown++;
        }
     }

   Print("SRB span: count=", srbCount,
         " from=", TimeToString(srbMinT, TIME_DATE | TIME_MINUTES),
         " to=", TimeToString(srbMaxT, TIME_DATE | TIME_MINUTES));

   long     firstVis   = ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
   int      visIdx     = (int)MathMin(MathMax((int)firstVis, 0), rates_total - 1);
   datetime tVisLeft   = time[RawIdx(rates_total, visIdx, asSeries)];
   datetime tNewest    = time[RawIdx(rates_total, 0, asSeries)];
   Print("SRB diag: srbObjects=", srbCount,
         " newest=", TimeToString(tNewest, TIME_DATE | TIME_MINUTES),
         " leftVisible=", TimeToString(tVisLeft, TIME_DATE | TIME_MINUTES),
         " canvasW=", ChartGetInteger(0, CHART_WIDTH_IN_PIXELS),
         " canvasH=", ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS),
         " scaleFix=", (bool)ChartGetInteger(0, CHART_SCALEFIX),
         " fixedMax=", DoubleToString(ChartGetDouble(0, CHART_FIXED_MAX), _Digits),
         " fixedMin=", DoubleToString(ChartGetDouble(0, CHART_FIXED_MIN), _Digits),
         " scale=", ChartGetInteger(0, CHART_SCALE),
         " visBars=", ChartGetInteger(0, CHART_VISIBLE_BARS),
         " firstVis=", ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR));
#endif
  }

//+------------------------------------------------------------------+
//| Indicator initialisation.                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   InitConfig();
   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Session Range Breakout");
   DeleteAllObjects();
   g_scannedBars = -1;

   //--- a freshly zoomed-in chart hides every range that is even a day old,
   //--- which looks exactly like "the indicator draws nothing"
   if(InpAutoZoom)
     {
      ChartSetInteger(0, CHART_SCALE, 1);
      ChartNavigate(0, CHART_END, 0);
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Indicator deinitialisation.                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- only drop our objects when the indicator is really removed from the chart
   if(reason == REASON_REMOVE || reason == REASON_CLOSE || reason == REASON_CHARTCLOSE)
      DeleteAllObjects();

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Main calculation.                                                 |
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
   if(rates_total < 10)
      return(0);

   //--- Do NOT call ArraySetAsSeries on these const arrays: the flag is
   //--- unreliable here and a silent failure draws every level at the
   //--- oldest bar on the chart. Resolve indices explicitly instead.
   bool asSeries = ArrayGetAsSeries(time);

   //--- rebuild only when a new bar appeared
   if(rates_total != g_scannedBars)
     {
      g_scannedBars = rates_total;
      RebuildAll(time, high, low, rates_total, asSeries);
      ChartRedraw(0);
     }

   //--- breakout check on the closed bar
   if(InpAlertBreakout)
     {
      datetime t0 = time[RawIdx(rates_total, 0, asSeries)];
      double   c1 = close[RawIdx(rates_total, 1, asSeries)];

      for(int s = 0; s < 3; s++)
        {
         if(!g_cfg[s].on || !g_state[s].active)
            continue;

         double hi = g_state[s].hi;
         double lo = g_state[s].lo;

         int side = 0;
         if(c1 > hi)
            side = 1;
         else if(c1 < lo)
            side = -1;

         if(side == 0)
            continue;

         if(g_lastAlertTime == t0 && g_lastAlertSide == side)
            continue;

         g_lastAlertTime = t0;
         g_lastAlertSide = side;

         string dir = (side > 0 ? "above the high" : "below the low");
         string msg = _Symbol + " " + g_cfg[s].name + " range breakout: " +
                      PriceToStr(c1) + " closed " + dir +
                      " (" + PriceToStr(lo) + " / " + PriceToStr(hi) + ")";

         if(InpAlertPopup)
            Alert(msg);
         if(InpAlertSound)
            PlaySound("alert.wav");
         if(InpAlertPush)
            SendNotification(msg);
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
