//+------------------------------------------------------------------+
//|                                                    EdgeMeter.mq5 |
//|                                                                  |
//|  Does your entry signal actually beat the spread?                |
//|                                                                  |
//|  This script places NO orders. It reads history, evaluates your  |
//|  signal on every closed bar, and answers one question:           |
//|                                                                  |
//|      after transaction costs, does this signal make money?       |
//|                                                                  |
//|  WHY THIS EXISTS                                                 |
//|  ---------------                                                 |
//|  I spent a month building a grid EA on XAUUSD M1. I fixed the    |
//|  stop loss, the basket cap, the reversal exit, the maximum age.  |
//|  It kept losing. When I finally measured the ENTRY signal alone, |
//|  the answer took thirty seconds:                                 |
//|                                                                  |
//|      average move after signal, 15 min : +0.04 $                 |
//|      spread paid per round turn        :  0.26 $                 |
//|                                                                  |
//|  No exit logic can repair that. The money was lost at entry, and |
//|  every hour I spent on exits was wasted. Measure first.          |
//|                                                                  |
//|  WHAT IT REPORTS                                                 |
//|  ---------------                                                 |
//|  For each holding period:                                        |
//|    - gross edge (average favourable move after the signal)       |
//|    - net result after cost, one position at a time               |
//|    - t-statistic on NON-OVERLAPPING samples                      |
//|    - share of profitable months                                  |
//|  Plus a RANDOM CONTROL: same trade count, coin-flip direction.   |
//|  If your signal does not clearly beat the control, it IS the     |
//|  control.                                                        |
//|                                                                  |
//|  THE OVERLAP TRAP                                                |
//|  ----------------                                                |
//|  Consecutive signals share most of their forward window. Using   |
//|  all of them inflates the t-statistic by roughly sqrt(horizon).  |
//|  My own signal showed t = 3.32 that way. On independent samples  |
//|  it was t = 1.20 -- indistinguishable from noise. This script    |
//|  reports the honest number.                                      |
//|                                                                  |
//|  HOW TO USE IT                                                   |
//|  -------------                                                   |
//|  Edit UserInit() and UserSignal() in the USER SECTION below.     |
//|  Nothing else needs to change. The default is a two-timeframe    |
//|  moving-average signal, kept as a worked example.                |
//|                                                                  |
//|  Free to use and modify.                                         |
//+------------------------------------------------------------------+
#property copyright "Published to MQL5 CodeBase - free to use"
#property version   "1.04"
#property script_show_inputs
#property description "Measures whether an entry signal beats transaction costs. Places no orders."
#property description "Edit UserInit() and UserSignal() to test your own signal."

//==================================================================
//                            INPUTS
//==================================================================
input group "===== COST -- the number that decides everything ====="
input double InpSpread     = 0.26;    // Average spread, in PRICE units
input double InpCommission = 0.00;    // Round-turn commission, in PRICE units
input double InpSlippage   = 0.05;    // Prudent slippage allowance, in PRICE units

input group "===== DATA ====="
//  Both are explicit on purpose. With InpTF = PERIOD_CURRENT the base silently
//  follows whatever chart you drop the script on, and the pair stops being
//  coherent the moment you switch charts. Set them, don't inherit them.
input ENUM_TIMEFRAMES InpTF  = PERIOD_H1;       // Base timeframe
input ENUM_TIMEFRAMES InpTFb = PERIOD_H4;       // Higher timeframe -- must be ABOVE the base
input int    InpBars       = 100000;  // Bars of history to analyse

input group "===== HOLDING PERIODS (in base-TF bars) ====="
input int    InpH1         = 5;
input int    InpH2         = 15;
input int    InpH3         = 60;
input int    InpH4         = 240;

input group "===== DEFAULT SIGNAL (example -- replace with your own) ====="
input int    InpMAFast     = 20;      // Fast MA period
input int    InpMASlow     = 50;      // Slow MA period
input ENUM_MA_METHOD InpMAMethod = MODE_EMA;
input bool   InpNeedHigherTF = true;  // Require the higher timeframe to agree

//==================================================================
//                        DATA AVAILABLE TO YOU
//
//  All arrays are indexed 0 = OLDEST bar, Bars()-1 = most recent.
//  This is the opposite of the usual "series" indexing, and it is
//  deliberate: forward returns are then simply index + horizon.
//==================================================================
MqlRates Rate[];    int NBase=0;   // base timeframe
MqlRates RateB[];   int NHigh=0;   // higher timeframe
int      MapHigh[];                // base bar -> last CLOSED higher-TF bar

double Open (int i) { return Rate[i].open;  }
double High (int i) { return Rate[i].high;  }
double Low  (int i) { return Rate[i].low;   }
double Close(int i) { return Rate[i].close; }
datetime Time(int i){ return Rate[i].time;  }

// index of the last CLOSED higher-timeframe bar at the close of base bar i
int MapB(int i) { return (i>=0 && i<NBase) ? MapHigh[i] : -1; }

double OpenB (int j) { return (j>=0)?RateB[j].open :0; }
double CloseB(int j) { return (j>=0)?RateB[j].close:0; }

//------------------------------------------------------------------
// Load a whole indicator buffer, aligned with the BASE timeframe.
//------------------------------------------------------------------
bool LoadBuffer(int handle, double &dest[])
  {
   if(handle==INVALID_HANDLE) { Print("LoadBuffer: invalid handle"); return false; }
   for(int k=0;k<100 && BarsCalculated(handle)<NBase;k++) Sleep(100);
   ArraySetAsSeries(dest,false);
   if(CopyBuffer(handle,0,0,NBase,dest)<NBase)
     { Print("LoadBuffer: CopyBuffer failed, error ",GetLastError()); return false; }
   return true;
  }

//------------------------------------------------------------------
// Same, aligned with the HIGHER timeframe. Index with MapB(i).
//------------------------------------------------------------------
bool LoadBufferB(int handle, double &dest[])
  {
   if(handle==INVALID_HANDLE) { Print("LoadBufferB: invalid handle"); return false; }
   for(int k=0;k<100 && BarsCalculated(handle)<NHigh;k++) Sleep(100);
   ArraySetAsSeries(dest,false);
   if(CopyBuffer(handle,0,0,NHigh,dest)<NHigh)
     { Print("LoadBufferB: CopyBuffer failed, error ",GetLastError()); return false; }
   return true;
  }

//==================================================================
//                        USER SECTION
//
//  EDIT ONLY THE TWO FUNCTIONS BELOW.
//
//  UserInit()   : create indicator handles, load their buffers.
//                 Return false if anything fails.
//  UserSignal(i): evaluate bar i (a CLOSED bar).
//                 Return  +1 to buy, -1 to sell, 0 to stand aside.
//
//  Entry is simulated at Open(i+1), i.e. the next bar. Never read
//  bar i+1 or later inside UserSignal -- that is look-ahead bias
//  and it will make a worthless signal look brilliant.
//==================================================================
double MAFast[], MASlow[];       // base timeframe
double MAFastB[], MASlowB[];     // higher timeframe
int    UserWarmup = 0;           // bars to skip at the start

//------------------------------------------------------------------
bool UserInit()
  {
   UserWarmup = MathMax(InpMAFast,InpMASlow)+5;

   if(!LoadBuffer(iMA(_Symbol,InpTF,InpMAFast,0,InpMAMethod,PRICE_CLOSE), MAFast)) return false;
   if(!LoadBuffer(iMA(_Symbol,InpTF,InpMASlow,0,InpMAMethod,PRICE_CLOSE), MASlow)) return false;

   if(InpNeedHigherTF)
     {
      if(!LoadBufferB(iMA(_Symbol,InpTFb,InpMAFast,0,InpMAMethod,PRICE_CLOSE), MAFastB)) return false;
      if(!LoadBufferB(iMA(_Symbol,InpTFb,InpMASlow,0,InpMAMethod,PRICE_CLOSE), MASlowB)) return false;
     }
   return true;
  }

//------------------------------------------------------------------
int UserSignal(int i)
  {
   //--- base timeframe vote
   int v = 0;
   if(MAFast[i] > MASlow[i]) v =  1;
   if(MAFast[i] < MASlow[i]) v = -1;
   if(v == 0) return 0;

   //--- higher timeframe must agree
   if(InpNeedHigherTF)
     {
      int j = MapB(i);
      if(j < UserWarmup) return 0;
      int vb = 0;
      if(MAFastB[j] > MASlowB[j]) vb =  1;
      if(MAFastB[j] < MASlowB[j]) vb = -1;
      if(vb != v) return 0;
     }
   return v;
  }
//==================================================================
//                     END OF USER SECTION
//==================================================================

#define NH 4
int    HOR[NH];
double COST = 0.0;

//==================================================================
//  RANDOM NUMBERS -- xorshift32, not MathRand()
//
//  MathRand() is a linear congruential generator, and the LOW bits of
//  an LCG are notoriously weak: MathRand()%2 is close to periodic, not
//  random. Drawing the entry gate and the direction from consecutive
//  MathRand() calls then correlates "when we enter" with "which way",
//  and the control develops a bias of its own.
//
//  That is fatal here. A biased control is not a noise floor - it is a
//  second, invisible signal. In testing, MathRand() gave the control a
//  t of -2.57, which by this script's own criteria reads as
//  "statistically significant". A coin flip must never be significant.
//
//  xorshift32 has good bits throughout and is seeded explicitly, so
//  every run is reproducible.
//==================================================================
uint g_rng = 2463534242;

void RngSeed(uint s) { g_rng = (s==0) ? 2463534242 : s; }

uint RngNext()
  {
   uint x = g_rng;
   x ^= (x << 13);
   x ^= (x >> 17);
   x ^= (x << 5);
   g_rng = x;
   return x;
  }

double RngUniform() { return (double)RngNext() / 4294967296.0; }

//--- take the HIGH bit, never the low one
int RngSign() { return ((RngNext() & 0x80000000) != 0) ? 1 : -1; }

//==================================================================
//                          LOADING
//==================================================================
ENUM_TIMEFRAMES TFbase, TFhigh;

bool LoadData()
  {
   //--- PERIOD_CURRENT prints as "PERIOD_CURRENT"; resolve it so the header
   //    reports the timeframe actually used.
   TFbase = (InpTF ==PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)_Period : InpTF;
   TFhigh = (InpTFb==PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)_Period : InpTFb;

   //--- a "higher" timeframe shorter than the base is almost always a mistake
   if(PeriodSeconds(TFhigh) < PeriodSeconds(TFbase))
     {
      Print("");
      Print("WARNING: the higher timeframe (", EnumToString(TFhigh),
            ") is SHORTER than the base timeframe (", EnumToString(TFbase), ").");
      Print("         Confirmation from a faster timeframe is not confirmation.");
      Print("         Set InpTFb to a timeframe above InpTF, or disable InpNeedHigherTF.");
      Print("");
     }

   //--- equal timeframes: the filter compares the signal to itself and always
   //    agrees. It looks like a filter, it costs nothing, it does nothing.
   if(InpNeedHigherTF && PeriodSeconds(TFhigh) == PeriodSeconds(TFbase))
     {
      Print("");
      Print("WARNING: base and higher timeframe are BOTH ", EnumToString(TFbase), ".");
      Print("         The confirmation compares the signal to itself, so it always");
      Print("         agrees and filters nothing. Watch the signal firing rate below:");
      Print("         a filter that changes nothing is not a filter.");
      Print("");
     }

   ArraySetAsSeries(Rate,false);
   NBase = CopyRates(_Symbol, TFbase, 0, InpBars, Rate);
   if(NBase < 1000)
     {
      Print("Not enough history on the base timeframe (", NBase, " bars).");
      Print("Open a chart for ", _Symbol, " on that timeframe and scroll far left to download more.");
      return false;
     }

   ArraySetAsSeries(RateB,false);
   int secA = PeriodSeconds(TFbase);
   int secB = PeriodSeconds(TFhigh);
   int want = (secB>0) ? (int)(NBase*(double)secA/(double)secB)+500 : 500;
   NHigh = CopyRates(_Symbol, TFhigh, 0, want, RateB);
   if(NHigh < 100)
     {
      Print("Not enough history on the higher timeframe (", NHigh, " bars).");
      return false;
     }

   //--- THE SILENT SAMPLE KILLER
   //    If the higher timeframe starts later than the base timeframe, every
   //    base bar before that point has no confirmation available and produces
   //    no signal. The header would still advertise the full base history,
   //    and you would believe you tested years when you tested months.
   if(RateB[0].time > Rate[0].time)
     {
      Print("");
      Print("WARNING: higher-timeframe history is SHORTER than base history.");
      PrintFormat("         base   %s starts %s", EnumToString(TFbase),
                  TimeToString(Rate[0].time, TIME_DATE));
      PrintFormat("         higher %s starts %s", EnumToString(TFhigh),
                  TimeToString(RateB[0].time, TIME_DATE));
      Print("         Bars before that date cannot produce a signal. Your real");
      Print("         sample is the SIGNAL SPAN printed below, not the base history.");
      Print("         Open a chart on the higher timeframe and scroll left to fix this.");
      Print("");
     }

   //--- map every base bar to the last CLOSED higher-timeframe bar.
   //    Using the still-forming higher bar is look-ahead bias.
   ArrayResize(MapHigh, NBase);
   int p = 0;
   for(int i=0; i<NBase; i++)
     {
      datetime tclose = (datetime)(Rate[i].time + secA);
      while(p+1 < NHigh && (datetime)(RateB[p+1].time + secB) <= tclose) p++;
      MapHigh[i] = ((datetime)(RateB[p].time + secB) <= tclose) ? p : p-1;
     }
   return true;
  }

//==================================================================
//                         EVALUATION
//==================================================================
void Measure(int horizon, bool randomControl, int forcedCount)
  {
   int start = MathMax(UserWarmup, 10) + 2;
   int end   = NBase - horizon - 2;
   if(end <= start) { Print("Horizon ", horizon, " : not enough bars."); return; }

   //--- gross edge over every signal (overlapping windows)
   double gSum=0, gSum2=0;
   long   gN=0, gPos=0;

   //--- realistic simulation : one position at a time
   double nSum=0, nSum2=0;
   long   nN=0, nWin=0;
   double eq=0, peak=0, dd=0;
   int    freeAt=0;

   //--- monthly buckets
   string curMonth="";
   double monthAcc=0;
   int    monthsPos=0, monthsTot=0;

   //--- seeded per horizon so each row is reproducible but not identical
   if(randomControl) RngSeed((uint)(20260819 + horizon*7919));
   double fireProb = (randomControl && end>start)
                     ? (double)forcedCount/(double)(end-start) : 0.0;

   for(int i=start; i<=end; i++)
     {
      int dir;
      if(randomControl)
        {
         //--- fire at the same rate as the real signal, direction by coin flip
         if(fireProb <= 0.0) break;
         if(RngUniform() >= fireProb) continue;
         dir = RngSign();
        }
      else
        {
         dir = UserSignal(i);
         if(dir==0) continue;
        }

      double entry = Open(i+1);
      double ret   = (Close(i+horizon) - entry) * dir;

      gSum += ret; gSum2 += ret*ret; gN++;
      if(ret>0) gPos++;

      if(i >= freeAt)
        {
         double net = ret - COST;
         nSum += net; nSum2 += net*net; nN++;
         if(net>0) nWin++;
         eq += net;
         if(eq>peak) peak=eq;
         if(eq-peak<dd) dd=eq-peak;
         freeAt = i + horizon;

         string mm = StringSubstr(TimeToString(Time(i), TIME_DATE), 0, 7);
         if(mm != curMonth)
           {
            if(curMonth != "") { monthsTot++; if(monthAcc>0) monthsPos++; }
            curMonth = mm; monthAcc = 0;
           }
         monthAcc += net;
        }
     }
   if(curMonth != "") { monthsTot++; if(monthAcc>0) monthsPos++; }

   if(gN < 10 || nN < 5)
     { PrintFormat("%5d bars : only %d signals -- too few to conclude.", horizon, (int)gN); return; }

   double gMean = gSum/(double)gN;
   double gSd   = MathSqrt(MathMax(0.0, gSum2/(double)gN - gMean*gMean));

   double nMean = nSum/(double)nN;
   double nSd   = MathSqrt(MathMax(0.0, nSum2/(double)nN - nMean*nMean));
   //--- the simulated trades do not overlap, so this t is honest
   double t     = (nSd>0) ? nMean/(nSd/MathSqrt((double)nN)) : 0.0;

   PrintFormat("%5d %9d %10.4f %10.4f %8d %11.2f %10.4f %8.2f %7.1f%% %7d/%d",
               horizon, (int)gN, gMean, gMean-COST,
               (int)nN, nSum, nMean, t,
               100.0*nWin/(double)nN, monthsPos, monthsTot);

   if(!randomControl)
     {
      bool c1 = (nMean > 0);
      bool c2 = (MathAbs(t) > 2.0);
      bool c3 = (monthsTot>0 && (double)monthsPos/(double)monthsTot >= 0.75);
      PrintFormat("      -> net>0 %s | |t|>2 %s | 3-of-4 months %s | max drawdown %.2f  ==> %s",
                  c1?"YES":"no ", c2?"YES":"no ", c3?"YES":"no ", dd,
                  (c1&&c2&&c3) ? "*** PASSES ***" : "REJECTED");

      //--- a t-statistic computed on a handful of trades means nothing
      if(nN < 100)
         PrintFormat("      -> CAUTION: only %d trades. The t above is unstable; treat this row as anecdote.",
                     (int)nN);
     }
  }

//------------------------------------------------------------------
// Counts signals AND records where they actually occur. The span of the
// signals is the real sample -- it can be far shorter than the history.
//------------------------------------------------------------------
datetime g_firstSig=0, g_lastSig=0;

int CountSignals()
  {
   int start = MathMax(UserWarmup,10)+2;
   int end   = NBase - HOR[NH-1] - 2;
   int c=0;
   g_firstSig=0; g_lastSig=0;
   for(int i=start;i<=end;i++)
      if(UserSignal(i)!=0)
        {
         c++;
         if(g_firstSig==0) g_firstSig=Time(i);
         g_lastSig=Time(i);
        }
   return c;
  }

//==================================================================
void OnStart()
  {
   HOR[0]=InpH1; HOR[1]=InpH2; HOR[2]=InpH3; HOR[3]=InpH4;
   COST = InpSpread + InpCommission + InpSlippage;

   TFbase = (InpTF ==PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)_Period : InpTF;
   TFhigh = (InpTFb==PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)_Period : InpTFb;

   Print("==================================================================");
   Print("EdgeMeter -- does this signal beat its cost? NO ORDERS ARE SENT.");
   PrintFormat("%s  base %s  higher %s",
               _Symbol, EnumToString(TFbase), EnumToString(TFhigh));
   PrintFormat("Cost per round turn: %.5f  (spread %.5f + commission %.5f + slippage %.5f)",
               COST, InpSpread, InpCommission, InpSlippage);

   if(!LoadData()) return;
   if(!UserInit()) { Print("UserInit() failed -- check your indicator handles."); return; }

   PrintFormat("History: %d bars from %s to %s",
               NBase,
               TimeToString(Rate[0].time, TIME_DATE),
               TimeToString(Rate[NBase-1].time, TIME_DATE));

   int nsig = CountSignals();
   double rate = 100.0*nsig/(double)MathMax(1,NBase);
   PrintFormat("Signal fires on %d bars (%.1f%% of the sample).", nsig, rate);

   //--- a signal that fires almost everywhere is not selecting anything.
   //    It is a market-exposure proxy, and it will inherit whatever the
   //    instrument did over the period -- which is not an edge.
   if(rate > 90.0)
     {
      Print(">>> This signal is active on almost every bar. It is not selecting");
      Print(">>> moments, it is holding the market. Any profit below is mostly the");
      Print(">>> instrument's own drift over the period, not predictive skill.");
     }

   //--- THE NUMBER THAT MATTERS: not how much history was loaded, but how
   //    much of it the signal actually covers.
   if(nsig>0)
     {
      double spanDays  = (double)(g_lastSig-g_firstSig)/86400.0;
      double totalDays = (double)(Rate[NBase-1].time-Rate[0].time)/86400.0;
      PrintFormat("SIGNAL SPAN: %s to %s  (%.0f months of the %.0f months loaded)",
                  TimeToString(g_firstSig,TIME_DATE), TimeToString(g_lastSig,TIME_DATE),
                  spanDays/30.4, totalDays/30.4);
      if(totalDays>0 && spanDays/totalDays < 0.7)
        {
         Print(">>> Your effective sample is the SIGNAL SPAN, not the loaded history.");
         Print(">>> Read every number below against that shorter period.");
        }
     }
   if(nsig < 30)
      Print("WARNING: very few signals. Any result below is anecdote, not evidence.");

   Print("");
   Print("YOUR SIGNAL      ('net' = gross minus cost, per signal)");
   PrintFormat("%5s %9s %10s %10s %8s %11s %10s %8s %8s %9s",
               "hold","signals","gross","net","trades","total","net/trade","t","win%","months+");
   for(int k=0;k<NH;k++) Measure(HOR[k], false, 0);

   Print("");
   Print("RANDOM CONTROL -- same firing rate, coin-flip direction");
   Print("A random entry must lose roughly the cost. If your signal does not");
   Print("clearly beat these rows, it carries no information.");
   Print("At long horizons the control is noisy -- read its t, not its total.");
   PrintFormat("%5s %9s %10s %10s %8s %11s %10s %8s %8s %9s",
               "hold","signals","gross","net","trades","total","net/trade","t","win%","months+");
   for(int k=0;k<NH;k++) Measure(HOR[k], true, nsig);

   Print("");
   Print("PASS CRITERIA, all three required:");
   Print("  [1] net per trade > 0 after cost");
   Print("  [2] |t| > 2");
   Print("  [3] at least 3 profitable months out of 4");
   Print("Decide on these before you look at the numbers. Deciding afterwards");
   Print("is how a losing system gets promoted to a live account.");
   Print("==================================================================");
  }
//+------------------------------------------------------------------+
