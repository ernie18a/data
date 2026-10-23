//+------------------------------------------------------------------+
//|                               Quantora Trading Journal Panel MT5 |
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
#property description "Professional trading journal and daily performance panel for MetaTrader 5."
#property description "Analyzes closed deals and displays win rate, P/L statistics and account status."

enum ENUM_Q_DATE_MODE
  {
   Q_TODAY       = 0,
   Q_CUSTOM_DATE = 1
  };

enum ENUM_Q_DIRECTION_FILTER
  {
   Q_ALL_DIRECTIONS = 0,
   Q_BUY_ONLY       = 1,
   Q_SELL_ONLY      = 2
  };

//============================== INPUTS =====================================
input group "========== JOURNAL SETTINGS =========="
input ENUM_Q_DATE_MODE         InpDateMode             = Q_TODAY;
input datetime                 InpCustomDate           = D'2026.01.01 00:00';
input bool                     InpAllSymbols           = true;
input string                   InpCustomSymbol         = "";
input bool                     InpUseMagicFilter       = false;
input long                     InpMagicNumber          = 0;
input ENUM_Q_DIRECTION_FILTER  InpDirectionFilter      = Q_ALL_DIRECTIONS;

input group "========== DASHBOARD =========="
input bool                     InpShowPanel            = true;
input ENUM_BASE_CORNER         InpPanelCorner          = CORNER_LEFT_UPPER;
input int                      InpPanelX               = 15;
input int                      InpPanelY               = 145;
input int                      InpTimerSeconds         = 2;

//============================== BRAND COLORS ===============================
#define Q_BG       C'8,23,38'
#define Q_GOLD     C'212,175,55'
#define Q_WHITE    C'245,245,245'
#define Q_GRAY     C'169,176,184'
#define Q_GREEN    C'0,200,83'
#define Q_YELLOW   C'255,193,7'
#define Q_RED      C'255,82,82'
#define Q_BORDER   C'62,76,89'

//============================== STATE ======================================
string g_prefix="QTJP5_";
string g_status="INITIALIZING";
string g_scope_text="ALL SYMBOLS";
string g_date_text="TODAY";

int    g_trades=0;
int    g_wins=0;
int    g_losses=0;
int    g_breakeven=0;

double g_win_rate=0.0;
double g_gross_profit=0.0;
double g_gross_loss=0.0;
double g_net_profit=0.0;
double g_avg_win=0.0;
double g_avg_loss=0.0;
double g_largest_win=0.0;
double g_largest_loss=0.0;
double g_profit_factor=0.0;

double g_balance=0.0;
double g_equity=0.0;
double g_floating=0.0;

//============================== HELPERS ====================================
datetime DayStart(datetime source)
  {
   MqlDateTime dt;
   TimeToStruct(source,dt);
   dt.hour=0;
   dt.min=0;
   dt.sec=0;
   return StructToTime(dt);
  }

void ResolveDateRange(datetime &from_time,datetime &to_time)
  {
   datetime base=(InpDateMode==Q_TODAY ? TimeCurrent() : InpCustomDate);
   from_time=DayStart(base);
   to_time=from_time+86400-1;

   if(InpDateMode==Q_TODAY)
      g_date_text="TODAY";
   else
      g_date_text=TimeToString(from_time,TIME_DATE);
  }

string SelectedSymbol()
  {
   if(InpAllSymbols)
      return "";

   if(StringLen(InpCustomSymbol)>0)
      return InpCustomSymbol;

   return _Symbol;
  }

bool DirectionMatches(ENUM_DEAL_TYPE type)
  {
   if(InpDirectionFilter==Q_ALL_DIRECTIONS)
      return (type==DEAL_TYPE_BUY || type==DEAL_TYPE_SELL);

   if(InpDirectionFilter==Q_BUY_ONLY)
      return (type==DEAL_TYPE_BUY);

   if(InpDirectionFilter==Q_SELL_ONLY)
      return (type==DEAL_TYPE_SELL);

   return false;
  }

bool DealMatchesFilters(ulong ticket)
  {
   ENUM_DEAL_ENTRY entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
   if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_OUT_BY)
      return false;

   ENUM_DEAL_TYPE type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);
   if(!DirectionMatches(type))
      return false;

   if(!InpAllSymbols)
     {
      string symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
      string wanted=SelectedSymbol();
      if(symbol!=wanted)
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

double DealNetResult(ulong ticket)
  {
   double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
   double swap=HistoryDealGetDouble(ticket,DEAL_SWAP);
   double commission=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
   double fee=HistoryDealGetDouble(ticket,DEAL_FEE);

   return profit+swap+commission+fee;
  }

void ResetStatistics()
  {
   g_trades=0;
   g_wins=0;
   g_losses=0;
   g_breakeven=0;

   g_win_rate=0.0;
   g_gross_profit=0.0;
   g_gross_loss=0.0;
   g_net_profit=0.0;
   g_avg_win=0.0;
   g_avg_loss=0.0;
   g_largest_win=0.0;
   g_largest_loss=0.0;
   g_profit_factor=0.0;
  }

bool CalculateJournal()
  {
   ResetStatistics();

   datetime from_time,to_time;
   ResolveDateRange(from_time,to_time);

   if(!HistorySelect(from_time,to_time))
     {
      g_status="HISTORY SELECT FAILED";
      return false;
     }

   int total=HistoryDealsTotal();

   double win_sum=0.0;
   double loss_sum=0.0;

   for(int i=0;i<total;i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
         continue;

      if(!DealMatchesFilters(ticket))
         continue;

      double result=DealNetResult(ticket);

      g_trades++;
      g_net_profit+=result;

      if(result>0.0)
        {
         g_wins++;
         g_gross_profit+=result;
         win_sum+=result;

         if(g_wins==1 || result>g_largest_win)
            g_largest_win=result;
        }
      else if(result<0.0)
        {
         g_losses++;
         g_gross_loss+=result;
         loss_sum+=result;

         if(g_losses==1 || result<g_largest_loss)
            g_largest_loss=result;
        }
      else
        {
         g_breakeven++;
        }
     }

   g_win_rate=(g_trades>0 ? 100.0*(double)g_wins/(double)g_trades : 0.0);
   g_avg_win=(g_wins>0 ? win_sum/g_wins : 0.0);
   g_avg_loss=(g_losses>0 ? loss_sum/g_losses : 0.0);
   g_profit_factor=(g_gross_loss<0.0 ? g_gross_profit/MathAbs(g_gross_loss) :
                    (g_gross_profit>0.0 ? 999.0 : 0.0));

   g_balance=AccountInfoDouble(ACCOUNT_BALANCE);
   g_equity=AccountInfoDouble(ACCOUNT_EQUITY);
   g_floating=AccountInfoDouble(ACCOUNT_PROFIT);

   g_scope_text=(InpAllSymbols ? "ALL SYMBOLS" : SelectedSymbol());

   g_status="UPDATED";
   return true;
  }

color ProfitColor(double value)
  {
   if(value>0.0) return Q_GREEN;
   if(value<0.0) return Q_RED;
   return Q_GRAY;
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

   CreateRectangle(g_prefix+"BG",x,y,560,570,Q_BG,Q_GOLD);

   CreateLabel(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   CreateLabel(g_prefix+"SUB","TRADING JOURNAL PANEL",x+18,y+38,11,Q_WHITE,true);
   CreateLabel(g_prefix+"VER","MT5 v1.00",x+470,y+18,9,Q_GRAY);

   CreateLabel(g_prefix+"STATUS","STATUS: INITIALIZING",x+18,y+74,10,Q_GREEN,true);

   CreateLabel(g_prefix+"DATE","DATE: TODAY",x+18,y+108,10,Q_WHITE);
   CreateLabel(g_prefix+"SCOPE","SCOPE: ALL SYMBOLS",x+300,y+108,10,Q_WHITE);

   CreateLabel(g_prefix+"TRADES","TRADES: 0",x+18,y+150,11,Q_GOLD,true);
   CreateLabel(g_prefix+"WINS","WINS: 0",x+150,y+150,11,Q_GREEN,true);
   CreateLabel(g_prefix+"LOSSES","LOSSES: 0",x+280,y+150,11,Q_RED,true);
   CreateLabel(g_prefix+"BE","BREAKEVEN: 0",x+410,y+150,10,Q_GRAY);

   CreateLabel(g_prefix+"WINRATE","WIN RATE: 0.0 %",x+18,y+190,12,Q_GOLD,true);
   CreateLabel(g_prefix+"PF","PROFIT FACTOR: 0.00",x+300,y+190,11,Q_WHITE,true);

   CreateRectangle(g_prefix+"SEP1",x+18,y+226,524,2,Q_BORDER,Q_BORDER);

   CreateLabel(g_prefix+"GPROFIT","GROSS PROFIT: 0.00",x+18,y+248,10,Q_GREEN,true);
   CreateLabel(g_prefix+"GLOSS","GROSS LOSS: 0.00",x+300,y+248,10,Q_RED,true);

   CreateLabel(g_prefix+"NET","NET PROFIT: 0.00",x+18,y+286,13,Q_GOLD,true);

   CreateLabel(g_prefix+"AVGW","AVG WIN: 0.00",x+18,y+326,10,Q_WHITE);
   CreateLabel(g_prefix+"AVGL","AVG LOSS: 0.00",x+300,y+326,10,Q_WHITE);

   CreateLabel(g_prefix+"BIGW","LARGEST WIN: 0.00",x+18,y+362,10,Q_GREEN);
   CreateLabel(g_prefix+"BIGL","LARGEST LOSS: 0.00",x+300,y+362,10,Q_RED);

   CreateRectangle(g_prefix+"SEP2",x+18,y+400,524,2,Q_BORDER,Q_BORDER);

   CreateLabel(g_prefix+"BAL","BALANCE: 0.00",x+18,y+424,10,Q_WHITE);
   CreateLabel(g_prefix+"EQ","EQUITY: 0.00",x+300,y+424,10,Q_WHITE);

   CreateLabel(g_prefix+"FLOAT","FLOATING P/L: 0.00",x+18,y+462,11,Q_GRAY,true);
   CreateLabel(g_prefix+"MAGIC","MAGIC FILTER: OFF",x+300,y+462,10,Q_GRAY);

   CreateLabel(g_prefix+"DIR","DIRECTION: ALL",x+18,y+500,10,Q_GRAY);

   CreateLabel(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",x+18,y+544,9,Q_GOLD);

   ChartRedraw();
  }

string DirectionFilterText()
  {
   if(InpDirectionFilter==Q_BUY_ONLY) return "BUY";
   if(InpDirectionFilter==Q_SELL_ONLY) return "SELL";
   return "ALL";
  }

void UpdatePanel()
  {
   if(!InpShowPanel)
      return;

   string cur=AccountInfoString(ACCOUNT_CURRENCY);

   ObjectSetString(0,g_prefix+"STATUS",OBJPROP_TEXT,"STATUS: "+g_status);
   ObjectSetInteger(0,g_prefix+"STATUS",OBJPROP_COLOR,
                    g_status=="UPDATED" ? Q_GREEN : Q_YELLOW);

   ObjectSetString(0,g_prefix+"DATE",OBJPROP_TEXT,"DATE: "+g_date_text);
   ObjectSetString(0,g_prefix+"SCOPE",OBJPROP_TEXT,"SCOPE: "+g_scope_text);

   ObjectSetString(0,g_prefix+"TRADES",OBJPROP_TEXT,"TRADES: "+IntegerToString(g_trades));
   ObjectSetString(0,g_prefix+"WINS",OBJPROP_TEXT,"WINS: "+IntegerToString(g_wins));
   ObjectSetString(0,g_prefix+"LOSSES",OBJPROP_TEXT,"LOSSES: "+IntegerToString(g_losses));
   ObjectSetString(0,g_prefix+"BE",OBJPROP_TEXT,"BREAKEVEN: "+IntegerToString(g_breakeven));

   ObjectSetString(0,g_prefix+"WINRATE",OBJPROP_TEXT,
                   "WIN RATE: "+DoubleToString(g_win_rate,1)+" %");

   string pf_text=(g_profit_factor>=999.0 ? "INF" : DoubleToString(g_profit_factor,2));
   ObjectSetString(0,g_prefix+"PF",OBJPROP_TEXT,"PROFIT FACTOR: "+pf_text);

   ObjectSetString(0,g_prefix+"GPROFIT",OBJPROP_TEXT,
                   "GROSS PROFIT: "+DoubleToString(g_gross_profit,2)+" "+cur);
   ObjectSetString(0,g_prefix+"GLOSS",OBJPROP_TEXT,
                   "GROSS LOSS: "+DoubleToString(g_gross_loss,2)+" "+cur);

   ObjectSetString(0,g_prefix+"NET",OBJPROP_TEXT,
                   "NET PROFIT: "+DoubleToString(g_net_profit,2)+" "+cur);
   ObjectSetInteger(0,g_prefix+"NET",OBJPROP_COLOR,ProfitColor(g_net_profit));

   ObjectSetString(0,g_prefix+"AVGW",OBJPROP_TEXT,
                   "AVG WIN: "+DoubleToString(g_avg_win,2)+" "+cur);
   ObjectSetString(0,g_prefix+"AVGL",OBJPROP_TEXT,
                   "AVG LOSS: "+DoubleToString(g_avg_loss,2)+" "+cur);

   ObjectSetString(0,g_prefix+"BIGW",OBJPROP_TEXT,
                   "LARGEST WIN: "+DoubleToString(g_largest_win,2)+" "+cur);
   ObjectSetString(0,g_prefix+"BIGL",OBJPROP_TEXT,
                   "LARGEST LOSS: "+DoubleToString(g_largest_loss,2)+" "+cur);

   ObjectSetString(0,g_prefix+"BAL",OBJPROP_TEXT,
                   "BALANCE: "+DoubleToString(g_balance,2)+" "+cur);
   ObjectSetString(0,g_prefix+"EQ",OBJPROP_TEXT,
                   "EQUITY: "+DoubleToString(g_equity,2)+" "+cur);

   ObjectSetString(0,g_prefix+"FLOAT",OBJPROP_TEXT,
                   "FLOATING P/L: "+DoubleToString(g_floating,2)+" "+cur);
   ObjectSetInteger(0,g_prefix+"FLOAT",OBJPROP_COLOR,ProfitColor(g_floating));

   ObjectSetString(0,g_prefix+"MAGIC",OBJPROP_TEXT,
                   InpUseMagicFilter ?
                   "MAGIC FILTER: "+IntegerToString((int)InpMagicNumber) :
                   "MAGIC FILTER: OFF");

   ObjectSetString(0,g_prefix+"DIR",OBJPROP_TEXT,
                   "DIRECTION: "+DirectionFilterText());

   ChartRedraw();
  }

//============================== INDICATOR EVENTS ===========================
int OnInit()
  {
   if(InpTimerSeconds<1)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Quantora Trading Journal Panel MT5 v1.00");

   BuildPanel();
   CalculateJournal();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
     {
      Print("Quantora Trading Journal Panel MT5: EventSetTimer failed. Error ",
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
   CalculateJournal();
   UpdatePanel();
  }

//===========================================================
// Developed by Quantora
//
// More Professional Trading Robots
//
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
