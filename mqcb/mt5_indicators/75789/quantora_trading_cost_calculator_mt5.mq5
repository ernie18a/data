//+------------------------------------------------------------------+
//|                             Quantora Trading Cost Calculator MT5 |
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
#property description "Professional trading cost calculator for MetaTrader 5."
#property description "Calculates spread cost, commission, swap and estimated total trading cost."

enum ENUM_Q_TRADE_DIRECTION
  {
   Q_BUY_TRADE  = 0,
   Q_SELL_TRADE = 1
  };

//============================== INPUTS =====================================
input group "========== COST SETTINGS =========="
input bool                   InpUseCurrentSymbol     = true;
input string                 InpCustomSymbol         = "";
input ENUM_Q_TRADE_DIRECTION InpTradeDirection       = Q_BUY_TRADE;
input double                 InpLotSize              = 0.10;
input double                 InpCommissionPerLot     = 7.00;  // round-turn or user convention
input int                    InpSwapDays             = 1;

input group "========== COST CLASSIFICATION =========="
input double                 InpLowCostPctMax        = 0.05;
input double                 InpModerateCostPctMax   = 0.15;
input double                 InpHighCostPctMax       = 0.30;

input group "========== DASHBOARD =========="
input bool                   InpShowPanel            = true;
input ENUM_BASE_CORNER       InpPanelCorner          = CORNER_LEFT_UPPER;
input int                    InpPanelX               = 15;
input int                    InpPanelY               = 145;
input int                    InpTimerSeconds         = 1;

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

//============================== STATE ======================================
string g_prefix="QTCC5_";
string g_symbol="";
string g_status="INITIALIZING";
string g_account_currency="";
string g_cost_status="UNKNOWN";

double g_bid=0.0;
double g_ask=0.0;
double g_spread_points=0.0;
double g_point=0.0;
double g_tick_size=0.0;
double g_tick_value=0.0;
double g_contract_size=0.0;

double g_point_value_per_lot=0.0;
double g_spread_cost=0.0;
double g_commission_cost=0.0;

double g_swap_long_raw=0.0;
double g_swap_short_raw=0.0;
long   g_swap_mode=0;

double g_swap_long_cost=0.0;
double g_swap_short_cost=0.0;
double g_selected_swap_cost=0.0;

double g_total_entry_cost=0.0;
double g_balance=0.0;
double g_cost_pct_balance=0.0;

//============================== HELPERS ====================================
string SelectedSymbol()
  {
   if(InpUseCurrentSymbol || StringLen(InpCustomSymbol)==0)
      return _Symbol;

   return InpCustomSymbol;
  }

string DirectionText()
  {
   return (InpTradeDirection==Q_BUY_TRADE ? "BUY" : "SELL");
  }

double MoneyValueForDistancePerLot(double distance)
  {
   if(distance<=0.0 || g_tick_size<=0.0 || g_tick_value<=0.0)
      return 0.0;

   return (distance/g_tick_size)*g_tick_value;
  }

double ConvertSwapToMoney(double swap_value,bool is_long)
  {
   // SYMBOL_SWAP_MODE semantics differ by broker/instrument.
   // We support the most common money/points-based modes and keep
   // calculation conservative for unsupported modes.
   switch((ENUM_SYMBOL_SWAP_MODE)g_swap_mode)
     {
      case SYMBOL_SWAP_MODE_POINTS:
        {
         double distance=swap_value*g_point;
         return MoneyValueForDistancePerLot(MathAbs(distance))*
                (swap_value<0.0 ? -1.0 : 1.0);
        }

      case SYMBOL_SWAP_MODE_CURRENCY_SYMBOL:
      case SYMBOL_SWAP_MODE_CURRENCY_MARGIN:
      case SYMBOL_SWAP_MODE_CURRENCY_DEPOSIT:
         return swap_value;

      case SYMBOL_SWAP_MODE_INTEREST_CURRENT:
      case SYMBOL_SWAP_MODE_INTEREST_OPEN:
        {
         // Interest modes require additional broker-specific context.
         // We avoid fabricating a precise cash value.
         return 0.0;
        }

      case SYMBOL_SWAP_MODE_REOPEN_CURRENT:
      case SYMBOL_SWAP_MODE_REOPEN_BID:
        {
         // Reopen modes are price adjustments, not direct cash values.
         return 0.0;
        }

      case SYMBOL_SWAP_MODE_DISABLED:
      default:
         return 0.0;
     }
  }

void ClassifyCost()
  {
   if(g_cost_pct_balance<=InpLowCostPctMax)
      g_cost_status="LOW";
   else if(g_cost_pct_balance<=InpModerateCostPctMax)
      g_cost_status="MODERATE";
   else if(g_cost_pct_balance<=InpHighCostPctMax)
      g_cost_status="HIGH";
   else
      g_cost_status="VERY HIGH";
  }

color CostColor()
  {
   if(g_cost_status=="LOW")
      return Q_GREEN;
   if(g_cost_status=="MODERATE")
      return Q_YELLOW;
   if(g_cost_status=="HIGH")
      return Q_ORANGE;
   return Q_RED;
  }

bool CalculateCosts()
  {
   g_symbol=SelectedSymbol();

   if(!SymbolSelect(g_symbol,true))
     {
      g_status="SYMBOL NOT AVAILABLE";
      return false;
     }

   if(InpLotSize<=0.0 || InpCommissionPerLot<0.0 || InpSwapDays<0)
     {
      g_status="INVALID INPUT";
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

   g_point=SymbolInfoDouble(g_symbol,SYMBOL_POINT);
   g_tick_size=SymbolInfoDouble(g_symbol,SYMBOL_TRADE_TICK_SIZE);
   g_tick_value=SymbolInfoDouble(g_symbol,SYMBOL_TRADE_TICK_VALUE);
   g_contract_size=SymbolInfoDouble(g_symbol,SYMBOL_TRADE_CONTRACT_SIZE);

   g_swap_long_raw=SymbolInfoDouble(g_symbol,SYMBOL_SWAP_LONG);
   g_swap_short_raw=SymbolInfoDouble(g_symbol,SYMBOL_SWAP_SHORT);
   g_swap_mode=SymbolInfoInteger(g_symbol,SYMBOL_SWAP_MODE);

   g_account_currency=AccountInfoString(ACCOUNT_CURRENCY);
   g_balance=AccountInfoDouble(ACCOUNT_BALANCE);

   if(g_point<=0.0 || g_tick_size<=0.0 || g_tick_value<=0.0)
     {
      g_status="INVALID SYMBOL DATA";
      return false;
     }

   g_spread_points=(g_ask-g_bid)/g_point;

   g_point_value_per_lot=MoneyValueForDistancePerLot(g_point);
   g_spread_cost=g_point_value_per_lot*g_spread_points*InpLotSize;

   g_commission_cost=InpCommissionPerLot*InpLotSize;

   g_swap_long_cost=ConvertSwapToMoney(g_swap_long_raw,true)*InpLotSize*InpSwapDays;
   g_swap_short_cost=ConvertSwapToMoney(g_swap_short_raw,false)*InpLotSize*InpSwapDays;

   g_selected_swap_cost=
      (InpTradeDirection==Q_BUY_TRADE ? g_swap_long_cost : g_swap_short_cost);

   // Entry cost treats negative swap as a cost and positive swap as a credit.
   g_total_entry_cost=g_spread_cost+g_commission_cost-g_selected_swap_cost;

   g_cost_pct_balance=
      (g_balance>0.0 ? 100.0*g_total_entry_cost/g_balance : 0.0);

   ClassifyCost();
   g_status="CALCULATION READY";

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

   CreateRectangle(g_prefix+"BG",x,y,540,500,Q_BG,Q_GOLD);

   CreateLabel(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   CreateLabel(g_prefix+"SUB","TRADING COST CALCULATOR",x+18,y+38,11,Q_WHITE,true);
   CreateLabel(g_prefix+"VER","MT5 v1.00",x+450,y+18,9,Q_GRAY);

   CreateLabel(g_prefix+"STATUS","STATUS: INITIALIZING",x+18,y+76,10,Q_GREEN,true);

   CreateLabel(g_prefix+"SYMBOL","SYMBOL: --",x+18,y+110,10,Q_WHITE);
   CreateLabel(g_prefix+"DIR","DIRECTION: BUY",x+280,y+110,10,Q_WHITE);

   CreateLabel(g_prefix+"LOT","LOT SIZE: 0.10",x+18,y+142,10,Q_GRAY);
   CreateLabel(g_prefix+"CUR","ACCOUNT CURRENCY: --",x+280,y+142,10,Q_GRAY);

   CreateLabel(g_prefix+"SPREAD","CURRENT SPREAD: 0.0 pts",x+18,y+182,10,Q_WHITE);
   CreateLabel(g_prefix+"SPREADCOST","SPREAD COST: 0.00",x+280,y+182,10,Q_GOLD,true);

   CreateLabel(g_prefix+"COMMLOT","COMMISSION / LOT: 0.00",x+18,y+218,10,Q_WHITE);
   CreateLabel(g_prefix+"COMMCOST","COMMISSION COST: 0.00",x+280,y+218,10,Q_WHITE);

   CreateLabel(g_prefix+"SWAPL","SWAP LONG: 0.00",x+18,y+254,10,Q_GRAY);
   CreateLabel(g_prefix+"SWAPS","SWAP SHORT: 0.00",x+280,y+254,10,Q_GRAY);

   CreateLabel(g_prefix+"SEL_SWAP","SELECTED SWAP COST: 0.00",x+18,y+290,10,Q_WHITE);
   CreateLabel(g_prefix+"SWAPDAYS","SWAP DAYS: 1",x+280,y+290,10,Q_GRAY);

   CreateRectangle(g_prefix+"SEP",x+18,y+326,504,2,Q_BORDER,Q_BORDER);

   CreateLabel(g_prefix+"TOTAL","ESTIMATED TOTAL COST: 0.00",x+18,y+348,13,Q_GOLD,true);
   CreateLabel(g_prefix+"PCT","COST / BALANCE: 0.000 %",x+18,y+388,11,Q_WHITE,true);
   CreateLabel(g_prefix+"COSTSTAT","COST STATUS: UNKNOWN",x+280,y+388,11,Q_GRAY,true);

   CreateLabel(g_prefix+"TICKSIZE","TICK SIZE: 0.00000",x+18,y+426,10,Q_GRAY);
   CreateLabel(g_prefix+"TICKVALUE","TICK VALUE: 0.00",x+280,y+426,10,Q_GRAY);

   CreateLabel(g_prefix+"CONTRACT","CONTRACT SIZE: 0.00",x+18,y+456,10,Q_GRAY);
   CreateLabel(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",x+280,y+456,9,Q_GOLD);

   ChartRedraw();
  }

void UpdatePanel()
  {
   if(!InpShowPanel)
      return;

   int digits=(int)SymbolInfoInteger(g_symbol,SYMBOL_DIGITS);
   color cost_color=CostColor();

   ObjectSetString(0,g_prefix+"STATUS",OBJPROP_TEXT,"STATUS: "+g_status);
   ObjectSetInteger(0,g_prefix+"STATUS",OBJPROP_COLOR,
                    g_status=="CALCULATION READY" ? Q_GREEN : Q_YELLOW);

   ObjectSetString(0,g_prefix+"SYMBOL",OBJPROP_TEXT,"SYMBOL: "+g_symbol);
   ObjectSetString(0,g_prefix+"DIR",OBJPROP_TEXT,"DIRECTION: "+DirectionText());

   ObjectSetString(0,g_prefix+"LOT",OBJPROP_TEXT,
                   "LOT SIZE: "+DoubleToString(InpLotSize,2));
   ObjectSetString(0,g_prefix+"CUR",OBJPROP_TEXT,
                   "ACCOUNT CURRENCY: "+g_account_currency);

   ObjectSetString(0,g_prefix+"SPREAD",OBJPROP_TEXT,
                   "CURRENT SPREAD: "+DoubleToString(g_spread_points,1)+" pts");
   ObjectSetString(0,g_prefix+"SPREADCOST",OBJPROP_TEXT,
                   "SPREAD COST: "+DoubleToString(g_spread_cost,2)+" "+g_account_currency);

   ObjectSetString(0,g_prefix+"COMMLOT",OBJPROP_TEXT,
                   "COMMISSION / LOT: "+DoubleToString(InpCommissionPerLot,2));
   ObjectSetString(0,g_prefix+"COMMCOST",OBJPROP_TEXT,
                   "COMMISSION COST: "+DoubleToString(g_commission_cost,2)+" "+g_account_currency);

   ObjectSetString(0,g_prefix+"SWAPL",OBJPROP_TEXT,
                   "SWAP LONG: "+DoubleToString(g_swap_long_cost,2)+" "+g_account_currency);
   ObjectSetString(0,g_prefix+"SWAPS",OBJPROP_TEXT,
                   "SWAP SHORT: "+DoubleToString(g_swap_short_cost,2)+" "+g_account_currency);

   ObjectSetString(0,g_prefix+"SEL_SWAP",OBJPROP_TEXT,
                   "SELECTED SWAP COST: "+DoubleToString(g_selected_swap_cost,2)+" "+g_account_currency);
   ObjectSetString(0,g_prefix+"SWAPDAYS",OBJPROP_TEXT,
                   "SWAP DAYS: "+IntegerToString(InpSwapDays));

   ObjectSetString(0,g_prefix+"TOTAL",OBJPROP_TEXT,
                   "ESTIMATED TOTAL COST: "+DoubleToString(g_total_entry_cost,2)+" "+g_account_currency);

   ObjectSetString(0,g_prefix+"PCT",OBJPROP_TEXT,
                   "COST / BALANCE: "+DoubleToString(g_cost_pct_balance,3)+" %");

   ObjectSetString(0,g_prefix+"COSTSTAT",OBJPROP_TEXT,
                   "COST STATUS: "+g_cost_status);
   ObjectSetInteger(0,g_prefix+"COSTSTAT",OBJPROP_COLOR,cost_color);

   ObjectSetString(0,g_prefix+"TICKSIZE",OBJPROP_TEXT,
                   "TICK SIZE: "+DoubleToString(g_tick_size,digits));
   ObjectSetString(0,g_prefix+"TICKVALUE",OBJPROP_TEXT,
                   "TICK VALUE: "+DoubleToString(g_tick_value,4)+" "+g_account_currency);

   ObjectSetString(0,g_prefix+"CONTRACT",OBJPROP_TEXT,
                   "CONTRACT SIZE: "+DoubleToString(g_contract_size,2));

   ChartRedraw();
  }

//============================== INDICATOR EVENTS ===========================
int OnInit()
  {
   if(InpLotSize<=0.0 ||
      InpCommissionPerLot<0.0 ||
      InpSwapDays<0 ||
      InpTimerSeconds<1 ||
      InpLowCostPctMax<0.0 ||
      InpModerateCostPctMax<InpLowCostPctMax ||
      InpHighCostPctMax<InpModerateCostPctMax)
     {
      Print("Quantora Trading Cost Calculator MT5: Invalid input values.");
      return INIT_PARAMETERS_INCORRECT;
     }

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Quantora Trading Cost Calculator MT5 v1.00");

   g_symbol=SelectedSymbol();

   BuildPanel();
   CalculateCosts();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
     {
      Print("Quantora Trading Cost Calculator MT5: EventSetTimer failed. Error ",
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
   CalculateCosts();
   UpdatePanel();
  }

//===========================================================
// Developed by Quantora
//
// More Professional Trading Robots
//
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
