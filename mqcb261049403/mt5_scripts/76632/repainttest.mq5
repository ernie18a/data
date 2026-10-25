//+------------------------------------------------------------------+
//|                                                  RepaintTest.mq5 |
//|                                      Copyright 2026, Yogesswarah |
//|                        https://www.mql5.com/en/users/yogesswarah |
//+------------------------------------------------------------------+
//| Measures whether a drawing indicator repaints, instead of         |
//| asserting that it does not.                                       |
//|                                                                   |
//| THE INVARIANT                                                     |
//|                                                                   |
//| Once a bar has closed and been processed, no object the indicator |
//| has drawn on it may ever change. Not move, not recolour, not      |
//| change its text, and not disappear.                               |
//|                                                                   |
//| That is a claim which can be false, which is the point. The word  |
//| "non-repainting" in a description cannot be false, because there  |
//| is no procedure attached to it.                                   |
//|                                                                   |
//| METHOD                                                            |
//|                                                                   |
//| A custom symbol is seeded with a warm-up slice of real history,   |
//| the indicator is attached through a template, and every object it |
//| draws is recorded. More bars are appended and the chart is forced |
//| through a full recalculation, which makes the indicator rebuild   |
//| every object from scratch over a LONGER history. Each object from |
//| the earlier pass that sits on an already-closed bar is then looked|
//| up in the new pass and compared field by field. Repeat for as     |
//| many steps as asked for.                                          |
//|                                                                   |
//| A full rebuild is a harder test than an incremental tick: the     |
//| indicator has to reproduce an identical map from a longer history |
//| using different array indices, with no memory of the last pass.   |
//| That is exactly what a trader triggers by scrolling back far      |
//| enough for the terminal to fetch older bars, and it is where      |
//| index-keyed object names break.                                   |
//|                                                                   |
//| SCORING                                                           |
//|                                                                   |
//| Changes and disappearances are counted separately, and only a     |
//| CHANGE means the claim is false. Most indicators purge old        |
//| objects on purpose once a cap is exceeded, so a disappearance is  |
//| usually your own MaxObjects/HistoryBars setting rather than a     |
//| defect. Run with those caps lifted.                               |
//|                                                                   |
//| A run that compared nothing is INCONCLUSIVE, never a pass. The    |
//| most dangerous bug a harness can have is reporting success on an  |
//| empty run, because that number is the one that ends up quoted.    |
//|                                                                   |
//| USAGE                                                             |
//|                                                                   |
//| 1. Set InpPrefix to your own object prefix, and list in           |
//|    InpExclude anything that changes by design - a legend redrawn  |
//|    every tick, a countdown timer. Those are not marks. State them |
//|    here rather than hiding them.                                  |
//| 2. Attach your indicator to a chart with every drawing cap lifted |
//|    and save that chart as a template; point InpTemplate at it.    |
//| 3. Raise InpSettleMs until the mark count on the first pass stops |
//|    changing between runs. Too short does not produce errors, it   |
//|    produces phantom disappearances.                               |
//| 4. Break something on purpose once - shift one object by a bar -  |
//|    and confirm this reports it. A harness you have never seen     |
//|    fail is not yet evidence.                                      |
//|                                                                   |
//| Output: a per-step CSV in MQL5\Files plus a summary in the log.   |
//| Quote the CSV's marks_compared column, summed. That number is     |
//| "invariant checks", not "bars verified" - they differ by an order |
//| of magnitude and only one of them is what you measured.           |
//+------------------------------------------------------------------+
#property copyright "Yogesswarah"
#property link      "https://www.mql5.com/en/users/yogesswarah"
#property version   "1.00"
#property script_show_inputs
#property description "Measures whether a drawing indicator repaints. Research tool."

input string InpPrefix      = "SMC_";          // Object name prefix to test
input string InpExclude     = "SMC_LEG_,SMC_TIMER"; // Excluded, comma separated
input string InpSymbols     = "EURUSD,XAUUSD,GBPUSD,USDJPY"; // Symbols
input string InpPeriods     = "M15,H1,H4";     // Timeframes
input int    InpTotalBars   = 1500;            // Bars of history to pull
input int    InpWarmup      = 600;             // Bars visible in the first pass
input int    InpSteps       = 20;              // How many times to extend
input int    InpStepBars    = 25;              // Bars added per step
input string InpTemplate    = "repaint_test.tpl";   // Template that attaches it
input string InpCustomPfx   = "RPT_";          // Custom symbol name prefix
input string InpReport      = "repaint_report.csv"; // Report file
input int    InpSettleMs    = 3200;            // Wait for a full recalculation

//--- one recorded object
struct Mark
{
   string   name;
   datetime t1;
   datetime t2;
   double   p1;
   double   p2;
   long     clr;
   string   text;
};

Mark   g_prev[];
string g_exclude[];
int    g_excludeCount = 0;
int    g_prevCount    = 0;
long   g_checks       = 0;
long   g_changed      = 0;   // moved, recoloured or retimed -- repaint
long   g_vanished     = 0;   // disappeared -- purge or a sliding window
int    g_report       = INVALID_HANDLE;
string g_symbol       = "";
string g_tfName       = "";

//+------------------------------------------------------------------+
//| Everything with the prefix is a mark, except what the caller has  |
//| declared changes by design.                                       |
//+------------------------------------------------------------------+
bool IsComparableMark(const string nm)
{
   if(StringFind(nm, InpPrefix) != 0) return false;
   for(int i = 0; i < g_excludeCount; i++)
      if(StringFind(nm, g_exclude[i]) == 0) return false;
   return true;
}

//+------------------------------------------------------------------+
int Snapshot(long cid, Mark &out[])
{
   int total = ObjectsTotal(cid, -1, -1);
   ArrayResize(out, total);
   int n = 0;
   for(int i = 0; i < total; i++)
   {
      string nm = ObjectName(cid, i, -1, -1);
      if(!IsComparableMark(nm)) continue;

      out[n].name = nm;
      out[n].t1   = (datetime)ObjectGetInteger(cid, nm, OBJPROP_TIME, 0);
      out[n].t2   = (datetime)ObjectGetInteger(cid, nm, OBJPROP_TIME, 1);
      out[n].p1   = ObjectGetDouble(cid, nm, OBJPROP_PRICE, 0);
      out[n].p2   = ObjectGetDouble(cid, nm, OBJPROP_PRICE, 1);
      out[n].clr  = ObjectGetInteger(cid, nm, OBJPROP_COLOR);
      out[n].text = ObjectGetString(cid, nm, OBJPROP_TEXT);
      n++;
   }
   ArrayResize(out, n);
   return n;
}

//+------------------------------------------------------------------+
int FindByName(const Mark &arr[], const int count, const string nm)
{
   for(int i = 0; i < count; i++)
      if(arr[i].name == nm) return i;
   return -1;
}

//+------------------------------------------------------------------+
//| Return the field that moved, not a boolean. When a run fails you  |
//| want to know WHAT changed, or it costs you the afternoon.         |
//+------------------------------------------------------------------+
string DiffMark(const Mark &a, const Mark &b)
{
   if(a.t1 != b.t1)   return StringFormat("time1 %s -> %s",
                          TimeToString(a.t1), TimeToString(b.t1));
   if(a.t2 != b.t2)   return StringFormat("time2 %s -> %s",
                          TimeToString(a.t2), TimeToString(b.t2));
   if(MathAbs(a.p1 - b.p1) > _Point / 2)
      return StringFormat("price1 %.5f -> %.5f", a.p1, b.p1);
   if(MathAbs(a.p2 - b.p2) > _Point / 2)
      return StringFormat("price2 %.5f -> %.5f", a.p2, b.p2);
   if(a.clr != b.clr) return StringFormat("colour %d -> %d", a.clr, b.clr);
   if(a.text != b.text) return StringFormat("text '%s' -> '%s'", a.text, b.text);
   return "";
}

//+------------------------------------------------------------------+
//| Build the custom symbol and seed it with the warm-up slice.       |
//+------------------------------------------------------------------+
bool BuildCustomSymbol(const MqlRates &rates[], const int upto,
                       const string srcSymbol, const string custom)
{
   CustomSymbolDelete(custom);      // drop cached rates from a prior run
   ResetLastError();
   if(!CustomSymbolCreate(custom, "Custom\\RepaintTest", srcSymbol))
   {
      int err = GetLastError();
      if(err != 5304)               // 5304 = already exists, which is fine
      {
         Print("CustomSymbolCreate failed err=", err);
         return false;
      }
      ResetLastError();
   }
   CustomRatesDelete(custom, 0, D'2100.01.01');

   MqlRates seed[];
   ArrayResize(seed, upto);
   for(int i = 0; i < upto; i++) seed[i] = rates[i];

   if(CustomRatesUpdate(custom, seed) < 0)
   {
      Print("CustomRatesUpdate failed err=", GetLastError());
      return false;
   }
   if(!SymbolSelect(custom, true))
   {
      Print("SymbolSelect failed err=", GetLastError());
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Force a complete recalculation, so the indicator rebuilds every   |
//| object rather than extending what is already on the chart.        |
//+------------------------------------------------------------------+
void ForceFullRecalc(long cid, const ENUM_TIMEFRAMES tf, const string custom)
{
   ChartSetSymbolPeriod(cid, custom, tf);
   ChartRedraw(cid);
   Sleep(InpSettleMs);
}

//+------------------------------------------------------------------+
void RunOne(const string InpSrcSymbol, const ENUM_TIMEFRAMES InpTF)
{
   Print("--- ", InpSrcSymbol, " ", EnumToString(InpTF), " ---");

   g_prevCount = 0;
   ArrayFree(g_prev);

   MqlRates rates[];
   ArraySetAsSeries(rates, false);
   int got = CopyRates(InpSrcSymbol, InpTF, 0, InpTotalBars, rates);
   if(got < InpWarmup + InpSteps * InpStepBars)
   {
      Print("not enough history: got ", got, " bars, need ",
            InpWarmup + InpSteps * InpStepBars,
            ". Scroll the source chart back or lower the inputs.");
      return;
   }
   Print("  source: ", got, " bars");

   string custom = InpCustomPfx + InpSrcSymbol + "_" + g_tfName;
   if(!BuildCustomSymbol(rates, InpWarmup, InpSrcSymbol, custom)) return;

   long cid = ChartOpen(custom, InpTF);
   if(cid == 0) { Print("ChartOpen failed err=", GetLastError()); return; }
   if(!ChartApplyTemplate(cid, InpTemplate))
   {
      Print("ChartApplyTemplate failed err=", GetLastError(),
            " -- is ", InpTemplate, " in MQL5\\Profiles\\Templates?");
      ChartClose(cid);
      return;
   }
   Sleep(InpSettleMs);

   g_prevCount = Snapshot(cid, g_prev);
   datetime prevLastClosed = rates[InpWarmup - 2].time;
   Print("  pass 0: ", InpWarmup, " bars, ", g_prevCount, " marks recorded");
   if(g_prevCount == 0)
   {
      Print("  ABORT: no marks on the first pass -- the indicator did not attach"
            " or did not draw. This run contributes nothing and must not be counted.");
      ChartClose(cid);
      return;
   }

   for(int step = 1; step <= InpSteps; step++)
   {
      int upto = InpWarmup + step * InpStepBars;
      if(upto > got) break;

      MqlRates add[];
      ArrayResize(add, InpStepBars);
      for(int i = 0; i < InpStepBars; i++) add[i] = rates[upto - InpStepBars + i];
      if(CustomRatesUpdate(custom, add) < 0)
      {
         Print("  step ", step, ": CustomRatesUpdate failed err=", GetLastError());
         break;
      }

      ForceFullRecalc(cid, InpTF, custom);

      Mark now[];
      int nowCount = Snapshot(cid, now);

      int compared = 0, changed = 0, vanished = 0;
      string firstDetail = "";
      for(int i = 0; i < g_prevCount; i++)
      {
         // Only marks that sat on an already-closed bar in the earlier pass are
         // bound by the invariant. A mark on the bar that was still forming is
         // allowed to settle.
         if(g_prev[i].t1 > prevLastClosed) continue;

         compared++;
         int j = FindByName(now, nowCount, g_prev[i].name);
         if(j < 0)
         {
            vanished++;
            if(firstDetail == "") firstDetail = "vanished: " + g_prev[i].name;
            continue;
         }
         string d = DiffMark(g_prev[i], now[j]);
         if(d != "")
         {
            changed++;
            // A change outranks a vanish in the report: it is the one that means
            // the claim is false.
            if(firstDetail == "" || StringFind(firstDetail, "vanished:") == 0)
               firstDetail = g_prev[i].name + " " + d;
         }
      }

      g_checks   += compared;
      g_changed  += changed;
      g_vanished += vanished;

      Print("  step ", step, ": ", upto, " bars, ", nowCount, " marks, ",
            compared, " compared, ", changed, " changed, ", vanished, " vanished",
            (firstDetail == "" ? "" : "  first: " + firstDetail));

      if(g_report != INVALID_HANDLE)
         FileWrite(g_report, g_symbol, g_tfName, IntegerToString(step),
                   IntegerToString(upto), IntegerToString(g_prevCount),
                   IntegerToString(compared), IntegerToString(changed),
                   IntegerToString(vanished), firstDetail);

      ArrayResize(g_prev, nowCount);
      for(int i = 0; i < nowCount; i++) g_prev[i] = now[i];
      g_prevCount = nowCount;
      prevLastClosed = rates[upto - 2].time;
   }

   ChartClose(cid);
}

//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TfFromString(const string t)
{
   if(t == "M1")  return PERIOD_M1;
   if(t == "M5")  return PERIOD_M5;
   if(t == "M15") return PERIOD_M15;
   if(t == "M30") return PERIOD_M30;
   if(t == "H1")  return PERIOD_H1;
   if(t == "H4")  return PERIOD_H4;
   if(t == "D1")  return PERIOD_D1;
   return PERIOD_CURRENT;
}

//+------------------------------------------------------------------+
void OnStart()
{
   Print("Repaint test: an object on a closed bar never changes once drawn");

   g_excludeCount = StringSplit(InpExclude, ',', g_exclude);
   for(int i = 0; i < g_excludeCount; i++)
   {
      StringTrimLeft(g_exclude[i]);
      StringTrimRight(g_exclude[i]);
   }

   g_report = FileOpen(InpReport, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
   if(g_report != INVALID_HANDLE)
      FileWrite(g_report, "symbol", "timeframe", "step", "bars_visible",
                "marks_carried", "marks_compared", "changed", "vanished", "detail");

   string syms[], tfs[];
   int ns = StringSplit(InpSymbols, ',', syms);
   int nt = StringSplit(InpPeriods, ',', tfs);
   int combos = 0;

   for(int a = 0; a < ns; a++)
   {
      string sym = syms[a];
      StringTrimLeft(sym); StringTrimRight(sym);
      if(!SymbolSelect(sym, true))
      {
         Print("--- ", sym, ": not available, skipped");
         continue;
      }
      for(int b = 0; b < nt; b++)
      {
         string tfName = tfs[b];
         StringTrimLeft(tfName); StringTrimRight(tfName);
         ENUM_TIMEFRAMES tf = TfFromString(tfName);
         if(tf == PERIOD_CURRENT) continue;
         g_symbol = sym; g_tfName = tfName;
         RunOne(sym, tf);
         combos++;
      }
   }

   if(g_report != INVALID_HANDLE) FileClose(g_report);

   Print("=====================================================");
   Print("  symbol/timeframe combinations: ", combos);
   Print("  invariant checks: ", g_checks);
   Print("  changed:          ", g_changed, "   <- this is what repaint means");
   Print("  vanished:         ", g_vanished, "   <- purge / window, not repaint");
   // A run that compared nothing is not a pass. Reporting PASS off changed == 0
   // alone means a run where every combination aborted with no marks reports
   // PASS on zero checks -- a claim with nothing behind it, and exactly the
   // number that ends up in a listing.
   if(g_checks == 0)
      Print("  INCONCLUSIVE - zero invariant checks. Nothing was compared, so this"
            " run proves nothing and must not be quoted. Check the ABORT lines above:"
            " the indicator did not attach or did not draw.");
   else if(g_changed == 0)
      Print("  PASS - no mark on a closed bar ever moved, recoloured or retimed");
   else
      Print("  FAIL - marks changed after their bar closed; see the report");
   if(g_vanished > 0)
      Print("  note: with your drawing caps lifted, a vanish is still a defect -"
            " it means a mark was not reproduced from a longer history");
   Print("  report: MQL5\\Files\\", InpReport);
   Print("=====================================================");
}
//+------------------------------------------------------------------+
