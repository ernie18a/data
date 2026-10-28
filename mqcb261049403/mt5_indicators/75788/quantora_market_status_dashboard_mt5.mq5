//+------------------------------------------------------------------+
//|                             Quantora Market Status Dashboard MT5 |
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
#property description "Professional market status dashboard for MetaTrader 5."
#property description "Displays spread, volatility, volume, ADR usage, sessions and market condition."

//============================== INPUTS =====================================
input group "========== MARKET SETTINGS =========="
input int                 InpATRPeriod             = 14;
input int                 InpADRPeriod             = 14;
input int                 InpVolumeLookback        = 20;

input group "========== SPREAD THRESHOLDS (POINTS) =========="
input double              InpSpreadLowMax          = 15.0;
input double              InpSpreadNormalMax       = 30.0;

input group "========== VOLATILITY THRESHOLDS =========="
input double              InpVolLowRatio           = 0.80;
input double              InpVolHighRatio          = 1.20;

input group "========== VOLUME THRESHOLDS =========="
input double              InpVolumeLowRatio        = 0.80;
input double              InpVolumeHighRatio       = 1.20;

input group "========== SESSION HOURS (UTC) =========="
input int                 InpSydneyOpenHour        = 21;
input int                 InpSydneyCloseHour       = 6;
input int                 InpTokyoOpenHour         = 0;
input int                 InpTokyoCloseHour        = 9;
input int                 InpLondonOpenHour        = 7;
input int                 InpLondonCloseHour       = 16;
input int                 InpNewYorkOpenHour       = 12;
input int                 InpNewYorkCloseHour      = 21;

input group "========== DASHBOARD =========="
input bool                InpShowPanel             = true;
input ENUM_BASE_CORNER    InpPanelCorner           = CORNER_LEFT_UPPER;
input int                 InpPanelX                = 15;
input int                 InpPanelY                = 145;
input int                 InpTimerSeconds          = 1;

//============================== BRAND COLORS ===============================
#define Q_BG       C'8,23,38'
#define Q_GOLD     C'212,175,55'
#define Q_WHITE    C'245,245,245'
#define Q_GRAY     C'169,176,184'
#define Q_GREEN    C'0,200,83'
#define Q_YELLOW   C'255,193,7'
#define Q_ORANGE   C'255,152,0'
#define Q_RED      C'255,82,82'
#define Q_BORDER   C'62,76,89'
#define Q_DARK2    C'5,14,24'

//============================== STATE ======================================
string g_prefix="QMSD5_";
string g_status="INITIALIZING";
string g_market_status="UNKNOWN";
string g_spread_status="UNKNOWN";
string g_volatility_status="UNKNOWN";
string g_volume_status="UNKNOWN";
string g_market_condition="UNKNOWN";
string g_active_sessions="NONE";

double g_bid=0.0;
double g_ask=0.0;
double g_spread_points=0.0;

double g_atr_current=0.0;
double g_atr_average=0.0;
double g_atr_ratio=0.0;

long   g_volume_current=0;
double g_volume_average=0.0;
double g_volume_ratio=0.0;

double g_today_open=0.0;
double g_today_high=0.0;
double g_today_low=0.0;
double g_today_range=0.0;
double g_today_range_points=0.0;
double g_adr=0.0;
double g_adr_points=0.0;
double g_adr_used_pct=0.0;
double g_price_position_pct=0.0;

int    g_active_session_count=0;
long   g_trade_mode=SYMBOL_TRADE_MODE_DISABLED;
datetime g_last_tick_time=0;

int g_atr_handle=INVALID_HANDLE;

//============================== HELPERS ====================================
int NormalizeHour(int h)
{
   h%=24;
   if(h<0) h+=24;
   return h;
}

bool IsSessionOpen(int open_hour,int close_hour,int sec_now)
{
   int o=NormalizeHour(open_hour)*3600;
   int c=NormalizeHour(close_hour)*3600;

   if(o==c) return true;
   if(o<c) return (sec_now>=o && sec_now<c);
   return (sec_now>=o || sec_now<c);
}

int SecondsOfDay(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t,dt);
   return dt.hour*3600+dt.min*60+dt.sec;
}

string TimeframeText()
{
   string text=EnumToString((ENUM_TIMEFRAMES)_Period);
   StringReplace(text,"PERIOD_","");
   return text;
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

color StatusColor(string value)
{
   if(value=="OPEN" || value=="LOW" || value=="NORMAL" || value=="ACTIVE")
      return Q_GREEN;
   if(value=="MODERATE")
      return Q_YELLOW;
   if(value=="HIGH" || value=="VOLATILE")
      return Q_ORANGE;
   if(value=="CLOSED" || value=="EXTREME" || value=="DANGEROUS")
      return Q_RED;
   return Q_GRAY;
}

void UpdateSessions()
{
   datetime utc=TimeGMT();
   if(utc<=0) utc=TimeCurrent();

   int sec_now=SecondsOfDay(utc);

   bool sydney=IsSessionOpen(InpSydneyOpenHour,InpSydneyCloseHour,sec_now);
   bool tokyo=IsSessionOpen(InpTokyoOpenHour,InpTokyoCloseHour,sec_now);
   bool london=IsSessionOpen(InpLondonOpenHour,InpLondonCloseHour,sec_now);
   bool newyork=IsSessionOpen(InpNewYorkOpenHour,InpNewYorkCloseHour,sec_now);

   g_active_sessions="";
   g_active_session_count=0;

   if(sydney){ if(StringLen(g_active_sessions)>0) g_active_sessions+=" / "; g_active_sessions+="SYDNEY"; g_active_session_count++; }
   if(tokyo){ if(StringLen(g_active_sessions)>0) g_active_sessions+=" / "; g_active_sessions+="TOKYO"; g_active_session_count++; }
   if(london){ if(StringLen(g_active_sessions)>0) g_active_sessions+=" / "; g_active_sessions+="LONDON"; g_active_session_count++; }
   if(newyork){ if(StringLen(g_active_sessions)>0) g_active_sessions+=" / "; g_active_sessions+="NEW YORK"; g_active_session_count++; }

   if(StringLen(g_active_sessions)==0)
      g_active_sessions="NONE";
}

bool UpdateSpreadAndMarket()
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
   {
      g_status="WAITING FOR TICKS";
      return false;
   }

   g_bid=tick.bid;
   g_ask=tick.ask;
   g_last_tick_time=tick.time;

   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   g_spread_points=(point>0.0 ? (g_ask-g_bid)/point : 0.0);

   if(g_spread_points<=InpSpreadLowMax)
      g_spread_status="LOW";
   else if(g_spread_points<=InpSpreadNormalMax)
      g_spread_status="NORMAL";
   else
      g_spread_status="HIGH";

   g_trade_mode=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);

   datetime now=TimeCurrent();
   bool recent_tick=(g_last_tick_time>0 && (now-g_last_tick_time)<=300);
   bool open=(g_trade_mode!=SYMBOL_TRADE_MODE_DISABLED && recent_tick);

   g_market_status=(open ? "OPEN" : "CLOSED");
   return true;
}

bool UpdateATR()
{
   if(g_atr_handle==INVALID_HANDLE)
      return false;

   int need=MathMax(5,InpATRPeriod);
   double atr[];
   ArraySetAsSeries(atr,true);

   int copied=CopyBuffer(g_atr_handle,0,0,need,atr);
   if(copied<need)
      return false;

   g_atr_current=atr[0];

   double sum=0.0;
   int count=0;
   for(int i=1;i<copied;i++)
   {
      if(atr[i]<=0.0) continue;
      sum+=atr[i];
      count++;
   }

   g_atr_average=(count>0 ? sum/count : g_atr_current);
   g_atr_ratio=(g_atr_average>0.0 ? g_atr_current/g_atr_average : 1.0);

   if(g_atr_ratio<InpVolLowRatio)
      g_volatility_status="LOW";
   else if(g_atr_ratio>InpVolHighRatio)
      g_volatility_status="HIGH";
   else
      g_volatility_status="NORMAL";

   return true;
}

bool UpdateVolume()
{
   int need=InpVolumeLookback+1;
   MqlRates rates[];
   ArraySetAsSeries(rates,true);

   int copied=CopyRates(_Symbol,(ENUM_TIMEFRAMES)_Period,0,need,rates);
   if(copied<need)
      return false;

   g_volume_current=rates[0].tick_volume;

   double sum=0.0;
   int count=0;
   for(int i=1;i<copied;i++)
   {
      sum+=(double)rates[i].tick_volume;
      count++;
   }

   g_volume_average=(count>0 ? sum/count : (double)g_volume_current);
   g_volume_ratio=(g_volume_average>0.0 ? (double)g_volume_current/g_volume_average : 1.0);

   if(g_volume_ratio<InpVolumeLowRatio)
      g_volume_status="LOW";
   else if(g_volume_ratio>InpVolumeHighRatio)
      g_volume_status="HIGH";
   else
      g_volume_status="NORMAL";

   return true;
}

bool UpdateADR()
{
   MqlRates daily[];
   ArraySetAsSeries(daily,true);

   int need=InpADRPeriod+1;
   int copied=CopyRates(_Symbol,PERIOD_D1,0,need,daily);
   if(copied<need)
      return false;

   g_today_open=daily[0].open;
   g_today_high=daily[0].high;
   g_today_low=daily[0].low;
   g_today_range=MathMax(0.0,g_today_high-g_today_low);

   double total=0.0;
   int count=0;
   for(int i=1;i<=InpADRPeriod;i++)
   {
      double range=daily[i].high-daily[i].low;
      if(range<=0.0) continue;
      total+=range;
      count++;
   }

   g_adr=(count>0 ? total/count : 0.0);

   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   g_today_range_points=(point>0.0 ? g_today_range/point : 0.0);
   g_adr_points=(point>0.0 ? g_adr/point : 0.0);
   g_adr_used_pct=(g_adr>0.0 ? 100.0*g_today_range/g_adr : 0.0);

   double price=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(g_today_high>g_today_low)
      g_price_position_pct=100.0*(price-g_today_low)/(g_today_high-g_today_low);
   else
      g_price_position_pct=0.0;

   g_price_position_pct=MathMax(0.0,MathMin(100.0,g_price_position_pct));

   return true;
}

void ClassifyMarketCondition()
{
   if(g_market_status!="OPEN")
   {
      g_market_condition="CLOSED";
      return;
   }

   if(g_spread_status=="HIGH" && g_volatility_status=="HIGH")
   {
      g_market_condition="VOLATILE";
      return;
   }

   if(g_volume_status=="HIGH" && g_volatility_status!="LOW" && g_spread_status!="HIGH")
   {
      g_market_condition="ACTIVE";
      return;
   }

   g_market_condition="MODERATE";
}

void UpdateAllData()
{
   bool a=UpdateSpreadAndMarket();
   bool b=UpdateATR();
   bool c=UpdateVolume();
   bool d=UpdateADR();
   UpdateSessions();
   ClassifyMarketCondition();

   if(a && b && c && d)
      g_status="LIVE DATA READY";
   else if(g_status!="WAITING FOR TICKS")
      g_status="WAITING FOR HISTORY";
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

   CreateRectangle(g_prefix+"BG",x,y,560,540,Q_BG,Q_GOLD);

   CreateLabel(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   CreateLabel(g_prefix+"SUB","MARKET STATUS DASHBOARD",x+18,y+38,11,Q_WHITE,true);
   CreateLabel(g_prefix+"VER","MT5 v1.00",x+470,y+18,9,Q_GRAY);

   CreateLabel(g_prefix+"STATUS","STATUS: INITIALIZING",x+18,y+74,10,Q_GREEN,true);

   CreateLabel(g_prefix+"SYMBOL","SYMBOL: "+_Symbol,x+18,y+108,10,Q_WHITE,true);
   CreateLabel(g_prefix+"TF","TIMEFRAME: "+TimeframeText(),x+300,y+108,10,Q_WHITE);

   CreateLabel(g_prefix+"MARKET","MARKET: UNKNOWN",x+18,y+144,11,Q_GRAY,true);
   CreateLabel(g_prefix+"TRADE","TRADING MODE: UNKNOWN",x+300,y+144,10,Q_GRAY);

   CreateLabel(g_prefix+"SPREAD","SPREAD: 0.0 pts",x+18,y+184,10,Q_WHITE);
   CreateLabel(g_prefix+"SPREADSTAT","SPREAD STATUS: UNKNOWN",x+300,y+184,10,Q_GRAY,true);

   CreateLabel(g_prefix+"ATR","ATR: 0.00000",x+18,y+220,10,Q_WHITE);
   CreateLabel(g_prefix+"VOLSTAT","VOLATILITY: UNKNOWN",x+300,y+220,10,Q_GRAY,true);

   CreateLabel(g_prefix+"VOLUME","CURRENT VOLUME: 0",x+18,y+256,10,Q_WHITE);
   CreateLabel(g_prefix+"VOLACT","VOLUME ACTIVITY: UNKNOWN",x+300,y+256,10,Q_GRAY,true);

   CreateLabel(g_prefix+"RANGE","DAILY RANGE: 0.0 pts",x+18,y+292,10,Q_WHITE);
   CreateLabel(g_prefix+"ADR","ADR: 0.0 pts",x+300,y+292,10,Q_WHITE);

   CreateLabel(g_prefix+"ADRUSED","ADR USED: 0.0 %",x+18,y+328,10,Q_GOLD,true);
   CreateLabel(g_prefix+"POS","PRICE POSITION: 0.0 %",x+300,y+328,10,Q_GRAY);

   CreateRectangle(g_prefix+"PB_BG",x+18,y+358,524,20,Q_DARK2,Q_BORDER);
   CreateRectangle(g_prefix+"PB_FILL",x+20,y+360,1,16,Q_GREEN,Q_GREEN);

   CreateLabel(g_prefix+"SESSIONS","ACTIVE SESSIONS: NONE",x+18,y+398,10,Q_WHITE);
   CreateLabel(g_prefix+"SESSIONCOUNT","SESSION COUNT: 0",x+300,y+398,10,Q_GRAY);

   CreateLabel(g_prefix+"CONDITION","MARKET CONDITION: UNKNOWN",x+18,y+438,12,Q_GOLD,true);

   CreateLabel(g_prefix+"TIME","SERVER TIME: --:--:--",x+18,y+476,10,Q_GRAY);
   CreateLabel(g_prefix+"HIGHLOW","DAY H/L: 0.00000 / 0.00000",x+300,y+476,10,Q_GRAY);

   CreateLabel(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",x+18,y+516,9,Q_GOLD);

   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel)
      return;

   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   string server_time=StringFormat("%02d:%02d:%02d",dt.hour,dt.min,dt.sec);

   ObjectSetString(0,g_prefix+"STATUS",OBJPROP_TEXT,"STATUS: "+g_status);
   ObjectSetInteger(0,g_prefix+"STATUS",OBJPROP_COLOR,
                    g_status=="LIVE DATA READY" ? Q_GREEN : Q_YELLOW);

   ObjectSetString(0,g_prefix+"MARKET",OBJPROP_TEXT,"MARKET: "+g_market_status);
   ObjectSetInteger(0,g_prefix+"MARKET",OBJPROP_COLOR,StatusColor(g_market_status));

   ObjectSetString(0,g_prefix+"TRADE",OBJPROP_TEXT,"TRADING MODE: "+TradeModeText());

   ObjectSetString(0,g_prefix+"SPREAD",OBJPROP_TEXT,
                   "SPREAD: "+DoubleToString(g_spread_points,1)+" pts");
   ObjectSetString(0,g_prefix+"SPREADSTAT",OBJPROP_TEXT,
                   "SPREAD STATUS: "+g_spread_status);
   ObjectSetInteger(0,g_prefix+"SPREADSTAT",OBJPROP_COLOR,StatusColor(g_spread_status));

   ObjectSetString(0,g_prefix+"ATR",OBJPROP_TEXT,
                   "ATR: "+DoubleToString(g_atr_current,digits));
   ObjectSetString(0,g_prefix+"VOLSTAT",OBJPROP_TEXT,
                   "VOLATILITY: "+g_volatility_status);
   ObjectSetInteger(0,g_prefix+"VOLSTAT",OBJPROP_COLOR,StatusColor(g_volatility_status));

   ObjectSetString(0,g_prefix+"VOLUME",OBJPROP_TEXT,
                   "CURRENT VOLUME: "+IntegerToString((int)g_volume_current));
   ObjectSetString(0,g_prefix+"VOLACT",OBJPROP_TEXT,
                   "VOLUME ACTIVITY: "+g_volume_status);
   ObjectSetInteger(0,g_prefix+"VOLACT",OBJPROP_COLOR,StatusColor(g_volume_status));

   ObjectSetString(0,g_prefix+"RANGE",OBJPROP_TEXT,
                   "DAILY RANGE: "+DoubleToString(g_today_range_points,1)+" pts");
   ObjectSetString(0,g_prefix+"ADR",OBJPROP_TEXT,
                   "ADR: "+DoubleToString(g_adr_points,1)+" pts");

   ObjectSetString(0,g_prefix+"ADRUSED",OBJPROP_TEXT,
                   "ADR USED: "+DoubleToString(g_adr_used_pct,1)+" %");
   ObjectSetString(0,g_prefix+"POS",OBJPROP_TEXT,
                   "PRICE POSITION: "+DoubleToString(g_price_position_pct,1)+" %");

   int fill=(int)MathRound(520.0*MathMin(g_adr_used_pct,100.0)/100.0);
   fill=MathMax(1,MathMin(520,fill));
   color fill_color=(g_adr_used_pct<70.0 ? Q_GREEN : g_adr_used_pct<100.0 ? Q_YELLOW : Q_RED);

   ObjectSetInteger(0,g_prefix+"PB_FILL",OBJPROP_XSIZE,fill);
   ObjectSetInteger(0,g_prefix+"PB_FILL",OBJPROP_BGCOLOR,fill_color);
   ObjectSetInteger(0,g_prefix+"PB_FILL",OBJPROP_BORDER_COLOR,fill_color);

   ObjectSetString(0,g_prefix+"SESSIONS",OBJPROP_TEXT,
                   "ACTIVE SESSIONS: "+g_active_sessions);
   ObjectSetString(0,g_prefix+"SESSIONCOUNT",OBJPROP_TEXT,
                   "SESSION COUNT: "+IntegerToString(g_active_session_count));

   ObjectSetString(0,g_prefix+"CONDITION",OBJPROP_TEXT,
                   "MARKET CONDITION: "+g_market_condition);
   ObjectSetInteger(0,g_prefix+"CONDITION",OBJPROP_COLOR,StatusColor(g_market_condition));

   ObjectSetString(0,g_prefix+"TIME",OBJPROP_TEXT,"SERVER TIME: "+server_time);
   ObjectSetString(0,g_prefix+"HIGHLOW",OBJPROP_TEXT,
                   "DAY H/L: "+DoubleToString(g_today_high,digits)+
                   " / "+DoubleToString(g_today_low,digits));

   ChartRedraw();
}

//============================== INDICATOR EVENTS ===========================
int OnInit()
{
   if(InpATRPeriod<2 || InpADRPeriod<2 || InpVolumeLookback<2 || InpTimerSeconds<1)
      return INIT_PARAMETERS_INCORRECT;

   if(InpVolLowRatio<=0.0 || InpVolHighRatio<InpVolLowRatio ||
      InpVolumeLowRatio<=0.0 || InpVolumeHighRatio<InpVolumeLowRatio ||
      InpSpreadLowMax<0.0 || InpSpreadNormalMax<InpSpreadLowMax)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Quantora Market Status Dashboard MT5 v1.00");

   g_atr_handle=iATR(_Symbol,(ENUM_TIMEFRAMES)_Period,InpATRPeriod);
   if(g_atr_handle==INVALID_HANDLE)
   {
      Print("Quantora Market Status Dashboard MT5: Failed to create ATR handle. Error ",GetLastError());
      return INIT_FAILED;
   }

   BuildPanel();
   UpdateAllData();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora Market Status Dashboard MT5: EventSetTimer failed. Error ",GetLastError());
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
   UpdateAllData();
   UpdatePanel();
}

//===========================================================
// Developed by Quantora
//
// More Professional Trading Robots
//
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
