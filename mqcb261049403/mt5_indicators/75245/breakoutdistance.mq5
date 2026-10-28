//+------------------------------------------------------------------+
//|                                             BreakoutDistance.mq5 |
//|                                                                  |
//|  Donchian channel plus a panel that answers one question:        |
//|  HOW FAR IS PRICE FROM TRIGGERING A BREAKOUT?                    |
//|                                                                  |
//|  The channel itself is ordinary. What this indicator adds is the |
//|  distance from the current price to each channel edge, shown at  |
//|  the same time in three units:                                   |
//|      - price      (how many dollars / points away)               |
//|      - ATR        (how far in units of current volatility)       |
//|       - a bar      (visual proximity, filled = close to trigger) |
//|                                                                  |
//|  Distance in price alone is misleading: $8 away from a breakout  |
//|  is far in a quiet market and close in a fast one. Dividing by   |
//|  ATR makes the number comparable across sessions, symbols and    |
//|  volatility regimes, which is the whole point of the panel.      |
//|                                                                  |
//|  The channel is built from CLOSED bars only (Shift >= 1), so the |
//|  levels never repaint. What you see now is what you saw when the |
//|  bar closed.                                                     |
//|                                                                  |
//|  No DLL, no external files, no trading logic. Display only.      |
//+------------------------------------------------------------------+
#property copyright "WylieDev"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Donchian channel with a live breakout-distance panel."
#property description "Shows how far price is from the upper and lower channel"
#property description "edge in price, in ATR units and as a proximity bar."
#property description "Closed-bar calculation, no repaint. Display only."

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

//--- plot 1: upper channel
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- plot 2: lower channel
#property indicator_label2  "Lower"
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- plot 3: midline
#property indicator_label3  "Mid"
#property indicator_type3   DRAW_LINE
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

//+------------------------------------------------------------------+
//| Inputs                                                            |
//+------------------------------------------------------------------+
input group "=== Channel ==="
input int    InpPeriod        = 60;             // Donchian period (bars)
input int    InpShift         = 1;              // Bars to skip (1 = closed bars only, no repaint)
input color  InpUpperColor    = clrDodgerBlue;  // Upper channel colour
input color  InpLowerColor    = clrTomato;      // Lower channel colour
input color  InpMidColor      = clrDimGray;     // Midline colour
input bool   InpShowMid       = true;           // Show midline

input group "=== Volatility reference ==="
input int    InpATRPeriod     = 14;             // ATR period used to scale the distance

input group "=== Panel ==="
input bool   InpShowPanel     = true;           // Show the distance panel
input ENUM_BASE_CORNER InpCorner = CORNER_LEFT_UPPER; // Panel corner
input int    InpPanelX        = 12;             // Panel X offset (px)
input int    InpPanelY        = 22;             // Panel Y offset (px)
input int    InpFontSize      = 9;              // Font size
input string InpFontName      = "Consolas";     // Font (a monospaced font keeps columns aligned)
input color  InpTextColor     = clrGainsboro;   // Normal text colour
input color  InpNearColor     = clrGold;        // Colour when within InpNearATR of a trigger
input color  InpVeryNearColor = clrOrangeRed;   // Colour when within InpVeryNearATR of a trigger
input color  InpPanelBgColor  = clrBlack;       // Panel background colour
input bool   InpPanelBg       = true;           // Draw a panel background

input group "=== Proximity thresholds (in ATR units) ==="
input double InpNearATR       = 1.0;            // "near"      : distance below this many ATR
input double InpVeryNearATR   = 0.5;            // "very near" : distance below this many ATR

input group "=== Alerts (optional, all default OFF) ==="
input bool   InpAlertPopup    = false;          // Popup alert when a trigger gets very near
input bool   InpAlertPush     = false;          // Push notification to the mobile terminal
input bool   InpAlertOncePerBar = true;         // At most one alert per bar

//+------------------------------------------------------------------+
//| Globals                                                           |
//+------------------------------------------------------------------+
double   g_upper[];
double   g_lower[];
double   g_mid[];

int      g_atrHandle = INVALID_HANDLE;
string   g_prefix    = "";        // unique object prefix for this instance
datetime g_lastAlertBar = 0;

#define ROW_COUNT 8

//+------------------------------------------------------------------+
//| Helpers                                                           |
//+------------------------------------------------------------------+

//--- one text row of the panel
void PanelRow(const int index, const string text, const color clr)
  {
   string name = g_prefix + "row" + IntegerToString(index);

   if(ObjectFind(0, name) < 0)
     {
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
         return;
      ObjectSetInteger(0, name, OBJPROP_CORNER,     InpCorner);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
      ObjectSetInteger(0, name, OBJPROP_BACK,       false);
     }

   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, InpPanelX + 6);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, InpPanelY + 6 + index * (InpFontSize + 7));
   ObjectSetInteger(0, name, OBJPROP_COLOR,     clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,  InpFontSize);
   ObjectSetString (0, name, OBJPROP_FONT,      InpFontName);
   ObjectSetString (0, name, OBJPROP_TEXT,      text);
  }

//--- panel background
void PanelBackground()
  {
   if(!InpPanelBg)
      return;

   string name = g_prefix + "bg";

   if(ObjectFind(0, name) < 0)
     {
      if(!ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
         return;
      ObjectSetInteger(0, name, OBJPROP_CORNER,     InpCorner);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
      ObjectSetInteger(0, name, OBJPROP_BACK,       false);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_WIDTH,      1);
     }

   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, InpPanelX);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, InpPanelY);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,     (int)(InpFontSize * 24));
   ObjectSetInteger(0, name, OBJPROP_YSIZE,     ROW_COUNT * (InpFontSize + 7) + 14);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,   InpPanelBgColor);
   ObjectSetInteger(0, name, OBJPROP_COLOR,     InpTextColor);
  }

//--- a 10-cell proximity bar. Full = at the trigger, empty = one ATR or more away.
string ProximityBar(const double distATR)
  {
   double d = distATR;
   if(d < 0.0) d = 0.0;
   if(d > 1.0) d = 1.0;

   int filled = (int)MathRound((1.0 - d) * 10.0);
   if(filled < 0)  filled = 0;
   if(filled > 10) filled = 10;

   string bar = "";
   for(int i = 0; i < 10; i++)
      bar += (i < filled ? "|" : ".");
   return(bar);
  }

//--- colour for a given distance
color DistanceColor(const double distATR)
  {
   if(distATR <= InpVeryNearATR) return(InpVeryNearColor);
   if(distATR <= InpNearATR)     return(InpNearColor);
   return(InpTextColor);
  }

//--- remove every object this instance created
void PanelDelete()
  {
   ObjectsDeleteAll(0, g_prefix);
  }

//+------------------------------------------------------------------+
//| OnInit                                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpPeriod < 2)
     {
      Print("BreakoutDistance: InpPeriod must be >= 2");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpShift < 0)
     {
      Print("BreakoutDistance: InpShift must be >= 0 (1 is recommended: closed bars only)");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpATRPeriod < 1)
     {
      Print("BreakoutDistance: InpATRPeriod must be >= 1");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpVeryNearATR > InpNearATR)
     {
      Print("BreakoutDistance: InpVeryNearATR must not be greater than InpNearATR");
      return(INIT_PARAMETERS_INCORRECT);
     }

   SetIndexBuffer(0, g_upper, INDICATOR_DATA);
   SetIndexBuffer(1, g_lower, INDICATOR_DATA);
   SetIndexBuffer(2, g_mid,   INDICATOR_DATA);

   PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpUpperColor);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpLowerColor);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, InpMidColor);

   int drawBegin = InpPeriod + InpShift;
   for(int p = 0; p < 3; p++)
     {
      PlotIndexSetInteger(p, PLOT_DRAW_BEGIN, drawBegin);
      PlotIndexSetDouble(p, PLOT_EMPTY_VALUE, EMPTY_VALUE);
     }

   if(!InpShowMid)
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);

   IndicatorSetString(INDICATOR_SHORTNAME,
                      StringFormat("BreakoutDistance(%d,%d)", InpPeriod, InpShift));
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   g_atrHandle = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
   if(g_atrHandle == INVALID_HANDLE)
     {
      Print("BreakoutDistance: failed to create the ATR handle, error ", GetLastError());
      return(INIT_FAILED);
     }

   //--- unique prefix so several copies on one chart never fight over objects
   g_prefix = StringFormat("BD_%d_%d_", InpPeriod, (int)ChartID());

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| OnDeinit                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   PanelDelete();
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| OnCalculate                                                       |
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
   int needed = InpPeriod + InpShift + 1;
   if(rates_total < needed)
      return(0);

   //--- where to (re)start. The last already-calculated bar is recomputed
   //    because it may still be forming.
   int start = (prev_calculated > 0) ? prev_calculated - 1 : 0;
   if(start < 0)
      start = 0;

   for(int i = start; i < rates_total; i++)
     {
      int last = i - InpShift;                 // newest bar included in the window
      int first = last - InpPeriod + 1;        // oldest bar included in the window

      if(first < 0 || last < 0)
        {
         g_upper[i] = EMPTY_VALUE;
         g_lower[i] = EMPTY_VALUE;
         g_mid[i]   = EMPTY_VALUE;
         continue;
        }

      double hh = high[first];
      double ll = low[first];
      for(int k = first + 1; k <= last; k++)
        {
         if(high[k] > hh) hh = high[k];
         if(low[k]  < ll) ll = low[k];
        }

      g_upper[i] = hh;
      g_lower[i] = ll;
      g_mid[i]   = (hh + ll) * 0.5;
     }

   //--- panel: only on the newest bar, and only if there is something to show
   if(InpShowPanel && rates_total > 0)
      UpdatePanel(rates_total, close, time);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Panel update                                                      |
//+------------------------------------------------------------------+
void UpdatePanel(const int rates_total, const double &close[], const datetime &time[])
  {
   int idx = rates_total - 1;
   if(idx < 0)
      return;

   double up = g_upper[idx];
   double dn = g_lower[idx];
   if(up == EMPTY_VALUE || dn == EMPTY_VALUE || up <= 0.0 || dn <= 0.0)
      return;

   //--- current price. Bid is used so the number matches what a sell fill sees;
   //    if the tick is unavailable we fall back to the last close.
   double price = close[idx];
   MqlTick tick;
   if(SymbolInfoTick(_Symbol, tick) && tick.bid > 0.0)
      price = tick.bid;

   //--- ATR of the last closed bar
   double atrArr[];
   double atr = 0.0;
   if(CopyBuffer(g_atrHandle, 0, InpShift, 1, atrArr) == 1)
      atr = atrArr[0];

   double distUp = up - price;         // to the BUY trigger
   double distDn = price - dn;         // to the SELL trigger
   if(distUp < 0.0) distUp = 0.0;      // price is already above the channel
   if(distDn < 0.0) distDn = 0.0;      // price is already below the channel

   bool   haveATR = (atr > 0.0);
   double upATR   = haveATR ? distUp / atr : 0.0;
   double dnATR   = haveATR ? distDn / atr : 0.0;

   color upClr = haveATR ? DistanceColor(upATR) : InpTextColor;
   color dnClr = haveATR ? DistanceColor(dnATR) : InpTextColor;

   string upBar = haveATR ? ProximityBar(upATR) : "..........";
   string dnBar = haveATR ? ProximityBar(dnATR) : "..........";

   int dg = _Digits;

   PanelBackground();

   PanelRow(0, StringFormat("BREAKOUT DISTANCE  %s %s",
                            _Symbol, StringSubstr(EnumToString(_Period), 7)), InpTextColor);
   PanelRow(1, StringFormat("channel %d bars, shift %d (closed)", InpPeriod, InpShift), InpTextColor);
   PanelRow(2, "", InpTextColor);

   PanelRow(3, StringFormat("UP  %s  %s", DoubleToString(up, dg), upBar), upClr);
   PanelRow(4, haveATR
               ? StringFormat("    away %s  (%.2f ATR)", DoubleToString(distUp, dg), upATR)
               : StringFormat("    away %s", DoubleToString(distUp, dg)), upClr);

   PanelRow(5, StringFormat("DN  %s  %s", DoubleToString(dn, dg), dnBar), dnClr);
   PanelRow(6, haveATR
               ? StringFormat("    away %s  (%.2f ATR)", DoubleToString(distDn, dg), dnATR)
               : StringFormat("    away %s", DoubleToString(distDn, dg)), dnClr);

   PanelRow(7, haveATR
               ? StringFormat("ATR(%d) %s", InpATRPeriod, DoubleToString(atr, dg))
               : "ATR unavailable", InpTextColor);

   ChartRedraw();

   //--- optional alert
   if(!haveATR)
      return;
   if(!InpAlertPopup && !InpAlertPush)
      return;

   bool nearUp = (upATR <= InpVeryNearATR);
   bool nearDn = (dnATR <= InpVeryNearATR);
   if(!nearUp && !nearDn)
      return;

   datetime barTime = time[idx];
   if(InpAlertOncePerBar && barTime == g_lastAlertBar)
      return;
   g_lastAlertBar = barTime;

   string side = nearUp ? "upper" : "lower";
   double d    = nearUp ? distUp : distDn;
   double dA   = nearUp ? upATR  : dnATR;

   string msg = StringFormat("%s %s: %s away from the %s channel edge (%.2f ATR)",
                             _Symbol, StringSubstr(EnumToString(_Period), 7),
                             DoubleToString(d, dg), side, dA);

   if(InpAlertPopup) Alert(msg);
   if(InpAlertPush)  SendNotification(msg);
  }
//+------------------------------------------------------------------+
