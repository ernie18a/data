//+------------------------------------------------------------------+
//|                                          SpreadProfileByHour.mq5 |
//|                                   Copyright 2026, Quoc Dat Quach |
//|                           https://www.mql5.com/en/users/datquach |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Quoc Dat Quach"
#property link        "https://www.mql5.com/en/users/datquach"
#property version     "1.00"
#property description "Spread distribution per server hour, built from the broker's own tick history."
#property description "Bars show the median spread, the lighter cap reaches the 90th percentile."
#property description "Enter your stop size to see how much of 1R the spread takes in every hour."
#property indicator_separate_window
#property indicator_buffers 0
#property indicator_plots   0

#include <Canvas\Canvas.mqh>

//--- how ticks are weighted in the distribution
enum ENUM_SPH_SAMPLE
  {
   SPH_SAMPLE_TICKS=0, // Tick count (every quote counts once)
   SPH_SAMPLE_TIME =1  // Time-weighted (time until the next quote, max 60 s)
  };
//--- weekday filter; values match MqlDateTime::day_of_week
enum ENUM_SPH_WEEKDAY
  {
   SPH_DAY_ALL=0,      // All days
   SPH_DAY_MON=1,      // Monday
   SPH_DAY_TUE=2,      // Tuesday
   SPH_DAY_WED=3,      // Wednesday
   SPH_DAY_THU=4,      // Thursday
   SPH_DAY_FRI=5       // Friday
  };

//--- inputs
input group "Data"
input int              InpDays         = 20;               // History depth, calendar days (today excluded)
input ENUM_SPH_SAMPLE  InpSampleMode   = SPH_SAMPLE_TICKS; // Sampling
input ENUM_SPH_WEEKDAY InpWeekday      = SPH_DAY_ALL;      // Weekday filter
input int              InpMaxBin       = 5000;             // Histogram range, points (wider spreads = overflow)
input int              InpMinTicks     = 100;              // Minimum ticks for an hour to be shown
input group "Cost view"
input int              InpStopPoints   = 0;                // Stop size, points (0 = off)
input group "Display"
input int              InpWindowHeight = 240;              // Window height at 100% scaling, px (0 = resizable)
input color            InpColorBack    = clrNONE;          // Background (None = chart background)
input color            InpColorBar     = C'52,128,235';    // Median bar
input color            InpColorP90     = clrNONE;          // 90th percentile cap (None = lighter bar color)
input color            InpColorNow     = C'255,153,0';     // Current hour
input color            InpColorLive    = C'235,64,52';     // Live spread line
input color            InpColorText    = clrNONE;          // Text (None = automatic)
input color            InpColorGrid    = clrNONE;          // Grid (None = automatic)
input int              InpFontSize     = 9;                // Font size, pt
input group "Export"
input bool             InpExportCsv    = false;            // Save per-hour statistics to MQL5\Files (CSV)

//--- constants
#define SPH_HOURS         24
#define SPH_DAY_SECONDS   86400
#define SPH_HOUR_MSC      3600000
#define SPH_TIME_CAP_MSC  60000   // a quote older than this no longer represents the market
#define SPH_MAX_ATTEMPTS  6       // CopyTicksRange attempts per day while history synchronizes
#define SPH_STOP_FAILED   3       // trading days in a row with M1 bars but no ticks that end the load
#define SPH_STOP_IDLE     10      // trading days in a row with neither ticks nor bars (longer than any holiday)
#define SPH_RANK_HOURS    3       // hours listed as cheapest and as most expensive
#define SPH_RETRY_MSC     500
#define SPH_CONFIRM_MSC   5000    // pause before the days that would end the load are read a second time
#define SPH_TIMER_LOAD    50
#define SPH_TIMER_IDLE    1000
#define SPH_REDRAW_MSC    250
#define SPH_FONT          "Arial"

//--- program state
enum ENUM_SPH_STATE
  {
   SPH_STATE_LOADING,
   SPH_STATE_READY,
   SPH_STATE_NODATA
  };

//+------------------------------------------------------------------+
//| Statistics of one server hour                                    |
//+------------------------------------------------------------------+
struct SHourStats
  {
   bool              valid;      // enough ticks to be shown
   long              ticks;
   int               median;     // points; InpMaxBin+1 means "above the histogram range"
   int               p90;
   double            mean;
   int               max;        // largest spread inside the histogram range
   long              overflow;   // ticks wider than InpMaxBin
  };

//+------------------------------------------------------------------+
//| One piece of header text                                         |
//+------------------------------------------------------------------+
struct STextSeg
  {
   string            text;
   color             clr;
   color             swatch;     // clrNONE = no color box in front of the text
   bool              bold;
  };

//--- configuration (inputs after validation)
int      g_cfgDays;
int      g_cfgMaxBin;
int      g_cfgMinTicks;
int      g_cfgStop;
int      g_cfgFont;
int      g_bins;                 // g_cfgMaxBin+2: spreads 0..g_cfgMaxBin plus one overflow bin

//--- histograms, weight per hour and spread in points
long     g_hist[];
long     g_weight[SPH_HOURS];
long     g_ticks[SPH_HOURS];
double   g_sum[SPH_HOURS];
int      g_maxSpread[SPH_HOURS];
long     g_overflow[SPH_HOURS];
SHourStats g_stats[SPH_HOURS];

//--- loading
int      g_state=SPH_STATE_LOADING;
datetime g_anchorDay=0;          // server day the profile belongs to (excluded from the data)
datetime g_dayList[];            // calendar days to read, newest first
int      g_dayPos=0;
int      g_attempt=0;
ulong    g_nextTry=0;
int      g_daysUsed=0;
int      g_daysPartial=0;
int      g_daysEmpty=0;
int      g_daysFailed=0;
int      g_daysIdle=0;           // trading days with neither ticks nor M1 bars
int      g_failStreak=0;         // trading days in a row with M1 bars but no ticks
int      g_idleStreak=0;         // trading days in a row with neither ticks nor M1 bars
int      g_streakPos=0;          // first day of the current run of days without ticks
int      g_markEmpty=0;          // day counters at the start of that run
int      g_markFailed=0;
int      g_markIdle=0;
bool     g_confirm=false;        // the stop rule was met once, the days are being read a second time
bool     g_coldRun=false;        // the terminal was seen downloading ticks during this load
int      g_prevN=-1;             // tick count of the current day at the previous attempt
bool     g_stopped=false;        // load ended early: the tick history does not reach further back
datetime g_oldestUsed=0;         // oldest and newest day that contributed ticks
datetime g_newestUsed=0;
long     g_totalTicks=0;
ulong    g_loadStart=0;
double   g_loadSeconds=0.0;

//--- drawing
CCanvas  g_canvas;
string   g_objName="";
int      g_subwin=-1;
double   g_scale=1.0;
ulong    g_lastDraw=0;
int      g_drawnLive=-1;
int      g_drawnHour=-1;
bool     g_dirty=true;           // the window still needs a full redraw
color    g_clrBack,g_clrText,g_clrMuted,g_clrGrid,g_clrBar,g_clrP90;
color    g_clrNow,g_clrNowP90,g_clrNowColumn,g_clrLive;
color    g_chartBack=clrNONE;    // chart background the colors were derived from

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(_Point<=0.0)
     {
      PrintFormat("Spread Profile: %s has no valid point size",_Symbol);
      return(INIT_FAILED);
     }
//--- validate inputs without refusing to start
   g_cfgDays    =(int)MathMax(1,MathMin(365,InpDays));
   g_cfgMaxBin  =(int)MathMax(10,MathMin(100000,InpMaxBin));
   g_cfgMinTicks=(int)MathMax(1,InpMinTicks);
   g_cfgStop    =(int)MathMax(0,InpStopPoints);
   g_cfgFont    =(int)MathMax(6,MathMin(24,InpFontSize));
   if(g_cfgDays!=InpDays || g_cfgMaxBin!=InpMaxBin || g_cfgStop!=InpStopPoints)
      PrintFormat("Spread Profile: inputs adjusted to days=%d, histogram range=%d, stop=%d",
                  g_cfgDays,g_cfgMaxBin,g_cfgStop);
   g_bins=g_cfgMaxBin+2;
   if(ArrayResize(g_hist,SPH_HOURS*g_bins)<0)
     {
      Print("Spread Profile: not enough memory for the histograms");
      return(INIT_FAILED);
     }
//--- chart window settings
   IndicatorSetString(INDICATOR_SHORTNAME,"Spread Profile by Hour");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   g_scale=MathMax(1.0,TerminalInfoInteger(TERMINAL_SCREEN_DPI)/96.0);
   if(InpWindowHeight>0)
      IndicatorSetInteger(INDICATOR_HEIGHT,(int)MathRound(InpWindowHeight*g_scale));
//--- unique object name, so several copies can live on one chart
   g_objName=StringFormat("SPH_%I64u_%d",GetMicrosecondCount(),MathRand());
   g_subwin=-1;
   g_dirty=true;
   g_canvas.Destroy();
//--- state is reset explicitly: globals may survive a re-initialization
   g_anchorDay=0;
   StartProfile();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   g_canvas.Destroy();
   ArrayFree(g_hist);
   ArrayFree(g_dayList);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   if(g_state!=SPH_STATE_LOADING)
     {
      if(IsNewServerDay())
        {
         StartProfile();
         Render();
        }
      else
         RenderIfChanged();
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer: loads one day per call, later watches for a new day       |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(g_state==SPH_STATE_LOADING)
     {
      LoadStep();
      Render();
      return;
     }
   if(IsNewServerDay())
     {
      StartProfile();
      Render();
      return;
     }
//--- a chart that was never displayed has no size yet: keep trying once a second;
//--- a canvas deleted by another program or a template is created again
   if(g_dirty || CanvasSizeChanged() || ObjectFind(0,g_objName)<0)
      Render();
   else
      RenderIfChanged();
  }
//+------------------------------------------------------------------+
//| Chart events: follow window size and color scheme                |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- this event also fires on scrolling, so redraw only what really changed
   if(id==CHARTEVENT_CHART_CHANGE)
      if(g_dirty || CanvasSizeChanged() || (color)ChartGetInteger(0,CHART_COLOR_BACKGROUND)!=g_chartBack)
         Render();
  }
//+------------------------------------------------------------------+
//| Start of a server day                                            |
//+------------------------------------------------------------------+
datetime DayStart(const datetime t)
  {
   return(t-(datetime)((long)t%SPH_DAY_SECONDS));
  }
//+------------------------------------------------------------------+
//| Day of week (0 = Sunday)                                         |
//+------------------------------------------------------------------+
int WeekdayOf(const datetime t)
  {
   MqlDateTime dt;
   TimeToStruct(t,dt);
   return(dt.day_of_week);
  }
//+------------------------------------------------------------------+
//| True when the server day moved on since the profile was built    |
//+------------------------------------------------------------------+
bool IsNewServerDay(void)
  {
   datetime now=TimeTradeServer();
   return(now>0 && g_anchorDay>0 && DayStart(now)!=g_anchorDay);
  }
//+------------------------------------------------------------------+
//| Reset histograms and plan the days to read                       |
//+------------------------------------------------------------------+
void StartProfile(void)
  {
   ArrayInitialize(g_hist,0);
   ArrayInitialize(g_weight,0);
   ArrayInitialize(g_ticks,0);
   ArrayInitialize(g_sum,0.0);
   ArrayInitialize(g_maxSpread,0);
   ArrayInitialize(g_overflow,0);
   for(int h=0; h<SPH_HOURS; h++)
      ZeroMemory(g_stats[h]);
   g_dayPos=0;
   g_attempt=0;
   g_nextTry=0;
   g_daysUsed=0;
   g_daysPartial=0;
   g_daysEmpty=0;
   g_daysFailed=0;
   g_daysIdle=0;
   g_failStreak=0;
   g_idleStreak=0;
   g_streakPos=0;
   g_markEmpty=0;
   g_markFailed=0;
   g_markIdle=0;
   g_confirm=false;
   g_coldRun=false;
   g_prevN=-1;
   g_stopped=false;
   g_oldestUsed=0;
   g_newestUsed=0;
   g_totalTicks=0;
   g_loadSeconds=0.0;
   g_loadStart=GetTickCount64();
   g_state=SPH_STATE_LOADING;
   EventKillTimer();
   EventSetMillisecondTimer(SPH_TIMER_LOAD);
   PlanDays();
  }
//+------------------------------------------------------------------+
//| Lists the calendar days to read, newest first                    |
//+------------------------------------------------------------------+
void PlanDays(void)
  {
   ArrayResize(g_dayList,0);
//--- server time is unknown until the terminal has connected; the timer retries
   datetime now=TimeTradeServer();
   if(now<=0)
     {
      g_anchorDay=0;
      return;
     }
   g_anchorDay=DayStart(now);
//--- today is excluded: a half-finished day would shift the profile during the session;
//--- newest first, so a tick history shorter than the depth ends the load at its start
   for(int k=1; k<=g_cfgDays; k++)
     {
      datetime day=g_anchorDay-(datetime)((long)k*SPH_DAY_SECONDS);
      if(InpWeekday!=SPH_DAY_ALL && WeekdayOf(day)!=(int)InpWeekday)
         continue;
      int n=ArraySize(g_dayList);
      ArrayResize(g_dayList,n+1,32);
      g_dayList[n]=day;
     }
  }
//+------------------------------------------------------------------+
//| Reads at most one day of ticks; skips closed days quickly        |
//+------------------------------------------------------------------+
void LoadStep(void)
  {
   if(g_anchorDay==0)
     {
      PlanDays();
      if(g_anchorDay==0)
         return;
     }
   if(GetTickCount64()<g_nextTry)
      return;
//--- closed days cost almost nothing, so several may be passed in one call
   int budget=8;
   while(g_dayPos<ArraySize(g_dayList) && budget-- > 0)
     {
      //--- remember where a run of days without ticks starts, so that it can be read again
      if(g_failStreak==0 && g_idleStreak==0)
        {
         g_streakPos =g_dayPos;
         g_markEmpty =g_daysEmpty;
         g_markFailed=g_daysFailed;
         g_markIdle  =g_daysIdle;
        }
      int result=ProcessDay(g_dayList[g_dayPos]);
      if(result<0)
        {
         g_nextTry=GetTickCount64()+SPH_RETRY_MSC;
         return;
        }
      g_dayPos++;
      g_attempt=0;
      g_prevN=-1;
      //--- several trading days in a row without ticks: the tick history ends here,
      //--- but only if a second reading of those days gives the same result
      if(g_failStreak>=SPH_STOP_FAILED || g_idleStreak>=SPH_STOP_IDLE)
        {
         if(g_confirm)
           {
            g_stopped=true;
            break;
           }
         ReadStreakAgain();
         return;
        }
      if(result>0)
         break;          // one real day of ticks per timer call keeps the chart responsive
     }
   if(g_stopped || g_dayPos>=ArraySize(g_dayList))
      FinishProfile();
  }
//+------------------------------------------------------------------+
//| The stop rule was met for the first time. On a first run the     |
//| terminal may still be downloading these days: wait, then read    |
//| the run of days without ticks again with the full retry count    |
//+------------------------------------------------------------------+
void ReadStreakAgain(void)
  {
   g_confirm   =true;
   g_coldRun   =true;
//--- undo what the run of days without ticks added to the counters
   g_dayPos    =g_streakPos;
   g_daysEmpty =g_markEmpty;
   g_daysFailed=g_markFailed;
   g_daysIdle  =g_markIdle;
   g_failStreak=0;
   g_idleStreak=0;
   g_attempt   =0;
   g_prevN     =-1;
   g_nextTry   =GetTickCount64()+SPH_CONFIRM_MSC;
  }
//+------------------------------------------------------------------+
//| Reads one day. Returns 1 = ticks used, 0 = nothing to use,       |
//| -1 = retry later (history is still synchronizing)                |
//+------------------------------------------------------------------+
int ProcessDay(const datetime day)
  {
   ulong    fromMsc=(ulong)day*1000;
   ulong    toMsc  =((ulong)day+SPH_DAY_SECONDS)*1000-1;
   MqlTick  ticks[];
   g_attempt++;
//--- right after a day without ticks the next one most likely has none either: stop waiting long;
//--- a second reading of the same days gets the full time
   int  attempts  =(g_failStreak>0 && !g_confirm) ? 2 : SPH_MAX_ATTEMPTS;
   bool lastChance=(g_attempt>=attempts);
   int  n=CopyTicksRange(_Symbol,ticks,COPY_TICKS_INFO,fromMsc,toMsc);
//--- a failed call, or a count that changed since the previous attempt, means a download
   bool stable=(g_attempt>1 && n==g_prevN);
   if(n<0 || (g_attempt>1 && n>0 && !stable))
      g_coldRun=true;
   g_prevN=n;
   if(n<=0)
     {
      ArrayFree(ticks);
      //--- no M1 bars either: the market was closed that day; without a trade session
      //--- on this weekday there is nothing to wait for, otherwise the bars get one retry
      if(n==0 && CountMinuteBars(day)==0)
        {
         bool session=HasTradeSession(day);
         if(session && g_attempt<2)
            return(-1);
         g_daysEmpty++;
         //--- a trading day without any data: a holiday, or the history ends here
         if(session)
           {
            g_daysIdle++;
            g_idleStreak++;
           }
         return(0);
        }
      //--- M1 bars without ticks: the ticks may still be on their way
      if(!lastChance)
        {
         g_coldRun=true;
         return(-1);
        }
      g_daysFailed++;
      g_failStreak++;
      return(0);
     }
//--- ticks may arrive only partly while the terminal is still downloading them
   bool complete=CoversMinuteBars(day,ticks,n,stable);
   if(!complete && !lastChance)
     {
      g_coldRun=true;
      ArrayFree(ticks);
      return(-1);
     }
   if(!complete)
      g_daysPartial++;
   Accumulate(ticks,n,(long)toMsc+1);
   ArrayFree(ticks);
//--- a day with ticks ends a run of days without ticks, and with it a second reading
   g_failStreak=0;
   g_idleStreak=0;
   g_confirm=false;
//--- remember the range that really contributed ticks
   g_daysUsed++;
   if(g_newestUsed==0 || day>g_newestUsed)
      g_newestUsed=day;
   if(g_oldestUsed==0 || day<g_oldestUsed)
      g_oldestUsed=day;
   return(1);
  }
//+------------------------------------------------------------------+
//| True when the symbol has a trade session on the day's weekday    |
//+------------------------------------------------------------------+
bool HasTradeSession(const datetime day)
  {
   datetime from,to;
   return(SymbolInfoSessionTrade(_Symbol,(ENUM_DAY_OF_WEEK)WeekdayOf(day),0,from,to));
  }
//+------------------------------------------------------------------+
//| Number of M1 bars in a day (0 when the market was closed)        |
//+------------------------------------------------------------------+
int CountMinuteBars(const datetime day)
  {
   int bars=Bars(_Symbol,PERIOD_M1,day,day+SPH_DAY_SECONDS-1);
   return(bars>0 ? bars : 0);
  }
//+------------------------------------------------------------------+
//| Every M1 bar is built from ticks, so complete tick data must     |
//| reach from the first to the last bar of the day. 'stable' = the  |
//| tick count did not change since the previous attempt             |
//+------------------------------------------------------------------+
bool CoversMinuteBars(const datetime day,const MqlTick &ticks[],const int n,const bool stable)
  {
   datetime times[];
   int bars=CopyTime(_Symbol,PERIOD_M1,day,day+SPH_DAY_SECONDS-1,times);
//--- for a day before the start of the M1 history CopyTime returns the nearest bar
//--- outside the day, so only bars inside the day are compared
   int firstBar=-1,lastBar=-1;
   for(int i=0; i<bars; i++)
      if(times[i]>=day && times[i]<day+SPH_DAY_SECONDS)
        {
         if(firstBar<0)
            firstBar=i;
         lastBar=i;
        }
//--- a day older than the M1 history has nothing to compare with: the ticks are trusted,
//--- unless this load has seen a download; then their count must stop changing first
   if(firstBar<0)
      return(!g_coldRun || stable);
   return(ticks[0].time<times[firstBar]+120 && ticks[n-1].time>=times[lastBar]-60);
  }
//+------------------------------------------------------------------+
//| Adds one day of ticks to the per-hour histograms                 |
//+------------------------------------------------------------------+
void Accumulate(const MqlTick &ticks[],const int n,const long dayEndMsc)
  {
   bool byTime=(InpSampleMode==SPH_SAMPLE_TIME);
   for(int i=0; i<n; i++)
     {
      double bid=ticks[i].bid;
      double ask=ticks[i].ask;
      if(bid<=0.0 || ask<=0.0)
         continue;
      int spread=(int)MathRound((ask-bid)/_Point);
      if(spread<0)
         continue;       // crossed quote: a feed error, not a spread
      int hour=(int)(((long)ticks[i].time%SPH_DAY_SECONDS)/3600);
      g_ticks[hour]++;
      g_totalTicks++;
      if(spread>g_cfgMaxBin)
         g_overflow[hour]++;
      else
         if(spread>g_maxSpread[hour])
            g_maxSpread[hour]=spread;
      int bin=(spread>g_cfgMaxBin) ? g_cfgMaxBin+1 : spread;
      if(!byTime)
        {
         AddWeight(hour,bin,spread,1);
         continue;
        }
      //--- the quote stays valid until the next one, but not longer than the cap
      long t   =ticks[i].time_msc;
      long next=(i+1<n) ? ticks[i+1].time_msc : dayEndMsc;
      long w   =next-t;
      if(w>SPH_TIME_CAP_MSC)
         w=SPH_TIME_CAP_MSC;
      if(w<=0)
         continue;
      //--- a quote near the end of an hour also covers the start of the next one
      long hourEnd=(t/SPH_HOUR_MSC+1)*SPH_HOUR_MSC;
      if(t+w>hourEnd && hour<SPH_HOURS-1)
        {
         AddWeight(hour,bin,spread,hourEnd-t);
         AddWeight(hour+1,bin,spread,t+w-hourEnd);
        }
      else
         AddWeight(hour,bin,spread,w);
     }
  }
//+------------------------------------------------------------------+
//| Adds weight to one histogram cell                                |
//+------------------------------------------------------------------+
void AddWeight(const int hour,const int bin,const int spread,const long w)
  {
   g_hist[hour*g_bins+bin]+=w;
   g_weight[hour]+=w;
   g_sum[hour]+=(double)spread*(double)w;
  }
//+------------------------------------------------------------------+
//| Smallest spread whose cumulative weight reaches num/den of total |
//+------------------------------------------------------------------+
int PercentileBin(const int hour,const long num,const long den)
  {
   long total=g_weight[hour];
   if(total<=0)
      return(0);
   long cum =0;
   int  base=hour*g_bins;
   for(int b=0; b<g_bins; b++)
     {
      cum+=g_hist[base+b];
      //--- integer comparison: 0.9*total in floating point can miss by one bin
      if(cum>0 && cum*den>=total*num)
         return(b);
     }
   return(g_bins-1);
  }
//+------------------------------------------------------------------+
//| Statistics per hour, then the result is shown (and exported)     |
//+------------------------------------------------------------------+
void FinishProfile(void)
  {
   int validHours=0;
   for(int h=0; h<SPH_HOURS; h++)
     {
      g_stats[h].ticks   =g_ticks[h];
      g_stats[h].overflow=g_overflow[h];
      g_stats[h].max     =g_maxSpread[h];
      g_stats[h].valid   =(g_ticks[h]>=g_cfgMinTicks && g_weight[h]>0);
      if(!g_stats[h].valid)
         continue;
      g_stats[h].median=PercentileBin(h,1,2);
      g_stats[h].p90   =PercentileBin(h,9,10);
      g_stats[h].mean  =g_sum[h]/(double)g_weight[h];
      validHours++;
     }
   g_loadSeconds=(GetTickCount64()-g_loadStart)/1000.0;
   g_state=(validHours>0) ? SPH_STATE_READY : SPH_STATE_NODATA;
   EventKillTimer();
   EventSetMillisecondTimer(SPH_TIMER_IDLE);
//--- one summary line per calculation, whatever happened to the single days
   string stop="";
   if(g_stopped)
      stop=StringFormat(", stopped after %d trading days in a row without ticks",g_failStreak+g_idleStreak);
   PrintFormat("Spread Profile: %s, %d of %d days with ticks (%d partial, %d unavailable%s), %s ticks, %d hours shown, %s, loaded in %.1f s",
               _Symbol,g_daysUsed,ArraySize(g_dayList),g_daysPartial,g_daysFailed,stop,
               FormatCount(g_totalTicks),validHours,SampleText(),g_loadSeconds);
   if(InpExportCsv && g_state==SPH_STATE_READY)
      ExportCsv();
  }
//+------------------------------------------------------------------+
//| Writes per-hour statistics to MQL5\Files                         |
//+------------------------------------------------------------------+
void ExportCsv(void)
  {
   string sym=_Symbol;
   string bad[]= {"\\","/",":","*","?","\"","<",">","|"};
   for(int i=0; i<ArraySize(bad); i++)
      StringReplace(sym,bad[i],"_");
   MqlDateTime dt;
   TimeToStruct(g_anchorDay,dt);
   string name=StringFormat("SpreadProfile_%s_%04d%02d%02d.csv",sym,dt.year,dt.mon,dt.day);
   ResetLastError();
   int handle=FileOpen(name,FILE_WRITE|FILE_CSV|FILE_ANSI,',',CP_UTF8);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("Spread Profile: cannot write %s (error %d)",name,GetLastError());
      return;
     }
//--- UTF-8 byte order mark, so that spreadsheet programs detect the encoding
   FileWriteString(handle,ShortToString(0xFEFF));
   double lotCost=MoneyPerLot(1.0);
   FileWrite(handle,"symbol","first_day","last_day","sampling","weekday","hour","ticks",
             "median_pts","p90_pts","mean_pts","max_pts","overflow_ticks",
             "median_pct_of_stop","median_cost_per_lot");
//--- the days that really contributed ticks
   string first=TimeToString(g_oldestUsed,TIME_DATE);
   string last =TimeToString(g_newestUsed,TIME_DATE);
   for(int h=0; h<SPH_HOURS; h++)
     {
      SHourStats s=g_stats[h];
      if(!s.valid)
        {
         FileWrite(handle,_Symbol,first,last,SampleText(),WeekdayText(),h,s.ticks,"","","","","","","");
         continue;
        }
      //--- a median above the histogram range has no exact cost: leave it empty
      bool   known=(s.median<=g_cfgMaxBin);
      string pct =(g_cfgStop>0 && known) ? DoubleToString(100.0*s.median/g_cfgStop,2) : "";
      string cost=(lotCost>0.0 && known) ? DoubleToString(lotCost*s.median,2) : "";
      //--- values above the histogram range are written as ">range", as on the chart
      string top =(s.overflow>0) ? PointsText(g_cfgMaxBin+1) : IntegerToString(s.max);
      FileWrite(handle,_Symbol,first,last,SampleText(),WeekdayText(),h,s.ticks,
                PointsText(s.median),PointsText(s.p90),DoubleToString(s.mean,2),top,s.overflow,pct,cost);
     }
   FileClose(handle);
   PrintFormat("Spread Profile: statistics saved to MQL5\\Files\\%s",name);
  }
//+------------------------------------------------------------------+
//| Account currency value of a spread of 'points' for 1.00 lot      |
//+------------------------------------------------------------------+
double MoneyPerLot(const double points)
  {
   double tickSize =SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickValue=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(tickValue<=0.0)
      tickValue=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   if(tickSize<=0.0 || tickValue<=0.0)
      return(-1.0);
   return(points*_Point/tickSize*tickValue);
  }
//+------------------------------------------------------------------+
//| Current spread in points (-1 when there is no quote)             |
//+------------------------------------------------------------------+
int LiveSpread(void)
  {
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick) || tick.bid<=0.0 || tick.ask<=0.0)
      return(-1);
   return((int)MathMax(0.0,MathRound((tick.ask-tick.bid)/_Point)));
  }
//+------------------------------------------------------------------+
//| Current server hour                                              |
//+------------------------------------------------------------------+
int ServerHour(void)
  {
   datetime now=TimeTradeServer();
   return((int)(((long)now%SPH_DAY_SECONDS)/3600));
  }
//+------------------------------------------------------------------+
//| Sampling mode as text                                            |
//+------------------------------------------------------------------+
string SampleText(void)
  {
   return(InpSampleMode==SPH_SAMPLE_TIME ? "time-weighted" : "tick count");
  }
//+------------------------------------------------------------------+
//| Weekday filter as text                                           |
//+------------------------------------------------------------------+
string WeekdayText(void)
  {
   switch(InpWeekday)
     {
      case SPH_DAY_MON:
         return("Mondays");
      case SPH_DAY_TUE:
         return("Tuesdays");
      case SPH_DAY_WED:
         return("Wednesdays");
      case SPH_DAY_THU:
         return("Thursdays");
      case SPH_DAY_FRI:
         return("Fridays");
      default:
         return("all days");
     }
  }
//+------------------------------------------------------------------+
//| Integer with thousands separators                                |
//+------------------------------------------------------------------+
string FormatCount(const long value)
  {
   string digits=IntegerToString(value);
   string out="";
   int len=StringLen(digits);
   for(int i=0; i<len; i++)
     {
      if(i>0 && (len-i)%3==0)
         out+=",";
      out+=StringSubstr(digits,i,1);
     }
   return(out);
  }
//+------------------------------------------------------------------+
//| Spread in points; overflow shown as '>range'                     |
//+------------------------------------------------------------------+
string PointsText(const int points)
  {
   return(points>g_cfgMaxBin ? ">"+IntegerToString(g_cfgMaxBin) : IntegerToString(points));
  }
//+------------------------------------------------------------------+
//| Spread as a share of the stop size                               |
//+------------------------------------------------------------------+
string StopShareText(const int points)
  {
//--- a spread above the histogram range is only known to be wider than it
   string prefix=(points>g_cfgMaxBin) ? ">" : "";
   double pct=100.0*MathMin(points,g_cfgMaxBin)/g_cfgStop;
   return(prefix+(pct<10.0 ? DoubleToString(pct,1) : DoubleToString(pct,0))+"%");
  }
//+------------------------------------------------------------------+
//| Hours with data ordered by median (ties: p90, then mean)         |
//+------------------------------------------------------------------+
int RankHours(int &order[])
  {
   ArrayResize(order,0);
   for(int h=0; h<SPH_HOURS; h++)
     {
      if(!g_stats[h].valid)
         continue;
      int n=ArraySize(order);
      ArrayResize(order,n+1,SPH_HOURS);
      order[n]=h;
      //--- insertion sort: 24 items at most
      for(int j=n; j>0 && CheaperThan(order[j],order[j-1]); j--)
        {
         int tmp=order[j];
         order[j]=order[j-1];
         order[j-1]=tmp;
        }
     }
   return(ArraySize(order));
  }
//+------------------------------------------------------------------+
//| Ordering used by RankHours                                       |
//+------------------------------------------------------------------+
bool CheaperThan(const int a,const int b)
  {
   if(g_stats[a].median!=g_stats[b].median)
      return(g_stats[a].median<g_stats[b].median);
   if(g_stats[a].p90!=g_stats[b].p90)
      return(g_stats[a].p90<g_stats[b].p90);
   return(g_stats[a].mean<g_stats[b].mean);
  }
//+------------------------------------------------------------------+
//| Hour with the highest median, -1 when several hours share it     |
//+------------------------------------------------------------------+
int PeakHour(void)
  {
   int peak=-1;
   int count=0;
   for(int h=0; h<SPH_HOURS; h++)
     {
      if(!g_stats[h].valid)
         continue;
      if(peak<0 || g_stats[h].median>g_stats[peak].median)
        {
         peak =h;
         count=1;
        }
      else
         if(g_stats[h].median==g_stats[peak].median)
            count++;
     }
   return(count==1 ? peak : -1);
  }
//+------------------------------------------------------------------+
//| Cheapest or most expensive hours as text. Hours with the same    |
//| median are listed together or not at all; a tie group too large  |
//| to list is summarized as "N hours at X pt"                       |
//+------------------------------------------------------------------+
string ExtremeHoursText(const int &order[],const int ranked,const bool cheapest)
  {
   string text  ="";
   int    listed=0;
   int    pos   =0;
   while(pos<ranked)
     {
      int median=g_stats[order[cheapest ? pos : ranked-1-pos]].median;
      //--- find the end of the group of hours that share this median
      int end=pos;
      while(end<ranked && g_stats[order[cheapest ? end : ranked-1-end]].median==median)
         end++;
      int group=end-pos;
      if(listed+group>SPH_RANK_HOURS)
        {
         if(listed==0)
            text=StringFormat("%d hours at %s pt",group,PointsText(median));
         break;
        }
      //--- the whole group fits: list every hour of it
      for(int i=pos; i<end; i++)
        {
         int hour=order[cheapest ? i : ranked-1-i];
         text+=StringFormat("%s%dh %s pt",listed>0 ? ", " : "",hour,PointsText(median));
         listed++;
        }
      pos=end;
     }
   return(text);
  }
//+------------------------------------------------------------------+
//| Mix of two colors, t = share of a (MQL5 color = 0x00BBGGRR)      |
//+------------------------------------------------------------------+
color Blend(const color a,const color b,const double t)
  {
   int r =(int)MathRound(((int)a&0xFF)*t+((int)b&0xFF)*(1.0-t));
   int g =(int)MathRound((((int)a>>8)&0xFF)*t+(((int)b>>8)&0xFF)*(1.0-t));
   int bl=(int)MathRound((((int)a>>16)&0xFF)*t+(((int)b>>16)&0xFF)*(1.0-t));
   return((color)((bl<<16)|(g<<8)|r));
  }
//+------------------------------------------------------------------+
//| Perceived brightness 0..255                                      |
//+------------------------------------------------------------------+
double Luma(const color c)
  {
   return(0.299*((int)c&0xFF)+0.587*(((int)c>>8)&0xFF)+0.114*(((int)c>>16)&0xFF));
  }
//+------------------------------------------------------------------+
//| Opaque canvas color                                              |
//+------------------------------------------------------------------+
uint ToArgb(const color c)
  {
   return(ColorToARGB(c,255));
  }
//+------------------------------------------------------------------+
//| Scales a 96-dpi pixel size to the screen                         |
//+------------------------------------------------------------------+
int Scaled(const double v)
  {
   return((int)MathRound(v*g_scale));
  }
//+------------------------------------------------------------------+
//| Colors follow the chart unless set explicitly                    |
//+------------------------------------------------------------------+
void UpdateColors(void)
  {
   g_chartBack=(color)ChartGetInteger(0,CHART_COLOR_BACKGROUND);
   g_clrBack=(InpColorBack==clrNONE) ? g_chartBack : InpColorBack;
   bool dark=(Luma(g_clrBack)<140.0);
   g_clrText =(InpColorText==clrNONE) ? (dark ? C'222,226,232' : C'30,34,40') : InpColorText;
   g_clrMuted=Blend(g_clrText,g_clrBack,0.62);
   g_clrGrid =(InpColorGrid==clrNONE) ? Blend(g_clrText,g_clrBack,0.16) : InpColorGrid;
   g_clrBar  =InpColorBar;
   g_clrP90  =(InpColorP90==clrNONE) ? Blend(g_clrBar,g_clrBack,0.42) : InpColorP90;
   g_clrNow  =InpColorNow;
   g_clrNowP90   =Blend(g_clrNow,g_clrBack,0.42);
   g_clrNowColumn=Blend(g_clrNow,g_clrBack,0.10);
   g_clrLive =InpColorLive;
  }
//+------------------------------------------------------------------+
//| Creates or resizes the canvas to fill the indicator window       |
//+------------------------------------------------------------------+
bool EnsureCanvas(void)
  {
   int sub=ChartWindowFind();
   if(sub<0)
      return(false);
   int w=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   int h=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,sub);
   if(w<=0 || h<=0)
      return(false);
   if(g_canvas.ChartObjectName()==NULL || sub!=g_subwin || ObjectFind(0,g_objName)<0)
     {
      g_canvas.Destroy();
      //--- canvases left in this window by a crashed copy or a template would cover the new one
      ObjectsDeleteAll(0,"SPH_",sub,OBJ_BITMAP_LABEL);
      if(!g_canvas.CreateBitmapLabel(0,sub,g_objName,0,0,w,h,COLOR_FORMAT_ARGB_NORMALIZE))
         return(false);
      ObjectSetInteger(0,g_objName,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,g_objName,OBJPROP_HIDDEN,true);
      ObjectSetString(0,g_objName,OBJPROP_TOOLTIP,"\n");
      g_subwin=sub;
     }
   else
      if(w!=g_canvas.Width() || h!=g_canvas.Height())
        {
         if(!g_canvas.Resize(w,h))
            return(false);
        }
   ObjectSetInteger(0,g_objName,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,g_objName,OBJPROP_YSIZE,h);
   return(true);
  }
//+------------------------------------------------------------------+
//| Redraws only when the live spread or the hour changed            |
//+------------------------------------------------------------------+
void RenderIfChanged(void)
  {
   if(!g_dirty && LiveSpread()==g_drawnLive && ServerHour()==g_drawnHour)
      return;
   if(GetTickCount64()-g_lastDraw<SPH_REDRAW_MSC)
      return;
   Render();
  }
//+------------------------------------------------------------------+
//| Draws the whole window                                           |
//+------------------------------------------------------------------+
void Render(void)
  {
   if(!EnsureCanvas())
     {
      g_dirty=true;
      return;
     }
   UpdateColors();
   g_canvas.Erase(ToArgb(g_clrBack));
   g_lastDraw =GetTickCount64();
   g_drawnLive=LiveSpread();
   g_drawnHour=ServerHour();
   if(g_canvas.Width()>=Scaled(120) && g_canvas.Height()>=Scaled(40))
     {
      g_canvas.FontSet(SPH_FONT,-g_cfgFont*10);
      if(g_state==SPH_STATE_LOADING)
         DrawLoading();
      else
         if(g_state==SPH_STATE_NODATA)
            DrawNoData();
         else
            DrawProfile();
     }
   g_canvas.Update(true);
   g_dirty=false;
  }
//+------------------------------------------------------------------+
//| True when the indicator window no longer matches the canvas      |
//+------------------------------------------------------------------+
bool CanvasSizeChanged(void)
  {
   int sub=ChartWindowFind();
   if(sub!=g_subwin)
      return(true);
   return((int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS)!=g_canvas.Width() ||
          (int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,sub)!=g_canvas.Height());
  }
//+------------------------------------------------------------------+
//| Progress while ticks are being read                              |
//+------------------------------------------------------------------+
void DrawLoading(void)
  {
   int w=g_canvas.Width();
   int h=g_canvas.Height();
   int total=ArraySize(g_dayList);
   string text=(g_anchorDay==0) ? "Waiting for the trade server time..." :
               StringFormat("Reading tick history of %s: day %d of %d",_Symbol,MathMin(g_dayPos+1,total),total);
   if(g_confirm)
      text+=" (second reading)";
   int th=g_canvas.TextHeight("0");
   int cy=h/2-th;
   g_canvas.TextOut(w/2,cy,text,ToArgb(g_clrText),TA_CENTER|TA_BOTTOM);
   int barW=MathMin(w-Scaled(40),Scaled(360));
   int x1=(w-barW)/2;
   int y1=cy+Scaled(8);
   g_canvas.FillRectangle(x1,y1,x1+barW-1,y1+Scaled(6)-1,ToArgb(g_clrGrid));
   if(total>0)
      g_canvas.FillRectangle(x1,y1,x1+(int)(barW*(double)g_dayPos/total)-1,y1+Scaled(6)-1,ToArgb(g_clrBar));
   string info=StringFormat("%d calendar days, %s, %s",g_cfgDays,SampleText(),WeekdayText());
   g_canvas.TextOut(w/2,y1+Scaled(14),info,ToArgb(g_clrMuted),TA_CENTER|TA_TOP);
  }
//+------------------------------------------------------------------+
//| Message when there is nothing to show                            |
//+------------------------------------------------------------------+
void DrawNoData(void)
  {
   int w=g_canvas.Width();
   int h=g_canvas.Height();
   string line1,line2;
   if(ArraySize(g_dayList)==0)
     {
      line1=StringFormat("No %s in the last %d calendar days.",WeekdayText(),g_cfgDays);
      line2="Increase the history depth to include more days of the chosen weekday.";
     }
   else
      if(g_daysUsed==0 && g_stopped)
        {
         line1=StringFormat("No tick history for %s: the last %d trading days returned no ticks.",_Symbol,g_daysFailed+g_daysIdle);
         line2="If the terminal is still downloading tick history, re-attach the indicator in a minute.";
        }
      else
         if(g_daysUsed==0)
           {
            line1=StringFormat("No tick history for %s in the last %d calendar days (%s).",_Symbol,g_cfgDays,WeekdayText());
            line2="The broker may not provide tick history for this symbol. Try a longer history depth.";
           }
         else
           {
            line1=StringFormat("%s: %s ticks in %d days, but no hour reached %s ticks.",
                               _Symbol,FormatCount(g_totalTicks),g_daysUsed,FormatCount(g_cfgMinTicks));
            line2="Increase the history depth or lower the minimum ticks per hour.";
           }
   g_canvas.TextOut(w/2,h/2-Scaled(2),line1,ToArgb(g_clrText),TA_CENTER|TA_BOTTOM);
   g_canvas.TextOut(w/2,h/2+Scaled(2),line2,ToArgb(g_clrMuted),TA_CENTER|TA_TOP);
  }
//+------------------------------------------------------------------+
//| Adds a header segment                                            |
//+------------------------------------------------------------------+
void AddSeg(STextSeg &segs[],const string text,const color clr,const color swatch=clrNONE,const bool bold=false)
  {
   int n=ArraySize(segs);
   ArrayResize(segs,n+1,16);
   segs[n].text  =text;
   segs[n].clr   =clr;
   segs[n].swatch=swatch;
   segs[n].bold  =bold;
  }
//+------------------------------------------------------------------+
//| Lays out segments left to right, wrapping when the line is full  |
//+------------------------------------------------------------------+
int DrawSegments(STextSeg &segs[],const int left,int y,const int right,const int lineH)
  {
   int x  =left;
   int gap=Scaled(18);
   int box=MathMax(4,lineH*6/10);
   for(int i=0; i<ArraySize(segs); i++)
     {
      g_canvas.FontSet(SPH_FONT,-g_cfgFont*10,segs[i].bold ? FW_BOLD : FW_NORMAL);
      int lead=(segs[i].swatch!=clrNONE) ? box+Scaled(5) : 0;
      int w=lead+g_canvas.TextWidth(segs[i].text);
      if(x>left && x+w>right)
        {
         x=left;
         y+=lineH;
        }
      if(lead>0)
         g_canvas.FillRectangle(x,y+(lineH-box)/2,x+box-1,y+(lineH-box)/2+box-1,ToArgb(segs[i].swatch));
      g_canvas.TextOut(x+lead,y,segs[i].text,ToArgb(segs[i].clr),TA_LEFT|TA_TOP);
      x+=w+gap;
     }
   g_canvas.FontSet(SPH_FONT,-g_cfgFont*10);
   return(y+lineH);
  }
//+------------------------------------------------------------------+
//| Dashed horizontal line                                           |
//+------------------------------------------------------------------+
void DashedLine(const int x1,const int x2,const int y,const int thick,const uint clr)
  {
   int dash=Scaled(6);
   int gap =Scaled(4);
   for(int x=x1; x<=x2; x+=dash+gap)
      g_canvas.FillRectangle(x,y,MathMin(x+dash-1,x2),y+thick-1,clr);
  }
//+------------------------------------------------------------------+
//| Nice axis step (1, 2 or 5 times a power of ten)                  |
//+------------------------------------------------------------------+
double NiceStep(const double raw)
  {
   if(raw<=0.0)
      return(1.0);
   double p=MathPow(10.0,MathFloor(MathLog10(raw)));
   double f=raw/p;
   double m=(f<=1.0) ? 1.0 : (f<=2.0) ? 2.0 : (f<=5.0) ? 5.0 : 10.0;
   return(MathMax(1.0,m*p));
  }
//+------------------------------------------------------------------+
//| Main view: header, axis, 24 bars, live spread                    |
//+------------------------------------------------------------------+
void DrawProfile(void)
  {
   int W  =g_canvas.Width();
   int H  =g_canvas.Height();
   int pad=Scaled(8);
   int th =g_canvas.TextHeight("0Hy");
   int lineH=th+Scaled(3);
   int now =ServerHour();
   int live=LiveSpread();
   string cur=AccountInfoString(ACCOUNT_CURRENCY);
//--- header line 1: what the profile is made of
   STextSeg segs[];
   string days=StringFormat("%d of %d days with ticks",g_daysUsed,ArraySize(g_dayList));
   if(g_daysPartial>0)
      days+=StringFormat(", %d partial",g_daysPartial);
   if(g_daysFailed>0)
      days+=StringFormat(", %d unavailable",g_daysFailed);
   AddSeg(segs,"Spread by server hour  "+_Symbol,g_clrText,clrNONE,true);
   AddSeg(segs,days,g_clrMuted);
   if(g_stopped)
      AddSeg(segs,"no ticks before "+TimeToString(g_oldestUsed,TIME_DATE),g_clrMuted);
   AddSeg(segs,StringFormat("last %d calendar days, %s",g_cfgDays,WeekdayText()),g_clrMuted);
   AddSeg(segs,SampleText(),g_clrMuted);
   AddSeg(segs,FormatCount(g_totalTicks)+" ticks",g_clrMuted);
   int y=DrawSegments(segs,pad,pad,W-pad,lineH);
//--- header line 2: the current hour and what it costs
   ArrayResize(segs,0);
   AddSeg(segs,StringFormat("Now %02d:00 server",now),g_clrNow,g_clrNow);
   if(live>=0)
      AddSeg(segs,StringFormat("live %d pt",live),g_clrLive);
   SHourStats s=g_stats[now];
   if(s.valid)
     {
      AddSeg(segs,StringFormat("median %s pt, p90 %s pt",PointsText(s.median),PointsText(s.p90)),g_clrText);
      double money=MoneyPerLot(MathMin(s.median,g_cfgMaxBin));
      if(money>0.0)
         AddSeg(segs,StringFormat("median cost %s%s %s per 1.00 lot",s.median>g_cfgMaxBin ? ">" : "",
                                  DoubleToString(money,2),cur),g_clrText);
      if(g_cfgStop>0)
         AddSeg(segs,StringFormat("%s of a %d pt stop (p90 %s)",StopShareText(s.median),
                                  g_cfgStop,StopShareText(s.p90)),g_clrText);
     }
   else
      AddSeg(segs,"no data for this hour",g_clrMuted);
   y=DrawSegments(segs,pad,y,W-pad,lineH);
//--- header line 3: cheapest and most expensive hours
   ArrayResize(segs,0);
   int order[];
   int ranked=RankHours(order);
   if(ranked>0 && g_stats[order[0]].median==g_stats[order[ranked-1]].median)
     {
      //--- a ranking of equal values would suggest differences that do not exist
      AddSeg(segs,StringFormat("Median is %s pt in every hour with data",PointsText(g_stats[order[0]].median)),g_clrText);
     }
   else
      if(ranked>0)
        {
         AddSeg(segs,"Cheapest: "+ExtremeHoursText(order,ranked,true),g_clrText);
         AddSeg(segs,"Most expensive: "+ExtremeHoursText(order,ranked,false),g_clrText);
        }
   AddSeg(segs,"median",g_clrMuted,g_clrBar);
   AddSeg(segs,"90th percentile",g_clrMuted,g_clrP90);
   AddSeg(segs,"live",g_clrMuted,g_clrLive);
   y=DrawSegments(segs,pad,y,W-pad,lineH);
//--- plot frame: y labels on the left, live label on the right
   double top=0.0;
   for(int h=0; h<SPH_HOURS; h++)
      if(g_stats[h].valid)
         top=MathMax(top,(double)MathMin(g_stats[h].p90,g_cfgMaxBin));
   if(live>0)
      top=MathMax(top,(double)MathMin(live,g_cfgMaxBin));
   double step=NiceStep(MathMax(top,1.0)*1.08/4.0);
   double axisMax=MathMax(step,MathCeil(MathMax(top,1.0)*1.08/step)*step);
   int labelW=g_canvas.TextWidth(IntegerToString((long)axisMax)+" pt");
   int liveW =g_canvas.TextWidth("live 00000");
   int left  =pad+labelW+Scaled(6);
   int right =W-pad-liveW-Scaled(6);
   int small =MathMax(6,g_cfgFont-1);
   g_canvas.FontSet(SPH_FONT,-small*10);
   int ths=g_canvas.TextHeight("0%");
   g_canvas.FontSet(SPH_FONT,-g_cfgFont*10);
   int plotTop=y+Scaled(4)+ths+Scaled(2);
   int bottom =H-pad-th-Scaled(4);
   if(bottom-plotTop<Scaled(20) || right-left<Scaled(120))
      return;            // window too small for the chart, header only
   double slot=(right-left)/(double)SPH_HOURS;
//--- current hour column
   int cx1=left+(int)MathRound(slot*now);
   int cx2=left+(int)MathRound(slot*(now+1))-1;
   g_canvas.FillRectangle(cx1,plotTop,cx2,bottom,ToArgb(g_clrNowColumn));
//--- grid and y labels
   for(double v=0.0; v<=axisMax+0.5; v+=step)
     {
      int gy=bottom-(int)MathRound(v/axisMax*(bottom-plotTop));
      g_canvas.LineHorizontal(left,right,gy,ToArgb(v==0.0 ? g_clrMuted : g_clrGrid));
      string lbl=IntegerToString((long)v);
      if(v+step>axisMax+0.5)
         lbl+=" pt";
      g_canvas.TextOut(left-Scaled(6),gy,lbl,ToArgb(g_clrMuted),TA_RIGHT|TA_VCENTER);
     }
//--- bars
   int barW=(int)MathMax(1.0,MathRound(slot*0.64));
   bool everyHour=(g_canvas.TextWidth("23")+Scaled(4)<=slot);
   int peak=PeakHour();
   for(int h=0; h<SPH_HOURS; h++)
     {
      int cx=left+(int)MathRound(slot*(h+0.5));
      int x1=cx-barW/2;
      int x2=x1+barW-1;
      bool isNow=(h==now);
      if(everyHour || h%2==0)
         g_canvas.TextOut(cx,bottom+Scaled(4),IntegerToString(h),ToArgb(isNow ? g_clrNow : g_clrMuted),TA_CENTER|TA_TOP);
      if(!g_stats[h].valid)
        {
         g_canvas.TextOut(cx,bottom-Scaled(2),"-",ToArgb(g_clrMuted),TA_CENTER|TA_BOTTOM);
         continue;
        }
      int med =MathMin(g_stats[h].median,g_cfgMaxBin);
      int p90 =MathMin(g_stats[h].p90,g_cfgMaxBin);
      int yMed=bottom-(int)MathRound(med/axisMax*(bottom-plotTop));
      int yP90=bottom-(int)MathRound(p90/axisMax*(bottom-plotTop));
      if(yP90<yMed)
        {
         g_canvas.FillRectangle(x1,yP90,x2,yMed-1,ToArgb(isNow ? g_clrNowP90 : g_clrP90));
         //--- a thin edge marks the exact 90th percentile level
         g_canvas.FillRectangle(x1,yP90,x2,yP90+MathMax(1,Scaled(1))-1,ToArgb(isNow ? g_clrNow : g_clrBar));
        }
      if(med>0)
         g_canvas.FillRectangle(x1,MathMin(yMed,bottom-1),x2,bottom-1,ToArgb(isNow ? g_clrNow : g_clrBar));
      //--- label above the bar: share of the stop, or the median itself;
      //--- in a narrow window only the highest bar keeps its label
      string lbl=(g_cfgStop>0) ? StopShareText(g_stats[h].median) : PointsText(g_stats[h].median);
      g_canvas.FontSet(SPH_FONT,-small*10);
      if(g_canvas.TextWidth(lbl)<=slot-Scaled(2) || h==peak)
         g_canvas.TextOut(cx,yP90-Scaled(2),lbl,ToArgb(isNow ? g_clrNow : g_clrMuted),TA_CENTER|TA_BOTTOM);
      g_canvas.FontSet(SPH_FONT,-g_cfgFont*10);
     }
//--- live spread
   if(live>=0)
     {
      int ly=bottom-(int)MathRound(MathMin(live,(int)axisMax)/axisMax*(bottom-plotTop));
      int lt=MathMax(1,Scaled(1));
      DashedLine(left,right,ly-lt/2,lt,ToArgb(g_clrLive));
      string lbl=(live>axisMax) ? StringFormat("live %d ^",live) : StringFormat("live %d",live);
      g_canvas.TextOut(right+Scaled(6),ly,lbl,ToArgb(g_clrLive),TA_LEFT|TA_VCENTER);
     }
  }
//+------------------------------------------------------------------+
