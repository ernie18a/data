//+------------------------------------------------------------------+
//|                                       Quantora Trading Clock MT5 |
//|           Professional Trading Utility for MetaTrader 5          |
//|                                                                  |
//| Copyright © 2026 Quantora                                        |
//| https://www.mql5.com/en/users/quantora/seller                    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.01"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Professional multi-market trading clock for MetaTrader 5."
#property description "Displays server, local, UTC and major financial-center times."

//============================== INPUTS =====================================
input group "========== CLOCK SETTINGS =========="
input int                 InpUTCOffsetSydney       = 10;
input int                 InpUTCOffsetTokyo        = 9;
input int                 InpUTCOffsetLondon       = 0;
input int                 InpUTCOffsetNewYork      = -5;
input bool                InpUseDSTLondon          = true;
input bool                InpUseDSTNewYork         = true;

input group "========== SESSION SETTINGS (LOCAL HOURS) =========="
input int                 InpSydneyOpenHour        = 8;
input int                 InpSydneyCloseHour       = 17;
input int                 InpTokyoOpenHour         = 9;
input int                 InpTokyoCloseHour        = 18;
input int                 InpLondonOpenHour        = 8;
input int                 InpLondonCloseHour       = 17;
input int                 InpNewYorkOpenHour       = 8;
input int                 InpNewYorkCloseHour      = 17;

input group "========== DASHBOARD =========="
input bool                InpShowPanel             = true;
input ENUM_BASE_CORNER    InpPanelCorner           = CORNER_LEFT_UPPER;
input int                 InpPanelX                = 15;
input int                 InpPanelY                = 145;
input int                 InpTimerSeconds          = 1;

//============================== COLORS =====================================
#define Q_BG       C'8,23,38'
#define Q_GOLD     C'212,175,55'
#define Q_WHITE    C'245,245,245'
#define Q_GRAY     C'169,176,184'
#define Q_GREEN    C'0,200,83'
#define Q_RED      C'255,82,82'
#define Q_BORDER   C'62,76,89'

//============================== STATE ======================================
string g_prefix="QTC5_";
string g_status="ACTIVE";

//============================== TIME HELPERS ===============================
datetime UTCNow()
{
   datetime t=TimeGMT();
   if(t<=0) t=TimeCurrent();
   return t;
}

string FormatClock(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t,dt);
   return StringFormat("%02d:%02d:%02d",dt.hour,dt.min,dt.sec);
}

string FormatDate(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t,dt);
   return StringFormat("%04d.%02d.%02d",dt.year,dt.mon,dt.day);
}

int DayOfWeek(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t,dt);
   return dt.day_of_week;
}

bool IsEU_DST(datetime utc)
{
   MqlDateTime dt;
   TimeToStruct(utc,dt);

   int y=dt.year;

   MqlDateTime a={0},b={0};
   a.year=y; a.mon=3;  a.day=31; a.hour=1;
   b.year=y; b.mon=10; b.day=31; b.hour=1;

   datetime end_mar=StructToTime(a);
   datetime end_oct=StructToTime(b);

   // Last Sunday of March
   int dow_mar=DayOfWeek(end_mar);
   end_mar-=dow_mar*86400;

   // Last Sunday of October
   int dow_oct=DayOfWeek(end_oct);
   end_oct-=dow_oct*86400;

   return (utc>=end_mar && utc<end_oct);
}

int NthSunday(int year,int month,int nth)
{
   MqlDateTime dt={0};
   dt.year=year;
   dt.mon=month;
   dt.day=1;
   dt.hour=2;

   datetime first=StructToTime(dt);
   int dow=DayOfWeek(first);

   int first_sunday=1+((7-dow)%7);
   return first_sunday+(nth-1)*7;
}

bool IsUS_DST(datetime utc)
{
   MqlDateTime dt;
   TimeToStruct(utc,dt);
   int y=dt.year;

   MqlDateTime s={0},e={0};
   s.year=y; s.mon=3; s.day=NthSunday(y,3,2); s.hour=7;
   e.year=y; e.mon=11; e.day=NthSunday(y,11,1); e.hour=6;

   datetime start=StructToTime(s);
   datetime end=StructToTime(e);

   return (utc>=start && utc<end);
}

datetime CityTime(datetime utc,int base_offset,bool dst)
{
   int offset=base_offset;
   if(dst) offset++;
   return utc+offset*3600;
}

bool IsLocalSessionOpen(datetime local_time,int open_hour,int close_hour)
{
   MqlDateTime dt;
   TimeToStruct(local_time,dt);

   if(open_hour==close_hour) return true;
   if(open_hour<close_hour)
      return (dt.hour>=open_hour && dt.hour<close_hour);

   return (dt.hour>=open_hour || dt.hour<close_hour);
}

//============================== OBJECT HELPERS =============================
bool CreateRect(string name,int x,int y,int w,int h,color bg,color border)
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

bool CreateLabel(string name,string text,int x,int y,int size,color clr,bool bold=false)
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

//============================== PANEL ======================================
void BuildPanel()
{
   if(!InpShowPanel) return;

   DeletePanel();

   int x=InpPanelX;
   int y=InpPanelY;

   CreateRect(g_prefix+"BG",x,y,540,455,Q_BG,Q_GOLD);

   CreateLabel(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   CreateLabel(g_prefix+"SUB","TRADING CLOCK",x+18,y+38,11,Q_WHITE,true);
   CreateLabel(g_prefix+"VER","MT5 v1.01",x+450,y+18,9,Q_GRAY);

   CreateLabel(g_prefix+"STATUS","STATUS: ACTIVE",x+18,y+72,10,Q_GREEN,true);

   CreateLabel(g_prefix+"SERVER","SERVER TIME: --",x+18,y+108,10,Q_WHITE);
   CreateLabel(g_prefix+"LOCAL","LOCAL TIME: --",x+280,y+108,10,Q_WHITE);
   CreateLabel(g_prefix+"UTC","UTC TIME: --",x+18,y+138,10,Q_GOLD,true);
   CreateLabel(g_prefix+"DATE","DATE: --",x+280,y+138,10,Q_GRAY);

   CreateLabel(g_prefix+"SYN","SYDNEY",x+18,y+188,10,Q_WHITE,true);
   CreateLabel(g_prefix+"SYNT","--:--:--",x+150,y+188,11,Q_GOLD,true);
   CreateLabel(g_prefix+"SYNS","CLOSED",x+340,y+188,10,Q_RED,true);

   CreateLabel(g_prefix+"TYO","TOKYO",x+18,y+228,10,Q_WHITE,true);
   CreateLabel(g_prefix+"TYOT","--:--:--",x+150,y+228,11,Q_GOLD,true);
   CreateLabel(g_prefix+"TYOS","CLOSED",x+340,y+228,10,Q_RED,true);

   CreateLabel(g_prefix+"LDN","LONDON",x+18,y+268,10,Q_WHITE,true);
   CreateLabel(g_prefix+"LDNT","--:--:--",x+150,y+268,11,Q_GOLD,true);
   CreateLabel(g_prefix+"LDNS","CLOSED",x+340,y+268,10,Q_RED,true);

   CreateLabel(g_prefix+"NY","NEW YORK",x+18,y+308,10,Q_WHITE,true);
   CreateLabel(g_prefix+"NYT","--:--:--",x+150,y+308,11,Q_GOLD,true);
   CreateLabel(g_prefix+"NYS","CLOSED",x+340,y+308,10,Q_RED,true);

   CreateRect(g_prefix+"SEP",x+18,y+348,504,2,Q_BORDER,Q_BORDER);

   CreateLabel(g_prefix+"ACTIVE","ACTIVE MARKETS: 0",x+18,y+370,10,Q_GREEN,true);
   CreateLabel(g_prefix+"OVERLAP","OVERLAP: NONE",x+260,y+370,10,Q_GOLD,true);

   CreateLabel(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",x+18,y+425,9,Q_GOLD);

   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel) return;

   datetime utc=UTCNow();

   bool eu_dst=(InpUseDSTLondon && IsEU_DST(utc));
   bool us_dst=(InpUseDSTNewYork && IsUS_DST(utc));

   datetime sydney=CityTime(utc,InpUTCOffsetSydney,false);
   datetime tokyo=CityTime(utc,InpUTCOffsetTokyo,false);
   datetime london=CityTime(utc,InpUTCOffsetLondon,eu_dst);
   datetime ny=CityTime(utc,InpUTCOffsetNewYork,us_dst);

   bool sydney_open=IsLocalSessionOpen(sydney,InpSydneyOpenHour,InpSydneyCloseHour);
   bool tokyo_open=IsLocalSessionOpen(tokyo,InpTokyoOpenHour,InpTokyoCloseHour);
   bool london_open=IsLocalSessionOpen(london,InpLondonOpenHour,InpLondonCloseHour);
   bool ny_open=IsLocalSessionOpen(ny,InpNewYorkOpenHour,InpNewYorkCloseHour);

   ObjectSetString(0,g_prefix+"SERVER",OBJPROP_TEXT,"SERVER TIME: "+FormatClock(TimeCurrent()));
   ObjectSetString(0,g_prefix+"LOCAL",OBJPROP_TEXT,"LOCAL TIME: "+FormatClock(TimeLocal()));
   ObjectSetString(0,g_prefix+"UTC",OBJPROP_TEXT,"UTC TIME: "+FormatClock(utc));
   ObjectSetString(0,g_prefix+"DATE",OBJPROP_TEXT,"DATE: "+FormatDate(utc));

   ObjectSetString(0,g_prefix+"SYNT",OBJPROP_TEXT,FormatClock(sydney));
   ObjectSetString(0,g_prefix+"TYOT",OBJPROP_TEXT,FormatClock(tokyo));
   ObjectSetString(0,g_prefix+"LDNT",OBJPROP_TEXT,FormatClock(london));
   ObjectSetString(0,g_prefix+"NYT",OBJPROP_TEXT,FormatClock(ny));

   ObjectSetString(0,g_prefix+"SYNS",OBJPROP_TEXT,sydney_open?"OPEN":"CLOSED");
   ObjectSetInteger(0,g_prefix+"SYNS",OBJPROP_COLOR,sydney_open?Q_GREEN:Q_RED);

   ObjectSetString(0,g_prefix+"TYOS",OBJPROP_TEXT,tokyo_open?"OPEN":"CLOSED");
   ObjectSetInteger(0,g_prefix+"TYOS",OBJPROP_COLOR,tokyo_open?Q_GREEN:Q_RED);

   ObjectSetString(0,g_prefix+"LDNS",OBJPROP_TEXT,london_open?"OPEN":"CLOSED");
   ObjectSetInteger(0,g_prefix+"LDNS",OBJPROP_COLOR,london_open?Q_GREEN:Q_RED);

   ObjectSetString(0,g_prefix+"NYS",OBJPROP_TEXT,ny_open?"OPEN":"CLOSED");
   ObjectSetInteger(0,g_prefix+"NYS",OBJPROP_COLOR,ny_open?Q_GREEN:Q_RED);

   int active=0;
   string overlap="";

   if(sydney_open){ active++; if(StringLen(overlap)>0) overlap+=" / "; overlap+="SYDNEY"; }
   if(tokyo_open){ active++; if(StringLen(overlap)>0) overlap+=" / "; overlap+="TOKYO"; }
   if(london_open){ active++; if(StringLen(overlap)>0) overlap+=" / "; overlap+="LONDON"; }
   if(ny_open){ active++; if(StringLen(overlap)>0) overlap+=" / "; overlap+="NEW YORK"; }

   if(active<2) overlap="NONE";

   ObjectSetString(0,g_prefix+"ACTIVE",OBJPROP_TEXT,
                   "ACTIVE MARKETS: "+IntegerToString(active));
   ObjectSetString(0,g_prefix+"OVERLAP",OBJPROP_TEXT,
                   "OVERLAP: "+overlap);

   ChartRedraw();
}

//============================== EVENTS =====================================
int OnInit()
{
   if(InpTimerSeconds<1)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,"Quantora Trading Clock MT5 v1.01");

   BuildPanel();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora Trading Clock MT5: EventSetTimer failed. Error ",GetLastError());
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
   UpdatePanel();
}

//===========================================================
// Developed by Quantora
//
// More Professional Trading Robots
//
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
