//+------------------------------------------------------------------+
//|              Quantora Trailing Stop Manager MT5                  |
//|       Professional Trading Utility for MetaTrader 5              |
//|                                                                  |
//| Copyright © 2026 Quantora                                        |
//| https://www.mql5.com/en/users/quantora/seller                    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.00"
#property strict
#property description "Professional automatic trailing stop manager for MetaTrader 5."
#property description "Supports manual trades, all positions, or a specific Magic Number."

#include <Trade/Trade.mqh>

//============================== ENUMS ======================================
enum ENUM_QTS_SCOPE
  {
   QTS_CURRENT_SYMBOL = 0,
   QTS_ALL_SYMBOLS    = 1
  };

enum ENUM_QTS_MAGIC_FILTER
  {
   QTS_MANUAL_ONLY    = 0,
   QTS_ALL_POSITIONS  = 1,
   QTS_SPECIFIC_MAGIC = 2
  };

//============================== INPUTS =====================================
input group "========== POSITION SCOPE =========="
input ENUM_QTS_SCOPE        InpScope                    = QTS_CURRENT_SYMBOL;
input ENUM_QTS_MAGIC_FILTER InpMagicFilter              = QTS_MANUAL_ONLY;
input long                  InpSpecificMagic            = 0;
input bool                  InpManageBuyPositions       = true;
input bool                  InpManageSellPositions      = true;

input group "========== TRAILING STOP =========="
input int                   InpTrailingStartPoints      = 600;
input int                   InpTrailingDistancePoints   = 350;
input int                   InpTrailingStepPoints       = 50;
input bool                  InpUseMinimumProfitFilter   = true;
input int                   InpMinimumProfitPoints      = 600;

input group "========== EXECUTION =========="
input int                   InpTimerSeconds             = 1;
input int                   InpMaxModifyRetries         = 2;
input bool                  InpEnablePrintLog           = true;

input group "========== DASHBOARD =========="
input bool                  InpShowDashboard            = true;
input ENUM_BASE_CORNER      InpPanelCorner              = CORNER_LEFT_UPPER;
input int                   InpPanelX                   = 15;
input int                   InpPanelY                   = 145;

//============================== CONSTANTS ==================================
#define QTS_BG       C'8,23,38'
#define QTS_GOLD     C'212,175,55'
#define QTS_WHITE    C'245,245,245'
#define QTS_GRAY     C'169,176,184'
#define QTS_GREEN    C'0,200,83'
#define QTS_RED      C'255,82,82'
#define QTS_DARKBTN  C'26,49,70'

//============================== STATE ======================================
CTrade   g_trade;
string   g_prefix="QTSM_";
bool     g_manager_enabled=true;
string   g_status="ACTIVE";
int      g_applied_count=0;
int      g_error_count=0;
datetime g_last_action=0;

//============================== UTILITIES ==================================
void Log(const string text)
  {
   if(InpEnablePrintLog)
      Print("[Quantora Trailing Stop Manager MT5] ",text);
  }

string AccountTypeText()
  {
   ENUM_ACCOUNT_MARGIN_MODE mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) return "HEDGING";
   if(mode==ACCOUNT_MARGIN_MODE_RETAIL_NETTING) return "NETTING";
   if(mode==ACCOUNT_MARGIN_MODE_EXCHANGE)       return "EXCHANGE";
   return "UNKNOWN";
  }

string ScopeText()
  {
   return (InpScope==QTS_CURRENT_SYMBOL ? "CURRENT SYMBOL" : "ALL SYMBOLS");
  }

string MagicFilterText()
  {
   if(InpMagicFilter==QTS_MANUAL_ONLY)    return "MANUAL ONLY";
   if(InpMagicFilter==QTS_ALL_POSITIONS)  return "ALL POSITIONS";
   return "MAGIC "+IntegerToString(InpSpecificMagic);
  }

int SymbolDigitsSafe(const string symbol)
  {
   return (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
  }

double NormalizePrice(const string symbol,const double price)
  {
   return NormalizeDouble(price,SymbolDigitsSafe(symbol));
  }

bool IsBuyType(const ENUM_POSITION_TYPE type)
  {
   return (type==POSITION_TYPE_BUY);
  }

bool IsSellType(const ENUM_POSITION_TYPE type)
  {
   return (type==POSITION_TYPE_SELL);
  }

bool PositionMatchesCurrentSelection()
  {
   string symbol=PositionGetString(POSITION_SYMBOL);
   long magic=(long)PositionGetInteger(POSITION_MAGIC);
   ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

   if(InpScope==QTS_CURRENT_SYMBOL && symbol!=_Symbol)
      return false;

   if(IsBuyType(type) && !InpManageBuyPositions)
      return false;

   if(IsSellType(type) && !InpManageSellPositions)
      return false;

   if(InpMagicFilter==QTS_MANUAL_ONLY && magic!=0)
      return false;

   if(InpMagicFilter==QTS_SPECIFIC_MAGIC && magic!=InpSpecificMagic)
      return false;

   return true;
  }

bool SelectPositionByIndexSafe(const int index,ulong &ticket)
  {
   ticket=PositionGetTicket(index);
   if(ticket==0)
      return false;
   return PositionSelectByTicket(ticket);
  }

int CountMatchedPositions()
  {
   int count=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=0;
      if(!SelectPositionByIndexSafe(i,ticket))
         continue;
      if(PositionMatchesCurrentSelection())
         count++;
     }
   return count;
  }

double MatchedFloatingProfit()
  {
   double value=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=0;
      if(!SelectPositionByIndexSafe(i,ticket))
         continue;
      if(!PositionMatchesCurrentSelection())
         continue;
      value+=PositionGetDouble(POSITION_PROFIT);
      value+=PositionGetDouble(POSITION_SWAP);
     }
   return value;
  }

//============================== BROKER RULES ================================
double MinimumStopDistancePrice(const string symbol)
  {
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   long stops=SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);
   long freeze=SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   long level=(stops>freeze ? stops : freeze);
   return (double)level*point;
  }

bool CandidateAllowed(const string symbol,
                      const ENUM_POSITION_TYPE type,
                      const double candidate)
  {
   MqlTick tick;
   if(!SymbolInfoTick(symbol,tick))
      return false;

   double minimum=MinimumStopDistancePrice(symbol);

   if(type==POSITION_TYPE_BUY)
      return (candidate>0.0 && candidate<=tick.bid-minimum);

   if(type==POSITION_TYPE_SELL)
      return (candidate>0.0 && candidate>=tick.ask+minimum);

   return false;
  }

bool ImprovesStop(const ENUM_POSITION_TYPE type,
                  const double old_sl,
                  const double candidate,
                  const double step_price)
  {
   if(old_sl<=0.0)
      return true;

   if(type==POSITION_TYPE_BUY)
      return (candidate>=old_sl+step_price);

   if(type==POSITION_TYPE_SELL)
      return (candidate<=old_sl-step_price);

   return false;
  }

bool ModifyPositionStops(const ulong ticket,
                         const string symbol,
                         const double new_sl,
                         const double tp)
  {
   g_trade.SetAsyncMode(false);
   g_trade.SetTypeFillingBySymbol(symbol);

   for(int attempt=0;attempt<=InpMaxModifyRetries;attempt++)
     {
      ResetLastError();
      if(g_trade.PositionModify(ticket,new_sl,tp))
        {
         g_applied_count++;
         g_last_action=TimeCurrent();
         Log("Trailing stop updated. Ticket="+IntegerToString((long)ticket)+
             " SL="+DoubleToString(new_sl,SymbolDigitsSafe(symbol)));
         return true;
        }

      int err=GetLastError();
      uint ret=g_trade.ResultRetcode();
      Log("PositionModify failed. Ticket="+IntegerToString((long)ticket)+
          " Attempt="+IntegerToString(attempt+1)+
          " Retcode="+IntegerToString((int)ret)+
          " Error="+IntegerToString(err));

      if(attempt<InpMaxModifyRetries)
         Sleep(100);
     }

   g_error_count++;
   return false;
  }

//============================== TRAILING LOGIC ==============================
bool ApplyTrailingToSelectedPosition(const bool force_now)
  {
   string symbol=PositionGetString(POSITION_SYMBOL);
   ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   ulong ticket=(ulong)PositionGetInteger(POSITION_TICKET);
   double open=PositionGetDouble(POSITION_PRICE_OPEN);
   double old_sl=PositionGetDouble(POSITION_SL);
   double tp=PositionGetDouble(POSITION_TP);
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);

   if(point<=0.0)
      return false;

   MqlTick tick;
   if(!SymbolInfoTick(symbol,tick))
      return false;

   double profit_points=0.0;
   if(type==POSITION_TYPE_BUY)
      profit_points=(tick.bid-open)/point;
   else if(type==POSITION_TYPE_SELL)
      profit_points=(open-tick.ask)/point;
   else
      return false;

   int required_points=InpTrailingStartPoints;
   if(InpUseMinimumProfitFilter && InpMinimumProfitPoints>required_points)
      required_points=InpMinimumProfitPoints;

   if(!force_now && profit_points<required_points)
      return false;

   // Even manual "Trail Now" must not place SL on the losing side of entry.
   if(profit_points<=0.0)
      return false;

   double candidate=0.0;
   if(type==POSITION_TYPE_BUY)
      candidate=tick.bid-InpTrailingDistancePoints*point;
   else
      candidate=tick.ask+InpTrailingDistancePoints*point;

   candidate=NormalizePrice(symbol,candidate);

   // Trailing must protect profit and never move SL behind the entry price.
   if(type==POSITION_TYPE_BUY && candidate<open)
      candidate=NormalizePrice(symbol,open);
   if(type==POSITION_TYPE_SELL && candidate>open)
      candidate=NormalizePrice(symbol,open);

   if(!CandidateAllowed(symbol,type,candidate))
      return false;

   double step_price=MathMax(1,InpTrailingStepPoints)*point;
   if(!ImprovesStop(type,old_sl,candidate,step_price))
      return false;

   return ModifyPositionStops(ticket,symbol,candidate,tp);
  }

int ManageTrailingStops(const bool force_now=false)
  {
   if(!g_manager_enabled && !force_now)
      return 0;

   int modified=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=0;
      if(!SelectPositionByIndexSafe(i,ticket))
         continue;
      if(!PositionMatchesCurrentSelection())
         continue;
      if(ApplyTrailingToSelectedPosition(force_now))
         modified++;
     }
   return modified;
  }

//============================== DASHBOARD OBJECTS ===========================
void DeleteDashboard()
  {
   for(int i=ObjectsTotal(0)-1;i>=0;i--)
     {
      string name=ObjectName(0,i);
      if(StringFind(name,g_prefix)==0)
         ObjectDelete(0,name);
     }
  }

bool CreateRect(const string name,const int x,const int y,const int w,const int h,
                const color bg,const color border)
  {
   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0)) return false;
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   return true;
  }

bool CreateLabel(const string name,const string text,const int x,const int y,
                 const int size,const color clr,const string font="Arial")
  {
   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0)) return false;
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,name,OBJPROP_FONT,font);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   return true;
  }

bool CreateButton(const string name,const string text,const int x,const int y,
                  const int w,const int h,const color bg)
  {
   if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0)) return false;
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,QTS_GOLD);
   ObjectSetInteger(0,name,OBJPROP_COLOR,QTS_WHITE);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial Bold");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   return true;
  }

void BuildDashboard()
  {
   if(!InpShowDashboard)
      return;

   DeleteDashboard();

   int x=InpPanelX;
   int y=InpPanelY;
   int w=470;
   int h=420;

   CreateRect(g_prefix+"BG",x,y,w,h,QTS_BG,QTS_GOLD);
   CreateLabel(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,QTS_GOLD,"Arial Bold");
   CreateLabel(g_prefix+"SUBTITLE","TRAILING STOP MANAGER",x+18,y+38,11,QTS_WHITE,"Arial Bold");
   CreateLabel(g_prefix+"VERSION","MT5  v1.00",x+370,y+18,10,QTS_GRAY,"Arial Bold");

   CreateLabel(g_prefix+"STATUS","STATUS: ACTIVE",x+18,y+72,11,QTS_GREEN,"Arial Bold");
   CreateLabel(g_prefix+"ACCOUNT","ACCOUNT: ",x+18,y+101,10,QTS_WHITE);
   CreateLabel(g_prefix+"BALANCE","BALANCE: ",x+18,y+128,10,QTS_WHITE);
   CreateLabel(g_prefix+"EQUITY","EQUITY: ",x+245,y+128,10,QTS_WHITE);
   CreateLabel(g_prefix+"MARGIN","FREE MARGIN: ",x+18,y+155,10,QTS_WHITE);
   CreateLabel(g_prefix+"SYMBOL","SYMBOL: ",x+245,y+155,10,QTS_WHITE);
   CreateLabel(g_prefix+"SPREAD","SPREAD: ",x+18,y+182,10,QTS_WHITE);
   CreateLabel(g_prefix+"FILTER","FILTER: ",x+245,y+182,10,QTS_WHITE);

   CreateLabel(g_prefix+"POSITIONS","MANAGED POSITIONS: 0",x+18,y+217,10,QTS_WHITE,"Arial Bold");
   CreateLabel(g_prefix+"FLOAT","FLOATING P/L: 0.00",x+245,y+217,10,QTS_WHITE,"Arial Bold");

   CreateLabel(g_prefix+"START","TRAILING START: ",x+18,y+250,10,QTS_GRAY);
   CreateLabel(g_prefix+"DIST","TRAILING DISTANCE: ",x+245,y+250,10,QTS_GRAY);
   CreateLabel(g_prefix+"STEP","TRAILING STEP: ",x+18,y+277,10,QTS_GRAY);
   CreateLabel(g_prefix+"APPLIED","UPDATES: 0",x+245,y+277,10,QTS_GRAY);

   CreateButton(g_prefix+"TOGGLE","STOP MANAGER",x+18,y+318,205,38,QTS_RED);
   CreateButton(g_prefix+"TRAILNOW","TRAIL NOW",x+247,y+318,205,38,QTS_DARKBTN);

   CreateLabel(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",x+18,y+385,10,QTS_GOLD,"Arial Bold");
   ChartRedraw();
  }

void UpdateDashboard()
  {
   if(!InpShowDashboard)
      return;

   int managed=CountMatchedPositions();
   double floating=MatchedFloatingProfit();
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   double spread=0.0;
   MqlTick tick;
   if(point>0.0 && SymbolInfoTick(_Symbol,tick))
      spread=(tick.ask-tick.bid)/point;

   if(!g_manager_enabled)
      g_status="STOPPED";
   else if(managed<=0)
      g_status="WAITING - NO MATCHED POSITION";
   else
      g_status="MONITORING "+IntegerToString(managed)+" POSITION(S)";

   ObjectSetString(0,g_prefix+"STATUS",OBJPROP_TEXT,"STATUS: "+g_status);
   ObjectSetInteger(0,g_prefix+"STATUS",OBJPROP_COLOR,
                    g_manager_enabled ? (managed>0 ? QTS_GREEN : QTS_GOLD) : QTS_RED);

   ObjectSetString(0,g_prefix+"ACCOUNT",OBJPROP_TEXT,"ACCOUNT: "+AccountTypeText()+" | "+ScopeText());
   ObjectSetString(0,g_prefix+"BALANCE",OBJPROP_TEXT,"BALANCE: "+DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2));
   ObjectSetString(0,g_prefix+"EQUITY",OBJPROP_TEXT,"EQUITY: "+DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2));
   ObjectSetString(0,g_prefix+"MARGIN",OBJPROP_TEXT,"FREE MARGIN: "+DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE),2));
   ObjectSetString(0,g_prefix+"SYMBOL",OBJPROP_TEXT,"SYMBOL: "+_Symbol);
   ObjectSetString(0,g_prefix+"SPREAD",OBJPROP_TEXT,"SPREAD: "+DoubleToString(spread,1)+" pts");
   ObjectSetString(0,g_prefix+"FILTER",OBJPROP_TEXT,"FILTER: "+MagicFilterText());
   ObjectSetString(0,g_prefix+"POSITIONS",OBJPROP_TEXT,"MANAGED POSITIONS: "+IntegerToString(managed));
   ObjectSetString(0,g_prefix+"FLOAT",OBJPROP_TEXT,"FLOATING P/L: "+DoubleToString(floating,2));
   ObjectSetInteger(0,g_prefix+"FLOAT",OBJPROP_COLOR,(floating>=0.0 ? QTS_GREEN : QTS_RED));

   ObjectSetString(0,g_prefix+"START",OBJPROP_TEXT,"TRAILING START: "+IntegerToString(InpTrailingStartPoints)+" pts");
   ObjectSetString(0,g_prefix+"DIST",OBJPROP_TEXT,"TRAILING DISTANCE: "+IntegerToString(InpTrailingDistancePoints)+" pts");
   ObjectSetString(0,g_prefix+"STEP",OBJPROP_TEXT,"TRAILING STEP: "+IntegerToString(InpTrailingStepPoints)+" pts");
   ObjectSetString(0,g_prefix+"APPLIED",OBJPROP_TEXT,"UPDATES: "+IntegerToString(g_applied_count)+" | ERRORS: "+IntegerToString(g_error_count));

   ObjectSetString(0,g_prefix+"TOGGLE",OBJPROP_TEXT,g_manager_enabled ? "STOP MANAGER" : "START MANAGER");
   ObjectSetInteger(0,g_prefix+"TOGGLE",OBJPROP_BGCOLOR,g_manager_enabled ? QTS_RED : QTS_GREEN);

   ChartRedraw();
  }

//============================== EVENTS ======================================
int OnInit()
  {
   if(InpTrailingStartPoints<0 || InpTrailingDistancePoints<=0 || InpTrailingStepPoints<=0)
     {
      Print("Quantora: Invalid trailing parameters.");
      return INIT_PARAMETERS_INCORRECT;
     }

   int timer=(InpTimerSeconds<1 ? 1 : InpTimerSeconds);
   g_trade.SetAsyncMode(false);

   BuildDashboard();
   UpdateDashboard();
   EventSetTimer(timer);

   Log("Initialized successfully.");
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeleteDashboard();
   ChartRedraw();
   Log("Deinitialized. Reason="+IntegerToString(reason));
  }

void OnTick()
  {
   ManageTrailingStops(false);
  }

void OnTimer()
  {
   ManageTrailingStops(false);
   UpdateDashboard();
  }

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id!=CHARTEVENT_OBJECT_CLICK)
      return;

   if(sparam==g_prefix+"TOGGLE")
     {
      g_manager_enabled=!g_manager_enabled;
      g_status=(g_manager_enabled ? "ACTIVE" : "STOPPED");
      ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
      UpdateDashboard();
      return;
     }

   if(sparam==g_prefix+"TRAILNOW")
     {
      int modified=ManageTrailingStops(true);
      g_status=(modified>0 ? "TRAIL NOW APPLIED" : "NO ELIGIBLE POSITION");
      ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
      UpdateDashboard();
      return;
     }
  }

//===========================================================
// Developed by Quantora
//
// More Professional Trading Robots
//
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
