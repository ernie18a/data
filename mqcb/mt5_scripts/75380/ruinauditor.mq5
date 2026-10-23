//+------------------------------------------------------------------+
//|                                                  RuinAuditor.mq5 |
//|                             Hidden Risk-of-Ruin Auditor for MQL5 |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Community contribution, MQL5.com"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Reads a closed-position history (CSV, or an auto-generated"
#property description "demo book) and reports a composite Hidden Risk-of-Ruin grade"
#property description "(A to F) built from four independent structural dimensions:"
#property description "volume escalation after losses, overlapping same-direction"
#property description "exposure, payoff asymmetry, and a classical risk-of-ruin"
#property description "approximation. Pure MQL5, no external libraries, no AI."
#property script_show_inputs

//--- input parameters ------------------------------------------------
input string InpCsvFileName          = "RuinAuditorSample.csv"; // CSV file (in MQL5\Files) to audit; a demo book is generated if it is missing
input double InpEscalationRatio      = 1.30;                    // Next-trade volume / previous-trade volume ratio that counts as "escalation" after a loss
input double InpEscalationRateRef    = 0.40;                    // Escalation rate (0-1) that maps the rate term to a full 100 points
input double InpEscalationStreakRef  = 5.0;                     // Longest escalation streak that maps the streak term to a full 100 points
input double InpGridConcurrentRef    = 6.0;                     // Concurrent same-direction position count that maps the overlap term to a full 100 points
input double InpWinRateLowBand       = 0.55;                    // Win rate at/below which the asymmetry win-rate term scores 0
input double InpWinRateHighBand      = 0.95;                    // Win rate at/above which the asymmetry win-rate term scores 100
input double InpPayoffLowBand        = 0.15;                    // Payoff ratio (avg win / avg loss) at/below which the payoff term scores 100
input double InpTailRatioRef         = 10.0;                    // largest-loss / average-win ratio that maps the tail term to a full 100 points
input double InpRiskFractionPerTrade = 0.02;                    // Fraction of capital you intend to risk per trade if you copy this book (classical risk-of-ruin input)
input double InpWeightEscalation     = 0.25;                    // Composite weight: volume-escalation dimension (weights are normalized, so only their ratio matters)
input double InpWeightGrid           = 0.25;                    // Composite weight: overlapping-exposure (grid/averaging) dimension
input double InpWeightAsymmetry      = 0.25;                    // Composite weight: payoff-asymmetry dimension
input double InpWeightRuin           = 0.25;                    // Composite weight: classical risk-of-ruin dimension
input double InpGradeA               = 85.0;                    // Minimum safety score for grade A
input double InpGradeB               = 70.0;                    // Minimum safety score for grade B
input double InpGradeC               = 50.0;                    // Minimum safety score for grade C
input double InpGradeD               = 30.0;                    // Minimum safety score for grade D (below this, grade F)
input int    InpMinPositions         = 30;                      // Minimum closed positions recommended for a statistically meaningful report

//--- one closed position at position-level granularity --------------
//--- MetaTrader 5 history is deal-level: a position closed through several
//--- partial exits is several deals, not one. Every dimension below is
//--- computed on reconstructed POSITIONS (this struct), never on raw deals,
//--- because the escalation and overlap fingerprints only make sense at
//--- position granularity. RuinExport.mq5 performs that reconstruction for
//--- your own account history; a hand-built CSV from a Signal's public
//--- history table is naturally already one row per closed position.
struct RuinPosition
  {
   datetime          open_time;                                 // time the position was opened (first entry fill)
   datetime          close_time;                                // time the position was fully closed (last exit fill)
   string            symbol;                                    // traded symbol
   bool              is_buy;                                    // true = long, false = short
   double            volume;                                    // net opened volume, in lots
   double            open_price;                                // volume-weighted average entry price
   double            close_price;                               // volume-weighted average exit price
   double            profit;                                    // net result in account currency (profit + swap + commission)
  };

//--- uniform output of one scoring dimension, shared by all four engines --
struct DimensionResult
  {
   double            score;                                     // 0-100, higher = more suspicious / higher risk contribution
   string            label;                                     // short name shown in the report
   string            detail;                                    // one-line, human-readable explanation of the numbers behind the score
  };

//+------------------------------------------------------------------+
//| Parse a direction column ("buy"/"sell"/"long"/"short") case-      |
//| insensitively; unrecognized text defaults to false (sell/short).  |
//+------------------------------------------------------------------+
bool ParseIsBuy(const string text)
  {
   string t = text;
   StringToLower(t);
   StringTrimLeft(t);
   StringTrimRight(t);
   return(t=="buy" || t=="long");
  }

//+------------------------------------------------------------------+
//| Insertion sort of a position array by open_time. n is typically a |
//| few hundred rows at most for an offline audit, so the simple O(n^2)|
//| worst case is fast enough and keeps the logic easy to verify.     |
//+------------------------------------------------------------------+
void SortPositionsByOpenTime(RuinPosition &pos[])
  {
   int n = ArraySize(pos);
   for(int i=1; i<n; i++)
     {
      RuinPosition key = pos[i];
      int j = i-1;
      while(j>=0 && pos[j].open_time>key.open_time)
        {
         pos[j+1] = pos[j];
         j--;
        }
      pos[j+1] = key;
     }
  }

//+------------------------------------------------------------------+
//| Append one fully-formed position row to a dynamic array.          |
//+------------------------------------------------------------------+
void AppendPosition(RuinPosition &out[], const datetime o_t, const datetime c_t, const string sym,
                     const bool is_buy, const double vol, const double o_price,
                     const double c_price, const double profit)
  {
   int idx = ArraySize(out);
   ArrayResize(out, idx+1);
   out[idx].open_time  = o_t;
   out[idx].close_time = c_t;
   out[idx].symbol     = sym;
   out[idx].is_buy      = is_buy;
   out[idx].volume      = vol;
   out[idx].open_price  = o_price;
   out[idx].close_price = c_price;
   out[idx].profit      = profit;
  }

//+------------------------------------------------------------------+
//| Uniform pseudo-random double in [0,1) built on MathRand(); used   |
//| only to shape the built-in demo book, never for scoring itself.   |
//+------------------------------------------------------------------+
double RandDouble01()
  {
   return(MathRand()/32767.0);
  }

//+------------------------------------------------------------------+
//| Append `count` ordinary, unremarkable trades: fixed 0.10-lot size,|
//| a 62% baseline win probability and no escalation or overlap. This |
//| is the "healthy" filler that surrounds the two injected fingerprints|
//| below, so the aggregate book still looks reasonable on the surface.|
//+------------------------------------------------------------------+
void AppendCleanTrades(RuinPosition &out[], const int count, const string symbol,
                        datetime &t, double &price)
  {
   for(int i=0; i<count; i++)
     {
      bool   win     = (RandDouble01()<0.62);
      double vol     = 0.10;
      double open_p  = price;
      double move    = 0.0006 + RandDouble01()*(0.0022-0.0006);
      bool   dir_buy = (RandDouble01()<0.5);
      double close_p, profit;
      if(win)
        {
         close_p = open_p+move;
         profit  = move*100000.0*vol;
        }
      else
        {
         close_p = open_p-move*0.9;
         profit  = -move*0.9*100000.0*vol;
        }
      datetime o_t = t;
      datetime c_t = t+(2+MathRand()%39)*60; // holding time: 2-40 minutes
      AppendPosition(out, o_t, c_t, symbol, dir_buy, vol, open_p, close_p, profit);
      t     = c_t+(1+MathRand()%15)*60;      // gap before the next trade: 1-15 minutes
      price = close_p;
     }
  }

//+------------------------------------------------------------------+
//| Build the built-in demo book: a fixed RNG seed plus two hand-      |
//| placed fingerprints (a grid/averaging cluster and a martingale     |
//| escalation streak), so the out-of-the-box report is reproducible   |
//| and lands on an instructive, non-trivial grade. The two fixed      |
//| clusters are literal, not randomly drawn, exactly because their    |
//| whole point is to be a known, deliberately injected pattern.       |
//+------------------------------------------------------------------+
void GenerateSampleBook(RuinPosition &out[])
  {
   ArrayResize(out, 0);
   MathSrand(1337);                                // fixed seed: same demo book on every run

   datetime t     = D'2026.01.05 00:00';
   double   price = 1.1000;

   AppendCleanTrades(out, 70, "EURUSD", t, price); // leg 1: baseline book

   //--- injected grid/averaging-down cluster: four overlapping BUY
   //--- entries on GBPUSD, each opened at a worse (lower) price than
   //--- the previous one, all closed together on the same losing exit.
   //--- This is the classic grid/averaging-down fingerprint.
   datetime base_t = t+50*60;
   AppendPosition(out, base_t,        base_t+400*60, "GBPUSD", true, 0.10, 1.2700, 1.2550, -150.0);
   AppendPosition(out, base_t+40*60,  base_t+400*60, "GBPUSD", true, 0.20, 1.2650, 1.2550, -200.0);
   AppendPosition(out, base_t+90*60,  base_t+400*60, "GBPUSD", true, 0.40, 1.2600, 1.2550, -200.0);
   AppendPosition(out, base_t+150*60, base_t+400*60, "GBPUSD", true, 0.80, 1.2560, 1.2550, -80.0);
   t = base_t+450*60;

   AppendCleanTrades(out, 20, "EURUSD", t, price); // leg 2: baseline book continues

   //--- injected martingale volume-escalation streak: three consecutive
   //--- losses, each followed by a doubled lot size, ending in a win
   //--- that "resets" the sequence back to a small size.
   datetime mt = t+60*60;
   AppendPosition(out, mt,       mt+20*60, "USDJPY", false, 0.10, 155.00, 155.30, -30.0);
   AppendPosition(out, mt+25*60, mt+45*60, "USDJPY", false, 0.20, 155.30, 155.55, -50.0);
   AppendPosition(out, mt+50*60, mt+70*60, "USDJPY", false, 0.40, 155.55, 155.80, -100.0);
   AppendPosition(out, mt+75*60, mt+95*60, "USDJPY", false, 0.80, 155.80, 155.20, 480.0);
   t = mt+100*60;

   AppendCleanTrades(out, 25, "EURUSD", t, price); // leg 3: baseline book concludes

   SortPositionsByOpenTime(out);
   PrintFormat("RuinAuditor: %s not found -- generated a %d-position demo book instead (fixed seed, reproducible).",
               InpCsvFileName, ArraySize(out));
  }

//+------------------------------------------------------------------+
//| Robust CSV loader. Expects the header row                         |
//| OpenTime,CloseTime,Symbol,Type,Volume,OpenPrice,ClosePrice,Profit  |
//| followed by one row per CLOSED POSITION (see the RuinPosition      |
//| comment above on why this must be position-, not deal-, level).   |
//| Reads as plain text, trims and skips blank lines, validates every  |
//| parsed field, and skips (rather than aborts on) a malformed row.   |
//+------------------------------------------------------------------+
bool LoadPositionsFromCsv(const string filename, RuinPosition &out[])
  {
   ResetLastError();
   int handle = FileOpen(filename, FILE_READ|FILE_TXT|FILE_ANSI);
   if(handle==INVALID_HANDLE)
      return(false);

   ArrayResize(out, 0);
   bool header_seen = false;
   int  line_no      = 0;
   int  skipped      = 0;

   while(!FileIsEnding(handle))
     {
      string line = FileReadString(handle);
      line_no++;
      StringTrimLeft(line);
      StringTrimRight(line);
      if(line=="")
         continue;           // skip blank lines
      if(!header_seen)
        {
         header_seen = true; // the first non-blank line is the header row
         continue;
        }

      string fields[];
      int n = StringSplit(line, ',', fields);
      if(n<8)
        {
         PrintFormat("RuinAuditor: skipping malformed line %d (expected 8 comma-separated fields, got %d)", line_no, n);
         skipped++;
         continue;
        }

      datetime o_time = StringToTime(fields[0]);
      datetime c_time = StringToTime(fields[1]);
      double   vol    = StringToDouble(fields[4]);
      double   o_price= StringToDouble(fields[5]);
      double   c_price= StringToDouble(fields[6]);

      if(o_time<=0 || c_time<=0 || vol<=0.0)
        {
         PrintFormat("RuinAuditor: skipping line %d, could not parse OpenTime/CloseTime/Volume", line_no);
         skipped++;
         continue;
        }

      AppendPosition(out, o_time, c_time, fields[2], ParseIsBuy(fields[3]), vol, o_price, c_price,
                     StringToDouble(fields[7]));
     }
   FileClose(handle);

   if(skipped>0)
      PrintFormat("RuinAuditor: loaded %d positions from %s, skipped %d unreadable line(s).",
                  ArraySize(out), filename, skipped);
   else
      PrintFormat("RuinAuditor: loaded %d positions from %s.", ArraySize(out), filename);

   SortPositionsByOpenTime(out);
   return(ArraySize(out)>0);
  }

//+------------------------------------------------------------------+
//| Dimension 1 - volume escalation after a loss. A martingale-style   |
//| system increases size after a losing trade to recover it faster.  |
//| For every losing position, this checks whether the NEXT position   |
//| (chronologically) used at least InpEscalationRatio times the       |
//| volume, and tracks the longest unbroken streak of such escalations,|
//| since a real martingale keeps doubling until a win, not just once. |
//+------------------------------------------------------------------+
DimensionResult ComputeEscalationScore(const RuinPosition &pos[])
  {
   int n = ArraySize(pos);
   int events=0, considered=0, cur_streak=0, max_streak=0;

   for(int i=0; i<n-1; i++)
     {
      if(pos[i].profit<0.0)
        {
         considered++;
         double ratio = (pos[i].volume>0.0) ? pos[i+1].volume/pos[i].volume : 0.0;
         if(ratio>=InpEscalationRatio)
           {
            events++;
            cur_streak++;
            if(cur_streak>max_streak) max_streak = cur_streak;
           }
         else
            cur_streak = 0;
        }
      else
         cur_streak = 0;
     }

   double rate         = (considered>0) ? (double)events/(double)considered : 0.0;
   double rate_score    = 100.0*MathMin(rate/InpEscalationRateRef, 1.0);
   double streak_score  = 100.0*MathMin((double)max_streak/InpEscalationStreakRef, 1.0);

   DimensionResult r;
   r.score  = 0.6*rate_score+0.4*streak_score;
   r.label  = "Volume escalation after a loss";
   r.detail = StringFormat("%d of %d post-loss transitions escalated volume by >= %.0f%% (longest streak: %d)",
                           events, considered, (InpEscalationRatio-1.0)*100.0, max_streak);
   return(r);
  }

//+------------------------------------------------------------------+
//| Dimension 2 - overlapping same-direction exposure (grid/averaging).|
//| Groups positions by (symbol, direction), finds the largest number  |
//| of them open at the same instant, and checks whether time-         |
//| overlapping clusters of two or more entries worsen monotonically   |
//| in the adverse direction -- the averaging-down fingerprint. A high |
//| concurrent count WITHOUT worsening entries can be legitimate       |
//| scaling into strength, so both terms matter, not just the count.   |
//+------------------------------------------------------------------+
DimensionResult ComputeGridScore(const RuinPosition &pos[])
  {
   int n = ArraySize(pos);
   string keys_symbol[];
   bool   keys_isbuy[];
   int    key_count = 0;

   for(int i=0; i<n; i++)
     {
      bool found = false;
      for(int k=0; k<key_count; k++)
         if(keys_symbol[k]==pos[i].symbol && keys_isbuy[k]==pos[i].is_buy)
           {
            found = true;
            break;
           }
      if(!found)
        {
         ArrayResize(keys_symbol, key_count+1);
         ArrayResize(keys_isbuy,  key_count+1);
         keys_symbol[key_count] = pos[i].symbol;
         keys_isbuy[key_count]  = pos[i].is_buy;
         key_count++;
        }
     }

   int max_concurrent     = 0;
   int total_clusters     = 0;
   int worsening_clusters = 0;

   for(int k=0; k<key_count; k++)
     {
      int idxs[];
      int cnt = 0;
      for(int i=0; i<n; i++)
         if(pos[i].symbol==keys_symbol[k] && pos[i].is_buy==keys_isbuy[k])
           {
            ArrayResize(idxs, cnt+1);
            idxs[cnt] = i;
            cnt++;
           }

      //--- largest number of this symbol/direction open at the same instant
      for(int a=0; a<cnt; a++)
        {
         int concurrent_here = 0;
         for(int b=0; b<cnt; b++)
            if(pos[idxs[b]].open_time<=pos[idxs[a]].open_time && pos[idxs[b]].close_time>=pos[idxs[a]].open_time)
               concurrent_here++;
         if(concurrent_here>max_concurrent) max_concurrent = concurrent_here;
        }

      //--- group into maximal time-overlapping clusters (idxs[] is already in
      //--- open_time order because pos[] itself is sorted by open_time)
      int      cluster_of[];
      datetime running_end[];
      ArrayResize(cluster_of,  cnt);
      ArrayResize(running_end, cnt);
      int n_clusters = 0;
      for(int a=0; a<cnt; a++)
        {
         int idx = idxs[a];
         bool placed = false;
         for(int c=0; c<n_clusters; c++)
            if(pos[idx].open_time<=running_end[c])
              {
               cluster_of[a] = c;
               if(pos[idx].close_time>running_end[c]) running_end[c] = pos[idx].close_time;
               placed = true;
               break;
              }
         if(!placed)
           {
            cluster_of[a]        = n_clusters;
            running_end[n_clusters] = pos[idx].close_time;
            n_clusters++;
           }
        }

      for(int c=0; c<n_clusters; c++)
        {
         int members[];
         int mc = 0;
         for(int a=0; a<cnt; a++)
            if(cluster_of[a]==c)
              {
               ArrayResize(members, mc+1);
               members[mc] = idxs[a];
               mc++;
              }
         if(mc<2) continue; // a lone position is not a cluster
         total_clusters++;

         bool worsening = true;
         for(int m=0; m<mc-1; m++)
           {
            double p1 = pos[members[m]].open_price;
            double p2 = pos[members[m+1]].open_price;
            if(keys_isbuy[k]) { if(p1<p2) { worsening=false; break; } }
            else              { if(p1>p2) { worsening=false; break; } }
           }
         if(worsening) worsening_clusters++;
        }
     }

   double worsening_fraction = (total_clusters>0) ? (double)worsening_clusters/(double)total_clusters : 0.0;
   double concurrent_score   = 100.0*MathMin((double)max_concurrent/InpGridConcurrentRef, 1.0);
   double worsening_score    = 100.0*worsening_fraction;

   DimensionResult r;
   r.score  = 0.5*concurrent_score+0.5*worsening_score;
   r.label  = "Overlapping same-direction exposure (grid/averaging)";
   r.detail = StringFormat("largest same-symbol same-direction overlap: %d concurrent position(s); %d of %d overlapping cluster(s) averaged into a worse price",
                           max_concurrent, worsening_clusters, total_clusters);
   return(r);
  }

//+------------------------------------------------------------------+
//| Dimension 3 - payoff asymmetry. The classic martingale/grid        |
//| signature is many small wins next to a rare, disproportionately    |
//| large loss. Also returns win_rate and payoff_ratio by reference so |
//| the classical risk-of-ruin dimension can reuse them without a      |
//| second pass over the book. A book with zero losing trades cannot   |
//| rule out an inflating martingale that simply has not unwound yet,  |
//| so that case is treated as high-attention, not as "safe".          |
//+------------------------------------------------------------------+
DimensionResult ComputePayoffAsymmetryScore(const RuinPosition &pos[], double &out_win_rate, double &out_payoff_ratio)
  {
   int    n = ArraySize(pos);
   int    wins=0, losses=0;
   double sum_win=0.0, sum_loss=0.0, largest_loss=0.0;

   for(int i=0; i<n; i++)
     {
      if(pos[i].profit>0.0)
        {
         wins++;
         sum_win += pos[i].profit;
        }
      else if(pos[i].profit<0.0)
        {
         losses++;
         double loss = -pos[i].profit;
         sum_loss += loss;
         if(loss>largest_loss) largest_loss = loss;
        }
     }

   double win_rate = (n>0) ? (double)wins/(double)n : 0.0;
   double avg_win  = (wins>0) ? sum_win/wins : 0.0;

   DimensionResult r;
   r.label = "Payoff asymmetry (small wins vs. tail-risk losses)";

   if(losses==0)
     {
      out_win_rate     = win_rate;
      out_payoff_ratio = -1.0; // sentinel: undefined, no losses recorded yet
      r.score  = 70.0;
      r.detail = "no losing trades in the sample yet -- inconclusive by definition, treated as high-attention rather than safe";
      return(r);
     }

   double avg_loss     = sum_loss/losses;
   double payoff_ratio = (avg_loss>0.0) ? avg_win/avg_loss : 0.0;
   double tail_ratio   = (avg_win>0.0)  ? largest_loss/avg_win : 0.0;

   double winrate_score = 100.0*MathMax(0.0, MathMin((win_rate-InpWinRateLowBand)/(InpWinRateHighBand-InpWinRateLowBand), 1.0));
   double payoff_score  = (payoff_ratio<=1.0) ? 100.0*MathMax(0.0, MathMin((1.0-payoff_ratio)/(1.0-InpPayoffLowBand), 1.0)) : 0.0;
   double tail_score    = 100.0*MathMin(tail_ratio/InpTailRatioRef, 1.0);

   out_win_rate     = win_rate;
   out_payoff_ratio = payoff_ratio;

   r.score  = 0.35*winrate_score+0.35*payoff_score+0.30*tail_score;
   r.detail = StringFormat("win rate %.1f%%, payoff ratio %.2f (avg win / avg loss), largest loss = %.1fx the average win",
                           win_rate*100.0, payoff_ratio, tail_ratio);
   return(r);
  }

//+------------------------------------------------------------------+
//| Dimension 4 - classical risk of ruin (heuristic approximation).    |
//| A = (W*Rp - L) / (W*Rp + L), assuming independent, identically     |
//| distributed win/loss outcomes fixed at their historical averages,  |
//| and a fixed fraction of capital risked per trade (InpRiskFraction- |
//| PerTrade). R = ((1-A)/(1+A))^U, with U = 1/risk fraction "capital  |
//| units". This is the classical gambler's-ruin approximation for     |
//| unequal payoffs (Vince, 1990/1992); real trade sequences are not   |
//| strictly i.i.d., so treat this as a heuristic screen, not a proof. |
//+------------------------------------------------------------------+
DimensionResult ComputeClassicalRuinScore(const double win_rate, const double payoff_ratio)
  {
   DimensionResult r;
   r.label = "Classical risk of ruin (heuristic approximation)";

   if(payoff_ratio<0.0) // sentinel from the asymmetry step: no losses recorded
     {
      r.score  = 50.0;
      r.detail = "cannot be estimated without at least one losing trade; treated as neutral/undefined";
      return(r);
     }

   double W     = win_rate;
   double L     = 1.0-win_rate;
   double denom = W*payoff_ratio+L;
   double edge  = (denom>0.0) ? (W*payoff_ratio-L)/denom : -1.0;
   double units = 1.0/MathMax(InpRiskFractionPerTrade, 0.0001);

   double ruin_probability;
   string note;
   if(edge<=0.0)
     {
      ruin_probability = 1.0;
      note = "non-positive edge: the classical formula assumes certain eventual ruin over an unbounded series of trades";
     }
   else
     {
      ruin_probability = MathPow((1.0-edge)/(1.0+edge), units);
      ruin_probability = MathMax(0.0, MathMin(ruin_probability, 1.0));
      note = StringFormat("edge=%.3f, capital cushion=%.0f risk units at %.1f%% risked per trade",
                          edge, units, InpRiskFractionPerTrade*100.0);
     }

   r.score  = ruin_probability*100.0;
   r.detail = StringFormat("%s (win rate %.1f%%, payoff ratio %.2f)", note, win_rate*100.0, payoff_ratio);
   return(r);
  }

//+------------------------------------------------------------------+
//| Map a 0-100 safety score (100 = safest) to a letter grade using   |
//| the configurable thresholds above.                                 |
//+------------------------------------------------------------------+
string GradeFromScore(const double safety)
  {
   if(safety>=InpGradeA) return("A");
   if(safety>=InpGradeB) return("B");
   if(safety>=InpGradeC) return("C");
   if(safety>=InpGradeD) return("D");
   return("F");
  }

//+------------------------------------------------------------------+
//| Print one plain-language recommendation per dimension that        |
//| crossed the 50-point attention threshold, or a neutral note if     |
//| none did -- a clean screen is not proof of safety, only the        |
//| absence of these four specific fingerprints.                       |
//+------------------------------------------------------------------+
void PrintRecommendations(const DimensionResult &esc, const DimensionResult &grd,
                          const DimensionResult &asym, const DimensionResult &ruin)
  {
   Print("--- Recommendations ---");
   bool any = false;
   if(esc.score>=50.0)  { Print("- Investigate the sizing rule: volume increases materially after losing trades."); any=true; }
   if(grd.score>=50.0)  { Print("- Investigate position stacking: this book repeatedly averages into a losing side."); any=true; }
   if(asym.score>=50.0) { Print("- Treat the win rate with caution: frequent small wins are paired with disproportionate losses."); any=true; }
   if(ruin.score>=50.0) { Print("- The classical risk-of-ruin approximation is elevated at the stated risk per trade; reduce size or gather a larger sample."); any=true; }
   if(!any)
      Print("- No dimension crossed the attention threshold; this screen found no fingerprint, which is not the same as a guarantee of safety (see Applicability and limitations).");
  }

//+------------------------------------------------------------------+
//| Script program start function                                     |
//+------------------------------------------------------------------+
void OnStart()
  {
   RuinPosition positions[];
   if(!LoadPositionsFromCsv(InpCsvFileName, positions))
      GenerateSampleBook(positions);

   int total = ArraySize(positions);
   if(total<InpMinPositions)
      PrintFormat("RuinAuditor: only %d closed position(s) available (minimum recommended is %d) -- the scores below are shown for reference only and are not statistically meaningful yet.",
                  total, InpMinPositions);

   double win_rate=0.0, payoff_ratio=0.0;
   DimensionResult esc  = ComputeEscalationScore(positions);
   DimensionResult grd  = ComputeGridScore(positions);
   DimensionResult asym = ComputePayoffAsymmetryScore(positions, win_rate, payoff_ratio);
   DimensionResult ruin = ComputeClassicalRuinScore(win_rate, payoff_ratio);

   double wsum = MathMax(InpWeightEscalation+InpWeightGrid+InpWeightAsymmetry+InpWeightRuin, 0.0001);
   double we = InpWeightEscalation/wsum;
   double wg = InpWeightGrid/wsum;
   double wa = InpWeightAsymmetry/wsum;
   double wr = InpWeightRuin/wsum;

   double risk_composite = we*esc.score+wg*grd.score+wa*asym.score+wr*ruin.score;
   double safety_score   = 100.0-risk_composite;
   string letter         = GradeFromScore(safety_score);

   PrintFormat("=== Hidden Risk-of-Ruin Auditor: %d closed position(s) analyzed ===", total);
   PrintFormat("[1] %s -- score %.1f (%s)", esc.label,  esc.score,  esc.detail);
   PrintFormat("[2] %s -- score %.1f (%s)", grd.label,  grd.score,  grd.detail);
   PrintFormat("[3] %s -- score %.1f (%s)", asym.label, asym.score, asym.detail);
   PrintFormat("[4] %s -- score %.1f (%s)", ruin.label, ruin.score, ruin.detail);
   PrintFormat("Composite risk score: %.1f/100  ->  Safety score: %.1f/100  ->  Grade: %s",
               risk_composite, safety_score, letter);

   PrintRecommendations(esc, grd, asym, ruin);
  }
//+------------------------------------------------------------------+
