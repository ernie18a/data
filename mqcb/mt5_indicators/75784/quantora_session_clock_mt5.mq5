//+------------------------------------------------------------------+
//|                                       Quantora Session Clock MT5 |
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
#property description "Professional trading session clock for MetaTrader 5."
#property description "Displays Sydney, Tokyo, London and New York sessions with countdowns, overlaps and alerts."

input group "========== TIME SETTINGS =========="
input int InpUTCOffsetHours=0;
input int InpTimerSeconds=1;

input group "========== SESSION HOURS (UTC) =========="
input int InpSydneyOpenHour=21;
input int InpSydneyCloseHour=6;
input int InpTokyoOpenHour=0;
input int InpTokyoCloseHour=9;
input int InpLondonOpenHour=7;
input int InpLondonCloseHour=16;
input int InpNewYorkOpenHour=12;
input int InpNewYorkCloseHour=21;

input group "========== ALERT SETTINGS =========="
input bool InpEnableAlerts=true;
input bool InpAlertSessionOpen=true;
input bool InpAlertSessionClose=true;
input bool InpPopupAlert=true;
input bool InpSoundAlert=false;
input string InpSoundFile="alert.wav";
input bool InpPushNotification=false;

input group "========== DASHBOARD =========="
input bool InpShowPanel=true;
input ENUM_BASE_CORNER InpPanelCorner=CORNER_LEFT_UPPER;
input int InpPanelX=15;
input int InpPanelY=145;

#define Q_BG C'8,23,38'
#define Q_GOLD C'212,175,55'
#define Q_WHITE C'245,245,245'
#define Q_GRAY C'169,176,184'
#define Q_GREEN C'0,200,83'
#define Q_RED C'255,82,82'
#define Q_BLUE C'32,93,145'
#define Q_BORDER C'62,76,89'
#define Q_DARK2 C'5,14,24'

string g_prefix="QSC5_";
bool g_alert_enabled=true;
int g_alert_count=0;

struct SessionState
{
   string name;
   int open_hour;
   int close_hour;
   bool is_open;
   bool previous_open;
   int seconds_to_event;
   double progress_pct;
};
SessionState g_sessions[4];

bool IsTesterEnvironment(){ return (bool)MQLInfoInteger(MQL_TESTER); }

datetime GetUTCNow()
{
   datetime t=TimeGMT();
   return (t>0 ? t : TimeCurrent());
}

string FormatClock(datetime value)
{
   MqlDateTime dt; TimeToStruct(value,dt);
   return StringFormat("%02d:%02d:%02d",dt.hour,dt.min,dt.sec);
}

string FormatDuration(int s)
{
   s=MathMax(0,s);
   return StringFormat("%02d:%02d:%02d",s/3600,(s%3600)/60,s%60);
}

int SecOfDay(datetime t)
{
   MqlDateTime dt; TimeToStruct(t,dt);
   return dt.hour*3600+dt.min*60+dt.sec;
}

int NormalizeHour(int h){ h%=24; if(h<0) h+=24; return h; }

bool IsOpen(int open_hour,int close_hour,int nowsec)
{
   int o=NormalizeHour(open_hour)*3600;
   int c=NormalizeHour(close_hour)*3600;
   if(o==c) return true;
   if(o<c) return (nowsec>=o && nowsec<c);
   return (nowsec>=o || nowsec<c);
}

int UntilOpen(int open_hour,int nowsec)
{
   int o=NormalizeHour(open_hour)*3600;
   int d=o-nowsec; if(d<=0) d+=86400; return d;
}

int UntilClose(int close_hour,int nowsec)
{
   int c=NormalizeHour(close_hour)*3600;
   int d=c-nowsec; if(d<=0) d+=86400; return d;
}

double Progress(int open_hour,int close_hour,int nowsec)
{
   int o=NormalizeHour(open_hour)*3600;
   int c=NormalizeHour(close_hour)*3600;
   int len=(o==c ? 86400 : (o<c ? c-o : 86400-o+c));
   int elapsed=(o<c ? nowsec-o : (nowsec>=o ? nowsec-o : 86400-o+nowsec));
   return MathMax(0.0,MathMin(100.0,100.0*elapsed/len));
}

void SendSessionAlert(string msg)
{
   if(!InpEnableAlerts || !g_alert_enabled) return;
   g_alert_count++;
   if(IsTesterEnvironment()) return;
   string full="Quantora Session Clock: "+msg;
   if(InpPopupAlert) Alert(full);
   if(InpSoundAlert && StringLen(InpSoundFile)>0) PlaySound(InpSoundFile);
   if(InpPushNotification) SendNotification(full);
}

void InitSessions()
{
   g_sessions[0].name="SYDNEY";   g_sessions[0].open_hour=InpSydneyOpenHour;   g_sessions[0].close_hour=InpSydneyCloseHour;
   g_sessions[1].name="TOKYO";    g_sessions[1].open_hour=InpTokyoOpenHour;    g_sessions[1].close_hour=InpTokyoCloseHour;
   g_sessions[2].name="LONDON";   g_sessions[2].open_hour=InpLondonOpenHour;   g_sessions[2].close_hour=InpLondonCloseHour;
   g_sessions[3].name="NEW YORK"; g_sessions[3].open_hour=InpNewYorkOpenHour; g_sessions[3].close_hour=InpNewYorkCloseHour;
   for(int i=0;i<4;i++){ g_sessions[i].is_open=false; g_sessions[i].previous_open=false; g_sessions[i].seconds_to_event=0; g_sessions[i].progress_pct=0.0; }
}

void UpdateSessions()
{
   int nowsec=SecOfDay(GetUTCNow());
   for(int i=0;i<4;i++)
   {
      bool open_now=IsOpen(g_sessions[i].open_hour,g_sessions[i].close_hour,nowsec);
      g_sessions[i].seconds_to_event = open_now ? UntilClose(g_sessions[i].close_hour,nowsec) : UntilOpen(g_sessions[i].open_hour,nowsec);
      g_sessions[i].progress_pct = open_now ? Progress(g_sessions[i].open_hour,g_sessions[i].close_hour,nowsec) : 0.0;

      if(g_sessions[i].previous_open!=open_now)
      {
         if(!g_sessions[i].previous_open && open_now && InpAlertSessionOpen) SendSessionAlert(g_sessions[i].name+" session opened");
         if(g_sessions[i].previous_open && !open_now && InpAlertSessionClose) SendSessionAlert(g_sessions[i].name+" session closed");
      }
      g_sessions[i].is_open=open_now;
      g_sessions[i].previous_open=open_now;
   }
}

int ActiveCount()
{
   int c=0; for(int i=0;i<4;i++) if(g_sessions[i].is_open) c++; return c;
}

string OverlapText()
{
   string s="";
   for(int i=0;i<4;i++) if(g_sessions[i].is_open){ if(StringLen(s)>0) s+=" / "; s+=g_sessions[i].name; }
   return (StringLen(s)>0 ? s : "NONE");
}

bool CreateRect(string name,int x,int y,int w,int h,color bg,color border)
{
   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0)) return false;
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w); ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg); ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   return true;
}

bool CreateLabel(string name,string text,int x,int y,int size,color clr,bool bold=false)
{
   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0)) return false;
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr); ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,name,OBJPROP_FONT,bold?"Arial Bold":"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   return true;
}

bool CreateButton(string name,string text,int x,int y,int w,int h,color bg)
{
   if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0)) return false;
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w); ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg); ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,Q_GOLD);
   ObjectSetInteger(0,name,OBJPROP_COLOR,Q_WHITE); ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial Bold"); ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
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
   CreateRect(g_prefix+"BG",x,y,560,500,Q_BG,Q_GOLD);
   CreateLabel(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   CreateLabel(g_prefix+"SUB","SESSION CLOCK",x+18,y+38,11,Q_WHITE,true);
   CreateLabel(g_prefix+"VER","MT5 v1.00",x+470,y+18,9,Q_GRAY);
   CreateLabel(g_prefix+"SERVER","SERVER TIME: --",x+18,y+76,10,Q_WHITE);
   CreateLabel(g_prefix+"UTC","UTC TIME: --",x+290,y+76,10,Q_WHITE);
   int rows[4]={128,188,248,308};
   for(int i=0;i<4;i++)
   {
      string k=IntegerToString(i);
      CreateLabel(g_prefix+"NAME_"+k,g_sessions[i].name,x+18,y+rows[i],10,Q_WHITE,true);
      CreateLabel(g_prefix+"STATE_"+k,"CLOSED",x+150,y+rows[i],10,Q_RED,true);
      CreateLabel(g_prefix+"NEXT_"+k,"OPENS IN 00:00:00",x+280,y+rows[i],10,Q_GRAY);
      CreateRect(g_prefix+"PBG_"+k,x+18,y+rows[i]+24,520,10,Q_DARK2,Q_BORDER);
      CreateRect(g_prefix+"PBF_"+k,x+20,y+rows[i]+26,1,6,Q_GREEN,Q_GREEN);
   }
   CreateLabel(g_prefix+"ACTIVE","ACTIVE SESSIONS: 0",x+18,y+376,10,Q_WHITE,true);
   CreateLabel(g_prefix+"OVERLAP","OVERLAP: NONE",x+280,y+376,10,Q_GOLD,true);
   CreateLabel(g_prefix+"OFFSET","DISPLAY UTC OFFSET: "+IntegerToString(InpUTCOffsetHours),x+18,y+406,10,Q_GRAY);
   CreateLabel(g_prefix+"ALERTCOUNT","ALERTS: 0",x+280,y+406,10,Q_GRAY);
   CreateButton(g_prefix+"ALERT","DISABLE ALERTS",x+18,y+434,245,34,Q_RED);
   CreateButton(g_prefix+"RESET","RESET STATUS",x+295,y+434,245,34,Q_BLUE);
   CreateLabel(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",x+18,y+480,9,Q_GOLD);
   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel) return;

   ObjectSetString(0,g_prefix+"SERVER",OBJPROP_TEXT,"SERVER TIME: "+FormatClock(TimeCurrent()));
   ObjectSetString(0,g_prefix+"UTC",OBJPROP_TEXT,"UTC TIME: "+FormatClock(GetUTCNow()+InpUTCOffsetHours*3600));

   for(int i=0;i<4;i++)
   {
      string k=IntegerToString(i);
      bool op=g_sessions[i].is_open;
      ObjectSetString(0,g_prefix+"STATE_"+k,OBJPROP_TEXT,op?"OPEN":"CLOSED");
      ObjectSetInteger(0,g_prefix+"STATE_"+k,OBJPROP_COLOR,op?Q_GREEN:Q_RED);
      ObjectSetString(0,g_prefix+"NEXT_"+k,OBJPROP_TEXT,(op?"CLOSES IN ":"OPENS IN ")+FormatDuration(g_sessions[i].seconds_to_event));
      int fill=(int)MathRound(516.0*g_sessions[i].progress_pct/100.0);
      fill=MathMax(1,MathMin(516,fill));
      ObjectSetInteger(0,g_prefix+"PBF_"+k,OBJPROP_XSIZE,op?fill:1);
      ObjectSetInteger(0,g_prefix+"PBF_"+k,OBJPROP_BGCOLOR,op?Q_GREEN:Q_BORDER);
      ObjectSetInteger(0,g_prefix+"PBF_"+k,OBJPROP_BORDER_COLOR,op?Q_GREEN:Q_BORDER);
   }

   ObjectSetString(0,g_prefix+"ACTIVE",OBJPROP_TEXT,"ACTIVE SESSIONS: "+IntegerToString(ActiveCount()));
   ObjectSetString(0,g_prefix+"OVERLAP",OBJPROP_TEXT,"OVERLAP: "+OverlapText());
   ObjectSetString(0,g_prefix+"ALERTCOUNT",OBJPROP_TEXT,"ALERTS: "+IntegerToString(g_alert_count));
   ObjectSetString(0,g_prefix+"ALERT",OBJPROP_TEXT,g_alert_enabled?"DISABLE ALERTS":"ENABLE ALERTS");
   ObjectSetInteger(0,g_prefix+"ALERT",OBJPROP_BGCOLOR,g_alert_enabled?Q_RED:Q_GREEN);
   ChartRedraw();
}

int OnInit()
{
   if(InpTimerSeconds<1) return INIT_PARAMETERS_INCORRECT;
   int h[8]={InpSydneyOpenHour,InpSydneyCloseHour,InpTokyoOpenHour,InpTokyoCloseHour,InpLondonOpenHour,InpLondonCloseHour,InpNewYorkOpenHour,InpNewYorkCloseHour};
   for(int i=0;i<8;i++) if(h[i]<0 || h[i]>23) return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,"Quantora Session Clock MT5 v1.00");
   g_alert_enabled=InpEnableAlerts;
   InitSessions(); UpdateSessions(); BuildPanel(); UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora Session Clock MT5: EventSetTimer failed. Error ",GetLastError());
      return INIT_FAILED;
   }
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   DeletePanel();
}

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],const double &close[],
                const long &tick_volume[],const long &volume[],const int &spread[])
{
   return rates_total;
}

void OnTimer()
{
   UpdateSessions();
   UpdatePanel();
}

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(id!=CHARTEVENT_OBJECT_CLICK) return;

   if(sparam==g_prefix+"ALERT")
   {
      g_alert_enabled=!g_alert_enabled;
      UpdatePanel();
   }
   else if(sparam==g_prefix+"RESET")
   {
      g_alert_count=0;
      InitSessions();
      UpdateSessions();
      UpdatePanel();
   }
}

//===========================================================
// Developed by Quantora
//
// More Professional Trading Robots
//
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
