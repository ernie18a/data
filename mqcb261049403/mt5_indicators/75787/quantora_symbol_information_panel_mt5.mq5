//+------------------------------------------------------------------+
//|               Quantora Symbol Information Panel MT5              |
//|           Professional Trading Utility for MetaTrader 5          |
//|                                                                  |
//| Copyright © 2026 Quantora                                        |
//| https://www.mql5.com/en/users/quantora/seller                    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Professional symbol information panel for MetaTrader 5."
#property description "Displays live symbol, spread, tick, volume, swap, margin and trading information."

input group "========== SYMBOL SETTINGS =========="
input bool                InpUseCurrentSymbol   = true;
input string              InpCustomSymbol       = "";

input group "========== DASHBOARD =========="
input bool                InpShowPanel          = true;
input ENUM_BASE_CORNER    InpPanelCorner        = CORNER_LEFT_UPPER;
input int                 InpPanelX             = 15;
input int                 InpPanelY             = 145;
input int                 InpTimerSeconds       = 1;

//============================== BRAND COLORS ===============================
#define Q_BG       C'8,23,38'
#define Q_GOLD     C'212,175,55'
#define Q_WHITE    C'245,245,245'
#define Q_GRAY     C'169,176,184'
#define Q_GREEN    C'0,200,83'
#define Q_YELLOW   C'255,193,7'
#define Q_RED      C'255,82,82'
#define Q_BLUE     C'32,93,145'
#define Q_BORDER   C'62,76,89'

//============================== STATE ======================================
string g_prefix="QSIP5_";
string g_symbol="";
string g_status="INITIALIZING";
string g_market_status="UNKNOWN";
string g_trade_status="UNKNOWN";

double g_bid=0.0;
double g_ask=0.0;
double g_spread_points=0.0;
int    g_digits=0;
double g_point=0.0;
double g_tick_size=0.0;
double g_tick_value=0.0;
double g_contract_size=0.0;
double g_min_lot=0.0;
double g_max_lot=0.0;
double g_lot_step=0.0;
long   g_stops_level=0;
long   g_freeze_level=0;
double g_swap_long=0.0;
double g_swap_short=0.0;
string g_base_currency="";
string g_profit_currency="";
string g_margin_currency="";
string g_account_currency="";
double g_margin_initial=0.0;
double g_margin_maintenance=0.0;
long   g_trade_mode=SYMBOL_TRADE_MODE_DISABLED;
datetime g_last_tick_time=0;

//============================== HELPERS ====================================
string SelectedSymbol()
{
   if(InpUseCurrentSymbol || StringLen(InpCustomSymbol)==0)
      return _Symbol;
   return InpCustomSymbol;
}

string TradeModeText(long mode)
{
   switch((ENUM_SYMBOL_TRADE_MODE)mode)
   {
      case SYMBOL_TRADE_MODE_DISABLED:  return "DISABLED";
      case SYMBOL_TRADE_MODE_LONGONLY:  return "LONG ONLY";
      case SYMBOL_TRADE_MODE_SHORTONLY: return "SHORT ONLY";
      case SYMBOL_TRADE_MODE_CLOSEONLY: return "CLOSE ONLY";
      case SYMBOL_TRADE_MODE_FULL:      return "FULL";
   }
   return "UNKNOWN";
}

bool UpdateSymbolData()
{
   g_symbol=SelectedSymbol();

   if(!SymbolSelect(g_symbol,true))
   {
      g_status="SYMBOL NOT AVAILABLE";
      return false;
   }

   MqlTick tick;
   if(!SymbolInfoTick(g_symbol,tick))
   {
      g_status="WAITING FOR TICKS";
      return false;
   }

   g_bid=tick.bid;
   g_ask=tick.ask;
   g_last_tick_time=tick.time;

   g_digits=(int)SymbolInfoInteger(g_symbol,SYMBOL_DIGITS);
   g_point=SymbolInfoDouble(g_symbol,SYMBOL_POINT);
   g_tick_size=SymbolInfoDouble(g_symbol,SYMBOL_TRADE_TICK_SIZE);
   g_tick_value=SymbolInfoDouble(g_symbol,SYMBOL_TRADE_TICK_VALUE);
   g_contract_size=SymbolInfoDouble(g_symbol,SYMBOL_TRADE_CONTRACT_SIZE);

   g_min_lot=SymbolInfoDouble(g_symbol,SYMBOL_VOLUME_MIN);
   g_max_lot=SymbolInfoDouble(g_symbol,SYMBOL_VOLUME_MAX);
   g_lot_step=SymbolInfoDouble(g_symbol,SYMBOL_VOLUME_STEP);

   g_stops_level=SymbolInfoInteger(g_symbol,SYMBOL_TRADE_STOPS_LEVEL);
   g_freeze_level=SymbolInfoInteger(g_symbol,SYMBOL_TRADE_FREEZE_LEVEL);

   g_swap_long=SymbolInfoDouble(g_symbol,SYMBOL_SWAP_LONG);
   g_swap_short=SymbolInfoDouble(g_symbol,SYMBOL_SWAP_SHORT);

   g_base_currency=SymbolInfoString(g_symbol,SYMBOL_CURRENCY_BASE);
   g_profit_currency=SymbolInfoString(g_symbol,SYMBOL_CURRENCY_PROFIT);
   g_margin_currency=SymbolInfoString(g_symbol,SYMBOL_CURRENCY_MARGIN);
   g_account_currency=AccountInfoString(ACCOUNT_CURRENCY);

   g_margin_initial=SymbolInfoDouble(g_symbol,SYMBOL_MARGIN_INITIAL);
   g_margin_maintenance=SymbolInfoDouble(g_symbol,SYMBOL_MARGIN_MAINTENANCE);

   g_trade_mode=SymbolInfoInteger(g_symbol,SYMBOL_TRADE_MODE);
   g_trade_status=TradeModeText(g_trade_mode);

   if(g_point>0.0)
      g_spread_points=(g_ask-g_bid)/g_point;
   else
      g_spread_points=0.0;

   datetime now=TimeCurrent();
   bool recent_tick=(g_last_tick_time>0 && (now-g_last_tick_time)<=300);
   bool market_open=(g_trade_mode!=SYMBOL_TRADE_MODE_DISABLED && recent_tick);

   g_market_status=(market_open ? "OPEN" : "CLOSED");
   g_status="LIVE DATA READY";

   return true;
}

//============================== OBJECT HELPERS =============================
bool CreateRectangle(string name,int x,int y,int width,int height,color background,color border)
{
   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
      return false;

   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,background);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   return true;
}

bool CreateLabel(string name,string text,int x,int y,int size,color text_color,bool bold=false)
{
   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
      return false;

   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,text_color);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,name,OBJPROP_FONT,(bold ? "Arial Bold" : "Arial"));
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   return true;
}

void DeletePanel()
{
   for(int i=ObjectsTotal(0)-1;i>=0;i--)
   {
      string name=ObjectName(0,i);
      if(StringFind(name,g_prefix)==0)
         ObjectDelete(0,name);
   }
}

//============================== DASHBOARD ==================================
void BuildPanel()
{
   if(!InpShowPanel)
      return;

   DeletePanel();

   int x=InpPanelX;
   int y=InpPanelY;

   CreateRectangle(g_prefix+"BG",x,y,560,560,Q_BG,Q_GOLD);

   CreateLabel(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   CreateLabel(g_prefix+"SUB","SYMBOL INFORMATION PANEL",x+18,y+38,11,Q_WHITE,true);
   CreateLabel(g_prefix+"VER","MT5 v1.00",x+470,y+18,9,Q_GRAY);

   CreateLabel(g_prefix+"STATUS","STATUS: INITIALIZING",x+18,y+74,10,Q_GREEN,true);

   CreateLabel(g_prefix+"SYMBOL","SYMBOL: --",x+18,y+108,10,Q_WHITE,true);
   CreateLabel(g_prefix+"MARKET","MARKET: UNKNOWN",x+300,y+108,10,Q_GRAY,true);

   CreateLabel(g_prefix+"BID","BID: 0.00000",x+18,y+144,10,Q_WHITE);
   CreateLabel(g_prefix+"ASK","ASK: 0.00000",x+200,y+144,10,Q_WHITE);
   CreateLabel(g_prefix+"SPREAD","SPREAD: 0.0 pts",x+382,y+144,10,Q_GOLD,true);

   CreateLabel(g_prefix+"DIGITS","DIGITS: 0",x+18,y+180,10,Q_GRAY);
   CreateLabel(g_prefix+"POINT","POINT: 0.00000",x+200,y+180,10,Q_GRAY);
   CreateLabel(g_prefix+"TICKSIZE","TICK SIZE: 0.00000",x+382,y+180,10,Q_GRAY);

   CreateLabel(g_prefix+"TICKVALUE","TICK VALUE: 0.00",x+18,y+216,10,Q_WHITE);
   CreateLabel(g_prefix+"CONTRACT","CONTRACT SIZE: 0.00",x+300,y+216,10,Q_WHITE);

   CreateLabel(g_prefix+"MINLOT","MIN LOT: 0.00",x+18,y+252,10,Q_GRAY);
   CreateLabel(g_prefix+"MAXLOT","MAX LOT: 0.00",x+200,y+252,10,Q_GRAY);
   CreateLabel(g_prefix+"LOTSTEP","LOT STEP: 0.00",x+382,y+252,10,Q_GRAY);

   CreateLabel(g_prefix+"STOPS","STOPS LEVEL: 0",x+18,y+288,10,Q_WHITE);
   CreateLabel(g_prefix+"FREEZE","FREEZE LEVEL: 0",x+300,y+288,10,Q_WHITE);

   CreateLabel(g_prefix+"SWAPL","SWAP LONG: 0.00",x+18,y+324,10,Q_WHITE);
   CreateLabel(g_prefix+"SWAPS","SWAP SHORT: 0.00",x+300,y+324,10,Q_WHITE);

   CreateLabel(g_prefix+"BASE","BASE CURRENCY: --",x+18,y+360,10,Q_GRAY);
   CreateLabel(g_prefix+"PROFIT","PROFIT CURRENCY: --",x+300,y+360,10,Q_GRAY);

   CreateLabel(g_prefix+"MARGCUR","MARGIN CURRENCY: --",x+18,y+396,10,Q_GRAY);
   CreateLabel(g_prefix+"ACCCUR","ACCOUNT CURRENCY: --",x+300,y+396,10,Q_GRAY);

   CreateLabel(g_prefix+"MARGININIT","INITIAL MARGIN: 0.00",x+18,y+432,10,Q_WHITE);
   CreateLabel(g_prefix+"MARGINMAINT","MAINT. MARGIN: 0.00",x+300,y+432,10,Q_WHITE);

   CreateLabel(g_prefix+"TRADE","TRADING MODE: UNKNOWN",x+18,y+468,11,Q_GOLD,true);
   CreateLabel(g_prefix+"TIME","SERVER TIME: --:--:--",x+300,y+468,10,Q_GRAY);

   CreateLabel(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",x+18,y+532,9,Q_GOLD);

   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel)
      return;

   color status_color=(g_status=="LIVE DATA READY" ? Q_GREEN : Q_YELLOW);
   color market_color=(g_market_status=="OPEN" ? Q_GREEN : Q_RED);
   color trade_color=(g_trade_mode==SYMBOL_TRADE_MODE_FULL ? Q_GREEN :
                      g_trade_mode==SYMBOL_TRADE_MODE_DISABLED ? Q_RED : Q_YELLOW);

   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   string server_time=StringFormat("%02d:%02d:%02d",dt.hour,dt.min,dt.sec);

   ObjectSetString(0,g_prefix+"STATUS",OBJPROP_TEXT,"STATUS: "+g_status);
   ObjectSetInteger(0,g_prefix+"STATUS",OBJPROP_COLOR,status_color);

   ObjectSetString(0,g_prefix+"SYMBOL",OBJPROP_TEXT,"SYMBOL: "+g_symbol);

   ObjectSetString(0,g_prefix+"MARKET",OBJPROP_TEXT,"MARKET: "+g_market_status);
   ObjectSetInteger(0,g_prefix+"MARKET",OBJPROP_COLOR,market_color);

   ObjectSetString(0,g_prefix+"BID",OBJPROP_TEXT,"BID: "+DoubleToString(g_bid,g_digits));
   ObjectSetString(0,g_prefix+"ASK",OBJPROP_TEXT,"ASK: "+DoubleToString(g_ask,g_digits));
   ObjectSetString(0,g_prefix+"SPREAD",OBJPROP_TEXT,
                   "SPREAD: "+DoubleToString(g_spread_points,1)+" pts");

   ObjectSetString(0,g_prefix+"DIGITS",OBJPROP_TEXT,"DIGITS: "+IntegerToString(g_digits));
   ObjectSetString(0,g_prefix+"POINT",OBJPROP_TEXT,
                   "POINT: "+DoubleToString(g_point,g_digits));
   ObjectSetString(0,g_prefix+"TICKSIZE",OBJPROP_TEXT,
                   "TICK SIZE: "+DoubleToString(g_tick_size,g_digits));

   ObjectSetString(0,g_prefix+"TICKVALUE",OBJPROP_TEXT,
                   "TICK VALUE: "+DoubleToString(g_tick_value,4)+" "+g_account_currency);
   ObjectSetString(0,g_prefix+"CONTRACT",OBJPROP_TEXT,
                   "CONTRACT SIZE: "+DoubleToString(g_contract_size,2));

   ObjectSetString(0,g_prefix+"MINLOT",OBJPROP_TEXT,
                   "MIN LOT: "+DoubleToString(g_min_lot,2));
   ObjectSetString(0,g_prefix+"MAXLOT",OBJPROP_TEXT,
                   "MAX LOT: "+DoubleToString(g_max_lot,2));
   ObjectSetString(0,g_prefix+"LOTSTEP",OBJPROP_TEXT,
                   "LOT STEP: "+DoubleToString(g_lot_step,4));

   ObjectSetString(0,g_prefix+"STOPS",OBJPROP_TEXT,
                   "STOPS LEVEL: "+IntegerToString((int)g_stops_level));
   ObjectSetString(0,g_prefix+"FREEZE",OBJPROP_TEXT,
                   "FREEZE LEVEL: "+IntegerToString((int)g_freeze_level));

   ObjectSetString(0,g_prefix+"SWAPL",OBJPROP_TEXT,
                   "SWAP LONG: "+DoubleToString(g_swap_long,2));
   ObjectSetString(0,g_prefix+"SWAPS",OBJPROP_TEXT,
                   "SWAP SHORT: "+DoubleToString(g_swap_short,2));

   ObjectSetString(0,g_prefix+"BASE",OBJPROP_TEXT,
                   "BASE CURRENCY: "+g_base_currency);
   ObjectSetString(0,g_prefix+"PROFIT",OBJPROP_TEXT,
                   "PROFIT CURRENCY: "+g_profit_currency);

   ObjectSetString(0,g_prefix+"MARGCUR",OBJPROP_TEXT,
                   "MARGIN CURRENCY: "+g_margin_currency);
   ObjectSetString(0,g_prefix+"ACCCUR",OBJPROP_TEXT,
                   "ACCOUNT CURRENCY: "+g_account_currency);

   ObjectSetString(0,g_prefix+"MARGININIT",OBJPROP_TEXT,
                   "INITIAL MARGIN: "+DoubleToString(g_margin_initial,2));
   ObjectSetString(0,g_prefix+"MARGINMAINT",OBJPROP_TEXT,
                   "MAINT. MARGIN: "+DoubleToString(g_margin_maintenance,2));

   ObjectSetString(0,g_prefix+"TRADE",OBJPROP_TEXT,
                   "TRADING MODE: "+g_trade_status);
   ObjectSetInteger(0,g_prefix+"TRADE",OBJPROP_COLOR,trade_color);

   ObjectSetString(0,g_prefix+"TIME",OBJPROP_TEXT,
                   "SERVER TIME: "+server_time);

   ChartRedraw();
}

//============================== INDICATOR EVENTS ===========================
int OnInit()
{
   if(InpTimerSeconds<1)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Quantora Symbol Information Panel MT5 v1.00");

   g_symbol=SelectedSymbol();

   BuildPanel();
   UpdateSymbolData();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora Symbol Information Panel MT5: EventSetTimer failed. Error ",
            GetLastError());
      return INIT_FAILED;
   }

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   DeletePanel();
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
   UpdateSymbolData();
   UpdatePanel();
}

//===========================================================
// Developed by Quantora
//
// More Professional Trading Robots
//
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
