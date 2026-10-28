//+------------------------------------------------------------------+
//|                           Quantora Daily Profit Loss Monitor MT5 |
//|           Professional Trading Utility for MetaTrader 5          |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Professional daily profit and loss monitor for MetaTrader 5."
#property description "Tracks daily closed P/L, floating P/L, trade statistics and daily targets."

input group "========== DAILY TARGETS =========="
input double InpDailyProfitTarget = 500.0;
input double InpDailyLossLimit    = 300.0;

input group "========== FILTERS =========="
input bool   InpAllSymbols        = true;
input string InpCustomSymbol      = "";
input bool   InpUseMagicFilter    = false;
input long   InpMagicNumber       = 0;

input group "========== DASHBOARD =========="
input bool             InpShowPanel    = true;
input ENUM_BASE_CORNER InpPanelCorner  = CORNER_LEFT_UPPER;
input int              InpPanelX       = 15;
input int              InpPanelY       = 145;
input int              InpTimerSeconds = 2;

#define Q_BG       C'8,23,38'
#define Q_GOLD     C'212,175,55'
#define Q_WHITE    C'245,245,245'
#define Q_GRAY     C'169,176,184'
#define Q_GREEN    C'0,200,83'
#define Q_YELLOW   C'255,193,7'
#define Q_RED      C'255,82,82'
#define Q_BORDER   C'62,76,89'
#define Q_DARK     C'5,14,24'

string g_prefix="QDPL5_";
string g_currency="";
string g_status="MONITORING";
string g_scope="ALL SYMBOLS";

double g_start_balance=0.0;
double g_balance=0.0;
double g_equity=0.0;
double g_closed_profit=0.0;
double g_closed_loss=0.0;
double g_net_closed=0.0;
double g_floating=0.0;
double g_total_daily=0.0;
double g_daily_pct=0.0;
double g_profit_progress=0.0;
double g_loss_progress=0.0;

int g_trades=0;
int g_wins=0;
int g_losses=0;
int g_breakeven=0;
double g_win_rate=0.0;

datetime DayStart(datetime value)
{
   MqlDateTime dt;
   TimeToStruct(value,dt);
   dt.hour=0;
   dt.min=0;
   dt.sec=0;
   return StructToTime(dt);
}

string SelectedSymbol()
{
   if(InpAllSymbols)
      return "";
   if(StringLen(InpCustomSymbol)>0)
      return InpCustomSymbol;
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

   if(!InpAllSymbols)
   {
      if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=SelectedSymbol())
         return false;
   }

   if(InpUseMagicFilter)
   {
      long magic=(long)HistoryDealGetInteger(ticket,DEAL_MAGIC);
      if(magic!=InpMagicNumber)
         return false;
   }

   return true;
}

double DealNet(ulong ticket)
{
   return HistoryDealGetDouble(ticket,DEAL_PROFIT)
        + HistoryDealGetDouble(ticket,DEAL_SWAP)
        + HistoryDealGetDouble(ticket,DEAL_COMMISSION)
        + HistoryDealGetDouble(ticket,DEAL_FEE);
}

double FilteredFloating()
{
   double result=0.0;

   for(int i=0;i<PositionsTotal();i++)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket))
         continue;

      if(!InpAllSymbols && PositionGetString(POSITION_SYMBOL)!=SelectedSymbol())
         continue;

      if(InpUseMagicFilter &&
         (long)PositionGetInteger(POSITION_MAGIC)!=InpMagicNumber)
         continue;

      result+=PositionGetDouble(POSITION_PROFIT);
      result+=PositionGetDouble(POSITION_SWAP);
   }

   return result;
}

void CalculateData()
{
   g_currency=AccountInfoString(ACCOUNT_CURRENCY);
   g_balance=AccountInfoDouble(ACCOUNT_BALANCE);
   g_equity=AccountInfoDouble(ACCOUNT_EQUITY);
   g_scope=(InpAllSymbols ? "ALL SYMBOLS" : SelectedSymbol());

   g_closed_profit=0.0;
   g_closed_loss=0.0;
   g_net_closed=0.0;
   g_trades=0;
   g_wins=0;
   g_losses=0;
   g_breakeven=0;

   datetime now=TimeCurrent();
   datetime from=DayStart(now);

   if(HistorySelect(from,now))
   {
      int total=HistoryDealsTotal();

      for(int i=0;i<total;i++)
      {
         ulong ticket=HistoryDealGetTicket(i);
         if(ticket==0 || !DealMatches(ticket))
            continue;

         double result=DealNet(ticket);

         g_trades++;
         g_net_closed+=result;

         if(result>0.0)
         {
            g_wins++;
            g_closed_profit+=result;
         }
         else if(result<0.0)
         {
            g_losses++;
            g_closed_loss+=result;
         }
         else
            g_breakeven++;
      }
   }

   g_start_balance=g_balance-g_net_closed;
   g_floating=FilteredFloating();
   g_total_daily=g_net_closed+g_floating;

   g_daily_pct=(g_start_balance>0.0 ?
                100.0*g_total_daily/g_start_balance : 0.0);

   g_win_rate=(g_trades>0 ?
               100.0*(double)g_wins/(double)g_trades : 0.0);

   g_profit_progress=(InpDailyProfitTarget>0.0 ?
                      100.0*MathMax(0.0,g_total_daily)/InpDailyProfitTarget : 0.0);

   g_loss_progress=(InpDailyLossLimit>0.0 ?
                    100.0*MathMax(0.0,-g_total_daily)/InpDailyLossLimit : 0.0);

   if(InpDailyProfitTarget>0.0 && g_total_daily>=InpDailyProfitTarget)
      g_status="TARGET REACHED";
   else if(InpDailyLossLimit>0.0 && g_total_daily<=-InpDailyLossLimit)
      g_status="LOSS LIMIT REACHED";
   else if(g_total_daily>0.0)
      g_status="PROFITABLE";
   else if(g_total_daily<0.0)
      g_status="NEGATIVE";
   else
      g_status="FLAT";
}

color ValueColor(double v)
{
   if(v>0.0) return Q_GREEN;
   if(v<0.0) return Q_RED;
   return Q_GRAY;
}

color StatusColor()
{
   if(g_status=="TARGET REACHED" || g_status=="PROFITABLE")
      return Q_GREEN;
   if(g_status=="LOSS LIMIT REACHED" || g_status=="NEGATIVE")
      return Q_RED;
   return Q_YELLOW;
}

bool Rect(string name,int x,int y,int w,int h,color bg,color border)
{
   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
      return false;
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   return true;
}

bool Label(string name,string text,int x,int y,int size,color clr,bool bold=false)
{
   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
      return false;
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,name,OBJPROP_FONT,bold ? "Arial Bold" : "Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
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

   Rect(g_prefix+"BG",x,y,580,590,Q_BG,Q_GOLD);

   Label(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   Label(g_prefix+"SUB","DAILY P/L MONITOR",x+18,y+39,11,Q_WHITE,true);
   Label(g_prefix+"VER","MT5 v1.00",x+490,y+18,9,Q_GRAY);

   Label(g_prefix+"STATUS","STATUS: MONITORING",x+18,y+76,11,Q_GREEN,true);
   Label(g_prefix+"TIME","SERVER: --",x+340,y+76,9,Q_GRAY);

   Label(g_prefix+"SCOPE","SCOPE: ALL SYMBOLS",x+18,y+112,10,Q_WHITE);
   Label(g_prefix+"MAGIC","MAGIC: OFF",x+340,y+112,10,Q_WHITE);

   Rect(g_prefix+"SEP1",x+18,y+146,544,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"START","START BALANCE: 0.00",x+18,y+168,10,Q_WHITE);
   Label(g_prefix+"BAL","BALANCE: 0.00",x+310,y+168,10,Q_WHITE);
   Label(g_prefix+"EQ","EQUITY: 0.00",x+18,y+204,10,Q_WHITE);
   Label(g_prefix+"FLOAT","FLOATING P/L: 0.00",x+310,y+204,10,Q_GRAY);

   Rect(g_prefix+"SEP2",x+18,y+240,544,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"CP","CLOSED PROFIT: 0.00",x+18,y+262,10,Q_GREEN);
   Label(g_prefix+"CL","CLOSED LOSS: 0.00",x+310,y+262,10,Q_RED);
   Label(g_prefix+"NET","NET CLOSED P/L: 0.00",x+18,y+298,11,Q_GOLD,true);
   Label(g_prefix+"TOTAL","TOTAL DAILY P/L: 0.00",x+310,y+298,11,Q_GOLD,true);
   Label(g_prefix+"PCT","DAILY RETURN: 0.00 %",x+18,y+334,10,Q_WHITE);

   Label(g_prefix+"TRADES","TRADES: 0",x+18,y+378,10,Q_GOLD,true);
   Label(g_prefix+"WINS","WINS: 0",x+150,y+378,10,Q_GREEN,true);
   Label(g_prefix+"LOSSES","LOSSES: 0",x+270,y+378,10,Q_RED,true);
   Label(g_prefix+"WR","WIN RATE: 0.0 %",x+400,y+378,10,Q_WHITE,true);

   Rect(g_prefix+"SEP3",x+18,y+414,544,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"PT","PROFIT TARGET: 0.00",x+18,y+436,10,Q_WHITE);
   Label(g_prefix+"PP","PROGRESS: 0.0 %",x+370,y+436,10,Q_GREEN,true);
   Rect(g_prefix+"PBG",x+18,y+466,544,18,Q_DARK,Q_BORDER);
   Rect(g_prefix+"PFILL",x+20,y+468,1,14,Q_GREEN,Q_GREEN);

   Label(g_prefix+"LL","LOSS LIMIT: 0.00",x+18,y+500,10,Q_WHITE);
   Label(g_prefix+"LP","USED: 0.0 %",x+370,y+500,10,Q_RED,true);
   Rect(g_prefix+"LBG",x+18,y+530,544,18,Q_DARK,Q_BORDER);
   Rect(g_prefix+"LFILL",x+20,y+532,1,14,Q_RED,Q_RED);

   Label(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",x+18,y+566,9,Q_GOLD);

   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel) return;

   color sc=StatusColor();

   ObjectSetString(0,g_prefix+"STATUS",OBJPROP_TEXT,"STATUS: "+g_status);
   ObjectSetInteger(0,g_prefix+"STATUS",OBJPROP_COLOR,sc);

   ObjectSetString(0,g_prefix+"TIME",OBJPROP_TEXT,
                   "SERVER: "+TimeToString(TimeCurrent(),TIME_SECONDS));

   ObjectSetString(0,g_prefix+"SCOPE",OBJPROP_TEXT,"SCOPE: "+g_scope);
   ObjectSetString(0,g_prefix+"MAGIC",OBJPROP_TEXT,
                   InpUseMagicFilter ?
                   "MAGIC: "+IntegerToString((int)InpMagicNumber) :
                   "MAGIC: OFF");

   ObjectSetString(0,g_prefix+"START",OBJPROP_TEXT,
                   "START BALANCE: "+DoubleToString(g_start_balance,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"BAL",OBJPROP_TEXT,
                   "BALANCE: "+DoubleToString(g_balance,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"EQ",OBJPROP_TEXT,
                   "EQUITY: "+DoubleToString(g_equity,2)+" "+g_currency);

   ObjectSetString(0,g_prefix+"FLOAT",OBJPROP_TEXT,
                   "FLOATING P/L: "+DoubleToString(g_floating,2)+" "+g_currency);
   ObjectSetInteger(0,g_prefix+"FLOAT",OBJPROP_COLOR,ValueColor(g_floating));

   ObjectSetString(0,g_prefix+"CP",OBJPROP_TEXT,
                   "CLOSED PROFIT: "+DoubleToString(g_closed_profit,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"CL",OBJPROP_TEXT,
                   "CLOSED LOSS: "+DoubleToString(g_closed_loss,2)+" "+g_currency);

   ObjectSetString(0,g_prefix+"NET",OBJPROP_TEXT,
                   "NET CLOSED P/L: "+DoubleToString(g_net_closed,2)+" "+g_currency);
   ObjectSetInteger(0,g_prefix+"NET",OBJPROP_COLOR,ValueColor(g_net_closed));

   ObjectSetString(0,g_prefix+"TOTAL",OBJPROP_TEXT,
                   "TOTAL DAILY P/L: "+DoubleToString(g_total_daily,2)+" "+g_currency);
   ObjectSetInteger(0,g_prefix+"TOTAL",OBJPROP_COLOR,ValueColor(g_total_daily));

   ObjectSetString(0,g_prefix+"PCT",OBJPROP_TEXT,
                   "DAILY RETURN: "+DoubleToString(g_daily_pct,2)+" %");
   ObjectSetInteger(0,g_prefix+"PCT",OBJPROP_COLOR,ValueColor(g_daily_pct));

   ObjectSetString(0,g_prefix+"TRADES",OBJPROP_TEXT,"TRADES: "+IntegerToString(g_trades));
   ObjectSetString(0,g_prefix+"WINS",OBJPROP_TEXT,"WINS: "+IntegerToString(g_wins));
   ObjectSetString(0,g_prefix+"LOSSES",OBJPROP_TEXT,"LOSSES: "+IntegerToString(g_losses));
   ObjectSetString(0,g_prefix+"WR",OBJPROP_TEXT,
                   "WIN RATE: "+DoubleToString(g_win_rate,1)+" %");

   ObjectSetString(0,g_prefix+"PT",OBJPROP_TEXT,
                   "PROFIT TARGET: "+DoubleToString(InpDailyProfitTarget,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"PP",OBJPROP_TEXT,
                   "PROGRESS: "+DoubleToString(g_profit_progress,1)+" %");

   ObjectSetString(0,g_prefix+"LL",OBJPROP_TEXT,
                   "LOSS LIMIT: "+DoubleToString(InpDailyLossLimit,2)+" "+g_currency);
   ObjectSetString(0,g_prefix+"LP",OBJPROP_TEXT,
                   "USED: "+DoubleToString(g_loss_progress,1)+" %");

   int profit_fill=(int)MathRound(540.0*MathMin(g_profit_progress,100.0)/100.0);
   int loss_fill=(int)MathRound(540.0*MathMin(g_loss_progress,100.0)/100.0);

   profit_fill=MathMax(1,MathMin(540,profit_fill));
   loss_fill=MathMax(1,MathMin(540,loss_fill));

   ObjectSetInteger(0,g_prefix+"PFILL",OBJPROP_XSIZE,profit_fill);
   ObjectSetInteger(0,g_prefix+"LFILL",OBJPROP_XSIZE,loss_fill);

   ChartRedraw();
}

int OnInit()
{
   if(InpTimerSeconds<1 || InpDailyProfitTarget<0.0 || InpDailyLossLimit<0.0)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Quantora Daily Profit Loss Monitor MT5 v1.00");

   BuildPanel();
   CalculateData();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora Daily P/L Monitor: EventSetTimer failed. Error ",GetLastError());
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
   CalculateData();
   UpdatePanel();
}

//===========================================================
// Developed by Quantora
//
// More Professional Trading Robots
//
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
