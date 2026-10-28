//+------------------------------------------------------------------+
//|                                       FoxWave_SpreadMeter.mq5    |
//|                       Copyright Fox Wave - foxwavetrading.top    |
//|          Single-Symbol Live Spread Meter with Max/Min Record     |
//+------------------------------------------------------------------+
#property copyright "Fox Wave | foxwavetrading.top"
#property link      "https://foxwavetrading.top"
#property version   "1.00"
#property description "FoxWave Spread Meter - tracks live, max and min spread for the current chart symbol."
#property indicator_chart_window
#property indicator_plots 0

//======================================================================
//  INPUTS
//======================================================================
input group "PANEL"
input int     PanelX           = 15;   // Panel X offset
input int     PanelY           = 25;   // Panel Y offset
input int     RefreshSeconds   = 1;    // Refresh interval (seconds)

input group "COLORS"
input color   ClrPanelBg       = C'10,12,20';     // Outer panel background
input color   ClrHeaderBg      = C'16,20,38';     // Header bar background
input color   ClrAccent        = C'255,140,0';    // Fox Wave accent (orange)
input color   ClrSymbol        = C'235,240,250';  // Symbol name text
input color   ClrLive          = C'255,255,255';  // Live spread value
input color   ClrMax           = C'255,90,90';    // Max spread value (red - widest)
input color   ClrMin           = C'90,220,160';   // Min spread value (green - tightest)
input color   ClrLabel         = C'110,120,145';  // Small caption labels
input color   ClrTime          = C'80,92,118';    // Timestamp
input color   ClrFlash         = C'255,210,60';   // Flash on new record
input color   ClrBorder        = C'45,55,85';     // Borders
input color   ClrFooter        = C'70,80,105';    // Footer brand text

//======================================================================
//  CONSTANTS
//======================================================================
#define PANEL_W     220
#define PANEL_H     188
#define FONT_MAIN   "Consolas"
#define PFX         "FWSM_"

//======================================================================
//  GLOBALS
//======================================================================
string   g_sym;
int      g_liveSpread  = 0;
int      g_maxSpread   = 0;
int      g_minSpread   = 999999;
datetime g_maxTime     = 0;
datetime g_minTime     = 0;
bool     g_flashMax    = false;
bool     g_flashMin    = false;
bool     g_started     = false;

//======================================================================
int OnInit()
  {
   g_sym = _Symbol;
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
   UpdateSpread();
   RefreshPanel();
  }

//======================================================================
//  CORE LOGIC
//======================================================================
void UpdateSpread()
  {
   if(!SymbolSelect(g_sym, true)) return;

   int sp = (int)SymbolInfoInteger(g_sym, SYMBOL_SPREAD);
   g_liveSpread = sp;

   g_flashMax = false;
   g_flashMin = false;

   if(sp > g_maxSpread)
     { g_maxSpread = sp; g_maxTime = TimeCurrent(); g_flashMax = true; }

   if(sp > 0 && sp < g_minSpread)
     { g_minSpread = sp; g_minTime = TimeCurrent(); g_flashMin = true; }

   g_started = true;
  }

//======================================================================
//  DRAW PANEL (built once)
//======================================================================
void DrawPanel()
  {
   // Outer frame
   Rect(PFX+"BG", PanelX, PanelY, PANEL_W, PANEL_H, ClrPanelBg, ClrBorder);

   // Header bar
   Rect(PFX+"HDR", PanelX, PanelY, PANEL_W, 30, ClrHeaderBg, ClrHeaderBg);
   Rect(PFX+"HDRLINE", PanelX, PanelY+30, PANEL_W, 2, ClrAccent, ClrAccent);

   // Header text
   Label(PFX+"TITLE", PanelX+10, PanelY+6, "FOX WAVE", FONT_MAIN, 11, ClrAccent);
   Label(PFX+"SUB",   PanelX+10, PanelY+19, "SPREAD METER", FONT_MAIN, 7, ClrLabel);

   // Symbol name - big, centered feel
   Label(PFX+"SYM", PanelX+10, PanelY+40, g_sym, FONT_MAIN, 13, ClrSymbol);

   // Divider
   Rect(PFX+"DIV1", PanelX+10, PanelY+62, PANEL_W-20, 1, ClrBorder, ClrBorder);

   // LIVE block
   Label(PFX+"LIVE_LBL", PanelX+10, PanelY+70, "LIVE SPREAD", FONT_MAIN, 7, ClrLabel);
   Label(PFX+"LIVE_VAL", PanelX+10, PanelY+82, "---", FONT_MAIN, 20, ClrLive);
   Label(PFX+"LIVE_PTS", PanelX+95, PanelY+90, "points", FONT_MAIN, 8, ClrLabel);

   // Divider
   Rect(PFX+"DIV2", PanelX+10, PanelY+112, PANEL_W-20, 1, ClrBorder, ClrBorder);

   // MAX row
   Label(PFX+"MAX_LBL", PanelX+10, PanelY+119, "MAX RECORD", FONT_MAIN, 7, ClrLabel);
   Label(PFX+"MAX_VAL", PanelX+95, PanelY+118, "---", FONT_MAIN, 10, ClrMax);
   Label(PFX+"MAX_TIME", PanelX+10, PanelY+132, "--:--:--", FONT_MAIN, 7, ClrTime);

   // MIN row
   Label(PFX+"MIN_LBL", PanelX+10, PanelY+147, "MIN RECORD", FONT_MAIN, 7, ClrLabel);
   Label(PFX+"MIN_VAL", PanelX+95, PanelY+146, "---", FONT_MAIN, 10, ClrMin);
   Label(PFX+"MIN_TIME", PanelX+10, PanelY+160, "--:--:--", FONT_MAIN, 7, ClrTime);

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
   // LIVE
   string liveTxt = g_started ? (string)g_liveSpread : "---";
   ObjectSetString(0, PFX+"LIVE_VAL", OBJPROP_TEXT, liveTxt);

   // MAX
   string maxTxt = (g_maxSpread > 0) ? (string)g_maxSpread+" pts" : "---";
   ObjectSetString(0,  PFX+"MAX_VAL", OBJPROP_TEXT,  maxTxt);
   ObjectSetInteger(0, PFX+"MAX_VAL", OBJPROP_COLOR, g_flashMax ? ClrFlash : ClrMax);
   string maxTimeTxt = (g_maxTime>0) ? TimeToString(g_maxTime, TIME_DATE|TIME_MINUTES|TIME_SECONDS) : "--:--:--";
   ObjectSetString(0, PFX+"MAX_TIME", OBJPROP_TEXT, maxTimeTxt);

   // MIN
   bool minReady = (g_minSpread < 999999);
   string minTxt = minReady ? (string)g_minSpread+" pts" : "---";
   ObjectSetString(0,  PFX+"MIN_VAL", OBJPROP_TEXT,  minTxt);
   ObjectSetInteger(0, PFX+"MIN_VAL", OBJPROP_COLOR, g_flashMin ? ClrFlash : ClrMin);
   string minTimeTxt = (g_minTime>0) ? TimeToString(g_minTime, TIME_DATE|TIME_MINUTES|TIME_SECONDS) : "--:--:--";
   ObjectSetString(0, PFX+"MIN_TIME", OBJPROP_TEXT, minTimeTxt);

   ChartRedraw();
  }

//======================================================================
//  HELPERS
//======================================================================
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