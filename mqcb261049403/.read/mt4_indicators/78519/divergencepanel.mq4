//+------------------------------------------------------------------+

//|                                             DivergencePanel6.mq4 |

//|                       Bruno Myrrha + Claude AI + Grok + DeepSeek |

//+------------------------------------------------------------------+

//| Panel: one row per timeframe (M1..MN1), six columns (bars -5..-1 |

//| and the current bar), up to 10 squares per cell (one per         |

//| oscillator). Green = bullish, red = bearish.                     |

//|                                                                  |

//| Same engine AND same display rule as MultiIndicatorDivergence:   |

//| a newer signal on the same side, before the next pivot of that   |

//| side forms, REPLACES the previous one. So a closed-bar column    |

//| only shows a signal that is still on the chart indicator.        |

//| The "Atual" column is a preview: what the chart indicator would  |

//| show if the current bar closed now (it never changes the closed  |

//| columns while confirmation is on).                               |

//+------------------------------------------------------------------+

#property copyright "Bruno Nunes Myrrha Ribeiro"

#property version   "1.20"

#property description "Divergence Panel - same engine and display rules as MultiIndicatorDivergence"

#property strict

#property indicator_chart_window



enum ENUM_PIVOT_SOURCE { PIVOT_CLOSE, PIVOT_WICKS };

enum ENUM_DIV_KINDS    { KINDS_REGULAR, KINDS_HIDDEN, KINDS_BOTH };



input string SepPivots = "------------";

input int               InpSpan      = 5;             // pivot period, bars on each side

input ENUM_PIVOT_SOURCE InpSource    = PIVOT_CLOSE;   // pivot source

input ENUM_DIV_KINDS    InpKinds     = KINDS_REGULAR; // divergence type

input int               InpMinCount  = 1;             // minimum divergences on a bar

input int               InpMaxPivots = 10;            // pivots checked back

input int               InpMaxReach  = 100;           // bars checked back

input bool              InpConfirm   = true;          // wait for the next bar to confirm

input bool              InpLastOnly  = false;         // keep only the latest divergence (same as the chart indicator)

input int               InpBars      = 1200;          // bars loaded per timeframe



input string SepOsc = "------------";

input bool InpUseMacd   = true;

input bool InpUseHist   = true;

input bool InpUseRsi    = true;

input bool InpUseStoch  = true;

input bool InpUseCci    = true;

input bool InpUseMom    = true;

input bool InpUseObv    = true;

input bool InpUseVwmacd = true;

input bool InpUseCmf    = true;

input bool InpUseMfi    = true;



input string SepPanel = "------------";

input int   InpX          = 8;

input int   InpY          = 18;

input int   InpSquare     = 7;

input int   InpGap        = 2;

input int   InpFontSize   = 8;

input bool  InpEmptySlots = true;

input bool  InpShowBg     = true;

input color InpBullColor  = C'0,214,143';

input color InpBearColor  = C'255,82,82';

input color InpEmptyColor = C'52,56,66';

input color InpBgColor    = C'22,25,31';

input color InpBorderColor= C'62,67,80';

input color InpStripeColor= C'30,34,42';

input color InpTitleColor = C'235,238,245';

input color InpTextColor  = C'150,157,172';

input color InpAccentColor= C'255,196,61';



#define OSCILLATORS  10

#define KINDS        4

#define PIVOT_SLOTS  20

#define MIN_REACH    5

#define NO_VALUE     DBL_MAX

#define WARMUP       400

#define BULL_REGULAR 0

#define BEAR_REGULAR 1

#define BULL_HIDDEN  2

#define BEAR_HIDDEN  3

#define TFS          9

#define SLOTS        10

#define COLS         6

#define PAD          8

#define COL_GAP      12

#define TAG          "DP_"



int    g_tfs[TFS]     = {PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};

string g_tfNames[TFS] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN1"};



struct ScanRules {

   int  span;

   bool wicks;

   bool regular;

   bool hidden;

   int  maxPivots;

   int  maxReach;

   bool liveBar;

   bool lastOnly;

   int  minCount;

   bool enabled[OSCILLATORS];

};



struct PivotStack {

   int    bar[PIVOT_SLOTS];

   double level[PIVOT_SLOTS];

   int    count;

};



struct Pivots {

   PivotStack highs;

   PivotStack lows;

};



double g_emaFast[], g_emaSlow[], g_macd[], g_signal[], g_hist[];

double g_gain[], g_loss[], g_rsi[], g_rawK[], g_stoch[];

double g_cci[], g_mom[], g_obv[], g_vwmacd[], g_cmf[], g_mfi[];

double g_high[], g_low[], g_close[];

long   g_vol[];



ScanRules g_rules;

int       g_state[TFS][COLS][SLOTS];

bool      g_pending = false;



//+------------------------------------------------------------------+

//| Oscillators (same as the chart indicator)                        |

//+------------------------------------------------------------------+

double MeanAt(const double &v[], const int i, const int n, const int first) {

   if(i-n+1 < first) return(NO_VALUE);

   double sum = 0;

   for(int k = i-n+1; k <= i; k++) {

      if(v[k] == NO_VALUE) return(NO_VALUE);

      sum += v[k];

   }

   return(sum / n);

}



double EmaAt(const double &src[], const double &dst[], const int i, const int n, const int first) {

   if(src[i] == NO_VALUE) return(NO_VALUE);

   if(i > first && dst[i-1] != NO_VALUE) {

      double alpha = 2.0 / (n + 1);

      return(alpha * src[i] + (1 - alpha) * dst[i-1]);

   }

   return(MeanAt(src, i, n, first));

}



void MacdAt(const double &close[], double &fast[], double &slow[], double &line[],

            double &signal[], double &hist[], const int i, const int first) {

   fast[i] = EmaAt(close, fast, i, 12, first);

   slow[i] = EmaAt(close, slow, i, 26, first);

   line[i] = (fast[i] == NO_VALUE || slow[i] == NO_VALUE) ? NO_VALUE : fast[i] - slow[i];

   signal[i] = EmaAt(line, signal, i, 9, first);

   hist[i] = (signal[i] == NO_VALUE) ? NO_VALUE : line[i] - signal[i];

}



void RsiAt(const double &close[], double &gain[], double &loss[], double &rsi[],

           const int i, const int first) {

   const int n = 14;

   gain[i] = NO_VALUE;

   loss[i] = NO_VALUE;

   rsi[i] = NO_VALUE;

   if(i-1 < first) return;

   double up = MathMax(close[i] - close[i-1], 0.0);

   double down = MathMax(close[i-1] - close[i], 0.0);

   if(gain[i-1] != NO_VALUE) {

      gain[i] = (up + (n-1)*gain[i-1]) / n;

      loss[i] = (down + (n-1)*loss[i-1]) / n;

   } else {

      if(i-n < first) return;

      double sumUp = 0, sumDown = 0;

      for(int k = i-n+1; k <= i; k++) {

         sumUp += MathMax(close[k] - close[k-1], 0.0);

         sumDown += MathMax(close[k-1] - close[k], 0.0);

      }

      gain[i] = sumUp / n;

      loss[i] = sumDown / n;

   }

   if(loss[i] == 0) rsi[i] = (gain[i] > 0) ? 100 : NO_VALUE;

   else rsi[i] = 100 - 100 / (1 + gain[i]/loss[i]);

}



void StochAt(const double &high[], const double &low[], const double &close[], double &raw[],

             double &smooth[], const int i, const int first) {

   raw[i] = NO_VALUE;

   if(i-13 >= first) {

      double top = high[i], bottom = low[i];

      for(int k = i-13; k < i; k++) {

         top = MathMax(top, high[k]);

         bottom = MathMin(bottom, low[k]);

      }

      if(top > bottom) raw[i] = 100 * (close[i] - bottom) / (top - bottom);

   }

   smooth[i] = MeanAt(raw, i, 3, first);

}



double CciAt(const double &close[], const int i, const int first) {

   double mean = MeanAt(close, i, 10, first);

   if(mean == NO_VALUE) return(NO_VALUE);

   double dev = 0;

   for(int k = i-9; k <= i; k++) dev += MathAbs(close[k] - mean);

   dev /= 10;

   return(dev > 0 ? (close[i] - mean) / (0.015 * dev) : NO_VALUE);

}



double MomentumAt(const double &close[], const int i, const int first) {

   return(i-10 >= first ? close[i] - close[i-10] : NO_VALUE);

}



double ObvAt(const double &close[], const long &volume[], const double &obv[], const int i, const int first) {

   if(i <= first || obv[i-1] == NO_VALUE) return(0);

   double move = close[i] - close[i-1];

   double sign = (move > 0) ? 1 : (move < 0 ? -1 : 0);

   return(obv[i-1] + sign * (double)volume[i]);

}



double VwmaAt(const double &close[], const long &volume[], const int i, const int n, const int first) {

   if(i-n+1 < first) return(NO_VALUE);

   double weighted = 0, total = 0;

   for(int k = i-n+1; k <= i; k++) {

      weighted += close[k] * (double)volume[k];

      total += (double)volume[k];

   }

   return(total > 0 ? weighted / total : NO_VALUE);

}



double VwmacdAt(const double &close[], const long &volume[], const int i, const int first) {

   double fast = VwmaAt(close, volume, i, 12, first);

   double slow = VwmaAt(close, volume, i, 26, first);

   return((fast == NO_VALUE || slow == NO_VALUE) ? NO_VALUE : fast - slow);

}



double CmfAt(const double &high[], const double &low[], const double &close[], const long &volume[], const int i, const int first) {

   const int n = 21;

   if(i-n+1 < first) return(NO_VALUE);

   double flow = 0, total = 0;

   for(int k = i-n+1; k <= i; k++) {

      double range = high[k] - low[k];

      if(range <= 0) return(NO_VALUE);

      flow += ((close[k] - low[k]) - (high[k] - close[k])) / range * (double)volume[k];

      total += (double)volume[k];

   }

   return(total > 0 ? flow / total : NO_VALUE);

}



double MfiAt(const double &close[], const long &volume[], const int i, const int first) {

   const int n = 14;

   if(i-n < first) return(NO_VALUE);

   double rising = 0, falling = 0;

   for(int k = i-n+1; k <= i; k++) {

      double move = close[k] - close[k-1];

      if(move > 0) rising += (double)volume[k] * close[k];

      if(move < 0) falling += (double)volume[k] * close[k];

   }

   if(falling == 0) return(rising > 0 ? 100 : NO_VALUE);

   return(100 - 100 / (1 + rising / falling));

}



//+------------------------------------------------------------------+

//| Divergence logic (same as the chart indicator)                   |

//+------------------------------------------------------------------+

bool Beyond(const double b, const double a, const int dir) {

   if(b == NO_VALUE || a == NO_VALUE) return(false);

   return(dir > 0 ? b > a : b < a);

}



bool IsTurn(const double &v[], const int c, const int span, const int dir) {

   for(int k = 1; k <= span; k++) {

      if(dir * (v[c] - v[c-k]) <= 0) return(false);

      if(dir * (v[c] - v[c+k]) < 0) return(false);

   }

   return(true);

}



void PushPivot(PivotStack &stack, const int bar, const double level) {

   for(int k = MathMin(stack.count, PIVOT_SLOTS-1); k > 0; k--) {

      stack.bar[k] = stack.bar[k-1];

      stack.level[k] = stack.level[k-1];

   }

   stack.bar[0] = bar;

   stack.level[0] = level;

   stack.count = MathMin(stack.count + 1, PIVOT_SLOTS);

}



//--- records the pivot confirmed at bar; tells whether a new top / bottom appeared

void TrackPivots(Pivots &pv, const int bar, bool &newTop, bool &newBottom) {

   newTop = false;

   newBottom = false;

   int c = bar - g_rules.span;

   if(c - g_rules.span < 0) return;

   newTop = g_rules.wicks ? IsTurn(g_high, c, g_rules.span, 1) : IsTurn(g_close, c, g_rules.span, 1);

   newBottom = g_rules.wicks ? IsTurn(g_low, c, g_rules.span, -1) : IsTurn(g_close, c, g_rules.span, -1);

   if(newTop) PushPivot(pv.highs, c, g_rules.wicks ? g_high[c] : g_close[c]);

   if(newBottom) PushPivot(pv.lows, c, g_rules.wicks ? g_low[c] : g_close[c]);

}



bool ClearPath(const double &osc[], const double &close[], const int bar, const int from, const int reach, const int dir) {

   double stepOsc = (osc[bar-from] - osc[bar-reach]) / (reach - from);

   double stepPx = (close[bar-from] - close[bar-reach]) / (reach - from);

   double lineOsc = osc[bar-from] - stepOsc;

   double linePx = close[bar-from] - stepPx;

   for(int k = from + 1; k < reach; k++) {

      if(Beyond(lineOsc, osc[bar-k], dir) || Beyond(linePx, close[bar-k], dir)) return(false);

      lineOsc -= stepOsc;

      linePx -= stepPx;

   }

   return(true);

}



int SeekPivot(const double &osc[], const double &close[], const double &probe[],

              const int bar, const PivotStack &stack, const int dir, const bool hidden) {

   if(!g_rules.liveBar && !Beyond(osc[bar], osc[bar-1], dir) && !Beyond(close[bar], close[bar-1], dir))

      return(0);

   int from = g_rules.liveBar ? 0 : 1;

   int end = bar - from;

   int depth = MathMin(g_rules.maxPivots, stack.count);

   for(int n = 0; n < depth; n++) {

      int reach = bar - stack.bar[n];

      if(reach > g_rules.maxReach) break;

      if(reach <= MIN_REACH) continue;

      int pivot = stack.bar[n];

      bool shape;

      if(hidden)

         shape = Beyond(osc[pivot], osc[end], dir) && Beyond(probe[end], stack.level[n], dir);

      else

         shape = Beyond(osc[end], osc[pivot], dir) && Beyond(stack.level[n], probe[end], dir);

      if(shape && ClearPath(osc, close, bar, from, reach, dir))

         return(reach);

   }

   return(0);

}



void ScanOsc(const double &osc[], const int bar, const Pivots &pv, int &found[]) {

   ArrayInitialize(found, 0);

   if(g_rules.wicks) {

      if(g_rules.regular) {

         found[BULL_REGULAR] = SeekPivot(osc, g_close, g_low, bar, pv.lows, 1, false);

         found[BEAR_REGULAR] = SeekPivot(osc, g_close, g_high, bar, pv.highs, -1, false);

      }

      if(g_rules.hidden) {

         found[BULL_HIDDEN] = SeekPivot(osc, g_close, g_low, bar, pv.lows, 1, true);

         found[BEAR_HIDDEN] = SeekPivot(osc, g_close, g_high, bar, pv.highs, -1, true);

      }

   } else {

      if(g_rules.regular) {

         found[BULL_REGULAR] = SeekPivot(osc, g_close, g_close, bar, pv.lows, 1, false);

         found[BEAR_REGULAR] = SeekPivot(osc, g_close, g_close, bar, pv.highs, -1, false);

      }

      if(g_rules.hidden) {

         found[BULL_HIDDEN] = SeekPivot(osc, g_close, g_close, bar, pv.lows, 1, true);

         found[BEAR_HIDDEN] = SeekPivot(osc, g_close, g_close, bar, pv.highs, -1, true);

      }

   }

}



void ScanSlot(const int slot, const int bar, const Pivots &pv, int &found[]) {

   switch(slot) {

      case 0: ScanOsc(g_macd, bar, pv, found); break;

      case 1: ScanOsc(g_hist, bar, pv, found); break;

      case 2: ScanOsc(g_rsi, bar, pv, found); break;

      case 3: ScanOsc(g_stoch, bar, pv, found); break;

      case 4: ScanOsc(g_cci, bar, pv, found); break;

      case 5: ScanOsc(g_mom, bar, pv, found); break;

      case 6: ScanOsc(g_obv, bar, pv, found); break;

      case 7: ScanOsc(g_vwmacd, bar, pv, found); break;

      case 8: ScanOsc(g_cmf, bar, pv, found); break;

      default: ScanOsc(g_mfi, bar, pv, found); break;

   }

}



//--- oscillators with a bullish / bearish divergence on the bar (raw, before replacement)

void CountBar(const int bar, const Pivots &pv, int &bulls, int &bears) {

   bulls = 0;

   bears = 0;

   int found[OSCILLATORS * KINDS];

   ArrayInitialize(found, 0);

   int total = 0;



   for(int s = 0; s < OSCILLATORS; s++) {

      if(!g_rules.enabled[s]) continue;

      int temp[KINDS];

      ScanSlot(s, bar, pv, temp);

      for(int k = 0; k < KINDS; k++) {

         found[s*KINDS+k] = temp[k];

         if(temp[k] > 0) total++;

      }

   }



   if(total < g_rules.minCount) return;



   for(int s = 0; s < OSCILLATORS; s++) {

      bool hasBull = (found[s*KINDS + BULL_REGULAR] > 0) || (found[s*KINDS + BULL_HIDDEN] > 0);

      bool hasBear = (found[s*KINDS + BEAR_REGULAR] > 0) || (found[s*KINDS + BEAR_HIDDEN] > 0);

      if(hasBull) bulls++;

      if(hasBear) bears++;

   }

}



void PrepareCalc(const int total) {

   ArrayResize(g_emaFast, total); ArrayResize(g_emaSlow, total);

   ArrayResize(g_macd, total); ArrayResize(g_signal, total); ArrayResize(g_hist, total);

   ArrayResize(g_gain, total); ArrayResize(g_loss, total); ArrayResize(g_rsi, total);

   ArrayResize(g_rawK, total); ArrayResize(g_stoch, total);

   ArrayResize(g_cci, total); ArrayResize(g_mom, total); ArrayResize(g_obv, total);

   ArrayResize(g_vwmacd, total); ArrayResize(g_cmf, total); ArrayResize(g_mfi, total);

   ArrayInitialize(g_emaFast, NO_VALUE); ArrayInitialize(g_emaSlow, NO_VALUE);

   ArrayInitialize(g_macd, NO_VALUE); ArrayInitialize(g_signal, NO_VALUE); ArrayInitialize(g_hist, NO_VALUE);

   ArrayInitialize(g_gain, NO_VALUE); ArrayInitialize(g_loss, NO_VALUE); ArrayInitialize(g_rsi, NO_VALUE);

   ArrayInitialize(g_rawK, NO_VALUE); ArrayInitialize(g_stoch, NO_VALUE);

   ArrayInitialize(g_cci, NO_VALUE); ArrayInitialize(g_mom, NO_VALUE); ArrayInitialize(g_obv, NO_VALUE);

   ArrayInitialize(g_vwmacd, NO_VALUE); ArrayInitialize(g_cmf, NO_VALUE); ArrayInitialize(g_mfi, NO_VALUE);

}



//+------------------------------------------------------------------+

//| True when a later signal of the same side takes the place of the |

//| signal on column c, exactly like the chart indicator does:       |

//|  - a newer signal replaces it, unless a new pivot of that side   |

//|    formed in between (flag[y] = new pivot confirmed on bar y)    |

//|  - with "last only" any newer signal replaces it                 |

//+------------------------------------------------------------------+

bool Replaced(const int &sig[], const bool &flag[], const int c, const int last) {

   for(int y = c + 1; y <= last; y++) {

      if(!g_rules.lastOnly && flag[y]) return(false);

      if(sig[y] > 0) return(true);

   }

   return(false);

}



bool Analyze(const int tf, int &bulls[], int &bears[]) {

   for(int c = 0; c < COLS; c++) {

      bulls[c] = 0;

      bears[c] = 0;

   }



   MqlRates r[];

   ArraySetAsSeries(r, false);



   int total = CopyRates(_Symbol, (ENUM_TIMEFRAMES)tf, 0, InpBars + WARMUP + InpMaxReach, r);

   if(total < 100) return(false);



   ArrayResize(g_high, total); ArrayResize(g_low, total);

   ArrayResize(g_close, total); ArrayResize(g_vol, total);



   for(int i = 0; i < total; i++) {

      g_high[i] = r[i].high; g_low[i] = r[i].low;

      g_close[i] = r[i].close; g_vol[i] = r[i].tick_volume;

   }



   PrepareCalc(total);



   int firstScan = 2 * g_rules.span + 1;

   int scanFrom = MathMax(firstScan, total - 1 - InpBars);

   int calcFrom = MathMax(0, scanFrom - g_rules.maxReach - WARMUP);



   for(int i = calcFrom; i < total; i++) {

      MacdAt(g_close, g_emaFast, g_emaSlow, g_macd, g_signal, g_hist, i, calcFrom);

      RsiAt(g_close, g_gain, g_loss, g_rsi, i, calcFrom);

      StochAt(g_high, g_low, g_close, g_rawK, g_stoch, i, calcFrom);

      g_cci[i] = CciAt(g_close, i, calcFrom);

      g_mom[i] = MomentumAt(g_close, i, calcFrom);

      g_obv[i] = ObvAt(g_close, g_vol, g_obv, i, calcFrom);

      g_vwmacd[i] = VwmacdAt(g_close, g_vol, i, calcFrom);

      g_cmf[i] = CmfAt(g_high, g_low, g_close, g_vol, i, calcFrom);

      g_mfi[i] = MfiAt(g_close, g_vol, i, calcFrom);

   }



   int firstCol = total - COLS;       // bar of column 0

   int live = COLS - 1;               // column of the current bar



   //--- pivots only matter within "bars checked back" of the first column

   int startBar = MathMax(firstScan, firstCol - g_rules.maxReach - g_rules.span - 2);



   int  sigBull[COLS], sigBear[COLS];

   bool newTop[COLS], newBot[COLS];

   for(int c = 0; c < COLS; c++) {

      sigBull[c] = 0; sigBear[c] = 0;

      newTop[c] = false; newBot[c] = false;

   }



   Pivots pv;

   pv.highs.count = 0;

   pv.lows.count = 0;



   //--- closed bars, in order, with the pivots known on each bar

   for(int bar = startBar; bar <= total - 2; bar++) {

      bool nt = false, nb = false;

      TrackPivots(pv, bar, nt, nb);

      if(bar >= firstCol) {

         int bCnt = 0, eCnt = 0;

         CountBar(bar, pv, bCnt, eCnt);

         int col = bar - firstCol;

         sigBull[col] = bCnt;

         sigBear[col] = eCnt;

         newTop[col] = nt;

         newBot[col] = nb;

      }

   }



   //--- current bar: what the chart indicator would draw if the bar closed now

   Pivots pvLive = pv;

   bool lt = false, lb = false;

   TrackPivots(pvLive, total - 1, lt, lb);

   int liveBull = 0, liveBear = 0;

   CountBar(total - 1, pvLive, liveBull, liveBear);

   sigBull[live] = liveBull;

   sigBear[live] = liveBear;

   newTop[live] = lt;

   newBot[live] = lb;



   //--- closed columns show only the signals that survive the replacement rule.

   //--- With confirmation on, the bar in progress does not replace anything yet.

   int lastCol = g_rules.liveBar ? live : live - 1;

   for(int c = 0; c < live; c++) {

      bulls[c] = (sigBull[c] > 0 && !Replaced(sigBull, newBot, c, lastCol)) ? sigBull[c] : 0;

      bears[c] = (sigBear[c] > 0 && !Replaced(sigBear, newTop, c, lastCol)) ? sigBear[c] : 0;

   }

   bulls[live] = sigBull[live];

   bears[live] = sigBear[live];



   return(true);

}



//+------------------------------------------------------------------+

//| UI                                                               |

//+------------------------------------------------------------------+

int LabelWidth() { return(30); }

int RowStep() { return(InpSquare + 6); }

int ColW() { return(SLOTS * (InpSquare + InpGap) - InpGap); }

int ColumnX(const int col) { return(InpX + PAD + LabelWidth() + col * (ColW() + COL_GAP)); }

int RowY(const int row) { return(InpY + 42 + row * RowStep()); }

int PanelW() { return(PAD + LabelWidth() + COLS * ColW() + (COLS-1) * COL_GAP + PAD); }

int PanelH() { return(42 + TFS * RowStep() + PAD - 2); }



string SquareName(const int t, const int col, const int k) {

   return(TAG + "S" + IntegerToString(t) + "_" + IntegerToString(col) + "_" + IntegerToString(k));

}



void MakeLabel(const string name, const int x, const int y, const string text, const color clr, const int size, const string font) {

   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);

   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);

   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);

   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);

   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);

   ObjectSetString(0, name, OBJPROP_TEXT, text);

   ObjectSetString(0, name, OBJPROP_FONT, font);

   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);

   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);

   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);

   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);

}



void MakeRect(const string name, const int x, const int y, const int w, const int h, const color fill, const color edge) {

   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);

   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);

   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);

   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);

   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);

   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);

   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);

   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, fill);

   ObjectSetInteger(0, name, OBJPROP_COLOR, edge);

   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);

   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);

}



void BuildPanel() {

   if(InpShowBg) {

      MakeRect(TAG + "BG", InpX, InpY, PanelW(), PanelH(), InpBgColor, InpBorderColor);

      MakeRect(TAG + "HL", InpX + PAD, InpY + 37, PanelW() - 2*PAD, 1, InpBorderColor, InpBorderColor);

      for(int t = 0; t < TFS; t += 2)

         MakeRect(TAG + "ST" + IntegerToString(t), InpX + 2, RowY(t) - 3, PanelW() - 4, RowStep(), InpStripeColor, InpStripeColor);

   }



   MakeLabel(TAG + "TT", InpX + PAD, InpY + 6, "DIVERGENCIAS", InpTitleColor, InpFontSize + 1, "Arial Bold");



   for(int c = 0; c < COLS; c++) {

      if(c == COLS-1)

         MakeLabel(TAG + "HC" + IntegerToString(c), ColumnX(c), InpY + 22, "Atual", InpAccentColor, InpFontSize-1, "Arial");

      else

         MakeLabel(TAG + "HC" + IntegerToString(c), ColumnX(c), InpY + 22, "Barra -" + IntegerToString(COLS-1-c), InpTextColor, InpFontSize-1, "Arial");

   }



   for(int t = 0; t < TFS; t++) {

      bool mine = (g_tfs[t] == _Period);

      MakeLabel(TAG + "T" + IntegerToString(t), InpX + PAD, RowY(t) - 2, g_tfNames[t],

                mine ? InpAccentColor : InpTextColor, InpFontSize, mine ? "Arial Bold" : "Arial");

      for(int col = 0; col < COLS; col++)

         for(int k = 0; k < SLOTS; k++) {

            string name = SquareName(t, col, k);

            MakeRect(name, ColumnX(col) + k * (InpSquare + InpGap), RowY(t), InpSquare, InpSquare, InpEmptyColor, InpEmptyColor);

            ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, InpEmptySlots ? OBJ_ALL_PERIODS : OBJ_NO_PERIODS);

            g_state[t][col][k] = 0;

         }

   }

}



void DrawCell(const int t, const int col, const int bulls, const int bears) {

   for(int k = 0; k < SLOTS; k++) {

      int state = 0;

      if(k < bulls) state = 1;

      else if(k < bulls + bears) state = 2;



      if(g_state[t][col][k] == state) continue;

      g_state[t][col][k] = state;



      string name = SquareName(t, col, k);

      color tint = (state == 1) ? InpBullColor : (state == 2 ? InpBearColor : InpEmptyColor);

      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, tint);

      ObjectSetInteger(0, name, OBJPROP_COLOR, tint);

      ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, (state == 0 && !InpEmptySlots) ? OBJ_NO_PERIODS : OBJ_ALL_PERIODS);

   }

}



void UpdatePanel() {

   g_pending = false;

   int bulls[COLS], bears[COLS];



   for(int t = 0; t < TFS; t++) {

      if(!Analyze(g_tfs[t], bulls, bears)) {

         g_pending = true;

         continue;

      }

      for(int c = 0; c < COLS; c++)

         DrawCell(t, c, bulls[c], bears[c]);

   }

   ChartRedraw(0);

}



int OnInit() {

   if(InpSpan < 1 || InpSpan > 50 || InpMaxPivots < 1 || InpMaxPivots > PIVOT_SLOTS ||

      InpMaxReach < 30 || InpMaxReach > 200 || InpBars < 300 || InpBars > 5000 ||

      InpMinCount < 1 || InpMinCount > OSCILLATORS || InpSquare < 4 || InpGap < 0) {

      Print("Out of range parameters");

      return(INIT_PARAMETERS_INCORRECT);

   }



   g_rules.span = InpSpan;

   g_rules.wicks = (InpSource == PIVOT_WICKS);

   g_rules.regular = (InpKinds != KINDS_HIDDEN);

   g_rules.hidden = (InpKinds != KINDS_REGULAR);

   g_rules.maxPivots = InpMaxPivots;

   g_rules.maxReach = InpMaxReach;

   g_rules.liveBar = !InpConfirm;

   g_rules.lastOnly = InpLastOnly;

   g_rules.minCount = InpMinCount;



   g_rules.enabled[0] = InpUseMacd;

   g_rules.enabled[1] = InpUseHist;

   g_rules.enabled[2] = InpUseRsi;

   g_rules.enabled[3] = InpUseStoch;

   g_rules.enabled[4] = InpUseCci;

   g_rules.enabled[5] = InpUseMom;

   g_rules.enabled[6] = InpUseObv;

   g_rules.enabled[7] = InpUseVwmacd;

   g_rules.enabled[8] = InpUseCmf;

   g_rules.enabled[9] = InpUseMfi;



   IndicatorShortName("Divergence Panel 6");

   ObjectsDeleteAll(0, TAG);

   BuildPanel();

   EventSetTimer(2);



   return(INIT_SUCCEEDED);

}



void OnDeinit(const int reason) {

   EventKillTimer();

   ObjectsDeleteAll(0, TAG);

   ChartRedraw(0);

}



void OnTimer() {

   if(g_pending) UpdatePanel();

}



int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],

                const double &open[], const double &high[], const double &low[],

                const double &close[], const long &tick_volume[], const long &volume[],

                const int &spread[]) {

   UpdatePanel();

   return(rates_total);

}