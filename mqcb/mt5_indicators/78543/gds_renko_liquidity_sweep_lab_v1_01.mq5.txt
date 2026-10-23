//+------------------------------------------------------------------+
//| GDS Renko Liquidity Sweep Lab                                    |
//| Educational price-level study. No orders or trade signals.       |
//| Copyright 2026 Golden Delta / Andrey Goida.                       |
//| A single-file indicator; no external libraries or custom symbol. |
//+------------------------------------------------------------------+
#property copyright "Golden Delta / Andrey Goida"
#property link      "https://www.mql5.com/en/users/gavaav"
#property version   "1.01"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_NONE
#property tester_everytick_calculate
#property description "Study breaches of confirmed Renko swing levels, reclaims and acceptance."
#property description "Historical BID ticks, classic two-brick reversals, forward-only processing."
#property description "Liquidity is a price-pattern label, not observed order-book liquidity."
#property description "No orders. Outcome statistics are price changes, not trading returns."

input double InpBrickSize          = 0.0;  // Brick in price units; 0 = 200 symbol points
input datetime InpHistoryStart     = 0;    // Server time; 0 = trailing history then live
input int    InpHistoryHours       = 72;   // History duration in hours (1..720)
input int    InpMinRunBricks        = 2;    // Minimum completed run before a swing (1..20)
input double InpSweepBufferBricks  = 0.25; // Minimum breach beyond level, in bricks (0..5)
input double InpReclaimBufferBricks= 0.0;  // Required return inside level, in bricks (0..2)
input int    InpAcceptanceBricks   = 2;    // Consecutive closes outside after breach (1..20)
input int    InpMaxWaitBricks      = 12;   // Classification deadline in completed bricks (2..200)
input int    InpLevelMaxAgeBricks  = 80;   // Expire an unbreached level after this many bricks (5..2000)
input int    InpOutcomeBricks      = 5;    // Follow-up horizon after classification (1..100)
const int VISIBLE_BRICKS=80;

#define LAB_KEEP 256
#define LAB_EVENTS 20000
#define LAB_ACTIVE 256
#define LAB_TICK_BRICKS 4096

// CORE_BEGIN: pure sequential logic, also exercised by the host tests.
struct SLabBrick
  {
   long open,close,index,stamp;
   int dir;
  };
struct SLabLevel
  {
   bool armed;
   int side;                       // +1 upper swing, -1 lower swing
   long price,confirmed_brick,confirmed_seq,confirmed_msc;
  };
struct SLabEvent
  {
   int id,side,state,outside;       // 0 waiting, 1 reclaim, 2 acceptance, 3 expired
   long level,level_brick,level_msc,level_seq;
   long breach_seq,breach_brick,breach_msc;
   long resolved_seq,resolved_brick,resolved_msc,reference;
   bool measured;
   long outcome_msc,outcome_brick,outcome_price,outcome_seq;
   double move,mfe,mae;             // Signed directional price change / brick size
  };
struct SLabStats
  {
   int classified,measured,positive;
   double sum_move,sum_mfe,sum_mae;
  };

class CSweepLab
  {
public:
   long size,sweep,inside,total,seq,last_price,last_msc,rows,skipped;
   int min_run,acceptance,max_wait,max_age,horizon;
   int dir,run,kept,event_count,active_count,expired,expired_levels;
   bool anchored,full_run,failed;
   long close;
   SLabBrick bricks[LAB_KEEP];
   SLabLevel levels[2];
   SLabEvent events[LAB_EVENTS];
   int active[LAB_ACTIVE];
   SLabStats stats[2];

   void Init(const long brick_size,const long breach_size,const long inside_size,
             const int minimum_run,const int outside_closes,const int deadline,
             const int level_age,const int followup)
     {
      size=brick_size; sweep=breach_size; inside=inside_size;
      min_run=minimum_run; acceptance=outside_closes; max_wait=deadline;
      max_age=level_age; horizon=followup;
      total=0; seq=0; last_price=0; last_msc=0; rows=0; skipped=0;
      dir=0; run=0; close=0; kept=0; event_count=0; active_count=0;
      expired=0; expired_levels=0; anchored=false; full_run=false; failed=false;
      for(int i=0;i<2;i++)
        {
         SLabLevel blank_level={}; levels[i]=blank_level;
         SLabStats blank_stats={}; stats[i]=blank_stats;
        }
     }

   void Arm(const int side,const long price,const long stamp)
     {
      const int slot=(side>0 ? 0 : 1);
      SLabLevel lev={};
      lev.armed=true; lev.side=side; lev.price=price;
      lev.confirmed_brick=total; lev.confirmed_seq=seq; lev.confirmed_msc=stamp;
      levels[slot]=lev; // Latest confirmed swing on each side replaces the old unbreached one.
     }

   bool Breach(const int slot,const long stamp)
     {
      if(event_count>=LAB_EVENTS || active_count>=LAB_ACTIVE)
        { failed=true; return false; } // Stop explicitly; never discard samples silently.
      SLabEvent ev={};
      ev.id=event_count+1; ev.side=levels[slot].side; ev.level=levels[slot].price;
      ev.level_brick=levels[slot].confirmed_brick; ev.level_msc=levels[slot].confirmed_msc;
      ev.level_seq=levels[slot].confirmed_seq;
      ev.breach_seq=seq; ev.breach_brick=total; ev.breach_msc=stamp;
      events[event_count]=ev; active[active_count++]=event_count++;
      levels[slot].armed=false; // Exactly one event per confirmed level.
      return true;
     }

   void Resolve(const int index,const int state,const long price,const long stamp)
     {
      events[index].state=state;
      events[index].resolved_seq=seq; events[index].resolved_brick=total;
      events[index].resolved_msc=stamp; events[index].reference=price;
      if(state==3) expired++;
      else stats[state-1].classified++;
     }

   // p is an actual BID rounded to the symbol's integer tick grid.
   bool Feed(const long p,const long stamp)
     {
      if(failed) return false;
      rows++;
      if(p<=0 || stamp<=0) { skipped++; return true; }
      if(last_msc>stamp) { failed=true; return false; }
      if(!anchored)
        { close=p; last_price=p; last_msc=stamp; anchored=true; seq++; return true; }

      // Count the whole tick before changing the builder; never truncate a price gap.
      const long delta=p-close;
      long count=0;
      int new_dir=dir;
      bool reversal=false;
      if(dir==0)
        {
         if(delta>=size) { new_dir=1; count=delta/size; }
         else if(delta<=-size) { new_dir=-1; count=(-delta)/size; }
        }
      else if(dir>0)
        {
         if(delta>=size) count=delta/size;
         else if(delta<=-2*size) { new_dir=-1; count=(-delta)/size-1; reversal=true; }
        }
      else
        {
         if(delta<=-size) count=(-delta)/size;
         else if(delta>=2*size) { new_dir=1; count=delta/size-1; reversal=true; }
        }
      if(count>LAB_TICK_BRICKS) { failed=true; return false; }
      seq++; last_price=p; last_msc=stamp;

      // A level must already have been known BEFORE this real tick.
      for(int s=0;s<2;s++)
        {
         if(!levels[s].armed) continue;
         if(total-levels[s].confirmed_brick>max_age)
           { levels[s].armed=false; expired_levels++; continue; }
         if(levels[s].confirmed_seq<seq && levels[s].side*(p-levels[s].price)>=sweep)
            if(!Breach(s,stamp)) return false;
        }

      for(int j=0;j<(int)count;j++)
        {
         const long previous_close=close;
         const long open=close+((reversal && j==0) ? new_dir*size : 0);
         close=open+new_dir*size; total++;
         if(new_dir!=dir && dir!=0)
           {
            // The first run is cut by the history boundary and is not a valid swing.
            if(full_run && run>=min_run) Arm(dir,previous_close,stamp);
            full_run=true;
           }
         if(new_dir==dir) run++;
         else { dir=new_dir; run=1; }
         const int slot=(int)((total-1)%LAB_KEEP);
         SLabBrick b={}; b.open=open; b.close=close; b.index=total; b.stamp=stamp; b.dir=dir;
         bricks[slot]=b; if(kept<LAB_KEEP) kept++;

         for(int a=0;a<active_count;a++)
           {
            const int i=active[a];
            if(events[i].state!=0 || events[i].breach_seq>=seq) continue;
            if(events[i].side*(close-events[i].level)>=sweep) events[i].outside++;
            else events[i].outside=0;
           }
        }

      // Classify at the END of the real tick. Synthetic gap bricks are not entry prices.
      for(int a=0;a<active_count;)
        {
         const int i=active[a];
         // The breach belongs to the whole actual tick, including all its gap bricks.
         // Deadlines start AFTER that tick, matching the acceptance counter.
         if(events[i].breach_seq==seq) events[i].breach_brick=total;
         if(events[i].state==0 && total-events[i].breach_brick>max_wait)
            Resolve(i,3,p,stamp);
         if(events[i].state==0 && count>0 && events[i].breach_seq<seq)
           {
            const long dc=events[i].side*(close-events[i].level);
            const long dp=events[i].side*(p-events[i].level);
            // If a gap has jumped beyond the deadline, its eventual state is censored.
            if(dc<=-inside && dp<=-inside) Resolve(i,1,p,stamp);
            else if(events[i].outside>=acceptance && dc>=sweep && dp>=sweep) Resolve(i,2,p,stamp);
            else if(total-events[i].breach_brick==max_wait) Resolve(i,3,p,stamp);
           }

         if((events[i].state==1 || events[i].state==2) && events[i].resolved_seq<seq)
           {
            const int direction=(events[i].state==1 ? -events[i].side : events[i].side);
            const double move=(double)(direction*(p-events[i].reference))/(double)size;
            events[i].mfe=MathMax(events[i].mfe,move);
            events[i].mae=MathMax(events[i].mae,-move);
            if(total-events[i].resolved_brick>=horizon)
              {
               events[i].measured=true; events[i].move=move;
               events[i].outcome_msc=stamp; events[i].outcome_brick=total;
               events[i].outcome_price=p;
               events[i].outcome_seq=seq;
               const int s=events[i].state-1;
               stats[s].measured++; if(move>0) stats[s].positive++;
               stats[s].sum_move+=move; stats[s].sum_mfe+=events[i].mfe; stats[s].sum_mae+=events[i].mae;
              }
           }
         if(events[i].state==3 || events[i].measured)
           { active[a]=active[--active_count]; }
         else a++;
        }
      return true;
     }

   bool Brick(const long index,SLabBrick &b)
     {
      if(index<1 || index>total || index<=total-kept) return false;
      b=bricks[(int)((index-1)%LAB_KEEP)]; return true;
     }
   int WaitingClass(void)
     {
      int n=0;
      for(int a=0;a<active_count;a++) if(events[active[a]].state==0) n++;
      return n;
     }
  };
// CORE_END

CSweepLab g_lab;
double g_dummy[],g_grid=0.0,g_brick=0.0;
string g_prefix="GDS_RLS010_",g_message="Preparing broker tick history...";
string g_export_notice="";
ulong g_notice_until=0;
bool g_owns_chart=false,g_paused=false,g_stop=false,g_started=false,g_dirty=true;
bool g_tester=false,g_dashboard_allowed=true,g_timer_active=false;
ulong g_next_dashboard_try=0,g_last_pump=0;
long g_old_show=1,g_old_background=0,g_last_raw=0;
ulong g_start=0,g_fixed_end=0,g_cursor=0,g_chunk_end=0,g_target=0,g_retry_after=0,g_last_draw=0;
int g_tick_index=0,g_failures=0,g_chunks=0,g_digits=0;
MqlTick g_ticks[];

const color C_BG=C'12,18,28',C_PANEL=C'20,29,42',C_GRID=C'38,51,67';
const color C_TEXT=C'226,234,244',C_MUTED=C'143,164,187',C_UP=C'39,196,164';
const color C_DOWN=C'239,102,123',C_RECLAIM=C'72,190,236',C_ACCEPT=C'240,189,86';

string Stamp(const long msc,const bool full=true)
  {
   if(msc<=0) return "-";
   return TimeToString((datetime)(msc/1000),(full ? TIME_DATE|TIME_SECONDS : TIME_SECONDS));
  }
string Price(const long units) { return DoubleToString((double)units*g_grid,g_digits); }
string StateName(const int state)
  {
   if(state==1) return "RECLAIM";
   if(state==2) return "ACCEPTANCE";
   if(state==3) return "EXPIRED";
   return "WAITING";
  }
void Halt(const string why)
  {
   g_stop=true; g_message=why; g_dirty=true;
   Print("GDS Renko Sweep Lab: ",why);
  }

// No history request in OnInit. Indicator history requests may need asynchronous retries.
bool StartHistory(void)
  {
   MqlTick quote={};
   if(!SymbolInfoTick(_Symbol,quote) || quote.time_msc<=0)
     { g_message="Waiting for the first broker quote..."; return false; }
   const long beginning=(InpHistoryStart>0 ? (long)InpHistoryStart*1000 : quote.time_msc-(long)InpHistoryHours*3600000);
   if(beginning>quote.time_msc)
     { g_message="Start is later than the latest quote. Change the start."; return false; }
   g_start=(ulong)(beginning>0 ? beginning : 1);
   g_fixed_end=(InpHistoryStart>0 ? g_start+(ulong)InpHistoryHours*3600000-1 : 0);
   g_cursor=g_start; g_target=(ulong)quote.time_msc-1;
   if(g_fixed_end>0 && g_target>g_fixed_end) g_target=g_fixed_end;
   g_started=true; g_message="Loading BID ticks in chronological order...";
   return true;
  }

bool LoadChunk(void)
  {
   // Retry delays follow simulated time in the tester, wall time on a normal chart.
   const ulong now=(g_tester ? (ulong)TimeCurrent()*1000 : GetTickCount64());
   if(now<g_retry_after) return false;
   MqlTick quote={};
   if(!SymbolInfoTick(_Symbol,quote) || quote.time_msc<=1) return false;
   // Only sealed milliseconds: no same-millisecond tail is discarded between calls.
   g_target=(ulong)quote.time_msc-1;
   if(g_fixed_end>0 && g_target>g_fixed_end) g_target=g_fixed_end;
   if(g_cursor>g_target) return false;
   g_chunk_end=g_cursor+59999;
   if(g_chunk_end>g_target) g_chunk_end=g_target;
   ResetLastError();
   const int n=CopyTicksRange(_Symbol,g_ticks,COPY_TICKS_INFO,g_cursor,g_chunk_end);
   const int error=GetLastError();
   if(n<0 || error!=0)
     {
      // A positive partial return with a synchronization error is NOT committed.
      ArrayResize(g_ticks,0); g_tick_index=0; g_failures++;
      const int delay=(g_failures<5 ? (1<<g_failures) : 30);
      g_retry_after=now+(ulong)delay*1000;
      g_message=StringFormat("Waiting for tick history: error %d. Retry in %d s.",error,delay);
      if(g_failures==1) Print("GDS Renko Sweep Lab: tick history is not ready (",error,"). Retrying automatically.");
      g_dirty=true; return false;
     }
   if(g_failures>0) Print("GDS Renko Sweep Lab: tick history is available; resuming.");
   g_failures=0; g_retry_after=0; g_tick_index=0; g_chunks++;
   if(n==0) g_cursor=g_chunk_end+1; // Empty successful windows, including maintenance/weekends.
   return true;
  }

void Pump(void)
  {
   if(g_stop || g_paused) return;
   if(!g_started && !StartHistory()) return;
   const ulong begin=GetTickCount64();
   int processed=0,loads=0;
   while(!IsStopped() && !g_stop && processed<20000 && GetTickCount64()-begin<35)
     {
      const int n=ArraySize(g_ticks);
      if(g_tick_index>=n)
        {
         if(n>0) { g_cursor=g_chunk_end+1; ArrayResize(g_ticks,0); g_tick_index=0; }
         if(loads>=12) break;
         loads++;
         if(!LoadChunk()) break;
         if(ArraySize(g_ticks)==0) continue;
        }
      const MqlTick tick=g_ticks[g_tick_index++]; processed++;
      if(tick.time_msc<g_last_raw || (ulong)tick.time_msc<g_cursor || (ulong)tick.time_msc>g_chunk_end)
        { Halt("Stopped: tick history is not ordered. Reload on a new chart."); break; }
      g_last_raw=tick.time_msc;
      if(!MathIsValidNumber(tick.bid) || tick.bid<=0 || tick.bid/g_grid>1.0e12)
        { g_lab.rows++; g_lab.skipped++; continue; }
      if(!g_lab.Feed((long)MathRound(tick.bid/g_grid),tick.time_msc))
        { Halt("Stopped: capacity/order/price-gap limit. Export, then use fewer history hours or a larger brick."); break; }
      g_dirty=true;
     }
   if(!g_stop && g_failures==0)
     {
      if(g_lab.seq==0 && g_cursor>g_target) g_message="No valid BID ticks. Check history or change the interval.";
      else if(g_fixed_end>0 && g_cursor>g_fixed_end) g_message="Fixed interval complete. Ready to export.";
      else if(g_cursor<=g_target) g_message="Loading BID history. Statistics are provisional.";
      else g_message="History loaded. Waiting for new broker ticks.";
     }
  }

// Pixel-based dashboard. Only two chart properties are changed and both are restored.
bool Make(const string key,const ENUM_OBJECT type)
  {
   const string name=g_prefix+key;
   if(ObjectFind(0,name)>=0) return true;
   if(!ObjectCreate(0,name,type,0,0,0)) return false;
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,"\n");
   return true;
  }
void Box(const string key,const int x,const int y,const int w,const int h,const color fill,const color border)
  {
   if(!Make(key,OBJ_RECTANGLE_LABEL)) return;
   const string n=g_prefix+key;
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_XSIZE,MathMax(1,w)); ObjectSetInteger(0,n,OBJPROP_YSIZE,MathMax(1,h));
   ObjectSetInteger(0,n,OBJPROP_BGCOLOR,fill); ObjectSetInteger(0,n,OBJPROP_COLOR,border);
   ObjectSetInteger(0,n,OBJPROP_BORDER_TYPE,BORDER_FLAT); ObjectSetInteger(0,n,OBJPROP_WIDTH,1);
  }
void Text(const string key,const int x,const int y,const string value,const color ink,const int size=10)
  {
   if(!Make(key,OBJ_LABEL)) return;
   const string n=g_prefix+key;
   ObjectSetInteger(0,n,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_COLOR,ink); ObjectSetInteger(0,n,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,n,OBJPROP_FONT,"Arial");
   ObjectSetString(0,n,OBJPROP_TEXT,(value=="" ? " " : value));
  }
void Button(const string key,const int x,const int y,const string value)
  {
   if(!Make(key,OBJ_BUTTON)) return;
   const string n=g_prefix+key;
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_XSIZE,100); ObjectSetInteger(0,n,OBJPROP_YSIZE,29);
   ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C_PANEL); ObjectSetInteger(0,n,OBJPROP_COLOR,C_TEXT);
   ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C_GRID); ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,n,OBJPROP_ZORDER,10); ObjectSetInteger(0,n,OBJPROP_STATE,false);
   ObjectSetString(0,n,OBJPROP_TEXT,value);
  }
void Remove(const string key) { ObjectDelete(0,g_prefix+key); }
int YPrice(const double price,const double low,const double high,const int top,const int height)
  { return top+(int)MathRound((high-price)/(high-low)*height); }
int XBrick(const long index,const long first,const int x,const int step)
  { return x+(int)(index-first)*step; }

void DrawChart(const int x,const int y,const int width,const int height)
  {
   Box("plot",x,y,width,height,C_PANEL,C_GRID);
   const int left=x+12,right=x+width-86,top=y+38,bottom=y+height-23;
   const int count=(int)MathMin(g_lab.kept,VISIBLE_BRICKS);
   const int step=(int)MathMax(3,(right-left)/VISIBLE_BRICKS);
   const int first_x=right-count*step;
   const long first=g_lab.total-count+1;
   double low=(double)g_lab.last_price-g_lab.size*2,high=(double)g_lab.last_price+g_lab.size*2;
   SLabBrick b={};
   for(int j=0;j<count;j++)
     {
      if(!g_lab.Brick(first+j,b)) continue;
      low=MathMin(low,MathMin(b.open,b.close)); high=MathMax(high,MathMax(b.open,b.close));
     }
   low-=g_lab.size; high+=g_lab.size;
   if(low<0) low=0;
   if(high<=low) high=low+1;
   for(int i=0;i<5;i++)
     {
      const int gy=top+i*(bottom-top)/4;
      Box("grid"+(string)i,left,gy,right-left,1,C_GRID,C_GRID);
      const double p=high-(high-low)*i/4.0;
      Text("scale"+(string)i,right+8,gy-7,DoubleToString(p*g_grid,g_digits),C_MUTED,8);
     }
   for(int j=0;j<VISIBLE_BRICKS;j++)
     {
      if(j>=count) { Remove("brick"+(string)j); continue; }
      g_lab.Brick(first+j,b);
      const int ya=YPrice((double)MathMax(b.open,b.close),low,high,top,bottom-top);
      const int yb=YPrice((double)MathMin(b.open,b.close),low,high,top,bottom-top);
      const color ink=(b.dir>0 ? C_UP : C_DOWN);
      Box("brick"+(string)j,first_x+j*step,ya,(int)MathMax(2,step-2),(int)MathMax(2,yb-ya),ink,ink);
     }
   for(int s=0;s<2;s++)
     {
      const SLabLevel level=g_lab.levels[s];
      const string key="lev"+(string)s;
      if(!level.armed || level.price<low || level.price>high)
        { Remove(key); Remove(key+"t"); continue; }
      const int ly=YPrice((double)level.price,low,high,top,bottom-top);
      const int lx=(int)MathMax(left,XBrick(level.confirmed_brick,first,first_x,step));
      const color ink=(s==0 ? C_DOWN : C_UP);
      Box(key,lx,ly,(int)MathMax(2,right-lx),1,ink,ink);
      Text(key+"t",left+5,ly-15,(s==0 ? "HIGH " : "LOW ")+Price(level.price),ink,8);
     }
   // Retain a few consumed levels so a reclaim/acceptance can be read on the chart.
   int lines=0;
   for(int i=g_lab.event_count-1;i>=0 && lines<6;i--)
     {
      const SLabEvent e=g_lab.events[i];
      const long end=(e.state==0 ? g_lab.total : e.resolved_brick);
      if(end<first || e.level<low || e.level>high) continue;
      const string key="past"+(string)lines;
      const int lx=(int)MathMax(left,XBrick(e.level_brick,first,first_x,step));
      const int rx=(int)MathMin(right,XBrick(end,first,first_x,step)+step);
      const int ly=YPrice((double)e.level,low,high,top,bottom-top);
      const color ink=(e.state==1 ? C_RECLAIM : (e.state==2 ? C_ACCEPT : C_MUTED));
      Box(key,lx,ly,(int)MathMax(2,rx-lx),1,ink,ink);
      if(e.breach_brick>=first)
        {
         const int bx=(int)MathMin(right-25,XBrick(e.breach_brick,first,first_x,step));
         Text(key+"t",bx,ly+(e.side>0 ? -15 : 3),"S"+(string)e.id,C_MUTED,8);
        }
      else Remove(key+"t");
      lines++;
     }
   for(int i=lines;i<6;i++) { Remove("past"+(string)i); Remove("past"+(string)i+"t"); }
   int shown=0;
   for(int i=g_lab.event_count-1;i>=0 && shown<16;i--)
     {
      const SLabEvent e=g_lab.events[i];
      if(e.state!=1 && e.state!=2) continue;
      if(e.resolved_brick<first || e.resolved_brick>g_lab.total) continue;
      const string key="event"+(string)shown;
      const int mx=XBrick(e.resolved_brick,first,first_x,step);
      const int my=top+3+(shown%3)*16;
      const color ink=(e.state==1 ? C_RECLAIM : C_ACCEPT);
      Text(key,mx,my,(e.state==1 ? "R" : "A")+(string)e.id,ink,8);
      ObjectSetString(0,g_prefix+key,OBJPROP_TOOLTIP,StateName(e.state)+" | "+Stamp(e.resolved_msc)+" | level "+Price(e.level));
      shown++;
     }
   for(int j=shown;j<16;j++) Remove("event"+(string)j);
   Text("legend",left,y+10,"RENKO  |  S: breach   R: reclaim   A: acceptance",C_TEXT,9);
   Text("axis",left,bottom+6,"Brick sequence | events appear at confirmation",C_MUTED,8);
   if(g_lab.seq>0)
     {
      const int py=YPrice((double)g_lab.last_price,low,high,top,bottom-top);
      Box("bid",left,py,right-left,1,C_RECLAIM,C_RECLAIM);
      Text("bidt",right-120,y+10,"BID "+Price(g_lab.last_price),C_RECLAIM,9);
     }
   else { Remove("bid"); Text("bidt",left+15,top+45,"Waiting for valid historical BID ticks...",C_MUTED,10); }
  }

void Draw(void)
  {
   if(!g_owns_chart) return;
   const int w=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   const int h=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   if(w<760 || h<520)
     {
      // Avoid stale overflowing objects when the chart becomes too small.
      ObjectsDeleteAll(0,g_prefix,0,-1);
      Text("owner",20,20,"GDS RENKO SWEEP LAB - enlarge chart to at least 760 x 520",C_TEXT,12);
      ChartRedraw(); return;
     }
   Text("owner",22,17,"GDS RENKO LIQUIDITY SWEEP LAB",C_TEXT,18);
   Text("badge",w-140,24,"RESEARCH ONLY",C_UP,9);
   Text("subtitle",24,48,_Symbol+" | brick "+DoubleToString(g_brick,g_digits)+
        " | BID ticks | 2-brick reversal",C_MUTED,10);
   Button("pause",w-238,76,(g_paused ? "RESUME" : "PAUSE"));
   Button("export",w-126,76,"EXPORT CSV");
   const string mode=(g_stop ? "STOPPED" : (!g_started ? "WAITING" : (g_paused ? "PAUSED" :
      (g_fixed_end>0 && g_cursor>g_fixed_end ? "COMPLETE" : (g_cursor<=g_target ? "LOADING" : "READY")))));
   Text("clock",24,82,mode+"  |  "+Stamp(g_lab.last_msc),g_stop ? C_DOWN : C_RECLAIM,10);
   ObjectSetString(0,g_prefix+"clock",OBJPROP_TOOLTIP,"Start: "+Stamp((long)g_start)+
      (g_fixed_end>0 ? " | End: "+Stamp((long)g_fixed_end) : " | Continues when new broker ticks arrive"));
   const int card_w=(w-60)/4;
   for(int c=0;c<4;c++)
     {
      const int cx=24+c*(card_w+4);
      Box("card"+(string)c,cx,119,card_w,64,C_PANEL,C_GRID);
      string label="LEVEL BREACHES",value=(string)g_lab.event_count;
      color ink=C_TEXT;
      if(c==1) { label="RECLAIM"; value=(string)g_lab.stats[0].classified; ink=C_RECLAIM; }
      if(c==2) { label="ACCEPTANCE"; value=(string)g_lab.stats[1].classified; ink=C_ACCEPT; }
      if(c==3) { label="WAITING / EXPIRED"; value=(string)g_lab.WaitingClass()+" / "+(string)g_lab.expired; ink=C_MUTED; }
      Text("cl"+(string)c,cx+12,127,label,C_MUTED,8);
      Text("cv"+(string)c,cx+12,146,value,ink,18);
     }
   const int chart_h=(int)MathMax(130,h-410);
   DrawChart(24,198,w-48,chart_h);
   const int sy=198+chart_h+12,split=(int)(w*0.52);
   Text("stitle",24,sy,"AFTER "+(string)InpOutcomeBricks+" BRICKS | price / brick",C_TEXT,9);
   const int sw=split-42;
   const int nx=24+(int)(sw*0.25),mx=24+(int)(sw*0.38),px=24+(int)(sw*0.56),ex=24+(int)(sw*0.73);
   Text("sh0",24,sy+23,"Type",C_MUTED,8); Text("sh1",nx,sy+23,"N",C_MUTED,8);
   Text("sh2",mx,sy+23,"Mean",C_MUTED,8); Text("sh3",px,sy+23,"Pos %",C_MUTED,8);
   Text("sh4",ex,sy+23,"MFE / MAE",C_MUTED,8);
   for(int s=0;s<2;s++)
     {
      const SLabStats st=g_lab.stats[s];
      const double n=(double)st.measured;
      Text("stype"+(string)s,24,sy+43+s*23,(s==0 ? "Reclaim" : "Accept"),s==0 ? C_RECLAIM : C_ACCEPT,9);
      Text("sn"+(string)s,nx,sy+43+s*23,(string)st.measured,C_TEXT,9);
      Text("sm"+(string)s,mx,sy+43+s*23,(n>0 ? StringFormat("%+.2f",st.sum_move/n) : "-"),C_TEXT,9);
      Text("sp"+(string)s,px,sy+43+s*23,(n>0 ? DoubleToString(100.0*st.positive/n,1) : "-"),C_TEXT,9);
      Text("se"+(string)s,ex,sy+43+s*23,(n>0 ? StringFormat("%.2f / %.2f",st.sum_mfe/n,st.sum_mae/n) : "-"),C_TEXT,8);
     }
   // Keep the footer clear of the fourth recent-event row on short charts.
   Remove("scaption");
   Text("rtitle",split,sy,"LATEST EVENTS | level / state / move",C_TEXT,9);
   for(int j=0;j<4;j++)
     {
      const int i=g_lab.event_count-1-j;
      string row=""; color ink=C_MUTED;
      if(i>=0)
        {
         const SLabEvent e=g_lab.events[i];
         row="#"+(string)e.id+" "+(e.side>0 ? "HIGH " : "LOW ")+Price(e.level)+"  "+StateName(e.state);
         row+=(e.measured ? "  "+StringFormat("%+.2f",e.move)+" br" : (e.state==1 || e.state==2 ? "  pending" : ""));
         ink=(e.state==1 ? C_RECLAIM : (e.state==2 ? C_ACCEPT : C_MUTED));
        }
      Text("recent"+(string)j,split,sy+25+j*22,row,ink,9);
     }
   Text("counts",24,h-71,StringFormat("Rows %I64d | bricks %I64d",g_lab.rows,g_lab.total),C_MUTED,8);
   Text("counts2",split,h-71,StringFormat("Invalid BID %I64d | pending follow-up %d",
        g_lab.skipped,g_lab.active_count-g_lab.WaitingClass()),C_MUTED,8);
   // Short labels avoid platform-dependent text clipping; full status is in the tooltip.
   // Export feedback remains visible while the history pump continues in the background.
   const string status=(!g_stop && GetTickCount64()<g_notice_until ? g_export_notice : g_message);
   const string visible=(StringLen(status)>60 ? StringSubstr(status,0,57)+"..." : status);
   Text("status",24,h-50,visible,g_stop ? C_DOWN : C_MUTED,9);
   ObjectSetString(0,g_prefix+"status",OBJPROP_TOOLTIP,status);
   Text("note",24,h-27,"Research only | gross BID moves | no orders",C_MUTED,8);
   Text("note2",split,h-27,"Ctrl+I: settings | CSV path: see Experts",C_MUTED,8);
   g_last_draw=GetTickCount64(); g_dirty=false; ChartRedraw();
  }

// One row for every breach, including unresolved/expired outcomes. No winner-only export.
void Export(void)
  {
   MqlTick latest={};
   if(SymbolInfoTick(_Symbol,latest) && latest.time_msc>1) g_target=(ulong)latest.time_msc-1;
   if(g_fixed_end>0 && g_target>g_fixed_end) g_target=g_fixed_end;
   string safe=_Symbol;
   StringReplace(safe,"/","_"); StringReplace(safe,"\\","_"); StringReplace(safe,":","_");
   const string path="GDS_Renko_Sweep_Lab\\"+safe+"_"+(string)TimeLocal()+"_"+(string)GetTickCount64()+".csv";
   ResetLastError();
   const int f=FileOpen(path,FILE_WRITE|FILE_CSV|FILE_ANSI,',',CP_UTF8);
   if(f==INVALID_HANDLE)
     {
      g_export_notice="CSV could not be created; error "+(string)GetLastError();
      g_notice_until=GetTickCount64()+8000;
      Print("GDS Renko Sweep Lab: ",g_export_notice); g_dirty=true; return;
     }
   bool ok=FileWrite(f,"symbol","brick_price","tick_size","effective_breach_price","effective_reclaim_price",
      "history_from_msc","requested_end_msc_0_live","processed_to_msc","history_caught_up",
      "min_run","breach_buffer_bricks","reclaim_buffer_bricks","acceptance_bricks","max_wait_bricks","max_level_age","horizon_bricks",
      "event_id","level_side","level_price","level_known_msc","level_known_brick","level_known_seq","breach_msc","breach_brick","breach_seq",
      "state","classification_msc","classification_brick","classification_seq","reference_bid","followup_complete","outcome_msc",
      "outcome_brick","outcome_seq","outcome_bid","directional_move_bricks","mfe_bricks","mae_bricks")>0;
   for(int i=0;i<g_lab.event_count && ok;i++)
     {
      const SLabEvent e=g_lab.events[i];
      ok=FileWrite(f,_Symbol,DoubleToString(g_brick,g_digits),DoubleToString(g_grid,g_digits),Price(g_lab.sweep),Price(g_lab.inside),
         g_start,g_fixed_end,g_lab.last_msc,
         (g_cursor>g_target && !g_stop ? "yes" : "no"),InpMinRunBricks,InpSweepBufferBricks,InpReclaimBufferBricks,
         InpAcceptanceBricks,InpMaxWaitBricks,InpLevelMaxAgeBricks,InpOutcomeBricks,e.id,(e.side>0 ? "upper" : "lower"),
         Price(e.level),e.level_msc,e.level_brick,e.level_seq,e.breach_msc,e.breach_brick,e.breach_seq,
         StateName(e.state),e.resolved_msc,e.resolved_brick,e.resolved_seq,
         (e.resolved_msc>0 ? Price(e.reference) : ""),(e.measured ? "yes" : "no"),e.outcome_msc,e.outcome_brick,e.outcome_seq,
         (e.measured ? Price(e.outcome_price) : ""),(e.measured ? DoubleToString(e.move,6) : ""),
         (e.measured ? DoubleToString(e.mfe,6) : ""),(e.measured ? DoubleToString(e.mae,6) : ""))>0;
     }
   FileFlush(f); const int error=GetLastError(); FileClose(f);
   g_export_notice=(ok && error==0 ? "CSV saved. Full path is in the Experts log." :
                    "CSV write error. Check disk space and the Experts log.");
   g_notice_until=GetTickCount64()+8000;
   Print("GDS Renko Sweep Lab: ",(ok && error==0 ? "Exported: MQL5/Files/"+path : g_export_notice));
   g_dirty=true;
  }

// The dashboard is optional. A calculation handle or a non-visual tester
// need not expose chart properties or support graphical objects.
void TryAttachDashboard(void)
  {
   if(!g_dashboard_allowed || g_owns_chart) return;
   const ulong now=GetTickCount64();
   if(now<g_next_dashboard_try) return;
   g_next_dashboard_try=now+1000;
   long width=0,height=0;
   if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,width) || width<=0 ||
      !ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,height) || height<=0) return;
   if(!ChartGetInteger(0,CHART_SHOW,0,g_old_show) ||
      !ChartGetInteger(0,CHART_COLOR_BACKGROUND,0,g_old_background)) return;
   if(ObjectFind(0,g_prefix+"owner")>=0)
     {
      // Keep the existing panel and its original chart settings untouched.
      g_dashboard_allowed=false;
      Print("GDS Renko Sweep Lab: another panel owns this chart; this instance calculates without a panel.");
      return;
     }
   g_owns_chart=true;
   ChartSetInteger(0,CHART_SHOW,false);
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,C_BG);
   g_dirty=true;
   Draw();
  }

// The same history pump runs with or without a GUI. Dependent indicators may
// receive OnCalculate without OnTimer; a timer is therefore never required.
void RunCycle(void)
  {
   const ulong now=GetTickCount64();
   if(!g_tester && now-g_last_pump<100) return;
   g_last_pump=now;
   Pump();
   TryAttachDashboard();
   if(!g_owns_chart) return;
   const ulong since=GetTickCount64()-g_last_draw;
   if((g_dirty && since>=250) || since>=2000) Draw();
  }

int OnInit(void)
  {
   if(!MathIsValidNumber(InpBrickSize) || InpBrickSize<0 ||
      InpHistoryHours<1 || InpHistoryHours>720 || InpMinRunBricks<1 || InpMinRunBricks>20 ||
      !MathIsValidNumber(InpSweepBufferBricks) || InpSweepBufferBricks<0 || InpSweepBufferBricks>5 ||
      !MathIsValidNumber(InpReclaimBufferBricks) || InpReclaimBufferBricks<0 || InpReclaimBufferBricks>2 ||
      InpAcceptanceBricks<1 || InpAcceptanceBricks>20 || InpMaxWaitBricks<2 || InpMaxWaitBricks>200 ||
      InpMaxWaitBricks<InpAcceptanceBricks || InpLevelMaxAgeBricks<5 || InpLevelMaxAgeBricks>2000 ||
      InpOutcomeBricks<1 || InpOutcomeBricks>100 || InpHistoryStart<0)
     { Print("GDS Renko Sweep Lab: check the input ranges shown in their descriptions."); return INIT_PARAMETERS_INCORRECT; }
   g_grid=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(!MathIsValidNumber(g_grid) || g_grid<=0) g_grid=_Point;
   if(!MathIsValidNumber(g_grid) || g_grid<=0)
     { Print("GDS Renko Sweep Lab: symbol price step is unavailable. Error ",GetLastError()); return INIT_FAILED; }
   g_digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   const double desired=(InpBrickSize==0 ? 200.0*_Point : InpBrickSize);
   if(desired/g_grid>1.0e9) { Print("Brick size is too large."); return INIT_PARAMETERS_INCORRECT; }
   const long units=(long)MathMax(1,MathRound(desired/g_grid));
   g_brick=(double)units*g_grid;
   const long breach=(long)MathMax(1,MathCeil(units*InpSweepBufferBricks-1e-10));
   const long inside=(long)MathMax(1,MathCeil(units*InpReclaimBufferBricks-1e-10));
   g_lab.Init(units,breach,inside,InpMinRunBricks,InpAcceptanceBricks,InpMaxWaitBricks,InpLevelMaxAgeBricks,InpOutcomeBricks);
   ResetLastError();
   if(!SetIndexBuffer(0,g_dummy,INDICATOR_DATA))
     { Print("GDS Renko Sweep Lab: cannot bind indicator buffer. Error ",GetLastError()); return INIT_FAILED; }
   ArraySetAsSeries(g_dummy,false);
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   IndicatorSetString(INDICATOR_SHORTNAME,"GDS Renko Liquidity Sweep Lab v1.01");
   g_tester=(bool)MQLInfoInteger(MQL_TESTER);
   g_dashboard_allowed=(!g_tester || (bool)MQLInfoInteger(MQL_VISUAL_MODE));
   // Tester calculations are driven by OnCalculate on every tick. Avoid an
   // unnecessary high-frequency timer across months of simulated time.
   if(!g_tester)
     {
      ResetLastError();
      g_timer_active=EventSetMillisecondTimer(100);
      if(!g_timer_active)
        { ResetLastError(); g_timer_active=EventSetTimer(1); }
      if(!g_timer_active)
         Print("GDS Renko Sweep Lab: timer unavailable; processing continues in OnCalculate. Error ",GetLastError());
     }
   TryAttachDashboard();
   Print("GDS Renko Liquidity Sweep Lab v1.01: initialized; no orders. ",
         (g_tester ? "Tester ticks are processed in OnCalculate; results depend on the tick model." :
                     "Broker history loads asynchronously."));
   return INIT_SUCCEEDED;
  }

int OnCalculate(const int rates_total,const int prev_calculated,const int begin,const double &price[])
  {
   if(prev_calculated==0) ArrayInitialize(g_dummy,EMPTY_VALUE);
   else if(rates_total>prev_calculated)
      for(int i=prev_calculated;i<rates_total;i++) g_dummy[i]=EMPTY_VALUE;
   RunCycle();
   return rates_total;
  }
void OnTimer(void)
  {
   RunCycle();
  }
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(!g_owns_chart) return;
   if(id==CHARTEVENT_CHART_CHANGE) { g_dirty=true; Draw(); return; }
   if(id!=CHARTEVENT_OBJECT_CLICK) return;
   if(sparam==g_prefix+"pause")
     { g_paused=!g_paused; g_message=(g_paused ? "Paused. Resume catches up from the same tick cursor." : "Resuming chronological tick processing..."); }
   else if(sparam==g_prefix+"export") Export();
   g_dirty=true; Draw();
  }
void OnDeinit(const int reason)
  {
   if(g_timer_active) EventKillTimer();
   if(!g_owns_chart) return;
   ObjectsDeleteAll(0,g_prefix,0,-1);
   ChartSetInteger(0,CHART_SHOW,g_old_show);
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,g_old_background);
   ChartRedraw();
  }
