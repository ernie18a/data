//+------------------------------------------------------------------+
//|                   Quantora Drawdown Monitor MT5                  |
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
#property description "Professional drawdown and account risk monitor for MetaTrader 5."
#property description "Displays current drawdown, equity drawdown, daily P/L and configurable risk status."

//============================== INPUTS =====================================
input group "========== RISK LEVELS =========="
input double              InpLowMaxPct            = 2.0;
input double              InpModerateMaxPct       = 5.0;
input double              InpHighMaxPct           = 10.0;

input group "========== MONITOR SETTINGS =========="
input bool                InpCountAllPositions    = true;
input bool                InpUseMagicFilter       = false;
input long                InpMagicNumber          = 0;

input group "========== DASHBOARD =========="
input bool                InpShowPanel            = true;
input ENUM_BASE_CORNER    InpPanelCorner          = CORNER_LEFT_UPPER;
input int                 InpPanelX               = 15;
input int                 InpPanelY               = 145;
input int                 InpTimerSeconds         = 1;

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
string g_prefix="QDDM5_";
string g_status="INITIALIZING";
string g_risk_status="LOW";
string g_currency="";

double g_balance=0.0;
double g_equity=0.0;
double g_floating=0.0;

double g_current_dd_money=0.0;
double g_current_dd_pct=0.0;

double g_peak_equity=0.0;
double g_equity_dd_money=0.0;
double g_equity_dd_pct=0.0;
double g_max_dd_money=0.0;
double g_max_dd_pct=0.0;

double g_daily_start_balance=0.0;
double g_daily_closed_pl=0.0;
double g_daily_pl_total=0.0;
double g_daily_dd_money=0.0;
double g_daily_dd_pct=0.0;

int    g_open_positions=0;
datetime g_day_start=0;

//============================== HELPERS ====================================
datetime StartOfDay(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t,dt);
   dt.hour=0;
   dt.min=0;
   dt.sec=0;
   return StructToTime(dt);
}

bool IsMagicMatch(long magic)
{
   if(!InpUseMagicFilter)
      return true;

   return (magic==InpMagicNumber);
}

int CountOpenPositions()
{
   int count=0;

   for(int i=0;i<PositionsTotal();i++)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0)
         continue;

      if(!PositionSelectByTicket(ticket))
         continue;

      if(InpUseMagicFilter)
      {
         long magic=(long)PositionGetInteger(POSITION_MAGIC);
         if(!IsMagicMatch(magic))
            continue;
      }

      count++;
   }

   return count;
}

double CalculateFilteredFloatingPL()
{
   if(!InpUseMagicFilter)
      return AccountInfoDouble(ACCOUNT_PROFIT);

   double total=0.0;

   for(int i=0;i<PositionsTotal();i++)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0)
         continue;

      if(!PositionSelectByTicket(ticket))
         continue;

      long magic=(long)PositionGetInteger(POSITION_MAGIC);
      if(!IsMagicMatch(magic))
         continue;

      total+=PositionGetDouble(POSITION_PROFIT);
      total+=PositionGetDouble(POSITION_SWAP);
   }

   return total;
}

double DealNetResult(ulong ticket)
{
   return HistoryDealGetDouble(ticket,DEAL_PROFIT)
        + HistoryDealGetDouble(ticket,DEAL_SWAP)
        + HistoryDealGetDouble(ticket,DEAL_COMMISSION)
        + HistoryDealGetDouble(ticket,DEAL_FEE);
}

double CalculateTodayClosedPL()
{
   datetime now=TimeCurrent();
   datetime from=StartOfDay(now);

   if(!HistorySelect(from,now))
      return 0.0;

   double total=0.0;
   int deals=HistoryDealsTotal();

   for(int i=0;i<deals;i++)
   {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
         continue;

      ENUM_DEAL_ENTRY entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);

      // Include balance-affecting closed deal legs.
      if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_OUT_BY)
         continue;

      if(InpUseMagicFilter)
      {
         long magic=(long)HistoryDealGetInteger(ticket,DEAL_MAGIC);
         if(!IsMagicMatch(magic))
            continue;
      }

      total+=DealNetResult(ticket);
   }

   return total;
}

void ResetDayIfNeeded()
{
   datetime today=StartOfDay(TimeCurrent());

   if(g_day_start==0)
      g_day_start=today;

   if(today!=g_day_start)
   {
      g_day_start=today;
      g_daily_start_balance=0.0;
      g_daily_closed_pl=0.0;
      g_daily_pl_total=0.0;
      g_daily_dd_money=0.0;
      g_daily_dd_pct=0.0;
   }
}

void UpdateRiskStatus()
{
   double reference=MathMax(g_current_dd_pct,MathMax(g_equity_dd_pct,g_daily_dd_pct));

   if(reference<=InpLowMaxPct)
      g_risk_status="LOW";
   else if(reference<=InpModerateMaxPct)
      g_risk_status="MODERATE";
   else if(reference<=InpHighMaxPct)
      g_risk_status="HIGH";
   else
      g_risk_status="CRITICAL";
}

color RiskColor()
{
   if(g_risk_status=="LOW")
      return Q_GREEN;
   if(g_risk_status=="MODERATE")
      return Q_YELLOW;
   if(g_risk_status=="HIGH")
      return Q_ORANGE;
   return Q_RED;
}

void UpdateData()
{
   ResetDayIfNeeded();

   g_currency=AccountInfoString(ACCOUNT_CURRENCY);
   g_balance=AccountInfoDouble(ACCOUNT_BALANCE);
   g_equity=AccountInfoDouble(ACCOUNT_EQUITY);

   g_floating=CalculateFilteredFloatingPL();
   g_open_positions=CountOpenPositions();

   // Current drawdown relative to current balance.
   g_current_dd_money=MathMax(0.0,g_balance-g_equity);
   g_current_dd_pct=(g_balance>0.0 ? 100.0*g_current_dd_money/g_balance : 0.0);

   // Peak equity and max drawdown are tracked from indicator initialization.
   if(g_peak_equity<=0.0 || g_equity>g_peak_equity)
      g_peak_equity=g_equity;

   g_equity_dd_money=MathMax(0.0,g_peak_equity-g_equity);
   g_equity_dd_pct=(g_peak_equity>0.0 ? 100.0*g_equity_dd_money/g_peak_equity : 0.0);

   if(g_equity_dd_money>g_max_dd_money)
      g_max_dd_money=g_equity_dd_money;

   if(g_equity_dd_pct>g_max_dd_pct)
      g_max_dd_pct=g_equity_dd_pct;

   // Daily start balance is reconstructed from current balance minus today's closed P/L.
   g_daily_closed_pl=CalculateTodayClosedPL();
   g_daily_start_balance=g_balance-g_daily_closed_pl;

   // Total daily account effect = closed result + current floating result.
   g_daily_pl_total=g_daily_closed_pl+g_floating;

   double daily_reference_equity=g_daily_start_balance;
   g_daily_dd_money=MathMax(0.0,daily_reference_equity-g_equity);
   g_daily_dd_pct=(daily_reference_equity>0.0
                   ? 100.0*g_daily_dd_money/daily_reference_equity
                   : 0.0);

   UpdateRiskStatus();
   g_status="MONITORING";
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

   CreateRectangle(g_prefix+"BG",x,y,560,560,Q_BG,Q_GOLD);

   CreateLabel(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   CreateLabel(g_prefix+"SUB","DRAWDOWN MONITOR",x+18,y+38,11,Q_WHITE,true);
   CreateLabel(g_prefix+"VER","MT5 v1.00",x+470,y+18,9,Q_GRAY);

   CreateLabel(g_prefix+"STATUS","STATUS: INITIALIZING",x+18,y+74,10,Q_GREEN,true);
   CreateLabel(g_prefix+"RISK","RISK STATUS: LOW",x+300,y+74,11,Q_GREEN,true);

   CreateLabel(g_prefix+"BAL","BALANCE: 0.00",x+18,y+112,10,Q_WHITE);
   CreateLabel(g_prefix+"EQ","EQUITY: 0.00",x+300,y+112,10,Q_WHITE);
   CreateLabel(g_prefix+"FLOAT","FLOATING P/L: 0.00",x+18,y+148,10,Q_GRAY);
   CreateLabel(g_prefix+"POS","OPEN POSITIONS: 0",x+300,y+148,10,Q_GRAY);

   CreateRectangle(g_prefix+"SEP1",x+18,y+184,524,2,Q_BORDER,Q_BORDER);

   CreateLabel(g_prefix+"CDD","CURRENT DRAWDOWN",x+18,y+206,11,Q_GOLD,true);
   CreateLabel(g_prefix+"CDDM","MONEY: 0.00",x+18,y+242,10,Q_WHITE);
   CreateLabel(g_prefix+"CDDP","PERCENT: 0.00 %",x+300,y+242,10,Q_WHITE);

   CreateLabel(g_prefix+"PEAK","PEAK EQUITY: 0.00",x+18,y+278,10,Q_WHITE);
   CreateLabel(g_prefix+"EDD","EQUITY DD: 0.00 %",x+300,y+278,10,Q_WHITE);
   CreateLabel(g_prefix+"MAXDD","MAX DD: 0.00 %",x+18,y+314,10,Q_RED,true);

   CreateRectangle(g_prefix+"SEP2",x+18,y+348,524,2,Q_BORDER,Q_BORDER);

   CreateLabel(g_prefix+"DAY","DAILY PERFORMANCE",x+18,y+370,11,Q_GOLD,true);
   CreateLabel(g_prefix+"DSTART","DAILY START: 0.00",x+18,y+406,10,Q_WHITE);
   CreateLabel(g_prefix+"DPL","DAILY P/L: 0.00",x+300,y+406,10,Q_WHITE);
   CreateLabel(g_prefix+"DDD","DAILY DD: 0.00 %",x+18,y+442,10,Q_WHITE);

   CreateRectangle(g_prefix+"PB_BG",x+18,y+478,524,22,Q_DARK2,Q_BORDER);
   CreateRectangle(g_prefix+"PB_FILL",x+20,y+480,1,18,Q_GREEN,Q_GREEN);

   CreateLabel(g_prefix+"LEVELS","LOW < 2%   MODERATE < 5%   HIGH < 10%   CRITICAL > 10%",
               x+18,y+512,9,Q_GRAY);

   CreateLabel(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",
               x+18,y+540,9,Q_GOLD);

   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel)
      return;

   color risk_color=RiskColor();

   ObjectSetString(0,g_prefix+"STATUS",OBJPROP_TEXT,"STATUS: "+g_status);
   ObjectSetString(0,g_prefix+"RISK",OBJPROP_TEXT,"RISK STATUS: "+g_risk_status);
   ObjectSetInteger(0,g_prefix+"RISK",OBJPROP_COLOR,risk_color);

   ObjectSetString(0,g_prefix+"BAL",OBJPROP_TEXT,
                   "BALANCE: "+DoubleToString(g_balance,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"EQ",OBJPROP_TEXT,
                   "EQUITY: "+DoubleToString(g_equity,2)+" "+g_currency);

   ObjectSetString(0,g_prefix+"FLOAT",OBJPROP_TEXT,
                   "FLOATING P/L: "+DoubleToString(g_floating,2)+" "+g_currency);
   ObjectSetInteger(0,g_prefix+"FLOAT",OBJPROP_COLOR,
                    g_floating>0.0 ? Q_GREEN : g_floating<0.0 ? Q_RED : Q_GRAY);

   ObjectSetString(0,g_prefix+"POS",OBJPROP_TEXT,
                   "OPEN POSITIONS: "+IntegerToString(g_open_positions));

   ObjectSetString(0,g_prefix+"CDDM",OBJPROP_TEXT,
                   "MONEY: "+DoubleToString(g_current_dd_money,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"CDDP",OBJPROP_TEXT,
                   "PERCENT: "+DoubleToString(g_current_dd_pct,2)+" %");

   ObjectSetString(0,g_prefix+"PEAK",OBJPROP_TEXT,
                   "PEAK EQUITY: "+DoubleToString(g_peak_equity,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"EDD",OBJPROP_TEXT,
                   "EQUITY DD: "+DoubleToString(g_equity_dd_pct,2)+" %");
   ObjectSetString(0,g_prefix+"MAXDD",OBJPROP_TEXT,
                   "MAX DD: "+DoubleToString(g_max_dd_pct,2)+" %");

   ObjectSetString(0,g_prefix+"DSTART",OBJPROP_TEXT,
                   "DAILY START: "+DoubleToString(g_daily_start_balance,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"DPL",OBJPROP_TEXT,
                   "DAILY P/L: "+DoubleToString(g_daily_pl_total,2)+" "+g_currency);
   ObjectSetInteger(0,g_prefix+"DPL",OBJPROP_COLOR,
                    g_daily_pl_total>0.0 ? Q_GREEN : g_daily_pl_total<0.0 ? Q_RED : Q_GRAY);

   ObjectSetString(0,g_prefix+"DDD",OBJPROP_TEXT,
                   "DAILY DD: "+DoubleToString(g_daily_dd_pct,2)+" %");

   double reference=MathMax(g_current_dd_pct,MathMax(g_equity_dd_pct,g_daily_dd_pct));
   double scale=MathMax(InpHighMaxPct,1.0);
   int fill=(int)MathRound(520.0*MathMin(reference,scale)/scale);
   fill=MathMax(1,MathMin(520,fill));

   ObjectSetInteger(0,g_prefix+"PB_FILL",OBJPROP_XSIZE,fill);
   ObjectSetInteger(0,g_prefix+"PB_FILL",OBJPROP_BGCOLOR,risk_color);
   ObjectSetInteger(0,g_prefix+"PB_FILL",OBJPROP_BORDER_COLOR,risk_color);

   string levels=
      "LOW < "+DoubleToString(InpLowMaxPct,1)+"%   MODERATE < "+
      DoubleToString(InpModerateMaxPct,1)+"%   HIGH < "+
      DoubleToString(InpHighMaxPct,1)+"%   CRITICAL > "+
      DoubleToString(InpHighMaxPct,1)+"%";

   ObjectSetString(0,g_prefix+"LEVELS",OBJPROP_TEXT,levels);

   ChartRedraw();
}

//============================== INDICATOR EVENTS ===========================
int OnInit()
{
   if(InpTimerSeconds<1 ||
      InpLowMaxPct<0.0 ||
      InpModerateMaxPct<InpLowMaxPct ||
      InpHighMaxPct<InpModerateMaxPct)
   {
      Print("Quantora Drawdown Monitor MT5: Invalid input values.");
      return INIT_PARAMETERS_INCORRECT;
   }

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Quantora Drawdown Monitor MT5 v1.00");

   g_day_start=StartOfDay(TimeCurrent());
   g_peak_equity=AccountInfoDouble(ACCOUNT_EQUITY);

   BuildPanel();
   UpdateData();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora Drawdown Monitor MT5: EventSetTimer failed. Error ",
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
   UpdateData();
   UpdatePanel();
}

//===========================================================
// Developed by Quantora
//
// More Professional Trading Robots
//
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
