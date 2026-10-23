//+------------------------------------------------------------------+
//|                                   Channel Breakout Dashboard.mq5 |
//|               Multi-timeframe channel breakout dashboard for MT5 |
//|                                Copyright (c) 2026 Marian Beceanu |
//|                            https://www.mql5.com/en/users/zorbacc |
//|                                  Email: marian.beceanu@gmail.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026"
#property link        "https://forge.mql5.io"
#property version     "1.60"
#property indicator_chart_window
#property indicator_plots 0

//============================== ENUMERATIONS ================================
enum ENUM_BG_THEME
  {
   BG_THEME_BLOOMBERG,        // Bloomberg Classic (Default)
   BG_THEME_BLOOMBERG_DEEP,   // Bloomberg Deep Black
   BG_THEME_BLOOMBERG_NAVY,   // Bloomberg Navy
   BG_THEME_DARK_NAVY,        // Dark Navy
   BG_THEME_BLACK,            // Pure Black
   BG_THEME_CHARCOAL,         // Charcoal Gray
   BG_THEME_DARK_BLUE,        // Deep Blue
   BG_THEME_DARK_GREEN,       // Dark Green
   BG_THEME_DARK_PURPLE,      // Dark Purple
   BG_THEME_CUSTOM            // Custom Color (set below)
  };

enum ENUM_ACCENT_THEME
  {
   ACCENT_AMBER,       // Amber / Orange (Bloomberg Default)
   ACCENT_ORANGE,      // Bright Orange
   ACCENT_GOLD,        // Gold
   ACCENT_CYAN,        // Cyan (Bloomberg alt)
   ACCENT_BLUE,        // Blue
   ACCENT_GREEN,       // Green
   ACCENT_RED,         // Red
   ACCENT_SILVER,      // Silver
   ACCENT_CUSTOM       // Custom Color (set below)
  };

//============================== INPUTS ======================================
input group "===== INSTANCE ====="
input int                 InpInstanceID            = 1;                   // Instance ID (use a different number per copy)

input group "===== PANEL DISPLAY ====="
input bool                InpShowPanel             = true;                // Show dashboard panel
input ENUM_BASE_CORNER    InpPanelCorner           = CORNER_LEFT_UPPER;   // Panel corner (position)
input int                 InpPanelX                = 12;                  // Horizontal offset (pixels)
input int                 InpPanelY                = 12;                  // Vertical offset (pixels)
input int                 InpFontSize              = 9;                   // Base text size (7-24)
input bool                InpAutoWidth             = true;                // Auto-fit panel width to longest text
input int                 InpFixedWidth            = 340;                 // Fixed panel width (used only if auto width = false)

input group "===== BLOOMBERG COLOR THEME ====="
input ENUM_BG_THEME       InpBackgroundTheme       = BG_THEME_BLOOMBERG;  // Background theme
input color               InpCustomBackgroundColor = C'12,16,22';         // Custom background (theme = Custom)
input ENUM_ACCENT_THEME   InpAccentTheme           = ACCENT_AMBER;        // Accent / title / border theme
input color               InpCustomAccentColor     = C'255,165,0';        // Custom accent (theme = Custom)

input group "===== BLOOMBERG TEXT & UI COLORS ====="
input color               InpTextPrimary           = C'230,235,240';      // Primary text (values, titles)
input color               InpTextSecondary         = C'140,150,160';      // Secondary / muted text
input color               InpColorBullish          = C'0,200,100';        // Bullish / positive color
input color               InpColorBearish          = C'255,70,70';        // Bearish / negative color
input color               InpColorWarning          = C'255,193,7';        // Warning / wait color
input color               InpColorNeutral          = C'140,150,160';      // Neutral color
input color               InpBarBackground         = C'8,12,18';          // ADR bar background
input color               InpBorderColor           = C'40,50,60';         // Inner borders / bar track

input group "===== TREND SETTINGS ====="
input int                 InpFastMAPeriod          = 20;                  // Fast MA period
input int                 InpSlowMAPeriod          = 50;                  // Slow MA period
input ENUM_MA_METHOD      InpMAMethod              = MODE_EMA;            // MA method
input ENUM_APPLIED_PRICE  InpMAPrice               = PRICE_CLOSE;         // MA applied price
input ENUM_TIMEFRAMES     InpHigherTimeframe       = PERIOD_H4;           // Higher timeframe for trend bias

input group "===== MOMENTUM SETTINGS ====="
input int                 InpRSIPeriod             = 14;                  // RSI period
input double              InpRSIOverbought         = 70.0;                // RSI overbought level
input double              InpRSIOversold           = 30.0;                // RSI oversold level

input group "===== VOLATILITY SETTINGS ====="
input int                 InpATRPeriod             = 14;                  // ATR period
input double              InpVolLowRatio           = 0.80;                // Low volatility ratio threshold
input double              InpVolHighRatio          = 1.20;                // High volatility ratio threshold

input group "===== CHANNEL / SWING RANGE SETTINGS ====="
input int                 InpSwingLookback         = 20;                  // Channel high/low lookback (bars)
input double              InpBreakoutBufferPoints  = 5.0;                 // Breakout confirmation buffer (points)
input bool                InpDrawChannelLines      = true;                // Draw channel lines on chart
input ENUM_LINE_STYLE     InpChannelLineStyle      = STYLE_SOLID;         // Channel line style
input int                 InpChannelLineWidth      = 2;                   // Channel line width (1-5)
input color               InpChannelHighColor      = C'0,200,100';        // Channel High line color
input color               InpChannelLowColor       = C'255,70,70';        // Channel Low line color

input group "===== DAILY RANGE SETTINGS ====="
input int                 InpADRPeriod             = 14;                  // Average Daily Range period

input group "===== SPREAD THRESHOLDS (POINTS) ====="
input double              InpSpreadLowMax          = 15.0;                // Low spread max (points)
input double              InpSpreadNormalMax       = 30.0;                // Normal spread max (points)

input group "===== REFRESH ====="
input int                 InpTimerSeconds          = 2;                   // Refresh interval (seconds, min 1)

//============================== RUNTIME COLORS ===============================
color C_WHITE  = C'230,235,240';
color C_GRAY   = C'140,150,160';
color C_GREEN  = C'0,200,100';
color C_YELLOW = C'255,193,7';
color C_ORANGE = C'255,140,0';
color C_AMBER  = C'255,165,0';
color C_RED    = C'255,70,70';
color C_BORDER = C'40,50,60';
color C_DARK2  = C'8,12,18';

//============================== LABEL INDICES ================================
enum ENUM_LABEL
  {
   LBL_TITLE = 0,
   LBL_SUB,
   LBL_STATUS,
   LBL_MARKET,
   LBL_TRADE,
   LBL_TRENDCUR,
   LBL_TRENDHTF,
   LBL_RSI,
   LBL_VOL,
   LBL_SWINGHIGH,
   LBL_SWINGLOW,
   LBL_BREAKOUT,
   LBL_ADRLABEL,
   LBL_SPREAD,
   LBL_BIAS,
   LBL_TIME,
   LBL_FOOT,
   LBL_COUNT
  };

//============================== GLOBAL STATE =================================
string g_prefix        = "CBD_";
int    g_font_size     = 9;
double g_ratio         = 1.0;
int    g_pad           = 14;
int    g_line_h        = 20;
int    g_panel_width   = 340;
int    g_panel_height  = 400;

color  g_bg_color      = (color)C'12,16,22';
color  g_accent_color  = (color)C'255,165,0';

string g_obj_name[LBL_COUNT];
int    g_obj_localx[LBL_COUNT];
int    g_obj_localy[LBL_COUNT];
int    g_obj_size[LBL_COUNT];
bool   g_obj_bold[LBL_COUNT];
string g_obj_text[LBL_COUNT];
bool   g_obj_used[LBL_COUNT];
string g_last_text[LBL_COUNT];
color  g_last_color[LBL_COUNT];

int    g_bar_localx = 0, g_bar_localy = 0, g_bar_height = 12;
int    g_last_fill_w = -1;
color  g_last_fill_color = CLR_NONE;

int g_ma_fast_handle     = INVALID_HANDLE;
int g_ma_slow_handle     = INVALID_HANDLE;
int g_htf_ma_fast_handle = INVALID_HANDLE;
int g_htf_ma_slow_handle = INVALID_HANDLE;
int g_rsi_handle         = INVALID_HANDLE;
int g_atr_handle         = INVALID_HANDLE;

double g_point  = 0.0;
int    g_digits = 5;

string g_status            = "INITIALIZING";
string g_market_status     = "UNKNOWN";
string g_trend_current     = "UNKNOWN";
string g_trend_htf         = "UNKNOWN";
string g_momentum_status   = "UNKNOWN";
string g_momentum_bias     = "NEUTRAL";
string g_volatility_status = "UNKNOWN";
string g_breakout_status   = "UNKNOWN";
string g_spread_status     = "UNKNOWN";
string g_bias              = "WAIT";

//----- resilience / degraded-history tracking -----
bool   g_swing_degraded  = false;   // fewer bars than requested were available
bool   g_adr_degraded    = false;
int    g_consec_tick_fail = 0;      // consecutive SymbolInfoTick failures

double   g_bid = 0.0, g_ask = 0.0, g_spread_points = 0.0;
long     g_trade_mode = SYMBOL_TRADE_MODE_DISABLED;
datetime g_last_tick_time = 0;

double g_rsi = 0.0;
double g_atr_current = 0.0, g_atr_average = 0.0, g_atr_ratio = 1.0;
double g_swing_high = 0.0, g_swing_low = 0.0;
double g_drawn_high = 0.0, g_drawn_low = 0.0;   // last prices written to HLINE

double g_today_high = 0.0, g_today_low = 0.0, g_today_range = 0.0;
double g_today_range_points = 0.0, g_adr = 0.0, g_adr_points = 0.0, g_adr_used_pct = 0.0;

bool g_width_dirty   = true;
bool g_need_redraw   = false;
bool g_channel_ready = false;

datetime g_last_adr_update   = 0;
datetime g_last_swing_update = 0;
datetime g_last_vol_update   = 0;
datetime g_last_trend_update = 0;

double   g_buf1[1], g_buf2[1], g_buf3[1], g_buf4[1];
double   g_atr_buf[];
MqlRates g_rates_buf[];
MqlRates g_daily_buf[];

string g_tf_cur = "";
string g_tf_htf = "";

//============================== HELPERS ======================================
string GetTimeframeText(const ENUM_TIMEFRAMES tf)
{
   string text = EnumToString(tf);
   StringReplace(text, "PERIOD_", "");
   return text;
}

int NormalizeFontSize(const int size)
{
   if(size < 7)  return 7;
   if(size > 24) return 24;
   return size;
}

string TradeModeText()
{
   switch((ENUM_SYMBOL_TRADE_MODE)g_trade_mode)
     {
      case SYMBOL_TRADE_MODE_DISABLED:  return "DISABLED";
      case SYMBOL_TRADE_MODE_LONGONLY:  return "LONG ONLY";
      case SYMBOL_TRADE_MODE_SHORTONLY: return "SHORT ONLY";
      case SYMBOL_TRADE_MODE_CLOSEONLY: return "CLOSE ONLY";
      case SYMBOL_TRADE_MODE_FULL:      return "FULL";
     }
   return "UNKNOWN";
}

color GetBackgroundColor()
{
   switch(InpBackgroundTheme)
     {
      case BG_THEME_BLOOMBERG:      return (color)C'12,16,22';
      case BG_THEME_BLOOMBERG_DEEP: return (color)C'5,8,12';
      case BG_THEME_BLOOMBERG_NAVY: return (color)C'10,18,32';
      case BG_THEME_DARK_NAVY:      return (color)C'8,23,38';
      case BG_THEME_BLACK:          return (color)C'0,0,0';
      case BG_THEME_CHARCOAL:       return (color)C'28,28,30';
      case BG_THEME_DARK_BLUE:      return (color)C'6,20,45';
      case BG_THEME_DARK_GREEN:     return (color)C'6,28,18';
      case BG_THEME_DARK_PURPLE:    return (color)C'26,12,36';
      case BG_THEME_CUSTOM:         return InpCustomBackgroundColor;
      default:                      return (color)C'12,16,22';
     }
}

color GetAccentColor()
{
   switch(InpAccentTheme)
     {
      case ACCENT_AMBER:  return (color)C'255,165,0';
      case ACCENT_ORANGE: return (color)C'255,140,0';
      case ACCENT_GOLD:   return (color)C'212,175,55';
      case ACCENT_CYAN:   return (color)C'0,200,220';
      case ACCENT_BLUE:   return (color)C'64,156,255';
      case ACCENT_GREEN:  return (color)C'0,200,100';
      case ACCENT_RED:    return (color)C'255,70,70';
      case ACCENT_SILVER: return (color)C'190,200,210';
      case ACCENT_CUSTOM: return InpCustomAccentColor;
      default:            return (color)C'255,165,0';
     }
}

void ApplyPalette()
{
   C_WHITE  = InpTextPrimary;
   C_GRAY   = InpTextSecondary;
   C_GREEN  = InpColorBullish;
   C_YELLOW = InpColorWarning;
   C_RED    = InpColorBearish;
   C_BORDER = InpBorderColor;
   C_DARK2  = InpBarBackground;
   C_ORANGE = InpColorWarning;
   C_AMBER  = GetAccentColor();
   g_bg_color     = GetBackgroundColor();
   g_accent_color = C_AMBER;
}

color TrendColor(const string t)
{
   if(t == "BULLISH") return InpColorBullish;
   if(t == "BEARISH") return InpColorBearish;
   return InpColorNeutral;
}

int GetX(const int local_x)
{
   if(InpPanelCorner == CORNER_LEFT_UPPER || InpPanelCorner == CORNER_LEFT_LOWER)
      return InpPanelX + local_x;
   return InpPanelX + g_panel_width - local_x;
}

int GetY(const int local_y)
{
   if(InpPanelCorner == CORNER_LEFT_UPPER || InpPanelCorner == CORNER_RIGHT_UPPER)
      return InpPanelY + local_y;
   return InpPanelY + g_panel_height - local_y;
}

//============================== OBJECT MANAGEMENT ============================
void ResetRegistry()
{
   ArrayInitialize(g_obj_used, false);
   for(int i = 0; i < LBL_COUNT; i++)
     {
      g_obj_name[i]   = "";
      g_obj_text[i]   = "";
      g_last_text[i]  = "";
      g_last_color[i] = CLR_NONE;
     }
}

void CreateManagedLabel(const ENUM_LABEL id, const string suffix,
                        const int localx, const int localy,
                        const int size, const color clr, const bool bold,
                        const string init_text)
{
   string name = g_prefix + suffix;
   if(ObjectFind(0, name) < 0)
     {
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
        {
         Print("CBD: failed to create label '", name, "', error ", GetLastError());
         return;
        }
     }

   ObjectSetInteger(0, name, OBJPROP_CORNER,     InpPanelCorner);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,   size);
   ObjectSetString (0, name, OBJPROP_FONT,       bold ? "Arial Bold" : "Arial");
   ObjectSetInteger(0, name, OBJPROP_COLOR,      clr);
   ObjectSetString (0, name, OBJPROP_TEXT,       init_text);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0, name, OBJPROP_BACK,       false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER,     2);

   g_obj_name[id]   = name;
   g_obj_localx[id] = localx;
   g_obj_localy[id] = localy;
   g_obj_size[id]   = size;
   g_obj_bold[id]   = bold;
   g_obj_text[id]   = init_text;
   g_obj_used[id]   = true;
   g_last_text[id]  = init_text;
   g_last_color[id] = clr;
}

void SetLabelText(const ENUM_LABEL id, const string text, const color clr = CLR_NONE)
{
   if(!g_obj_used[id]) return;

   const bool text_changed  = (text != g_last_text[id]);
   const bool color_changed = (clr != CLR_NONE && clr != g_last_color[id]);
   if(!text_changed && !color_changed) return;

   if(text_changed)
     {
      ObjectSetString(0, g_obj_name[id], OBJPROP_TEXT, text);
      g_obj_text[id]  = text;
      g_last_text[id] = text;
      // Only mark width dirty for labels that can grow significantly
      if(id == LBL_ADRLABEL || id == LBL_BIAS || id == LBL_BREAKOUT || id == LBL_RSI ||
         id == LBL_STATUS   || id == LBL_SPREAD)
         g_width_dirty = true;
     }
   if(color_changed)
     {
      ObjectSetInteger(0, g_obj_name[id], OBJPROP_COLOR, clr);
      g_last_color[id] = clr;
     }
   g_need_redraw = true;
}

int EstimateTextWidth(const string text, const int size, const bool bold)
{
   return (int)MathCeil(StringLen(text) * size * (bold ? 0.70 : 0.58));
}

int ComputePanelWidth()
{
   if(!InpAutoWidth)
     {
      int fixed = InpFixedWidth;
      return (fixed < 220 ? 220 : fixed);
     }

   int maxw = 0;
   for(int i = 0; i < LBL_COUNT; i++)
     {
      if(!g_obj_used[i]) continue;
      int w = g_obj_localx[i] + EstimateTextWidth(g_obj_text[i], g_obj_size[i], g_obj_bold[i]);
      if(w > maxw) maxw = w;
     }
   int width = maxw + g_pad;
   int minw  = (int)MathRound(260 * g_ratio);
   if(width < minw) width = minw;

   long chart_w = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   int max_limit = (chart_w > 0 ? (int)chart_w - 20 : 900);
   if(width > max_limit) width = max_limit;
   return width;
}

void CreateOrUpdateRect(const string suffix, const color bg, const color border, const bool as_background)
{
   string name = g_prefix + suffix;
   if(ObjectFind(0, name) < 0)
     {
      if(!ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
        {
         Print("CBD: failed to create rectangle '", name, "', error ", GetLastError());
         return;
        }
     }

   ObjectSetInteger(0, name, OBJPROP_CORNER,       InpPanelCorner);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,      bg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR,  border);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE,   BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,   false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,       true);
   ObjectSetInteger(0, name, OBJPROP_BACK,         as_background);
   ObjectSetInteger(0, name, OBJPROP_ZORDER,       as_background ? 0 : 1);
}

void PositionRect(const string suffix, const int localx, const int localy, const int w, const int h)
{
   string name = g_prefix + suffix;
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, GetX(localx));
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, GetY(localy));
   ObjectSetInteger(0, name, OBJPROP_XSIZE,     w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,     h);
}

void RepositionAll()
{
   for(int i = 0; i < LBL_COUNT; i++)
      if(g_obj_used[i])
        {
         ObjectSetInteger(0, g_obj_name[i], OBJPROP_XDISTANCE, GetX(g_obj_localx[i]));
         ObjectSetInteger(0, g_obj_name[i], OBJPROP_YDISTANCE, GetY(g_obj_localy[i]));
        }

   PositionRect("BG", 0, 0, g_panel_width, g_panel_height);

   int bar_w = g_panel_width - 2 * g_pad;
   if(bar_w < 40) bar_w = 40;
   PositionRect("BARBG", g_bar_localx, g_bar_localy, bar_w, g_bar_height);
   UpdateAdrBar(bar_w);
}

void UpdateAdrBar(const int bar_w)
{
   double pct = g_adr_used_pct;
   if(pct < 0.0)   pct = 0.0;
   if(pct > 100.0) pct = 100.0;
   int fill_w = (int)MathRound((bar_w - 4) * pct / 100.0);
   if(fill_w < 2) fill_w = 2;

   color fill_color = (g_adr_used_pct < 70.0 ? C_GREEN : (g_adr_used_pct < 100.0 ? C_YELLOW : C_RED));

   if(fill_w == g_last_fill_w && fill_color == g_last_fill_color)
      return;

   PositionRect("BARFILL", g_bar_localx + 2, g_bar_localy + 2, fill_w, g_bar_height - 4);
   ObjectSetInteger(0, g_prefix + "BARFILL", OBJPROP_BGCOLOR,     fill_color);
   ObjectSetInteger(0, g_prefix + "BARFILL", OBJPROP_BORDER_COLOR, fill_color);
   g_last_fill_w     = fill_w;
   g_last_fill_color = fill_color;
   g_need_redraw     = true;
}

//----- Channel lines: create once, only move price when it changes -----
void EnsureChannelLine(const string name, const double price, const color clr)
{
   int width = InpChannelLineWidth;
   if(width < 1) width = 1;
   if(width > 5) width = 5;

   if(ObjectFind(0, name) < 0)
     {
      if(!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price))
        {
         Print("CBD: failed to create channel line '", name, "', error ", GetLastError());
         return;
        }
      ObjectSetInteger(0, name, OBJPROP_COLOR,      clr);
      ObjectSetInteger(0, name, OBJPROP_STYLE,      InpChannelLineStyle);
      ObjectSetInteger(0, name, OBJPROP_WIDTH,      width);
      ObjectSetInteger(0, name, OBJPROP_BACK,       true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
     }
   else
      ObjectSetDouble(0, name, OBJPROP_PRICE, price);
}

void UpdateChannelLines()
{
   if(!InpDrawChannelLines || g_swing_high <= 0.0 || g_swing_low <= 0.0)
     {
      if(g_channel_ready)
        {
         ObjectDelete(0, g_prefix + "CH_HIGH");
         ObjectDelete(0, g_prefix + "CH_LOW");
         g_channel_ready = false;
         g_drawn_high = g_drawn_low = 0.0;
         g_need_redraw = true;
        }
      return;
     }

   // Only touch objects when price actually changed (main freeze fix)
   if(g_swing_high != g_drawn_high)
     {
      EnsureChannelLine(g_prefix + "CH_HIGH", g_swing_high, InpChannelHighColor);
      g_drawn_high = g_swing_high;
      g_need_redraw = true;
     }
   if(g_swing_low != g_drawn_low)
     {
      EnsureChannelLine(g_prefix + "CH_LOW", g_swing_low, InpChannelLowColor);
      g_drawn_low = g_swing_low;
      g_need_redraw = true;
     }
   g_channel_ready = true;
}

void DeleteAllObjects()
{
   for(int i = 0; i < LBL_COUNT; i++)
      if(g_obj_used[i] && g_obj_name[i] != "")
         ObjectDelete(0, g_obj_name[i]);

   ObjectDelete(0, g_prefix + "BG");
   ObjectDelete(0, g_prefix + "BARBG");
   ObjectDelete(0, g_prefix + "BARFILL");
   ObjectDelete(0, g_prefix + "CH_HIGH");
   ObjectDelete(0, g_prefix + "CH_LOW");

   // Safety sweep only at shutdown (not every tick)
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringFind(name, g_prefix) == 0)
         ObjectDelete(0, name);
     }
}

//============================== DATA UPDATES =================================
bool UpdateSpreadAndMarket()
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
     {
      g_consec_tick_fail++;
      g_status = "WAITING FOR TICKS";
      return false;
     }
   g_bid = tick.bid;
   g_ask = tick.ask;
   g_last_tick_time = tick.time;

   if(g_point <= 0.0)
      g_point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   g_spread_points = (g_point > 0.0 ? (g_ask - g_bid) / g_point : 0.0);
   g_trade_mode    = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE);

   if(g_spread_points <= InpSpreadLowMax)          g_spread_status = "LOW";
   else if(g_spread_points <= InpSpreadNormalMax)  g_spread_status = "NORMAL";
   else                                             g_spread_status = "WIDE";

   datetime now = TimeCurrent();
   bool recent = (g_last_tick_time > 0 && (now - g_last_tick_time) <= 300);
   g_market_status = ((g_trade_mode != SYMBOL_TRADE_MODE_DISABLED && recent) ? "OPEN" : "CLOSED");
   g_consec_tick_fail = 0;
   return true;
}

bool UpdateTrend()
{
   // Throttle HTF + LTF trend to every 2 seconds minimum
   datetime now = TimeCurrent();
   if(now - g_last_trend_update < 2 && g_last_trend_update > 0)
      return true;

   if(CopyBuffer(g_ma_fast_handle, 0, 0, 1, g_buf1) < 1) return false;
   if(CopyBuffer(g_ma_slow_handle, 0, 0, 1, g_buf2) < 1) return false;
   g_trend_current = (g_buf1[0] > g_buf2[0] ? "BULLISH" : (g_buf1[0] < g_buf2[0] ? "BEARISH" : "NEUTRAL"));

   if(CopyBuffer(g_htf_ma_fast_handle, 0, 0, 1, g_buf3) < 1) return false;
   if(CopyBuffer(g_htf_ma_slow_handle, 0, 0, 1, g_buf4) < 1) return false;
   g_trend_htf = (g_buf3[0] > g_buf4[0] ? "BULLISH" : (g_buf3[0] < g_buf4[0] ? "BEARISH" : "NEUTRAL"));

   g_last_trend_update = now;
   return true;
}

bool UpdateMomentum()
{
   if(CopyBuffer(g_rsi_handle, 0, 0, 1, g_buf1) < 1) return false;
   g_rsi = g_buf1[0];

   if(g_rsi >= InpRSIOverbought)      g_momentum_status = "OVERBOUGHT";
   else if(g_rsi <= InpRSIOversold)   g_momentum_status = "OVERSOLD";
   else                               g_momentum_status = "NEUTRAL";

   g_momentum_bias = (g_rsi > 50.0 ? "BULLISH" : (g_rsi < 50.0 ? "BEARISH" : "NEUTRAL"));
   return true;
}

bool UpdateVolatility()
{
   datetime now = TimeCurrent();
   if(now - g_last_vol_update < 8 && g_last_vol_update > 0)
      return true;

   int need = MathMax(5, InpATRPeriod);
   if(ArraySize(g_atr_buf) < need)
     {
      ArrayResize(g_atr_buf, need);
      ArraySetAsSeries(g_atr_buf, true);
     }

   int copied = CopyBuffer(g_atr_handle, 0, 0, need, g_atr_buf);
   if(copied < need) return false;

   g_atr_current = g_atr_buf[0];
   double sum = 0.0;
   int count = 0;
   for(int i = 1; i < copied; i++)
     {
      if(g_atr_buf[i] <= 0.0) continue;
      sum += g_atr_buf[i];
      count++;
     }
   g_atr_average = (count > 0 ? sum / count : g_atr_current);
   g_atr_ratio   = (g_atr_average > 0.0 ? g_atr_current / g_atr_average : 1.0);

   if(g_atr_ratio < InpVolLowRatio)        g_volatility_status = "LOW";
   else if(g_atr_ratio > InpVolHighRatio)  g_volatility_status = "HIGH";
   else                                    g_volatility_status = "NORMAL";

   g_last_vol_update = now;
   return true;
}

bool UpdateSwingRange()
{
   datetime now = TimeCurrent();

   // Fast path: only re-check breakout vs current bid (no CopyRates)
   if(now - g_last_swing_update < 5 && g_last_swing_update > 0 && g_swing_high > 0.0)
     {
      double buffer = InpBreakoutBufferPoints * g_point;
      if(g_bid > g_swing_high + buffer)        g_breakout_status = "BULLISH BREAKOUT";
      else if(g_bid < g_swing_low - buffer)    g_breakout_status = "BEARISH BREAKOUT";
      else                                     g_breakout_status = "WITHIN CHANNEL";
      return true;
     }

   int need = InpSwingLookback;
   if(need < 3) need = 3;
   if(ArraySize(g_rates_buf) < need)
     {
      ArrayResize(g_rates_buf, need);
      ArraySetAsSeries(g_rates_buf, true);
     }

   int copied = CopyRates(_Symbol, _Period, 1, need, g_rates_buf);
   if(copied <= 0)
     {
      // Nothing at all available yet (e.g. history still downloading) - try again later.
      return false;
     }
   if(copied < need)
     {
      // Not a hard failure: work with whatever bars the terminal already has,
      // rather than freezing the panel on "WAITING FOR HISTORY" indefinitely.
      g_swing_degraded = true;
     }
   else
      g_swing_degraded = false;

   double highest = g_rates_buf[0].high;
   double lowest  = g_rates_buf[0].low;
   for(int i = 1; i < copied; i++)
     {
      if(g_rates_buf[i].high > highest) highest = g_rates_buf[i].high;
      if(g_rates_buf[i].low  < lowest)  lowest  = g_rates_buf[i].low;
     }
   g_swing_high = highest;
   g_swing_low  = lowest;

   double buffer = InpBreakoutBufferPoints * g_point;
   if(g_bid > highest + buffer)        g_breakout_status = "BULLISH BREAKOUT";
   else if(g_bid < lowest - buffer)    g_breakout_status = "BEARISH BREAKOUT";
   else                                g_breakout_status = "WITHIN CHANNEL";

   g_last_swing_update = now;
   return true;
}

bool UpdateADR()
{
   datetime now = TimeCurrent();
   if(now - g_last_adr_update < 15 && g_last_adr_update > 0)
      return true;

   int need = InpADRPeriod + 1;
   if(ArraySize(g_daily_buf) < need)
     {
      ArrayResize(g_daily_buf, need);
      ArraySetAsSeries(g_daily_buf, true);
     }

   int copied = CopyRates(_Symbol, PERIOD_D1, 0, need, g_daily_buf);
   if(copied <= 1)
     {
      // Need at least today's bar; if D1 history isn't ready yet, retry later.
      return false;
     }
   g_adr_degraded = (copied < need);

   g_today_high  = g_daily_buf[0].high;
   g_today_low   = g_daily_buf[0].low;
   g_today_range = MathMax(0.0, g_today_high - g_today_low);

   double total = 0.0;
   int count = 0;
   for(int i = 1; i <= InpADRPeriod && i < copied; i++)
     {
      double range = g_daily_buf[i].high - g_daily_buf[i].low;
      if(range <= 0.0) continue;
      total += range;
      count++;
     }
   g_adr = (count > 0 ? total / count : 0.0);

   g_today_range_points = (g_point > 0.0 ? g_today_range / g_point : 0.0);
   g_adr_points         = (g_point > 0.0 ? g_adr / g_point : 0.0);
   g_adr_used_pct       = (g_adr > 0.0 ? 100.0 * g_today_range / g_adr : 0.0);

   g_last_adr_update = now;
   return true;
}

void ClassifyBias()
{
   if(g_market_status != "OPEN")
     {
      g_bias = "MARKET CLOSED";
      return;
     }

   int votes_bull = 0, votes_bear = 0;

   if(g_trend_current == "BULLISH") votes_bull++; else if(g_trend_current == "BEARISH") votes_bear++;
   if(g_trend_htf     == "BULLISH") votes_bull++; else if(g_trend_htf     == "BEARISH") votes_bear++;
   if(g_momentum_bias == "BULLISH") votes_bull++; else if(g_momentum_bias == "BEARISH") votes_bear++;

   if(g_breakout_status == "BULLISH BREAKOUT") votes_bull++;
   else if(g_breakout_status == "BEARISH BREAKOUT") votes_bear++;

   if(g_momentum_status == "OVERBOUGHT" && votes_bull > votes_bear)
     { g_bias = "WAIT (OVERBOUGHT)"; return; }
   if(g_momentum_status == "OVERSOLD" && votes_bear > votes_bull)
     { g_bias = "WAIT (OVERSOLD)"; return; }

   if(votes_bull >= 3)      g_bias = "BUY SETUP";
   else if(votes_bear >= 3) g_bias = "SELL SETUP";
   else                     g_bias = "NEUTRAL / WAIT";
}

void UpdateAllData()
{
   bool a = UpdateSpreadAndMarket();
   bool b = UpdateTrend();
   bool c = UpdateMomentum();
   bool d = UpdateVolatility();
   bool e = UpdateSwingRange();
   bool f = UpdateADR();
   ClassifyBias();

   if(e) UpdateChannelLines();

   if(a && b && c && d && e && f)
      g_status = (g_swing_degraded || g_adr_degraded) ? "LIVE (LIMITED HISTORY)" : "LIVE";
   else if(g_status != "WAITING FOR TICKS")
      g_status = "WAITING FOR HISTORY";
}

//============================== DASHBOARD ====================================
void BuildPanel()
{
   if(!InpShowPanel) return;

   DeleteAllObjects();
   ResetRegistry();
   ApplyPalette();

   g_tf_cur = GetTimeframeText((ENUM_TIMEFRAMES)_Period);
   g_tf_htf = GetTimeframeText(InpHigherTimeframe);

   int titleSize = g_font_size + 3;
   int subSize   = g_font_size + 1;
   int rowSize   = g_font_size;
   int biasSize  = g_font_size + 2;
   int footSize  = MathMax(7, g_font_size - 2);

   int y = g_pad;

   // Title always in gold
   CreateManagedLabel(LBL_TITLE, "TITLE", g_pad, y, titleSize, (color)C'212,175,55', true,
                      "CHANNEL BREAKOUT DASHBOARD");
   y += (int)MathRound(24 * g_ratio);

   CreateManagedLabel(LBL_SUB, "SUB", g_pad, y, subSize, C_WHITE, true,
                      _Symbol + "  |  " + g_tf_cur);
   y += (int)MathRound(20 * g_ratio) + (int)MathRound(6 * g_ratio);

   CreateManagedLabel(LBL_STATUS,   "STATUS",   g_pad, y, rowSize, C_YELLOW, true,  "STATUS: INITIALIZING"); y += g_line_h;
   CreateManagedLabel(LBL_MARKET,   "MARKET",   g_pad, y, rowSize, C_GRAY,   true,  "MARKET: UNKNOWN");     y += g_line_h;
   CreateManagedLabel(LBL_TRADE,    "TRADE",    g_pad, y, rowSize, C_GRAY,   false, "TRADING MODE: UNKNOWN"); y += g_line_h;
   CreateManagedLabel(LBL_TRENDCUR, "TRENDCUR", g_pad, y, rowSize, C_GRAY,   true,  "TREND (" + g_tf_cur + "): UNKNOWN"); y += g_line_h;
   CreateManagedLabel(LBL_TRENDHTF, "TRENDHTF", g_pad, y, rowSize, C_GRAY,   true,  "TREND (" + g_tf_htf + "): UNKNOWN"); y += g_line_h;
   CreateManagedLabel(LBL_RSI,      "RSI",      g_pad, y, rowSize, C_WHITE,  false, "MOMENTUM (RSI): UNKNOWN"); y += g_line_h;
   CreateManagedLabel(LBL_VOL,      "VOL",      g_pad, y, rowSize, C_GRAY,   true,  "VOLATILITY (ATR): UNKNOWN"); y += g_line_h;
   CreateManagedLabel(LBL_SWINGHIGH,"SWINGHIGH",g_pad, y, rowSize, C_WHITE,  false, "CHANNEL HIGH: 0.00000"); y += g_line_h;
   CreateManagedLabel(LBL_SWINGLOW, "SWINGLOW", g_pad, y, rowSize, C_WHITE,  false, "CHANNEL LOW: 0.00000");  y += g_line_h;
   CreateManagedLabel(LBL_BREAKOUT, "BREAKOUT", g_pad, y, rowSize, C_GRAY,   true,  "CHANNEL STATUS: UNKNOWN"); y += g_line_h;
   CreateManagedLabel(LBL_ADRLABEL, "ADRLABEL", g_pad, y, rowSize, C_WHITE,  false, "ADR USED: 0.0 %");
   y += (int)MathRound(16 * g_ratio);

   g_bar_localx = g_pad;
   g_bar_localy = y;
   g_bar_height = (int)MathRound(12 * g_ratio);
   CreateOrUpdateRect("BARBG",  C_DARK2, C_BORDER, false);
   CreateOrUpdateRect("BARFILL", C_GREEN, C_GREEN, false);
   y += g_bar_height + (int)MathRound(12 * g_ratio);

   CreateManagedLabel(LBL_SPREAD, "SPREAD", g_pad, y, rowSize, C_WHITE, false, "SPREAD: 0.0 pts");
   y += g_line_h + (int)MathRound(4 * g_ratio);

   CreateManagedLabel(LBL_BIAS, "BIAS", g_pad, y, biasSize, C_GRAY, true, "BREAKOUT BIAS: WAIT");
   y += (int)MathRound(26 * g_ratio);

   CreateManagedLabel(LBL_TIME, "TIME", g_pad, y, rowSize, C_GRAY, false, "SERVER TIME: --:--:--");
   y += g_line_h + (int)MathRound(4 * g_ratio);

   CreateManagedLabel(LBL_FOOT, "FOOT", g_pad, y, footSize, g_accent_color, false,
                      "Channel Breakout Dashboard  ·  #" + IntegerToString(InpInstanceID));
   y += (int)MathRound(16 * g_ratio);

   g_panel_height = y + g_pad;
   CreateOrUpdateRect("BG", g_bg_color, g_accent_color, true);

   g_panel_width = ComputePanelWidth();
   g_last_fill_w = -1;
   RepositionAll();

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Channel Breakout [" + _Symbol + " " + g_tf_cur + "] #" + IntegerToString(InpInstanceID));

   // Force first full text write
   for(int i = 0; i < LBL_COUNT; i++)
     {
      g_last_text[i]  = "";
      g_last_color[i] = CLR_NONE;
     }
   g_width_dirty = false;
   g_need_redraw = true;
}

void UpdatePanel()
{
   if(!InpShowPanel) return;

   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   string server_time = StringFormat("%02d:%02d:%02d", dt.hour, dt.min, dt.sec);

   color status_clr = (g_status == "LIVE" ? C_GREEN :
                       (g_status == "LIVE (LIMITED HISTORY)" ? C_ORANGE : C_YELLOW));
   SetLabelText(LBL_STATUS, "STATUS: " + g_status, status_clr);

   SetLabelText(LBL_MARKET, "MARKET: " + g_market_status,
                (g_market_status == "OPEN" ? C_GREEN : (g_market_status == "CLOSED" ? C_RED : C_GRAY)));

   SetLabelText(LBL_TRADE, "TRADING MODE: " + TradeModeText());

   SetLabelText(LBL_TRENDCUR, "TREND (" + g_tf_cur + "): " + g_trend_current, TrendColor(g_trend_current));
   SetLabelText(LBL_TRENDHTF, "TREND (" + g_tf_htf + "): " + g_trend_htf,   TrendColor(g_trend_htf));

   color rsi_clr = ((g_momentum_status == "OVERBOUGHT" || g_momentum_status == "OVERSOLD") ? C_ORANGE : C_WHITE);
   SetLabelText(LBL_RSI, "MOMENTUM (RSI " + DoubleToString(g_rsi, 1) + "): " + g_momentum_status, rsi_clr);

   color vol_clr = (g_volatility_status == "HIGH" ? C_ORANGE : (g_volatility_status == "LOW" ? C_GRAY : C_GREEN));
   SetLabelText(LBL_VOL, "VOLATILITY (ATR): " + g_volatility_status, vol_clr);

   SetLabelText(LBL_SWINGHIGH, "CHANNEL HIGH: " + DoubleToString(g_swing_high, g_digits));
   SetLabelText(LBL_SWINGLOW,  "CHANNEL LOW: "  + DoubleToString(g_swing_low,  g_digits));

   color brk_clr = (g_breakout_status == "BULLISH BREAKOUT" ? C_GREEN :
                    (g_breakout_status == "BEARISH BREAKOUT" ? C_RED : C_GRAY));
   SetLabelText(LBL_BREAKOUT, "CHANNEL STATUS: " + g_breakout_status, brk_clr);

   SetLabelText(LBL_ADRLABEL,
                "ADR USED: " + DoubleToString(g_adr_used_pct, 1) + " %  (" +
                DoubleToString(g_today_range_points, 0) + " / " +
                DoubleToString(g_adr_points, 0) + " pts)" +
                (g_adr_degraded ? "  [PARTIAL]" : ""),
                (g_adr_degraded ? C_ORANGE : C_WHITE));

   color spread_clr = (g_spread_status == "LOW" ? C_GREEN :
                       (g_spread_status == "NORMAL" ? C_WHITE : C_ORANGE));
   SetLabelText(LBL_SPREAD, "SPREAD: " + DoubleToString(g_spread_points, 1) + " pts (" + g_spread_status + ")", spread_clr);

   color bias_clr = (g_bias == "BUY SETUP"  ? C_GREEN :
                     (g_bias == "SELL SETUP" ? C_RED :
                     (StringFind(g_bias, "WAIT") >= 0 ? C_YELLOW : C_GRAY)));
   SetLabelText(LBL_BIAS, "BREAKOUT BIAS: " + g_bias, bias_clr);

   SetLabelText(LBL_TIME, "SERVER TIME: " + server_time);

   if(g_width_dirty)
     {
      int new_w = ComputePanelWidth();
      if(new_w != g_panel_width)
        {
         g_panel_width = new_w;
         RepositionAll();
        }
      else
        {
         int bar_w = g_panel_width - 2 * g_pad;
         if(bar_w < 40) bar_w = 40;
         UpdateAdrBar(bar_w);
        }
      g_width_dirty = false;
     }
   else
     {
      int bar_w = g_panel_width - 2 * g_pad;
      if(bar_w < 40) bar_w = 40;
      UpdateAdrBar(bar_w);
     }

   if(g_need_redraw)
     {
      ChartRedraw(0);
      g_need_redraw = false;
     }
}

//============================== HANDLES ======================================
void ReleaseHandles()
{
   if(g_ma_fast_handle     != INVALID_HANDLE) { IndicatorRelease(g_ma_fast_handle);     g_ma_fast_handle     = INVALID_HANDLE; }
   if(g_ma_slow_handle     != INVALID_HANDLE) { IndicatorRelease(g_ma_slow_handle);     g_ma_slow_handle     = INVALID_HANDLE; }
   if(g_htf_ma_fast_handle != INVALID_HANDLE) { IndicatorRelease(g_htf_ma_fast_handle); g_htf_ma_fast_handle = INVALID_HANDLE; }
   if(g_htf_ma_slow_handle != INVALID_HANDLE) { IndicatorRelease(g_htf_ma_slow_handle); g_htf_ma_slow_handle = INVALID_HANDLE; }
   if(g_rsi_handle         != INVALID_HANDLE) { IndicatorRelease(g_rsi_handle);         g_rsi_handle         = INVALID_HANDLE; }
   if(g_atr_handle         != INVALID_HANDLE) { IndicatorRelease(g_atr_handle);         g_atr_handle         = INVALID_HANDLE; }
}

//============================== EVENTS =======================================
int OnInit()
{
   g_font_size = NormalizeFontSize(InpFontSize);
   g_ratio     = g_font_size / 10.0;
   g_pad       = (int)MathRound(14 * g_ratio);
   g_line_h    = (int)MathRound(20 * g_ratio);

   ApplyPalette();

   if(InpFastMAPeriod < 1 || InpSlowMAPeriod <= InpFastMAPeriod)
     { Print("CBD: invalid MA periods."); return INIT_PARAMETERS_INCORRECT; }
   if(InpRSIPeriod < 2 || InpRSIOversold < 0.0 || InpRSIOverbought > 100.0 || InpRSIOversold >= InpRSIOverbought)
     { Print("CBD: invalid RSI settings."); return INIT_PARAMETERS_INCORRECT; }
   if(InpATRPeriod < 2 || InpVolLowRatio <= 0.0 || InpVolHighRatio < InpVolLowRatio)
     { Print("CBD: invalid ATR settings."); return INIT_PARAMETERS_INCORRECT; }
   if(InpSwingLookback < 3 || InpBreakoutBufferPoints < 0.0)
     { Print("CBD: invalid channel settings."); return INIT_PARAMETERS_INCORRECT; }
   if(InpADRPeriod < 2)
     { Print("CBD: invalid ADR period."); return INIT_PARAMETERS_INCORRECT; }
   if(InpTimerSeconds < 1)
     { Print("CBD: timer must be >= 1."); return INIT_PARAMETERS_INCORRECT; }
   if(InpSpreadLowMax < 0.0 || InpSpreadNormalMax < InpSpreadLowMax)
     { Print("CBD: invalid spread thresholds."); return INIT_PARAMETERS_INCORRECT; }

   g_prefix = "CBD" + IntegerToString(InpInstanceID) + "_" +
              IntegerToString((long)ChartID() % 100000) + "_";

   g_point  = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   g_digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   g_swing_degraded   = false;
   g_adr_degraded     = false;
   g_consec_tick_fail = 0;

   g_ma_fast_handle     = iMA(_Symbol, _Period, InpFastMAPeriod, 0, InpMAMethod, InpMAPrice);
   g_ma_slow_handle     = iMA(_Symbol, _Period, InpSlowMAPeriod, 0, InpMAMethod, InpMAPrice);
   g_htf_ma_fast_handle = iMA(_Symbol, InpHigherTimeframe, InpFastMAPeriod, 0, InpMAMethod, InpMAPrice);
   g_htf_ma_slow_handle = iMA(_Symbol, InpHigherTimeframe, InpSlowMAPeriod, 0, InpMAMethod, InpMAPrice);
   g_rsi_handle         = iRSI(_Symbol, _Period, InpRSIPeriod, PRICE_CLOSE);
   g_atr_handle         = iATR(_Symbol, _Period, InpATRPeriod);

   if(g_ma_fast_handle == INVALID_HANDLE || g_ma_slow_handle == INVALID_HANDLE ||
      g_htf_ma_fast_handle == INVALID_HANDLE || g_htf_ma_slow_handle == INVALID_HANDLE ||
      g_rsi_handle == INVALID_HANDLE || g_atr_handle == INVALID_HANDLE)
     {
      Print("CBD: handle create failed. Error ", GetLastError());
      ReleaseHandles();
      return INIT_FAILED;
     }

   ArrayResize(g_atr_buf,   MathMax(5, InpATRPeriod));
   ArrayResize(g_rates_buf, MathMax(3, InpSwingLookback));
   ArrayResize(g_daily_buf, InpADRPeriod + 1);
   ArraySetAsSeries(g_atr_buf,   true);
   ArraySetAsSeries(g_rates_buf, true);
   ArraySetAsSeries(g_daily_buf, true);

   BuildPanel();
   UpdateAllData();
   UpdatePanel();

   int timer_sec = InpTimerSeconds;
   if(timer_sec < 1) timer_sec = 1;
   if(!EventSetTimer(timer_sec))
     {
      Print("CBD: EventSetTimer failed. Error ", GetLastError());
      ReleaseHandles();
      DeleteAllObjects();
      return INIT_FAILED;
     }

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   ReleaseHandles();
   DeleteAllObjects();
   ChartRedraw(0);
}

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
   return rates_total;
}

void OnTimer()
{
   UpdateAllData();
   UpdatePanel();
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   // React immediately to window/chart resize so the panel width clamp and
   // corner-based positions stay correct without waiting for the next timer tick.
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      if(InpShowPanel && InpAutoWidth)
        {
         g_width_dirty = true;
         UpdatePanel();
        }
     }
}
//+------------------------------------------------------------------+
