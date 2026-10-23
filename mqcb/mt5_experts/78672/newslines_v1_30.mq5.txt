//+------------------------------------------------------------------+
//|                                                   NewsLines.mq5  |
//|  Single-file EA (does not trade): economic news lines on the     |
//|  chart (+ optional labels, tooltips) and a draggable /           |
//|  resizable / collapsible event panel with quick-filter buttons.  |
//|                                                                  |
//|  Sources (select in inputs):                                     |
//|   1) MetaQuotes built-in Economic Calendar (MT5 native)          |
//|   2) Forex Factory weekly JSON feed (FairEconomy mirror)         |
//|                                                                  |
//|  SETUP for source 2 only (once):                                 |
//|   Tools > Options > Expert Advisors > tick                       |
//|   "Allow WebRequest for listed URL" and add:                     |
//|        https://nfs.faireconomy.media                             |
//|  No DLLs needed. Attach to a chart; works on all timeframes.     |
//|                                                                  |
//|  CHANGELOG                                                       |
//|  1.30  Strategy Tester support (CSV history / sample schedule),  |
//|        actual values hidden until release in tester,             |
//|        no-UI safe mode in non-visual tester                      |
//|  1.20  Click-to-focus event + Reset, source switch button,       |
//|        draggable scrollbar, groups, font zoom, label toggle      |
//|  1.00  First release                                             |
//+------------------------------------------------------------------+
#property copyright "Free to use and modify"
#property version   "1.30"
#property description "News event lines + panel (EA, no trading). Sources: MT5 Economic Calendar or Forex Factory JSON."
#property description "Strategy Tester: uses NewsLines_history.csv (Common\\Files) or a clearly-labelled sample schedule."

#include <Canvas\Canvas.mqh>
#include <Generic\HashMap.mqh>

//--- enums
enum ENUM_NEWS_SOURCE { SRC_MT5 = 0,   // MT5 built-in Economic Calendar (MetaQuotes)
                        SRC_FF  = 1 }; // Forex Factory weekly JSON feed (FairEconomy)
enum ENUM_CCY_MODE    { CCY_SYMBOL = 0, // Currencies of the chart symbol
                        CCY_ALL    = 1, // All currencies
                        CCY_CUSTOM = 2 }; // Custom list (below)
enum ENUM_TIME_MODE   { TM_LOCAL = 0,   // Panel shows my PC local time
                        TM_SERVER = 1 }; // Panel shows broker server time
enum ENUM_GROUP       { GRP_DEFAULT = 0, // Default (currency filter below)
                        GRP_GOLD    = 1, // Gold & Silver
                        GRP_FOREX   = 2, // Major forex pairs
                        GRP_INDICES = 3, // Indices
                        GRP_OIL     = 4 }; // Oil & Gas

//--- inputs
input group "=== News source ==="
input ENUM_NEWS_SOURCE InpSource      = SRC_MT5;   // News source
input string           InpFFUrlThis   = "https://nfs.faireconomy.media/ff_calendar_thisweek.json"; // FF feed: this week
input string           InpFFUrlNext   = "https://nfs.faireconomy.media/ff_calendar_nextweek.json"; // FF feed: next week
input int              InpRefreshMin  = 15;        // Refresh interval (minutes; FF feed min 5)

input group "=== Start-up state (buttons change these live and are remembered) ==="
input ENUM_GROUP       InpStartGroup  = GRP_DEFAULT; // Start group
input bool             InpStartAllImp = false;     // Start showing ALL impact levels (default: High only)
input bool             InpStartLabels = false;     // Start with labels visible
input bool             InpResetState  = false;     // Ignore remembered state/position (re-apply these inputs)

input group "=== Default group: currency filter ==="
input ENUM_CCY_MODE    InpCcyMode     = CCY_SYMBOL;        // Currency filter
input string           InpCustomCcy   = "USD,EUR,GBP,JPY"; // Custom currencies

input group "=== Impact levels allowed (Medium/Low only show when Impact button = All) ==="
input bool             InpShowHigh    = true;      // Allow HIGH impact
input bool             InpShowMed     = true;      // Allow MEDIUM impact
input bool             InpShowLow     = true;      // Allow LOW impact

input group "=== Group: Gold & Silver  (keywords match event title; empty = all events of those currencies) ==="
input string           InpGoldCcy     = "USD";
input string           InpGoldKeys    = "non-farm,nonfarm,payroll,employment,unemployment,jobless,cpi,inflation,pce,ppi,retail sales,gdp,fed,fomc,federal funds,interest rate,ism,powell,treasury";

input group "=== Group: Major forex pairs ==="
input string           InpFxCcy       = "USD,EUR,GBP,JPY,CHF,CAD,AUD,NZD";
input string           InpFxKeys      = "";

input group "=== Group: Indices ==="
input string           InpIdxCcy      = "USD,EUR,GBP,JPY";
input string           InpIdxKeys     = "non-farm,nonfarm,payroll,employment,unemployment,cpi,ppi,gdp,retail sales,pmi,ism,fed,fomc,ecb,boe,boj,interest rate,rate decision,consumer confidence,ifo,zew,sentiment";

input group "=== Group: Oil & Gas ==="
input string           InpOilCcy      = "USD,CAD";
input string           InpOilKeys     = "crude,oil,natural gas,eia,api,baker hughes,rig count,gasoline,distillate,cushing,refinery,opec,non-farm,nonfarm,fomc,fed,cpi,gdp";

input group "=== Chart lines ==="
input bool             InpShowLines   = true;      // Draw lines on chart
input color            InpColHigh     = clrRed;           // High impact colour
input color            InpColMed      = clrOrange;        // Medium impact colour
input color            InpColLow      = C'184,150,0';     // Low impact colour (dark yellow)
input ENUM_LINE_STYLE  InpLineStyle   = STYLE_DASH;       // Line style
input int              InpLineWidth   = 1;         // Line width
input int              InpLabelSize   = 8;         // Label font size
input int              InpLabelChars  = 32;        // Label max characters
input int              InpMaxLines    = 1000;      // Max lines drawn (lowest impact dropped first)
input int              InpMaxDaysBack = 0;         // Limit history in days (0 = as far as chart goes)
input bool             InpSelectable  = false;     // Lines selectable (turn on if tooltips don't show)

input group "=== Panel ==="
input bool             InpShowPanel   = true;      // Show panel
input int              InpHoursBack   = 36;        // Panel: hours back
input int              InpHoursAhead  = 36;        // Panel: hours ahead
input ENUM_TIME_MODE   InpTimeMode    = TM_LOCAL;  // Panel time zone
input int              InpPanelX      = 20;        // Initial X
input int              InpPanelY      = 40;        // Initial Y
input int              InpPanelW      = 460;       // Initial width
input int              InpPanelH      = 400;       // Initial height

//--- data
struct SNews { datetime t; string cur; string title; int imp; string fc; string pv; string ac; };
struct SSlot { datetime t; int imp; string tip; string lbl; };
struct SRow  { int kind; int ev; string txt; };      // kind 0=section, 1=event, 2=message
struct SInfo { string name; string cur; int imp; int digits; };
struct SBtn  { int x1; int y1; int x2; int y2; int id; };

SNews g_ev[];
SRow  g_rows[];
SInfo g_info[];
SBtn  g_btn[];
CHashMap<ulong,int> g_infoMap;

#define PFX "NLN_"
#define MINW 340
#define GRIP 16
int HDR=26, TB=23, FTR=19, RH=21, g_fs=13;     // metrics (scaled by font zoom)

CCanvas  g_cv;
string   g_status="Loading...";
string   g_ccy="";
bool     g_ccyAll=false;
string   g_gCcy="";
bool     g_gCcyAll=true;
string   g_gKeys[];
int      g_srvOff=0;

//--- runtime state (buttons)
bool     g_showLabels=false;
bool     g_allImp=false;
int      g_group=0;
int      g_fz=0;               // font zoom (px added to base size)
ENUM_NEWS_SOURCE g_source=SRC_MT5;   // runtime news source (button)
bool     g_tester=false, g_visual=false, g_panelOn=true;
datetime g_tstRebuild=0;
int      g_tbH=23;             // current toolbar height (1 or 2 rows)
bool     g_selOn=false;        // focus on one event (set by clicking a row)
string   g_selCur="", g_selTitle="";

bool     g_loaded=false;
datetime g_loadFrom=0, g_loadTo=0, g_loadWall=0;
datetime g_drawFrom=0, g_drawTo=0;
bool     g_forceRebuild=true, g_chgPending=false, g_firstRun=true;
uint     g_chgTick=0;
int      g_lblN=0;
double   g_lastPmin=0, g_lastPmax=0;
datetime g_lastPanelWall=0;
string   g_httpErr="";

int  g_px,g_py,g_pw,g_ph;
bool g_col=false;
int  g_scroll=0;
int  g_drag=0, g_dx=0, g_dy=0, g_sw=0, g_sh=0;
bool g_prevDown=false, g_scrollLocked=false;
//--- scrollbar geometry (set by DrawPanel)
bool g_sbOn=false;
int  g_sbX1=0, g_sbTop=0, g_sbTrack=0, g_sbThumbY=0, g_sbThumbH=0, g_sbMax=0, g_sbStart=0;

//+------------------------------------------------------------------+
//| helpers / filters                                                |
//+------------------------------------------------------------------+
color ImpColor(const int imp) { return imp>=3 ? InpColHigh : (imp==2 ? InpColMed : InpColLow); }
string ImpTag(const int imp)  { return imp>=3 ? "H" : (imp==2 ? "M" : "L"); }

string GroupName(const int g)
{
   switch(g)
   {
      case 1: return "Gold & Silver";
      case 2: return "Forex Majors";
      case 3: return "Indices";
      case 4: return "Oil & Gas";
   }
   return "Default";
}

void BuildCcyList()
{
   g_ccyAll=false; g_ccy="";
   if(InpCcyMode==CCY_ALL){ g_ccyAll=true; return; }
   string list;
   if(InpCcyMode==CCY_SYMBOL)
      list=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE)+","+SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT)+","+SymbolInfoString(_Symbol,SYMBOL_CURRENCY_MARGIN);
   else
      list=InpCustomCcy;
   StringToUpper(list);
   StringReplace(list," ","");
   string tmp=list;
   StringReplace(tmp,",","");
   if(StringLen(tmp)==0){ g_ccyAll=true; return; }
   g_ccy=","+list+",";
}

// parse currency list + keywords of the active group
void ApplyGroup()
{
   ArrayResize(g_gKeys,0);
   string ccy="", keys="";
   switch(g_group)
   {
      case 1: ccy=InpGoldCcy; keys=InpGoldKeys; break;
      case 2: ccy=InpFxCcy;   keys=InpFxKeys;   break;
      case 3: ccy=InpIdxCcy;  keys=InpIdxKeys;  break;
      case 4: ccy=InpOilCcy;  keys=InpOilKeys;  break;
      default:
         g_gCcy=g_ccy; g_gCcyAll=g_ccyAll;
         return;
   }
   StringToUpper(ccy);
   StringReplace(ccy," ","");
   string tmp=ccy;
   StringReplace(tmp,",","");
   if(StringLen(tmp)==0){ g_gCcyAll=true; g_gCcy=""; }
   else { g_gCcyAll=false; g_gCcy=","+ccy+","; }

   StringToLower(keys);
   string parts[];
   int n=StringSplit(keys,',',parts);
   for(int i=0;i<n;i++)
   {
      string k=parts[i];
      StringTrimLeft(k);
      StringTrimRight(k);
      if(StringLen(k)==0) continue;
      int m=ArraySize(g_gKeys);
      ArrayResize(g_gKeys,m+1);
      g_gKeys[m]=k;
   }
}

bool GroupAllows(const SNews &e)
{
   if(!g_gCcyAll && StringFind(g_gCcy,","+e.cur+",")<0) return false;
   int nk=ArraySize(g_gKeys);
   if(nk==0) return true;
   string tl=e.title;
   StringToLower(tl);
   for(int k=0;k<nk;k++)
      if(StringFind(tl,g_gKeys[k])>=0) return true;
   return false;
}

// does this event pass the current impact + group filter?
bool Pass(const SNews &e)
{
   if(e.imp>=3){ if(!InpShowHigh) return false; }
   else if(e.imp==2){ if(!(g_allImp && InpShowMed)) return false; }
   else if(e.imp==1){ if(!(g_allImp && InpShowLow)) return false; }
   else return false;
   return GroupAllows(e);
}

// filter used for the CHART lines: a focused event overrides the other filters
string ActVal(const SNews &e)
{
   if(g_tester && e.t>TimeCurrent()) return "";   // no look-ahead in backtests
   return e.ac;
}

bool PassChart(const SNews &e)
{
   if(g_selOn) return (e.cur==g_selCur && e.title==g_selTitle);
   return Pass(e);
}

void SetMetrics()
{
   g_fs=13+g_fz;
   HDR=g_fs+13;
   TB =g_fs+10;
   RH =g_fs+8;
   FTR=g_fs+6;
   g_tbH=TB;
}

bool EvGreater(const SNews &a,const SNews &b)
{
   if(a.t!=b.t) return a.t>b.t;
   return a.imp<b.imp;            // higher impact first inside the same time
}

void SortEvents()
{
   int n=ArraySize(g_ev);
   for(int gap=n/2; gap>0; gap/=2)
      for(int i=gap;i<n;i++)
      {
         SNews tmp=g_ev[i];
         int j=i;
         while(j>=gap && EvGreater(g_ev[j-gap],tmp)){ g_ev[j]=g_ev[j-gap]; j-=gap; }
         g_ev[j]=tmp;
      }
}

void CopyNews(SNews &dst[],SNews &src[])
{
   int n=ArraySize(src);
   ArrayResize(dst,n);
   for(int i=0;i<n;i++) dst[i]=src[i];
}

datetime BarTime(const int idx)
{
   if(idx>=0)
   {
      datetime t[];
      if(CopyTime(_Symbol,_Period,idx,1,t)==1) return t[0];
      return 0;
   }
   datetime t0=iTime(_Symbol,_Period,0);
   return (datetime)((long)t0+(long)(-idx)*PeriodSeconds());
}

void GetVisibleRange(datetime &vf,datetime &vt)
{
   int first=(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR);
   int vis  =(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
   vf=BarTime(first);
   vt=BarTime(first-vis+1);
   datetime now=TimeTradeServer();
   if(vf==0) vf=(datetime)((long)now-7*86400);
   if(vt==0) vt=(datetime)((long)now+86400);
   if(vt<vf)  { datetime x=vf; vf=vt; vt=x; }
}

//+------------------------------------------------------------------+
//| source 1: MT5 calendar                                           |
//+------------------------------------------------------------------+
int GetInfo(const ulong id)
{
   int idx;
   if(g_infoMap.TryGetValue(id,idx)) return idx;
   MqlCalendarEvent ev;
   idx=-1;
   if(CalendarEventById(id,ev))
   {
      MqlCalendarCountry c;
      string cur="";
      if(CalendarCountryById(ev.country_id,c)) cur=c.currency;
      int imp=0;
      if(ev.importance==CALENDAR_IMPORTANCE_HIGH) imp=3;
      else if(ev.importance==CALENDAR_IMPORTANCE_MODERATE) imp=2;
      else if(ev.importance==CALENDAR_IMPORTANCE_LOW) imp=1;
      idx=ArraySize(g_info);
      ArrayResize(g_info,idx+1,256);
      g_info[idx].name=ev.name;
      g_info[idx].cur=cur;
      g_info[idx].imp=imp;
      g_info[idx].digits=(int)ev.digits;
   }
   g_infoMap.Add(id,idx);
   return idx;
}

bool LoadMT5(const datetime from,const datetime to)
{
   MqlCalendarValue vals[];
   ResetLastError();
   int n=CalendarValueHistory(vals,from,to);
   if(n<0)
   {
      g_status="MT5 calendar error "+IntegerToString(GetLastError());
      return false;
   }
   ArrayResize(g_ev,0);
   ArrayResize(g_ev,n);
   int c=0;
   for(int i=0;i<n;i++)
   {
      int k=GetInfo(vals[i].event_id);
      if(k<0) continue;
      if(g_info[k].imp<=0) continue;
      g_ev[c].t=vals[i].time;
      g_ev[c].cur=g_info[k].cur;
      g_ev[c].title=g_info[k].name;
      g_ev[c].imp=g_info[k].imp;
      int dg=g_info[k].digits;
      g_ev[c].fc=vals[i].HasForecastValue() ? DoubleToString(vals[i].GetForecastValue(),dg) : "";
      g_ev[c].pv=vals[i].HasPreviousValue() ? DoubleToString(vals[i].GetPreviousValue(),dg) : "";
      g_ev[c].ac=vals[i].HasActualValue()   ? DoubleToString(vals[i].GetActualValue(),dg)   : "";
      c++;
   }
   ArrayResize(g_ev,c);
   SortEvents();
   g_status="MT5 calendar: "+IntegerToString(c)+" events";
   if(n==0) g_status="MT5 calendar returned no data (not connected / unsupported broker?)";
   return true;
}

//+------------------------------------------------------------------+
//| source 2: Forex Factory JSON (WebRequest + file cache)           |
//+------------------------------------------------------------------+
bool HttpGet(const string url,string &out)
{
   char data[],result[];
   string rh;
   out="";
   ResetLastError();
   int code=WebRequest("GET",url,"User-Agent: Mozilla/5.0\r\n",10000,data,result,rh);
   if(code==-1)
   {
      g_httpErr="WebRequest error "+IntegerToString(GetLastError())+" - add https://nfs.faireconomy.media to Tools>Options>Expert Advisors";
      return false;
   }
   if(code!=200){ g_httpErr="HTTP "+IntegerToString(code); return false; }
   out=CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8);
   string t=out;
   StringTrimLeft(t);
   if(StringGetCharacter(t,0)!='['){ g_httpErr="unexpected response"; return false; }
   return true;
}

bool ReadTextFile(const string file,string &body)
{
   int h=FileOpen(file,FILE_READ|FILE_BIN|FILE_COMMON);
   if(h==INVALID_HANDLE) return false;
   uchar a[];
   FileReadArray(h,a);
   FileClose(h);
   body=CharArrayToString(a,0,WHOLE_ARRAY,CP_UTF8);
   return StringLen(body)>2;
}

void WriteTextFile(const string file,const string s)
{
   int h=FileOpen(file,FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(h==INVALID_HANDLE) return;
   uchar a[];
   int n=StringToCharArray(s,a,0,WHOLE_ARRAY,CP_UTF8);
   if(n>1) FileWriteArray(h,a,0,n-1);
   FileClose(h);
}

bool GetFeed(const string url,const string file,string &body)
{
   bool have=FileIsExist(file,FILE_COMMON);
   bool fresh=false;
   if(have)
   {
      datetime mt=(datetime)FileGetInteger(file,FILE_MODIFY_DATE,true);
      fresh=((long)TimeLocal()-(long)mt) < (long)MathMax(InpRefreshMin,5)*60;
   }
   if(have && fresh && ReadTextFile(file,body)) return true;
   string dl;
   if(HttpGet(url,dl)){ WriteTextFile(file,dl); body=dl; return true; }
   if(have) return ReadTextFile(file,body);   // fall back to stale cache
   return false;
}

string JsonGet(const string o,const string key)
{
   string k="\""+key+"\"";
   int p=StringFind(o,k);
   if(p<0) return "";
   p=StringFind(o,":",p+StringLen(k));
   if(p<0) return "";
   p++;
   int len=StringLen(o);
   while(p<len && StringGetCharacter(o,p)==' ') p++;
   if(p>=len) return "";
   string res="";
   if(StringGetCharacter(o,p)=='"')
   {
      p++;
      while(p<len)
      {
         ushort c=StringGetCharacter(o,p);
         if(c=='\\' && p+1<len)
         {
            ushort d=StringGetCharacter(o,p+1);
            if(d=='"' || d=='\\' || d=='/') res+=ShortToString(d);
            p+=2;
            continue;
         }
         if(c=='"') break;
         res+=ShortToString(c);
         p++;
      }
   }
   else
   {
      while(p<len)
      {
         ushort c=StringGetCharacter(o,p);
         if(c==',' || c=='}') break;
         res+=ShortToString(c);
         p++;
      }
   }
   return res;
}

bool ParseFFDate(const string d,datetime &srv)
{
   if(StringLen(d)<19) return false;
   string ds=StringSubstr(d,0,10);
   StringReplace(ds,"-",".");
   datetime wall=StringToTime(ds+" "+StringSubstr(d,11,8));
   if(wall==0) return false;
   long off=0;
   if(StringLen(d)>=25)
   {
      ushort sg=StringGetCharacter(d,19);
      long hh=StringToInteger(StringSubstr(d,20,2));
      long mm=StringToInteger(StringSubstr(d,23,2));
      off=hh*3600+mm*60;
      if(sg=='-') off=-off;
   }
   long utc=(long)wall-off;
   srv=(datetime)(utc+g_srvOff);
   return true;
}

void ParseFF(const string json)
{
   int pos=0;
   while(true)
   {
      int s=StringFind(json,"{",pos);
      if(s<0) break;
      int e=StringFind(json,"}",s);
      if(e<0) break;
      string o=StringSubstr(json,s,e-s+1);
      pos=e+1;

      string im=JsonGet(o,"impact");
      int imp=0;
      if(im=="High") imp=3; else if(im=="Medium") imp=2; else if(im=="Low") imp=1;
      if(imp==0) continue;
      string cur=JsonGet(o,"country");
      StringToUpper(cur);
      datetime t;
      if(!ParseFFDate(JsonGet(o,"date"),t)) continue;

      int k=ArraySize(g_ev);
      ArrayResize(g_ev,k+1,256);
      g_ev[k].t=t;
      g_ev[k].cur=cur;
      g_ev[k].title=JsonGet(o,"title");
      g_ev[k].imp=imp;
      g_ev[k].fc=JsonGet(o,"forecast");
      g_ev[k].pv=JsonGet(o,"previous");
      g_ev[k].ac="";
   }
}

bool LoadFF()
{
   g_srvOff=(int)MathRound((double)(TimeTradeServer()-TimeGMT())/900.0)*900;
   string urls[2];  urls[0]=InpFFUrlThis; urls[1]=InpFFUrlNext;
   string files[2]; files[0]="NewsLines_ff_this.json"; files[1]="NewsLines_ff_next.json";
   SNews keep[];
   CopyNews(keep,g_ev);
   ArrayResize(g_ev,0);
   int ok=0;
   for(int i=0;i<2;i++)
   {
      string body;
      if(urls[i]!="" && GetFeed(urls[i],files[i],body)){ ParseFF(body); ok++; }
   }
   if(ok==0)
   {
      CopyNews(g_ev,keep);
      g_status="FF feed failed: "+g_httpErr;
      return false;
   }
   SortEvents();
   g_status="FF feed: "+IntegerToString(ArraySize(g_ev))+" events (this/next week)";
   return true;
}

//+------------------------------------------------------------------+
//| Strategy Tester data                                             |
//|  1) NewsLines_history.csv in Common\Files  (or MQL5\Files)       |
//|     one event per line, ';' separated:                           |
//|     yyyy.mm.dd hh:mm;CUR;High|Medium|Low;Title;Forecast;Prev;Actual |
//|     (time = broker server time; last 3 columns optional)         |
//|  2) otherwise a clearly-labelled SAMPLE schedule (not real data) |
//+------------------------------------------------------------------+
string TrimS(string x){ StringTrimLeft(x); StringTrimRight(x); return x; }

bool LoadCSV(const string file)
{
   int h=FileOpen(file,FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON);
   if(h==INVALID_HANDLE) h=FileOpen(file,FILE_READ|FILE_TXT|FILE_ANSI);
   if(h==INVALID_HANDLE) return false;
   int c=0;
   while(!FileIsEnding(h))
   {
      string ln=TrimS(FileReadString(h));
      if(StringLen(ln)<12) continue;
      ushort c0=StringGetCharacter(ln,0);
      if(c0<'0' || c0>'9') continue;          // header / comment line
      string p[];
      int n=StringSplit(ln,';',p);
      if(n<4) continue;
      datetime t=StringToTime(TrimS(p[0]));
      if(t==0) continue;
      string im=TrimS(p[2]);
      StringToLower(im);
      int imp=0;
      if(im=="high" || im=="3") imp=3;
      else if(im=="medium" || im=="med" || im=="moderate" || im=="2") imp=2;
      else if(im=="low" || im=="1") imp=1;
      if(imp==0) continue;
      string cur=TrimS(p[1]);
      StringToUpper(cur);
      int k=ArraySize(g_ev);
      ArrayResize(g_ev,k+1,512);
      g_ev[k].t=t;
      g_ev[k].cur=cur;
      g_ev[k].imp=imp;
      g_ev[k].title=TrimS(p[3]);
      g_ev[k].fc=(n>4) ? TrimS(p[4]) : "";
      g_ev[k].pv=(n>5) ? TrimS(p[5]) : "";
      g_ev[k].ac=(n>6) ? TrimS(p[6]) : "";
      c++;
   }
   FileClose(h);
   return c>0;
}

void AddSample(const long t,const string cur,const string title,const int imp)
{
   int k=ArraySize(g_ev);
   ArrayResize(g_ev,k+1,512);
   g_ev[k].t=(datetime)t;
   g_ev[k].cur=cur;
   g_ev[k].title=title+" (sample)";
   g_ev[k].imp=imp;
   g_ev[k].fc=""; g_ev[k].pv=""; g_ev[k].ac="";
}

// recurring pattern only - NOT real release dates
void GenSample()
{
   long now=(long)TimeCurrent();
   long first=(long)SeriesInfoInteger(_Symbol,_Period,SERIES_FIRSTDATE);
   long lim=now-5*365*86400;
   long from=(first>lim) ? first : lim;
   long to=now+90*86400;
   for(long d=from-(from%86400); d<=to; d+=86400)
   {
      MqlDateTime dt;
      TimeToStruct((datetime)d,dt);
      int dow=dt.day_of_week;
      if(dow==0 || dow==6) continue;
      if(dow==1) AddSample(d+8*3600,"EUR","Sentiment Index",1);
      if(dow==1 && dt.day<=7) AddSample(d+17*3600,"USD","ISM Manufacturing PMI",2);
      if(dow==3) AddSample(d+16*3600+1800,"USD","Crude Oil Inventories",2);
      if(dow==4) AddSample(d+14*3600+1800,"USD","Unemployment Claims",2);
      if(dow==5 && dt.day<=7) AddSample(d+14*3600+1800,"USD","Non-Farm Payrolls",3);
      if(dt.day==12 || (dt.day>12 && dt.day<=14 && dow==1)) AddSample(d+14*3600+1800,"USD","CPI m/m",3);
      if(dow==4 && dt.day>=8 && dt.day<=14) AddSample(d+15*3600+900,"EUR","ECB Rate Decision",3);
      if(dow==3 && dt.day>=15 && dt.day<=21 &&
         (dt.mon==1 || dt.mon==3 || dt.mon==5 || dt.mon==6 || dt.mon==7 || dt.mon==9 || dt.mon==11 || dt.mon==12))
         AddSample(d+21*3600,"USD","FOMC Rate Decision",3);
   }
}

bool LoadTester()
{
   ArrayResize(g_ev,0);
   if(LoadCSV("NewsLines_history.csv"))
   {
      SortEvents();
      g_status="TESTER: "+IntegerToString(ArraySize(g_ev))+" events from NewsLines_history.csv";
      return true;
   }
   GenSample();
   SortEvents();
   g_status="TESTER: SAMPLE schedule (not real data) - add NewsLines_history.csv";
   return true;
}

//+------------------------------------------------------------------+
//| panel rows                                                       |
//+------------------------------------------------------------------+
void AddRow(const int kind,const int ev,const string txt)
{
   int k=ArraySize(g_rows);
   ArrayResize(g_rows,k+1,256);
   g_rows[k].kind=kind; g_rows[k].ev=ev; g_rows[k].txt=txt;
}

void BuildRows()
{
   ArrayResize(g_rows,0);
   datetime now=TimeTradeServer();
   long a=(long)now-(long)InpHoursBack*3600;
   long b=(long)now+(long)InpHoursAhead*3600;
   int n=ArraySize(g_ev);

   AddRow(0,-1,"UPCOMING  (next "+IntegerToString(InpHoursAhead)+"h)");
   int c=0;
   for(int i=0;i<n;i++)
      if((long)g_ev[i].t>=(long)now && (long)g_ev[i].t<=b && Pass(g_ev[i])){ AddRow(1,i,""); c++; }
   if(c==0) AddRow(2,-1,"No upcoming events");

   AddRow(0,-1,"PAST  (last "+IntegerToString(InpHoursBack)+"h)");
   c=0;
   for(int i=n-1;i>=0;i--)
      if((long)g_ev[i].t<(long)now && (long)g_ev[i].t>=a && Pass(g_ev[i])){ AddRow(1,i,""); c++; }
   if(c==0) AddRow(2,-1,"No past events");
}

//+------------------------------------------------------------------+
//| data loading control                                             |
//+------------------------------------------------------------------+
void EnsureLoaded()
{
   datetime now=TimeTradeServer();
   if(g_tester)
   {
      if(!g_loaded && LoadTester()){ g_loaded=true; BuildRows(); }
      return;
   }
   if(g_source==SRC_FF)
   {
      if(!g_loaded && (long)TimeLocal()-(long)g_loadWall>=120)
      {
         g_loadWall=TimeLocal();
         if(LoadFF()){ g_loaded=true; BuildRows(); }
      }
      return;
   }
   long rf=MathMin((long)g_drawFrom,(long)now-(long)InpHoursBack*3600-86400);
   long rt=MathMax((long)g_drawTo,(long)now+(long)InpHoursAhead*3600+86400);
   if(g_loaded && rf>=(long)g_loadFrom && rt<=(long)g_loadTo) return;
   if(g_loaded){ rf=MathMin(rf,(long)g_loadFrom); rt=MathMax(rt,(long)g_loadTo); }
   if(LoadMT5((datetime)rf,(datetime)rt))
   {
      g_loadFrom=(datetime)rf; g_loadTo=(datetime)rt; g_loaded=true; g_loadWall=TimeLocal();
      BuildRows();
   }
}

void ReloadAll()
{
   if(g_tester) return;
   g_loadWall=TimeLocal();
   bool ok=false;
   if(g_source==SRC_FF) ok=LoadFF();
   else if(g_loaded)     ok=LoadMT5(g_loadFrom,g_loadTo);
   if(ok){ g_loaded=true; BuildRows(); g_forceRebuild=true; }
}

//+------------------------------------------------------------------+
//| chart lines                                                      |
//+------------------------------------------------------------------+
void RebuildLines()
{
   ObjectsDeleteAll(0,PFX+"L_");
   ObjectsDeleteAll(0,PFX+"T_");
   g_lblN=0;
   if(!InpShowLines){ ChartRedraw(0); return; }

   int n=ArraySize(g_ev);
   // indices of events that pass the filters and lie in the draw range
   int ix[];
   int nx=0;
   for(int q=0;q<n;q++)
   {
      if(g_ev[q].t<g_drawFrom) continue;
      if(g_ev[q].t>g_drawTo) break;
      if(!PassChart(g_ev[q])) continue;
      ArrayResize(ix,nx+1,512);
      ix[nx]=q;
      nx++;
   }

   SSlot sl[];
   int sc=0, i=0;
   while(i<nx)
   {
      int j=i;
      while(j<nx && g_ev[ix[j]].t==g_ev[ix[i]].t) j++;
      int f=ix[i];

      ArrayResize(sl,sc+1,512);
      sl[sc].t=g_ev[f].t;
      sl[sc].imp=g_ev[f].imp;
      string tip=TimeToString(g_ev[f].t,TIME_DATE|TIME_MINUTES)+" (server time)";
      int shown=0;
      for(int k=i;k<j;k++)
      {
         int e=ix[k];
         if(shown>=10){ tip+="\n... +"+IntegerToString(j-k)+" more"; break; }
         tip+="\n["+ImpTag(g_ev[e].imp)+"] "+g_ev[e].cur+"  "+g_ev[e].title;
         if(g_ev[e].fc!="" || g_ev[e].pv!="" || ActVal(g_ev[e])!="")
         {
            tip+="\n      ";
            if(ActVal(g_ev[e])!="") tip+="Actual: "+ActVal(g_ev[e])+"   ";
            if(g_ev[e].fc!="") tip+="Forecast: "+g_ev[e].fc+"   ";
            if(g_ev[e].pv!="") tip+="Previous: "+g_ev[e].pv;
         }
         shown++;
      }
      string lbl=TimeToString(g_ev[f].t,TIME_MINUTES)+" "+g_ev[f].cur+" "+g_ev[f].title;
      if(StringLen(lbl)>InpLabelChars) lbl=StringSubstr(lbl,0,InpLabelChars)+"..";
      if(j-i>1) lbl+=" +"+IntegerToString(j-i-1);
      sl[sc].tip=tip;
      sl[sc].lbl=lbl;
      sc++;
      i=j;
   }

   // cap number of lines: drop lowest impact first
   int cnt[4];
   ArrayInitialize(cnt,0);
   for(int s=0;s<sc;s++) cnt[sl[s].imp]++;
   int thr=1;
   if(cnt[1]+cnt[2]+cnt[3]>InpMaxLines) thr=2;
   if(thr==2 && cnt[2]+cnt[3]>InpMaxLines) thr=3;

   double pmin=ChartGetDouble(0,CHART_PRICE_MIN);
   double pmax=ChartGetDouble(0,CHART_PRICE_MAX);
   double lp=pmin+(pmax-pmin)*0.03;
   g_lastPmin=pmin; g_lastPmax=pmax;

   for(int s=0;s<sc;s++)
   {
      if(sl[s].imp<thr) continue;
      color clr=ImpColor(sl[s].imp);
      string nm=PFX+"L_"+IntegerToString(s);
      if(ObjectCreate(0,nm,OBJ_VLINE,0,sl[s].t,0))
      {
         ObjectSetInteger(0,nm,OBJPROP_COLOR,clr);
         ObjectSetInteger(0,nm,OBJPROP_STYLE,InpLineStyle);
         ObjectSetInteger(0,nm,OBJPROP_WIDTH,InpLineWidth);
         ObjectSetInteger(0,nm,OBJPROP_BACK,true);
         ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,InpSelectable);
         ObjectSetInteger(0,nm,OBJPROP_SELECTED,false);
         ObjectSetInteger(0,nm,OBJPROP_HIDDEN,true);
         ObjectSetInteger(0,nm,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
         ObjectSetString(0,nm,OBJPROP_TOOLTIP,sl[s].tip);
      }
      if(g_showLabels)
      {
         string tn=PFX+"T_"+IntegerToString(g_lblN);
         if(ObjectCreate(0,tn,OBJ_TEXT,0,sl[s].t,lp))
         {
            ObjectSetString(0,tn,OBJPROP_TEXT,sl[s].lbl);
            ObjectSetString(0,tn,OBJPROP_FONT,"Arial");
            ObjectSetInteger(0,tn,OBJPROP_FONTSIZE,InpLabelSize);
            ObjectSetInteger(0,tn,OBJPROP_COLOR,clr);
            ObjectSetDouble(0,tn,OBJPROP_ANGLE,90.0);
            ObjectSetInteger(0,tn,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
            ObjectSetInteger(0,tn,OBJPROP_SELECTABLE,false);
            ObjectSetInteger(0,tn,OBJPROP_HIDDEN,true);
            ObjectSetInteger(0,tn,OBJPROP_BACK,true);     // background layer => always below the panel
            ObjectSetInteger(0,tn,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
            ObjectSetString(0,tn,OBJPROP_TOOLTIP,sl[s].tip);
            g_lblN++;
         }
      }
   }
   ChartRedraw(0);
}

void RepositionLabels()
{
   if(!g_showLabels || g_lblN==0) return;
   double pmin=ChartGetDouble(0,CHART_PRICE_MIN);
   double pmax=ChartGetDouble(0,CHART_PRICE_MAX);
   if(pmin==g_lastPmin && pmax==g_lastPmax) return;
   g_lastPmin=pmin; g_lastPmax=pmax;
   double p=pmin+(pmax-pmin)*0.03;
   for(int i=0;i<g_lblN;i++)
      ObjectSetDouble(0,PFX+"T_"+IntegerToString(i),OBJPROP_PRICE,p);
   ChartRedraw(0);
}

void HandleChange()
{
   datetime vf,vt;
   GetVisibleRange(vf,vt);
   datetime lim=0;
   if(InpMaxDaysBack>0)
   {
      lim=(datetime)((long)TimeTradeServer()-(long)InpMaxDaysBack*86400);
      if(vf<lim) vf=lim;
   }
   if(!g_forceRebuild && g_drawTo>0 && vf>=g_drawFrom && vt<=g_drawTo)
   {
      RepositionLabels();
      return;
   }
   long w=(long)(vt-vf);
   if(w<3600) w=3600;
   g_drawFrom=(datetime)((long)vf-w);
   g_drawTo  =(datetime)((long)vt+w);
   if(lim>0 && g_drawFrom<lim) g_drawFrom=lim;
   EnsureLoaded();
   RebuildLines();
   g_forceRebuild=false;
}

//+------------------------------------------------------------------+
//| panel drawing                                                    |
//+------------------------------------------------------------------+
string RelTime(const long secs)
{
   long s=secs<0 ? -secs : secs;
   long d=s/86400, h=(s%86400)/3600, m=(s%3600)/60;
   string r;
   if(d>0) r=IntegerToString(d)+"d "+IntegerToString(h)+"h";
   else if(h>0) r=IntegerToString(h)+"h "+IntegerToString(m)+"m";
   else r=IntegerToString(m)+"m";
   if(secs<0) return r+" ago";
   if(s<60) return "now";
   return "in "+r;
}

string FitText(const string s,const int maxw)
{
   if(maxw<12) return "";
   if(g_cv.TextWidth(s)<=maxw) return s;
   string t=s;
   while(StringLen(t)>1 && g_cv.TextWidth(t+"..")>maxw) t=StringSubstr(t,0,StringLen(t)-1);
   return t+"..";
}

void AddBtn(const int x1,const int y1,const int x2,const int y2,const int id)
{
   int k=ArraySize(g_btn);
   ArrayResize(g_btn,k+1,16);
   g_btn[k].x1=x1; g_btn[k].y1=y1; g_btn[k].x2=x2; g_btn[k].y2=y2; g_btn[k].id=id;
}

void DrawButton(const int x1,const int y1,const int x2,const int y2,const string txt,const bool active,const int id)
{
   g_cv.FillRectangle(x1,y1,x2,y2,ColorToARGB(active ? C'38,104,184' : C'56,63,78'));
   g_cv.Rectangle(x1,y1,x2,y2,ColorToARGB(C'96,106,126'));
   int th=g_cv.TextHeight(txt);
   g_cv.TextOut((x1+x2)/2,y1+(y2-y1-th)/2,txt,ColorToARGB(C'238,242,248'),TA_CENTER|TA_TOP);
   AddBtn(x1,y1,x2,y2,id);
}

void DrawPanel()
{
   if(!g_panelOn) return;
   ArrayResize(g_btn,0);
   g_sbOn=false;
   int H=g_col ? HDR : g_ph;
   g_cv.Erase(ColorToARGB(C'22,25,31',238));
   g_cv.Rectangle(0,0,g_pw-1,H-1,ColorToARGB(C'74,82,98'));
   g_cv.FillRectangle(1,1,g_pw-2,HDR-1,ColorToARGB(C'40,46,58'));

   // header: title + font zoom + collapse
   g_cv.FontSet("Segoe UI",g_fs+1,FW_BOLD);
   int th=g_cv.TextHeight("Ag");
   g_cv.TextOut(8,(HDR-th)/2,"Economic News",ColorToARGB(C'235,238,242'),TA_LEFT|TA_TOP);
   int bw=HDR+8;
   DrawButton(g_pw-bw+2,3,g_pw-3,HDR-4,g_col ? "+" : "-",false,6);
   if(!g_col)
   {
      DrawButton(g_pw-2*bw+2,3,g_pw-bw-1,HDR-4,"A+",false,5);
      DrawButton(g_pw-3*bw+2,3,g_pw-2*bw-1,HDR-4,"A-",false,4);
   }
   if(g_col){ g_cv.Update(); return; }

   // toolbar (wraps onto a second row if the panel is narrow)
   g_cv.FontSet("Segoe UI",g_fs,FW_NORMAL);
   string bt[5];
   bool   act[5];
   int    bid[5];
   int    nb=0;
   if(g_selOn){ bt[nb]="Reset"; act[nb]=true; bid[nb]=7; nb++; }
   bt[nb]=g_showLabels ? "Labels: On" : "Labels: Off"; act[nb]=g_showLabels; bid[nb]=1; nb++;
   bt[nb]=g_allImp ? "Impact: All" : "Impact: High";   act[nb]=g_allImp;     bid[nb]=2; nb++;
   bt[nb]="Group: "+GroupName(g_group);                act[nb]=(g_group!=0); bid[nb]=3; nb++;
   if(!g_tester){ bt[nb]=(g_source==SRC_FF ? "Source: FF" : "Source: MT5"); act[nb]=(g_source==SRC_FF); bid[nb]=8; nb++; }

   int brow[5], bx0[5], bw0[5];
   int cx=6, rows=1;
   for(int b=0;b<nb;b++)
   {
      int w=g_cv.TextWidth(bt[b])+16;
      if(cx+w>g_pw-4 && cx>6){ rows++; cx=6; }
      brow[b]=rows-1; bx0[b]=cx; bw0[b]=w;
      cx+=w+5;
   }
   g_tbH=rows*TB;
   g_cv.FillRectangle(1,HDR,g_pw-2,HDR+g_tbH-1,ColorToARGB(C'30,34,43'));
   for(int b=0;b<nb;b++)
   {
      int by=HDR+brow[b]*TB;
      DrawButton(bx0[b],by+3,bx0[b]+bw0[b],by+TB-4,bt[b],act[b],bid[b]);
   }

   int top=HDR+g_tbH, bottom=H-FTR;
   int vis=(bottom-top)/RH;
   int total=ArraySize(g_rows);
   int maxS=MathMax(0,total-vis);
   if(g_scroll>maxS) g_scroll=maxS;
   if(g_scroll<0) g_scroll=0;

   datetime now=TimeTradeServer();
   long doff=0;
   if(InpTimeMode==TM_LOCAL)
      doff=(long)MathRound((double)(TimeLocal()-now)/60.0)*60;

   double sc=(double)g_fs/13.0;
   int xTime=10;
   int xRel=xTime+(int)(92*sc);
   int xCur=xRel+(int)(88*sc);
   int xTitle=xCur+(int)(46*sc);
   uint cTxt=ColorToARGB(C'222,226,232'), cDim=ColorToARGB(C'128,136,150');

   for(int r=0;r<vis && g_scroll+r<total;r++)
   {
      SRow row=g_rows[g_scroll+r];
      int y=top+r*RH;
      if(row.kind==0)
      {
         g_cv.FillRectangle(1,y,g_pw-2,y+RH-1,ColorToARGB(C'31,35,44'));
         g_cv.FontSet("Segoe UI",g_fs-1,FW_BOLD);
         g_cv.TextOut(8,y+4,row.txt,cDim,TA_LEFT|TA_TOP);
         continue;
      }
      if(row.kind==2)
      {
         g_cv.FontSet("Segoe UI",g_fs,FW_NORMAL);
         g_cv.TextOut(14,y+4,row.txt,cDim,TA_LEFT|TA_TOP);
         continue;
      }
      if(row.ev<0 || row.ev>=ArraySize(g_ev)) continue;
      SNews e=g_ev[row.ev];
      long diff=(long)e.t-(long)now;
      bool past=(diff<0);
      if(!past && diff<=1800) g_cv.FillRectangle(1,y,g_pw-2,y+RH-1,ColorToARGB(C'52,44,22'));
      if(g_selOn && e.cur==g_selCur && e.title==g_selTitle) g_cv.FillRectangle(1,y,g_pw-2,y+RH-1,ColorToARGB(C'30,58,92'));
      g_cv.FillRectangle(2,y+2,5,y+RH-3,ColorToARGB(ImpColor(e.imp)));

      string ts=TimeToString((datetime)((long)e.t+doff),TIME_DATE|TIME_MINUTES);
      ts=StringSubstr(ts,5,11);
      uint tc=past ? cDim : cTxt;
      g_cv.FontSet("Segoe UI",g_fs,FW_NORMAL);
      g_cv.TextOut(xTime,y+4,ts,tc,TA_LEFT|TA_TOP);
      g_cv.TextOut(xRel,y+4,RelTime(diff),past ? cDim : ColorToARGB(ImpColor(e.imp)),TA_LEFT|TA_TOP);
      g_cv.FontSet("Segoe UI",g_fs,FW_BOLD);
      g_cv.TextOut(xCur,y+4,e.cur,tc,TA_LEFT|TA_TOP);

      string ex="";
      if(g_pw>=520)
      {
         if(ActVal(e)!="") ex+="A "+ActVal(e)+"  ";
         if(e.fc!="") ex+="F "+e.fc+"  ";
         if(e.pv!="") ex+="P "+e.pv;
      }
      g_cv.FontSet("Segoe UI",g_fs,FW_NORMAL);
      int exW=(ex=="") ? 0 : g_cv.TextWidth(ex)+10;
      if(ex!="") g_cv.TextOut(g_pw-20,y+4,ex,cDim,TA_RIGHT|TA_TOP);
      g_cv.TextOut(xTitle,y+4,FitText(e.title,g_pw-xTitle-exW-24),tc,TA_LEFT|TA_TOP);
   }

   // scrollbar (track + draggable thumb)
   if(total>vis)
   {
      int trackH=bottom-top;
      int thumbH=MathMax(24,trackH*vis/total);
      int thumbY=top+(trackH-thumbH)*g_scroll/MathMax(1,maxS);
      g_cv.FillRectangle(g_pw-12,top,g_pw-3,bottom-1,ColorToARGB(C'34,38,48'));
      g_cv.FillRectangle(g_pw-11,thumbY,g_pw-4,thumbY+thumbH,ColorToARGB(g_drag==3 ? C'160,170,190' : C'104,114,132'));
      g_sbOn=true; g_sbX1=g_pw-14; g_sbTop=top; g_sbTrack=trackH;
      g_sbThumbY=thumbY; g_sbThumbH=thumbH; g_sbMax=maxS;
   }

   // footer
   g_cv.FillRectangle(1,bottom,g_pw-2,H-2,ColorToARGB(C'31,35,44'));
   g_cv.FontSet("Segoe UI",g_fs-1,FW_NORMAL);
   string ft=g_status+"  |  "+(InpTimeMode==TM_LOCAL ? "local time" : "server time");
   if(g_selOn) ft="Chart shows only: "+g_selCur+" "+g_selTitle;
   g_cv.TextOut(8,bottom+3,FitText(ft,g_pw-34),cDim,TA_LEFT|TA_TOP);
   g_cv.FillTriangle(g_pw-3,H-3,g_pw-3,H-13,g_pw-13,H-3,ColorToARGB(C'120,128,144'));
   g_cv.Update();
}

//+------------------------------------------------------------------+
//| state persistence                                                |
//+------------------------------------------------------------------+
int StartSig()
{
   return (int)InpSource*1000+(int)InpStartGroup*100+(InpStartAllImp ? 10 : 0)+(InpStartLabels ? 1 : 0);
}

void SavePanel()
{
   GlobalVariableSet("NLN_PX",g_px);
   GlobalVariableSet("NLN_PY",g_py);
   GlobalVariableSet("NLN_PW",g_pw);
   GlobalVariableSet("NLN_PH",g_ph);
   GlobalVariableSet("NLN_COL",g_col ? 1 : 0);
   GlobalVariableSet("NLN_FZ",g_fz);
   GlobalVariableSet("NLN_LBL",g_showLabels ? 1 : 0);
   GlobalVariableSet("NLN_ALL",g_allImp ? 1 : 0);
   GlobalVariableSet("NLN_GRP",g_group);
   GlobalVariableSet("NLN_SRC",(int)g_source);
   GlobalVariableSet("NLN_SIG",StartSig());
}

void LoadState()
{
   g_fz=0;
   g_showLabels=InpStartLabels;
   g_allImp=InpStartAllImp;
   g_group=(int)InpStartGroup;
   g_source=InpSource;
   g_px=InpPanelX; g_py=InpPanelY; g_pw=InpPanelW; g_ph=InpPanelH; g_col=false;
   if(!InpResetState && GlobalVariableCheck("NLN_PX"))
   {
      g_px=(int)GlobalVariableGet("NLN_PX");
      g_py=(int)GlobalVariableGet("NLN_PY");
      g_pw=(int)GlobalVariableGet("NLN_PW");
      g_ph=(int)GlobalVariableGet("NLN_PH");
      g_col=(GlobalVariableGet("NLN_COL")>0.5);
      if(GlobalVariableCheck("NLN_FZ"))  g_fz=(int)GlobalVariableGet("NLN_FZ");
      // remembered button states are used only if the start-up inputs were not changed since last run
      bool same=GlobalVariableCheck("NLN_SIG") && (int)GlobalVariableGet("NLN_SIG")==StartSig();
      if(same)
      {
         if(GlobalVariableCheck("NLN_LBL")) g_showLabels=(GlobalVariableGet("NLN_LBL")>0.5);
         if(GlobalVariableCheck("NLN_ALL")) g_allImp=(GlobalVariableGet("NLN_ALL")>0.5);
         if(GlobalVariableCheck("NLN_GRP")) g_group=(int)GlobalVariableGet("NLN_GRP");
         if(GlobalVariableCheck("NLN_SRC")) g_source=(GlobalVariableGet("NLN_SRC")>0.5) ? SRC_FF : SRC_MT5;
      }
   }
   g_fz=MathMax(-3,MathMin(10,g_fz));
   if(g_group<0 || g_group>4) g_group=0;
   SetMetrics();
   int cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   int ch=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   int minH=HDR+TB+2*RH+FTR;
   g_pw=MathMax(MINW,MathMin(g_pw,MathMax(MINW,cw)));
   g_ph=MathMax(minH,MathMin(g_ph,MathMax(minH,ch)));
   g_px=MathMax(0,MathMin(g_px,MathMax(0,cw-g_pw)));
   g_py=MathMax(0,MathMin(g_py,MathMax(0,ch-HDR)));
}

//+------------------------------------------------------------------+
//| button actions                                                   |
//+------------------------------------------------------------------+
void FilterChanged()
{
   SavePanel();
   g_scroll=0;
   BuildRows();
   g_forceRebuild=true;
   HandleChange();
   DrawPanel();
   ChartRedraw(0);
}

void FontChanged()
{
   SetMetrics();
   int minH=HDR+TB+2*RH+FTR;
   if(g_ph<minH) g_ph=minH;
   g_cv.Resize(g_pw,g_col ? HDR : g_ph);
   SavePanel();
   DrawPanel();
   ChartRedraw(0);
}

void SwitchSource()
{
   if(g_tester) return;
   g_source=(g_source==SRC_MT5) ? SRC_FF : SRC_MT5;
   g_selOn=false;
   ArrayResize(g_ev,0);
   g_loaded=false; g_loadFrom=0; g_loadTo=0; g_loadWall=0;
   g_scroll=0;
   g_status=(g_source==SRC_FF ? "Forex Factory feed" : "MT5 calendar")+": loading...";
   BuildRows();
   DrawPanel();
   ChartRedraw(0);          // show "loading" state before the (possibly blocking) download
   g_forceRebuild=true;
   HandleChange();          // loads the new source and redraws the lines
   BuildRows();
   SavePanel();
   DrawPanel();
   ChartRedraw(0);
}

void SelectionChanged()
{
   g_forceRebuild=true;
   HandleChange();
   DrawPanel();
   ChartRedraw(0);
}

void DoButton(const int id)
{
   switch(id)
   {
      case 1: g_showLabels=!g_showLabels; FilterChanged(); break;
      case 2: g_allImp=!g_allImp; g_selOn=false; FilterChanged(); break;
      case 3: g_group=(g_group+1)%5; ApplyGroup(); g_selOn=false; FilterChanged(); break;
      case 4: if(g_fz>-3){ g_fz--; FontChanged(); } break;
      case 5: if(g_fz<10){ g_fz++; FontChanged(); } break;
      case 7: g_selOn=false; SelectionChanged(); break;
      case 8: SwitchSource(); break;
      case 6:
         g_col=!g_col;
         g_cv.Resize(g_pw,g_col ? HDR : g_ph);
         SavePanel();
         DrawPanel();
         ChartRedraw(0);
         break;
   }
}

void OnMouse(const int x,const int y,const uint st)
{
   bool down=((st&1)!=0);
   int H=g_col ? HDR : g_ph;
   bool inside=(x>=g_px && x<g_px+g_pw && y>=g_py && y<g_py+H);
   int cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   int ch=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);

   if(down && !g_prevDown && inside)
   {
      int rx=x-g_px, ry=y-g_py;
      int hit=0;
      for(int b=0;b<ArraySize(g_btn);b++)
         if(rx>=g_btn[b].x1 && rx<=g_btn[b].x2 && ry>=g_btn[b].y1 && ry<=g_btn[b].y2){ hit=g_btn[b].id; break; }
      if(hit>0) DoButton(hit);
      else if(g_sbOn && rx>=g_sbX1 && ry>=g_sbTop && ry<g_sbTop+g_sbTrack)
      {
         if(!(ry>=g_sbThumbY && ry<=g_sbThumbY+g_sbThumbH))
         {
            // click on the track: centre the thumb on the click
            int range=MathMax(1,g_sbTrack-g_sbThumbH);
            int pos=ry-g_sbThumbH/2-g_sbTop;
            g_scroll=MathMax(0,MathMin(g_sbMax,(int)MathRound((double)pos*g_sbMax/range)));
            DrawPanel();
            ChartRedraw(0);
         }
         g_drag=3; g_dy=y; g_sbStart=g_scroll;
      }
      else if(!g_col && ry>=HDR+g_tbH && ry<g_ph-FTR)
      {
         int idx=g_scroll+(ry-HDR-g_tbH)/RH;
         if(idx>=0 && idx<ArraySize(g_rows) && g_rows[idx].kind==1)
         {
            int evi=g_rows[idx].ev;
            if(evi>=0 && evi<ArraySize(g_ev))
            {
               if(g_selOn && g_selCur==g_ev[evi].cur && g_selTitle==g_ev[evi].title) g_selOn=false;
               else { g_selOn=true; g_selCur=g_ev[evi].cur; g_selTitle=g_ev[evi].title; }
               SelectionChanged();
            }
         }
      }
      else if(!g_col && rx>=g_pw-GRIP && ry>=H-GRIP)
      { g_drag=2; g_dx=x; g_dy=y; g_sw=g_pw; g_sh=g_ph; }
      else if(ry<HDR)
      { g_drag=1; g_dx=x-g_px; g_dy=y-g_py; }
   }

   if(down && g_drag==1)
   {
      g_px=MathMax(0,MathMin(x-g_dx,MathMax(0,cw-g_pw)));
      g_py=MathMax(0,MathMin(y-g_dy,MathMax(0,ch-HDR)));
      ObjectSetInteger(0,PFX+"PANEL",OBJPROP_XDISTANCE,g_px);
      ObjectSetInteger(0,PFX+"PANEL",OBJPROP_YDISTANCE,g_py);
      ChartRedraw(0);
   }
   else if(down && g_drag==3)
   {
      int range=MathMax(1,g_sbTrack-g_sbThumbH);
      int ns=g_sbStart+(int)MathRound((double)(y-g_dy)*g_sbMax/range);
      ns=MathMax(0,MathMin(g_sbMax,ns));
      if(ns!=g_scroll)
      {
         g_scroll=ns;
         DrawPanel();
         ChartRedraw(0);
      }
   }
   else if(down && g_drag==2)
   {
      int minH=HDR+TB+2*RH+FTR;
      g_pw=MathMax(MINW,MathMin(g_sw+(x-g_dx),MathMax(MINW,cw-g_px)));
      g_ph=MathMax(minH,MathMin(g_sh+(y-g_dy),MathMax(minH,ch-g_py)));
      g_cv.Resize(g_pw,g_ph);
      DrawPanel();
      ChartRedraw(0);
   }
   if(!down && g_drag!=0)
   {
      bool wasSb=(g_drag==3);
      g_drag=0;
      if(wasSb){ DrawPanel(); ChartRedraw(0); }
      else SavePanel();
   }
   g_prevDown=down;

   H=g_col ? HDR : g_ph;
   inside=(x>=g_px && x<g_px+g_pw && y>=g_py && y<g_py+H);
   bool lock=(inside || g_drag!=0);
   if(lock!=g_scrollLocked)
   {
      ChartSetInteger(0,CHART_MOUSE_SCROLL,!lock);
      g_scrollLocked=lock;
   }
}

//+------------------------------------------------------------------+
//| init / deinit / events                                           |
//+------------------------------------------------------------------+
int OnInit()
{
   g_tester=(bool)MQLInfoInteger(MQL_TESTER);
   g_visual=(bool)MQLInfoInteger(MQL_VISUAL_MODE);
   g_panelOn=InpShowPanel;
   BuildCcyList();
   g_srvOff=(int)MathRound((double)(TimeTradeServer()-TimeGMT())/900.0)*900;
   LoadState();
   ApplyGroup();
   if(g_tester && !g_visual)
   {
      // non-visual backtest: nothing to draw - run quietly (safe for Market validation)
      g_panelOn=false;
      Print("NewsLines: non-visual tester - display disabled. Use visual mode to see news lines.");
      return INIT_SUCCEEDED;
   }

   if(g_panelOn)
   {
      if(!g_cv.CreateBitmapLabel(0,0,PFX+"PANEL",g_px,g_py,g_pw,g_col ? HDR : g_ph,COLOR_FORMAT_ARGB_NORMALIZE))
      {
         Print("NewsLines: cannot create panel canvas - panel disabled");
         g_panelOn=false;
      }
      ObjectSetInteger(0,PFX+"PANEL",OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,PFX+"PANEL",OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,PFX+"PANEL",OBJPROP_BACK,false);
      ObjectSetInteger(0,PFX+"PANEL",OBJPROP_ZORDER,10);
      ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
      ChartSetInteger(0,CHART_EVENT_MOUSE_WHEEL,true);
      DrawPanel();
   }
   g_firstRun=true;
   g_loadWall=TimeLocal();
   EventSetMillisecondTimer(g_tester ? 500 : 250);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   ChartSetInteger(0,CHART_MOUSE_SCROLL,true);
   if(g_panelOn){ SavePanel(); g_cv.Destroy(); }
   ObjectsDeleteAll(0,PFX+"L_");
   ObjectsDeleteAll(0,PFX+"T_");
   ChartRedraw(0);
}

void OnTick() {}

void OnTimer()
{
   if(g_firstRun)
   {
      g_firstRun=false;
      g_loadWall=0;
      g_forceRebuild=true;
      HandleChange();
      g_loadWall=TimeLocal();
      DrawPanel();
      ChartRedraw(0);
      return;
   }

   if(g_chgPending && GetTickCount()-g_chgTick>350)
   {
      g_chgPending=false;
      HandleChange();
   }

   long refSec=(long)MathMax(InpRefreshMin,(g_source==SRC_FF ? 5 : 1))*60;
   if(!g_tester && ((long)TimeLocal()-(long)g_loadWall>=refSec || (!g_loaded && g_source==SRC_FF && (long)TimeLocal()-(long)g_loadWall>=120)))
   {
      if(g_loaded) ReloadAll(); else g_forceRebuild=true;
      HandleChange();
      DrawPanel();
   }

   if(g_tester && (long)TimeCurrent()-(long)g_tstRebuild>=3600)
   {
      g_tstRebuild=TimeCurrent();      // refresh lines hourly so 'actual' values appear after release
      g_forceRebuild=true;
      HandleChange();
   }

   if(g_panelOn && g_drag==0 && (long)TimeLocal()-(long)g_lastPanelWall>=15)
   {
      g_lastPanelWall=TimeLocal();
      if(g_loaded) BuildRows();
      DrawPanel();
      ChartRedraw(0);
   }
}

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(id==CHARTEVENT_MOUSE_MOVE)
   {
      if(g_panelOn) OnMouse((int)lparam,(int)dparam,(uint)StringToInteger(sparam));
   }
   else if(id==CHARTEVENT_MOUSE_WHEEL)
   {
      if(!g_panelOn || g_col) return;
      int x=(int)(short)lparam;
      int y=(int)(short)(lparam>>16);
      int delta=(int)dparam;
      if(x>=g_px && x<g_px+g_pw && y>=g_py && y<g_py+g_ph)
      {
         g_scroll+= (delta<0 ? 2 : -2);
         DrawPanel();
         ChartRedraw(0);
      }
   }
   else if(id==CHARTEVENT_CHART_CHANGE)
   {
      g_chgPending=true;
      g_chgTick=GetTickCount();
   }
}
//+------------------------------------------------------------------+
