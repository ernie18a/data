//+------------------------------------------------------------------+
//|                                                    AcdEvents.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/24742 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/24742"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| CAcdEvents - turns a tick stream into a series of waits.         |
//|                                                                  |
//|  A tick here is a quote change, not a trade. Ticks sharing a     |
//|  millisecond fold into one event, since a zero wait is one burst |
//|  split into records. A wait over the gap threshold marks a new   |
//|  session instead of feeding the model a weekend-long wait.       |
//+------------------------------------------------------------------+
class CAcdEvents
  {
private:
   long              m_time[];         // event time in server milliseconds
   uchar             m_start[];        // 1 when the wait into this event crossed a gap
   int               m_total;
   int               m_capacity;

   long              m_gap_ms;         // waits above this open a new session
   long              m_last_msc;       // time of the newest event, -1 when empty
   long              m_ticks;          // ticks offered
   long              m_merged;         // ticks folded into an existing event
   long              m_sessions;       // session starts, the first event included

   bool              Reserve(const int need);

public:
                     CAcdEvents(void);

//--- waits longer than this many seconds are treated as a closed market
   void              SetGapSeconds(const int seconds);
   int               GapSeconds(void) const { return (int)(m_gap_ms/1000); }

   void              Clear(void);

//--- append time-ordered ticks; callable repeatedly, a day at a time
   int               AddTicks(const MqlTick &ticks[],const int count);

//--- load [from, to) from the terminal's tick history, a day at a time
   bool              Load(const string symbol,const datetime from,const datetime to);

   int               Total(void)             const { return m_total;    }
   long              Time(const int i)       const { return m_time[i];  }
   bool              IsStart(const int i)    const { return m_start[i]!=0; }
   uchar             StartFlag(const int i)  const { return m_start[i]; }

//--- milliseconds since the previous event; meaningless at a start
   double            Wait(const int i) const;

//--- first event whose time is at or after t_msc
   int               FindTime(const long t_msc) const;

   long              TicksRead(void)   const { return m_ticks;    }
   long              TicksMerged(void) const { return m_merged;   }
   long              Sessions(void)    const { return m_sessions; }
  };

//+------------------------------------------------------------------+
//| Five-minute session gap by default.                              |
//+------------------------------------------------------------------+
CAcdEvents::CAcdEvents(void)
  {
   m_gap_ms  =300000;
   m_capacity=0;
   Clear();
  }

//+------------------------------------------------------------------+
//| Set the session-gap threshold. Existing events keep their flags. |
//+------------------------------------------------------------------+
void CAcdEvents::SetGapSeconds(const int seconds)
  {
   m_gap_ms=(seconds>0 ? (long)seconds*1000 : 300000);
  }

//+------------------------------------------------------------------+
//| Drop every event and counter, keeping the allocated memory.      |
//+------------------------------------------------------------------+
void CAcdEvents::Clear(void)
  {
   m_total   =0;
   m_last_msc=-1;
   m_ticks   =0;
   m_merged  =0;
   m_sessions=0;
  }

//+------------------------------------------------------------------+
//| Grow storage geometrically.                                      |
//+------------------------------------------------------------------+
bool CAcdEvents::Reserve(const int need)
  {
   if(need<=m_capacity)
      return true;
   int cap=(m_capacity<1024 ? 1024 : m_capacity);
   while(cap<need)
      cap=(cap<INT_MAX/2 ? cap*2 : need);
   if(ArrayResize(m_time,cap)!=cap || ArrayResize(m_start,cap)!=cap)
     {
      PrintFormat("CAcdEvents: cannot hold %d events",cap);
      return false;
     }
   m_capacity=cap;
   return true;
  }

//+------------------------------------------------------------------+
//| Fold, flag and append; returns the number of events created.     |
//| An out-of-order tick is merged, so no wait is ever negative.     |
//+------------------------------------------------------------------+
int CAcdEvents::AddTicks(const MqlTick &ticks[],const int count)
  {
   if(count<=0 || !Reserve(m_total+count))
      return 0;

   const int before=m_total;
   for(int i=0;i<count;i++)
     {
      const long t=(long)ticks[i].time_msc;
      m_ticks++;
      if(m_last_msc>=0 && t<=m_last_msc)
        {
         m_merged++;
         continue;
        }

      const bool start=(m_last_msc<0 || t-m_last_msc>m_gap_ms);
      m_time[m_total] =t;
      m_start[m_total]=(uchar)(start ? 1 : 0);
      if(start)
         m_sessions++;
      m_total++;
      m_last_msc=t;
     }
   return m_total-before;
  }

//+------------------------------------------------------------------+
//| Load a range one calendar day per request, to cap memory. A      |
//| failed day is skipped, since a retry would block just as long.   |
//+------------------------------------------------------------------+
bool CAcdEvents::Load(const string symbol,const datetime from,const datetime to)
  {
   if(to<=from)
      return false;
   if(!SymbolSelect(symbol,true))
     {
      PrintFormat("CAcdEvents: symbol %s is not available",symbol);
      return false;
     }

   MqlTick buf[];
   int failed=0;
   for(datetime day=from;day<to && !IsStopped();day+=86400)
     {
      const datetime next=(day+86400<to ? day+86400 : to);
      ResetLastError();
      const int n=CopyTicksRange(symbol,buf,COPY_TICKS_INFO,
                                 (ulong)day*1000,(ulong)next*1000-1);
      if(n<0)
        {
         failed++;
         PrintFormat("CAcdEvents: %s %s not loaded (error %d)",
                     symbol,TimeToString(day,TIME_DATE),GetLastError());
         continue;
        }
      if(n==0)
         continue;
      if(!Reserve(m_total+n))
         return false;
      AddTicks(buf,n);
     }
   ArrayFree(buf);

   if(m_total<2)
     {
      PrintFormat("CAcdEvents: no usable ticks for %s between %s and %s",
                  symbol,TimeToString(from),TimeToString(to));
      return false;
     }
   if(failed>0)
      PrintFormat("CAcdEvents: %d day(s) of %s could not be loaded",failed,symbol);
   return true;
  }

//+------------------------------------------------------------------+
//| Wait into event i in milliseconds.                               |
//+------------------------------------------------------------------+
double CAcdEvents::Wait(const int i) const
  {
   if(i<=0 || i>=m_total)
      return 0.0;
   return (double)(m_time[i]-m_time[i-1]);
  }

//+------------------------------------------------------------------+
//| Binary search for the first event at or after a time.            |
//+------------------------------------------------------------------+
int CAcdEvents::FindTime(const long t_msc) const
  {
   int lo=0,hi=m_total;
   while(lo<hi)
     {
      const int mid=(lo+hi)/2;
      if(m_time[mid]<t_msc)
         lo=mid+1;
      else
         hi=mid;
     }
   return lo;
  }
//+------------------------------------------------------------------+
