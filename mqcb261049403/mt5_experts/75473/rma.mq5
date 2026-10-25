//+------------------------------------------------------------------+
//|                                                          RMA.mq5 |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23693 |
//+------------------------------------------------------------------+
#property copyright   "MMQ — Muhammad Minhas Qamar"
#property link        "https://www.mql5.com/en/articles/23693"
#property description "Trades the Relative Moving Average fractile against its own window."
#property version     "1.00"
#property strict

#include <RMA\RmaTypes.mqh>
#include <RMA\SignalEngine.mqh>
#include <RMA\TradeManager.mqh>
#include <RMA\RmaDisplay.mqh>

//+------------------------------------------------------------------+
//| The Expert, which is almost entirely plumbing.                   |
//|                                                                  |
//|  There is one calculation and it lives in the indicator.         |
//|  RMA_Engine recomputes closed bars through prev_calculated, draws|
//|  what it produces, and publishes the rest in buffers. This file  |
//|  opens a handle on it, reads two bars' worth of state at each    |
//|  close, and hands that to three objects: CSignalEngine decides,  |
//|  then CTradeManager acts, then CRmaDisplay draws. What is left   |
//|  over - which is what you are reading - is the order they run in.|
//|                                                                  |
//|  The split matters beyond tidiness. Because the EA does not own  |
//|  the mathematics, it cannot disagree with the chart about what   |
//|  f_w was on a given bar; and because the rules never touch an    |
//|  order, they can be replayed over history by a script with no    |
//|  broker involved.                                                |
//+------------------------------------------------------------------+

input group "=== Window ==="
input int      InpWindowSize        = 106;      // Window size (W)
input int      InpSmoothingPeriod   = 10;       // Smoothing period for the alpha means

input group "=== Regime detection ==="
input double   InpEpsilonLow        = 0.15;     // Epsilon low (contraction threshold)
input double   InpEpsilonHigh       = 3.0;      // Epsilon high (expansion threshold)
input double   InpSlopeThreshold    = 0.0001;   // Slope threshold for regime transition
input int      InpRegimeLookback    = 20;       // Lookback for slope and variation ratio
input double   InpVariationRatioLow = 0.1;      // Variation ratio below this reads as steady
input double   InpZScoreExpansion   = 1.0;      // Z-score above this reads as expansion
input int      InpRangeHistoryLookback = 100;   // Range min/max envelope (0 = unlimited)

input group "=== Adverse movement ==="
input bool     InpUseAdverseExit    = true;     // Leave positions the trend is walking away from
input int      InpAdverseLookback   = 10;       // Lookback bars for D_k
input double   InpAdverseThresholdDown = 0.3;   // D_k below this = trending down
input double   InpAdverseThresholdUp   = 0.7;   // D_k above this = trending up

input group "=== Entries ==="
input double   InpEntryUpperThreshold = 0.9;    // Upper f_w threshold for a short
input double   InpEntryLowerThreshold = 0.1;    // Lower f_w threshold for a long
input double   InpEntryMinDiff        = 0.0;    // Smallest f_w turn that counts (0 = any)
input double   InpCloseThreshold      = 0.1;    // How near rma_w must sit to the extremum

input group "=== Exits ==="
input double   InpExitTargetUpper    = 0.0;     // f_w that closes a long (0 = extremum logic)
input double   InpExitTargetLower    = 0.0;     // f_w that closes a short (0 = extremum logic)
input double   InpExitProfitMinPips  = 0.0;     // Profit a strategy exit must show (0 = off)

input group "=== Trading ==="
input double   InpLotSize           = 0.01;     // Position size (lots)
input int      InpMagicNumber       = 20251230; // Magic number
input string   InpTradeComment      = "RMA";    // Trade comment

input group "=== Risk ==="
input double   InpStopLossPips      = 0;        // Stop loss (pips, 0 = none)
input double   InpTakeProfitPips    = 0;        // Take profit (pips, 0 = none)
input bool     InpUseTimeFilter     = false;    // Restrict trading to a session
input int      InpStartHour         = 8;        // Session start hour
input int      InpEndHour           = 20;       // Session end hour
input bool     InpEODClosePositions = false;    // Flatten at the session end hour

input group "=== On the chart (off by default: the EA trades silently) ==="
input bool     InpShowDisplay       = false;    // Draw the status block and trade markers
input bool     InpAttachEngine      = false;    // Put RMA_Engine on the chart as well
input bool     InpShowPanels        = false;    // Let the engine open its side panels
input bool     InpPanelAdverse      = true;     // Panel: D_k and d_med_w (if panels shown)
input bool     InpPanelRmaValues    = false;    // Panel: rma_w / rma_min / rma_max (if panels shown)
input bool     InpShowRegimeBand    = true;     // Shade the indicator window by regime (if engine shown)
input bool     InpVerbose           = false;    // Journal every refusal, not just the trades

CSignalEngine  g_signals;
CTradeManager  g_trades;
CRmaDisplay    g_display;

int            g_engine=INVALID_HANDLE;
datetime       g_last_bar=0;
int            g_drawn=0;             // trades the display has already marked
bool           g_engine_shown=false;
bool           g_engine_added=false;  // true only if this EA put it on the chart
string         g_note="";             // last thing declined, and why

//+------------------------------------------------------------------+
//| Journal a refusal, if the operator asked to hear about them.     |
//|  It is always kept for the status block, whose whole purpose is  |
//|  to show it - the input only governs the journal, where a line   |
//|  per bar would bury the trades.                                  |
//+------------------------------------------------------------------+
void Note(const string text)
  {
   if(text=="")
      return;
   g_note=text;
   if(InpVerbose)
      Print("[RMA] ",text);
  }

//+------------------------------------------------------------------+
//| Is this reading absent rather than merely small?                 |
//+------------------------------------------------------------------+
bool Missing(const double v)
  {
   return (v==EMPTY_VALUE || !MathIsValidNumber(v));
  }

//+------------------------------------------------------------------+
//| Read one engine buffer, newest closed bar first.                 |
//|  Position one, not zero: bar zero is still forming, and every    |
//|  rule below is written about a bar whose close is final.         |
//+------------------------------------------------------------------+
bool Pull(const int buffer,const int count,double &out[])
  {
   ArraySetAsSeries(out,true);
   return (CopyBuffer(g_engine,buffer,1,count,out)==count);
  }

//+------------------------------------------------------------------+
//| Assemble one bar of engine state, or say why it cannot be had.   |
//|  Everything the strategy reads goes through here, so a warmup    |
//|  bar, a gap in the history, or an engine that has not calculated |
//|  yet all produce the same answer: not this bar.                  |
//+------------------------------------------------------------------+
bool ReadBar(SRmaBar &b)
  {
   double fw[],dmed[],one[];

   if(!Pull(RMA_BUF_FW,2,fw) || !Pull(RMA_BUF_D_MED_W,2,dmed))
      return false;

   b.time         =iTime(_Symbol,_Period,1);
   b.f_w          =fw[0];
   b.f_w_prev     =fw[1];
   b.d_med_w      =dmed[0];
   b.d_med_w_prev =dmed[1];

   if(!Pull(RMA_BUF_RMA_W,1,one))
      return false;
   b.rma_w=one[0];
   if(!Pull(RMA_BUF_RMA_MIN,1,one))
      return false;
   b.rma_min=one[0];
   if(!Pull(RMA_BUF_RMA_MAX,1,one))
      return false;
   b.rma_max=one[0];
   if(!Pull(RMA_BUF_D_K,1,one))
      return false;
   b.d_k=one[0];

   if(!Pull(RMA_BUF_REGIME,1,one))
      return false;
   if(Missing(one[0]))
      return false;
   b.regime=(ENUM_RMA_REGIME)(int)one[0];

   if(Missing(b.f_w) || Missing(b.f_w_prev) || Missing(b.d_med_w) ||
      Missing(b.d_med_w_prev) || Missing(b.d_k) || Missing(b.rma_w) ||
      Missing(b.rma_min) || Missing(b.rma_max))
      return false;

   return true;
  }

//+------------------------------------------------------------------+
//| Show the engine, so the EA arrives with its own chart.           |
//|  Only if it is not already there: the operator may well have     |
//|  added it by hand, and a second copy would recompute everything  |
//|  to draw the same lines twice.                                   |
//+------------------------------------------------------------------+
void ShowEngine(void)
  {
   if(!InpAttachEngine)
      return;
   if(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE))
      return;

   long chart=ChartID();
   int  windows=(int)ChartGetInteger(chart,CHART_WINDOWS_TOTAL);
   for(int w=0;w<windows;w++)
     {
      int total=ChartIndicatorsTotal(chart,w);
      for(int k=0;k<total;k++)
        {
         if(StringFind(ChartIndicatorName(chart,w,k),"RMA Engine")==0)
            return;
        }
     }

   if(!ChartIndicatorAdd(chart,windows,g_engine))
     {
      PrintFormat("[RMA] could not show the engine: error %d",GetLastError());
      return;
     }
   g_engine_added=true;
  }

//+------------------------------------------------------------------+
//| Everything that follows a trade ending, whichever way it ended.  |
//|  Four routes lead here - a strategy close, a retried close, a    |
//|  stop, an end-of-day flatten - and the leg has to be dropped and |
//|  the exit drawn on all four. Noticing by way of the trade count  |
//|  rather than by return value is what keeps that true when a new  |
//|  route is added.                                                 |
//+------------------------------------------------------------------+
void AfterClose(void)
  {
   if(g_trades.Trades()==g_drawn)
      return;

   g_drawn=g_trades.Trades();
   g_signals.SetState(RMA_STATE_NONE);
   g_display.MarkExit(TimeCurrent(),g_trades.LastPrice(),
                      g_trades.LastPips(),g_trades.LastReason());
  }

//+------------------------------------------------------------------+
//| Carry out an instruction that opens something.                   |
//+------------------------------------------------------------------+
bool Take(const SRmaOrder &o)
  {
   ENUM_ORDER_TYPE type=(o.action==RMA_ACT_BUY)?ORDER_TYPE_BUY:ORDER_TYPE_SELL;
   if(!g_trades.Open(type,o.reason))
      return false;

   g_signals.SetState(o.state);
   g_trades.SaveState(o.state);
   g_display.MarkEntry(g_trades.EntryTime(),g_trades.EntryPrice(),
                       (o.action==RMA_ACT_BUY),o.reason);
   g_drawn=g_trades.Trades();
   return true;
  }

//+------------------------------------------------------------------+
//| A flat account, on a closed bar.                                 |
//+------------------------------------------------------------------+
void HandleFlat(const SRmaBar &b)
  {
   SRmaOrder o;
   g_signals.Entry(b,o);

   if(o.action==RMA_ACT_NONE)
     {
      Note(o.reason);
      return;
     }
   Take(o);
  }

//+------------------------------------------------------------------+
//| An open position, on a closed bar.                               |
//|  The leg is taken before the close, because the reversal is a    |
//|  question about the trade that just ended and the close is what  |
//|  ends it.                                                        |
//+------------------------------------------------------------------+
void HandleOpen(const SRmaBar &b)
  {
   SRmaOrder o;
   g_signals.Exit(b,g_trades.Type(),g_trades.ProfitPips(),o);
   if(o.action==RMA_ACT_NONE)
      return;

   ENUM_RMA_CROSS_STATE leg=g_signals.State();
   bool reverse=(o.action==RMA_ACT_CLOSE_REVERSE);

   g_trades.Close(o.reason);
   AfterClose();

   if(!reverse)
      return;

//--- a close the broker would not take leaves the position running,
//--- and a reversal on top of it would be a second position rather
//--- than the opposite one. The retry will finish the job.
   if(g_trades.IsOpen())
      return;

   SRmaOrder rev;
   g_signals.Reversal(b,leg,rev);
   if(rev.action==RMA_ACT_NONE)
     {
      Note(rev.reason);
      return;
     }
   Take(rev);
  }

//+------------------------------------------------------------------+
//| Expert initialisation.                                           |
//|                                                                  |
//|  Every "" below stands for an `input group` in RMA_Engine. The   |
//|  documentation calls group a purely visual divider, but iCustom  |
//|  gives it a slot in the parameter list all the same, and a       |
//|  caller that skips it shifts every value after it by one         |
//|  position - silently, because the types still convert. The       |
//|  first version of this call omitted them and the engine came up  |
//|  with W=10 (the smoothing period) and smoothing=0 (the epsilon   |
//|  0.15 truncated to int).                                         |
//|                                                                  |
//|  So the list below is not the engine's inputs; it is the         |
//|  engine's inputs interleaved with its group dividers, in         |
//|  declaration order. Add a group there and one has to be added    |
//|  here too. The four colour inputs at the end are left off, which |
//|  is allowed - a short list defaults the remainder - but nothing  |
//|  in the middle may be.                                           |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   g_engine=iCustom(_Symbol,_Period,"RMA\\RMA_Engine",
                    "",                       // group: Window
                    InpWindowSize,InpSmoothingPeriod,
                    "",                       // group: Regime detection
                    InpEpsilonLow,InpEpsilonHigh,InpSlopeThreshold,
                    InpRegimeLookback,InpVariationRatioLow,InpZScoreExpansion,
                    InpRangeHistoryLookback,
                    "",                       // group: Adverse movement
                    InpAdverseLookback,
                    "",                       // group: Reference lines
                    InpEntryUpperThreshold,InpEntryLowerThreshold,
                    "",                       // group: Panels
                    InpShowPanels,InpPanelAdverse,InpPanelRmaValues,
                    InpAdverseThresholdDown,InpAdverseThresholdUp,
                    "",                       // group: Regime backdrop
                    InpShowRegimeBand);

   if(g_engine==INVALID_HANDLE)
     {
      Print("[RMA] RMA_Engine would not load - compile Indicators\\RMA\\RMA_Engine.mq5");
      return INIT_FAILED;
     }

   if(!g_signals.Init(InpEntryUpperThreshold,InpEntryLowerThreshold,
                      InpEntryMinDiff,InpCloseThreshold,
                      InpExitTargetUpper,InpExitTargetLower,InpExitProfitMinPips,
                      InpUseAdverseExit,InpAdverseThresholdDown,InpAdverseThresholdUp))
      return INIT_PARAMETERS_INCORRECT;

   if(!g_trades.Init(InpMagicNumber,InpLotSize,InpStopLossPips,InpTakeProfitPips,
                     InpTradeComment))
      return INIT_PARAMETERS_INCORRECT;
   g_trades.SetSession(InpUseTimeFilter,InpStartHour,InpEndHour,InpEODClosePositions);

   g_display.Init(InpShowDisplay,"RMA_"+IntegerToString(InpMagicNumber)+"_",
                  CORNER_LEFT_UPPER,12,20,8,"Consolas",clrSilver,clrWhite);

//--- a position may have outlived the last run. The terminal knows it
//--- exists; only the saved leg knows which trade it was.
   ENUM_RMA_CROSS_STATE leg=RMA_STATE_NONE;
   if(g_trades.RestoreState(leg))
      g_signals.SetState(leg);

   g_drawn=g_trades.Trades();
   g_last_bar=0;
   g_engine_shown=false;
   g_note="";
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert shutdown.                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   bool removed=(reason==REASON_REMOVE);

   g_display.Destroy(removed);

   if(removed && g_engine_added)
      ChartIndicatorDelete(ChartID(),
                           (int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL)-1,
                           StringFormat("RMA Engine (%d)",InpWindowSize));

   if(g_engine!=INVALID_HANDLE)
     {
      IndicatorRelease(g_engine);
      g_engine=INVALID_HANDLE;
     }

   Summary();
  }

//+------------------------------------------------------------------+
//| Expert tick.                                                     |
//|  Two clocks run here. A refused close is retried on every tick,  |
//|  because the thing being waited for is the market opening and    |
//|  that does not happen on a bar boundary. Everything else waits   |
//|  for a bar to close, because every number it reads is only       |
//|  final then.                                                     |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   g_trades.RetryPendingClose();
   AfterClose();

   datetime bar_time=iTime(_Symbol,_Period,0);
   if(bar_time==g_last_bar || bar_time==0)
      return;
   g_last_bar=bar_time;

   if(!g_engine_shown)
     {
      g_engine_shown=true;
      ShowEngine();
     }

   g_trades.Sync();
   AfterClose();

   if(g_trades.AtSessionEnd() && g_trades.IsOpen())
     {
      g_trades.Close("session end");
      AfterClose();
     }

   if(!g_trades.SessionAllows())
      return;

   SRmaBar bar;
   if(!ReadBar(bar))
      return;

   g_signals.OnBar(bar);

//--- whether the account was open is settled before anything acts on
//--- it, so that a close and an entry cannot both land on one bar.
   bool was_open=g_trades.IsOpen();
   if(was_open)
      HandleOpen(bar);
   if(!was_open)
      HandleFlat(bar);

   g_display.Update(bar,g_signals,g_trades,g_note);
  }

//+------------------------------------------------------------------+
//| Closing report.                                                  |
//+------------------------------------------------------------------+
void Summary(void)
  {
   Print("---------------- RMA ----------------");
   PrintFormat("trades          %d  (%d won, %d lost)",
               g_trades.Trades(),g_trades.Wins(),g_trades.Losses());
   if(g_trades.Trades()>0)
     {
      PrintFormat("win rate        %.1f%%",g_trades.WinRate());
      PrintFormat("gross           +%.1f / %.1f pips",
                  g_trades.GrossWin(),g_trades.GrossLoss());
      PrintFormat("net             %+.1f pips  (%.2f per trade)",
                  g_trades.NetPips(),g_trades.NetPips()/g_trades.Trades());
     }
   Print("-------------------------------------");
  }

//+------------------------------------------------------------------+
//| Optimisation criterion.                                          |
//+------------------------------------------------------------------+
double OnTester(void)
  {
   return g_trades.Score();
  }
//+------------------------------------------------------------------+
