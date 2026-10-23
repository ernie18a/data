//+------------------------------------------------------------------+
//|               Quantora Trading Session Monitor MT5               |
//|           Professional Trading Utility for MetaTrader 5          |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Professional trading session monitor for MetaTrader 5."
#property description "Displays active sessions, overlaps, next session, spread, ATR and market activity."

input group "========== SESSION HOURS (UTC) =========="
input int InpSydneyOpenHour   = 21;
input int InpSydneyCloseHour  = 6;
input int InpTokyoOpenHour    = 0;
input int InpTokyoCloseHour   = 9;
input int InpLondonOpenHour   = 7;
input int InpLondonCloseHour  = 16;
input int InpNewYorkOpenHour  = 12;
input int InpNewYorkCloseHour = 21;

input group "========== ACTIVITY SETTINGS =========="
input int    InpATRPeriod          = 14;
input int    InpATRLookback        = 20;
input double InpLowActivityRatio   = 0.80;
input double InpHighActivityRatio  = 1.20;

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
#define Q_DARK    C'5,14,24'

string g_prefix="QTSM5_";
string g_activity="UNKNOWN";
string g_overlap="NONE";
string g_active_text="NONE";
string g_next_session="--";
string g_status="INITIALIZING";

double g_spread_points=0.0;
double g_atr_current=0.0;
double g_atr_average=0.0;
double g_activity_ratio=0.0;
double g_today_range=0.0;

int g_active_count=0;
int g_seconds_remaining=0;
int g_seconds_to_next=0;

int g_atr_handle=INVALID_HANDLE;

struct SessionState
{
   string name;
   int open_hour;
   int close_hour;
   bool active;
   int seconds_to_event;
};

SessionState g_sessions[4];

int NormalizeHour(int h)
{
   h%=24;
   if(h<0) h+=24;
   return h;
}

datetime UTCNow()
{
   datetime t=TimeGMT();
   if(t<=0) t=TimeCurrent();
   return t;
}

int SecondsOfDay(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t,dt);
   return dt.hour*3600+dt.min*60+dt.sec;
}

bool IsOpen(int open_hour,int close_hour,int nowsec)
{
   int o=NormalizeHour(open_hour)*3600;
   int c=NormalizeHour(close_hour)*3600;

   if(o==c) return true;
   if(o<c) return (nowsec>=o && nowsec<c);
   return (nowsec>=o || nowsec<c);
}

int SecondsUntilOpen(int open_hour,int nowsec)
{
   int o=NormalizeHour(open_hour)*3600;
   int d=o-nowsec;
   if(d<=0) d+=86400;
   return d;
}

int SecondsUntilClose(int close_hour,int nowsec)
{
   int c=NormalizeHour(close_hour)*3600;
   int d=c-nowsec;
   if(d<=0) d+=86400;
   return d;
}

string FormatDuration(int sec)
{
   sec=MathMax(0,sec);
   int h=sec/3600;
   int m=(sec%3600)/60;
   int s=sec%60;
   return StringFormat("%02d:%02d:%02d",h,m,s);
}

string FormatClock(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t,dt);
   return StringFormat("%02d:%02d:%02d",dt.hour,dt.min,dt.sec);
}

color ActivityColor()
{
   if(g_activity=="LOW") return Q_YELLOW;
   if(g_activity=="NORMAL") return Q_GREEN;
   if(g_activity=="HIGH") return Q_ORANGE;
   return Q_GRAY;
}

void InitSessions()
{
   g_sessions[0].name="SYDNEY";
   g_sessions[0].open_hour=InpSydneyOpenHour;
   g_sessions[0].close_hour=InpSydneyCloseHour;

   g_sessions[1].name="TOKYO";
   g_sessions[1].open_hour=InpTokyoOpenHour;
   g_sessions[1].close_hour=InpTokyoCloseHour;

   g_sessions[2].name="LONDON";
   g_sessions[2].open_hour=InpLondonOpenHour;
   g_sessions[2].close_hour=InpLondonCloseHour;

   g_sessions[3].name="NEW YORK";
   g_sessions[3].open_hour=InpNewYorkOpenHour;
   g_sessions[3].close_hour=InpNewYorkCloseHour;
}

void UpdateSessions()
{
   int nowsec=SecondsOfDay(UTCNow());

   g_active_count=0;
   g_active_text="";
   g_overlap="NONE";
   g_seconds_remaining=0;

   int best_next=86401;
   string next_name="--";

   for(int i=0;i<4;i++)
   {
      g_sessions[i].active=IsOpen(g_sessions[i].open_hour,g_sessions[i].close_hour,nowsec);

      if(g_sessions[i].active)
      {
         g_sessions[i].seconds_to_event=SecondsUntilClose(g_sessions[i].close_hour,nowsec);

         if(g_active_count==0 || g_sessions[i].seconds_to_event<g_seconds_remaining)
            g_seconds_remaining=g_sessions[i].seconds_to_event;

         if(StringLen(g_active_text)>0) g_active_text+=" / ";
         g_active_text+=g_sessions[i].name;
         g_active_count++;
      }
      else
      {
         g_sessions[i].seconds_to_event=SecondsUntilOpen(g_sessions[i].open_hour,nowsec);

         if(g_sessions[i].seconds_to_event<best_next)
         {
            best_next=g_sessions[i].seconds_to_event;
            next_name=g_sessions[i].name;
         }
      }
   }

   if(g_active_count==0)
      g_active_text="NONE";

   if(g_active_count>=2)
      g_overlap=g_active_text;

   g_next_session=next_name;
   g_seconds_to_next=(best_next<=86400 ? best_next : 0);
}

void UpdateMarketData()
{
   MqlTick tick;
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);

   if(point>0.0 && SymbolInfoTick(_Symbol,tick))
      g_spread_points=(tick.ask-tick.bid)/point;
   else
      g_spread_points=0.0;

   MqlRates day[1];
   ArraySetAsSeries(day,true);

   if(CopyRates(_Symbol,PERIOD_D1,0,1,day)==1)
      g_today_range=MathMax(0.0,day[0].high-day[0].low);
   else
      g_today_range=0.0;
}

void UpdateActivity()
{
   if(g_atr_handle==INVALID_HANDLE)
   {
      g_activity="UNKNOWN";
      return;
   }

   int need=MathMax(InpATRLookback+1,3);
   double atr[];
   ArraySetAsSeries(atr,true);

   int copied=CopyBuffer(g_atr_handle,0,0,need,atr);
   if(copied<3)
   {
      g_activity="WAITING";
      return;
   }

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
   g_activity_ratio=(g_atr_average>0.0 ? g_atr_current/g_atr_average : 1.0);

   if(g_activity_ratio<InpLowActivityRatio)
      g_activity="LOW";
   else if(g_activity_ratio>InpHighActivityRatio)
      g_activity="HIGH";
   else
      g_activity="NORMAL";
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

bool Label(string n,string t,int x,int y,int size,color clr,bool bold=false)
{
   if(!ObjectCreate(0,n,OBJ_LABEL,0,0,0))
      return false;

   ObjectSetInteger(0,n,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,size);
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

   Rect(g_prefix+"BG",x,y,590,600,Q_BG,Q_GOLD);

   Label(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   Label(g_prefix+"SUB","TRADING SESSION MONITOR",x+18,y+38,11,Q_WHITE,true);
   Label(g_prefix+"VER","MT5 v1.00",x+500,y+18,9,Q_GRAY);

   Label(g_prefix+"STATUS","STATUS: INITIALIZING",x+18,y+76,10,Q_GREEN,true);

   Label(g_prefix+"UTC","UTC TIME: --",x+18,y+110,10,Q_WHITE);
   Label(g_prefix+"SERVER","SERVER TIME: --",x+310,y+110,10,Q_WHITE);

   Label(g_prefix+"SYMBOL","SYMBOL: "+_Symbol,x+18,y+144,10,Q_GRAY);
   Label(g_prefix+"SPREAD","SPREAD: 0.0 pts",x+310,y+144,10,Q_GRAY);

   Rect(g_prefix+"SEP1",x+18,y+178,554,2,Q_BORDER,Q_BORDER);

   int rows[4]={202,242,282,322};

   for(int i=0;i<4;i++)
   {
      string k=IntegerToString(i);

      Label(g_prefix+"NAME_"+k,g_sessions[i].name,x+18,y+rows[i],10,Q_WHITE,true);
      Label(g_prefix+"STATE_"+k,"CLOSED",x+180,y+rows[i],10,Q_RED,true);
      Label(g_prefix+"COUNT_"+k,"--",x+330,y+rows[i],10,Q_GRAY);
   }

   Rect(g_prefix+"SEP2",x+18,y+362,554,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"ACTIVE","ACTIVE SESSIONS: NONE",x+18,y+386,10,Q_GREEN,true);
   Label(g_prefix+"OVERLAP","OVERLAP: NONE",x+18,y+420,10,Q_GOLD,true);

   Label(g_prefix+"REMAIN","ACTIVE SESSION REMAINING: --",x+18,y+454,10,Q_WHITE);
   Label(g_prefix+"NEXT","NEXT SESSION: --",x+310,y+454,10,Q_WHITE);
   Label(g_prefix+"NEXTIN","STARTS IN: --",x+310,y+484,10,Q_GRAY);

   Rect(g_prefix+"SEP3",x+18,y+518,554,2,Q_BORDER,Q_BORDER);

   Label(g_prefix+"ACTIVITY","MARKET ACTIVITY: UNKNOWN",x+18,y+540,11,Q_GOLD,true);
   Label(g_prefix+"ATR","ATR: 0.00000",x+310,y+540,10,Q_WHITE);
   Label(g_prefix+"RANGE","TODAY RANGE: 0.00000",x+18,y+570,10,Q_GRAY);

   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel) return;

   datetime utc=UTCNow();
   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

   ObjectSetString(0,g_prefix+"STATUS",OBJPROP_TEXT,"STATUS: MONITORING");
   ObjectSetString(0,g_prefix+"UTC",OBJPROP_TEXT,"UTC TIME: "+FormatClock(utc));
   ObjectSetString(0,g_prefix+"SERVER",OBJPROP_TEXT,"SERVER TIME: "+FormatClock(TimeCurrent()));
   ObjectSetString(0,g_prefix+"SYMBOL",OBJPROP_TEXT,"SYMBOL: "+_Symbol);
   ObjectSetString(0,g_prefix+"SPREAD",OBJPROP_TEXT,"SPREAD: "+DoubleToString(g_spread_points,1)+" pts");

   for(int i=0;i<4;i++)
   {
      string k=IntegerToString(i);

      ObjectSetString(0,g_prefix+"STATE_"+k,OBJPROP_TEXT,
                      g_sessions[i].active ? "ACTIVE" : "CLOSED");
      ObjectSetInteger(0,g_prefix+"STATE_"+k,OBJPROP_COLOR,
                       g_sessions[i].active ? Q_GREEN : Q_RED);

      string count_text=(g_sessions[i].active ? "CLOSES IN " : "OPENS IN ");
      count_text+=FormatDuration(g_sessions[i].seconds_to_event);

      ObjectSetString(0,g_prefix+"COUNT_"+k,OBJPROP_TEXT,count_text);
   }

   ObjectSetString(0,g_prefix+"ACTIVE",OBJPROP_TEXT,
                   "ACTIVE SESSIONS: "+g_active_text);
   ObjectSetString(0,g_prefix+"OVERLAP",OBJPROP_TEXT,
                   "OVERLAP: "+g_overlap);

   ObjectSetString(0,g_prefix+"REMAIN",OBJPROP_TEXT,
                   "ACTIVE SESSION REMAINING: "+
                   (g_active_count>0 ? FormatDuration(g_seconds_remaining) : "--"));

   ObjectSetString(0,g_prefix+"NEXT",OBJPROP_TEXT,
                   "NEXT SESSION: "+g_next_session);
   ObjectSetString(0,g_prefix+"NEXTIN",OBJPROP_TEXT,
                   "STARTS IN: "+(g_seconds_to_next>0 ? FormatDuration(g_seconds_to_next) : "--"));

   ObjectSetString(0,g_prefix+"ACTIVITY",OBJPROP_TEXT,
                   "MARKET ACTIVITY: "+g_activity);
   ObjectSetInteger(0,g_prefix+"ACTIVITY",OBJPROP_COLOR,ActivityColor());

   ObjectSetString(0,g_prefix+"ATR",OBJPROP_TEXT,
                   "ATR: "+DoubleToString(g_atr_current,digits));
   ObjectSetString(0,g_prefix+"RANGE",OBJPROP_TEXT,
                   "TODAY RANGE: "+DoubleToString(g_today_range,digits));

   ChartRedraw();
}

int OnInit()
{
   if(InpTimerSeconds<1 ||
      InpATRPeriod<2 ||
      InpATRLookback<2 ||
      InpLowActivityRatio<=0.0 ||
      InpHighActivityRatio<InpLowActivityRatio)
      return INIT_PARAMETERS_INCORRECT;

   int hours[8]={
      InpSydneyOpenHour,InpSydneyCloseHour,
      InpTokyoOpenHour,InpTokyoCloseHour,
      InpLondonOpenHour,InpLondonCloseHour,
      InpNewYorkOpenHour,InpNewYorkCloseHour
   };

   for(int i=0;i<8;i++)
      if(hours[i]<0 || hours[i]>23)
         return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "Quantora Trading Session Monitor MT5 v1.00");

   InitSessions();

   g_atr_handle=iATR(_Symbol,(ENUM_TIMEFRAMES)_Period,InpATRPeriod);

   if(g_atr_handle==INVALID_HANDLE)
   {
      Print("Quantora Trading Session Monitor: ATR handle error ",GetLastError());
      return INIT_FAILED;
   }

   UpdateSessions();
   UpdateMarketData();
   UpdateActivity();

   BuildPanel();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora Trading Session Monitor: EventSetTimer error ",GetLastError());
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
   UpdateSessions();
   UpdateMarketData();
   UpdateActivity();
   UpdatePanel();
}

//===========================================================
// Developed by Quantora
// More Professional Trading Robots
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
