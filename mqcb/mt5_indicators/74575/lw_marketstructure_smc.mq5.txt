//+-------------------------------------------------------------------+
//| LW_MarketStructure_SMC.mq5                                        |
//| SMC Market Structure — Swing H/L + BOS + CHoCH                    |
//| Author : Yeoh Joo Yam | Display: Lonely Wolf                      |
//| 2026-07-02 v1.00                                                  |
//|                                                                   |
//| - Swing High/Low via N-bar fractal (InpSwingN each side).         |
//| - BOS  (Break of Structure)  = close breaks last swing in the     |
//|   direction of the current trend  -> continuation (green).        |
//| - CHoCH (Change of Character) = close breaks last swing against   |
//|   the current trend             -> possible reversal (red).       |
//| - QML (Quasimodo) = on a CHoCH, dotted level at the left-shoulder |
//|   swing (sell=prev high / buy=prev low) = retrace entry level.    |
//+-------------------------------------------------------------------+
#property copyright "Lonely Wolf"
#property version   "1.10"
#property description "SMC Market Structure: fractal swing H/L + BOS (continuation) + CHoCH (reversal) + Order Blocks + FVG + QML (Quasimodo) level on reversals. Close-confirmed. All drawn on the chart."
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- Plot 0: Swing High marker (down arrow at the high)
#property indicator_label1  "Swing High"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_width1  1

//--- Plot 1: Swing Low marker (up arrow at the low)
#property indicator_label2  "Swing Low"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrLimeGreen
#property indicator_width2  1

//============================== INPUTS ===============================
input int    InpSwingN        = 5;            // Fractal bars each side (swing sensitivity; higher = fewer/bigger)
input bool   InpBreakOnClose  = true;         // Confirm break on candle CLOSE (false = wick)
input int    InpMaxBars       = 1500;         // How many recent bars to analyze
input color  InpBOSColor      = clrLimeGreen; // BOS = continuation
input color  InpCHoCHColor    = clrRed;       // CHoCH = reversal
input bool   InpShowLines     = true;         // Draw the broken-level line
input bool   InpShowLabels    = true;         // Draw BOS / CHoCH text
input bool   InpShowFVG       = true;         // Draw Fair Value Gaps (3-candle imbalance)
input color  InpFVGColor      = clrGoldenrod; // FVG fill color (brighter = easier to see on black)
input bool   InpShowOB        = true;         // Draw Order Blocks (last opposite candle before a break)
input color  InpOBBullColor   = clrLimeGreen; // Bullish Order Block
input color  InpOBBearColor   = clrRed;       // Bearish Order Block
input bool   InpShowQML        = true;         // Draw QML (Quasimodo) level on CHoCH reversals
input color  InpQMLColor       = clrMagenta;   // QML level (left-shoulder) dotted line

//============================== BUFFERS ==============================
double SwingHighBuf[];
double SwingLowBuf[];

//============================== STATE ================================
const string OBJ_PREFIX = "LWMS_";
datetime g_lastBarTime = 0;

//============================== INIT =================================
int OnInit()
  {
   SetIndexBuffer(0, SwingHighBuf, INDICATOR_DATA);
   SetIndexBuffer(1, SwingLowBuf,  INDICATOR_DATA);

   PlotIndexSetInteger(0, PLOT_ARROW, 234);   // down arrow, sits at swing high
   PlotIndexSetInteger(1, PLOT_ARROW, 233);   // up arrow,   sits at swing low
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);

   ArraySetAsSeries(SwingHighBuf, false);
   ArraySetAsSeries(SwingLowBuf,  false);

   IndicatorSetString(INDICATOR_SHORTNAME, "LW Market Structure (SMC)");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, OBJ_PREFIX);
  }

//============================== DRAW HELPERS =========================
void DrawBreak(const datetime &time[], int fromBar, int atBar,
               double level, bool bullish, bool isBOS)
  {
   color clr   = isBOS ? InpBOSColor : InpCHoCHColor;
   string tag  = isBOS ? "BOS" : "CHoCH";
   string arr  = bullish ? " ^" : " v";
   string base = OBJ_PREFIX + (string)atBar;

   if(InpShowLines)
     {
      string ln = base + "_ln";
      ObjectCreate(0, ln, OBJ_TREND, 0, time[fromBar], level, time[atBar], level);
      ObjectSetInteger(0, ln, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, ln, OBJPROP_STYLE, isBOS ? STYLE_SOLID : STYLE_DASH);
      ObjectSetInteger(0, ln, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, ln, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, ln, OBJPROP_BACK, true);
      ObjectSetInteger(0, ln, OBJPROP_SELECTABLE, false);
     }
   if(InpShowLabels)
     {
      string tx = base + "_tx";
      ObjectCreate(0, tx, OBJ_TEXT, 0, time[atBar], level);
      ObjectSetString(0, tx, OBJPROP_TEXT, tag + arr);
      ObjectSetInteger(0, tx, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, tx, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, tx, OBJPROP_ANCHOR, bullish ? ANCHOR_LOWER : ANCHOR_UPPER);
      ObjectSetInteger(0, tx, OBJPROP_SELECTABLE, false);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawBox(string name, datetime t1, double p1, datetime t2, double p2, color clr, bool fill)
  {
   ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FILL, fill);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

// QML (Quasimodo): after a CHoCH, the "left shoulder" swing = the entry level.
// Bearish QML (sell) = left-shoulder HIGH ; Bullish QML (buy) = left-shoulder LOW.
// Dotted horizontal line extended right = the level price may retrace into.
void DrawQML(const datetime &time[], int shoulderBar, int atBar, double level, bool bullish)
  {
   string base = OBJ_PREFIX + "qml" + (string)atBar;
   string ln   = base + "_ln";
   ObjectCreate(0, ln, OBJ_TREND, 0, time[shoulderBar], level, time[atBar], level);
   ObjectSetInteger(0, ln, OBJPROP_COLOR, InpQMLColor);
   ObjectSetInteger(0, ln, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, ln, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, ln, OBJPROP_RAY_RIGHT, true);   // extend right = retrace target
   ObjectSetInteger(0, ln, OBJPROP_BACK, false);
   ObjectSetInteger(0, ln, OBJPROP_SELECTABLE, false);

   string tx = base + "_tx";
   ObjectCreate(0, tx, OBJ_TEXT, 0, time[atBar], level);
   ObjectSetString(0, tx, OBJPROP_TEXT, bullish ? "QML (buy)" : "QML (sell)");
   ObjectSetInteger(0, tx, OBJPROP_COLOR, InpQMLColor);
   ObjectSetInteger(0, tx, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, tx, OBJPROP_ANCHOR, bullish ? ANCHOR_UPPER : ANCHOR_LOWER);
   ObjectSetInteger(0, tx, OBJPROP_SELECTABLE, false);
  }

//============================== ON CALCULATE =========================
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
   if(rates_total < InpSwingN * 2 + 5)
      return rates_total;

// Only recompute on a new bar (breaks are close-confirmed anyway)
   if(time[rates_total - 1] == g_lastBarTime && prev_calculated > 0)
      return rates_total;
   g_lastBarTime = time[rates_total - 1];

// Reset our drawings + buffers for the analysis window
   ObjectsDeleteAll(0, OBJ_PREFIX);
   for(int i = 0; i < rates_total; i++)
     {
      SwingHighBuf[i] = 0.0;
      SwingLowBuf[i] = 0.0;
     }

   int start = MathMax(InpSwingN, rates_total - InpMaxBars);

//--- Pass 1: mark fractal swing highs / lows
   for(int i = start; i < rates_total - InpSwingN; i++)
     {
      bool isHigh = true, isLow = true;
      for(int k = 1; k <= InpSwingN; k++)
        {
         if(high[i] <= high[i - k] || high[i] <= high[i + k])
            isHigh = false;
         if(low[i]  >= low[i - k]  || low[i]  >= low[i + k])
            isLow  = false;
        }
      if(isHigh)
         SwingHighBuf[i] = high[i];
      if(isLow)
         SwingLowBuf[i]  = low[i];
     }

//--- Pass 1b: Fair Value Gaps (3-candle imbalance, drawn over the gap)
   if(InpShowFVG)
     {
      for(int i = start + 1; i < rates_total - 1; i++)
        {
         if(low[i + 1] > high[i - 1])        // bullish FVG (gap up)
            DrawBox(OBJ_PREFIX + "fvg" + (string)i, time[i - 1], high[i - 1],
                    time[i + 1], low[i + 1], InpFVGColor, true);
         else
            if(high[i + 1] < low[i - 1])   // bearish FVG (gap down)
               DrawBox(OBJ_PREFIX + "fvg" + (string)i, time[i - 1], low[i - 1],
                       time[i + 1], high[i + 1], InpFVGColor, true);
        }
     }

//--- Pass 2: BOS / CHoCH state machine
   int    trend      = 0;      //  1 = up, -1 = down, 0 = neutral
   double refHigh    = 0.0;    // last swing-high level to break (bullish)
   double refLow     = 0.0;    // last swing-low  level to break (bearish)
   int    refHighBar = -1, refLowBar = -1;
   bool   haveHigh   = false, haveLow = false;
// "left shoulder" = the swing BEFORE the current one (used for QML)
   double prevHigh   = 0.0, prevLow = 0.0;
   int    prevHighBar= -1, prevLowBar = -1;

   for(int i = start + InpSwingN; i < rates_total; i++)
     {
      int j = i - InpSwingN;                    // swing confirmed at bar i sits at bar j
      if(SwingHighBuf[j] > 0.0)
        {
         prevHigh = refHigh;
         prevHighBar = refHighBar;
         refHigh = high[j];
         refHighBar = j;
         haveHigh = true;
        }
      if(SwingLowBuf[j]  > 0.0)
        {
         prevLow  = refLow;
         prevLowBar  = refLowBar;
         refLow  = low[j];
         refLowBar  = j;
         haveLow  = true;
        }

      double upPx   = InpBreakOnClose ? close[i] : high[i];
      double downPx = InpBreakOnClose ? close[i] : low[i];

      // Bullish break of the last swing high
      if(haveHigh && upPx > refHigh)
        {
         bool isBOS = (trend != -1);           // up-break with up/neutral trend = BOS; against down trend = CHoCH
         DrawBreak(time, refHighBar, i, refHigh, true, isBOS);
         if(InpShowOB)                          // Bullish OB = last DOWN candle before this up-break
            for(int b = i; b > refHighBar; b--)
               if(close[b] < open[b])
                 { DrawBox(OBJ_PREFIX+"ob"+(string)b, time[b], high[b], time[i], low[b], InpOBBullColor, true); break; }
         // Bullish QML: CHoCH up (reversal from down) -> left shoulder = prev swing LOW = buy level
         if(InpShowQML && !isBOS && prevLowBar >= 0)
            DrawQML(time, prevLowBar, i, prevLow, true);
         trend    = 1;
         haveHigh = false;                      // level consumed; next swing high sets a new one
        }
      // Bearish break of the last swing low
      else
         if(haveLow && downPx < refLow)
           {
            bool isBOS = (trend != 1);             // down-break with down/neutral trend = BOS; against up trend = CHoCH
            DrawBreak(time, refLowBar, i, refLow, false, isBOS);
            if(InpShowOB)                          // Bearish OB = last UP candle before this down-break
               for(int b = i; b > refLowBar; b--)
                  if(close[b] > open[b])
                    { DrawBox(OBJ_PREFIX+"ob"+(string)b, time[b], high[b], time[i], low[b], InpOBBearColor, true); break; }
            // Bearish QML: CHoCH down (reversal from up) -> left shoulder = prev swing HIGH = sell level
            if(InpShowQML && !isBOS && prevHighBar >= 0)
               DrawQML(time, prevHighBar, i, prevHigh, false);
            trend   = -1;
            haveLow = false;
           }
     }

   return rates_total;
  }
//+------------------------------------------------------------------+
