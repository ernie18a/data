//+------------------------------------------------------------------+
//| GDS Renko Trade Manager v1.000 - CodeBase release candidate        |
//| Manual-position management using completed fixed Renko bricks.  |
//| CodeBase candidate. Compile, test and validate before publication.      |
//+------------------------------------------------------------------+
#property copyright "Golden Delta"
#property version   "1.000"
#property strict
#property description "Manages existing MT5 positions using completed classic Renko bricks."
#property description "No entries. Monitor-only by default; active mode needs hedging."
#property description "Break-even and brick-based trailing stops for existing positions."
#property description "MQL5 terminal Global Variables retain Renko and position state."
#property description "Compact dashboard and bounded visual-only tick history replay."
#property description "Tick replay is visual only, monitored and verified against a frozen stream checkpoint."

enum ENUM_GDS_TM_MODE
  {
   GDS_TM_MONITOR_ONLY=0, // Default: never send trade requests
   GDS_TM_MANAGE_LIVE=1   // Explicit: may modify/partially/fully close positions
  };

input ENUM_GDS_TM_MODE InpMode=GDS_TM_MONITOR_ONLY;
input double InpBrickSize=2.0;              // Price units; e.g. XAUUSD $2.00
input bool   InpManualOnly=true;            // Verify manual origin from position deal history
input long   InpMagicFilter=0;              // Used ONLY when ManualOnly=false; positive, exact magic
input int    InpBEAfterBricks=3;            // 0 disables break-even
input double InpBEOffsetBricks=0.0;         // Additional BE distance in brick units, >=0
input int    InpTrailStartBricks=5;         // 0 disables trailing
input int    InpTrailGapBricks=2;           // SL offset behind best completed Renko close
input int    InpTrailStepBricks=1;          // Minimum SL improvement (bricks)
input int    InpRecoveryMaxHours=24;        // Refuse unsafe very-long tick-history catchups

input group "Visual dashboard / completed Renko inset"
input bool   InpShowDashboard=true;          // Price/position status panel on the chart
input bool   InpShowRenkoBricks=true;        // Same-engine completed bricks; retain display on reload
input int    InpVisibleBricks=28;            // Recorded bars or last validated run, 12 to 36
input bool   InpDockRight=false;            // False=left, true=right; can toggle on panel
input bool   InpStartMinimized=false;       // Collapse display on attach, trading unaffected
input bool   InpAvoidOneClickOverlap=true; // Shift panel clear of native One Click Trading controls
input int    InpPanelWidth=354;             // Compact integrated panel: 330 to 420 px
input int    InpPanelX=14;                  // Left dock margin (px)
input int    InpPanelY=12;                  // Panel distance from chart top (px)
input int    InpRenkoRightMargin=14;        // Right dock margin (px)
input bool   InpReplayVisualTicks=true;     // Verify older bars against frozen stream checkpoint
input int    InpVisualLookbackHours=12;      // Visual-only BID-tick window: 1..72 hours
input int    InpVisualMaxTicks=360000;       // Bounded history scan, 10000..750000 ticks

#define GDS_MAX_TRACKS 32
#define GDS_TICK_CHUNK 2000
#define GDS_MAX_CHUNKS 4
#define GDS_MAX_BRICKS 4096

#define GDS_UI_RING_SIZE 48
#define GDS_VIS_CHUNK 1500
#define GDS_VIS_COPIES_PER_TIMER 1
#define GDS_VIS_MAX_EMPTY_RETRIES 3
#define GDS_UI_BG       C'14,24,38'
#define GDS_UI_TILE     C'22,38,56'
#define GDS_UI_SHADOW   C'8,13,22'
#define GDS_UI_LINE     C'49,70,90'
#define GDS_UI_TEXT     C'236,244,252'
#define GDS_UI_MUTED    C'150,170,192'
#define GDS_UI_ACCENT   C'75,195,229'
#define GDS_UI_UP       C'44,215,174'
#define GDS_UI_DOWN     C'244,102,112'
#define GDS_UI_AMBER    C'249,195,105'
#define GDS_UI_AMBER_BG C'65,53,36'

struct SBrick
  {
   double close;
   int direction;
   int run;
  };

// One stream per symbol. Integer tick grid prevents floating-point drift.
class CRenkoBuilder
  {
private:
   double m_tick;
   long m_size,m_close;
   int m_direction,m_run;
   bool m_anchor;
public:
   void Init(const double tick,const long size)
     {
      m_tick=tick; m_size=size; m_close=0; m_direction=0; m_run=0; m_anchor=false;
     }
   void Anchor(const double price)
     {
      m_close=(long)MathRound(price/m_tick);
      m_anchor=true;
     }
   void GetState(long &last_close,int &direction,int &run,bool &anchored)
     {
      last_close=m_close; direction=m_direction; run=m_run; anchored=m_anchor;
     }
   bool Restore(const long last_close,const int direction,const int run,const bool anchored)
     {
      if(!anchored || last_close<=0 || direction < -1 || direction>1 || run<0)
         return false;
      m_close=last_close; m_direction=direction; m_run=run; m_anchor=anchored;
      return true;
     }
   double ClosePrice(void) { return m_close*m_tick; }
   int Push(const double price,SBrick &output[])
     {
      ArrayResize(output,0);
      if(!m_anchor || !MathIsValidNumber(price) || price<=0.0) return -1;
      const long p=(long)MathRound(price/m_tick);
      const long delta=p-m_close;
      int direction=m_direction;
      long count=0;
      bool reversed=false;
      if(m_direction==0)
        {
         if(delta>=m_size) { direction=1; count=delta/m_size; }
         else if(delta<=-m_size) { direction=-1; count=(-delta)/m_size; }
        }
      else if(m_direction>0)
        {
         if(delta>=m_size) count=delta/m_size;
         else if(delta<=-2*m_size)
           { direction=-1; reversed=true; count=(-delta)/m_size-1; }
        }
      else
        {
         if(delta<=-m_size) count=(-delta)/m_size;
         else if(delta>=2*m_size)
           { direction=1; reversed=true; count=delta/m_size-1; }
        }
      if(count>GDS_MAX_BRICKS) return -1;
      if(count==0) return 0;
      if(ArrayResize(output,(int)count)!=(int)count) return -1;
      for(int i=0;i<(int)count;i++)
        {
         const long open_tick=m_close+((reversed && i==0) ? direction*m_size : 0);
         m_close=open_tick+direction*m_size;
         if(direction==m_direction) m_run++;
         else { m_direction=direction; m_run=1; }
         output[i].close=m_close*m_tick;
         output[i].direction=m_direction;
         output[i].run=m_run;
        }
      return (int)count;
     }
  };

struct STrack
  {
   ulong id;
   ulong ticket;
   int side;                         // +1 BUY / -1 SELL
   double reference;                // Renko close at first observation
   double best;                     // Most favorable COMPLETED Renko close since reference
   bool partial_attempted;         // Persisted BEFORE sending a close request
   bool exit_signaled;              // Most recent opposite first brick not superseded
   long exit_event_ms;              // Used to prevent stale reversal exits after downtime
   bool exit_attempted;            // Persisted BEFORE sending a full-close request
   bool dirty;
  };

CRenkoBuilder g_renko;
STrack g_tracks[];
double g_tick_size=0.0,g_brick_price=0.0;
long g_last_ms=0;
int g_seen_ms=0,g_bank=0;
string g_base="",g_lock="",g_beat="";
double g_owner=0.0;
bool g_has_lock=false,g_blocked=false;
int g_last_error_report=0;
// Tester-only: defer fresh-stream anchor until a real simulated OnTick.
// Production/live initialization, stream ownership, and trading remain unchanged.
bool g_test_waiting_tick=false;
bool g_test_future_logged=false;
long g_test_start_msc=0;

// UI is intentionally a read-only observer of CRenkoBuilder::Push events.
// Visual-only state uses separate GDTM13_UI checkpoints; the GDTM10 trading ID is unchanged.
SBrick g_ui_bricks[GDS_UI_RING_SIZE];
int g_ui_next=0,g_ui_count=0,g_ui_last_visible_cards=0;
int g_ui_layout=0;
bool g_ui_collapsed=false,g_ui_dock_right=false;
int g_ui_last_draw_positions=-1;
// Display preferences are purely transient and NEVER influence risk/trade rules.
// When more than one trade is found, automatically show the all-positions view.
bool g_ui_positions_focus=false,g_ui_view_touched=false;
int g_ui_page=0,g_ui_page_capacity=1,g_ui_last_list_rows=0;
int g_ui_last_selected_card_index=-1;
ulong g_ui_selected_id=0;
ulong g_ui_last_draw_ms=0;
ulong g_ui_completed_total=0;
bool g_ui_synced=false,g_ui_error_reported=false;
string g_ui_prefix="";
// Visual checkpoints have independent two-bank ownership-neutral storage.
// They never feed the live Renko state, position management, or trade requests.
string g_ui_history_base="";
int g_ui_history_bank=-1;
bool g_ui_dirty=false;
string g_ui_origin="CURRENT RUN";
int g_ui_reconstructed=0;
bool g_ui_proven=false; // proof persists only for tick-derived, checkpoint-matched bricks

// Visual replay NEVER shares a CRenkoBuilder instance, stream cursor,
// position state, or checkpoint with the trading path. We only READ a frozen
// snapshot taken at OnInit. The live manager continues processing normally.
// Three distinct initial price-grid states must converge BEFORE recorded bars
// can qualify for display; all three must then match the frozen authoritative
// stream state at the exact stored millisecond/tick ordinal.
CRenkoBuilder g_vis_builders[3];
SBrick g_vis_bricks[GDS_UI_RING_SIZE];
int g_vis_next=0,g_vis_count=0;
long g_vis_start_ms=0,g_vis_cursor_ms=0,g_vis_checkpoint_ms=0;
int g_vis_seen=0,g_vis_checkpoint_seen=0;
long g_vis_checkpoint_close=0;
int g_vis_checkpoint_dir=0,g_vis_checkpoint_run=0;
ulong g_vis_begin_ui_count=0;
int g_vis_processed=0,g_vis_waits=0;
bool g_vis_seeded=false,g_vis_converged=false;
// 0=not requested, 1=replaying, 2=matched, 3=unverified/incomplete,
// 4=new session, 5=disabled in active management, 6=saved history sufficient.
int g_vis_status=0;
string g_vis_reason="";

uint HashText(const string s)
  {
   uint h=5381;
   for(int i=0;i<StringLen(s);i++) h=h*33+(uint)StringGetCharacter(s,i);
   return h;
  }

bool Store(const string name,const double value)
  {
   ResetLastError();
   if(GlobalVariableSet(name,value)==0)
     {
      Print("GDS TM: Cannot persist ",name," error=",GetLastError());
      return false;
     }
   return true;
  }

bool Read(const string name,double &value)
  {
   if(!GlobalVariableCheck(name)) return false;
   return GlobalVariableGet(name,value);
  }

void Halt(const string reason)
  {
   if(!g_blocked) Print("GDS TM SAFE HALT: ",reason,"; no new broker requests.");
   g_blocked=true;
  }

bool AcquireLock(void)
  {
   g_lock=g_base+".lock";
   g_beat=g_base+".beat";
   // Double precision retains seconds*1000 plus small per-chart suffix exactly.
   g_owner=(double)TimeLocal()*1000.0+(double)(ChartID()%997);
   if(!GlobalVariableCheck(g_lock) && !Store(g_lock,0.0)) return false;
   double previous=0.0,beat=0.0;
   if(!Read(g_lock,previous)) return false;
   if(previous!=0.0)
     {
      if(!Read(g_beat,beat)) return false; // Missing heartbeat: manual reset required.
      if((double)TimeLocal()-beat<120.0)
        { Print("GDS TM: Another instance already manages this symbol/filter."); return false; }
     }
   if(!GlobalVariableSetOnCondition(g_lock,g_owner,previous)) return false;
   g_has_lock=true;
   return Store(g_beat,(double)TimeLocal());
  }

void ReleaseLock(void)
  {
   if(!g_has_lock) return;
   double old=0.0;
   if(Read(g_lock,old) && old==g_owner)
     {
      GlobalVariableSetOnCondition(g_lock,0.0,g_owner);
      Store(g_beat,0.0);
     }
   g_has_lock=false;
  }

string BankPrefix(const int bank)
  {
   return g_base+(bank==0 ? ".a" : ".b");
  }

bool SaveStream(void)
  {
   long c; int d,r; bool anchored;
   g_renko.GetState(c,d,r,anchored);
   const int next=1-g_bank;
   const string p=BankPrefix(next);
   if(!Store(p+".v",1.0) || !Store(p+".c",(double)c) ||
      !Store(p+".d",(double)d) || !Store(p+".r",(double)r) ||
      !Store(p+".h",anchored ? 1.0 : 0.0) ||
      !Store(p+".m",(double)g_last_ms) || !Store(p+".s",(double)g_seen_ms)) return false;
   GlobalVariablesFlush();
   // Commit only after writing the entire alternate bank.
   if(!Store(g_base+".selected",(double)next)) return false;
   GlobalVariablesFlush();
   g_bank=next;
   return true;
  }

bool LoadStream(void)
  {
   double selected=0.0;
   if(!GlobalVariableCheck(g_base+".selected")) return false;
   if(!Read(g_base+".selected",selected) || (selected!=0.0 && selected!=1.0))
     { Halt("Corrupt Renko snapshot selector"); return true; }
   g_bank=(int)selected;
   const string p=BankPrefix(g_bank);
   double v,c,d,r,h,m,s;
   if(!Read(p+".v",v) || !Read(p+".c",c) || !Read(p+".d",d) ||
      !Read(p+".r",r) || !Read(p+".h",h) || !Read(p+".m",m) ||
      !Read(p+".s",s) || v!=1.0 || m<=0.0 || s<0.0 || s>100000.0 ||
      !g_renko.Restore((long)c,(int)d,(int)r,(h==1.0)))
     { Halt("Incomplete/corrupt Renko snapshot; do not reset automatically"); return true; }
   g_last_ms=(long)m;
   g_seen_ms=(int)s;
   return true;
  }

string PositionKey(const ulong id)
  {
   return g_base+StringFormat(".%I64u",id);
  }

bool SavePosition(const int index)
  {
   const string p=PositionKey(g_tracks[index].id);
   // Marker is created LAST for a new record; existing records are monotone.
   if(!Store(p+".ref",g_tracks[index].reference) ||
      !Store(p+".best",g_tracks[index].best) ||
      !Store(p+".sigms",(double)g_tracks[index].exit_event_ms) ||
      !Store(p+".part",g_tracks[index].partial_attempted ? 1.0 : 0.0) ||
      !Store(p+".exit",g_tracks[index].exit_signaled ? 1.0 : 0.0) ||
      !Store(p+".done",g_tracks[index].exit_attempted ? 1.0 : 0.0) ||
      !Store(p+".v",1.0)) return false;
   g_tracks[index].dirty=false;
   return true;
  }

bool LoadPosition(const int index)
  {
   const string p=PositionKey(g_tracks[index].id);
   double v,r,b,partial,exit_signal,done,sigms;
   if(!Read(p+".v",v) || !Read(p+".ref",r) || !Read(p+".best",b) ||
      !Read(p+".sigms",sigms) ||
      !Read(p+".part",partial) || !Read(p+".exit",exit_signal) ||
      !Read(p+".done",done) || v!=1.0 || r<=0.0 || b<=0.0 ||
      (partial!=0.0 && partial!=1.0) || (exit_signal!=0.0 && exit_signal!=1.0) ||
      (done!=0.0 && done!=1.0) || sigms<0.0)
     { Halt("Corrupt position record: "+p); return false; }
   g_tracks[index].reference=r;
   g_tracks[index].best=b;
   g_tracks[index].partial_attempted=(partial==1.0);
   g_tracks[index].exit_signaled=(exit_signal==1.0);
   g_tracks[index].exit_event_ms=(long)sigms;
   g_tracks[index].exit_attempted=(done==1.0);
   return true;
  }

int TrackIndex(const ulong id)
  {
   for(int i=0;i<ArraySize(g_tracks);i++) if(g_tracks[i].id==id) return i;
   return -1;
  }

bool VerifiedManualOrigin(const ulong id)
  {
   if(!HistorySelectByPosition(id)) return false; // Unknown origin: fail closed.
   bool found=false;
   const int deals=HistoryDealsTotal();
   for(int k=0;k<deals;k++)
     {
      const ulong deal=HistoryDealGetTicket(k);
      if(deal==0 || (ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal,DEAL_ENTRY)!=DEAL_ENTRY_IN)
         continue;
      found=true;
      const ENUM_DEAL_REASON reason=(ENUM_DEAL_REASON)HistoryDealGetInteger(deal,DEAL_REASON);
      if(reason!=DEAL_REASON_CLIENT && reason!=DEAL_REASON_MOBILE &&
         reason!=DEAL_REASON_WEB) return false;
     }
   return found;
  }

bool EligibleNewPosition(const ulong id,const long magic)
  {
   if(InpManualOnly)
     {
      if(magic!=0) return false;
      return VerifiedManualOrigin(id);
     }
   return magic==InpMagicFilter;
  }

// Called before replay (restore previously observed positions only) and after
// replay (also register newly detected positions at the CURRENT Renko close).
void PruneClosedTracks(void)
  {
   for(int i=ArraySize(g_tracks)-1;i>=0;i--)
     {
      bool present=false;
      for(int k=PositionsTotal()-1;k>=0;k--)
        {
         const ulong ticket=PositionGetTicket(k);
         if(ticket==0 || !PositionSelectByTicket(ticket)) continue;
         if(PositionGetString(POSITION_SYMBOL)==_Symbol &&
            (ulong)PositionGetInteger(POSITION_IDENTIFIER)==g_tracks[i].id)
           { present=true; break; }
        }
      if(present) continue;
      const int n=ArraySize(g_tracks);
      for(int k=i+1;k<n;k++) g_tracks[k-1]=g_tracks[k];
      ArrayResize(g_tracks,n-1);
      // Persisted history is retained. IDs are not recycled within an account.
     }
  }

void DiscoverPositions(const bool allow_new)
  {
   PruneClosedTracks();
   for(int k=PositionsTotal()-1;k>=0;k--)
     {
      const ulong ticket=PositionGetTicket(k);
      if(ticket==0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      const ulong id=(ulong)PositionGetInteger(POSITION_IDENTIFIER);
      const long magic=PositionGetInteger(POSITION_MAGIC);
      if(id==0) continue;
      int idx=TrackIndex(id);
      if(idx>=0)
        {
         g_tracks[idx].ticket=ticket;
         const int side=(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY ? 1 : -1);
         if(g_tracks[idx].side!=side) Halt("Position direction unexpectedly changed");
         continue;
        }
      const string p=PositionKey(id);
      const bool exists=GlobalVariableCheck(p+".v");
      // A previous manual position can acquire nonzero POSITION_MAGIC after
      // an EA-assisted close; its VERIFIED manual opening remains authoritative.
      if(!(InpManualOnly && exists && VerifiedManualOrigin(id)) &&
         !EligibleNewPosition(id,magic)) continue;
      if(!exists && !allow_new) continue;
      if(ArraySize(g_tracks)>=GDS_MAX_TRACKS)
        { Halt("More than 32 managed positions"); return; }
      idx=ArraySize(g_tracks);
      if(ArrayResize(g_tracks,idx+1)!=idx+1)
        { Halt("Position list allocation failed"); return; }
      g_tracks[idx].id=id;
      g_tracks[idx].ticket=ticket;
      g_tracks[idx].side=(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY ? 1 : -1);
      g_tracks[idx].partial_attempted=false;
      g_tracks[idx].exit_signaled=false;
      g_tracks[idx].exit_event_ms=0;
      g_tracks[idx].exit_attempted=false;
      g_tracks[idx].dirty=false;
      if(exists)
        {
         if(!LoadPosition(idx)) return;
         Print("GDS TM: Restored position id=",id);
        }
      else
        {
         g_tracks[idx].reference=g_renko.ClosePrice();
         g_tracks[idx].best=g_tracks[idx].reference;
         if(g_tracks[idx].reference<=0.0 || !SavePosition(idx))
           { Halt("Cannot initialize new position record"); return; }
         GlobalVariablesFlush();
         Print("GDS TM: Registered position id=",id," from NOW (no historical position progress assumed)");
        }
     }
  }

void UIRecordCompleted(const SBrick &brick);

void OnCompletedBrick(const SBrick &b,const long tick_ms)
  {
   UIRecordCompleted(b);  // Read-only display from the EXACT same completed-brick event.
   for(int i=0;i<ArraySize(g_tracks);i++)
     {
      bool changed=false;
      if(g_tracks[i].side>0 && b.close>g_tracks[i].best)
        { g_tracks[i].best=b.close; changed=true; }
      if(g_tracks[i].side<0 && b.close<g_tracks[i].best)
        { g_tracks[i].best=b.close; changed=true; }
      if(b.direction==g_tracks[i].side && g_tracks[i].exit_signaled)
        { g_tracks[i].exit_signaled=false; g_tracks[i].exit_event_ms=0; changed=true; }
      else if(b.direction==-g_tracks[i].side && b.run==1 &&
              !g_tracks[i].exit_attempted && !g_tracks[i].exit_signaled)
        { g_tracks[i].exit_signaled=true; g_tracks[i].exit_event_ms=tick_ms; changed=true; }
      if(changed) g_tracks[i].dirty=true;
     }
  }

// Returns false if tick history is unavailable, corrupt or not yet caught up.
// All broker actions are withheld until the snapshot is committed.
bool PollTicks(void)
  {
   MqlTick latest={};
   if(!SymbolInfoTick(_Symbol,latest) || latest.time_msc<=0 ||
      latest.bid<=0.0 || latest.ask<latest.bid) return false;
   if(g_last_ms>latest.time_msc)
     {
      // Fail closed: never silently reset a live or recovered stream.
      PrintFormat("GDS TM TIME DIAGNOSTIC: cursor_ms=%I64d > quote_ms=%I64d, test=%d, simulated=%s",
                  g_last_ms,latest.time_msc,(int)MQLInfoInteger(MQL_TESTER),
                  TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
      Halt("Stored cursor is ahead of broker quote time"); return false;
     }
   if(InpRecoveryMaxHours>0 &&
      ((double)latest.time_msc-(double)g_last_ms)>InpRecoveryMaxHours*3600000.0)
     { Halt("Tick recovery exceeds configured time window"); return false; }
   bool progressed=false;
   bool capped=false;
   bool test_future_tick_held=false;
   for(int chunk=0;chunk<GDS_MAX_CHUNKS;chunk++)
     {
      MqlTick quotes[];
      ResetLastError();
      const int n=CopyTicks(_Symbol,quotes,COPY_TICKS_INFO,(ulong)g_last_ms,GDS_TICK_CHUNK);
      if(n<0) return false;
      if(n==0) break;
      bool chunk_progress=false;
      int index_same=0;
      for(int i=0;i<n;i++)
        {
         const long ms=quotes[i].time_msc;
         // CopyTicks is a historical query. A simulated timer must NEVER
         // ingest a tick newer than SymbolInfoTick's current simulated quote.
         // This guard applies ONLY in Strategy Tester, not in a live terminal.
         if(MQLInfoInteger(MQL_TESTER) && ms>latest.time_msc)
           { test_future_tick_held=true; break; }
         if(ms<g_last_ms) continue;
         if(ms==g_last_ms)
           {
            index_same++;
            if(index_same<=g_seen_ms) continue;
           }
         else
           { g_last_ms=ms; g_seen_ms=0; index_same=1; }
         if(quotes[i].bid<=0.0 || !MathIsValidNumber(quotes[i].bid))
           { Halt("Invalid Bid in recovered ticks"); return false; }
         g_seen_ms=index_same;
         SBrick completed[];
         const int added=g_renko.Push(quotes[i].bid,completed);
         if(added<0) { Halt("Renko generation failed or exceeds per-tick budget"); return false; }
         for(int b=0;b<added;b++) OnCompletedBrick(completed[b],ms);
         chunk_progress=true;
         progressed=true;
        }
      if(test_future_tick_held)
        {
         if(!g_test_future_logged)
           {
            PrintFormat("GDS TM TESTER TIME GUARD: future CopyTicks item held. quote_ms=%I64d, cursor_ms=%I64d. No future brick committed.",
                        latest.time_msc,g_last_ms);
            g_test_future_logged=true;
           }
         break;
        }
      if(n<GDS_TICK_CHUNK) break;
      if(!chunk_progress)
        { capped=true; break; }
      if(chunk==GDS_MAX_CHUNKS-1) capped=true;
      // Exactly full batch may hide later ticks with identical millisecond.
      if(g_last_ms>=latest.time_msc) { capped=true; break; }
     }
   if(progressed)
     {
      for(int i=0;i<ArraySize(g_tracks);i++)
         if(g_tracks[i].dirty && !SavePosition(i))
           { Halt("Position checkpoint failed"); return false; }
      GlobalVariablesFlush();
      if(!SaveStream()) { Halt("Renko checkpoint failed"); return false; }
     }
   if(capped || g_last_ms<latest.time_msc) return false;
   return true;
  }

bool TradePermitted(void)
  {
   if(g_blocked || !g_has_lock || InpMode!=GDS_TM_MANAGE_LIVE ||
      AccountInfoInteger(ACCOUNT_MARGIN_MODE)!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) return false;
   double owner=0.0;
   if(!Read(g_lock,owner) || owner!=g_owner)
     { Halt("Single-instance lock lost"); return false; }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED) ||
      !AccountInfoInteger(ACCOUNT_TRADE_ALLOWED) || !AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
      return false;
   return true;
  }

bool SelectTrackPosition(const int i)
  {
   if(!PositionSelectByTicket(g_tracks[i].ticket)) return false;
   return PositionGetString(POSITION_SYMBOL)==_Symbol &&
          (ulong)PositionGetInteger(POSITION_IDENTIFIER)==g_tracks[i].id &&
          (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY ? 1 : -1)==g_tracks[i].side;
  }

double NormalizeStop(const double wanted,const int side)
  {
   const double ticks=wanted/g_tick_size;
   const double rounded=(side>0 ? MathFloor(ticks+1.0e-9) : MathCeil(ticks-1.0e-9));
   return NormalizeDouble(rounded*g_tick_size,_Digits);
  }

bool ValidStop(const double stop,const int side,const MqlTick &quote)
  {
   const long stops=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   const long freeze=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   const double distance=(MathMax(stops,freeze)+2)*_Point;
   if(side>0) return stop>0.0 && stop<quote.bid-distance;
   return stop>quote.ask+distance;
  }

bool SendSL(const int i,const double target)
  {
   if(!SelectTrackPosition(i) || !TradePermitted()) return false;
   // Re-read broker state immediately before the request. Another script,
   // the trader or broker may have tightened SL since ManagePositions().
   // Never overwrite a stronger SL or issue a duplicate SL update.
   const int side=g_tracks[i].side;
   const double current_sl=PositionGetDouble(POSITION_SL);
   if(!MathIsValidNumber(target) || target<=0.0) return false;
   if(current_sl>0.0 &&
      side*(target-current_sl)<=g_tick_size*0.5) return false;
   MqlTick fresh={};
   if(!SymbolInfoTick(_Symbol,fresh) || fresh.bid<=0.0 ||
      fresh.ask<fresh.bid || !ValidStop(target,side,fresh)) return false;
   MqlTradeRequest req={};
   MqlTradeResult res={};
   req.action=TRADE_ACTION_SLTP;
   req.symbol=_Symbol;
   req.position=g_tracks[i].ticket;
   req.sl=target;
   req.tp=PositionGetDouble(POSITION_TP); // NEVER remove user's take profit.
   req.magic=26101210;
   ResetLastError();
   const bool ok=OrderSend(req,res);
   if(!ok || res.retcode!=TRADE_RETCODE_DONE)
     {
      Print("GDS TM: SL modify rejected #",g_tracks[i].ticket,
            " retcode=",res.retcode," err=",GetLastError()," ",res.comment);
      return false;
     }
   Print("GDS TM: SL updated #",g_tracks[i].ticket," -> ",DoubleToString(target,_Digits));
   return true;
  }

// This initial CodeBase release deliberately does not submit position-close
// orders. Partial closing and reversal exits remain outside the public
// baseline until their execution and restart paths have been verified.

int FavorableBricks(const int i)
  {
   const double movement=g_tracks[i].side*(g_tracks[i].best-g_tracks[i].reference);
   return (int)MathFloor(MathMax(0.0,movement)/g_brick_price+1e-8);
  }

//------------------- V0.13 VISUALIZATION ONLY ----------------------
// One compact, optionally collapsible/dockable observer panel.
// Plot data comes exclusively from OnCompletedBrick(): no chart-candle
// reconstruction and no extra builder feeding trade decisions.
void UIBox(const string key,const int x,const int y,const int width,const int height,
           const color fill,const color outline)
  {
   const string name=g_ui_prefix+key;
   if(ObjectFind(0,name)<0 && !ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
     {
      if(!g_ui_error_reported)
        { Print("GDS TM UI: rectangle creation failed, error=",GetLastError()); g_ui_error_reported=true; }
      return;
     }
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,MathMax(width,1));
   ObjectSetInteger(0,name,OBJPROP_YSIZE,MathMax(height,1));
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,fill);
   ObjectSetInteger(0,name,OBJPROP_COLOR,outline);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

void UIText(const string key,const string value,const int x,const int y,
            const int size,const color ink,const bool heading=false)
  {
   const string name=g_ui_prefix+key;
   if(value=="") { ObjectDelete(0,name); return; }
   if(ObjectFind(0,name)<0 && !ObjectCreate(0,name,OBJ_LABEL,0,0,0))
     {
      if(!g_ui_error_reported)
        { Print("GDS TM UI: label creation failed, error=",GetLastError()); g_ui_error_reported=true; }
      return;
     }
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,ink);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetString(0,name,OBJPROP_FONT,(heading ? "Segoe UI Semibold" : "Segoe UI"));
   ObjectSetString(0,name,OBJPROP_TEXT,value);
  }

// These two controls change CHART PRESENTATION only, never trading mode.
void UIButton(const string key,const string label,const int x,const int y,
              const int width,const string tip)
  {
   const string name=g_ui_prefix+key;
   if(ObjectFind(0,name)<0 && !ObjectCreate(0,name,OBJ_BUTTON,0,0,0))
     {
      if(!g_ui_error_reported)
        { Print("GDS TM UI: button creation failed, error=",GetLastError()); g_ui_error_reported=true; }
      return;
     }
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,22);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,GDS_UI_TILE);
   ObjectSetInteger(0,name,OBJPROP_COLOR,GDS_UI_TEXT);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_STATE,false);
   ObjectSetString(0,name,OBJPROP_FONT,"Segoe UI");
   ObjectSetString(0,name,OBJPROP_TEXT,label);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,tip);
  }

void UIChip(const string key,const string value,const int x,const int y,
            const int width,const color bg,const color ink)
  {
   UIBox(key+".bg",x,y,width,23,bg,bg);
   UIText(key+".text",value,x+8,y+3,9,ink,true);
  }

void UIRecordCompleted(const SBrick &brick)
  {
   // Exactly the same completed-brick event the manager just received.
   // Read-only volatile ring: it never supplies input to the trade logic.
   // If the ring is full, the overwritten oldest bar may be inferred.
   if(g_ui_count==GDS_UI_RING_SIZE && g_ui_reconstructed>0)
      g_ui_reconstructed--;
   g_ui_bricks[g_ui_next]=brick;
   g_ui_next=(g_ui_next+1)%GDS_UI_RING_SIZE;
   if(g_ui_count<GDS_UI_RING_SIZE) g_ui_count++;
   g_ui_completed_total++;
   g_ui_dirty=true;
   g_ui_origin="SAVED EVENTS"; // Visual data NEVER feed the live manager.
  }

SBrick UIGetRecent(const int newest_count,const int oldest_index);

// UI-only persistence: a committed snapshot is written into an alternate
// bank and exposed by changing its selector LAST. Invalid/torn history is
// discarded; it cannot change the separately stored GDTM10 trade state.
bool UIStoreValue(const string name,const double value)
  {
   return (GlobalVariableSet(name,value)!=0);
  }

string UIHistoryBank(const int bank)
  {
   return g_ui_history_base+(bank==0 ? ".a" : ".b");
  }

bool UIAppendRestoreBrick(const SBrick &b)
  {
   if(g_ui_count>=GDS_UI_RING_SIZE) return false;
   g_ui_bricks[g_ui_next]=b;
   g_ui_next=(g_ui_next+1)%GDS_UI_RING_SIZE;
   g_ui_count++;
   return true;
  }

// Rebuild only the mathematically determined CURRENT directional run from
// the authoritative stored close/direction/run. Earlier reversals cannot
// be reconstructed from a single checkpoint, so they are NOT fabricated.
void UISeedCurrentRun(void)
  {
   g_ui_next=0;
   g_ui_count=0;
   g_ui_history_bank=-1;
   g_ui_origin="CURRENT RUN";
   g_ui_reconstructed=0;
   g_ui_proven=false;
   long close_tick=0;
   int direction=0,run=0;
   bool anchored=false;
   g_renko.GetState(close_tick,direction,run,anchored);
   if(!anchored || close_tick<=0 || direction==0 || run<=0) return;
   const int n=MathMin(run,GDS_UI_RING_SIZE);
   const long brick_ticks=(long)MathRound(g_brick_price/g_tick_size);
   for(int i=n-1;i>=0;i--)
     {
      const long close_at=close_tick-(long)direction*brick_ticks*i;
      if(close_at<=0) { g_ui_count=0; g_ui_next=0; return; }
      SBrick b;
      b.close=(double)close_at*g_tick_size;
      b.direction=direction;
      b.run=run-i;
      UIAppendRestoreBrick(b);
     }
   g_ui_reconstructed=g_ui_count;
   g_ui_dirty=(g_ui_count>0);
  }

// Verify every stored bar lies on the same Renko price grid. Adjacent bars
// must be either one brick in the trend or the classic 2-brick reversal.
bool UIValidPair(const SBrick &prev,const SBrick &b,const long brick_ticks)
  {
   if(b.direction!=1 && b.direction!=-1) return false;
   if(b.run<=0 || b.close<=0.0 || !MathIsValidNumber(b.close)) return false;
   if(prev.direction!=1 && prev.direction!=-1) return false;
   const long a=(long)MathRound(prev.close/g_tick_size);
   const long z=(long)MathRound(b.close/g_tick_size);
   if(MathAbs(prev.close-(double)a*g_tick_size)>g_tick_size*0.11 ||
      MathAbs(b.close-(double)z*g_tick_size)>g_tick_size*0.11) return false;
   const bool same=(b.direction==prev.direction);
   return (z-a==(long)b.direction*brick_ticks*(same ? 1 : 2) &&
           b.run==(same ? prev.run+1 : 1));
  }

bool UILoadBank(const int bank)
  {
   const string p=UIHistoryBank(bank);
   double version=0.0,number=0.0,last=0.0,dr=0.0,run=0.0,seed=0.0;
   if(!Read(p+".v",version) || !Read(p+".n",number) ||
      !Read(p+".last",last) || !Read(p+".dr",dr) || !Read(p+".run",run) ||
      !Read(p+".seed",seed) ||
      version!=130.0 || number<1.0 || number>GDS_UI_RING_SIZE ||
      number!=MathFloor(number) || seed<0.0 || seed>number ||
      seed!=MathFloor(seed) || dr!=(double)(int)dr ||
      run!=(double)(int)run) return false;
   long current=0; int current_direction=0,current_run=0; bool anchored=false;
   g_renko.GetState(current,current_direction,current_run,anchored);
   if(!anchored || current<=0 || current_direction!=(int)dr ||
      current_run!=(int)run || current!=(long)last) return false;
   const int n=(int)number;
   const long step=(long)MathRound(g_brick_price/g_tick_size);
   SBrick recovered[GDS_UI_RING_SIZE];
   for(int i=0;i<n;i++)
     {
      const string name=p+".b"+IntegerToString(i);
      double c=0.0,d=0.0,r=0.0;
      if(!Read(name+"c",c) || !Read(name+"d",d) || !Read(name+"r",r) ||
         c<=0.0 || !MathIsValidNumber(c) ||
         (d!=1.0 && d!=-1.0) || r<=0.0 || r!=MathFloor(r)) return false;
      recovered[i].close=c;
      recovered[i].direction=(int)d;
      recovered[i].run=(int)r;
      const long tick=(long)MathRound(c/g_tick_size);
      if(tick<=0 || MathAbs(c-(double)tick*g_tick_size)>g_tick_size*0.11)
         return false;
      if(i>0 && !UIValidPair(recovered[i-1],recovered[i],step)) return false;
     }
   if((long)MathRound(recovered[n-1].close/g_tick_size)!=current ||
      recovered[n-1].direction!=current_direction ||
      recovered[n-1].run!=current_run) return false;
   g_ui_next=0;
   g_ui_count=0;
   for(int i=0;i<n;i++) UIAppendRestoreBrick(recovered[i]);
   g_ui_history_bank=bank;
   g_ui_origin="SAVED EVENTS";
   g_ui_reconstructed=(int)seed;
   double proof=0.0;
   // v0.13 checkpoints have no .proof field: never assume verified history.
   if(Read(p+".proof",proof) && proof==1.0 && g_ui_reconstructed==0)
      g_ui_proven=true;
   else g_ui_proven=false;
   g_ui_dirty=false;
   return true;
  }

void UIRestoreHistory(void)
  {
   if(!InpShowRenkoBricks) return;
   double selected=-1.0;
   // Historical UI records may not exist on an upgrade from v0.12.
   if(Read(g_ui_history_base+".selected",selected) &&
      (selected==0.0 || selected==1.0))
     {
      if(UILoadBank((int)selected)) return;
      // If the selected bank is torn, check the other bank. Both are
      // accepted only if they end at the CURRENT engine checkpoint.
      if(UILoadBank(1-(int)selected)) return;
     }
   UISeedCurrentRun();
   if(g_ui_reconstructed>0)
      Print("GDS TM UI: Recovered ",g_ui_reconstructed,
            " current-run closes from the engine checkpoint. Earlier runs unavailable.");
  }

// Persistence runs only AFTER the engine's own commit in PollTicks(). If this
// observer write fails, trade state and live processing remain unchanged.
void UIPersistHistory(void)
  {
   if(!InpShowRenkoBricks || !g_ui_dirty || g_ui_count<=0 ||
      g_ui_history_base=="") return;
   long close_tick=0; int direction=0,run=0; bool anchored=false;
   g_renko.GetState(close_tick,direction,run,anchored);
   if(!anchored || direction==0 || run<=0) return;
   const SBrick last=UIGetRecent(g_ui_count,g_ui_count-1);
   if((long)MathRound(last.close/g_tick_size)!=close_tick ||
      last.direction!=direction || last.run!=run) return;
   const int bank=(g_ui_history_bank==0 ? 1 : 0);
   const string p=UIHistoryBank(bank);
   if(!UIStoreValue(p+".v",130.0) ||
      !UIStoreValue(p+".n",(double)g_ui_count) ||
      !UIStoreValue(p+".last",(double)close_tick) ||
      !UIStoreValue(p+".dr",(double)direction) ||
      !UIStoreValue(p+".run",(double)run) ||
      !UIStoreValue(p+".seed",(double)g_ui_reconstructed) ||
      !UIStoreValue(p+".proof",g_ui_proven ? 1.0 : 0.0)) return;
   for(int i=0;i<g_ui_count;i++)
     {
      const SBrick b=UIGetRecent(g_ui_count,i);
      const string name=p+".b"+IntegerToString(i);
      if(!UIStoreValue(name+"c",b.close) ||
         !UIStoreValue(name+"d",(double)b.direction) ||
         !UIStoreValue(name+"r",(double)b.run)) return;
     }
   GlobalVariablesFlush();
   if(!UIStoreValue(g_ui_history_base+".selected",(double)bank)) return;
   GlobalVariablesFlush();
   g_ui_history_bank=bank;
   g_ui_dirty=false;
  }

SBrick UIGetRecent(const int newest_count,const int oldest_index)
  {
   const int base=(g_ui_next-newest_count+GDS_UI_RING_SIZE)%GDS_UI_RING_SIZE;
   return g_ui_bricks[(base+oldest_index)%GDS_UI_RING_SIZE];
  }

//------------------- V0.14 BOUNDED HISTORICAL DISPLAY -------------------
// We cannot deduce an old streaming anchor from a recent snapshot alone.
// Broker ticks are replayed for visualization from three DIFFERENT hypothetical
// states on the frozen stream's price grid. No pre-convergence bricks are shown.
// The displayed suffix is accepted only if the three shadow builders converge
// and all end at the EXACT stored live state and cursor tick. This is a strong
// suffix consistency check, not a claim about unrecorded pre-convergence bars.
void UIVisualAbort(const string why)
  {
   g_vis_status=3;
   g_vis_reason=why;
   Print("GDS TM visual replay unavailable: ",why,
         ". Existing UI bars retained. Trading state unchanged.");
  }

void UIVisualStart(const bool stream_restored)
  {
   g_vis_status=0;
   if(!InpShowRenkoBricks || !InpReplayVisualTicks) return;
   if(InpMode!=GDS_TM_MONITOR_ONLY)
     { g_vis_status=5; return; } // Avoid historical disk/HTTP waits on a trading timer.
   if(!stream_restored)
     {
      g_vis_status=4; // A new engine anchored NOW has no historical trade bricks.
      return;
     }
   if(g_ui_count>=InpVisibleBricks && g_ui_reconstructed==0 && g_ui_proven)
     { g_vis_status=6; return; }
   long c=0; int d=0,r=0; bool anchored=false;
   g_renko.GetState(c,d,r,anchored);
   if(!anchored || c<=0 || d==0 || r<=0 || g_last_ms<=0 ||
      g_seen_ms<=0 || g_seen_ms>GDS_VIS_CHUNK)
     { UIVisualAbort("no suitable completed-brick checkpoint"); return; }
   g_vis_checkpoint_close=c;
   g_vis_checkpoint_dir=d;
   g_vis_checkpoint_run=r;
   g_vis_checkpoint_ms=g_last_ms;
   g_vis_checkpoint_seen=g_seen_ms;
   g_vis_start_ms=g_last_ms-(long)InpVisualLookbackHours*3600000;
   if(g_vis_start_ms<1) g_vis_start_ms=1;
   if(g_vis_start_ms>=g_vis_checkpoint_ms)
     { UIVisualAbort("empty historical window"); return; }
   g_vis_cursor_ms=g_vis_start_ms;
   g_vis_seen=0;
   g_vis_processed=0;
   g_vis_waits=0;
   g_vis_next=0;
   g_vis_count=0;
   g_vis_seeded=false;
   g_vis_converged=false;
   g_vis_begin_ui_count=g_ui_completed_total;
   g_vis_status=1;
   Print("GDS TM visual replay: scanning up to ",InpVisualLookbackHours,
         "h of BID ticks toward frozen checkpoint, limit=",InpVisualMaxTicks,
         ", no changes to trading/position state.");
  }

bool UIVisualInitialize(const double first_bid)
  {
   if(first_bid<=0.0 || !MathIsValidNumber(first_bid)) return false;
   const long step=(long)MathRound(g_brick_price/g_tick_size);
   if(step<=0) return false;
   const long p=(long)MathRound(first_bid/g_tick_size);
   // All actual engine closes belong to the lattice of the known checkpoint.
   const long k=(long)MathRound((double)(p-g_vis_checkpoint_close)/(double)step);
   const long aligned=g_vis_checkpoint_close+k*step;
   if(aligned<=step || aligned+step<=0) return false;
   for(int i=0;i<3;i++) g_vis_builders[i].Init(g_tick_size,step);
   if(!g_vis_builders[0].Restore(aligned,0,0,true) ||
      !g_vis_builders[1].Restore(aligned-step,1,1,true) ||
      !g_vis_builders[2].Restore(aligned+step,-1,1,true)) return false;
   g_vis_seeded=true;
   return true;
  }

bool UIVisualStatesAgree(void)
  {
   long a=0,c=0; int da=0,ra=0,d=0,r=0; bool ha=false,h=false;
   g_vis_builders[0].GetState(a,da,ra,ha);
   if(!ha || a<=0 || da==0 || ra<=0) return false;
   for(int i=1;i<3;i++)
     {
      g_vis_builders[i].GetState(c,d,r,h);
      if(!h || c!=a || d!=da || r!=ra) return false;
     }
   return true;
  }

void UIVisualSaveBrick(const SBrick &b)
  {
   g_vis_bricks[g_vis_next]=b;
   g_vis_next=(g_vis_next+1)%GDS_UI_RING_SIZE;
   if(g_vis_count<GDS_UI_RING_SIZE) g_vis_count++;
  }

bool UIVisualFeed(const double bid)
  {
   if(!g_vis_seeded && !UIVisualInitialize(bid)) return false;
   SBrick primary[];
   for(int k=0;k<3;k++)
     {
      SBrick produced[];
      const int n=g_vis_builders[k].Push(bid,produced);
      if(n<0) return false;
      if(k==0)
        {
         if(ArrayResize(primary,n)!=n) return false;
         for(int j=0;j<n;j++) primary[j]=produced[j];
        }
     }
   const bool equal=UIVisualStatesAgree();
   if(g_vis_converged)
     {
      if(!equal) return false;
      for(int j=0;j<ArraySize(primary);j++) UIVisualSaveBrick(primary[j]);
     }
   else if(equal)
     {
      // The event that first converges hypothetical states might have
      // different earlier bricks within this tick. Start at the NEXT tick.
      g_vis_converged=true;
      g_vis_count=0;
      g_vis_next=0;
     }
   return true;
  }

bool UIVisualAtFrozenCheckpoint(void)
  {
   if(!g_vis_converged) return false;
   for(int i=0;i<3;i++)
     {
      long c=0; int d=0,r=0; bool a=false;
      g_vis_builders[i].GetState(c,d,r,a);
      if(!a || c!=g_vis_checkpoint_close ||
         d!=g_vis_checkpoint_dir || r!=g_vis_checkpoint_run) return false;
     }
   return true;
  }

void UIVisualAppendRolling(const SBrick &b)
  {
   g_ui_bricks[g_ui_next]=b;
   g_ui_next=(g_ui_next+1)%GDS_UI_RING_SIZE;
   if(g_ui_count<GDS_UI_RING_SIZE) g_ui_count++;
  }

void UIVisualFinish(void)
  {
   if(!UIVisualAtFrozenCheckpoint())
     { UIVisualAbort("broker BID replay does not match original Renko checkpoint"); return; }
   if(g_vis_count<=0)
     { UIVisualAbort("converged but no completed bricks in verified suffix"); return; }
   if(g_ui_completed_total<g_vis_begin_ui_count ||
      g_ui_completed_total-g_vis_begin_ui_count>GDS_UI_RING_SIZE)
     { UIVisualAbort("too many new live bricks during visual replay"); return; }
   const int added=(int)(g_ui_completed_total-g_vis_begin_ui_count);
   // Save ONLY the live bars recorded since the frozen checkpoint. Do not
   // mix historical display output into live event counters or trade logic.
   SBrick live[GDS_UI_RING_SIZE];
   for(int i=0;i<added;i++) live[i]=UIGetRecent(added,i);
   g_ui_count=0;
   g_ui_next=0;
   const int begin=(g_vis_next-g_vis_count+GDS_UI_RING_SIZE)%GDS_UI_RING_SIZE;
   for(int i=0;i<g_vis_count;i++)
      UIVisualAppendRolling(g_vis_bricks[(begin+i)%GDS_UI_RING_SIZE]);
   for(int i=0;i<added;i++) UIVisualAppendRolling(live[i]);
   g_ui_reconstructed=0;
   g_ui_proven=true;
   g_ui_origin="TICK REPLAY VERIFIED";
   g_ui_dirty=true;
   g_vis_status=2;
   Print("GDS TM visual replay MATCHED checkpoint; last ",g_vis_count,
         " reconstructed + ",added," new confirmed bricks; scanned BID ticks=",
         g_vis_processed,". Trading state unchanged.");
  }

void UIVisualStep(void)
  {
   if(g_vis_status!=1 || g_blocked || InpMode!=GDS_TM_MONITOR_ONLY) return;
   for(int batch=0;batch<GDS_VIS_COPIES_PER_TIMER;batch++)
     {
      if(g_vis_processed>=InpVisualMaxTicks)
        { UIVisualAbort("history tick budget reached before checkpoint"); return; }
      MqlTick ticks[];
      ResetLastError();
      const int n=CopyTicks(_Symbol,ticks,COPY_TICKS_INFO,
                             (ulong)g_vis_cursor_ms,GDS_VIS_CHUNK);
      const int error=GetLastError();
      if(n<=0 || error!=0)
        {
         if(++g_vis_waits>=GDS_VIS_MAX_EMPTY_RETRIES)
            UIVisualAbort("historical tick database unavailable/incomplete, error="+
                          IntegerToString(error));
         return;
        }
      bool advanced=false;
      int index_at_ms=0;
      for(int i=0;i<n;i++)
        {
         const long ms=ticks[i].time_msc;
         if(ms<g_vis_cursor_ms) continue;
         if(ms==g_vis_cursor_ms)
           {
            index_at_ms++;
            if(index_at_ms<=g_vis_seen) continue;
           }
         else
           {
            g_vis_cursor_ms=ms;
            g_vis_seen=0;
            index_at_ms=1;
           }
         if(ms>g_vis_checkpoint_ms ||
            (ms==g_vis_checkpoint_ms && index_at_ms>g_vis_checkpoint_seen))
           { UIVisualAbort("frozen checkpoint tick ordinal not found"); return; }
         if(ticks[i].bid<=0.0 || !MathIsValidNumber(ticks[i].bid) ||
            !UIVisualFeed(ticks[i].bid))
           { UIVisualAbort("invalid BID or unbounded multi-brick replay"); return; }
         g_vis_seen=index_at_ms;
         g_vis_processed++;
         advanced=true;
         if(ms==g_vis_checkpoint_ms && index_at_ms==g_vis_checkpoint_seen)
           { UIVisualFinish(); return; }
         if(g_vis_processed>=InpVisualMaxTicks)
           { UIVisualAbort("history tick budget reached before checkpoint"); return; }
        }
      if(!advanced)
        {
         if(++g_vis_waits>=GDS_VIS_MAX_EMPTY_RETRIES)
            UIVisualAbort("history cursor stalled / incomplete broker ticks");
         return;
        }
      if(n<GDS_VIS_CHUNK)
        {
         // Not enough synchronized broker ticks to reach the checkpoint.
         // Never accept a partial replay as verified. Retry if history is
         // arriving asynchronously; stop after bounded no-progress attempts.
         g_vis_waits=0;
         return;
        }
      g_vis_waits=0;
     }
  }
//--------------------------------------------------------------------------

int UIPriceY(const double price,const double low,const double high,
             const int top,const int height)
  {
   if(high<=low) return top+height/2;
   return top+(int)MathRound((high-price)/(high-low)*(double)height);
  }

string UIPrice(const double price)
  {
   return (price<=0.0 ? "--" : DoubleToString(price,_Digits));
  }

string UIBrickDirection(void)
  {
   long close_tick=0; int direction=0,run=0; bool anchor=false;
   g_renko.GetState(close_tick,direction,run,anchor);
   if(!anchor) return "WAITING FOR SEED";
   if(direction>0) return "UP  /  RUN "+IntegerToString(run);
   if(direction<0) return "DOWN  /  RUN "+IntegerToString(run);
   return "ANCHORED  /  WAITING";
  }

// Actual next BID thresholds of the classic two-brick reversal engine.
// Do not display these as already completed bars or as trade signals.
void UITriggerLevels(double &up,double &down)
  {
   long close_tick=0; int direction=0,run=0; bool anchor=false;
   g_renko.GetState(close_tick,direction,run,anchor);
   const double last=g_renko.ClosePrice();
   up=NormalizeDouble(last+(direction<0 ? 2.0 : 1.0)*g_brick_price,_Digits);
   down=NormalizeDouble(last-(direction>0 ? 2.0 : 1.0)*g_brick_price,_Digits);
  }

string UIAccountMode(void)
  {
   const long mode=AccountInfoInteger(ACCOUNT_TRADE_MODE);
   if(mode==ACCOUNT_TRADE_MODE_DEMO) return "DEMO";
   if(mode==ACCOUNT_TRADE_MODE_REAL) return "REAL";
   return "CONTEST";
  }

void UIFrame(const int x,const int y,const int w,const int h)
  {
   UIBox("panel.shadow",x+3,y+4,w,h,GDS_UI_SHADOW,GDS_UI_SHADOW);
   UIBox("panel.bg",x,y,w,h,GDS_UI_BG,GDS_UI_LINE);
   UIBox("panel.accent",x,y,w,3,GDS_UI_ACCENT,GDS_UI_ACCENT);
  }

void UIHeader(const int x,const int y,const int w,const bool synchronized,
              const bool collapsed)
  {
   UIText("brand","GOLDEN DELTA   /   GDS",x+15,y+11,9,GDS_UI_ACCENT,true);
   UIText("version","v1.000",x+w-149,y+12,9,GDS_UI_MUTED);
   UIButton("ui.dock",(g_ui_dock_right ? "LEFT" : "RIGHT"),x+w-95,y+8,50,
            "Move display to the opposite side of the chart");
   UIButton("ui.toggle",(collapsed ? "+" : "-"),x+w-39,y+8,25,
            (collapsed ? "Expand display" : "Minimize display"));
   UIText("title","RENKO TRADE MANAGER",x+15,y+34,14,GDS_UI_TEXT,true);
   if(collapsed)
     {
      UIText("mini.mode",(InpMode==GDS_TM_MONITOR_ONLY ? "MONITOR ONLY" : "MANAGE LIVE")+
             "   /   "+UIAccountMode()+"   /   "+IntegerToString(ArraySize(g_tracks))+" TRACKED",
             x+15,y+57,9,(InpMode==GDS_TM_MONITOR_ONLY ? GDS_UI_MUTED : GDS_UI_AMBER));
      return;
     }
   const bool monitor=(InpMode==GDS_TM_MONITOR_ONLY);
   const bool narrow=(w<338);
   UIChip("mode",(monitor ? "MONITOR ONLY" : "MANAGE LIVE"),x+15,y+63,(narrow ? 113 : 125),
          (monitor ? GDS_UI_TILE : GDS_UI_AMBER_BG),
          (monitor ? GDS_UI_ACCENT : GDS_UI_AMBER));
   UIChip("feed",(g_blocked ? "HALT" : (synchronized ? "TICKS OK" : "SYNC WAIT")),
          x+(narrow ? 132 : 148),y+63,(narrow ? 87 : 111),GDS_UI_TILE,
          (g_blocked ? GDS_UI_DOWN : (synchronized ? GDS_UI_UP : GDS_UI_AMBER)));
   UIChip("account",UIAccountMode(),x+w-(narrow ? 71 : 77),y+63,(narrow ? 56 : 62),
          (AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_REAL ?
           GDS_UI_AMBER_BG : GDS_UI_TILE),
          (AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_REAL ?
           GDS_UI_AMBER : GDS_UI_MUTED));
   UIBox("head.rule",x+15,y+94,w-30,1,GDS_UI_LINE,GDS_UI_LINE);
  }

void UIMarket(const int x,const int y,const int w)
  {
   MqlTick quote={};
   const bool valid=SymbolInfoTick(_Symbol,quote) && quote.bid>0.0 && quote.time_msc>0;
   const double bid=(valid ? quote.bid : 0.0);
   double up=0.0,down=0.0;
   UITriggerLevels(up,down);
   UIText("market.label","MARKET  /  "+_Symbol,x+15,y+100,9,GDS_UI_MUTED,true);
   UIText("market.clock",(valid ? "QUOTE "+TimeToString(quote.time,TIME_SECONDS) : "NO QUOTE"),
          x+w-113,y+101,8,GDS_UI_MUTED);
   UIText("market.bid",UIPrice(bid),x+15,y+116,17,GDS_UI_TEXT,true);
   UIText("market.brick","BRICK   "+UIPrice(g_brick_price),x+w-145,y+120,11,GDS_UI_ACCENT,true);
   UIText("market.state",UIBrickDirection(),x+15,y+148,9,GDS_UI_TEXT,true);
   UIText("market.count","+"+StringFormat("%I64u",g_ui_completed_total)+" since load",
          x+w-130,y+148,8,GDS_UI_MUTED);
   UIText("market.triggers","NEXT UP  >= "+UIPrice(up)+"     DOWN  <= "+UIPrice(down),
          x+15,y+167,9,GDS_UI_MUTED);
   UIBox("market.rule",x+15,y+189,w-30,1,GDS_UI_LINE,GDS_UI_LINE);
  }

// A compact price-scaled inset; horizontal axis is completed-brick ORDER,
// NOT the timeframe/candle clock (several bricks can share one tick).
void UIRenkoInset(const int x,const int y,const int w,const int plot_h)
  {
   const int count=MathMin(g_ui_count,InpVisibleBricks);
   UIText("plot.heading","COMPLETED RENKO  /  BID",x+15,y+197,10,GDS_UI_TEXT,true);
   UIText("plot.counter",IntegerToString(count)+" / "+IntegerToString(InpVisibleBricks),
          x+w-71,y+199,9,GDS_UI_ACCENT,true);
   const int px=x+15,py=y+220,pw=w-30,ph=plot_h;
   UIBox("plot.area",px,py,pw,ph,GDS_UI_TILE,GDS_UI_TILE);
   if(count==0)
     {
      // A fresh attach does not replay historical bars just to fill the UI.
      // Show true BID progress toward the next confirmed brick instead.
      ObjectsDeleteAll(0,g_ui_prefix+"plot.grid");
      ObjectsDeleteAll(0,g_ui_prefix+"plot.axis");
      ObjectsDeleteAll(0,g_ui_prefix+"plot.last.");
      UIText("plot.empty.title","Waiting for the next COMPLETED brick",px+11,py+8,10,GDS_UI_TEXT,true);
      double up=0.0,down=0.0; UITriggerLevels(up,down);
      MqlTick q={};
      const bool valid=SymbolInfoTick(_Symbol,q) && q.bid>0.0;
      const double last=g_renko.ClosePrice();
      const double up_progress=(valid ? MathMax(0.0,MathMin(1.0,(q.bid-last)/MathMax(up-last,g_tick_size))) : 0.0);
      const double down_progress=(valid ? MathMax(0.0,MathMin(1.0,(last-q.bid)/MathMax(last-down,g_tick_size))) : 0.0);
      const int half=(pw-36)/2;
      const int by=py+ph-17;
      UIText("plot.empty.uptext","UP  "+UIPrice(up),px+12,py+ph-51,9,GDS_UI_UP,true);
      UIText("plot.empty.downtext","DOWN  "+UIPrice(down),px+half+24,py+ph-51,9,GDS_UI_DOWN,true);
      UIBox("plot.empty.upbg",px+12,by,half,7,GDS_UI_LINE,GDS_UI_LINE);
      UIBox("plot.empty.upfill",px+12,by,MathMax(1,(int)MathRound(half*up_progress)),7,
            (up_progress>0.0 ? GDS_UI_UP : GDS_UI_LINE),
            (up_progress>0.0 ? GDS_UI_UP : GDS_UI_LINE));
      UIBox("plot.empty.downbg",px+half+24,by,half,7,GDS_UI_LINE,GDS_UI_LINE);
      UIBox("plot.empty.downfill",px+half+24,by,MathMax(1,(int)MathRound(half*down_progress)),7,
            (down_progress>0.0 ? GDS_UI_DOWN : GDS_UI_LINE),
            (down_progress>0.0 ? GDS_UI_DOWN : GDS_UI_LINE));
     }
   else
     {
      ObjectsDeleteAll(0,g_ui_prefix+"plot.empty.");
      const int ax=px+pw-55;
      const int draw_w=MathMax(24,ax-px-7);
      SBrick first=UIGetRecent(count,0);
      double low=MathMin(first.close,first.close-first.direction*g_brick_price);
      double high=MathMax(first.close,first.close-first.direction*g_brick_price);
      for(int i=1;i<count;i++)
        {
         SBrick b=UIGetRecent(count,i);
         const double opening=b.close-b.direction*g_brick_price;
         low=MathMin(low,MathMin(opening,b.close));
         high=MathMax(high,MathMax(opening,b.close));
        }
      const double pad=MathMax(g_brick_price*0.6,(high-low)*0.09);
      low-=pad; high+=pad;
      if(high<=low) high=low+g_brick_price;
      for(int j=0;j<3;j++)
        {
         const int gy=py+8+(int)MathRound((double)j*(ph-17)/2.0);
         const double p=high-(high-low)*(double)(gy-py)/(double)ph;
         UIBox("plot.grid"+IntegerToString(j),px+5,gy,draw_w-5,1,GDS_UI_LINE,GDS_UI_LINE);
         UIText("plot.axis"+IntegerToString(j),UIPrice(p),ax,gy-7,8,GDS_UI_MUTED);
        }
      const int step=MathMax(4,(draw_w-14)/InpVisibleBricks);
      const int bw=MathMax(2,step-2);
      for(int i=0;i<InpVisibleBricks;i++)
        {
         const string key="plot.brick"+IntegerToString(i);
         if(i>=count) { ObjectDelete(0,g_ui_prefix+key); continue; }
         SBrick b=UIGetRecent(count,i);
         const double opening=b.close-b.direction*g_brick_price;
         const int by1=UIPriceY(MathMax(opening,b.close),low,high,py+5,ph-10);
         const int by2=UIPriceY(MathMin(opening,b.close),low,high,py+5,ph-10);
         const int bx=px+draw_w-7-(count-1-i)*step-bw;
         const color ink=(b.direction>0 ? GDS_UI_UP : GDS_UI_DOWN);
         UIBox(key,bx,by1,bw,MathMax(2,by2-by1),ink,
               (i==count-1 ? GDS_UI_TEXT : ink));
         ObjectSetString(0,g_ui_prefix+key,OBJPROP_TOOLTIP,
                         (b.direction>0 ? "UP" : "DOWN")+"  /  close "+UIPrice(b.close));
        }
      SBrick latest_brick=UIGetRecent(count,count-1);
      const int ly=UIPriceY(latest_brick.close,low,high,py+5,ph-10);
      UIBox("plot.last.line",px+5,ly,draw_w-8,1,GDS_UI_ACCENT,GDS_UI_ACCENT);
      UIText("plot.last.value","LAST "+UIPrice(latest_brick.close),px+8,py+5,8,GDS_UI_ACCENT,true);
     }
   string note="Live engine bricks / no time axis";
   if(g_vis_status==1)
      note="BID TICK REPLAY: "+IntegerToString(g_vis_processed)+" scanned (pending)";
   else if(g_vis_status==3)
      note="REPLAY UNVERIFIED / showing available bars";
   else if(g_vis_status==2 || g_ui_proven)
      note="BID REPLAY MATCHED / checkpoint-verified suffix";
   else if(g_vis_status==4)
      note="FRESH ENGINE / history starts at attach";
   else if(g_vis_status==5)
      note="LIVE MODE / historical scan disabled";
   else if(g_ui_reconstructed>0)
      note="Checkpoint run / earlier reversals unknown";
   else if(g_ui_origin=="SAVED EVENTS" && g_ui_completed_total==0)
      note="Saved completed events / history not replayed";
   else if(count==0)
      note="Waiting for first completed brick";
   UIText("plot.note",note,x+15,py+ph+6,8,GDS_UI_MUTED);
  }

// Read-only position card. Targets reflect the manager's actual persisted
// reference, best Renko close and configured thresholds (not order changes).
void UIPositionCard(const int i,const int x,const int y,const int w)
  {
   const string p="position."+IntegerToString(i)+".";
   UIBox(p+"bg",x,y,w,87,GDS_UI_TILE,GDS_UI_LINE);
   if(i>=ArraySize(g_tracks) || !SelectTrackPosition(i))
     {
      // Never leave old levels from a position no longer selectable.
      ObjectsDeleteAll(0,g_ui_prefix+p);
      UIBox(p+"bg",x,y,w,87,GDS_UI_TILE,GDS_UI_LINE);
      UIText(p+"header","Position data temporarily unavailable",x+12,y+10,9,GDS_UI_MUTED);
      return;
     }
   const int progress=FavorableBricks(i);
   const int side=g_tracks[i].side;
   const color ink=(side>0 ? GDS_UI_UP : GDS_UI_DOWN);
   const double entry=PositionGetDouble(POSITION_PRICE_OPEN);
   const double sl=PositionGetDouble(POSITION_SL);
   const double lot=PositionGetDouble(POSITION_VOLUME);
   const string side_text=(side>0 ? "BUY" : "SELL");
   UIText(p+"header",side_text+"  "+DoubleToString(lot,2)+" lot",x+11,y+6,10,ink,true);
   UIText(p+"ticket",StringFormat("#%I64u",g_tracks[i].ticket),x+w-112,y+8,9,GDS_UI_MUTED);
   // MET means the completed-brick threshold was reached, NOT that
   // the broker already accepted the corresponding stop modification.
   const string be_progress=(InpBEAfterBricks>0 ?
         (progress>=InpBEAfterBricks ? "MET" : IntegerToString(InpBEAfterBricks-progress)+" left") : "OFF");
   const string tr_progress=(InpTrailStartBricks>0 ?
         (progress>=InpTrailStartBricks ? "MET" : IntegerToString(InpTrailStartBricks-progress)+" left") : "OFF");
   UIText(p+"progress","PEAK "+IntegerToString(progress)+" brick(s)    BE "+be_progress+
          "    TRAIL "+tr_progress,x+11,y+25,9,GDS_UI_TEXT);
   const int goal=(InpTrailStartBricks>0 ? InpTrailStartBricks :
                   (InpBEAfterBricks>0 ? InpBEAfterBricks : 1));
   const double portion=(double)MathMin(progress,goal)/(double)MathMax(1,goal);
   UIBox(p+"meter.bg",x+11,y+44,w-22,4,GDS_UI_LINE,GDS_UI_LINE);
   UIBox(p+"meter.fill",x+11,y+44,MathMax(1,(int)MathRound((w-22)*portion)),4,
         (portion>0.0 ? ink : GDS_UI_LINE),(portion>0.0 ? ink : GDS_UI_LINE));
   string be="OFF";
   if(InpBEAfterBricks>0)
      be=UIPrice(NormalizeStop(entry+side*InpBEOffsetBricks*g_brick_price,side));
   string tr="OFF";
   if(InpTrailStartBricks>0)
      tr=UIPrice(NormalizeStop(g_tracks[i].best-side*InpTrailGapBricks*g_brick_price,side));
   UIText(p+"levels","SL "+(sl>0.0 ? UIPrice(sl) : "NOT SET")+
          "   /   BE "+be+"   /   TRAIL "+tr,
          x+11,y+52,9,(sl>0.0 ? GDS_UI_MUTED : GDS_UI_AMBER));
   UIText(p+"flags","NO NEW ENTRIES / NO POSITION CLOSES",
          x+11,y+70,8,GDS_UI_MUTED);
  }

void UIPositions(const int x,const int y,const int w,const int start,
                 const int card_capacity)
  {
   const int total=ArraySize(g_tracks);
   UIText("positions.heading","MANAGED POSITIONS",x+15,y+start,10,GDS_UI_TEXT,true);
   UIText("positions.count",IntegerToString(total)+" tracked",x+w-(total>1 ? 178 : 88),y+start+1,9,GDS_UI_ACCENT,true);
   if(total>1)
      UIButton("ui.view","VIEW ALL",x+w-99,y+start-5,84,
               "Show each position, its stop and brick progress on this chart");
   else ObjectDelete(0,g_ui_prefix+"ui.view");
   const int card_top=y+start+25;
   const int cards=MathMin(total,card_capacity);
   for(int i=cards;i<g_ui_last_visible_cards;i++)
      ObjectsDeleteAll(0,g_ui_prefix+"position."+IntegerToString(i)+".");
   g_ui_last_visible_cards=cards;
   if(cards==0)
     {
      UIBox("positions.empty.bg",x+15,card_top,w-30,62,GDS_UI_TILE,GDS_UI_LINE);
      UIText("positions.empty.title","No eligible manual positions",x+27,card_top+10,10,GDS_UI_TEXT,true);
      UIText("positions.empty.tip","DEMO: open a manual trade on "+_Symbol,x+27,card_top+34,9,GDS_UI_MUTED);
     }
   else ObjectsDeleteAll(0,g_ui_prefix+"positions.empty.");
   for(int i=0;i<cards;i++) UIPositionCard(i,x+15,card_top+i*93,w-30);
   const int more=total-cards;
   UIText("positions.more",(more>0 ? "+ "+IntegerToString(more)+" more positions (click VIEW ALL)" : ""),
          x+15,card_top+cards*93+3,8,GDS_UI_AMBER);
  }


// Full multi-position observer. Five rows fit in an ordinary MT5 chart.
// A read-only list is shown by default with 2+ positions. The RENKO button
// switches back to the brick plot without changing the manager state.
// In smaller windows, pages expose EVERY tracked position, never silently drop it.
string UIReadyLabel(const int progress,const int threshold)
  {
   if(threshold<=0) return "OFF";
   if(progress>=threshold) return "MET"; // Brick count only; not execution status.
   return IntegerToString(threshold-progress)+" left";
  }

void UIPositionListRow(const int index,const int slot,const int x,const int y,
                       const int w,const bool selected)
  {
   const string k="poslist.row."+IntegerToString(slot)+".";
   const color surface=(selected ? C'27,53,70' : GDS_UI_TILE);
   UIBox(k+"bg",x,y,w,38,surface,(selected ? GDS_UI_ACCENT : GDS_UI_LINE));
   if(index<0 || index>=ArraySize(g_tracks) || !SelectTrackPosition(index))
     {
      const string label=(index>=0 && index<ArraySize(g_tracks) ?
                          "#"+StringFormat("%I64u",g_tracks[index].ticket) : "Position");
      UIText(k+"header",label+"  /  temporarily unavailable",x+10,y+9,9,GDS_UI_AMBER);
      ObjectDelete(0,g_ui_prefix+k+"ticket");
      ObjectDelete(0,g_ui_prefix+k+"favorable");
      ObjectDelete(0,g_ui_prefix+k+"details");
      ObjectDelete(0,g_ui_prefix+k+"side");
      ObjectDelete(0,g_ui_prefix+k+"pick");
      return;
     }
   const bool buy=(g_tracks[index].side>0);
   const int progress=FavorableBricks(index);
   const double sl=PositionGetDouble(POSITION_SL);
   const double lot=PositionGetDouble(POSITION_VOLUME);
   const color ink=(buy ? GDS_UI_UP : GDS_UI_DOWN);
   UIBox(k+"side",x+2,y+3,3,32,ink,ink);
   UIText(k+"header",(buy ? "BUY " : "SELL ")+DoubleToString(lot,2)+" lot",
          x+11,y+3,9,ink,true);
   UIText(k+"ticket",StringFormat("#%I64u",g_tracks[index].ticket),
          x+104,y+3,8,GDS_UI_MUTED);
   UIText(k+"favorable","PEAK "+IntegerToString(progress),x+w-77,y+3,8,GDS_UI_TEXT);
   UIText(k+"details","SL "+(sl>0.0 ? UIPrice(sl) : "NOT SET")+
          "   BE "+UIReadyLabel(progress,InpBEAfterBricks)+
          "   TR "+UIReadyLabel(progress,InpTrailStartBricks),
          x+11,y+21,8,(sl<=0.0 ? GDS_UI_AMBER : GDS_UI_MUTED));
   UIButton(k+"pick",(selected ? "*" : ">"),x+w-29,y+8,22,
            "Select this position to see its expanded Renko management details");
  }

// Purely visual reporting: broker SL is the only proof that a stop is set.
// Thresholds and calculated targets alone do NOT imply broker acceptance.
int UINoStopCount(void)
  {
   int count=0;
   for(int i=0;i<ArraySize(g_tracks);i++)
     {
      if(!SelectTrackPosition(i)) continue;
      if(PositionGetDouble(POSITION_SL)<=0.0) count++;
     }
   return count;
  }

string UIFooterText(void)
  {
   if(g_blocked) return "SAFE HALT  /  NO BROKER ACTIONS";
   const int missing=UINoStopCount();
   const string prefix=(InpMode==GDS_TM_MONITOR_ONLY ? "READ-ONLY" : "MANAGE LIVE");
   if(missing>0)
      return prefix+"  /  "+IntegerToString(missing)+" POSITION(S) WITHOUT SL";
   return prefix+"  /  NO NEW ENTRIES";
  }

void UIPositionFocusedView(const int x,const int y,const int w,
                           const int available,const bool synchronized)
  {
   const int total=ArraySize(g_tracks);
   const bool short_view=(available<515);
   const int row_top=(short_view ? 162 : 230);
   const int row_height=40;
   // Space for a readable footer, plus paging controls if required.
   int capacity=MathMax(1,MathMin(5,(available-row_top-27)/row_height));
   while(capacity>1 && total>capacity &&
         row_top+capacity*row_height+27+27>available) capacity--;
   g_ui_page_capacity=capacity;
   const int pages=(total==0 ? 1 : (total+capacity-1)/capacity);
   g_ui_page=MathMax(0,MathMin(g_ui_page,pages-1));
   const int first=g_ui_page*capacity;
   const int rows=MathMin(capacity,MathMax(0,total-first));
   const bool pager=(pages>1);
   const int pager_h=(pager ? 27 : 0);
   const bool detail=(total>0 && row_top+rows*row_height+pager_h+93+27<=available);
   const int detail_h=(detail ? 93 : 0);
   const int panel_h=MathMin(available,row_top+(total==0 ? 59 : rows*row_height)+
                             pager_h+detail_h+27);
   UIFrame(x,y,w,panel_h);
   UIHeader(x,y,w,synchronized,false);
   if(!short_view) UIMarket(x,y,w);
   else
     {
      UIText("focus.market",_Symbol+"  /  BID "+UIPrice(SymbolInfoDouble(_Symbol,SYMBOL_BID))+
             "    BRICK "+UIPrice(g_brick_price),x+15,y+102,10,GDS_UI_ACCENT,true);
      UIText("focus.direction",UIBrickDirection()+
             "   |   "+IntegerToString(total)+" tracked",x+15,y+121,9,GDS_UI_MUTED);
     }
   const int title_y=row_top-29;
   UIText("focus.heading","MANAGED POSITIONS",x+15,y+title_y,10,GDS_UI_TEXT,true);
   UIText("focus.count",IntegerToString(total)+" tracked",x+w-162,y+title_y+1,8,GDS_UI_ACCENT);
   UIButton("ui.view","RENKO",x+w-88,y+title_y-5,73,
            "Show the completed Renko brick plot instead of the all-positions list");
   if(total==0)
     {
      if(g_ui_last_selected_card_index>=0)
        {
         ObjectsDeleteAll(0,g_ui_prefix+"position."+
                          IntegerToString(g_ui_last_selected_card_index)+".");
         g_ui_last_selected_card_index=-1;
        }
      g_ui_selected_id=0;
      UIBox("focus.empty.bg",x+15,y+row_top,w-30,56,GDS_UI_TILE,GDS_UI_LINE);
      UIText("focus.empty.title","No eligible positions",x+27,y+row_top+10,10,GDS_UI_TEXT,true);
      UIText("focus.empty.tip","Manual positions will appear here",x+27,y+row_top+30,8,GDS_UI_MUTED);
     }
   else
     {
      ObjectsDeleteAll(0,g_ui_prefix+"focus.empty.");
      // Preserve selection by POSITION_IDENTIFIER, not by transient index.
      int selected=-1;
      for(int i=0;i<ArraySize(g_tracks);i++)
         if(g_tracks[i].id==g_ui_selected_id) { selected=i; break; }
      if(selected<first || selected>=first+rows)
        {
         selected=first;
         g_ui_selected_id=g_tracks[selected].id;
        }
      for(int slot=0;slot<rows;slot++)
         UIPositionListRow(first+slot,slot,x+15,y+row_top+slot*row_height,
                           w-30,first+slot==selected);
      if(detail)
        {
         if(g_ui_last_selected_card_index!=selected)
           {
            if(g_ui_last_selected_card_index>=0)
               ObjectsDeleteAll(0,g_ui_prefix+"position."+
                                IntegerToString(g_ui_last_selected_card_index)+".");
            g_ui_last_selected_card_index=selected;
           }
         UIPositionCard(selected,x+15,y+row_top+rows*row_height+pager_h+5,w-30);
        }
      else if(g_ui_last_selected_card_index>=0)
        {
         ObjectsDeleteAll(0,g_ui_prefix+"position."+
                          IntegerToString(g_ui_last_selected_card_index)+".");
         g_ui_last_selected_card_index=-1;
        }
     }
   for(int slot=rows;slot<g_ui_last_list_rows;slot++)
      ObjectsDeleteAll(0,g_ui_prefix+"poslist.row."+IntegerToString(slot)+".");
   g_ui_last_list_rows=rows;
   if(pager)
     {
      const int nav_y=y+row_top+rows*row_height+2;
      UIButton("ui.page.prev","<",x+15,nav_y,26,"Previous positions page");
      UIText("focus.page","PAGE "+IntegerToString(g_ui_page+1)+" / "+IntegerToString(pages)+
             "    ("+IntegerToString(first+1)+"-"+IntegerToString(first+rows)+" of "+
             IntegerToString(total)+")",x+50,nav_y+5,8,GDS_UI_MUTED);
      UIButton("ui.page.next",">",x+w-41,nav_y,26,"Next positions page");
     }
   else
     {
      ObjectDelete(0,g_ui_prefix+"ui.page.prev");
      ObjectDelete(0,g_ui_prefix+"ui.page.next");
      ObjectDelete(0,g_ui_prefix+"focus.page");
     }
   UIText("foot",UIFooterText(),x+15,y+panel_h-21,8,
          (InpMode==GDS_TM_MONITOR_ONLY ? GDS_UI_MUTED : GDS_UI_AMBER),true);
  }

void UIMiniSummary(const int x,const int y,const int w)
  {
   UIText("compact.summary",_Symbol+"   "+UIBrickDirection(),x+15,y+105,10,GDS_UI_TEXT,true);
   UIText("compact.price","BID "+UIPrice(SymbolInfoDouble(_Symbol,SYMBOL_BID))+
          "    /    BRICK "+UIPrice(g_brick_price),x+15,y+129,10,GDS_UI_ACCENT);
   UIText("compact.count",StringFormat("%I64u",g_ui_completed_total)+
          " completed since load    /    "+IntegerToString(ArraySize(g_tracks))+" tracked",
          x+15,y+154,9,GDS_UI_MUTED);
   double up=0.0,down=0.0; UITriggerLevels(up,down);
   UIText("compact.thresholds","NEXT UP "+UIPrice(up)+"   /   DOWN "+UIPrice(down),
          x+15,y+180,9,GDS_UI_MUTED);
   UIBox("compact.rule",x+15,y+209,w-30,1,GDS_UI_LINE,GDS_UI_LINE);
   UIText("compact.text","Expand chart height to see Renko and positions.",
          x+15,y+226,9,GDS_UI_MUTED);
  }

void UIRender(const bool synchronized,const bool force=false)
  {
   // Throttle chart-object updates; the existing trading timer is unchanged.
   const ulong now=GetTickCount64();
   const int positions=ArraySize(g_tracks);
   if(!force && g_ui_last_draw_ms>0 && now>=g_ui_last_draw_ms &&
      now-g_ui_last_draw_ms<1600 && g_ui_synced==synchronized &&
      g_ui_last_draw_positions==positions) return;
   g_ui_synced=synchronized;
   if(!g_ui_view_touched)
      g_ui_positions_focus=(InpShowDashboard && positions>1);
   if(g_ui_prefix=="" || (!InpShowDashboard && !InpShowRenkoBricks)) return;
   const int cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   const int ch=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   if(cw<250 || ch<90) return;
   const int w=MathMin(InpPanelWidth,cw-20);
   const bool one_click_visible=(InpAvoidOneClickOverlap && !g_ui_dock_right &&
                                 (bool)ChartGetInteger(0,CHART_SHOW_ONE_CLICK,0));
   int safe_left=InpPanelX;
   int safe_top=InpPanelY;
   if(one_click_visible)
     {
      // Standard MT5 One Click Trading buttons occupy top-left chart pixels.
      // Do not disable the native panel; keep our controls out of its area.
      if(cw-w>=230) safe_left=MathMax(safe_left,218);
      else safe_top=MathMax(safe_top,116);
     }
   const int x=MathMax(2,MathMin(cw-w-2,
      (g_ui_dock_right ? cw-InpRenkoRightMargin-w : safe_left)));
   const int y=MathMax(2,MathMin(ch-76,safe_top));
   const int available=ch-y-7;
   const bool minimized=(g_ui_collapsed || available<275 || w<280);
   const bool compact=(available<490 || w<322);
   const bool focused=(InpShowDashboard && g_ui_positions_focus);
   const int layout=(minimized ? 1 : (focused ? (available<515 ? 5 : 6) :
                    (compact ? 2 : (InpShowRenkoBricks ? 3 : 4))));
   if(layout!=g_ui_layout)
     {
      ObjectsDeleteAll(0,g_ui_prefix);
      g_ui_last_visible_cards=0;
      g_ui_last_list_rows=0;
      g_ui_last_selected_card_index=-1;
      g_ui_layout=layout;
     }
   if(minimized)
     {
      UIFrame(x,y,w,79);
      UIHeader(x,y,w,synchronized,true);
      ChartRedraw(0);
      g_ui_last_draw_ms=now; g_ui_last_draw_positions=positions;
      return;
     }
   if(focused)
     {
      // Multi-position mode: compact two-line summaries for EVERY ticket.
      // The risk/trading engine does not read any of these UI controls.
      UIPositionFocusedView(x,y,w,available,synchronized);
     }
   else if(compact)
     {
      // Automatic small-chart view: no invisible panels below the window.
      UIFrame(x,y,w,261);
      UIHeader(x,y,w,synchronized,false);
      UIMiniSummary(x,y,w);
     }
   else
     {
      // Fit one full position card and the available number of additional
      // cards; reduce only the chart-inset height on shorter workspaces.
      const int more_budget=(InpShowDashboard && positions>1 ? 18 : 0);
      const int ph=(InpShowRenkoBricks ?
                    MathMax(74,MathMin(142,available-400-more_budget)) : 0);
      const int pos_start=(InpShowRenkoBricks ? 250+ph : 195);
      int capacity=0;
      if(InpShowDashboard)
        {
         for(int candidate=1;candidate<=MathMin(positions,3);candidate++)
           {
            const int hidden_after=MathMax(0,positions-candidate);
            const int required=pos_start+25+candidate*93-6+30+
                               (hidden_after>0 ? 18 : 0);
            if(required<=available) capacity=candidate;
            else break;
           }
        }
      const int card_height=(InpShowDashboard ? (positions==0 ? 62 : capacity*93-6) : 0);
      const int hidden=(InpShowDashboard ? MathMax(0,positions-capacity) : 0);
      const int panel_h=(InpShowDashboard ? pos_start+25+card_height+30+(hidden>0 ? 18 : 0) : 242+ph);
      UIFrame(x,y,w,panel_h);
      UIHeader(x,y,w,synchronized,false);
      UIMarket(x,y,w);
      if(InpShowRenkoBricks) UIRenkoInset(x,y,w,ph);
      if(InpShowDashboard) UIPositions(x,y,w,pos_start,capacity);
      UIText("foot",UIFooterText(),x+15,y+panel_h-21,8,
             (InpMode==GDS_TM_MONITOR_ONLY ? GDS_UI_MUTED : GDS_UI_AMBER),true);
     }
   ChartRedraw(0);
   g_ui_last_draw_ms=now;
   g_ui_last_draw_positions=positions;
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK && sparam==g_ui_prefix+"ui.toggle")
     {
      g_ui_collapsed=!g_ui_collapsed;
      UIRender(g_ui_synced,true);
     }
   else if(id==CHARTEVENT_OBJECT_CLICK && sparam==g_ui_prefix+"ui.dock")
     {
      g_ui_dock_right=!g_ui_dock_right;
      UIRender(g_ui_synced,true);
     }
   else if(id==CHARTEVENT_OBJECT_CLICK && sparam==g_ui_prefix+"ui.view")
     {
      g_ui_positions_focus=!g_ui_positions_focus;
      g_ui_view_touched=true;
      g_ui_page=0;
      UIRender(g_ui_synced,true);
     }
   else if(id==CHARTEVENT_OBJECT_CLICK && sparam==g_ui_prefix+"ui.page.prev")
     {
      if(g_ui_page>0) g_ui_page--;
      g_ui_selected_id=0;
      UIRender(g_ui_synced,true);
     }
   else if(id==CHARTEVENT_OBJECT_CLICK && sparam==g_ui_prefix+"ui.page.next")
     {
      const int pages=(ArraySize(g_tracks)+g_ui_page_capacity-1)/g_ui_page_capacity;
      if(g_ui_page+1<pages) g_ui_page++;
      g_ui_selected_id=0;
      UIRender(g_ui_synced,true);
     }
   else if(id==CHARTEVENT_OBJECT_CLICK &&
           StringFind(sparam,g_ui_prefix+"poslist.row.")==0)
     {
      for(int slot=0;slot<g_ui_last_list_rows;slot++)
        {
         if(sparam==g_ui_prefix+"poslist.row."+IntegerToString(slot)+".pick")
           {
            const int index=g_ui_page*g_ui_page_capacity+slot;
            if(index>=0 && index<ArraySize(g_tracks))
               g_ui_selected_id=g_tracks[index].id;
            UIRender(g_ui_synced,true);
            return;
           }
        }
     }
   else if(id==CHARTEVENT_CHART_CHANGE) UIRender(g_ui_synced,true);
  }
//-------------------------------------------------------------------

void ManagePositions(const bool synchronized)
  {
   string status="GDS RENKO TRADE MANAGER 1.000 | "+
      (InpMode==GDS_TM_MANAGE_LIVE ? "LIVE ENABLED" : "MONITOR ONLY")+
      " | "+_Symbol+" | brick="+DoubleToString(g_brick_price,_Digits)+
      " | positions="+IntegerToString(ArraySize(g_tracks));
   if(g_blocked) status+="\nSAFE HALT: state/ownership fault";
   else if(!synchronized) status+="\nWaiting for tick-history synchronization; actions disabled";
   int shown=0;
   for(int i=0;i<ArraySize(g_tracks);i++)
     {
      if(!SelectTrackPosition(i)) continue;
      const int progress=FavorableBricks(i);
      if(shown<5)
        {
         status+="\n#"+StringFormat("%I64u",g_tracks[i].ticket)+
              (g_tracks[i].side>0 ? " BUY " : " SELL ")+
              IntegerToString(progress)+" favorable bricks";
         shown++;
        }
      if(!synchronized || g_blocked || InpMode!=GDS_TM_MANAGE_LIVE) continue;
      if(!TradePermitted()) continue;
      MqlTick quote={};
      if(!SymbolInfoTick(_Symbol,quote) || quote.bid<=0.0 || quote.ask<quote.bid)
         continue;
      const double original=PositionGetDouble(POSITION_PRICE_OPEN);
      const double previous=PositionGetDouble(POSITION_SL);
      double proposed=0.0;
      bool desired=false;
      if(InpBEAfterBricks>0 && progress>=InpBEAfterBricks)
        {
         proposed=original+g_tracks[i].side*InpBEOffsetBricks*g_brick_price;
         desired=true;
        }
      if(InpTrailStartBricks>0 && progress>=InpTrailStartBricks)
        {
         const double t=g_tracks[i].best-g_tracks[i].side*InpTrailGapBricks*g_brick_price;
         if(!desired || g_tracks[i].side*(t-proposed)>0.0) proposed=t;
         desired=true;
        }
      if(desired)
        {
         proposed=NormalizeStop(proposed,g_tracks[i].side);
         const double min_advance=(previous==0.0 ? 0.0 :
            (InpTrailStepBricks>0 ? InpTrailStepBricks*g_brick_price : g_tick_size));
         if((previous==0.0 || g_tracks[i].side*(proposed-previous)>=min_advance-1e-8) &&
            ValidStop(proposed,g_tracks[i].side,quote))
            SendSL(i,proposed);
        }

     }
   if(!InpShowDashboard && !InpShowRenkoBricks) Comment(status);
   else Comment("");
  }

int OnInit(void)
  {
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      if(InpMode==GDS_TM_MANAGE_LIVE)
        { Print("GDS TM: active mode requires a hedging account."); return INIT_FAILED; }
      Print("GDS TM: netting/exchange account accepted in MONITOR-ONLY mode. No broker actions.");
     }
   if(!MathIsValidNumber(InpBrickSize) || InpBrickSize<=0.0 ||
      InpBEAfterBricks<0 || InpTrailStartBricks<0 || InpTrailGapBricks<1 ||
      InpTrailStepBricks<0 || !MathIsValidNumber(InpBEOffsetBricks) || InpBEOffsetBricks<0.0 ||
      InpRecoveryMaxHours<1 ||
      (!InpManualOnly && InpMagicFilter<=0) ||
      InpVisibleBricks<12 || InpVisibleBricks>36 ||
      InpPanelWidth<330 || InpPanelWidth>420 ||
      InpPanelX<0 || InpPanelY<0 || InpRenkoRightMargin<0 ||
      InpVisualLookbackHours<1 || InpVisualLookbackHours>72 ||
      InpVisualMaxTicks<10000 || InpVisualMaxTicks>750000)
      return INIT_PARAMETERS_INCORRECT;
   g_tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(g_tick_size<=0.0 || !MathIsValidNumber(g_tick_size)) return INIT_FAILED;
   const double units=InpBrickSize/g_tick_size;
   if(units<1.0 || units>1000000000.0 || MathAbs(units-MathRound(units))>1e-6)
     { Print("GDS TM: Brick size must be an exact multiple of trade tick size."); return INIT_PARAMETERS_INCORRECT; }
   g_brick_price=MathRound(units)*g_tick_size;
   g_renko.Init(g_tick_size,(long)MathRound(units));
   const string identity=StringFormat("%I64d",AccountInfoInteger(ACCOUNT_LOGIN))+"|"+
      _Symbol+"|"+DoubleToString(g_brick_price,8)+"|"+
      (InpManualOnly ? "MANUAL" : StringFormat("%I64d",InpMagicFilter));
   g_base=StringFormat("GDTM10_%I64d_%08X",AccountInfoInteger(ACCOUNT_LOGIN),HashText(identity));
   // Object identifiers are isolated per chart; remove only stale GDS UI.
   g_ui_prefix="GDS_TM_V14_"+StringFormat("%I64d",ChartID())+"_";
   g_ui_collapsed=InpStartMinimized;
   g_ui_dock_right=InpDockRight;
   g_ui_history_base=g_base+".ui13";
   ObjectsDeleteAll(0,g_ui_prefix);
   if(!AcquireLock()) return INIT_FAILED;
   const bool restored=LoadStream();
   if(!restored)
     {
      if(MQLInfoInteger(MQL_TESTER))
        {
         // Before the first simulated market tick, SymbolInfoTick may hold
         // a pre-session quote or an initialization quote. Never anchor to it.
         g_test_waiting_tick=true;
         g_test_start_msc=(long)TimeCurrent()*1000;
         PrintFormat("GDS TM TESTER: waiting for first simulated OnTick. Start_ms=%I64d; no pre-session anchor.",
                     g_test_start_msc);
        }
      else
        {
         // Unchanged LIVE semantics, retained from v0.14.
         MqlTick seed={};
         if(!SymbolInfoTick(_Symbol,seed) || seed.time_msc<=0 || seed.bid<=0.0)
           { Print("GDS TM: Live quote required for initial anchor."); return INIT_FAILED; }
         g_renko.Anchor(seed.bid);
         g_last_ms=seed.time_msc;
         g_seen_ms=100000;
         if(!SaveStream()) return INIT_FAILED;
         Print("GDS TM: Fresh Renko anchor NOW. Existing trades start at observation time.");
        }
     }
   if(g_blocked) return INIT_FAILED;
   if(!g_test_waiting_tick)
     {
      // Display, replay and position restoration only after a trusted anchor.
      UIRestoreHistory();
      UIPersistHistory();
      UIVisualStart(restored);
      DiscoverPositions(false);
      if(g_blocked) return INIT_FAILED;
     }
   if(!EventSetTimer(1)) return INIT_FAILED;
   if(!g_test_waiting_tick) UIRender(false);
   Print("GDS TM: v1.000 UI / risk status initialized on ",_Symbol,". Mode=",EnumToString(InpMode),
         ". NO NEW POSITIONS WILL EVER BE OPENED.");
   return INIT_SUCCEEDED;
  }

// A first real simulated tick is the ONLY initial anchor source in a new test.
// OnTick does NOT manage positions or place orders; OnTimer remains in charge.
void OnTick(void)
  {
   if(!g_test_waiting_tick || g_blocked) return;
   MqlTick seed={};
   if(!SymbolInfoTick(_Symbol,seed) || seed.time_msc<=0 ||
      seed.bid<=0.0 || !MathIsValidNumber(seed.bid) || seed.ask<seed.bid) return;
   const long simulated_end_msc=(long)TimeCurrent()*1000+999;
   if(seed.time_msc<g_test_start_msc || seed.time_msc>simulated_end_msc)
     {
      PrintFormat("GDS TM TESTER: first-tick time mismatch start=%I64d quote=%I64d simulated_end=%I64d; seed withheld.",
                  g_test_start_msc,seed.time_msc,simulated_end_msc);
      return;
     }
   g_renko.Anchor(seed.bid);
   g_last_ms=seed.time_msc;
   g_seen_ms=100000;
   if(!SaveStream()) { Halt("Cannot persist first tester Renko anchor"); return; }
   g_test_waiting_tick=false;
   UIRestoreHistory();
   UIPersistHistory();
   UIVisualStart(false);
   DiscoverPositions(false);
   if(g_blocked) return;
   UIRender(false);
   PrintFormat("GDS TM TESTER: first real tick anchor ACCEPTED, ms=%I64d, bid=%s. No backdated bricks.",
               g_last_ms,DoubleToString(seed.bid,_Digits));
  }

void OnTimer(void)
  {
   if(g_test_waiting_tick) return; // Test before first trading tick; nothing to replay.
   if(g_blocked) { ManagePositions(false); UIRender(false); return; }
   double owner=0.0;
   if(!Read(g_lock,owner) || owner!=g_owner)
     { Halt("Instance ownership lost"); ManagePositions(false); UIRender(false); return; }
   if(!Store(g_beat,(double)TimeLocal()))
     { Halt("Cannot refresh instance heartbeat"); ManagePositions(false); UIRender(false); return; }
   DiscoverPositions(false);
   if(g_blocked) { ManagePositions(false); UIRender(false); return; }
   const bool synced=PollTicks();
   if(synced) DiscoverPositions(true);
   ManagePositions(synced && !g_blocked);
   // Saving optional chart history is deliberately AFTER trading decisions.
   if(!g_blocked)
     {
      UIPersistHistory();
      UIVisualStep(); // After trading path, monitor-only, visual observer only.
      UIPersistHistory(); // Commit visually matched bars when a replay completes.
     }
   UIRender(synced && !g_blocked);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   ReleaseLock();
   if(g_ui_prefix!="") ObjectsDeleteAll(0,g_ui_prefix);
   Comment("");
  }
//+------------------------------------------------------------------+
