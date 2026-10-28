//+------------------------------------------------------------------+
//|                              Quantora Drawdown Monitor MT5 v1.00 |
//|              Professional Account Risk Dashboard                 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Professional drawdown and account risk monitor for MetaTrader 5."
#property description "Displays current, daily and peak-equity drawdown with account risk statistics."

input group "========== RISK LEVELS =========="
input double InpWarningDDPercent = 5.0;
input double InpDangerDDPercent  = 10.0;

input group "========== FILTER =========="
input bool   InpAllSymbols       = true;
input bool   InpUseMagicFilter   = false;
input long   InpMagicNumber      = 0;

input group "========== DASHBOARD =========="
input bool             InpShowPanel    = true;
input ENUM_BASE_CORNER InpPanelCorner  = CORNER_LEFT_UPPER;
input int              InpPanelX       = 15;
input int              InpPanelY       = 145;
input int              InpTimerSeconds = 1;

#define Q_BG      C'8,23,38'
#define Q_GOLD    C'212,175,55'
#define Q_WHITE   C'245,245,245'
#define Q_GRAY    C'169,176,184'
#define Q_GREEN   C'0,200,83'
#define Q_YELLOW  C'255,193,7'
#define Q_ORANGE  C'255,152,0'
#define Q_RED     C'255,82,82'
#define Q_BORDER  C'62,76,89'

string g_prefix="QDDM5_";
string g_currency="";
string g_risk="LOW";

double g_balance=0.0;
double g_equity=0.0;
double g_free_margin=0.0;
double g_margin=0.0;
double g_margin_level=0.0;
double g_floating=0.0;

double g_current_dd_money=0.0;
double g_current_dd_pct=0.0;
double g_peak_equity=0.0;
double g_peak_dd_money=0.0;
double g_peak_dd_pct=0.0;

double g_day_start_balance=0.0;
double g_day_start_equity=0.0;
double g_daily_pnl=0.0;
double g_daily_dd_money=0.0;
double g_daily_dd_pct=0.0;

int g_positions=0;
datetime g_day_marker=0;

datetime DayStart(datetime t)
{
   MqlDateTime d;
   TimeToStruct(t,d);
   d.hour=0; d.min=0; d.sec=0;
   return StructToTime(d);
}

bool PositionMatches()
{
   if(!InpAllSymbols && PositionGetString(POSITION_SYMBOL)!=_Symbol)
      return false;
   if(InpUseMagicFilter && (long)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber)
      return false;
   return true;
}

double ClosedPnLSince(datetime from_time)
{
   if(!HistorySelect(from_time,TimeCurrent()))
      return 0.0;

   double result=0.0;
   int total=HistoryDealsTotal();

   for(int i=0;i<total;i++)
   {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0) continue;

      ENUM_DEAL_ENTRY entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
      if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_OUT_BY)
         continue;

      ENUM_DEAL_TYPE type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);
      if(type!=DEAL_TYPE_BUY && type!=DEAL_TYPE_SELL)
         continue;

      if(!InpAllSymbols && HistoryDealGetString(ticket,DEAL_SYMBOL)!=_Symbol)
         continue;

      if(InpUseMagicFilter && (long)HistoryDealGetInteger(ticket,DEAL_MAGIC)!=InpMagicNumber)
         continue;

      result+=HistoryDealGetDouble(ticket,DEAL_PROFIT);
      result+=HistoryDealGetDouble(ticket,DEAL_SWAP);
      result+=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
      result+=HistoryDealGetDouble(ticket,DEAL_FEE);
   }

   return result;
}

void ResetDailyReference()
{
   g_day_marker=DayStart(TimeCurrent());
   double closed_today=ClosedPnLSince(g_day_marker);

   // Estimate balance at the beginning of the broker day.
   g_day_start_balance=AccountInfoDouble(ACCOUNT_BALANCE)-closed_today;
   g_day_start_equity=g_day_start_balance;
}

void UpdateOpenData()
{
   g_positions=0;
   g_floating=0.0;

   for(int i=0;i<PositionsTotal();i++)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket))
         continue;

      if(!PositionMatches())
         continue;

      g_positions++;
      g_floating+=PositionGetDouble(POSITION_PROFIT);
      g_floating+=PositionGetDouble(POSITION_SWAP);
   }
}

void UpdateData()
{
   datetime today=DayStart(TimeCurrent());
   if(g_day_marker!=today)
      ResetDailyReference();

   g_currency=AccountInfoString(ACCOUNT_CURRENCY);
   g_balance=AccountInfoDouble(ACCOUNT_BALANCE);
   g_equity=AccountInfoDouble(ACCOUNT_EQUITY);
   g_margin=AccountInfoDouble(ACCOUNT_MARGIN);
   g_free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   g_margin_level=AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);

   UpdateOpenData();

   g_current_dd_money=MathMax(0.0,g_balance-g_equity);
   g_current_dd_pct=(g_balance>0.0 ? 100.0*g_current_dd_money/g_balance : 0.0);

   if(g_peak_equity<=0.0 || g_equity>g_peak_equity)
      g_peak_equity=g_equity;

   g_peak_dd_money=MathMax(0.0,g_peak_equity-g_equity);
   g_peak_dd_pct=(g_peak_equity>0.0 ? 100.0*g_peak_dd_money/g_peak_equity : 0.0);

   double closed_today=ClosedPnLSince(g_day_marker);
   g_daily_pnl=closed_today+g_floating;

   g_daily_dd_money=MathMax(0.0,g_day_start_equity-g_equity);
   g_daily_dd_pct=(g_day_start_equity>0.0 ? 100.0*g_daily_dd_money/g_day_start_equity : 0.0);

   double risk_dd=MathMax(g_current_dd_pct,MathMax(g_daily_dd_pct,g_peak_dd_pct));

   if(risk_dd>=InpDangerDDPercent)
      g_risk="DANGER";
   else if(risk_dd>=InpWarningDDPercent)
      g_risk="WARNING";
   else
      g_risk="LOW";
}

color RiskColor()
{
   if(g_risk=="DANGER") return Q_RED;
   if(g_risk=="WARNING") return Q_ORANGE;
   return Q_GREEN;
}

color ValueColor(double value)
{
   if(value>0.0) return Q_GREEN;
   if(value<0.0) return Q_RED;
   return Q_GRAY;
}

bool Rect(string n,int x,int y,int w,int h,color bg,color br)
{
   if(!ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0)) return false;
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
   if(!ObjectCreate(0,n,OBJ_LABEL,0,0,0)) return false;
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

   int x=InpPanelX,y=InpPanelY;
   Rect(g_prefix+"BG",x,y,590,560,Q_BG,Q_GOLD);

   Label(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   Label(g_prefix+"SUB","DRAWDOWN MONITOR MT5",x+18,y+38,11,Q_WHITE,true);
   Label(g_prefix+"VER","v1.00",x+520,y+18,9,Q_GRAY);

   Label(g_prefix+"RISK","RISK LEVEL: LOW",x+18,y+78,12,Q_GREEN,true);

   Label(g_prefix+"BAL","BALANCE: --",x+18,y+120,10,Q_WHITE);
   Label(g_prefix+"EQ","EQUITY: --",x+300,y+120,10,Q_WHITE);
   Label(g_prefix+"FLOAT","FLOATING P/L: --",x+18,y+154,10,Q_GRAY);
   Label(g_prefix+"POS","OPEN POSITIONS: 0",x+300,y+154,10,Q_GRAY);

   Rect(g_prefix+"SEP1",x+18,y+188,554,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"CURRENT_TITLE","CURRENT DRAWDOWN",x+18,y+210,10,Q_GOLD,true);
   Label(g_prefix+"CDD","MONEY: 0.00",x+18,y+244,10,Q_WHITE);
   Label(g_prefix+"CDDP","PERCENT: 0.00%",x+300,y+244,10,Q_WHITE);

   Label(g_prefix+"DAILY_TITLE","DAILY DRAWDOWN",x+18,y+286,10,Q_GOLD,true);
   Label(g_prefix+"DDD","MONEY: 0.00",x+18,y+320,10,Q_WHITE);
   Label(g_prefix+"DDDP","PERCENT: 0.00%",x+300,y+320,10,Q_WHITE);
   Label(g_prefix+"DPNL","DAILY P/L: 0.00",x+18,y+354,10,Q_WHITE);

   Label(g_prefix+"PEAK_TITLE","SESSION PEAK-EQUITY DRAWDOWN",x+18,y+396,10,Q_GOLD,true);
   Label(g_prefix+"PEAK","PEAK EQUITY: 0.00",x+18,y+430,10,Q_WHITE);
   Label(g_prefix+"PDD","DRAWDOWN: 0.00",x+300,y+430,10,Q_WHITE);
   Label(g_prefix+"PDDP","DRAWDOWN %: 0.00%",x+18,y+464,10,Q_WHITE);

   Rect(g_prefix+"SEP2",x+18,y+496,554,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"MARGIN","MARGIN: 0.00",x+18,y+514,9,Q_GRAY);
   Label(g_prefix+"FREE","FREE MARGIN: 0.00",x+200,y+514,9,Q_GRAY);
   Label(g_prefix+"LEVEL","MARGIN LEVEL: 0.00%",x+410,y+514,9,Q_GRAY);
   Label(g_prefix+"STATUS","STATUS: MONITORING",x+18,y+540,9,Q_GREEN);

   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel) return;

   ObjectSetString(0,g_prefix+"RISK",OBJPROP_TEXT,"RISK LEVEL: "+g_risk);
   ObjectSetInteger(0,g_prefix+"RISK",OBJPROP_COLOR,RiskColor());

   ObjectSetString(0,g_prefix+"BAL",OBJPROP_TEXT,"BALANCE: "+DoubleToString(g_balance,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"EQ",OBJPROP_TEXT,"EQUITY: "+DoubleToString(g_equity,2)+" "+g_currency);

   ObjectSetString(0,g_prefix+"FLOAT",OBJPROP_TEXT,"FLOATING P/L: "+DoubleToString(g_floating,2)+" "+g_currency);
   ObjectSetInteger(0,g_prefix+"FLOAT",OBJPROP_COLOR,ValueColor(g_floating));
   ObjectSetString(0,g_prefix+"POS",OBJPROP_TEXT,"OPEN POSITIONS: "+IntegerToString(g_positions));

   ObjectSetString(0,g_prefix+"CDD",OBJPROP_TEXT,"MONEY: "+DoubleToString(g_current_dd_money,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"CDDP",OBJPROP_TEXT,"PERCENT: "+DoubleToString(g_current_dd_pct,2)+"%");

   ObjectSetString(0,g_prefix+"DDD",OBJPROP_TEXT,"MONEY: "+DoubleToString(g_daily_dd_money,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"DDDP",OBJPROP_TEXT,"PERCENT: "+DoubleToString(g_daily_dd_pct,2)+"%");
   ObjectSetString(0,g_prefix+"DPNL",OBJPROP_TEXT,"DAILY P/L: "+DoubleToString(g_daily_pnl,2)+" "+g_currency);
   ObjectSetInteger(0,g_prefix+"DPNL",OBJPROP_COLOR,ValueColor(g_daily_pnl));

   ObjectSetString(0,g_prefix+"PEAK",OBJPROP_TEXT,"PEAK EQUITY: "+DoubleToString(g_peak_equity,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"PDD",OBJPROP_TEXT,"DRAWDOWN: "+DoubleToString(g_peak_dd_money,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"PDDP",OBJPROP_TEXT,"DRAWDOWN %: "+DoubleToString(g_peak_dd_pct,2)+"%");

   ObjectSetString(0,g_prefix+"MARGIN",OBJPROP_TEXT,"MARGIN: "+DoubleToString(g_margin,2));
   ObjectSetString(0,g_prefix+"FREE",OBJPROP_TEXT,"FREE MARGIN: "+DoubleToString(g_free_margin,2));
   ObjectSetString(0,g_prefix+"LEVEL",OBJPROP_TEXT,"MARGIN LEVEL: "+DoubleToString(g_margin_level,2)+"%");

   ChartRedraw();
}

int OnInit()
{
   if(InpWarningDDPercent<0.0 ||
      InpDangerDDPercent<=InpWarningDDPercent ||
      InpTimerSeconds<1)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,"Quantora Drawdown Monitor MT5 v1.00");

   ResetDailyReference();

   g_peak_equity=AccountInfoDouble(ACCOUNT_EQUITY);
   if(g_peak_equity<=0.0)
      g_peak_equity=AccountInfoDouble(ACCOUNT_BALANCE);

   BuildPanel();
   UpdateData();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora Drawdown Monitor: EventSetTimer error ",GetLastError());
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
// More Professional Trading Robots
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
