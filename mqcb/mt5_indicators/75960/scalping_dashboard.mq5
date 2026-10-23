//+------------------------------------------------------------------+
//|                                          Scalping Dashboard MT5  |
//|                                                                  |
//|           Professional Trading Utility for MetaTrader 5          |
//|                          Copyright (c) 2026 Marian Beceanu       |
//|                   https://www.mql5.com/en/users/zorbacc          |
//|                          Email: marian.beceanu@gmail.com         |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2026 Marian Beceanu"
#property link      "https://www.mql5.com/en/users/zorbacc"
#property version   "1.70"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Scalping Strategy Dashboard - Hardened for live trading"

enum ENUM_CUSTOM_COLOR
{
    CLR_DARK_BLUE   = C'8,23,38',     // Dark Blue
    CLR_BLACK       = C'10,10,10',    // Deep Black
    CLR_CHARCOAL    = C'30,30,30',    // Charcoal Gray
    CLR_NAVY        = C'10,25,47',    // Navy
    CLR_GOLD        = C'212,175,55',  // Gold
    CLR_WHITE       = C'245,245,245', // White
    CLR_GRAY        = C'169,176,184', // Gray
    CLR_GREEN       = C'0,200,83',    // Profit Green
    CLR_RED         = C'255,82,82',   // Loss Red
    CLR_YELLOW      = C'255,215,0'    // Yellow
};

input group "========== SCALPING SETTINGS =========="
input int                 InpFastEMA               = 5;
input int                 InpSlowEMA               = 20;
input double              InpMaxSpread             = 12.0;
input int                 InpTimerSeconds          = 1;

input group "========== UI POSITION & SCALING =========="
input bool                InpShowPanel             = true;
input int                 InpPanelX                = 15;
input int                 InpPanelY                = 15;
input int                 InpBaseFontSize          = 10;

input group "========== COLOR THEME (DROPDOWN) =========="
input ENUM_CUSTOM_COLOR   InpColorBackground       = CLR_DARK_BLUE;
input ENUM_CUSTOM_COLOR   InpColorGold             = CLR_GOLD;
input ENUM_CUSTOM_COLOR   InpColorWhite            = CLR_WHITE;
input ENUM_CUSTOM_COLOR   InpColorGray             = CLR_GRAY;
input ENUM_CUSTOM_COLOR   InpColorGreen            = CLR_GREEN;
input ENUM_CUSTOM_COLOR   InpColorRed              = CLR_RED;
input color               InpColorBorder           = C'62,76,89';
input color               InpColorDarkBox          = C'5,14,24';

//--- runtime (validated/derived) state -------------------------------
string g_prefix         = "SCALP_";
int    g_fast_handle    = INVALID_HANDLE;
int    g_slow_handle    = INVALID_HANDLE;
double g_point           = 0.0;
double g_max_spread      = 0.0;
int    g_timer_seconds   = 1;
int    g_panel_width     = 420;
bool   g_panel_built     = false;
bool   g_tick_warned     = false;   // avoid log-spam on repeated tick failures
bool   g_buffer_warned   = false;   // avoid log-spam on repeated CopyBuffer failures

//+------------------------------------------------------------------+
//| Timeframe -> short text                                          |
//+------------------------------------------------------------------+
string GetCurrentTimeframeString()
{
   switch(_Period)
   {
      case PERIOD_M1:  return "M1";
      case PERIOD_M2:  return "M2";
      case PERIOD_M3:  return "M3";
      case PERIOD_M4:  return "M4";
      case PERIOD_M5:  return "M5";
      case PERIOD_M6:  return "M6";
      case PERIOD_M10: return "M10";
      case PERIOD_M12: return "M12";
      case PERIOD_M15: return "M15";
      case PERIOD_M20: return "M20";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H2:  return "H2";
      case PERIOD_H3:  return "H3";
      case PERIOD_H4:  return "H4";
      case PERIOD_H6:  return "H6";
      case PERIOD_H8:  return "H8";
      case PERIOD_H12: return "H12";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN1";
      default:         return EnumToString(_Period);
   }
}

//+------------------------------------------------------------------+
//| Safe indicator-handle release                                    |
//+------------------------------------------------------------------+
void SafeReleaseHandle(int &handle)
{
   if(handle != INVALID_HANDLE)
   {
      IndicatorRelease(handle);
      handle = INVALID_HANDLE;
   }
}

//+------------------------------------------------------------------+
//| Object helpers (defensive: never throw, always report failures)  |
//+------------------------------------------------------------------+
bool CreateRectangle(string name,int x,int y,int w,int h,color bg,color border)
{
   ObjectDelete(0, name);

   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
   {
      Print("SCALP: failed to create rectangle '",name,"' err=",GetLastError());
      return false;
   }

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   return true;
}

bool CreateLabel(string name,string text,int x,int y,int fontsize,color clr,bool bold=false)
{
   ObjectDelete(0, name);

   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
   {
      Print("SCALP: failed to create label '",name,"' err=",GetLastError());
      return false;
   }

   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT, bold ? "Arial Bold" : "Arial");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   return true;
}

//+------------------------------------------------------------------+
//| Remove every object owned by this instance                       |
//+------------------------------------------------------------------+
void DeletePanel()
{
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, -1, -1);
      if(name != "" && StringFind(name, g_prefix) == 0)
         ObjectDelete(0, name);
   }
   g_panel_built = false;
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Build the static part of the panel                                |
//+------------------------------------------------------------------+
void BuildPanel()
{
   if(!InpShowPanel) return;
   DeletePanel(); // clean slate before rebuilding

   int x = InpPanelX, y = InpPanelY;

   int titleSize  = InpBaseFontSize + 4;
   int subSize    = InpBaseFontSize;
   int textSize   = InpBaseFontSize;
   int signalSize = InpBaseFontSize + 2;
   int footSize   = MathMax(6, InpBaseFontSize - 1);

   int paddingY = (int)(InpBaseFontSize * 1.6);
   int currentY = y + 14;

   int rowTitleY = currentY;  currentY += (int)(titleSize * 1.4);
   int rowSubY   = currentY;  currentY += (int)(subSize   * 2.2);
   int rowSymY   = currentY;  currentY += paddingY;
   int rowSprY   = currentY;  currentY += paddingY;
   int rowMomY   = currentY;  currentY += paddingY;
   int rowSigY   = currentY;  currentY += (int)(signalSize * 1.8);
   int barY      = currentY;  currentY += 28;
   int footY     = currentY;  currentY += (int)(footSize * 1.8);

   // Panel width adapts to the symbol name length so long symbols
   // (e.g. "EURUSD.i", "US30.cash") never get clipped.
   int estWidth   = 220 + StringLen(_Symbol) * 8;
   g_panel_width  = MathMax(420, estWidth);
   int panelHeight = currentY - y;

   CreateRectangle(g_prefix+"BG",x,y,g_panel_width,panelHeight,(color)InpColorBackground,InpColorGold);

   CreateLabel(g_prefix+"TITLE","SCALPING SYSTEM",x+18,rowTitleY,titleSize,(color)InpColorGold,true);
   CreateLabel(g_prefix+"SUB","RAPID-FIRE & PIRANHA",x+18,rowSubY,subSize,(color)InpColorWhite,true);

   string symbolText = "SYMBOL: " + _Symbol + " (" + GetCurrentTimeframeString() + ")";
   CreateLabel(g_prefix+"SYMBOL",symbolText,x+18,rowSymY,textSize,(color)InpColorWhite,true);

   CreateLabel(g_prefix+"SPREAD","SPREAD: -- pts",x+18,rowSprY,textSize,(color)InpColorWhite);
   CreateLabel(g_prefix+"SPREADSTAT","CHECKING...",x+g_panel_width-170,rowSprY,textSize,(color)InpColorGray,true);

   CreateLabel(g_prefix+"MOMENTUM","MOMENTUM: FLAT",x+18,rowMomY,textSize,(color)InpColorGray,true);
   CreateLabel(g_prefix+"SIGNAL","SIGNAL: WAIT",x+18,rowSigY,signalSize,(color)InpColorGold,true);

   CreateRectangle(g_prefix+"PB_BG",x+18,barY,g_panel_width-36,16,InpColorDarkBox,InpColorBorder);
   CreateRectangle(g_prefix+"PB_FILL",x+20,barY+2,1,12,(color)InpColorGreen,(color)InpColorGreen);

   CreateLabel(g_prefix+"FOOT","Professional Scalper MT5",x+18,footY,footSize,(color)InpColorGold);

   g_panel_built = true;
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Refresh the dynamic parts of the panel                            |
//+------------------------------------------------------------------+
void UpdatePanel()
{
   if(!InpShowPanel || !g_panel_built) return;

   // --- tick data: bail out safely if unavailable, keep last state ---
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
   {
      if(!g_tick_warned) { Print("SCALP: SymbolInfoTick failed, err=",GetLastError()); g_tick_warned = true; }
      return;
   }
   g_tick_warned = false;

   if(tick.bid <= 0.0 || tick.ask <= 0.0 || tick.ask < tick.bid || g_point <= 0.0)
      return; // corrupt/stale quote or invalid symbol point - skip this cycle

   double spd = (tick.ask - tick.bid) / g_point;
   bool spread_ok = (spd <= g_max_spread);

   // --- EMA buffers: bail out safely if not enough history yet ---
   double fast_val[1], slow_val[1];
   if(CopyBuffer(g_fast_handle,0,0,1,fast_val) != 1 ||
      CopyBuffer(g_slow_handle,0,0,1,slow_val) != 1)
   {
      if(!g_buffer_warned) { Print("SCALP: CopyBuffer failed, err=",GetLastError()); g_buffer_warned = true; }
      return;
   }
   g_buffer_warned = false;

   string mom = "FLAT";
   color  mom_col = (color)InpColorGray;
   string sig = "STANDBY";
   color  sig_col = (color)InpColorGold;

   int max_bar_width = g_panel_width - 40;
   int fill_w = 50;

   if(fast_val[0] > slow_val[0])
   {
      mom = "BULLISH"; mom_col = (color)InpColorGreen;
      sig = spread_ok ? "BUY SETUP" : "SPREAD HIGH";
      sig_col = spread_ok ? (color)InpColorGreen : (color)InpColorRed;
      fill_w = max_bar_width - 100;
   }
   else if(fast_val[0] < slow_val[0])
   {
      mom = "BEARISH"; mom_col = (color)InpColorRed;
      sig = spread_ok ? "SELL SETUP" : "SPREAD HIGH";
      sig_col = (color)InpColorRed;
      fill_w = max_bar_width - 100;
   }

   fill_w = MathMax(1, MathMin(fill_w, max_bar_width));

   ObjectSetString(0,g_prefix+"SPREAD",OBJPROP_TEXT,"SPREAD: "+DoubleToString(spd,1)+" pts");
   ObjectSetString(0,g_prefix+"SPREADSTAT",OBJPROP_TEXT,spread_ok ? "SPREAD OK" : "HIGH SPREAD");
   ObjectSetInteger(0,g_prefix+"SPREADSTAT",OBJPROP_COLOR,spread_ok ? (color)InpColorGreen : (color)InpColorRed);

   ObjectSetString(0,g_prefix+"MOMENTUM",OBJPROP_TEXT,"MOMENTUM: "+mom);
   ObjectSetInteger(0,g_prefix+"MOMENTUM",OBJPROP_COLOR,mom_col);

   ObjectSetString(0,g_prefix+"SIGNAL",OBJPROP_TEXT,"SIGNAL: "+sig);
   ObjectSetInteger(0,g_prefix+"SIGNAL",OBJPROP_COLOR,sig_col);

   ObjectSetInteger(0,g_prefix+"PB_FILL",OBJPROP_XSIZE,fill_w);
   ObjectSetInteger(0,g_prefix+"PB_FILL",OBJPROP_BGCOLOR,sig_col);
   ObjectSetInteger(0,g_prefix+"PB_FILL",OBJPROP_BORDER_COLOR,sig_col);

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Expert initialization                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- validate & clamp inputs so a bad parameter can never crash / freeze the terminal
   if(InpFastEMA <= 0 || InpSlowEMA <= 0)
   {
      Print("SCALP: EMA periods must be positive. Fast=",InpFastEMA," Slow=",InpSlowEMA);
      return INIT_PARAMETERS_INCORRECT;
   }
   if(InpFastEMA >= InpSlowEMA)
   {
      Print("SCALP: Fast EMA (",InpFastEMA,") must be smaller than Slow EMA (",InpSlowEMA,")");
      return INIT_PARAMETERS_INCORRECT;
   }

   g_max_spread    = MathMax(0.0, InpMaxSpread);
   g_timer_seconds = MathMax(1, InpTimerSeconds);

   g_point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(g_point <= 0.0)
   {
      Print("SCALP: invalid SYMBOL_POINT for ",_Symbol,", err=",GetLastError());
      return INIT_FAILED;
   }

   // unique prefix per symbol/timeframe/chart -> no collisions if the
   // indicator is (re)attached multiple times or across several charts
   g_prefix = StringFormat("SCALP_%s_%d_%I64d_", _Symbol, (int)_Period, ChartID());

   g_fast_handle = iMA(_Symbol,_Period,InpFastEMA,0,MODE_EMA,PRICE_CLOSE);
   g_slow_handle = iMA(_Symbol,_Period,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE);

   if(g_fast_handle == INVALID_HANDLE || g_slow_handle == INVALID_HANDLE)
   {
      Print("SCALP: failed to create EMA handles, err=",GetLastError());
      SafeReleaseHandle(g_fast_handle);
      SafeReleaseHandle(g_slow_handle);
      return INIT_FAILED;
   }

   BuildPanel();
   UpdatePanel();

   if(!EventSetTimer(g_timer_seconds))
   {
      Print("SCALP: EventSetTimer failed, err=",GetLastError());
      SafeReleaseHandle(g_fast_handle);
      SafeReleaseHandle(g_slow_handle);
      DeletePanel();
      return INIT_FAILED;
   }

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization - always leaves the chart clean           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   SafeReleaseHandle(g_fast_handle);
   SafeReleaseHandle(g_slow_handle);
   DeletePanel();
}

//+------------------------------------------------------------------+
//| Custom indicator calculation - panel only, no buffers needed      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[])
{
   return rates_total;
}

//+------------------------------------------------------------------+
//| Timer - drives the live refresh, decoupled from tick load         |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(IsStopped()) return;
   UpdatePanel();
}

//+------------------------------------------------------------------+
//| Keep the panel in sync if the terminal recolors/resizes the chart |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(id == CHARTEVENT_CHART_CHANGE && InpShowPanel && !g_panel_built)
      BuildPanel();
}
