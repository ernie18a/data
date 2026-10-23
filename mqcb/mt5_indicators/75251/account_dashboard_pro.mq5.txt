//+------------------------------------------------------------------+
//|                                             AccountDashboard.mq5 |
//|                            Neon Cyberpunk Account Info Dashboard |
//|                                      Professional Indicator v3.0 |
//+------------------------------------------------------------------+
#property copyright   "Account Dashboard v3.0"
#property link        ""
#property version     "3.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0

//--- Dashboard configuration inputs
input int    InpPaddingRight   = 10;        // Right margin from chart edge (px)
input int    InpPaddingTop     = 25;        // Top margin from chart edge (px)
input int    InpRefreshMs      = 500;       // Refresh interval (milliseconds)
input int    InpFontSize       = 9;         // Font size for data rows
input string InpFontName       = "Consolas";// Font face
input bool   InpShiftChart     = true;      // Shift chart left to avoid overlap

//--- Color scheme (Neon Cyberpunk - High Contrast)
#define CLR_PANEL_BG       C'8,8,20'            // Deep dark navy-black
#define CLR_PANEL_BORDER   C'0,150,255'         // Neon blue border
#define CLR_HEADER         C'0,200,255'         // Vivid cyan header
#define CLR_LABEL          C'90,150,210'        // Neon-tinted label
#define CLR_VALUE_DEFAULT  C'230,240,255'       // Crisp white-blue values
#define CLR_POSITIVE       C'0,255,80'          // Neon green
#define CLR_NEGATIVE       C'255,40,40'         // Neon red
#define CLR_FOOTER         C'255,0,200'         // Hot neon magenta
#define CLR_SEPARATOR      C'0,60,130'          // Dim blue line

//--- Layout constants
#define PANEL_WIDTH        285
#define ROW_HEIGHT         20
#define HEADER_HEIGHT      28
#define SEPARATOR_HEIGHT   8
#define PADDING_X          10
#define FOOTER_HEIGHT      24
#define PANEL_INNER_PAD    8
#define TOTAL_ROWS         10

//--- Unique prefix
#define OBJ_PREFIX         "NCAD3_"

//--- Resource name for bitmap background
#define RES_BG_NAME        "::NCAD3_bg_bitmap"

//--- Globals
int    g_closedTradesAtStart = 0;
bool   g_initialized        = false;
int    g_panelHeight        = 0;
uint   g_lastRefreshTick    = 0;
bool   g_chartShiftOriginal = false;
int    g_chartShiftSizeOrig = 0;

//+------------------------------------------------------------------+
//| Calculate panel height                                            |
//+------------------------------------------------------------------+
int CalcPanelHeight()
  {
   return PANEL_INNER_PAD + HEADER_HEIGHT +
          (4 * SEPARATOR_HEIGHT) +
          (TOTAL_ROWS * ROW_HEIGHT) +
          FOOTER_HEIGHT + PANEL_INNER_PAD + 4;
  }

//+------------------------------------------------------------------+
//| Create a solid-color bitmap resource in memory                    |
//+------------------------------------------------------------------+
bool CreateSolidBitmap(const string resName, const int width, const int height,
                       const uint fillColor)
  {
//--- Create pixel array (ARGB format)
   uint pixels[];
   int  totalPixels = width * height;
   if(ArrayResize(pixels, totalPixels) != totalPixels)
      return false;

//--- Fill with solid color (0xFF alpha = fully opaque)
   uint argb = (0xFF000000) | fillColor;  // Full opacity + BGR color
   ArrayInitialize(pixels, argb);

//--- Create resource
   if(!ResourceCreate(resName, pixels, width, height, 0, 0, width, COLOR_FORMAT_ARGB_NORMALIZE))
     {
      Print("[Dashboard] ERROR: Failed to create bitmap resource.");
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Safe object deletion                                              |
//+------------------------------------------------------------------+
void SafeDeleteObject(const string name)
  {
   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);
  }

//+------------------------------------------------------------------+
//| Delete all dashboard objects                                      |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   int total = ObjectsTotal(0, 0, -1);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, OBJ_PREFIX) == 0)
         ObjectDelete(0, name);
     }
//--- Free bitmap resource
   ResourceFree(RES_BG_NAME);
  }

//+------------------------------------------------------------------+
//| Create opaque bitmap background that covers candles               |
//+------------------------------------------------------------------+
void CreateBitmapBackground()
  {
   g_panelHeight = CalcPanelHeight();

//--- Create solid bitmap in memory
//--- Convert CLR_PANEL_BG (R,G,B) to uint for ARGB
//--- C'8,8,20' = 0x140808 in BGR -> for ARGB we need 0x00080814
   uint bgColorUint = (8 << 16) | (8 << 8) | 20;  // RGB to uint
   if(!CreateSolidBitmap(RES_BG_NAME, PANEL_WIDTH, g_panelHeight, bgColorUint))
     {
      Print("[Dashboard] Falling back to rectangle label.");
      // Fallback to rectangle if bitmap fails
      string bgName = OBJ_PREFIX + "BG_RECT";
      SafeDeleteObject(bgName);
      ObjectCreate(0, bgName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, bgName, OBJPROP_CORNER,       CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, bgName, OBJPROP_XDISTANCE,    InpPaddingRight);
      ObjectSetInteger(0, bgName, OBJPROP_YDISTANCE,    InpPaddingTop);
      ObjectSetInteger(0, bgName, OBJPROP_XSIZE,        PANEL_WIDTH);
      ObjectSetInteger(0, bgName, OBJPROP_YSIZE,        g_panelHeight);
      ObjectSetInteger(0, bgName, OBJPROP_BGCOLOR,      CLR_PANEL_BG);
      ObjectSetInteger(0, bgName, OBJPROP_BORDER_TYPE,  BORDER_FLAT);
      ObjectSetInteger(0, bgName, OBJPROP_BORDER_COLOR, CLR_PANEL_BORDER);
      ObjectSetInteger(0, bgName, OBJPROP_WIDTH,        2);
      ObjectSetInteger(0, bgName, OBJPROP_BACK,         false);
      ObjectSetInteger(0, bgName, OBJPROP_SELECTABLE,   false);
      ObjectSetInteger(0, bgName, OBJPROP_HIDDEN,       true);
      return;
     }

//--- Create bitmap label object
   string bmpName = OBJ_PREFIX + "BG_BMP";
   SafeDeleteObject(bmpName);

   if(!ObjectCreate(0, bmpName, OBJ_BITMAP_LABEL, 0, 0, 0))
     {
      Print("[Dashboard] ERROR: Cannot create OBJ_BITMAP_LABEL.");
      return;
     }

   ObjectSetInteger(0, bmpName, OBJPROP_CORNER,     CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, bmpName, OBJPROP_XDISTANCE,  InpPaddingRight);
   ObjectSetInteger(0, bmpName, OBJPROP_YDISTANCE,  InpPaddingTop);
   ObjectSetInteger(0, bmpName, OBJPROP_XSIZE,      PANEL_WIDTH);
   ObjectSetInteger(0, bmpName, OBJPROP_YSIZE,      g_panelHeight);
   ObjectSetString(0, bmpName, OBJPROP_BMPFILE,    RES_BG_NAME);
   ObjectSetInteger(0, bmpName, OBJPROP_BACK,       false);   // FOREGROUND - covers candles
   ObjectSetInteger(0, bmpName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bmpName, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0, bmpName, OBJPROP_ZORDER,     0);

//--- Border rectangle on top of bitmap
   string borderName = OBJ_PREFIX + "BG_BORDER";
   SafeDeleteObject(borderName);

   if(ObjectCreate(0, borderName, OBJ_RECTANGLE_LABEL, 0, 0, 0))
     {
      ObjectSetInteger(0, borderName, OBJPROP_CORNER,       CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, borderName, OBJPROP_XDISTANCE,    InpPaddingRight);
      ObjectSetInteger(0, borderName, OBJPROP_YDISTANCE,    InpPaddingTop);
      ObjectSetInteger(0, borderName, OBJPROP_XSIZE,        PANEL_WIDTH);
      ObjectSetInteger(0, borderName, OBJPROP_YSIZE,        g_panelHeight);
      ObjectSetInteger(0, borderName, OBJPROP_BGCOLOR,      CLR_NONE);
      ObjectSetInteger(0, borderName, OBJPROP_COLOR,        CLR_PANEL_BORDER);
      ObjectSetInteger(0, borderName, OBJPROP_BORDER_TYPE,  BORDER_FLAT);
      ObjectSetInteger(0, borderName, OBJPROP_BORDER_COLOR, CLR_PANEL_BORDER);
      ObjectSetInteger(0, borderName, OBJPROP_WIDTH,        2);
      ObjectSetInteger(0, borderName, OBJPROP_BACK,         false);
      ObjectSetInteger(0, borderName, OBJPROP_SELECTABLE,   false);
      ObjectSetInteger(0, borderName, OBJPROP_HIDDEN,       true);
      ObjectSetInteger(0, borderName, OBJPROP_ZORDER,       1);
     }
  }

//+------------------------------------------------------------------+
//| Apply chart shift to push candles away from panel area            |
//+------------------------------------------------------------------+
void ApplyChartShift()
  {
   if(!InpShiftChart)
      return;

//--- Save original chart shift settings to restore on deinit
   g_chartShiftOriginal  = (bool)ChartGetInteger(0, CHART_SHIFT);
   g_chartShiftSizeOrig  = (int)ChartGetDouble(0, CHART_SHIFT_SIZE);

//--- Enable chart shift and set size to push candles left
//--- CHART_SHIFT_SIZE is percentage of chart width (10-50%)
   double shiftPercent = 20.0; // 20% shift right margin
   int chartWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);

   if(chartWidth > 0)
     {
      double neededPercent = ((double)(PANEL_WIDTH + InpPaddingRight + 20) / chartWidth) * 100.0;
      shiftPercent = MathMax(neededPercent, 15.0);
      shiftPercent = MathMin(shiftPercent, 50.0);
     }

   ChartSetInteger(0, CHART_SHIFT, true);
   ChartSetDouble(0, CHART_SHIFT_SIZE, shiftPercent);
  }

//+------------------------------------------------------------------+
//| Restore original chart shift settings                             |
//+------------------------------------------------------------------+
void RestoreChartShift()
  {
   if(!InpShiftChart)
      return;

   ChartSetInteger(0, CHART_SHIFT, g_chartShiftOriginal);
   ChartSetDouble(0, CHART_SHIFT_SIZE, (double)g_chartShiftSizeOrig);
  }

//+------------------------------------------------------------------+
//| Create a text label                                               |
//+------------------------------------------------------------------+
void CreateLabel(const string name,
                 const int x,
                 const int y,
                 const string text,
                 const color clr,
                 const int fontSize = 0,
                 const ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER,
                 const string font = "")
  {
   SafeDeleteObject(name);

   if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
      return;

   string useFont     = (font == "") ? InpFontName : font;
   int    useFontSize = (fontSize == 0) ? InpFontSize : fontSize;

   ObjectSetInteger(0, name, OBJPROP_CORNER,    CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,   useFontSize);
   ObjectSetString(0, name, OBJPROP_FONT,       useFont);
   ObjectSetString(0, name, OBJPROP_TEXT,        text);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,     anchor);
   ObjectSetInteger(0, name, OBJPROP_BACK,       false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER,     10);
  }

//+------------------------------------------------------------------+
//| Update label text and color                                       |
//+------------------------------------------------------------------+
void UpdateLabel(const string name, const string text, const color clr = 0)
  {
   if(ObjectFind(0, name) < 0)
      return;
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   if(clr != 0)
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//| Create separator line                                             |
//+------------------------------------------------------------------+
void CreateSeparator(const string name, const int y)
  {
   SafeDeleteObject(name);
   if(!ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
      return;

   ObjectSetInteger(0, name, OBJPROP_CORNER,       CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,    InpPaddingRight + 6);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,    y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,        PANEL_WIDTH - 12);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,        1);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,      CLR_SEPARATOR);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE,  BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, CLR_SEPARATOR);
   ObjectSetInteger(0, name, OBJPROP_BACK,         false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,   false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,       true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER,       5);
  }

//+------------------------------------------------------------------+
//| Build dashboard layout                                            |
//+------------------------------------------------------------------+
void BuildDashboard()
  {
//--- Create opaque background first
   CreateBitmapBackground();

//--- Column positions
   int xLabel = InpPaddingRight + PANEL_WIDTH - PADDING_X;
   int xValue = InpPaddingRight + PADDING_X;

   int y = InpPaddingTop + PANEL_INNER_PAD;

//=== HEADER ===
   CreateLabel(OBJ_PREFIX + "HEADER",
               InpPaddingRight + (PANEL_WIDTH / 2), y,
               "ACCOUNT DASHBOARD", CLR_HEADER,
               InpFontSize + 2, ANCHOR_UPPER, "Consolas");
   y += HEADER_HEIGHT;

   CreateSeparator(OBJ_PREFIX + "SEP0", y);
   y += SEPARATOR_HEIGHT;

//=== DATA ROWS ===
// Row 1: Account
   CreateLabel(OBJ_PREFIX + "L01", xLabel, y, "Account:",   CLR_LABEL, 0, ANCHOR_LEFT_UPPER);
   CreateLabel(OBJ_PREFIX + "V01", xValue, y, "---",        CLR_VALUE_DEFAULT, 0, ANCHOR_RIGHT_UPPER);
   y += ROW_HEIGHT;

// Row 2: Broker
   CreateLabel(OBJ_PREFIX + "L02", xLabel, y, "Broker:",    CLR_LABEL, 0, ANCHOR_LEFT_UPPER);
   CreateLabel(OBJ_PREFIX + "V02", xValue, y, "---",        CLR_VALUE_DEFAULT, InpFontSize - 1, ANCHOR_RIGHT_UPPER);
   y += ROW_HEIGHT;

   CreateSeparator(OBJ_PREFIX + "SEP1", y);
   y += SEPARATOR_HEIGHT;

// Row 3: Balance
   CreateLabel(OBJ_PREFIX + "L03", xLabel, y, "Balance:",   CLR_LABEL, 0, ANCHOR_LEFT_UPPER);
   CreateLabel(OBJ_PREFIX + "V03", xValue, y, "---",        CLR_VALUE_DEFAULT, 0, ANCHOR_RIGHT_UPPER);
   y += ROW_HEIGHT;

// Row 4: Equity
   CreateLabel(OBJ_PREFIX + "L04", xLabel, y, "Equity:",    CLR_LABEL, 0, ANCHOR_LEFT_UPPER);
   CreateLabel(OBJ_PREFIX + "V04", xValue, y, "---",        CLR_VALUE_DEFAULT, 0, ANCHOR_RIGHT_UPPER);
   y += ROW_HEIGHT;

// Row 5: Float PnL
   CreateLabel(OBJ_PREFIX + "L05", xLabel, y, "Float P&L:", CLR_LABEL, 0, ANCHOR_LEFT_UPPER);
   CreateLabel(OBJ_PREFIX + "V05", xValue, y, "---",        CLR_VALUE_DEFAULT, 0, ANCHOR_RIGHT_UPPER);
   y += ROW_HEIGHT;

   CreateSeparator(OBJ_PREFIX + "SEP2", y);
   y += SEPARATOR_HEIGHT;

// Row 6: Open Positions
   CreateLabel(OBJ_PREFIX + "L06", xLabel, y, "Open Pos:",  CLR_LABEL, 0, ANCHOR_LEFT_UPPER);
   CreateLabel(OBJ_PREFIX + "V06", xValue, y, "---",        CLR_VALUE_DEFAULT, 0, ANCHOR_RIGHT_UPPER);
   y += ROW_HEIGHT;

// Row 7: Closed Trades
   CreateLabel(OBJ_PREFIX + "L07", xLabel, y, "Closed:",    CLR_LABEL, 0, ANCHOR_LEFT_UPPER);
   CreateLabel(OBJ_PREFIX + "V07", xValue, y, "---",        CLR_VALUE_DEFAULT, 0, ANCHOR_RIGHT_UPPER);
   y += ROW_HEIGHT;

   CreateSeparator(OBJ_PREFIX + "SEP3", y);
   y += SEPARATOR_HEIGHT;

// Row 8: Spread
   CreateLabel(OBJ_PREFIX + "L08", xLabel, y, "Spread:",    CLR_LABEL, 0, ANCHOR_LEFT_UPPER);
   CreateLabel(OBJ_PREFIX + "V08", xValue, y, "---",        CLR_VALUE_DEFAULT, 0, ANCHOR_RIGHT_UPPER);
   y += ROW_HEIGHT;

// Row 9: Daily PnL
   CreateLabel(OBJ_PREFIX + "L09", xLabel, y, "Daily P&L:", CLR_LABEL, 0, ANCHOR_LEFT_UPPER);
   CreateLabel(OBJ_PREFIX + "V09", xValue, y, "---",        CLR_VALUE_DEFAULT, 0, ANCHOR_RIGHT_UPPER);
   y += ROW_HEIGHT;

// Row 10: Ping
   CreateLabel(OBJ_PREFIX + "L10", xLabel, y, "Ping:",      CLR_LABEL, 0, ANCHOR_LEFT_UPPER);
   CreateLabel(OBJ_PREFIX + "V10", xValue, y, "---",        CLR_VALUE_DEFAULT, 0, ANCHOR_RIGHT_UPPER);
   y += ROW_HEIGHT;

   CreateSeparator(OBJ_PREFIX + "SEP4", y);
   y += SEPARATOR_HEIGHT;

//=== FOOTER ===
   CreateLabel(OBJ_PREFIX + "FOOTER",
               InpPaddingRight + (PANEL_WIDTH / 2), y + 2,
               "\" Slow & Steady wins the race \"", CLR_FOOTER,
               InpFontSize - 1, ANCHOR_UPPER, "Georgia");
  }

//+------------------------------------------------------------------+
//| Get closed trades count                                           |
//+------------------------------------------------------------------+
int GetClosedTradesCount()
  {
   if(!HistorySelect(0, TimeCurrent()))
      return 0;
   return HistoryDealsTotal();
  }

//+------------------------------------------------------------------+
//| Get floating PnL                                                  |
//+------------------------------------------------------------------+
double GetFloatingPnL()
  {
   double pnl = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetTicket(i) > 0)
         pnl += PositionGetDouble(POSITION_PROFIT) +
                PositionGetDouble(POSITION_SWAP);
     }
   return pnl;
  }

//+------------------------------------------------------------------+
//| Color by PnL direction                                            |
//+------------------------------------------------------------------+
color PnLColor(const double value)
  {
   if(value > 0.001)
      return CLR_POSITIVE;
   if(value < -0.001)
      return CLR_NEGATIVE;
   return CLR_VALUE_DEFAULT;
  }

//+------------------------------------------------------------------+
//| Format money with sign                                            |
//+------------------------------------------------------------------+
string FormatMoney(const double value, const int digits = 2)
  {
   return ((value >= 0.0) ? "+" : "") + DoubleToString(value, digits);
  }

//+------------------------------------------------------------------+
//| Truncate string safely                                            |
//+------------------------------------------------------------------+
string TruncateStr(const string text, const int maxLen)
  {
   if(StringLen(text) <= maxLen)
      return text;
   return StringSubstr(text, 0, maxLen - 2) + "..";
  }

//+------------------------------------------------------------------+
//| Refresh dashboard data                                            |
//+------------------------------------------------------------------+
void RefreshData()
  {
   long   acctNum    = AccountInfoInteger(ACCOUNT_LOGIN);
   string broker     = AccountInfoString(ACCOUNT_COMPANY);
   double balance    = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity     = AccountInfoDouble(ACCOUNT_EQUITY);
   string currency   = AccountInfoString(ACCOUNT_CURRENCY);
   double floatPnl   = GetFloatingPnL();
   int    openPos    = PositionsTotal();
   int    closedNow  = GetClosedTradesCount();
   int    closedNew  = MathMax(0, closedNow - g_closedTradesAtStart);
   long   spreadPts  = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   double dailyPct   = (balance > 0) ? (floatPnl / balance) * 100.0 : 0.0;
   long   pingUs     = TerminalInfoInteger(TERMINAL_PING_LAST);
   int    pingMs     = (pingUs > 0) ? (int)(pingUs / 1000) : -1;

//--- Update all value labels
   UpdateLabel(OBJ_PREFIX + "V01", IntegerToString(acctNum),                  CLR_VALUE_DEFAULT);
   UpdateLabel(OBJ_PREFIX + "V02", TruncateStr(broker, 18),                   CLR_VALUE_DEFAULT);
   UpdateLabel(OBJ_PREFIX + "V03", DoubleToString(balance, 2) + " " + currency, CLR_VALUE_DEFAULT);
   UpdateLabel(OBJ_PREFIX + "V04", DoubleToString(equity, 2) + " " + currency,  PnLColor(equity - balance));
   UpdateLabel(OBJ_PREFIX + "V05", FormatMoney(floatPnl) + " " + currency,     PnLColor(floatPnl));
   UpdateLabel(OBJ_PREFIX + "V06", IntegerToString(openPos),                   CLR_VALUE_DEFAULT);
   UpdateLabel(OBJ_PREFIX + "V07", IntegerToString(closedNew),                 CLR_VALUE_DEFAULT);
   UpdateLabel(OBJ_PREFIX + "V08", IntegerToString(spreadPts) + " pts", (spreadPts > 50) ? CLR_NEGATIVE : CLR_VALUE_DEFAULT);
   UpdateLabel(OBJ_PREFIX + "V09", FormatMoney(dailyPct, 2) + "%",             PnLColor(dailyPct));

   string pingStr = (pingMs >= 0) ? IntegerToString(pingMs) + " ms" : "N/A";
   color  pingClr = CLR_VALUE_DEFAULT;
   if(pingMs > 200)
      pingClr = CLR_NEGATIVE;
   else
      if(pingMs > 80)
         pingClr = C'255,180,0';
      else
         if(pingMs >= 0)
            pingClr = CLR_POSITIVE;
   UpdateLabel(OBJ_PREFIX + "V10", pingStr, pingClr);
  }

//+------------------------------------------------------------------+
//| Indicator initialization                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   HistorySelect(0, TimeCurrent());
   g_closedTradesAtStart = GetClosedTradesCount();
   g_initialized         = false;
   g_lastRefreshTick     = 0;

//--- Shift chart to make room for dashboard
   ApplyChartShift();

//--- Build and populate
   BuildDashboard();
   RefreshData();
   ChartRedraw(0);

//--- Timer for live updates
   if(!EventSetMillisecondTimer(InpRefreshMs))
      Print("[Dashboard] Timer unavailable, using tick fallback.");

   g_initialized = true;
   Print("[Dashboard] v3.0 initialized successfully.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Indicator deinitialization                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeleteAllObjects();
   RestoreChartShift();
   ChartRedraw(0);
   Print("[Dashboard] Removed cleanly.");
  }

//+------------------------------------------------------------------+
//| Timer handler                                                     |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(!g_initialized)
      return;
   RefreshData();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| OnCalculate — near-zero overhead                                  |
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
   uint now = GetTickCount();
   if(now - g_lastRefreshTick >= (uint)InpRefreshMs)
     {
      g_lastRefreshTick = now;
      RefreshData();
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Chart event handler                                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      //--- Recalculate shift if chart resized
      if(InpShiftChart)
        {
         int chartWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
         if(chartWidth > 0)
           {
            double neededPct = ((double)(PANEL_WIDTH + InpPaddingRight + 20) / chartWidth) * 100.0;
            neededPct = MathMax(neededPct, 15.0);
            neededPct = MathMin(neededPct, 50.0);
            ChartSetDouble(0, CHART_SHIFT_SIZE, neededPct);
           }
        }
      RefreshData();
      ChartRedraw(0);
     }
  }
//+------------------------------------------------------------------+
