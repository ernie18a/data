//+------------------------------------------------------------------+
//|                                                 SignalEngine.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23693 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23693"
#property version   "1.00"
#property strict

#include <RMA\RmaTypes.mqh>

//+------------------------------------------------------------------+
//| What the engine says about one closed bar.                       |
//|                                                                  |
//|  Every field here comes out of RMA_Engine with CopyBuffer. The   |
//|  struct exists so that the rules below can be read without       |
//|  knowing that, and so they can be driven from anywhere - a       |
//|  script, a test harness - by filling in ten numbers.             |
//+------------------------------------------------------------------+
struct SRmaBar
  {
   datetime          time;             // open time of the closed bar
   double            f_w;              // fractile of the last normalised return
   double            f_w_prev;         // the same, one bar back
   double            rma_w;
   double            rma_min;
   double            rma_max;
   double            d_med_w;          // f_w - 0.5
   double            d_med_w_prev;
   double            d_k;              // share of recent d_med_w steps that rose
   ENUM_RMA_REGIME   regime;

   double            Diff(void) const { return f_w-f_w_prev; }
  };

//+------------------------------------------------------------------+
//| What the strategy wants done about it.                           |
//+------------------------------------------------------------------+
enum ENUM_RMA_ACTION
  {
   RMA_ACT_NONE,                       // stand still
   RMA_ACT_BUY,                        // open long
   RMA_ACT_SELL,                       // open short
   RMA_ACT_CLOSE,                      // close and stay flat
   RMA_ACT_CLOSE_REVERSE               // close, then ask for a reversal
  };

//+------------------------------------------------------------------+
//| One instruction, with the sentence that justifies it.            |
//+------------------------------------------------------------------+
struct SRmaOrder
  {
   ENUM_RMA_ACTION   action;
   ENUM_RMA_CROSS_STATE state;         // leg to adopt if the action opens
   string            reason;           // journal line and arrow tooltip
  };

//+------------------------------------------------------------------+
//| CSignalEngine - the rules, and nothing that touches an order.    |
//|                                                                  |
//|  The strategy rides traversals of the window's own distribution. |
//|  The fractile f_w says where the newest normalised return sits   |
//|  in that distribution, and a move that leaves an extremum and    |
//|  walks across the bins toward the other one is what the paper    |
//|  calls a cross-reverse. Reaching the extremum arms the side;     |
//|  crossing bins away from it, still on that side of the median,   |
//|  is the entry - short the traversal that leaves the maximum,     |
//|  buy the one that leaves the minimum.                            |
//|                                                                  |
//|  What makes it more than a two-line rule is the bookkeeping      |
//|  that follows an entry. A position belongs to one of six legs    |
//|  (ENUM_RMA_CROSS_STATE), and the leg decides which exit test     |
//|  applies and what a reversal turns into - so the same f_w        |
//|  reading closes one position and holds another.                  |
//|                                                                  |
//|  Two things sit on top of that. The range regime swaps the exit  |
//|  test outright when the window is contracting. The adverse-      |
//|  movement block refuses re-entry on the side that just lost      |
//|  and - if the range is expanding - takes the opposite side       |
//|  instead, on the grounds that a mean-reversion signal that       |
//|  keeps failing is evidence of a trend, not a better price.       |
//|                                                                  |
//|  Nothing here calls OrderSend, reads a position, or prints. It   |
//|  is given a bar and returns an instruction, which is what makes  |
//|  the rules testable without a broker.                            |
//+------------------------------------------------------------------+
class CSignalEngine
  {
private:
//--- entry geometry
   double            m_entry_hi;       // f_w above this arms a downward traversal
   double            m_entry_lo;       // f_w below this arms an upward traversal
   bool              m_armed_max;      // a traversal may originate from the maximum
   bool              m_armed_min;      // a traversal may originate from the minimum
   double            m_entry_min_diff; // smallest f_w move that counts as a turn
   double            m_near_thresh;    // relative distance rma_w may sit from the extremum

//--- exit geometry
   double            m_target_hi;      // f_w that closes a long outright (0 = off)
   double            m_target_lo;      // f_w that closes a short outright (0 = off)
   double            m_min_pips;       // profit a strategy exit must already show

//--- adverse movement
   bool              m_use_adverse;
   double            m_adverse_down;   // D_k below this reads as a downtrend
   double            m_adverse_up;     // D_k above this reads as an uptrend

//--- carried state
   ENUM_RMA_CROSS_STATE m_state;
   int               m_bin_direction;  // signed run length of quantile-bin steps
   bool              m_block_long;
   bool              m_block_short;

   int               Bin(const double f_w) const;
   int               BinCrossing(const double curr,const double prev) const;
   int               MedianCrossing(const double curr,const double prev) const;
   bool              Near(const double a,const double b) const;
   bool              AtMax(const SRmaBar &b) const;
   bool              AtMin(const SRmaBar &b) const;

   bool              TrendFollowExit(const SRmaBar &b,const int type,SRmaOrder &o) const;
   bool              AdverseExit(const SRmaBar &b,const int type,SRmaOrder &o) const;
   bool              TargetExit(const SRmaBar &b,const int type,const double pips,SRmaOrder &o) const;
   bool              CrossoverExit(const SRmaBar &b,const int type,const double pips,SRmaOrder &o) const;
   bool              RevertExit(const SRmaBar &b,const int type,const double pips,SRmaOrder &o);

public:
                     CSignalEngine(void);

   bool              Init(const double entry_hi,const double entry_lo,
                          const double entry_min_diff,const double near_thresh,
                          const double target_hi,const double target_lo,
                          const double min_pips,
                          const bool use_adverse,const double adverse_down,
                          const double adverse_up);

//--- once per closed bar, before any decision is asked for.
   void              OnBar(const SRmaBar &b);

//--- the three questions, each answering into the same instruction.
   void              Entry(const SRmaBar &b,SRmaOrder &o);
   void              Exit(const SRmaBar &b,const int type,const double pips,SRmaOrder &o);
   void              Reversal(const SRmaBar &b,const ENUM_RMA_CROSS_STATE from,SRmaOrder &o);

   ENUM_RMA_CROSS_STATE State(void) const { return m_state; }
   void              SetState(const ENUM_RMA_CROSS_STATE s) { m_state=s; }

   bool              BlockLong(void)  const { return m_block_long;  }
   bool              BlockShort(void) const { return m_block_short; }
  };

//+------------------------------------------------------------------+
//| Construct flat, unblocked and with no leg.                       |
//+------------------------------------------------------------------+
CSignalEngine::CSignalEngine(void)
  {
   m_entry_hi       =0.9;
   m_entry_lo       =0.1;
   m_entry_min_diff =0.0;
   m_near_thresh    =0.1;
   m_target_hi      =0.0;
   m_target_lo      =0.0;
   m_min_pips       =0.0;
   m_use_adverse    =true;
   m_adverse_down   =0.3;
   m_adverse_up     =0.7;

   m_state          =RMA_STATE_NONE;
   m_bin_direction  =0;
   m_armed_max      =false;
   m_armed_min      =false;
   m_block_long     =false;
   m_block_short    =false;
  }

//+------------------------------------------------------------------+
//| Store the thresholds and start from a clean slate.               |
//+------------------------------------------------------------------+
bool CSignalEngine::Init(const double entry_hi,const double entry_lo,
                         const double entry_min_diff,const double near_thresh,
                         const double target_hi,const double target_lo,
                         const double min_pips,
                         const bool use_adverse,const double adverse_down,
                         const double adverse_up)
  {
   if(entry_hi<=entry_lo || entry_hi>1.0 || entry_lo<0.0)
     {
      PrintFormat("CSignalEngine: entry thresholds cross over, lo=%.3f hi=%.3f",
                  entry_lo,entry_hi);
      return false;
     }
   if(near_thresh<=0.0)
     {
      Print("CSignalEngine: the closeness threshold has to be positive");
      return false;
     }

   m_entry_hi       =entry_hi;
   m_entry_lo       =entry_lo;
   m_entry_min_diff =entry_min_diff;
   m_near_thresh    =near_thresh;
   m_target_hi      =target_hi;
   m_target_lo      =target_lo;
   m_min_pips       =min_pips;
   m_use_adverse    =use_adverse;
   m_adverse_down   =adverse_down;
   m_adverse_up     =adverse_up;

   m_state          =RMA_STATE_NONE;
   m_bin_direction  =0;
   m_armed_max      =false;
   m_armed_min      =false;
   m_block_long     =false;
   m_block_short    =false;
   return true;
  }

//+------------------------------------------------------------------+
//| Which tenth of the distribution f_w falls in.                    |
//+------------------------------------------------------------------+
int CSignalEngine::Bin(const double f_w) const
  {
   if(f_w<=0.0)
      return 0;
   if(f_w>=1.0)
      return 10;
   return (int)(f_w*10.0);
  }

//+------------------------------------------------------------------+
//| Did this bar move f_w into a different tenth, and which way?     |
//+------------------------------------------------------------------+
int CSignalEngine::BinCrossing(const double curr,const double prev) const
  {
   int a=Bin(curr);
   int b=Bin(prev);
   if(a>b)
      return 1;
   if(a<b)
      return -1;
   return 0;
  }

//+------------------------------------------------------------------+
//| Did this bar carry f_w across the median?                        |
//|  The paper detects the crossing of the median itself and puts    |
//|  no dead band around it, so neither does this: the test is a     |
//|  sign change in f_w-0.5 and nothing more. It is the same test    |
//|  OnBar uses to lift an adverse block, written on f_w rather      |
//|  than on the d_med_w the engine publishes.                       |
//+------------------------------------------------------------------+
int CSignalEngine::MedianCrossing(const double curr,const double prev) const
  {
   if(prev<=0.5 && curr>0.5)
      return 1;
   if(prev>=0.5 && curr<0.5)
      return -1;
   return 0;
  }

//+------------------------------------------------------------------+
//| Are two rma readings the same number to within the threshold?    |
//|  Relative, not absolute: rma values are ratios a few thousandths |
//|  wide, and a fixed distance that suits one instrument would be   |
//|  either everything or nothing on the next.                       |
//+------------------------------------------------------------------+
bool CSignalEngine::Near(const double a,const double b) const
  {
   double scale=MathMax(MathAbs(a),MathAbs(b));
   if(scale<1e-10)
      return true;
   return (MathAbs(a-b)/scale<m_near_thresh);
  }

//+------------------------------------------------------------------+
//| Is the window stretched to the top of its recent range?          |
//+------------------------------------------------------------------+
bool CSignalEngine::AtMax(const SRmaBar &b) const
  {
   return (b.f_w>m_entry_hi && Near(b.rma_w,b.rma_max));
  }

//+------------------------------------------------------------------+
//| Is the window stretched to the bottom of its recent range?       |
//+------------------------------------------------------------------+
bool CSignalEngine::AtMin(const SRmaBar &b) const
  {
   return (b.f_w<m_entry_lo && Near(b.rma_w,b.rma_min));
  }

//+------------------------------------------------------------------+
//| Bar bookkeeping that has to happen before any decision.          |
//|  A side is blocked until the fractile crosses back over the      |
//|  median, which is the cheapest available statement of "the move  |
//|  that beat us is over". Reading the crossing off two adjacent    |
//|  bars of the indicator - rather than off the last two bars the   |
//|  EA happened to look at - is what makes it survive a session     |
//|  filter, a restart, or a weekend.                                |
//|                                                                  |
//|  The two latches are the paper's origination test. A traversal   |
//|  only counts if it started at an extremum, so reaching one arms  |
//|  that side and disarms the other, and the arming is remembered   |
//|  until either the opposite extremum claims it or an entry        |
//|  consumes it. This is what keeps a bin crossing halfway down     |
//|  the distribution from being read as the start of a move.        |
//+------------------------------------------------------------------+
void CSignalEngine::OnBar(const SRmaBar &b)
  {
   if(m_block_long && b.d_med_w_prev<=0.0 && b.d_med_w>0.0)
      m_block_long=false;
   if(m_block_short && b.d_med_w_prev>=0.0 && b.d_med_w<0.0)
      m_block_short=false;

//--- Init refuses thresholds that cross over, so at most one of
//--- these can be true on any bar.
   if(AtMax(b))
     {
      m_armed_max=true;
      m_armed_min=false;
     }
   if(AtMin(b))
     {
      m_armed_min=true;
      m_armed_max=false;
     }
  }

//+------------------------------------------------------------------+
//| Should a flat account open something on this bar? (SS9.7.1.1)    |
//|                                                                  |
//|  A cross-reverse rides a traversal away from the extremum it     |
//|  began at: armed at the maximum, sold as f_w steps down; armed   |
//|  at the minimum, bought as it steps up. The median is not a      |
//|  precondition - the paper arms the move both above it and on the |
//|  way down to the far extremum - so only the latch and the        |
//|  crossing direction gate the entry. A cross-revert is the        |
//|  opposite: a traversal that turns back toward its origin before  |
//|  reaching the far end (Algorithm 3).                             |
//+------------------------------------------------------------------+
void CSignalEngine::Entry(const SRmaBar &b,SRmaOrder &o)
  {
   o.action=RMA_ACT_NONE;
   o.state =RMA_STATE_NONE;
   o.reason="";

   double diff=b.Diff();
   if(m_entry_min_diff>0.0 && MathAbs(diff)<m_entry_min_diff)
      return;

   int crossing=BinCrossing(b.f_w,b.f_w_prev);
   bool want_short=(m_armed_max && crossing<0);
   bool want_long =(m_armed_min && crossing>0);

//--- revert: armed, but crossing back past the median toward the origin.
   bool want_revert_long =(m_armed_max && crossing>0 && b.d_med_w<0.0);
   bool want_revert_short=(m_armed_min && crossing<0 && b.d_med_w>0.0);

   if(!want_short && !want_long && !want_revert_long && !want_revert_short)
      return;

   if(want_short && m_block_short && b.d_med_w>0.0)
     {
      //--- the refusal is itself a reading. A short that keeps being
      //--- wrong at the top of an expanding range is a trend, so the
      //--- blocked side is traded the other way round instead.
      if(b.regime!=RMA_REGIME_EXPANSION)
        {
         o.reason=StringFormat("short held back: adverse block, regime %s",
                               RmaRegimeName(b.regime));
         return;
        }
      m_armed_max=false;
      o.action=RMA_ACT_BUY;
      o.state =RMA_STATE_TREND_FOLLOW_LONG;
      o.reason=StringFormat("trend-follow long, short blocked, d_med_w=%.3f",b.d_med_w);
      return;
     }

   if(want_long && m_block_long && b.d_med_w<0.0)
     {
      if(b.regime!=RMA_REGIME_EXPANSION)
        {
         o.reason=StringFormat("long held back: adverse block, regime %s",
                               RmaRegimeName(b.regime));
         return;
        }
      m_armed_min=false;
      o.action=RMA_ACT_SELL;
      o.state =RMA_STATE_TREND_FOLLOW_SHORT;
      o.reason=StringFormat("trend-follow short, long blocked, d_med_w=%.3f",b.d_med_w);
      return;
     }

   if(want_short)
     {
      m_armed_max=false;
      o.action=RMA_ACT_SELL;
      o.state =RMA_STATE_LONG_CROSS_REVERSE;
      o.reason=StringFormat("long-cross-reverse: bin down to %d, f_w=%.3f %s median",
                            Bin(b.f_w),b.f_w,(b.d_med_w>0.0?"above":"below"));
      return;
     }

   if(want_long)
     {
      m_armed_min=false;
      o.action=RMA_ACT_BUY;
      o.state =RMA_STATE_SHORT_CROSS_REVERSE;
      o.reason=StringFormat("short-cross-reverse: bin up to %d, f_w=%.3f %s median",
                            Bin(b.f_w),b.f_w,(b.d_med_w<0.0?"below":"above"));
      return;
     }

//--- Algorithm 3: the revert legs, entered toward the origin extremum.
   if(want_revert_long)
     {
      m_armed_max=false;
      o.action=RMA_ACT_BUY;
      o.state =RMA_STATE_LONG_CROSS_REVERT;
      o.reason=StringFormat("long-cross-revert: reverted up toward max, bin %d, f_w=%.3f",
                            Bin(b.f_w),b.f_w);
      return;
     }

   m_armed_min=false;
   o.action=RMA_ACT_SELL;
   o.state =RMA_STATE_SHORT_CROSS_REVERT;
   o.reason=StringFormat("short-cross-revert: reverted down toward min, bin %d, f_w=%.3f",
                         Bin(b.f_w),b.f_w);
  }

//+------------------------------------------------------------------+
//| Has a trend-following position outlived its reason?              |
//|  It was opened because the fractile was on one side of the       |
//|  median and staying there. The moment it is not, the premise is  |
//|  gone, and there is no second test worth waiting for.            |
//+------------------------------------------------------------------+
bool CSignalEngine::TrendFollowExit(const SRmaBar &b,const int type,SRmaOrder &o) const
  {
   if(m_state==RMA_STATE_TREND_FOLLOW_LONG && type==0 && b.d_med_w<=0.0)
     {
      o.reason=StringFormat("trend-follow long done, d_med_w=%.3f",b.d_med_w);
      return true;
     }
   if(m_state==RMA_STATE_TREND_FOLLOW_SHORT && type==1 && b.d_med_w>=0.0)
     {
      o.reason=StringFormat("trend-follow short done, d_med_w=%.3f",b.d_med_w);
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Is the market walking away from a mean-reversion position?       |
//|  Being offside is not the test - a mean-reversion trade is       |
//|  offside by construction for a while. The test is being offside  |
//|  while the fractile keeps stepping further offside, which is     |
//|  what a low D_k on the wrong side of the median says.            |
//+------------------------------------------------------------------+
bool CSignalEngine::AdverseExit(const SRmaBar &b,const int type,SRmaOrder &o) const
  {
   if(!m_use_adverse)
      return false;

   if(type==0 && b.d_med_w<0.0 && b.d_k<m_adverse_down)
     {
      o.reason=StringFormat("adverse: long below median, D_k=%.2f",b.d_k);
      return true;
     }
   if(type==1 && b.d_med_w>0.0 && b.d_k>m_adverse_up)
     {
      o.reason=StringFormat("adverse: short above median, D_k=%.2f",b.d_k);
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Has the position reached the fractile it was aimed at?           |
//|  Off by default. It exists for the case where the operator wants |
//|  a fixed destination rather than the extremum logic below.       |
//+------------------------------------------------------------------+
bool CSignalEngine::TargetExit(const SRmaBar &b,const int type,const double pips,
                               SRmaOrder &o) const
  {
   if(m_min_pips>0.0 && pips<m_min_pips)
      return false;

   if(type==1 && m_target_lo>0.0 && b.f_w<=m_target_lo)
     {
      o.reason=StringFormat("target reached, short at f_w=%.3f",b.f_w);
      return true;
     }
   if(type==0 && m_target_hi>0.0 && b.f_w>=m_target_hi)
     {
      o.reason=StringFormat("target reached, long at f_w=%.3f",b.f_w);
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Contraction exit: hold for the whole width of the distribution.  |
//|                                                                  |
//|  A contracting range is one where the extremes are closing in on |
//|  each other, so a move from one end to the other is short in     |
//|  price and there is little point taking half of it. The position |
//|  is therefore held until the opposite extremum is reached and    |
//|  turning - which is also, conveniently, a fresh entry the other  |
//|  way, so this exit is the one that reverses.                     |
//+------------------------------------------------------------------+
bool CSignalEngine::CrossoverExit(const SRmaBar &b,const int type,const double pips,
                                  SRmaOrder &o) const
  {
   if(m_min_pips>0.0 && pips<m_min_pips)
      return false;

   double diff=b.Diff();

   if(m_state==RMA_STATE_LONG_CROSS_REVERSE && type==1 && AtMin(b) && diff>0.0)
     {
      o.reason="full-width crossover: short carried to the minimum";
      return true;
     }
   if(m_state==RMA_STATE_SHORT_CROSS_REVERSE && type==0 && AtMax(b) && diff<0.0)
     {
      o.reason="full-width crossover: long carried to the maximum";
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Expansion exit: leave when the fractile turns back.              |
//|                                                                  |
//|  Outside a contraction there is no reason to expect the far      |
//|  extremum to be reached, so the position is closed on evidence   |
//|  that the move it was riding has stopped: a run of quantile-bin  |
//|  steps the wrong way, a crossing of the median zone, or a single |
//|  step large enough to speak for itself.                          |
//|                                                                  |
//|  m_bin_direction is a signed run length, and it is advanced here |
//|  rather than in OnBar for a reason that is not tidiness: it must |
//|  only ever advance while a position is open, in an expanding     |
//|  range, on bars where no earlier exit fired. Advancing it        |
//|  anywhere else would change every exit this rule produces, so    |
//|  the placement is load-bearing rather than incidental.           |
//+------------------------------------------------------------------+
bool CSignalEngine::RevertExit(const SRmaBar &b,const int type,const double pips,
                               SRmaOrder &o)
  {
   int crossing=BinCrossing(b.f_w,b.f_w_prev);
   if(crossing!=0)
     {
      bool same_way=((crossing>0 && m_bin_direction>=0) ||
                     (crossing<0 && m_bin_direction<=0));
      m_bin_direction=same_way?(m_bin_direction+crossing):crossing;
     }

   if(m_min_pips>0.0 && pips<m_min_pips)
      return false;

   int median=MedianCrossing(b.f_w,b.f_w_prev);
   int bin=Bin(b.f_w);

   if(m_state==RMA_STATE_LONG_CROSS_REVERSE && type==1)
     {
      if(bin<5 && crossing>0 && m_bin_direction>=2)
        {
         o.reason="revert: short, two bins back up";
         return true;
        }
      if(median==1)
        {
         o.reason="revert: short, median zone crossed upward";
         return true;
        }
      if(b.f_w<0.5 && crossing>0 && bin>=3)
        {
         o.reason="revert: short, upward step out of the low bins";
         return true;
        }
      return false;
     }

   if(m_state==RMA_STATE_SHORT_CROSS_REVERSE && type==0)
     {
      if(bin>5 && crossing<0 && m_bin_direction<=-2)
        {
         o.reason="revert: long, two bins back down";
         return true;
        }
      if(median==-1)
        {
         o.reason="revert: long, median zone crossed downward";
         return true;
        }
      if(b.f_w>0.5 && crossing<0 && bin<=7)
        {
         o.reason="revert: long, downward step out of the high bins";
         return true;
        }
      return false;
     }

   if(m_state==RMA_STATE_LONG_CROSS_REVERT && type==0)
     {
      if(bin>=9)
        {
         o.reason="revert: long reached the top bin";
         return true;
        }
      if(bin>5 && crossing<0 && m_bin_direction<=-2)
        {
         o.reason="revert: long turning back down";
         return true;
        }
      return false;
     }

   if(m_state==RMA_STATE_SHORT_CROSS_REVERT && type==1)
     {
      if(bin<=1)
        {
         o.reason="revert: short reached the bottom bin";
         return true;
        }
      if(bin<5 && crossing>0 && m_bin_direction>=2)
        {
         o.reason="revert: short turning back up";
         return true;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//| Should the open position be closed on this bar?                  |
//|                                                                  |
//|  The tests run in order of how little they care about profit.    |
//|  Trend-follow and adverse exits are about the premise having     |
//|  failed, so they ignore the minimum-profit setting entirely; the |
//|  three below them are ordinary strategy exits and respect it.    |
//|  Only the last two reverse, because only they close at a point   |
//|  that is also an entry the other way. The contraction crossover  |
//|  (SS9.7.1.3) is for the reverse legs only; the revert legs use   |
//|  RevertExit in every regime.                                     |
//+------------------------------------------------------------------+
void CSignalEngine::Exit(const SRmaBar &b,const int type,const double pips,SRmaOrder &o)
  {
   o.action=RMA_ACT_NONE;
   o.state =m_state;
   o.reason="";

   if(TrendFollowExit(b,type,o))
     {
      o.action=RMA_ACT_CLOSE;
      return;
     }

   if(AdverseExit(b,type,o))
     {
      o.action=RMA_ACT_CLOSE;

      //--- a losing adverse exit blocks the side that lost. Winning
      //--- ones do not: the rule is there to stop the strategy from
      //--- feeding a trend the same trade repeatedly, and a trade
      //--- that made money is not evidence of that.
      if(pips<0.0 && type==0)
         m_block_long=true;
      if(pips<0.0 && type==1)
         m_block_short=true;
      return;
     }

   if(TargetExit(b,type,pips,o))
     {
      o.action=RMA_ACT_CLOSE;
      return;
     }

   bool reverse_leg=(m_state==RMA_STATE_LONG_CROSS_REVERSE ||
                     m_state==RMA_STATE_SHORT_CROSS_REVERSE);
   if(reverse_leg && b.regime==RMA_REGIME_CONTRACTION)
     {
      if(CrossoverExit(b,type,pips,o))
         o.action=RMA_ACT_CLOSE_REVERSE;
      return;
     }

   if(RevertExit(b,type,pips,o))
      o.action=RMA_ACT_CLOSE_REVERSE;
  }

//+------------------------------------------------------------------+
//| Having just closed, is this bar also an entry the other way?     |
//|                                                                  |
//|  Which reversal is on offer depends on the leg being left. A     |
//|  short taken at the top can become either a long riding back up  |
//|  (the revert leg) or a fresh long at the bottom, and those are   |
//|  different trades with different exits, so they get different    |
//|  states. Legs that have no natural continuation return nothing   |
//|  and the account simply stays flat.                              |
//|                                                                  |
//|  The leg being left is passed in rather than read off m_state,   |
//|  because by the time this is asked the position is already gone  |
//|  and the caller has been told to forget it. Taking it as an      |
//|  argument is what lets closing and reversing be two separate     |
//|  steps without one of them depending on the other's timing.      |
//+------------------------------------------------------------------+
void CSignalEngine::Reversal(const SRmaBar &b,const ENUM_RMA_CROSS_STATE from,SRmaOrder &o)
  {
   o.action=RMA_ACT_NONE;
   o.state =RMA_STATE_NONE;
   o.reason="";

   double diff=b.Diff();

   if(from==RMA_STATE_LONG_CROSS_REVERSE)
     {
      if(diff>0.0)
        {
         o.action=RMA_ACT_BUY;
         o.state =RMA_STATE_LONG_CROSS_REVERT;
         o.reason=StringFormat("reversal to long-cross-revert, f_w=%.3f",b.f_w);
         return;
        }
      if(AtMin(b))
        {
         o.action=RMA_ACT_BUY;
         o.state =RMA_STATE_SHORT_CROSS_REVERSE;
         o.reason=StringFormat("reversal to short-cross-reverse, f_w=%.3f",b.f_w);
        }
      return;
     }

   if(from==RMA_STATE_SHORT_CROSS_REVERSE)
     {
      if(diff<0.0)
        {
         o.action=RMA_ACT_SELL;
         o.state =RMA_STATE_SHORT_CROSS_REVERT;
         o.reason=StringFormat("reversal to short-cross-revert, f_w=%.3f",b.f_w);
         return;
        }
      if(AtMax(b))
        {
         o.action=RMA_ACT_SELL;
         o.state =RMA_STATE_LONG_CROSS_REVERSE;
         o.reason=StringFormat("reversal to long-cross-reverse, f_w=%.3f",b.f_w);
        }
      return;
     }

   if(from==RMA_STATE_LONG_CROSS_REVERT && diff<0.0 && b.f_w>0.5)
     {
      o.action=RMA_ACT_SELL;
      o.state =RMA_STATE_SHORT_CROSS_REVERT;
      o.reason=StringFormat("reversal to short-cross-revert, f_w=%.3f",b.f_w);
      return;
     }

   if(from==RMA_STATE_SHORT_CROSS_REVERT && diff>0.0 && b.f_w<0.5)
     {
      o.action=RMA_ACT_BUY;
      o.state =RMA_STATE_LONG_CROSS_REVERT;
      o.reason=StringFormat("reversal to long-cross-revert, f_w=%.3f",b.f_w);
     }
  }
//+------------------------------------------------------------------+
