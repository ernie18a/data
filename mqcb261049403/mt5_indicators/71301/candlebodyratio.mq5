//+------------------------------------------------------------------+
//|                                              CandleBodyRatio.mq5 |
//|                                    Copyright 2025, Hammad Dilber |
//|                           https://www.mql5.com/en/users/homirana |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2025, Hammad Dilber"
#property link        "https://www.mql5.com/en/users/homirana"
#property version     "2.00"
#property description "Candle Body-to-Wick Ratio Strength Meter with Heatmap"

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- Input parameters
input group "=== Panel Position ==="
input int    InpPanelX        = 20;       // Panel X Position
input int    InpPanelY        = 30;       // Panel Y Position

input group "=== Analysis Settings ==="
input int    InpLookback      = 14;       // Lookback Period (Avg Calculation)
input int    InpHeatmapBars   = 20;       // Heatmap Candle Count

input group "=== Signal Thresholds ==="
input double InpStrongBody    = 0.70;     // Strong Body Ratio (>=)
input double InpWeakBody      = 0.30;     // Weak/Indecision Ratio (<=)

input group "=== Colors ==="
input color  InpBullColor     = clrLime;       // Bullish Color
input color  InpBearColor     = clrRed;        // Bearish Color
input color  InpNeutralColor  = clrGray;       // Neutral / Indecision Color
input color  InpPanelBG       = C'15,15,20';   // Panel Background
input color  InpBorderColor   = C'60,60,80';   // Panel Border Color
input color  InpTextColor     = clrWhite;       // Main Text Color
input color  InpDimColor      = C'200,200,220'; // Dim Label Color

input group "=== Font ==="
input int    InpFontSize      = 9;        // Font Size

input group "=== Alerts ==="
input bool   InpShowAlert     = true;     // Enable Alerts on Strong Signal

//--- Constants
#define OBJ_PREFIX   "CBR_"
#define PANEL_W      240
#define PANEL_H      340
#define COL_VAL      130

//--- Alert state
datetime g_lastAlertTime = 0;

//+------------------------------------------------------------------+
//| Helpers: ratio calculations                                      |
//+------------------------------------------------------------------+
double BodyRatio(double o, double h, double l, double c)
{
   double r = h - l;
   return (r <= 0.0) ? 0.0 : MathAbs(c - o) / r;
}
double UpperWickRatio(double o, double h, double l, double c)
{
   double r = h - l;
   return (r <= 0.0) ? 0.0 : (h - MathMax(o,c)) / r;
}
double LowerWickRatio(double o, double h, double l, double c)
{
   double r = h - l;
   return (r <= 0.0) ? 0.0 : (MathMin(o,c) - l) / r;
}

//+------------------------------------------------------------------+
//| Pressure label                                                   |
//+------------------------------------------------------------------+
string PressureLabel(double body, double uw, double lw, bool bull)
{
   if(body >= InpStrongBody)
      return bull ? "STRONG BUY  ▲" : "STRONG SELL ▼";
   if(body <= InpWeakBody)
   {
      if(uw > lw * 1.5) return "SELL PRESSURE";
      if(lw > uw * 1.5) return "BUY PRESSURE";
      return "INDECISION  ─";
   }
   return bull ? "MODERATE BUY" : "MODERATE SELL";
}

//+------------------------------------------------------------------+
//| Map body ratio (0-1) to a gradient color                        |
//| Bull candles: dark green → bright lime                          |
//| Bear candles: dark red   → bright red                           |
//+------------------------------------------------------------------+
color HeatColor(double body, bool bull)
{
   // clamp
   body = MathMax(0.0, MathMin(1.0, body));

   if(bull)
   {
      // dark green (20,60,20) → bright lime (0,255,80)
      int r = (int)(20  + body * (0   - 20));
      int g = (int)(60  + body * (255 - 60));
      int b = (int)(20  + body * (80  - 20));
      return (color)((r & 0xFF) | ((g & 0xFF) << 8) | ((b & 0xFF) << 16));
   }
   else
   {
      // dark red (60,10,10) → bright red (255,30,30)
      int r = (int)(60  + body * (255 - 60));
      int g = (int)(10  + body * (30  - 10));
      int b = (int)(10  + body * (30  - 10));
      return (color)((r & 0xFF) | ((g & 0xFF) << 8) | ((b & 0xFF) << 16));
   }
}

//+------------------------------------------------------------------+
//| Draw / update a rectangle label (used for heatmap cells & bg)   |
//+------------------------------------------------------------------+
void SetRect(string name, int x, int y, int w, int h, color bg, color border=clrNONE, bool back=false)
{
   string obj = OBJ_PREFIX + name;
   if(ObjectFind(0, obj) < 0)
      ObjectCreate(0, obj, OBJ_RECTANGLE_LABEL, 0, 0, 0);

   ObjectSetInteger(0, obj, OBJPROP_CORNER,      CORNER_LEFT_UPPER);
   ObjectSetInteger(0, obj, OBJPROP_XDISTANCE,   x);
   ObjectSetInteger(0, obj, OBJPROP_YDISTANCE,   y);
   ObjectSetInteger(0, obj, OBJPROP_XSIZE,       w);
   ObjectSetInteger(0, obj, OBJPROP_YSIZE,       h);
   ObjectSetInteger(0, obj, OBJPROP_BGCOLOR,     bg);
   ObjectSetInteger(0, obj, OBJPROP_BORDER_TYPE, (border == clrNONE) ? BORDER_FLAT : BORDER_FLAT);
   ObjectSetInteger(0, obj, OBJPROP_COLOR,       (border == clrNONE) ? bg : border);
   ObjectSetInteger(0, obj, OBJPROP_WIDTH,       1);
   ObjectSetInteger(0, obj, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0, obj, OBJPROP_HIDDEN,      true);
   ObjectSetInteger(0, obj, OBJPROP_BACK,        back);
   ObjectSetInteger(0, obj, OBJPROP_ZORDER,      2);
}

//+------------------------------------------------------------------+
//| Draw / update a text label                                      |
//+------------------------------------------------------------------+
void SetLabel(string name, string text, int x, int y, color clr, int fs=-1)
{
   string obj = OBJ_PREFIX + name;
   if(ObjectFind(0, obj) < 0)
   {
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN,     true);
   }
   ObjectSetString(0,  obj, OBJPROP_TEXT,      text);
   ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, obj, OBJPROP_COLOR,     clr);
   ObjectSetString(0,  obj, OBJPROP_FONT,      "Consolas");
   ObjectSetInteger(0, obj, OBJPROP_FONTSIZE,  (fs < 0 ? InpFontSize : fs));
   ObjectSetInteger(0, obj, OBJPROP_BACK,      false);
   ObjectSetInteger(0, obj, OBJPROP_ZORDER,    2);
}

//+------------------------------------------------------------------+
//| Draw the heatmap strip (last N candles, oldest→newest L→R)      |
//+------------------------------------------------------------------+
void DrawHeatmap(const double &open[],
                 const double &high[],
                 const double &low[],
                 const double &close[],
                 int total,
                 int baseX, int baseY)
{
   int n      = MathMin(InpHeatmapBars, total);
   int startX = baseX + 10;
   // Each cell = one thick unicode block character
   // We draw each candle as a separate label so it gets its own color
   int cellW  = (PANEL_W - 20) / InpHeatmapBars;

   for(int i = 0; i < n; i++)
   {
      int    idx  = n - 1 - i;
      double o    = open[idx], h = high[idx], l = low[idx], c = close[idx];
      bool   bull = (c >= o);
      double body = BodyRatio(o, h, l, c);
      color  clr  = HeatColor(body, bull);

      int cx = startX + i * cellW;

      // Pure text label — "█" has zero shadow/border
      string cellName = "HM_" + IntegerToString(i);
      SetLabel(cellName, "█", cx, baseY, clr, 14);
   }
}

//+------------------------------------------------------------------+
//| Main dashboard update                                           |
//+------------------------------------------------------------------+
void UpdateDashboard(const double &open[],
                     const double &high[],
                     const double &low[],
                     const double &close[],
                     int total)
{
   if(total < InpLookback + 1) return;

   //--- Panel origin
   int PX = InpPanelX;
   int PY = InpPanelY;
   int X  = PX + 10;          // inner left padding
   int Y  = PY + 8;           // inner top padding
   int LH = 20;               // line height

   //--- Current candle data
   double o = open[0], h = high[0], l = low[0], c = close[0];
   bool   bull = (c >= o);

   double body = BodyRatio(o, h, l, c);
   double uw   = UpperWickRatio(o, h, l, c);
   double lw   = LowerWickRatio(o, h, l, c);

   //--- Average body over lookback
   double avgBody = 0.0;
   int    bullCount = 0, bearCount = 0;
   for(int i = 1; i <= InpLookback && i < total; i++)
   {
      avgBody += BodyRatio(open[i], high[i], low[i], close[i]);
      if(close[i] >= open[i]) bullCount++; else bearCount++;
   }
   avgBody /= InpLookback;

   //--- Signal labels & colors
   string pressure = PressureLabel(body, uw, lw, bull);

   color pressClr = InpNeutralColor;
   if(StringFind(pressure, "BUY")  >= 0) pressClr = InpBullColor;
   if(StringFind(pressure, "SELL") >= 0) pressClr = InpBearColor;

   color candleClr  = bull ? InpBullColor : InpBearColor;
   color convClr    = (body >= InpStrongBody) ? pressClr :
                      (body <= InpWeakBody)   ? InpNeutralColor : InpTextColor;

   //--- Dominance bar (bull vs bear count in lookback)
   int   domBull  = (int)MathRound((double)bullCount / InpLookback * 10.0);
   string domBar  = "";
   for(int b = 0; b < 10; b++)
      domBar += (b < domBull ? "▓" : "░");

   //--- Trend vs Avg
   string trendTxt;
   color  trendClr;
   if(body > avgBody + 0.10)      { trendTxt = "ABOVE AVG ↑"; trendClr = InpBullColor; }
   else if(body < avgBody - 0.10) { trendTxt = "BELOW AVG ↓"; trendClr = InpBearColor; }
   else                           { trendTxt = "NEAR AVG  ─"; trendClr = InpNeutralColor; }

   //--- Draw panel background (BACK=false = floats on chart, not behind candles)
   //    BG_OUTER drawn first => lower z-order => sits behind BG_INNER and labels
   string bgOuter = OBJ_PREFIX + "BG_OUTER";
   if(ObjectFind(0, bgOuter) < 0) ObjectCreate(0, bgOuter, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bgOuter, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bgOuter, OBJPROP_XDISTANCE, PX - 3);
   ObjectSetInteger(0, bgOuter, OBJPROP_YDISTANCE, PY - 3);
   ObjectSetInteger(0, bgOuter, OBJPROP_XSIZE,     PANEL_W + 6);
   ObjectSetInteger(0, bgOuter, OBJPROP_YSIZE,     PANEL_H + 6);
   ObjectSetInteger(0, bgOuter, OBJPROP_BGCOLOR,   InpBorderColor);
   ObjectSetInteger(0, bgOuter, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bgOuter, OBJPROP_COLOR,     InpBorderColor);
   ObjectSetInteger(0, bgOuter, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, bgOuter, OBJPROP_HIDDEN,    true);
   ObjectSetInteger(0, bgOuter, OBJPROP_BACK,      false);
   ObjectSetInteger(0, bgOuter, OBJPROP_ZORDER,    0);

   string bgInner = OBJ_PREFIX + "BG_INNER";
   if(ObjectFind(0, bgInner) < 0) ObjectCreate(0, bgInner, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bgInner, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bgInner, OBJPROP_XDISTANCE, PX);
   ObjectSetInteger(0, bgInner, OBJPROP_YDISTANCE, PY);
   ObjectSetInteger(0, bgInner, OBJPROP_XSIZE,     PANEL_W);
   ObjectSetInteger(0, bgInner, OBJPROP_YSIZE,     PANEL_H);
   ObjectSetInteger(0, bgInner, OBJPROP_BGCOLOR,   InpPanelBG);
   ObjectSetInteger(0, bgInner, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bgInner, OBJPROP_COLOR,     InpPanelBG);
   ObjectSetInteger(0, bgInner, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, bgInner, OBJPROP_HIDDEN,    true);
   ObjectSetInteger(0, bgInner, OBJPROP_BACK,      false);
   ObjectSetInteger(0, bgInner, OBJPROP_ZORDER,    1);

   //============================================================
   //  SECTION 1 — HEADER
   //============================================================
   // colors used throughout
   color clrLabelKey = C'180,200,255';   // soft blue-white  — key labels (Direction, Body…)
   color clrSecHdr   = C'255,210,80';    // warm yellow      — section headers
   color clrSepLine  = C'70,80,110';     // visible separator
   color clrSubtitle = C'160,180,210';   // subtitle / dim info

   SetLabel("Title",    "  CANDLE BODY RATIO v2",   X,  Y,  clrWhite, InpFontSize+1);
   SetLabel("SubTitle", "",                           X,  Y,  clrWhite, 1); // hidden — removed

   // separator line
   SetRect("Sep1", PX+5, Y+LH-4, PANEL_W-10, 1, clrSepLine);

   //============================================================
   //  SECTION 2 — CURRENT CANDLE
   //============================================================
   int S2 = Y + LH + 4;

   SetLabel("S2hdr",    "▸ CURRENT CANDLE",          X, S2,       clrSecHdr, InpFontSize);

   SetLabel("CandleLbl","  Direction :",              X, S2+LH,   clrLabelKey);
   SetLabel("CandleVal", bull ? "▲ BULLISH" : "▼ BEARISH",
                                                      X+COL_VAL, S2+LH,   candleClr);

   SetLabel("BodyLbl",  "  Body     :",              X, S2+LH*2, clrLabelKey);
   SetLabel("BodyVal",  DoubleToString(body*100,1)+"%",
                                                      X+COL_VAL, S2+LH*2, candleClr);

   SetLabel("UWickLbl", "  Up Wick  :",              X, S2+LH*3, clrLabelKey);
   SetLabel("UWickVal", DoubleToString(uw*100,1)+"%",X+COL_VAL, S2+LH*3, clrOrange);

   SetLabel("LWickLbl", "  Lo Wick  :",              X, S2+LH*4, clrLabelKey);
   SetLabel("LWickVal", DoubleToString(lw*100,1)+"%",X+COL_VAL, S2+LH*4, clrDodgerBlue);

   // Conviction — only bar, no text label
   int convBars = (body >= InpStrongBody) ? 8 :
                  (body >= 0.50)          ? 5 :
                  (body >= InpWeakBody)   ? 3 : 1;
   string convBar = "";
   for(int cb=0; cb<8; cb++) convBar += (cb < convBars ? "█" : "░");

   SetLabel("ConvLbl",  "  Conviction:",             X, S2+LH*5, clrLabelKey);
   SetLabel("ConvVal",  convBar,                     X+COL_VAL, S2+LH*5, convClr);

   SetRect("Sep2", PX+5, S2+LH*6+2, PANEL_W-10, 1, clrSepLine);

   //============================================================
   //  SECTION 3 — MARKET SUMMARY
   //============================================================
   int S3 = S2 + LH*6 + 10;

   SetLabel("S3hdr",    "▸ MARKET SUMMARY (" + IntegerToString(InpLookback) + " bars)",
                                                      X, S3,      clrSecHdr, InpFontSize);

   SetLabel("AvgLbl",   "  Avg Body :",              X, S3+LH,   clrLabelKey);
   SetLabel("AvgVal",   DoubleToString(avgBody*100,1)+"%",
                                                      X+COL_VAL, S3+LH,   clrWhite);

   SetLabel("TrendLbl", "  Strength :",              X, S3+LH*2, clrLabelKey);
   SetLabel("TrendVal", trendTxt,                    X+COL_VAL, S3+LH*2, trendClr);

   // Bull/Bear — label + sirf bar, koi extra object nahi
   SetLabel("DomLbl", "  Bull/Bear:", X,          S3+LH*3, clrLabelKey);
   SetLabel("DomBar", domBar,         X+COL_VAL,  S3+LH*3, clrGoldenrod);

   SetLabel("PressLbl", "  Pressure :",              X, S3+LH*4, clrLabelKey);
   SetLabel("PressVal", pressure,                    X+COL_VAL, S3+LH*4, pressClr);

   SetRect("Sep3", PX+5, S3+LH*5+2, PANEL_W-10, 1, clrSepLine);

   //============================================================
   //  SECTION 4 — HEATMAP (inside table as colored rect cells)
   //============================================================
   int S4 = S3 + LH*5 + 10;
   SetLabel("HMhdr",      "▸ HEATMAP",        X,          S4, clrSecHdr,              InpFontSize);
   SetLabel("HMdirLbl",  "oldest → newest",  X+COL_VAL-20, S4, C'120,140,170',  InpFontSize-1);
   DrawHeatmap(open, high, low, close, total, PX, S4+LH);

   // Heatmap ke neeche: simple hint
   int hmBelowY = S4 + LH + 22;
   SetLabel("HM_Hint", "brighter = stronger", X+2, hmBelowY, C'140,155,185', InpFontSize-1);

   ChartRedraw(0);

   //--- Alert
   if(InpShowAlert && body >= InpStrongBody)
   {
      datetime t = iTime(_Symbol, _Period, 0);
      if(t != g_lastAlertTime)
      {
         g_lastAlertTime = t;
         Alert(_Symbol, " ", EnumToString(_Period),
               " | ", pressure,
               " | Body: ", DoubleToString(body*100,1), "%");
      }
   }
}

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME,
      "CandleBodyRatio(" + IntegerToString(InpLookback) + ")");
   ChartRedraw(0);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, OBJ_PREFIX);
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| OnCalculate                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
{
   if(rates_total < InpLookback + 1) return 0;

   ArraySetAsSeries(open,  true);
   ArraySetAsSeries(high,  true);
   ArraySetAsSeries(low,   true);
   ArraySetAsSeries(close, true);

   UpdateDashboard(open, high, low, close, rates_total);

   return(rates_total);
}
//+------------------------------------------------------------------+