//+------------------------------------------------------------------+
//|                                       KillzonesSessionPivots.mq5 |
//|                                                     Bruno Myrrha |
//+------------------------------------------------------------------+
//| Purpose:      Draws intraday trading sessions (killzones) in New |
//|               York time, the high and low of each session carried|
//|               forward until price takes them, the previous day,  |
//|               week and month levels, opening-price lines at fixed|
//|               times and vertical time markers.                   |
//| Failure mode: Session times are given in New York time and       |
//|               converted from the broker's server time with both  |
//|               daylight-saving calendars; a wrong server offset in|
//|               the inputs shifts every session by whole hours.    |
//|               The bar in progress is recalculated on every tick  |
//|               from the last confirmed state.                     |
//| Dependencies: none (chart objects only)                          |
//| Part of:      KillzonesSessionPivots indicator                   |
//+------------------------------------------------------------------+

#property copyright "Bruno Nunes Myrrha Ribeiro"
#property link      "https://www.mql5.com/en/users/bruno_myrrha"
#property version   "1.04"
#property description "ICT killzones in New York time with session pivots, previous day, week"
#property description "and month levels, and opening-price lines at key times."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//+------------------------------------------------------------------+
//| Option lists                                                     |
//+------------------------------------------------------------------+
enum ENUM_EXTENSION                 // how long pivots run
  {
   EXTEND_UNTIL_TAKEN,              // until taken
   EXTEND_PAST_TAKEN                // past the take
  };
enum ENUM_SERVER_DST                // broker daylight-saving calendar
  {
   SERVER_DST_US,                   // US
   SERVER_DST_EU,                   // EU
   SERVER_DST_NONE                  // none
  };

//+------------------------------------------------------------------+
//| Inputs: sessions                                                 |
//+------------------------------------------------------------------+
input group "Sessions (New York time)"
input string InpS1Name     = "ASIA";         // session 1 name
input string InpS1Time     = "2000-0000";    // session 1 time
input color  InpS1Color    = C'94,129,172';  // session 1 color
input string InpS2Name     = "LONDON";       // session 2 name
input string InpS2Time     = "0200-0500";    // session 2 time
input color  InpS2Color    = C'196,98,62';   // session 2 color
input string InpS3Name     = "NY AM";        // session 3 name
input string InpS3Time     = "0930-1100";    // session 3 time
input color  InpS3Color    = C'52,140,96';   // session 3 color
input string InpS4Name     = "NY LUNCH";     // session 4 name
input string InpS4Time     = "";             // session 4 time
input color  InpS4Color    = C'201,152,40';  // session 4 color
input string InpS5Name     = "NY PM";        // session 5 name
input string InpS5Time     = "1330-1600";    // session 5 time
input color  InpS5Color    = C'134,92,176';  // session 5 color
input int    InpKeep       = 3;              // sessions kept on the chart
input int    InpBoxOpacity = 40;             // box opacity, percent

//+------------------------------------------------------------------+
//| Inputs: session pivots                                           |
//+------------------------------------------------------------------+
input group "Session pivots"
input bool           InpPivots    = true;               // draw session high and low
input bool           InpMid       = false;              // draw session midpoint
input bool           InpPivotTags = true;               // label the pivots
input ENUM_EXTENSION InpExtension = EXTEND_UNTIL_TAKEN; // extend pivots
input bool           InpAlerts    = true;               // alert when a high or low is taken

//+------------------------------------------------------------------+
//| Inputs: previous day, week and month                             |
//+------------------------------------------------------------------+
input group "Previous day, week, month"
input bool  InpDayLevels   = true;           // previous day levels
input color InpDayColor    = C'70,110,160';  // day color
input bool  InpWeekLevels  = true;           // previous week levels
input color InpWeekColor   = C'58,146,134';  // week color
input bool  InpMonthLevels = true;           // previous month levels
input color InpMonthColor  = C'176,72,84';   // month color

//+------------------------------------------------------------------+
//| Inputs: opening prices and time markers                          |
//+------------------------------------------------------------------+
input group "Key times (New York time)"
input bool   InpOpens   = true;              // opening-price line at each time
input bool   InpMarks   = true;              // vertical marker at each time
input string InpK1Time  = "0930";            // time 1
input string InpK1Name  = "NY Open";         // time 1 label
input color  InpK1Color = C'70,110,160';     // time 1 color
input string InpK2Time  = "1200";            // time 2
input string InpK2Name  = "Midday";          // time 2 label
input color  InpK2Color = C'201,152,40';     // time 2 color
input string InpK3Time  = "1600";            // time 3
input string InpK3Name  = "Close";           // time 3 label
input color  InpK3Color = C'176,72,84';      // time 3 color

//+------------------------------------------------------------------+
//| Inputs: broker clock                                             |
//+------------------------------------------------------------------+
input group "Broker clock"
input int             InpServerGmt = 2;             // broker server GMT offset in winter
input ENUM_SERVER_DST InpServerDst = SERVER_DST_US; // broker daylight-saving calendar
input ENUM_TIMEFRAMES InpMaxPeriod = PERIOD_M30;    // draw only up to this timeframe

//+------------------------------------------------------------------+
//| Constants                                                        |
//+------------------------------------------------------------------+
#define TAG        "KSP_"   // prefix of every chart object
#define SESSIONS   5        // session slots
#define SLOTS      3        // key-time slots
#define FRAMES     3        // day, week, month
#define KIND_HIGH  0        // frame line: previous high
#define KIND_LOW   1        // frame line: previous low
#define KIND_MID   2        // frame line: previous midline
#define FONT_SIZE  8        // label font size
#define HISTORY    5000     // bars processed on load

//+------------------------------------------------------------------+
//| A daily time window in minutes; "to" may wrap past midnight      |
//+------------------------------------------------------------------+
struct TimeSpan
  {
   int               from;        // first minute inside the window
   int               to;          // first minute after the window
   bool              valid;       // parsed correctly
  };

//+------------------------------------------------------------------+
//| One session's drawings and the state of its pivots               |
//+------------------------------------------------------------------+
struct SessionMark
  {
   int               slot;        // session slot, 0..4
   long              id;          // unique id, names the objects
   datetime          opened;      // first bar of the session
   datetime          lastIn;      // last bar inside the session
   double            top;         // session high so far
   double            bottom;      // session low so far
   datetime          topAt;       // bar of the high
   datetime          bottomAt;    // bar of the low
   datetime          topUntil;    // right end of the high line
   datetime          bottomUntil; // right end of the low line
   datetime          midUntil;    // right end of the midline
   bool              topOpen;     // high not taken yet
   bool              bottomOpen;  // low not taken yet
   bool              midOpen;     // midline not touched yet
  };

//+------------------------------------------------------------------+
//| One line of the day/week/month layer                             |
//+------------------------------------------------------------------+
struct FrameLine
  {
   int               frame;       // 0 day, 1 week, 2 month
   int               kind;        // KIND_HIGH, KIND_LOW or KIND_MID
   long              id;          // unique id
   double            price;       // level
   datetime          from;        // left end
   datetime          until;       // right end
   datetime          period;      // start of the period it describes
  };

//+------------------------------------------------------------------+
//| Running OHLC of the current and previous day/week/month          |
//+------------------------------------------------------------------+
struct FrameTotals
  {
   long              key;         // period key of the current period
   double            open;        // current period open
   double            high;        // current period high
   double            low;         // current period low
   double            prevHigh;    // previous period high
   double            prevLow;     // previous period low
   datetime          began;       // current period first bar
   datetime          prevBegan;   // previous period first bar
   bool              highTaken;   // previous high traded through
   bool              lowTaken;    // previous low traded through
   int               periods;     // periods counted for hit rates
   int               highHits;    // periods whose previous high was taken
   int               lowHits;     // periods whose previous low was taken
  };

//+------------------------------------------------------------------+
//| An opening-price line or a time marker                           |
//+------------------------------------------------------------------+
struct TimeLine
  {
   int               slot;        // key-time slot, 0..2
   long              id;          // unique id
   double            price;       // opening price (unused by markers)
   datetime          from;        // bar of the time
   datetime          until;       // right end
  };

//+------------------------------------------------------------------+
//| Everything the drawings are built from                           |
//+------------------------------------------------------------------+
class CLayerState
  {
public:
   SessionMark       marks[];
   FrameLine         frames[];
   TimeLine          opens[];
   TimeLine          stamps[];
   FrameTotals       totals[FRAMES];
   int               runs[SESSIONS];
   int               topHits[SESSIONS];
   int               bottomHits[SESSIONS];
   datetime          firstRun[SESSIONS];
   long              nextId;
   //--- empties every list and counter
   void              Clear(void);
   //--- takes a full copy of another state
   void              CopyFrom(const CLayerState &src);
  };

//+------------------------------------------------------------------+
//| Settings resolved in OnInit                                      |
//+------------------------------------------------------------------+
struct SessionSetup
  {
   bool              on;          // slot enabled
   string            name;        // label text
   color             tint;        // drawing color
   TimeSpan          span;        // window
  };

struct SlotSetup
  {
   bool              on;          // slot enabled
   string            name;        // label text
   color             tint;        // drawing color
   TimeSpan          span;        // one-minute window
  };

SessionSetup g_sessions[SESSIONS];   // the five sessions
SlotSetup    g_times[SLOTS];         // the key times
CLayerState  g_done;                 // state after the last closed bar
CLayerState  g_view;                 // state including the bar in progress
int          g_doneBar = -1;         // index of the last closed bar applied
datetime     g_doneTime = 0;         // time of that bar
string       g_drawn[];              // objects drawn on the last render
string       g_alerted[];            // alerts already sent, by key

//+------------------------------------------------------------------+
//| Resets a state to empty                                          |
//+------------------------------------------------------------------+
void CLayerState::Clear(void)
  {
   ArrayResize(marks,0);
   ArrayResize(frames,0);
   ArrayResize(opens,0);
   ArrayResize(stamps,0);
   ZeroMemory(totals);
   ArrayInitialize(runs,0);
   ArrayInitialize(topHits,0);
   ArrayInitialize(bottomHits,0);
   ArrayInitialize(firstRun,0);
   nextId=1;
  }

//+------------------------------------------------------------------+
//| Copies every list and counter of another state                   |
//+------------------------------------------------------------------+
void CLayerState::CopyFrom(const CLayerState &src)
  {
   ArrayCopy(marks,src.marks);
   ArrayResize(marks,ArraySize(src.marks));
   ArrayCopy(frames,src.frames);
   ArrayResize(frames,ArraySize(src.frames));
   ArrayCopy(opens,src.opens);
   ArrayResize(opens,ArraySize(src.opens));
   ArrayCopy(stamps,src.stamps);
   ArrayResize(stamps,ArraySize(src.stamps));
   for(int f=0; f<FRAMES; f++)
      totals[f]=src.totals[f];
   for(int s=0; s<SESSIONS; s++)
     {
      runs[s]=src.runs[s];
      topHits[s]=src.topHits[s];
      bottomHits[s]=src.bottomHits[s];
      firstRun[s]=src.firstRun[s];
     }
   nextId=src.nextId;
  }

//+------------------------------------------------------------------+
//| Parses "HHMM-HHMM" (or "HHMM" as a one-minute window)            |
//+------------------------------------------------------------------+
TimeSpan ParseSpan(string text,const bool single)
  {
   TimeSpan span;
   span.valid=false;
   StringReplace(text," ","");
   StringReplace(text,":","");
   string part[];
   int    count=StringSplit(text,'-',part);
   if(count!=(single ? 1 : 2))
      return(span);
   int edge[2];
   for(int k=0; k<count; k++)
     {
      string p=part[k];
      if(StringLen(p)==3)
         p="0"+p;
      if(StringLen(p)!=4)
         return(span);
      int hh=(int)StringToInteger(StringSubstr(p,0,2));
      int mm=(int)StringToInteger(StringSubstr(p,2,2));
      if(hh<0 || hh>23 || mm<0 || mm>59)
         return(span);
      edge[k]=hh*60+mm;
     }
   span.from=edge[0];
   span.to=single ? edge[0]+1 : (edge[1]==0 ? 1440 : edge[1]);
   span.valid=true;
   return(span);
  }

//+------------------------------------------------------------------+
//| True when a minute of the day falls inside the window            |
//+------------------------------------------------------------------+
bool Inside(const TimeSpan &span,const int minute)
  {
   if(!span.valid)
      return(false);
   if(span.from<span.to)
      return(minute>=span.from && minute<span.to);
   return(minute>=span.from || minute<span.to);
  }

//+------------------------------------------------------------------+
//| Day of the month of the n-th Sunday (n=0 means the last one)     |
//+------------------------------------------------------------------+
int SundayOf(const int year,const int month,const int n)
  {
   MqlDateTime d;
   ZeroMemory(d);
   d.year=year;
   d.mon=month;
   d.day=1;
   datetime first=StructToTime(d);
   TimeToStruct(first,d);
   int firstSunday=1+(7-d.day_of_week)%7;
   if(n>0)
      return(firstSunday+7*(n-1));
   MqlDateTime e;
   ZeroMemory(e);
   e.year=(month==12) ? year+1 : year;
   e.mon=(month==12) ? 1 : month+1;
   e.day=1;
   int days=(int)((StructToTime(e)-first)/86400);
   int last=firstSunday;
   while(last+7<=days)
      last+=7;
   return(last);
  }

//+------------------------------------------------------------------+
//| UTC time of a given date and hour                                |
//+------------------------------------------------------------------+
datetime At(const int year,const int month,const int day,const int hour)
  {
   MqlDateTime d;
   ZeroMemory(d);
   d.year=year;
   d.mon=month;
   d.day=day;
   d.hour=hour;
   return(StructToTime(d));
  }

//+------------------------------------------------------------------+
//| US daylight saving: second Sunday of March to first of November  |
//+------------------------------------------------------------------+
bool UsSummer(const datetime utc)
  {
   MqlDateTime d;
   TimeToStruct(utc,d);
   datetime begin=At(d.year,3,SundayOf(d.year,3,2),7);
   datetime end=At(d.year,11,SundayOf(d.year,11,1),6);
   return(utc>=begin && utc<end);
  }

//+------------------------------------------------------------------+
//| EU daylight saving: last Sunday of March to last of October      |
//+------------------------------------------------------------------+
bool EuSummer(const datetime utc)
  {
   MqlDateTime d;
   TimeToStruct(utc,d);
   datetime begin=At(d.year,3,SundayOf(d.year,3,0),1);
   datetime end=At(d.year,10,SundayOf(d.year,10,0),1);
   return(utc>=begin && utc<end);
  }

//+------------------------------------------------------------------+
//| Converts broker server time to New York time                     |
//+------------------------------------------------------------------+
datetime ToClock(const datetime server)
  {
   datetime guess=server-InpServerGmt*3600;
   bool     summer=(InpServerDst==SERVER_DST_US) ? UsSummer(guess) :
                   (InpServerDst==SERVER_DST_EU) ? EuSummer(guess) : false;
   datetime utc=guess-(summer ? 3600 : 0);
   return(utc+(UsSummer(utc) ? -4 : -5)*3600);
  }

//+------------------------------------------------------------------+
//| Minute of the day in New York time                               |
//+------------------------------------------------------------------+
int ClockMinute(const datetime server)
  {
   return((int)((ToClock(server)%86400)/60));
  }

//+------------------------------------------------------------------+
//| Period key of a bar for the day, week or month layer             |
//+------------------------------------------------------------------+
long PeriodKey(const int frame,const datetime t)
  {
   long day=(long)(t/86400);
   if(frame==0)
      return(day);
   if(frame==1)
      return((day+3)/7);
   MqlDateTime d;
   TimeToStruct(t,d);
   return((long)d.year*12+d.mon);
  }

//+------------------------------------------------------------------+
//| Sends an alert once per key while the indicator runs live        |
//+------------------------------------------------------------------+
void Notify(const bool live,const string key,const string text)
  {
   if(!live)
      return;
   for(int k=ArraySize(g_alerted)-1; k>=0; k--)
      if(g_alerted[k]==key)
         return;
   int n=ArraySize(g_alerted);
   ArrayResize(g_alerted,n+1);
   g_alerted[n]=key;
   Alert(_Symbol," ",text);
  }

//+------------------------------------------------------------------+
//| Removes the oldest session marks of a slot beyond the limit      |
//+------------------------------------------------------------------+
void TrimMarks(CLayerState &st,const int slot)
  {
   int seen=0;
   for(int k=ArraySize(st.marks)-1; k>=0; k--)
     {
      if(st.marks[k].slot!=slot)
         continue;
      if(++seen>MathMax(1,InpKeep))
         ArrayRemove(st.marks,k,1);
     }
  }

//+------------------------------------------------------------------+
//| Removes the oldest frame lines of one frame and kind             |
//+------------------------------------------------------------------+
void TrimFrames(CLayerState &st,const int frame,const int kind)
  {
   int seen=0,keep=MathMax(1,InpKeep);
   for(int k=ArraySize(st.frames)-1; k>=0; k--)
     {
      if(st.frames[k].frame!=frame || st.frames[k].kind!=kind)
         continue;
      if(++seen>keep)
         ArrayRemove(st.frames,k,1);
     }
  }

//+------------------------------------------------------------------+
//| Removes the oldest time lines of a slot beyond the limit         |
//+------------------------------------------------------------------+
void TrimLines(TimeLine &list[],const int slot,const int keep)
  {
   int seen=0;
   for(int k=ArraySize(list)-1; k>=0; k--)
     {
      if(list[k].slot!=slot)
         continue;
      if(++seen>keep)
         ArrayRemove(list,k,1);
     }
  }

//+------------------------------------------------------------------+
//| Applies one bar to the session layer                             |
//+------------------------------------------------------------------+
void StepSessions(CLayerState &st,const datetime t,const double hi,const double lo,
                  const int minute,const int prevMinute,const bool live)
  {
   for(int s=0; s<SESSIONS; s++)
     {
      if(!g_sessions[s].on)
         continue;
      bool now=Inside(g_sessions[s].span,minute);
      bool before=Inside(g_sessions[s].span,prevMinute);
      //--- a session starts
      if(now && !before)
        {
         SessionMark m;
         ZeroMemory(m);
         m.slot=s;
         m.id=st.nextId++;
         m.opened=t;
         m.lastIn=t;
         m.top=hi;
         m.bottom=lo;
         m.topAt=t;
         m.bottomAt=t;
         m.topUntil=t;
         m.bottomUntil=t;
         m.midUntil=t;
         m.topOpen=true;
         m.bottomOpen=true;
         m.midOpen=true;
         int n=ArraySize(st.marks);
         ArrayResize(st.marks,n+1);
         st.marks[n]=m;
         st.runs[s]++;
         if(st.firstRun[s]==0)
            st.firstRun[s]=t;
         TrimMarks(st,s);
        }
      //--- walk this slot's marks from the newest
      int rank=0;
      for(int k=ArraySize(st.marks)-1; k>=0; k--)
        {
         if(st.marks[k].slot!=s)
            continue;
         if(rank==0 && now)
           {
            st.marks[k].lastIn=t;
            if(hi>st.marks[k].top)
              {
               st.marks[k].top=hi;
               st.marks[k].topAt=t;
              }
            if(lo<st.marks[k].bottom)
              {
               st.marks[k].bottom=lo;
               st.marks[k].bottomAt=t;
              }
           }
         if(rank==0)
           {
            if(InpExtension==EXTEND_PAST_TAKEN || st.marks[k].topOpen)
               st.marks[k].topUntil=t;
            if(InpExtension==EXTEND_PAST_TAKEN || st.marks[k].bottomOpen)
               st.marks[k].bottomUntil=t;
            if(st.marks[k].topOpen && hi>st.marks[k].top)
              {
               st.marks[k].topOpen=false;
               st.topHits[s]++;
               if(InpAlerts && InpPivots)
                  Notify(live,StringFormat("P%I64dH",st.marks[k].id),"took "+g_sessions[s].name+" High");
              }
            if(st.marks[k].bottomOpen && lo<st.marks[k].bottom)
              {
               st.marks[k].bottomOpen=false;
               st.bottomHits[s]++;
               if(InpAlerts && InpPivots)
                  Notify(live,StringFormat("P%I64dL",st.marks[k].id),"took "+g_sessions[s].name+" Low");
              }
            if(!now || rank>0)
              {
               double mid=(st.marks[k].top+st.marks[k].bottom)/2;
               st.marks[k].midUntil=t;
               if(st.marks[k].midOpen && lo<=mid && hi>=mid)
                  st.marks[k].midOpen=false;
              }
           }
         rank++;
        }
     }
  }

//+------------------------------------------------------------------+
//| Adds a line to the day/week/month layer                          |
//+------------------------------------------------------------------+
void AddFrameLine(CLayerState &st,const int f,const int kind,const double price,
                  const datetime t,const datetime period)
  {
   FrameLine line;
   line.frame=f;
   line.kind=kind;
   line.id=st.nextId++;
   line.price=price;
   line.from=t;
   line.until=t;
   line.period=period;
   int n=ArraySize(st.frames);
   ArrayResize(st.frames,n+1);
   st.frames[n]=line;
   TrimFrames(st,f,kind);
  }

//+------------------------------------------------------------------+
//| Newest line of a frame and kind, or -1                           |
//+------------------------------------------------------------------+
int NewestFrame(const CLayerState &st,const int f,const int kind)
  {
   for(int k=ArraySize(st.frames)-1; k>=0; k--)
      if(st.frames[k].frame==f && st.frames[k].kind==kind)
         return(k);
   return(-1);
  }

//+------------------------------------------------------------------+
//| Applies one bar to the day/week/month layer                      |
//+------------------------------------------------------------------+
void StepFrames(CLayerState &st,const datetime t,const double op,const double hi,
                const double lo,const bool live)
  {
   static const string tags[FRAMES]= {"D","W","M"};
   bool show[FRAMES]= {InpDayLevels,InpWeekLevels,InpMonthLevels};
   for(int f=0; f<FRAMES; f++)
     {
      //--- extend the newest high, low and midline before a roll
      for(int kind=KIND_HIGH; kind<=KIND_MID; kind++)
        {
         int k=NewestFrame(st,f,kind);
         if(k>=0)
            st.frames[k].until=t;
        }
      long key=PeriodKey(f,t);
      bool roll=(key!=st.totals[f].key);
      if(roll)
        {
         bool had=(st.totals[f].key!=0);
         st.totals[f].prevHigh=had ? st.totals[f].high : 0;
         st.totals[f].prevLow=had ? st.totals[f].low : 0;
         st.totals[f].prevBegan=st.totals[f].began;
         st.totals[f].key=key;
         st.totals[f].open=op;
         st.totals[f].high=hi;
         st.totals[f].low=lo;
         st.totals[f].began=t;
         st.totals[f].highTaken=false;
         st.totals[f].lowTaken=false;
         if(show[f] && had)
           {
            AddFrameLine(st,f,KIND_HIGH,st.totals[f].prevHigh,t,st.totals[f].prevBegan);
            AddFrameLine(st,f,KIND_LOW,st.totals[f].prevLow,t,st.totals[f].prevBegan);
            AddFrameLine(st,f,KIND_MID,(st.totals[f].prevHigh+st.totals[f].prevLow)/2,t,st.totals[f].prevBegan);
            st.totals[f].periods++;
           }
        }
      else
        {
         st.totals[f].high=MathMax(st.totals[f].high,hi);
         st.totals[f].low=MathMin(st.totals[f].low,lo);
        }
      //--- previous high and low traded through
      if(!show[f] || st.totals[f].prevHigh==0)
         continue;
      if(!st.totals[f].highTaken && hi>st.totals[f].prevHigh)
        {
         st.totals[f].highTaken=true;
         st.totals[f].highHits++;
         if(InpAlerts)
            Notify(live,StringFormat("F%dH%I64d",f,key),"took P"+tags[f]+"H");
        }
      if(!st.totals[f].lowTaken && lo<st.totals[f].prevLow)
        {
         st.totals[f].lowTaken=true;
         st.totals[f].lowHits++;
         if(InpAlerts)
            Notify(live,StringFormat("F%dL%I64d",f,key),"took P"+tags[f]+"L");
        }
     }
  }

//+------------------------------------------------------------------+
//| Applies one bar to the key times: opening prices and markers     |
//+------------------------------------------------------------------+
void StepTimes(CLayerState &st,const datetime t,const double op,const int minute,
               const int prevMinute)
  {
   for(int s=0; s<SLOTS; s++)
     {
      if(!g_times[s].on)
         continue;
      bool now=Inside(g_times[s].span,minute);
      if(now && !Inside(g_times[s].span,prevMinute))
        {
         TimeLine line;
         ZeroMemory(line);
         line.slot=s;
         line.id=st.nextId++;
         line.price=op;
         line.from=t;
         line.until=t;
         if(InpOpens)
           {
            int n=ArraySize(st.opens);
            ArrayResize(st.opens,n+1);
            st.opens[n]=line;
            TrimLines(st.opens,s,1);
           }
         if(InpMarks)
           {
            int n=ArraySize(st.stamps);
            ArrayResize(st.stamps,n+1);
            st.stamps[n]=line;
            TrimLines(st.stamps,s,1);
           }
        }
      //--- the newest opening-price line runs until the next bar of its time
      if(!now)
         for(int k=ArraySize(st.opens)-1; k>=0; k--)
            if(st.opens[k].slot==s)
              {
               st.opens[k].until=t;
               break;
              }
     }
  }

//+------------------------------------------------------------------+
//| Applies one bar to every layer                                   |
//+------------------------------------------------------------------+
void StepBar(CLayerState &st,const int i,const datetime &time[],const double &open[],
             const double &high[],const double &low[],const bool live)
  {
   int  minute=ClockMinute(time[i]);
   int  prevMinute=ClockMinute(time[i-1]);
   StepSessions(st,time[i],high[i],low[i],minute,prevMinute,live);
   StepFrames(st,time[i],open[i],high[i],low[i],live);
   StepTimes(st,time[i],open[i],minute,prevMinute);
  }

//+------------------------------------------------------------------+
//| Mixes a color with the chart background (opacity in percent)     |
//+------------------------------------------------------------------+
color Faded(const color tint,const int opacity)
  {
   color  back=(color)ChartGetInteger(0,CHART_COLOR_BACKGROUND);
   double a=MathMax(0,MathMin(100,opacity))/100.0;
   int    r=(int)MathRound((tint&0xFF)*a+(back&0xFF)*(1-a));
   int    g=(int)MathRound(((tint>>8)&0xFF)*a+((back>>8)&0xFF)*(1-a));
   int    b=(int)MathRound(((tint>>16)&0xFF)*a+((back>>16)&0xFF)*(1-a));
   return((color)(r|(g<<8)|(b<<16)));
  }

//+------------------------------------------------------------------+
//| Records an object name as drawn on this render                   |
//+------------------------------------------------------------------+
void Keep(const string name)
  {
   int n=ArraySize(g_drawn);
   ArrayResize(g_drawn,n+1,64);
   g_drawn[n]=name;
  }

//+------------------------------------------------------------------+
//| Creates or moves a filled rectangle                              |
//+------------------------------------------------------------------+
void PutBox(const string name,const datetime t1,const double p1,const datetime t2,
            const double p2,const color tint)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_RECTANGLE,0,t1,p1,t2,p2);
      ObjectSetInteger(0,name,OBJPROP_FILL,true);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_TIME,0,t1);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,p1);
   ObjectSetInteger(0,name,OBJPROP_TIME,1,t2);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,p2);
   ObjectSetInteger(0,name,OBJPROP_COLOR,tint);
   Keep(name);
  }

//+------------------------------------------------------------------+
//| Creates or moves a horizontal segment                            |
//+------------------------------------------------------------------+
void PutLine(const string name,const datetime t1,const datetime t2,const double price,
             const color tint,const ENUM_LINE_STYLE style,const int width)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_TREND,0,t1,price,t2,price);
      ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_TIME,0,t1);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,price);
   ObjectSetInteger(0,name,OBJPROP_TIME,1,t2);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,tint);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   Keep(name);
  }

//+------------------------------------------------------------------+
//| Creates or moves a vertical line                                 |
//+------------------------------------------------------------------+
void PutVertical(const string name,const datetime t,const color tint,
                 const ENUM_LINE_STYLE style,const int width)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_VLINE,0,t,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_TIME,0,t);
   ObjectSetInteger(0,name,OBJPROP_COLOR,tint);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   Keep(name);
  }

//+------------------------------------------------------------------+
//| Creates or moves a text label with a tooltip                     |
//+------------------------------------------------------------------+
void PutText(const string name,const datetime t,const double price,const string text,
             const color tint,const ENUM_ANCHOR_POINT anchor,const string tip)
  {
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_TEXT,0,t,price);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_TIME,0,t);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,price);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,tint);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FONT_SIZE);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,tip);
   Keep(name);
  }

//+------------------------------------------------------------------+
//| Tooltip of a session pivot with its hit rate                     |
//+------------------------------------------------------------------+
string PivotTip(const CLayerState &st,const SessionMark &m,const bool top)
  {
   int    s=m.slot;
   int    hits=top ? st.topHits[s] : st.bottomHits[s];
   double price=top ? m.top : m.bottom;
   string rate=st.runs[s]>0 ? StringFormat("%.0f%%",100.0*hits/st.runs[s]) : "n/a";
   return(StringFormat("%s %s: %s\nDate: %s\n%s hit rate over %d sessions, since %s",
                       g_sessions[s].name,top ? "High" : "Low",DoubleToString(price,_Digits),
                       TimeToString(ToClock(m.opened),TIME_DATE),rate,st.runs[s],
                       TimeToString(ToClock(st.firstRun[s]),TIME_DATE)));
  }

//+------------------------------------------------------------------+
//| Draws the session layer                                          |
//+------------------------------------------------------------------+
void DrawSessions(const CLayerState &st)
  {
   for(int k=0; k<ArraySize(st.marks); k++)
     {
      SessionMark m=st.marks[k];
      color  tint=g_sessions[m.slot].tint;
      string base=TAG+"S"+IntegerToString(m.id);
      PutBox(base+"B",m.opened,m.top,m.lastIn,m.bottom,Faded(tint,InpBoxOpacity));
      if(!InpPivots)
         continue;
      PutLine(base+"H",m.topAt,MathMax(m.topUntil,m.topAt),m.top,tint,STYLE_SOLID,1);
      PutLine(base+"L",m.bottomAt,MathMax(m.bottomUntil,m.bottomAt),m.bottom,tint,STYLE_SOLID,1);
      if(InpMid)
        {
         datetime from=MathMax(m.topAt,m.bottomAt);
         PutLine(base+"M",from,MathMax(m.midUntil,from),(m.top+m.bottom)/2,tint,STYLE_DOT,1);
        }
      if(!InpPivotTags)
         continue;
      ENUM_ANCHOR_POINT upA=m.topOpen ? ANCHOR_LEFT : ANCHOR_LEFT_LOWER;
      ENUM_ANCHOR_POINT dnA=m.bottomOpen ? ANCHOR_LEFT : ANCHOR_LEFT_UPPER;
      PutText(base+"TH",MathMax(m.topUntil,m.topAt),m.top,
              g_sessions[m.slot].name+" High",tint,upA,PivotTip(st,m,true));
      PutText(base+"TL",MathMax(m.bottomUntil,m.bottomAt),m.bottom,
              g_sessions[m.slot].name+" Low",tint,dnA,PivotTip(st,m,false));
     }
  }

//+------------------------------------------------------------------+
//| Draws the day/week/month layer                                   |
//+------------------------------------------------------------------+
void DrawFrames(const CLayerState &st)
  {
   static const string tags[FRAMES]= {"D","W","M"};
   static const string words[FRAMES]= {"Day","Week","Month"};
   color tints[FRAMES];
   tints[0]=InpDayColor;
   tints[1]=InpWeekColor;
   tints[2]=InpMonthColor;
   for(int k=0; k<ArraySize(st.frames); k++)
     {
      FrameLine fl=st.frames[k];
      string    name=TAG+"F"+IntegerToString(fl.id);
      color     tint=tints[fl.frame];
      PutLine(name,fl.from,fl.until,fl.price,tint,STYLE_DOT,1);
      string text="P"+tags[fl.frame]+(fl.kind==KIND_HIGH ? "H" : fl.kind==KIND_LOW ? "L" : "M");
      string what=fl.kind==KIND_HIGH ? "High" : fl.kind==KIND_LOW ? "Low" : "Midline";
      string tip=StringFormat("%s %s: %s\nDate: %s","Previous "+words[fl.frame],
                              what,DoubleToString(fl.price,_Digits),TimeToString(ToClock(fl.period),TIME_DATE));
      if(fl.kind==KIND_HIGH || fl.kind==KIND_LOW)
        {
         int hits=(fl.kind==KIND_HIGH) ? st.totals[fl.frame].highHits : st.totals[fl.frame].lowHits;
         if(st.totals[fl.frame].periods>0)
            tip+=StringFormat("\n%.0f%% hit rate over %d %ss",100.0*hits/st.totals[fl.frame].periods,
                              st.totals[fl.frame].periods,StringSubstr(words[fl.frame],0)+"");
        }
      PutText(name+"T",fl.until,fl.price,text,tint,ANCHOR_LEFT,tip);
     }
  }

//+------------------------------------------------------------------+
//| Draws the opening prices and time markers                        |
//+------------------------------------------------------------------+
void DrawTimes(const CLayerState &st)
  {
   for(int k=0; k<ArraySize(st.opens); k++)
     {
      TimeLine ln=st.opens[k];
      string   name=TAG+"O"+IntegerToString(ln.id);
      PutLine(name,ln.from,ln.until,ln.price,g_times[ln.slot].tint,STYLE_DASH,1);
      PutText(name+"T",ln.until,ln.price,g_times[ln.slot].name,g_times[ln.slot].tint,ANCHOR_LEFT,
              StringFormat("%s: %s\nDate: %s",g_times[ln.slot].name,DoubleToString(ln.price,_Digits),
                           TimeToString(ToClock(ln.from),TIME_DATE)));
     }
   for(int k=0; k<ArraySize(st.stamps); k++)
      PutVertical(TAG+"V"+IntegerToString(st.stamps[k].id),st.stamps[k].from,
                  g_times[st.stamps[k].slot].tint,STYLE_DOT,1);
  }

//+------------------------------------------------------------------+
//| Redraws everything from a state and removes stale objects        |
//+------------------------------------------------------------------+
void Render(const CLayerState &st)
  {
   string before[];
   ArrayCopy(before,g_drawn);
   ArrayResize(g_drawn,0,64);
   DrawSessions(st);
   DrawFrames(st);
   DrawTimes(st);
   for(int k=0; k<ArraySize(before); k++)
     {
      bool still=false;
      for(int j=0; j<ArraySize(g_drawn) && !still; j++)
         still=(g_drawn[j]==before[k]);
      if(!still)
         ObjectDelete(0,before[k]);
     }
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Deletes every object of the indicator                            |
//+------------------------------------------------------------------+
void Wipe(void)
  {
   ObjectsDeleteAll(0,TAG);
   ArrayResize(g_drawn,0);
  }

//+------------------------------------------------------------------+
//| Indicator initialization: reads and checks the time inputs       |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   string nm[SESSIONS]= {InpS1Name,InpS2Name,InpS3Name,InpS4Name,InpS5Name};
   string tm[SESSIONS]= {InpS1Time,InpS2Time,InpS3Time,InpS4Time,InpS5Time};
   color  cl[SESSIONS]= {InpS1Color,InpS2Color,InpS3Color,InpS4Color,InpS5Color};
   for(int s=0; s<SESSIONS; s++)
     {
      string text=tm[s];
      StringTrimLeft(text);
      StringTrimRight(text);
      g_sessions[s].on=(text!="");
      g_sessions[s].name=nm[s];
      g_sessions[s].tint=cl[s];
      g_sessions[s].span=ParseSpan(text,false);
      if(g_sessions[s].on && !g_sessions[s].span.valid)
        {
         PrintFormat("Session %d time '%s' is not HHMM-HHMM",s+1,tm[s]);
         return(INIT_PARAMETERS_INCORRECT);
        }
     }
   string kt[SLOTS]= {InpK1Time,InpK2Time,InpK3Time};
   string kn[SLOTS]= {InpK1Name,InpK2Name,InpK3Name};
   color  kc[SLOTS]= {InpK1Color,InpK2Color,InpK3Color};
   for(int s=0; s<SLOTS; s++)
     {
      string text=kt[s];
      StringTrimLeft(text);
      StringTrimRight(text);
      g_times[s].on=(text!="");
      g_times[s].name=kn[s];
      g_times[s].tint=kc[s];
      g_times[s].span=ParseSpan(text,true);
      if(g_times[s].on && !g_times[s].span.valid)
        {
         PrintFormat("Key time %d '%s' is not HHMM",s+1,kt[s]);
         return(INIT_PARAMETERS_INCORRECT);
        }
     }
   g_doneBar=-1;
   g_done.Clear();
   Wipe();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Indicator deinitialization: removes the drawings                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Wipe();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Indicator iteration: confirms closed bars, previews the open one |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],const long &volume[],
                const int &spread[])
  {
   if(rates_total<3)
      return(0);
   if(PeriodSeconds(_Period)>PeriodSeconds(InpMaxPeriod))
     {
      Wipe();
      return(rates_total);
     }
//--- history changed or first run: start again from a bounded window
   if(prev_calculated==0 || g_doneBar<0 || g_doneBar>rates_total-2 || time[g_doneBar]!=g_doneTime)
     {
      Wipe();
      g_done.Clear();
      g_doneBar=MathMax(1,rates_total-HISTORY)-1;
     }
   for(int i=g_doneBar+1; i<=rates_total-2; i++)
      StepBar(g_done,i,time,open,high,low,false);
   g_doneBar=rates_total-2;
   g_doneTime=time[g_doneBar];
//--- the bar in progress is applied to a copy, never to the confirmed state
   g_view.CopyFrom(g_done);
   StepBar(g_view,rates_total-1,time,open,high,low,prev_calculated>0);
   Render(g_view);
   return(rates_total);
  }
//+------------------------------------------------------------------+
