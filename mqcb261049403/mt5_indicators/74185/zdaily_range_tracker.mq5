//+------------------------------------------------------------------+
//|                                 FoxWave_DailyRangeTracker.mq5    |
//|                       Copyright Fox Wave - foxwavetrading.top    |
//|        Live Daily High/Low/Range Tracker vs Average Range        |
//+------------------------------------------------------------------+
#property copyright "Fox Wave | foxwavetrading.top"
#property link      "https://foxwavetrading.top"
#property version   "1.00"
#property description "FoxWave Daily Range Tracker - shows today's High/Low/Range in pips and how much of the average daily range has already been used."
#property indicator_chart_window
#property indicator_plots 0

//======================================================================
//  INPUTS
//======================================================================
input group "PANEL"
input int     PanelX            = 15;   // Panel X offset
input int     PanelY            = 25;   // Panel Y offset
input int     RefreshSeconds    = 2;    // Refresh interval (seconds)

input group "RANGE"
input int     ADRPeriod         = 14;   // Average Daily Range period (days)

input group "COLORS"
input color   ClrPanelBg        = C'10,12,20';     // Outer panel background
input color   ClrHeaderBg       = C'16,20,38';     // Header bar background
input color   ClrAccent         = C'255,140,0';    // Fox Wave accent (orange)
input color   ClrSymbol         = C'235,240,250';  // Symbol name text
input color   ClrHigh           = C'90,220,160';   // Today's high (green)
input color   ClrLow            = C'255,90,90';     // Today's low (red)
input color   ClrRange          = C'255,255,255';  // Range value
input color   ClrADR            = C'120,170,255';   // Average daily range value
input color   ClrLabel          = C'110,120,145';  // Small caption labels
input color   ClrTime           = C'80,92,118';    // Timestamp
input color   ClrBorder         = C'45,55,85';     // Borders
input color   ClrFooter         = C'70,80,105';    // Footer brand text
input color   ClrBarBg          = C'30,34,52';     // Usage bar background
input color   ClrBarLow         = C'90,220,160';   // Usage bar fill <60%
input color   ClrBarMid         = C'255,200,60';   // Usage bar fill 60-90%
input color   ClrBarHigh        = C'255,90,90';     // Usage bar fill >90%

//======================================================================
//  CONSTANTS
//======================================================================
#define PANEL_W      230
#define PANEL_H      218
#define FONT_MAIN    "Consolas"
#define PFX          "FWDRT_"

//======================================================================
//  GLOBALS
//======================================================================
string   g_sym;
double   g_pipSize     = 0;
double   g_todayHigh    = 0;
double   g_todayLow     = 0;
double   g_todayRangePips = 0;
double   g_adrPips      = 0;
double   g_usagePct     = 0;
datetime g_lastUpdate   = 0;
datetime g_dayStart     = 0;

//======================================================================
int OnInit()
  {
   g_sym = _Symbol;
   g_pipSize = CalcPipSize();
   DrawPanel();
   EventSetTimer(MathMax(1, RefreshSeconds));
   return INIT_SUCCEEDED;
  }

//======================================================================
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PFX);
   ChartRedraw();
  }

//======================================================================
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],const double &open[],
                const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],
                const long &volume[],const int &spread[])
  { return rates_total; }

//======================================================================
void OnTimer()
  {
   UpdateRange();
   RefreshPanel();
  }

//======================================================================
//  PIP SIZE HELPER (handles 3/5-digit brokers and JPY pairs)
//======================================================================
double CalcPipSize()
  {
   int digits = (int)SymbolInfoInteger(g_sym, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(g_sym, SYMBOL_POINT);
   if(digits == 3 || digits == 5) return point * 10;
   return point;
  }

//======================================================================
//  CORE LOGIC
//======================================================================
void UpdateRange()
  {
   if(!SymbolSelect(g_sym, true)) return;

   // Today's high/low from D1 bar 0 (current day)
   MqlRates rates[];
   if(CopyRates(g_sym, PERIOD_D1, 0, 1, rates) < 1) return;

   g_todayHigh = rates[0].high;
   g_todayLow  = rates[0].low;
   g_todayRangePips = (g_todayHigh - g_todayLow) / g_pipSize;

   // Average Daily Range over ADRPeriod previous closed days
   MqlRates histRates[];
   int copied = CopyRates(g_sym, PERIOD_D1, 1, ADRPeriod, histRates);
   if(copied > 0)
     {
      double sumRange = 0;
      for(int i=0; i<copied; i++)
         sumRange += (histRates[i].high - histRates[i].low);
      g_adrPips = (sumRange / copied) / g_pipSize;
     }

   if(g_adrPips > 0)
      g_usagePct = (g_todayRangePips / g_adrPips) * 100.0;
   else
      g_usagePct = 0;

   g_lastUpdate = TimeCurrent();
  }

//======================================================================
//  DRAW PANEL (built once)
//======================================================================
void DrawPanel()
  {
   Rect(PFX+"BG", PanelX, PanelY, PANEL_W, PANEL_H, ClrPanelBg, ClrBorder);

   Rect(PFX+"HDR", PanelX, PanelY, PANEL_W, 30, ClrHeaderBg, ClrHeaderBg);
   Rect(PFX+"HDRLINE", PanelX, PanelY+30, PANEL_W, 2, ClrAccent, ClrAccent);

   Label(PFX+"TITLE", PanelX+10, PanelY+6, "FOX WAVE", FONT_MAIN, 11, ClrAccent);
   Label(PFX+"SUB",   PanelX+10, PanelY+19, "DAILY RANGE TRACKER", FONT_MAIN, 7, ClrLabel);

   Label(PFX+"SYM", PanelX+10, PanelY+40, g_sym, FONT_MAIN, 13, ClrSymbol);

   Rect(PFX+"DIV1", PanelX+10, PanelY+62, PANEL_W-20, 1, ClrBorder, ClrBorder);

   // HIGH / LOW row (side by side)
   Label(PFX+"HIGH_LBL", PanelX+10,  PanelY+69, "TODAY HIGH", FONT_MAIN, 7, ClrLabel);
   Label(PFX+"HIGH_VAL", PanelX+10,  PanelY+80, "---", FONT_MAIN, 11, ClrHigh);

   Label(PFX+"LOW_LBL", PanelX+120, PanelY+69, "TODAY LOW", FONT_MAIN, 7, ClrLabel);
   Label(PFX+"LOW_VAL", PanelX+120, PanelY+80, "---", FONT_MAIN, 11, ClrLow);

   Rect(PFX+"DIV2", PanelX+10, PanelY+100, PANEL_W-20, 1, ClrBorder, ClrBorder);

   // RANGE TODAY
   Label(PFX+"RNG_LBL", PanelX+10, PanelY+107, "RANGE TODAY", FONT_MAIN, 7, ClrLabel);
   Label(PFX+"RNG_VAL", PanelX+10, PanelY+119, "---", FONT_MAIN, 16, ClrRange);
   Label(PFX+"RNG_PIPS", PanelX+90, PanelY+125, "pips", FONT_MAIN, 8, ClrLabel);

   // ADR
   Label(PFX+"ADR_LBL", PanelX+130, PanelY+107, "AVG RANGE", FONT_MAIN, 7, ClrLabel);
   Label(PFX+"ADR_VAL", PanelX+130, PanelY+119, "---", FONT_MAIN, 16, ClrADR);

   Rect(PFX+"DIV3", PanelX+10, PanelY+147, PANEL_W-20, 1, ClrBorder, ClrBorder);

   // USAGE %
   Label(PFX+"USE_LBL", PanelX+10, PanelY+154, "RANGE USED", FONT_MAIN, 7, ClrLabel);
   Label(PFX+"USE_VAL", PanelX+130, PanelY+153, "---", FONT_MAIN, 11, ClrRange);

   // Usage bar background + fill
   Rect(PFX+"BARBG", PanelX+10, PanelY+168, PANEL_W-20, 10, ClrBarBg, ClrBorder);
   Rect(PFX+"BARFILL", PanelX+10, PanelY+168, 1, 10, ClrBarLow, ClrBarLow);

   Rect(PFX+"DIV4", PanelX+10, PanelY+184, PANEL_W-20, 1, ClrBorder, ClrBorder);

   // Timestamp
   Label(PFX+"TIME", PanelX+10, PanelY+190, "--:--:--", FONT_MAIN, 7, ClrTime);

   // Footer brand
   Rect(PFX+"FOOTLINE", PanelX, PanelY+PANEL_H-18, PANEL_W, 1, ClrBorder, ClrBorder);
   Label(PFX+"FOOT", PanelX+10, PanelY+PANEL_H-13, "foxwavetrading.top", FONT_MAIN, 7, ClrFooter);

   ChartRedraw();
  }

//======================================================================
//  REFRESH VALUES
//======================================================================
void RefreshPanel()
  {
   int digits = (int)SymbolInfoInteger(g_sym, SYMBOL_DIGITS);

   string highTxt = (g_todayHigh > 0) ? DoubleToString(g_todayHigh, digits) : "---";
   ObjectSetString(0, PFX+"HIGH_VAL", OBJPROP_TEXT, highTxt);

   string lowTxt = (g_todayLow > 0) ? DoubleToString(g_todayLow, digits) : "---";
   ObjectSetString(0, PFX+"LOW_VAL", OBJPROP_TEXT, lowTxt);

   string rngTxt = (g_todayRangePips > 0) ? DoubleToString(g_todayRangePips, 1) : "---";
   ObjectSetString(0, PFX+"RNG_VAL", OBJPROP_TEXT, rngTxt);

   string adrTxt = (g_adrPips > 0) ? DoubleToString(g_adrPips, 1) : "---";
   ObjectSetString(0, PFX+"ADR_VAL", OBJPROP_TEXT, adrTxt);

   string useTxt = (g_adrPips > 0) ? DoubleToString(g_usagePct, 0)+"%" : "---";
   color useClr  = UsageColor(g_usagePct);
   ObjectSetString(0,  PFX+"USE_VAL", OBJPROP_TEXT,  useTxt);
   ObjectSetInteger(0, PFX+"USE_VAL", OBJPROP_COLOR, useClr);

   // Update usage bar fill width
   int maxBarW = PANEL_W - 20;
   double clampedPct = MathMin(g_usagePct, 150.0); // allow overshoot visual cap
   int fillW = (int)MathRound((clampedPct/150.0) * maxBarW);
   if(fillW < 1) fillW = 1;
   ObjectSetInteger(0, PFX+"BARFILL", OBJPROP_XSIZE, fillW);
   ObjectSetInteger(0, PFX+"BARFILL", OBJPROP_BGCOLOR, useClr);
   ObjectSetInteger(0, PFX+"BARFILL", OBJPROP_COLOR,   useClr);

   string tTxt = (g_lastUpdate>0) ? TimeToString(g_lastUpdate, TIME_DATE|TIME_MINUTES|TIME_SECONDS) : "--:--:--";
   ObjectSetString(0, PFX+"TIME", OBJPROP_TEXT, tTxt);

   ChartRedraw();
  }

//======================================================================
//  HELPERS
//======================================================================
color UsageColor(double pct)
  {
   if(pct < 60)  return ClrBarLow;
   if(pct < 90)  return ClrBarMid;
   return ClrBarHigh;
  }

void Rect(string name,int x,int y,int w,int h,color bg,color border)
  {
   if(ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,  x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,  y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,      w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,      h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,    bg);
   ObjectSetInteger(0,name,OBJPROP_COLOR,      border);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_CORNER,     CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_BACK,       true);
  }

void Label(string name,int x,int y,string txt,string font,int sz,color clr)
  {
   if(ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name,OBJPROP_TEXT,      txt);
   ObjectSetString(0, name,OBJPROP_FONT,      font);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,  sz);
   ObjectSetInteger(0,name,OBJPROP_COLOR,     clr);
   ObjectSetInteger(0,name,OBJPROP_CORNER,    CORNER_LEFT_UPPER);
  }
//+------------------------------------------------------------------+