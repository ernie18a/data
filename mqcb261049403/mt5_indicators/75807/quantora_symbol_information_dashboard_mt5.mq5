//+------------------------------------------------------------------+
//|             Quantora Symbol Information Dashboard MT5            |
//|           Professional Trading Utility for MetaTrader 5          |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Professional symbol information dashboard for MetaTrader 5."
#property description "Displays live pricing, contract specifications, volume limits, margin, ATR and account details."

input group "========== SYMBOL SETTINGS =========="
input bool   InpUseCurrentSymbol   = true;
input string InpCustomSymbol       = "";

input group "========== ATR SETTINGS =========="
input int    InpATRPeriod          = 14;

input group "========== DASHBOARD =========="
input bool             InpShowPanel    = true;
input ENUM_BASE_CORNER InpPanelCorner  = CORNER_LEFT_UPPER;
input int              InpPanelX       = 15;
input int              InpPanelY       = 145;
input int              InpTimerSeconds = 1;

#define Q_BG       C'8,23,38'
#define Q_GOLD     C'212,175,55'
#define Q_WHITE    C'245,245,245'
#define Q_GRAY     C'169,176,184'
#define Q_GREEN    C'0,200,83'
#define Q_YELLOW   C'255,193,7'
#define Q_RED      C'255,82,82'
#define Q_BLUE     C'32,93,145'
#define Q_BORDER   C'62,76,89'

string g_prefix="QSID5_";
string g_symbol="";
string g_currency="";
string g_market_status="UNKNOWN";
string g_trade_mode_text="UNKNOWN";
string g_fill_mode_text="UNKNOWN";

int g_digits=0;
long g_trade_mode=SYMBOL_TRADE_MODE_DISABLED;
long g_fill_mode=0;
long g_stops_level=0;
long g_freeze_level=0;
long g_leverage=0;

double g_bid=0.0;
double g_ask=0.0;
double g_spread_points=0.0;
double g_point=0.0;
double g_tick_size=0.0;
double g_tick_value=0.0;
double g_contract_size=0.0;
double g_min_lot=0.0;
double g_max_lot=0.0;
double g_lot_step=0.0;
double g_swap_long=0.0;
double g_swap_short=0.0;
double g_margin_initial=0.0;
double g_margin_maintenance=0.0;
double g_day_high=0.0;
double g_day_low=0.0;
double g_day_range=0.0;
double g_atr=0.0;
double g_point_value_1lot=0.0;
double g_pip_value_1lot=0.0;

int g_atr_handle=INVALID_HANDLE;

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

string FillModeText(long mode)
{
   string text="";

   if((mode & SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK)
      text="FOK";

   if((mode & SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC)
   {
      if(StringLen(text)>0) text+=" / ";
      text+="IOC";
   }

   if((mode & SYMBOL_FILLING_BOC)==SYMBOL_FILLING_BOC)
   {
      if(StringLen(text)>0) text+=" / ";
      text+="BOC";
   }

   if(StringLen(text)==0)
      text="DEFAULT";

   return text;
}

double PipSize()
{
   if(g_point<=0.0)
      return 0.0;

   if(g_digits==3 || g_digits==5)
      return g_point*10.0;

   return g_point;
}

double MoneyValueForDistance(double distance)
{
   if(g_tick_size<=0.0 || g_tick_value<=0.0 || distance<=0.0)
      return 0.0;

   return (distance/g_tick_size)*g_tick_value;
}

bool UpdateATR()
{
   if(g_atr_handle==INVALID_HANDLE)
      return false;

   double buf[1];

   if(CopyBuffer(g_atr_handle,0,0,1,buf)!=1)
      return false;

   g_atr=buf[0];
   return true;
}

bool UpdateData()
{
   g_symbol=SelectedSymbol();

   if(!SymbolSelect(g_symbol,true))
      return false;

   MqlTick tick;
   if(!SymbolInfoTick(g_symbol,tick))
      return false;

   g_bid=tick.bid;
   g_ask=tick.ask;
   g_digits=(int)SymbolInfoInteger(g_symbol,SYMBOL_DIGITS);
   g_point=SymbolInfoDouble(g_symbol,SYMBOL_POINT);
   g_tick_size=SymbolInfoDouble(g_symbol,SYMBOL_TRADE_TICK_SIZE);
   g_tick_value=SymbolInfoDouble(g_symbol,SYMBOL_TRADE_TICK_VALUE);
   g_contract_size=SymbolInfoDouble(g_symbol,SYMBOL_TRADE_CONTRACT_SIZE);

   g_min_lot=SymbolInfoDouble(g_symbol,SYMBOL_VOLUME_MIN);
   g_max_lot=SymbolInfoDouble(g_symbol,SYMBOL_VOLUME_MAX);
   g_lot_step=SymbolInfoDouble(g_symbol,SYMBOL_VOLUME_STEP);

   g_swap_long=SymbolInfoDouble(g_symbol,SYMBOL_SWAP_LONG);
   g_swap_short=SymbolInfoDouble(g_symbol,SYMBOL_SWAP_SHORT);

   g_stops_level=SymbolInfoInteger(g_symbol,SYMBOL_TRADE_STOPS_LEVEL);
   g_freeze_level=SymbolInfoInteger(g_symbol,SYMBOL_TRADE_FREEZE_LEVEL);

   g_margin_initial=SymbolInfoDouble(g_symbol,SYMBOL_MARGIN_INITIAL);
   g_margin_maintenance=SymbolInfoDouble(g_symbol,SYMBOL_MARGIN_MAINTENANCE);

   g_trade_mode=SymbolInfoInteger(g_symbol,SYMBOL_TRADE_MODE);
   g_fill_mode=SymbolInfoInteger(g_symbol,SYMBOL_FILLING_MODE);

   g_trade_mode_text=TradeModeText(g_trade_mode);
   g_fill_mode_text=FillModeText(g_fill_mode);

   g_currency=AccountInfoString(ACCOUNT_CURRENCY);
   g_leverage=AccountInfoInteger(ACCOUNT_LEVERAGE);

   g_spread_points=(g_point>0.0 ? (g_ask-g_bid)/g_point : 0.0);

   MqlRates day[1];
   ArraySetAsSeries(day,true);

   if(CopyRates(g_symbol,PERIOD_D1,0,1,day)==1)
   {
      g_day_high=day[0].high;
      g_day_low=day[0].low;
      g_day_range=MathMax(0.0,g_day_high-g_day_low);
   }

   g_point_value_1lot=MoneyValueForDistance(g_point);
   g_pip_value_1lot=MoneyValueForDistance(PipSize());

   datetime now=TimeCurrent();
   bool recent_tick=(tick.time>0 && (now-tick.time)<=300);
   g_market_status=(g_trade_mode!=SYMBOL_TRADE_MODE_DISABLED && recent_tick ? "OPEN" : "CLOSED");

   UpdateATR();
   return true;
}

bool Rect(string n,int x,int y,int w,int h,color bg,color br)
{
   if(!ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0))
      return false;

   ObjectSetInteger(0,n,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,n,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,n,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,br);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   return true;
}

bool Label(string n,string t,int x,int y,int s,color c,bool bold=false)
{
   if(!ObjectCreate(0,n,OBJ_LABEL,0,0,0))
      return false;

   ObjectSetInteger(0,n,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_COLOR,c);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,s);
   ObjectSetString(0,n,OBJPROP_FONT,bold ? "Arial Bold" : "Arial");
   ObjectSetString(0,n,OBJPROP_TEXT,t);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   return true;
}

void DeletePanel()
{
   for(int i=ObjectsTotal(0)-1;i>=0;i--)
   {
      string n=ObjectName(0,i);
      if(StringFind(n,g_prefix)==0)
         ObjectDelete(0,n);
   }
}

void BuildPanel()
{
   if(!InpShowPanel) return;

   DeletePanel();

   int x=InpPanelX;
   int y=InpPanelY;

   Rect(g_prefix+"BG",x,y,620,650,Q_BG,Q_GOLD);

   Label(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   Label(g_prefix+"SUB","SYMBOL INFORMATION DASHBOARD",x+18,y+38,11,Q_WHITE,true);
   Label(g_prefix+"VER","MT5 v1.00",x+530,y+18,9,Q_GRAY);

   Label(g_prefix+"SYMBOL","SYMBOL: --",x+18,y+78,11,Q_GOLD,true);
   Label(g_prefix+"MARKET","MARKET: UNKNOWN",x+330,y+78,11,Q_GRAY,true);

   Label(g_prefix+"BID","BID: 0",x+18,y+118,10,Q_WHITE);
   Label(g_prefix+"ASK","ASK: 0",x+220,y+118,10,Q_WHITE);
   Label(g_prefix+"SPREAD","SPREAD: 0 pts",x+420,y+118,10,Q_GOLD,true);

   Rect(g_prefix+"SEP1",x+18,y+152,584,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"SPEC","CONTRACT SPECIFICATIONS",x+18,y+172,10,Q_GOLD,true);
   Label(g_prefix+"DIGITS","DIGITS: 0",x+18,y+206,10,Q_WHITE);
   Label(g_prefix+"POINT","POINT: 0",x+220,y+206,10,Q_WHITE);
   Label(g_prefix+"TICKSIZE","TICK SIZE: 0",x+420,y+206,10,Q_WHITE);

   Label(g_prefix+"TICKVALUE","TICK VALUE: 0",x+18,y+240,10,Q_WHITE);
   Label(g_prefix+"CONTRACT","CONTRACT SIZE: 0",x+310,y+240,10,Q_WHITE);

   Label(g_prefix+"POINTVALUE","1 LOT POINT VALUE: 0",x+18,y+274,10,Q_GREEN,true);
   Label(g_prefix+"PIPVALUE","1 LOT PIP VALUE: 0",x+310,y+274,10,Q_GREEN,true);

   Rect(g_prefix+"SEP2",x+18,y+308,584,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"VOL","VOLUME LIMITS",x+18,y+328,10,Q_GOLD,true);
   Label(g_prefix+"MINLOT","MIN LOT: 0.00",x+18,y+362,10,Q_WHITE);
   Label(g_prefix+"MAXLOT","MAX LOT: 0.00",x+220,y+362,10,Q_WHITE);
   Label(g_prefix+"LOTSTEP","LOT STEP: 0.00",x+420,y+362,10,Q_WHITE);

   Rect(g_prefix+"SEP3",x+18,y+396,584,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"COND","TRADING CONDITIONS",x+18,y+416,10,Q_GOLD,true);
   Label(g_prefix+"SWAPL","SWAP LONG: 0.00",x+18,y+450,10,Q_WHITE);
   Label(g_prefix+"SWAPS","SWAP SHORT: 0.00",x+310,y+450,10,Q_WHITE);
   Label(g_prefix+"STOPS","STOPS LEVEL: 0",x+18,y+484,10,Q_WHITE);
   Label(g_prefix+"FREEZE","FREEZE LEVEL: 0",x+310,y+484,10,Q_WHITE);
   Label(g_prefix+"TMODE","TRADING MODE: UNKNOWN",x+18,y+518,10,Q_GOLD,true);
   Label(g_prefix+"FMODE","FILLING MODE: UNKNOWN",x+310,y+518,10,Q_WHITE);

   Rect(g_prefix+"SEP4",x+18,y+552,584,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"DAY","DAILY MARKET",x+18,y+572,10,Q_GOLD,true);
   Label(g_prefix+"HIGH","HIGH: 0",x+18,y+606,10,Q_WHITE);
   Label(g_prefix+"LOW","LOW: 0",x+200,y+606,10,Q_WHITE);
   Label(g_prefix+"RANGE","RANGE: 0",x+380,y+606,10,Q_WHITE);
   Label(g_prefix+"ATR","ATR: 0",x+18,y+632,10,Q_BLUE,true);

   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel) return;

   color mc=(g_market_status=="OPEN" ? Q_GREEN : Q_RED);

   ObjectSetString(0,g_prefix+"SYMBOL",OBJPROP_TEXT,"SYMBOL: "+g_symbol);
   ObjectSetString(0,g_prefix+"MARKET",OBJPROP_TEXT,"MARKET: "+g_market_status);
   ObjectSetInteger(0,g_prefix+"MARKET",OBJPROP_COLOR,mc);

   ObjectSetString(0,g_prefix+"BID",OBJPROP_TEXT,"BID: "+DoubleToString(g_bid,g_digits));
   ObjectSetString(0,g_prefix+"ASK",OBJPROP_TEXT,"ASK: "+DoubleToString(g_ask,g_digits));
   ObjectSetString(0,g_prefix+"SPREAD",OBJPROP_TEXT,"SPREAD: "+DoubleToString(g_spread_points,1)+" pts");

   ObjectSetString(0,g_prefix+"DIGITS",OBJPROP_TEXT,"DIGITS: "+IntegerToString(g_digits));
   ObjectSetString(0,g_prefix+"POINT",OBJPROP_TEXT,"POINT: "+DoubleToString(g_point,g_digits));
   ObjectSetString(0,g_prefix+"TICKSIZE",OBJPROP_TEXT,"TICK SIZE: "+DoubleToString(g_tick_size,g_digits));

   ObjectSetString(0,g_prefix+"TICKVALUE",OBJPROP_TEXT,
                   "TICK VALUE: "+DoubleToString(g_tick_value,4)+" "+g_currency);
   ObjectSetString(0,g_prefix+"CONTRACT",OBJPROP_TEXT,
                   "CONTRACT SIZE: "+DoubleToString(g_contract_size,2));

   ObjectSetString(0,g_prefix+"POINTVALUE",OBJPROP_TEXT,
                   "1 LOT POINT VALUE: "+DoubleToString(g_point_value_1lot,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"PIPVALUE",OBJPROP_TEXT,
                   "1 LOT PIP VALUE: "+DoubleToString(g_pip_value_1lot,2)+" "+g_currency);

   ObjectSetString(0,g_prefix+"MINLOT",OBJPROP_TEXT,"MIN LOT: "+DoubleToString(g_min_lot,2));
   ObjectSetString(0,g_prefix+"MAXLOT",OBJPROP_TEXT,"MAX LOT: "+DoubleToString(g_max_lot,2));
   ObjectSetString(0,g_prefix+"LOTSTEP",OBJPROP_TEXT,"LOT STEP: "+DoubleToString(g_lot_step,4));

   ObjectSetString(0,g_prefix+"SWAPL",OBJPROP_TEXT,"SWAP LONG: "+DoubleToString(g_swap_long,2));
   ObjectSetString(0,g_prefix+"SWAPS",OBJPROP_TEXT,"SWAP SHORT: "+DoubleToString(g_swap_short,2));
   ObjectSetString(0,g_prefix+"STOPS",OBJPROP_TEXT,"STOPS LEVEL: "+IntegerToString((int)g_stops_level));
   ObjectSetString(0,g_prefix+"FREEZE",OBJPROP_TEXT,"FREEZE LEVEL: "+IntegerToString((int)g_freeze_level));

   ObjectSetString(0,g_prefix+"TMODE",OBJPROP_TEXT,"TRADING MODE: "+g_trade_mode_text);
   ObjectSetString(0,g_prefix+"FMODE",OBJPROP_TEXT,"FILLING MODE: "+g_fill_mode_text);

   ObjectSetString(0,g_prefix+"HIGH",OBJPROP_TEXT,"HIGH: "+DoubleToString(g_day_high,g_digits));
   ObjectSetString(0,g_prefix+"LOW",OBJPROP_TEXT,"LOW: "+DoubleToString(g_day_low,g_digits));
   ObjectSetString(0,g_prefix+"RANGE",OBJPROP_TEXT,"RANGE: "+DoubleToString(g_day_range,g_digits));
   ObjectSetString(0,g_prefix+"ATR",OBJPROP_TEXT,"ATR: "+DoubleToString(g_atr,g_digits));

   ChartRedraw();
}

int OnInit()
{
   if(InpATRPeriod<2 || InpTimerSeconds<1)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Quantora Symbol Information Dashboard MT5 v1.00");

   g_symbol=SelectedSymbol();

   if(!SymbolSelect(g_symbol,true))
      return INIT_FAILED;

   g_atr_handle=iATR(g_symbol,(ENUM_TIMEFRAMES)_Period,InpATRPeriod);

   if(g_atr_handle==INVALID_HANDLE)
   {
      Print("Quantora Symbol Information Dashboard: ATR handle error ",GetLastError());
      return INIT_FAILED;
   }

   BuildPanel();
   UpdateData();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora Symbol Information Dashboard: EventSetTimer error ",GetLastError());
      return INIT_FAILED;
   }

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();

   if(g_atr_handle!=INVALID_HANDLE)
   {
      IndicatorRelease(g_atr_handle);
      g_atr_handle=INVALID_HANDLE;
   }

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
   UpdateData();
   UpdatePanel();
}

//===========================================================
// Developed by Quantora
// More Professional Trading Robots
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
