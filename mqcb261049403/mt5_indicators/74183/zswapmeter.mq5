//+------------------------------------------------------------------+
//|                                         FoxWave_SwapMeter.mq5    |
//|                       Copyright Fox Wave - foxwavetrading.top    |
//|             Single-Symbol Live Sell/Buy Swap Meter Panel         |
//+------------------------------------------------------------------+
#property copyright "Fox Wave | foxwavetrading.top"
#property link      "https://foxwavetrading.top"
#property version   "1.00"
#property description "FoxWave Swap Meter - displays live SELL and BUY swap for the current chart symbol, with change alerts."
#property indicator_chart_window
#property indicator_plots 0

//======================================================================
//  INPUTS
//======================================================================
input group "PANEL"
input int     PanelX           = 15;   // Panel X offset
input int     PanelY           = 25;   // Panel Y offset
input int     RefreshSeconds   = 1;    // Refresh interval (seconds)

input group "ALERTS"
input bool    AlertsEnabled    = true;   // Master on/off switch
input bool    AlertPopup       = true;   // Show MT5 popup alert
input bool    AlertPush        = false;  // Send push notification to phone
input bool    AlertLog         = true;   // Print to Experts log
input double  AlertMinChange   = 0.01;   // Minimum change to trigger alert

input group "COLORS"
input color   ClrPanelBg       = C'10,12,20';     // Outer panel background
input color   ClrHeaderBg      = C'16,20,38';     // Header bar background
input color   ClrAccent        = C'255,140,0';    // Fox Wave accent (orange)
input color   ClrSymbol        = C'235,240,250';  // Symbol name text
input color   ClrPositive      = C'90,220,160';   // Positive swap (green)
input color   ClrNegative      = C'255,90,90';    // Negative swap (red)
input color   ClrNeutral       = C'150,160,180';  // Zero swap
input color   ClrLabel         = C'110,120,145';  // Small caption labels
input color   ClrTime          = C'80,92,118';    // Timestamp
input color   ClrFlash         = C'255,210,60';   // Flash on change
input color   ClrBorder        = C'45,55,85';     // Borders
input color   ClrFooter        = C'70,80,105';    // Footer brand text

//======================================================================
//  CONSTANTS
//======================================================================
#define PANEL_W     220
#define PANEL_H     188
#define FONT_MAIN   "Consolas"
#define PFX         "FWSWM_"

//======================================================================
//  GLOBALS
//======================================================================
string   g_sym;
double   g_sellSwap     = 0;
double   g_buySwap      = 0;
double   g_sellSwapPrev = 0;
double   g_buySwapPrev  = 0;
datetime g_lastUpdate   = 0;
bool     g_flashSell    = false;
bool     g_flashBuy     = false;
bool     g_initialized  = false;

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
   UpdateSwap();
   RefreshPanel();
  }

//======================================================================
//  CORE LOGIC
//======================================================================
void UpdateSwap()
  {
   if(!SymbolSelect(g_sym, true)) return;

   double sellSw = SymbolInfoDouble(g_sym, SYMBOL_SWAP_SHORT);
   double buySw  = SymbolInfoDouble(g_sym, SYMBOL_SWAP_LONG);

   g_flashSell = false;
   g_flashBuy  = false;

   if(g_initialized)
     {
      if(MathAbs(sellSw - g_sellSwapPrev) >= AlertMinChange)
        { g_flashSell = true; FireAlert("SELL", g_sellSwapPrev, sellSw); }
      if(MathAbs(buySw - g_buySwapPrev) >= AlertMinChange)
        { g_flashBuy = true; FireAlert("BUY", g_buySwapPrev, buySw); }
     }

   g_sellSwapPrev = sellSw;
   g_buySwapPrev  = buySw;
   g_sellSwap     = sellSw;
   g_buySwap      = buySw;
   g_lastUpdate   = TimeCurrent();
   g_initialized  = true;
  }

//======================================================================
//  ALERT
//======================================================================
void FireAlert(string side, double oldVal, double newVal)
  {
   if(!AlertsEnabled) return;

   string dir = (newVal > oldVal) ? "UP" : "DOWN";
   string msg = StringFormat("FoxWave SwapMeter: %s %s swap changed %s  %s -> %s",
                              g_sym, side, dir,
                              FormatSwap(oldVal), FormatSwap(newVal));

   if(AlertLog)   Print(msg);
   if(AlertPopup) Alert(msg);
   if(AlertPush)  SendNotification(msg);
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
   Label(PFX+"SUB",   PanelX+10, PanelY+19, "SWAP METER", FONT_MAIN, 7, ClrLabel);

   Label(PFX+"SYM", PanelX+10, PanelY+40, g_sym, FONT_MAIN, 13, ClrSymbol);

   Rect(PFX+"DIV1", PanelX+10, PanelY+62, PANEL_W-20, 1, ClrBorder, ClrBorder);

   // SELL block
   Label(PFX+"SELL_LBL", PanelX+10, PanelY+70, "SELL SWAP", FONT_MAIN, 7, ClrLabel);
   Label(PFX+"SELL_VAL", PanelX+10, PanelY+82, "---", FONT_MAIN, 18, ClrNeutral);

   Rect(PFX+"DIV2", PanelX+10, PanelY+112, PANEL_W-20, 1, ClrBorder, ClrBorder);

   // BUY block
   Label(PFX+"BUY_LBL", PanelX+10, PanelY+119, "BUY SWAP", FONT_MAIN, 7, ClrLabel);
   Label(PFX+"BUY_VAL", PanelX+10, PanelY+131, "---", FONT_MAIN, 18, ClrNeutral);

   Rect(PFX+"DIV3", PanelX+10, PanelY+161, PANEL_W-20, 1, ClrBorder, ClrBorder);

   // Timestamp
   Label(PFX+"TIME", PanelX+10, PanelY+167, "--:--:--", FONT_MAIN, 7, ClrTime);

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
   string sellTxt = FormatSwap(g_sellSwap);
   ObjectSetString(0,  PFX+"SELL_VAL", OBJPROP_TEXT,  sellTxt);
   ObjectSetInteger(0, PFX+"SELL_VAL", OBJPROP_COLOR, g_flashSell ? ClrFlash : SwapColor(g_sellSwap));

   string buyTxt = FormatSwap(g_buySwap);
   ObjectSetString(0,  PFX+"BUY_VAL", OBJPROP_TEXT,  buyTxt);
   ObjectSetInteger(0, PFX+"BUY_VAL", OBJPROP_COLOR, g_flashBuy ? ClrFlash : SwapColor(g_buySwap));

   string tTxt = (g_lastUpdate>0) ? TimeToString(g_lastUpdate, TIME_DATE|TIME_MINUTES|TIME_SECONDS) : "--:--:--";
   ObjectSetString(0, PFX+"TIME", OBJPROP_TEXT, tTxt);

   ChartRedraw();
  }

//======================================================================
//  HELPERS
//======================================================================
string FormatSwap(double val)
  {
   string sign = (val > 0) ? "+" : "";
   return sign + DoubleToString(val, 2);
  }

color SwapColor(double val)
  {
   if(val > 0.0001)  return ClrPositive;
   if(val < -0.0001) return ClrNegative;
   return ClrNeutral;
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