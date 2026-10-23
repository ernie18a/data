//+------------------------------------------------------------------+
//|                          Quantora Trade Statistics Dashboard MT5 |
//|           Professional Trading Utility for MetaTrader 5          |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Professional trade statistics dashboard for MetaTrader 5."
#property description "Analyzes trading history and displays performance, streak, direction and lot statistics."

enum ENUM_Q_STATS_PERIOD
  {
   Q_STATS_TODAY=0,
   Q_STATS_WEEK=1,
   Q_STATS_MONTH=2,
   Q_STATS_ALL=3
  };

input group "========== STATISTICS SETTINGS =========="
input ENUM_Q_STATS_PERIOD InpPeriodMode       = Q_STATS_ALL;
input bool                InpAllSymbols       = true;
input string              InpCustomSymbol     = "";
input bool                InpUseMagicFilter   = false;
input long                InpMagicNumber      = 0;

input group "========== DASHBOARD =========="
input bool                InpShowPanel        = true;
input ENUM_BASE_CORNER    InpPanelCorner      = CORNER_LEFT_UPPER;
input int                 InpPanelX           = 15;
input int                 InpPanelY           = 145;
input int                 InpTimerSeconds     = 2;

#define Q_BG       C'8,23,38'
#define Q_GOLD     C'212,175,55'
#define Q_WHITE    C'245,245,245'
#define Q_GRAY     C'169,176,184'
#define Q_GREEN    C'0,200,83'
#define Q_YELLOW   C'255,193,7'
#define Q_ORANGE   C'255,152,0'
#define Q_RED      C'255,82,82'
#define Q_BLUE     C'32,93,145'
#define Q_BORDER   C'62,76,89'

string g_prefix="QTSD5_";
string g_currency="";
string g_period_text="ALL HISTORY";
string g_scope="ALL SYMBOLS";
string g_status="INITIALIZING";

int g_total=0,g_wins=0,g_losses=0,g_be=0;
int g_buy_trades=0,g_sell_trades=0,g_buy_wins=0,g_sell_wins=0;
int g_current_win_streak=0,g_current_loss_streak=0,g_best_win_streak=0,g_worst_loss_streak=0;

double g_win_rate=0.0,g_loss_rate=0.0,g_profit_factor=0.0,g_rr=0.0;
double g_gross_profit=0.0,g_gross_loss=0.0,g_net_profit=0.0;
double g_avg_win=0.0,g_avg_loss=0.0,g_largest_win=0.0,g_largest_loss=0.0;
double g_buy_win_rate=0.0,g_sell_win_rate=0.0;
double g_total_lots=0.0,g_avg_lot=0.0;
double g_floating=0.0;
int g_open_positions=0;

datetime DayStart(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t,dt);
   dt.hour=0; dt.min=0; dt.sec=0;
   return StructToTime(dt);
}

datetime WeekStart(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t,dt);
   datetime d0=DayStart(t);
   int dow=dt.day_of_week; // 0=Sunday
   int days_since_monday=(dow==0 ? 6 : dow-1);
   return d0-days_since_monday*86400;
}

datetime MonthStart(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t,dt);
   dt.day=1; dt.hour=0; dt.min=0; dt.sec=0;
   return StructToTime(dt);
}

void ResolveRange(datetime &from_time,datetime &to_time)
{
   datetime now=TimeCurrent();
   to_time=now;

   if(InpPeriodMode==Q_STATS_TODAY)
   {
      from_time=DayStart(now);
      g_period_text="TODAY";
   }
   else if(InpPeriodMode==Q_STATS_WEEK)
   {
      from_time=WeekStart(now);
      g_period_text="THIS WEEK";
   }
   else if(InpPeriodMode==Q_STATS_MONTH)
   {
      from_time=MonthStart(now);
      g_period_text="THIS MONTH";
   }
   else
   {
      from_time=0;
      g_period_text="ALL HISTORY";
   }
}

string SelectedSymbol()
{
   if(InpAllSymbols) return "";
   if(StringLen(InpCustomSymbol)>0) return InpCustomSymbol;
   return _Symbol;
}

bool DealMatches(ulong ticket)
{
   ENUM_DEAL_ENTRY entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
   if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_OUT_BY)
      return false;

   ENUM_DEAL_TYPE type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);
   if(type!=DEAL_TYPE_BUY && type!=DEAL_TYPE_SELL)
      return false;

   if(!InpAllSymbols && HistoryDealGetString(ticket,DEAL_SYMBOL)!=SelectedSymbol())
      return false;

   if(InpUseMagicFilter && (long)HistoryDealGetInteger(ticket,DEAL_MAGIC)!=InpMagicNumber)
      return false;

   return true;
}

double DealNet(ulong ticket)
{
   return HistoryDealGetDouble(ticket,DEAL_PROFIT)
        + HistoryDealGetDouble(ticket,DEAL_SWAP)
        + HistoryDealGetDouble(ticket,DEAL_COMMISSION)
        + HistoryDealGetDouble(ticket,DEAL_FEE);
}

void ResetStats()
{
   g_total=g_wins=g_losses=g_be=0;
   g_buy_trades=g_sell_trades=g_buy_wins=g_sell_wins=0;
   g_current_win_streak=g_current_loss_streak=0;
   g_best_win_streak=g_worst_loss_streak=0;

   g_win_rate=g_loss_rate=g_profit_factor=g_rr=0.0;
   g_gross_profit=g_gross_loss=g_net_profit=0.0;
   g_avg_win=g_avg_loss=g_largest_win=g_largest_loss=0.0;
   g_buy_win_rate=g_sell_win_rate=0.0;
   g_total_lots=g_avg_lot=0.0;
}

void UpdateOpenStats()
{
   g_open_positions=0;
   g_floating=0.0;

   for(int i=0;i<PositionsTotal();i++)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket)) continue;

      if(!InpAllSymbols && PositionGetString(POSITION_SYMBOL)!=SelectedSymbol())
         continue;

      if(InpUseMagicFilter && (long)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber)
         continue;

      g_open_positions++;
      g_floating+=PositionGetDouble(POSITION_PROFIT);
      g_floating+=PositionGetDouble(POSITION_SWAP);
   }
}

void CalculateStatistics()
{
   ResetStats();

   datetime from_time,to_time;
   ResolveRange(from_time,to_time);

   if(!HistorySelect(from_time,to_time))
   {
      g_status="HISTORY SELECT FAILED";
      return;
   }

   int total=HistoryDealsTotal();
   double win_sum=0.0,loss_sum=0.0;
   int running_win=0,running_loss=0;

   for(int i=0;i<total;i++)
   {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0 || !DealMatches(ticket))
         continue;

      double result=DealNet(ticket);
      double volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);
      ENUM_DEAL_TYPE type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);

      g_total++;
      g_total_lots+=volume;
      g_net_profit+=result;

      if(type==DEAL_TYPE_BUY) g_buy_trades++;
      if(type==DEAL_TYPE_SELL) g_sell_trades++;

      if(result>0.0)
      {
         g_wins++;
         g_gross_profit+=result;
         win_sum+=result;

         if(type==DEAL_TYPE_BUY) g_buy_wins++;
         if(type==DEAL_TYPE_SELL) g_sell_wins++;

         if(g_wins==1 || result>g_largest_win) g_largest_win=result;

         running_win++;
         running_loss=0;
         if(running_win>g_best_win_streak) g_best_win_streak=running_win;
      }
      else if(result<0.0)
      {
         g_losses++;
         g_gross_loss+=result;
         loss_sum+=result;

         if(g_losses==1 || result<g_largest_loss) g_largest_loss=result;

         running_loss++;
         running_win=0;
         if(running_loss>g_worst_loss_streak) g_worst_loss_streak=running_loss;
      }
      else
      {
         g_be++;
         running_win=0;
         running_loss=0;
      }
   }

   g_current_win_streak=running_win;
   g_current_loss_streak=running_loss;

   g_win_rate=(g_total>0 ? 100.0*g_wins/g_total : 0.0);
   g_loss_rate=(g_total>0 ? 100.0*g_losses/g_total : 0.0);

   g_avg_win=(g_wins>0 ? win_sum/g_wins : 0.0);
   g_avg_loss=(g_losses>0 ? loss_sum/g_losses : 0.0);

   if(g_gross_loss<0.0)
      g_profit_factor=g_gross_profit/MathAbs(g_gross_loss);
   else if(g_gross_profit>0.0)
      g_profit_factor=999.0;
   else
      g_profit_factor=0.0;

   g_rr=(g_avg_loss<0.0 ? g_avg_win/MathAbs(g_avg_loss) : 0.0);

   g_buy_win_rate=(g_buy_trades>0 ? 100.0*g_buy_wins/g_buy_trades : 0.0);
   g_sell_win_rate=(g_sell_trades>0 ? 100.0*g_sell_wins/g_sell_trades : 0.0);

   g_avg_lot=(g_total>0 ? g_total_lots/g_total : 0.0);

   g_scope=(InpAllSymbols ? "ALL SYMBOLS" : SelectedSymbol());
   g_currency=AccountInfoString(ACCOUNT_CURRENCY);

   UpdateOpenStats();

   g_status="ANALYZING";
}

color ProfitColor(double v)
{
   if(v>0.0) return Q_GREEN;
   if(v<0.0) return Q_RED;
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

bool Label(string n,string t,int x,int y,int s,color c,bool b=false)
{
   if(!ObjectCreate(0,n,OBJ_LABEL,0,0,0)) return false;
   ObjectSetInteger(0,n,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_COLOR,c);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,s);
   ObjectSetString(0,n,OBJPROP_FONT,b?"Arial Bold":"Arial");
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
      if(StringFind(n,g_prefix)==0) ObjectDelete(0,n);
   }
}

void BuildPanel()
{
   if(!InpShowPanel) return;
   DeletePanel();

   int x=InpPanelX,y=InpPanelY;
   Rect(g_prefix+"BG",x,y,620,640,Q_BG,Q_GOLD);

   Label(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   Label(g_prefix+"SUB","TRADE STATISTICS DASHBOARD",x+18,y+38,11,Q_WHITE,true);
   Label(g_prefix+"VER","MT5 v1.00",x+530,y+18,9,Q_GRAY);

   Label(g_prefix+"PERIOD","PERIOD: ALL HISTORY",x+18,y+76,10,Q_WHITE);
   Label(g_prefix+"SCOPE","SCOPE: ALL SYMBOLS",x+330,y+76,10,Q_WHITE);

   Label(g_prefix+"TOTAL","TOTAL TRADES: 0",x+18,y+118,10,Q_GOLD,true);
   Label(g_prefix+"WINS","WINS: 0",x+170,y+118,10,Q_GREEN,true);
   Label(g_prefix+"LOSSES","LOSSES: 0",x+300,y+118,10,Q_RED,true);
   Label(g_prefix+"BE","BE: 0",x+450,y+118,10,Q_GRAY);

   Label(g_prefix+"WR","WIN RATE: 0.0%",x+18,y+154,11,Q_GREEN,true);
   Label(g_prefix+"LR","LOSS RATE: 0.0%",x+210,y+154,10,Q_RED,true);
   Label(g_prefix+"PF","PROFIT FACTOR: 0.00",x+390,y+154,10,Q_GOLD,true);

   Label(g_prefix+"RR","REWARD/RISK: 0.00",x+18,y+190,10,Q_WHITE);

   Rect(g_prefix+"SEP1",x+18,y+220,584,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"GP","GROSS PROFIT: 0.00",x+18,y+242,10,Q_GREEN,true);
   Label(g_prefix+"GL","GROSS LOSS: 0.00",x+320,y+242,10,Q_RED,true);
   Label(g_prefix+"NET","NET PROFIT: 0.00",x+18,y+278,12,Q_GOLD,true);

   Label(g_prefix+"AW","AVG WIN: 0.00",x+18,y+318,10,Q_WHITE);
   Label(g_prefix+"AL","AVG LOSS: 0.00",x+320,y+318,10,Q_WHITE);
   Label(g_prefix+"LW","LARGEST WIN: 0.00",x+18,y+354,10,Q_GREEN);
   Label(g_prefix+"LL","LARGEST LOSS: 0.00",x+320,y+354,10,Q_RED);

   Rect(g_prefix+"SEP2",x+18,y+390,584,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"CWS","CURRENT WIN STREAK: 0",x+18,y+412,10,Q_GREEN);
   Label(g_prefix+"CLS","CURRENT LOSS STREAK: 0",x+320,y+412,10,Q_RED);
   Label(g_prefix+"BWS","BEST WIN STREAK: 0",x+18,y+448,10,Q_WHITE);
   Label(g_prefix+"WLS","WORST LOSS STREAK: 0",x+320,y+448,10,Q_WHITE);

   Rect(g_prefix+"SEP3",x+18,y+484,584,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"BUY","BUY TRADES: 0",x+18,y+506,10,Q_BLUE,true);
   Label(g_prefix+"BUYWR","BUY WIN RATE: 0.0%",x+180,y+506,10,Q_WHITE);
   Label(g_prefix+"SELL","SELL TRADES: 0",x+370,y+506,10,Q_ORANGE,true);
   Label(g_prefix+"SELLWR","SELL WIN RATE: 0.0%",x+18,y+542,10,Q_WHITE);

   Label(g_prefix+"LOTS","TOTAL LOTS: 0.00",x+250,y+542,10,Q_GRAY);
   Label(g_prefix+"AVGLOT","AVG LOT: 0.00",x+450,y+542,10,Q_GRAY);

   Label(g_prefix+"OPEN","OPEN POSITIONS: 0",x+18,y+578,10,Q_WHITE);
   Label(g_prefix+"FLOAT","FLOATING P/L: 0.00",x+250,y+578,10,Q_WHITE);

   Label(g_prefix+"STATUS","STATUS: ANALYZING",x+18,y+612,9,Q_GREEN);
   Label(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",x+350,y+612,9,Q_GOLD);

   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel) return;

   ObjectSetString(0,g_prefix+"PERIOD",OBJPROP_TEXT,"PERIOD: "+g_period_text);
   ObjectSetString(0,g_prefix+"SCOPE",OBJPROP_TEXT,"SCOPE: "+g_scope);

   ObjectSetString(0,g_prefix+"TOTAL",OBJPROP_TEXT,"TOTAL TRADES: "+IntegerToString(g_total));
   ObjectSetString(0,g_prefix+"WINS",OBJPROP_TEXT,"WINS: "+IntegerToString(g_wins));
   ObjectSetString(0,g_prefix+"LOSSES",OBJPROP_TEXT,"LOSSES: "+IntegerToString(g_losses));
   ObjectSetString(0,g_prefix+"BE",OBJPROP_TEXT,"BE: "+IntegerToString(g_be));

   ObjectSetString(0,g_prefix+"WR",OBJPROP_TEXT,"WIN RATE: "+DoubleToString(g_win_rate,1)+"%");
   ObjectSetString(0,g_prefix+"LR",OBJPROP_TEXT,"LOSS RATE: "+DoubleToString(g_loss_rate,1)+"%");

   string pf=(g_profit_factor>=999.0 ? "INF" : DoubleToString(g_profit_factor,2));
   ObjectSetString(0,g_prefix+"PF",OBJPROP_TEXT,"PROFIT FACTOR: "+pf);
   ObjectSetString(0,g_prefix+"RR",OBJPROP_TEXT,"REWARD/RISK: "+DoubleToString(g_rr,2));

   ObjectSetString(0,g_prefix+"GP",OBJPROP_TEXT,"GROSS PROFIT: "+DoubleToString(g_gross_profit,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"GL",OBJPROP_TEXT,"GROSS LOSS: "+DoubleToString(g_gross_loss,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"NET",OBJPROP_TEXT,"NET PROFIT: "+DoubleToString(g_net_profit,2)+" "+g_currency);
   ObjectSetInteger(0,g_prefix+"NET",OBJPROP_COLOR,ProfitColor(g_net_profit));

   ObjectSetString(0,g_prefix+"AW",OBJPROP_TEXT,"AVG WIN: "+DoubleToString(g_avg_win,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"AL",OBJPROP_TEXT,"AVG LOSS: "+DoubleToString(g_avg_loss,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"LW",OBJPROP_TEXT,"LARGEST WIN: "+DoubleToString(g_largest_win,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"LL",OBJPROP_TEXT,"LARGEST LOSS: "+DoubleToString(g_largest_loss,2)+" "+g_currency);

   ObjectSetString(0,g_prefix+"CWS",OBJPROP_TEXT,"CURRENT WIN STREAK: "+IntegerToString(g_current_win_streak));
   ObjectSetString(0,g_prefix+"CLS",OBJPROP_TEXT,"CURRENT LOSS STREAK: "+IntegerToString(g_current_loss_streak));
   ObjectSetString(0,g_prefix+"BWS",OBJPROP_TEXT,"BEST WIN STREAK: "+IntegerToString(g_best_win_streak));
   ObjectSetString(0,g_prefix+"WLS",OBJPROP_TEXT,"WORST LOSS STREAK: "+IntegerToString(g_worst_loss_streak));

   ObjectSetString(0,g_prefix+"BUY",OBJPROP_TEXT,"BUY TRADES: "+IntegerToString(g_buy_trades));
   ObjectSetString(0,g_prefix+"BUYWR",OBJPROP_TEXT,"BUY WIN RATE: "+DoubleToString(g_buy_win_rate,1)+"%");
   ObjectSetString(0,g_prefix+"SELL",OBJPROP_TEXT,"SELL TRADES: "+IntegerToString(g_sell_trades));
   ObjectSetString(0,g_prefix+"SELLWR",OBJPROP_TEXT,"SELL WIN RATE: "+DoubleToString(g_sell_win_rate,1)+"%");

   ObjectSetString(0,g_prefix+"LOTS",OBJPROP_TEXT,"TOTAL LOTS: "+DoubleToString(g_total_lots,2));
   ObjectSetString(0,g_prefix+"AVGLOT",OBJPROP_TEXT,"AVG LOT: "+DoubleToString(g_avg_lot,2));

   ObjectSetString(0,g_prefix+"OPEN",OBJPROP_TEXT,"OPEN POSITIONS: "+IntegerToString(g_open_positions));
   ObjectSetString(0,g_prefix+"FLOAT",OBJPROP_TEXT,"FLOATING P/L: "+DoubleToString(g_floating,2)+" "+g_currency);
   ObjectSetInteger(0,g_prefix+"FLOAT",OBJPROP_COLOR,ProfitColor(g_floating));

   ObjectSetString(0,g_prefix+"STATUS",OBJPROP_TEXT,"STATUS: "+g_status);

   ChartRedraw();
}

int OnInit()
{
   if(InpTimerSeconds<1)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Quantora Trade Statistics Dashboard MT5 v1.00");

   BuildPanel();
   CalculateStatistics();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora Trade Statistics Dashboard: EventSetTimer error ",GetLastError());
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
   CalculateStatistics();
   UpdatePanel();
}

//===========================================================
// Developed by Quantora
// More Professional Trading Robots
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
