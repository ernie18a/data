# Signal Edge Tester - Backtest Any Indicator vs Random [Zofesu]

- url: https://www.tradingview.com/script/jd1xP1Pg-Signal-Edge-Tester-Backtest-Any-Indicator-vs-Random-Zofesu/
- type: indicator
- pine_id: PUB;b82bb99f77e341b08958721e6e36a086
- version: 1.0

## Description

[b]Signal Edge Tester - Backtest Any Indicator vs Random [Zofesu][/b] is an overlay tool that takes a signal from any indicator on your chart and tests it against random chance on the same instrument, the same timeframe and the same history.
 
It answers two separate questions. Does the signal beat random entries — is there skill? And does it make money after costs — is it tradable? A signal can have one without the other, and the tool tells you which.
 
The statistics are not new, and it is worth being clear about that. Judging a trading rule against random entries rather than against zero is an established idea in evidence-based technical analysis, and shifting a signal through time to build a null distribution is a standard permutation technique. The original part of this script is how these pieces are put together for everyday use: a universal signal input, a baseline that takes a trade from every bar, a correction for clustered signals, a locked out-of-sample test with an embargo, and a verdict that separates skill from trend-driven profit.
 
It places no trades, gives no signals and predicts nothing. It measures what a signal would have done on the history in front of you.
 
─────────────────────────────────────
[b]01 — What is Signal Edge Tester?[/b]
─────────────────────────────────────
Most indicators show where a signal fired. Very few show whether that signal was better than entering at a random bar.
 
This tool reads the output of another indicator, turns each signal into a trade with a fixed and pre-defined exit, and compares the average result with what the same trade would have produced from every bar in the sample. It then shifts the whole signal pattern through time many times to measure how large a difference luck alone can produce.
 
The result is a table with the numbers behind the test and a plain-word verdict in the last row.
 
─────────────────────────────────────
[b]02 — Connecting a Signal[/b]
─────────────────────────────────────
The signal is connected through the source inputs. The tool can read:
 
[list][*]an arrow or marker drawn with plotshape (read as 1 when present, 0 when not)
[*]a state series or a ±1 series
[*]an alert condition
[*]an oscillator, together with a level (for example RSI and 30)
[*]a moving level such as VWAP, a moving average or a value area boundary[/list]
 
[b]Triggers[/b] define WHEN the signal is active, not its direction. Direction is set by where you connect the source: the LONG section or the SHORT section.
 
[b]Value > 0[/b] — arrows, markers and states. Also used for SHORT when the source is an arrow.
[b]Value < 0[/b] — only for a ±1 series where −1 means short.
[b]Crosses above / below level[/b] — oscillators with a fixed level.
[b]Close crosses source up / down[/b] — moving levels. The source is the level itself.
 
An entry is created only when the state changes from inactive to active. A condition that stays true for ten bars produces one entry, not ten.
 
─────────────────────────────────────
[b]03 — How a Trade Is Measured[/b]
─────────────────────────────────────
Entry is always the open of the bar AFTER the signal bar. The signal bar is closed before anything is taken, so no information from inside that bar is used.
 
[b]Mode A — Horizon[/b]
The trade closes at the close of the H-th bar from entry. Simple and neutral: it measures where price went, without any target logic.
 
[b]Mode B — ATR take-profit / stop-loss[/b]
Take-profit and stop-loss are set in ATR multiples, using the ATR of the signal bar. If neither is reached, the trade closes after the maximum holding period. Two conservative rules apply:
[list][*]if one bar touches both take-profit and stop-loss, the stop-loss is counted
[*]a gap through the stop-loss exits at the open, not at the stop price[/list]
 
[b]Costs[/b] are subtracted per round trip (entry and exit together), as a percentage of price or in price units. Swaps and overnight financing are not included.
 
Choose the exit mode BEFORE you look at results. Trying several modes and keeping the best one produces false success.
 
─────────────────────────────────────
[b]04 — The Random Baseline[/b]
─────────────────────────────────────
The baseline takes exactly the same trade — same entry rule, same exit, same costs — from every single bar in the sample. This is the exact limit of infinitely many random entries, so it has no random noise of its own and gives the same answer every time.
 
[b]Baseline filter[/b]
Some signals only fire in a particular regime, for example only above a 200-period moving average. Comparing them with every bar would let the regime itself look like signal skill. With the filter on, the baseline takes entries only from bars where the filter is active, so the signal is compared with random entries in the same regime.
 
Signals that fire outside the filter are excluded from the test, because the baseline contains no comparable bars for them. The table states this whenever the filter is on, and the entry markers on the chart show only the signals that were actually tested.
 
─────────────────────────────────────
[b]05 — Cluster Correction[/b]
─────────────────────────────────────
Signals rarely arrive one by one. They come in bursts, and trades that overlap in time share the same price move. Counting them as independent pieces of evidence makes any result look more certain than it is.
 
To handle this, the whole signal pattern is shifted through time — up to 5,000 times — keeping the exact spacing between signals. Each shifted copy gives an average result, and the spread of those results is the band of luck for this particular signal.
 
[b]Percentile vs random[/b] — the share of shifted copies that did worse than the real signal. 50 means the signal is indistinguishable from random placement.
 
[b]Effective N[/b] — the number of trades after removing the effect of clustering. If signals are spread out, Effective N equals N. If they cluster, it drops.
 
With many signals the number of shifts is reduced automatically so the script stays inside the platform's loop time limit.
 
─────────────────────────────────────
[b]06 — In-Sample and Out-of-Sample[/b]
─────────────────────────────────────
The history is split into two parts.
 
[b]In-sample (IS)[/b] — used for tuning the signal. Its column is diagnostic only.
[b]Out-of-sample (OOS)[/b] — the final test. Only this column gives the verdict.
 
The OOS column is locked by default. Unlock it only when your settings are final. Once you have seen the OOS result and change anything, the OOS has effectively become in-sample and the verdict has lost its value.
 
[b]Embargo[/b] — an in-sample trade is not allowed to end inside the out-of-sample part, so no price move is shared between the two.
 
[b]Threshold[/b] — 95 when one direction is tested, 97.5 when both LONG and SHORT are tested, because two tests double the chance of a lucky result.
 
─────────────────────────────────────
[b]07 — The Verdict[/b]
─────────────────────────────────────
[b]PASSED[/b] — the signal beats random entries, its result after costs is positive beyond the band of luck, and the excess over random alone covers the costs.
 
[b]PASSED · trend-assisted[/b] — the signal beats random and is profitable after costs, but the excess over random alone does not cover the costs. Part of the profit comes from the instrument's overall direction during the sample.
 
[b]INCONCLUSIVE · edge without profit[/b] — the signal beats random, but the result after costs is not reliably positive.
 
[b]INCONCLUSIVE · profit from trend only[/b] — the result after costs is positive, but random entries would have done about as well.
 
[b]INCONCLUSIVE · too little evidence[/b] — Effective N is below the minimum. No conclusion is possible.
 
[b]INCONCLUSIVE[/b] — no statistically meaningful difference in either direction.
 
[b]FALSIFIED · worse than random[/b] — the signal did significantly worse than random entries.
 
[b]FALSIFIED · certain loss[/b] — the result after costs is negative beyond the band of luck.
 
─────────────────────────────────────
[b]08 — Reading the Table[/b]
─────────────────────────────────────
All results are shown as a percentage of the entry price, per trade.
 
[b]Trades (N)[/b] — number of tested signal trades.
[b]Effective N (declustered)[/b] — see section 05.
[b]Signal avg % (gross)[/b] — average signal trade before costs.
[b]Random avg %[/b] — average baseline trade before costs.
[b]Percentile vs random[/b] — see section 05.
[b]Net avg % (after costs)[/b] — average signal trade after costs.
[b]Net interval %[/b] — the band of luck around the net result.
[b]Excess after costs % (no trend)[/b] — signal minus random minus costs, with its band. This is what the signal would earn in a market with no overall direction.
[b]Verdict[/b] — see section 07.
 
The rows below the verdict show the exit mode, the OOS start date, the costs and the baseline type, so a screenshot of the table is a complete record of the test.
 
─────────────────────────────────────
[b]09 — Settings[/b]
─────────────────────────────────────
[b]LONG / SHORT signal[/b]
Test switch, source, trigger and level for each direction. Default: LONG on, SHORT off.
 
[b]Baseline filter[/b] — default off
Filter source and the condition under which a bar belongs to the baseline: Close above / below source, Value > 0 / < 0. Evaluated on the signal bar.
 
[b]Trade exit[/b]
Primary mode — default A · Horizon
A · Horizon — default 10 bars
B · ATR length — default 14
B · TP × ATR — default 2.0
B · SL × ATR — default 1.0
B · Max holding — default 50 bars
 
[b]Costs[/b]
Unit — default % of price
Cost per round trip — default 0.02
Rough guide: forex and indices 0.01–0.02, gold and oil 0.02–0.04, stocks 0.03–0.05, crypto 0.08–0.15.
 
[b]In-sample / Out-of-sample[/b]
OOS boundary — default Last X %
OOS = last X % — default 30
OOS start — used with Fixed date. If the date lies outside the loaded history, Last X % is used and the table shows a warning.
Auto data start from source — default on. Counting starts at the first bar where the signal source has a value, which handles indicators with limited history.
Limit data start — default on, from 1929-01-01. Excludes early history with poor data, such as SPX before 1928 with only a few bars per year. On any history that starts after 1929 it has no effect.
Unlock OOS — default off.
 
[b]Statistics[/b]
Shifts — default 1000
Min. effective trades — default 30
 
[b]Table[/b]
Position, text size, entry markers and OOS boundary line.
 
─────────────────────────────────────
[b]10 — How To Use[/b]
─────────────────────────────────────
[b]Step 1 — Add the indicator you want to test[/b]
Both scripts must be on the same chart. The signal must be a plot or an alert condition.
 
[b]Step 2 — Connect the source and choose the trigger[/b]
Check the triangles on the chart: each one must sit on the bar right after your signal. If they do not, the trigger is wrong.
 
[b]Step 3 — Fix the exit mode and costs before looking at results[/b]
Decide how the trade is closed and what it costs on your broker, then leave it.
 
[b]Step 4 — Tune on in-sample only[/b]
Adjust your signal while the OOS column is locked. If the regime matters, turn on the baseline filter.
 
[b]Step 5 — Unlock the OOS once[/b]
When the settings are final, unlock the OOS and read the verdict row. That is the result.
 
[b]Step 6 — Repeat per instrument and timeframe[/b]
A verdict describes one instrument on one timeframe. A PASSED on one symbol says nothing about another.
 
[b]Step 7 — Switching to another indicator[/b]
While a source is connected, the tester is linked to that indicator. If you remove the indicator from the chart, the tester is removed with it. To test something else, first connect the tester to the new indicator, or press Reset settings in the tester. Only then remove the old indicator.
 
─────────────────────────────────────
[b]11 — Limitations[/b]
─────────────────────────────────────
[list][*]Only plots and alert conditions are readable. Lines, boxes and labels drawn by another script are invisible to it.
[*]It cannot see inside another script. If the tested indicator repaints or uses future data, the verdict inherits that error.
[*]Swaps and overnight financing are not included.
[*]The statistics are built from the history your chart has loaded. Two users on the same symbol can see different numbers if one has scrolled back further.
[*]The verdict is a measurement of the past, not a forecast, and it is not a promise of future results.[/list]
 
[b]The publication chart[/b] shows the tester on SPX D1, connected to the built-in RSI with length 2 and testing RSI crossing below 10 as a LONG signal. The lower band of the RSI is moved to 10 so the tested level is visible. Exit and cost settings are the defaults. Two inputs differ from the defaults, because the tool cannot show anything without them: the signal source, trigger and level are connected to the RSI, and the out-of-sample column is unlocked so both columns are visible. In your own use, keep the OOS locked until your settings are final.
 
The chart is also a lesson in itself. The same signal is worse than random in the in-sample years (1929–1997) and passes in the out-of-sample years (1997 onward). A verdict belongs to one instrument and one period, not to the signal forever.
 
Works on all asset classes: Indices, Forex, Gold, Oil, Stocks, Crypto.
Works on all timeframes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Since 2020 Zofesu - SIGNAL EDGE TESTER v1.0
// ═══════════════════════════════════════════════════════════════════
// Tests ANY indicator signal against random chance on the same instrument.
//
// HOW IT WORKS
// • Connect a signal from any indicator on the chart through the source
//   inputs (a plotshape arrow, a state series, a ±1 series, an alert
//   condition, an oscillator or a moving level).
// • Entry = open of the bar AFTER the signal bar, exit by a fixed horizon
//   or by ATR take-profit / stop-loss. The baseline takes the same trade
//   from EVERY bar — the exact limit of infinitely many random entries.
// • Cluster correction: the whole signal is shifted through time and the
//   spread of those shifted results sets the band of luck. Clustered,
//   overlapping trades are not counted as independent evidence.
// • Two questions per verdict: does the signal beat random (skill), and
//   does it make money after costs (tradability) — including whether the
//   excess over random alone covers the costs, i.e. without trend help.
// • Only the out-of-sample part gives the verdict. In-sample is diagnostic.
//
// HARD LIMITS
// • Reads plots and alert conditions only — lines, boxes and labels are
//   invisible to it.
// • It cannot see inside another script: if that script repaints or uses
//   future data, the verdict inherits the error.
// • Swaps / overnight financing are not included.
// ═══════════════════════════════════════════════════════════════════
//@version=6
indicator("Signal Edge Tester - Backtest Any Indicator vs Random [Zofesu]", shorttitle = "[Zofesu] Signal Edge Tester", overlay = true, max_bars_back = 500)

// ═════════════════════ INPUTS ═════════════════════
grpL  = "① LONG signal"
useL  = input.bool(true, "Test LONG", group = grpL, tooltip = "Turn on to test buy signals.")
srcL  = input.source(close, "LONG source", group = grpL, tooltip = "Pick the indicator output: an arrow (plotshape), a state or a ±1 series. It must be a plot or an alert condition — lines, boxes and labels are not visible to the validator.")
trigL = input.string("Value > 0", "LONG trigger", options = ["Value > 0", "Value < 0", "Crosses above level", "Crosses below level", "Close crosses source up", "Close crosses source down"], group = grpL, tooltip = "WHEN the signal is active — not its direction. Direction is set by putting the source into LONG or SHORT. Arrow, level or price (always positive) → Value > 0, also for SHORT. Value < 0 only for a ±1 series where −1 = short. Moving level (VAH, VAL, VWAP, MA) → source = that level and 'Close crosses source up/down'. An entry is created only when the state changes from inactive to active.")
lvlL  = input.float(0.0, "LONG level", group = grpL, tooltip = "Used only with the level crossing triggers (e.g. RSI below 30).")

grpS  = "② SHORT signal"
useS  = input.bool(false, "Test SHORT", group = grpS, tooltip = "Turn on to test sell signals. With both directions on, the threshold tightens to 97.5 (two tests = twice the chance of luck).")
srcS  = input.source(close, "SHORT source", group = grpS, tooltip = "For an indicator with a single ±1 series, use the same series here with trigger 'Value < 0'.")
trigS = input.string("Value > 0", "SHORT trigger", options = ["Value > 0", "Value < 0", "Crosses above level", "Crosses below level", "Close crosses source up", "Close crosses source down"], group = grpS, tooltip = "WHEN the signal is active — not its direction. Direction is set by putting the source into LONG or SHORT. Arrow, level or price (always positive) → Value > 0, also for SHORT. Value < 0 only for a ±1 series where −1 = short. Moving level (VAH, VAL, VWAP, MA) → source = that level and 'Close crosses source up/down'. An entry is created only when the state changes from inactive to active.")
lvlS  = input.float(0.0, "SHORT level", group = grpS, tooltip = "Used only with the level crossing triggers (e.g. RSI above 70).")

grpF  = "②b Baseline filter"
useF  = input.bool(false, "Use baseline filter", group = grpF, tooltip = "Random entries are taken only from bars where the filter is active — the same regime as the signal. Example: the signal only fires above SMA200 → filter = Close above SMA200. Without it, a trend regime can look like signal skill.")
srcF  = input.source(close, "Filter source", group = grpF, tooltip = "E.g. an SMA200 plotted by another indicator.")
trigF = input.string("Close above source", "Filter active when", options = ["Close above source", "Close below source", "Value > 0", "Value < 0"], group = grpF, tooltip = "State on the signal bar (the bar before entry).")

grpX     = "③ Trade exit (entry = open of the next bar)"
exitMode = input.string("A · Horizon", "Primary mode", options = ["A · Horizon", "B · ATR TP/SL"], group = grpX, tooltip = "The verdict applies to this mode only. Choose it BEFORE looking at results — trying several modes and keeping the best one = false success.")
H        = input.int(10, "A · Horizon (bars)", minval = 1, maxval = 200, group = grpX, tooltip = "The trade closes at the close of the H-th bar from entry.")
atrLen   = input.int(14, "B · ATR length", minval = 1, group = grpX, tooltip = "ATR sets the distance of TP and SL. It is taken from the signal bar, so the trade never uses future volatility.")
tpM      = input.float(2.0, "B · TP × ATR", minval = 0.1, step = 0.1, group = grpX, tooltip = "Take-profit distance from entry in ATR multiples. 2.0 = two ATRs away.")
slM      = input.float(1.0, "B · SL × ATR", minval = 0.1, step = 0.1, group = grpX, tooltip = "If one bar hits both TP and SL, SL is counted (conservative). A gap through SL exits at the open.")
maxHold  = input.int(50, "B · Max holding (bars)", minval = 1, maxval = 200, group = grpX, tooltip = "If neither TP nor SL is hit, the trade closes at the close of this bar.")

grpC     = "④ Costs"
costUnit = input.string("% of price", "Unit", options = ["% of price", "Price"], group = grpC, tooltip = "% of price works on every instrument and on long histories. Use Price only when you know the spread in points exactly and the history is short.")
costVal  = input.float(0.02, "Cost per round trip", minval = 0.0, step = 0.01, group = grpC, tooltip = "Spread + slippage for entry AND exit together, in %. Rough guide: forex/indices 0.01–0.02 · gold/oil 0.02–0.04 · stocks 0.03–0.05 · crypto 0.08–0.15. Swaps are not included — account for them yourself.")

grpO   = "⑤ In-sample / Out-of-sample"
oosMode = input.string("Last X %", "OOS boundary", options = ["Last X %", "Fixed date"], group = grpO, tooltip = "Last X % suits any instrument and timeframe. Use Fixed date to lock the split — percentages shift slightly as new bars arrive.")
oosPct  = input.float(30.0, "OOS = last X %", minval = 10.0, maxval = 50.0, step = 5.0, group = grpO, tooltip = "Share of history kept aside for the final test. 30 % = the last 30 % of bars is the OOS, everything before it is the IS.")
oosT   = input.time(timestamp("2025-01-01T00:00:00"), "OOS start", group = grpO, tooltip = "Tune before this date (IS), test from it (OOS). If the date is outside the history, Last X % is used.")
autoStart = input.bool(true, "Auto data start from source", group = grpO, tooltip = "Counting starts at the first bar where the signal source has a value (not ∅). Handles indicators with limited history — e.g. footprint data only from 2022. Arrows and oscillators are unaffected. If a manual start is also on, the later one applies.")
useStart = input.bool(true, "Limit data start", group = grpO, inline = "st")
startT = input.time(timestamp("1929-01-01T00:00:00"), "", group = grpO, inline = "st", tooltip = "Nothing before this date is used. Useful when a history starts with poor data (e.g. SPX before 1928 has only ~10 bars a year, not daily data).")
unlock = input.bool(false, "Unlock OOS — final test", group = grpO, tooltip = "Open only when the settings are final. Once you have seen the OOS and change anything, the OOS has become IS and the verdict has lost its value.")

grpT    = "⑥ Statistics"
nShift  = input.int(1000, "Shifts (cluster correction)", minval = 100, maxval = 5000, group = grpT, tooltip = "1000 is enough. With many signals it is reduced automatically so Pine stays under its 500 ms loop limit (error RE10022).")
minNeff = input.int(30, "Min. effective trades", minval = 10, group = grpT, tooltip = "Below this the verdict is always INCONCLUSIVE — too little evidence. Effective = after removing the effect of clustering.")

grpV  = "⑦ Table"
tPos  = input.string("Top right", "Position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = grpV, tooltip = "Where the results table is placed on the chart.")
tSize = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpV, tooltip = "Text size of the results table.")
showMk = input.bool(true, "Entry markers and OOS boundary", group = grpV, tooltip = "Triangles mark the entry bar of each tested signal. The blue dashed line marks where the OOS starts.")

// ═════════════════════ TRIGGERS ═════════════════════
trigger(float src, string mode, float lvl) =>
    bool xo = ta.crossover(src, lvl)
    bool xu = ta.crossunder(src, lvl)
    bool co = ta.crossover(close, src)     // price crosses a moving level
    bool cu = ta.crossunder(close, src)
    switch mode
        "Value > 0"         => src > 0
        "Value < 0"         => src < 0
        "Crosses above level" => xo
        "Close crosses source up" => co
        "Close crosses source down" => cu
        => xu

bool actL = trigger(srcL, trigL, lvlL)
bool actS = trigger(srcS, trigS, lvlS)
bool newL = actL and not actL[1]          // entry only on a change of state
bool newS = actS and not actS[1]

bool fAct = switch trigF
    "Close above source" => close > srcF
    "Close below source" => close < srcF
    "Value > 0"       => srcF > 0
    => srcF < 0

bool  isA  = exitMode == "A · Horizon"
int   hold = isA ? H : maxHold
float atr  = ta.atr(atrLen)

// ═════════════════════ STORAGE ═════════════════════
// array index = entry bar; every bar is a baseline entry
var array<float> rL = array.new<float>()   // long result (fraction of entry price), na = unresolved/excluded
var array<float> rS = array.new<float>()   // short result
var array<float> px = array.new<float>()   // entry price (open)
var array<int>   tm = array.new<int>()     // entry time
var array<int>   sL = array.new<int>()     // long signal indices
var array<int>   sS = array.new<int>()     // short signal indices
var array<bool>  fOk = array.new<bool>()   // bar belongs to the baseline (filter on the signal bar)

type Tr
    int   i
    float tpL
    float slL
    float tpS
    float slS
    bool  dL = false
    bool  dS = false

var array<Tr> openTr = array.new<Tr>()

// ═════════════════════ EVERY BAR ═════════════════════
rL.push(na)
rS.push(na)
px.push(open)
tm.push(time)
fOk.push(useF ? fAct[1] : true)
int idx = rL.size() - 1
var int firstValid = -1                    // first bar with a valid source value
if firstValid < 0 and ((useL and not na(srcL)) or (useS and not na(srcS)))
    firstValid := idx

if useL and newL[1]                        // signal on the closed bar → entry on this one
    sL.push(idx)
if useS and newS[1]
    sS.push(idx)

if isA
    int j = idx - H + 1
    if j >= 0
        float ep = px.get(j)
        rL.set(j, close / ep - 1.0)
        rS.set(j, 1.0 - close / ep)
else
    float a1 = atr[1]
    if not na(a1)
        openTr.push(Tr.new(idx, open + tpM * a1, open - slM * a1, open - tpM * a1, open + slM * a1))
    int nOpen = openTr.size()
    if nOpen > 0
        for k = nOpen - 1 to 0
            Tr t = openTr.get(k)
            float ep  = px.get(t.i)
            int   age = idx - t.i + 1
            if not t.dL
                if low <= t.slL
                    rL.set(t.i, math.min(open, t.slL) / ep - 1.0)
                    t.dL := true
                else if high >= t.tpL
                    rL.set(t.i, t.tpL / ep - 1.0)
                    t.dL := true
                else if age >= maxHold
                    rL.set(t.i, close / ep - 1.0)
                    t.dL := true
            if not t.dS
                if high >= t.slS
                    rS.set(t.i, 1.0 - math.max(open, t.slS) / ep)
                    t.dS := true
                else if low <= t.tpS
                    rS.set(t.i, 1.0 - t.tpS / ep)
                    t.dS := true
                else if age >= maxHold
                    rS.set(t.i, 1.0 - close / ep)
                    t.dS := true
            if t.dL and t.dS
                openTr.remove(k)

// ═════════════════════ SEGMENT STATISTICS ═════════════════════
// Returns: [N, Neff, signal avg, random avg, percentile, net avg, lower, upper, excess after costs, its lower, upper]
evalSeg(array<float> r, array<int> sig, array<float> prices, array<bool> ok, int a, int b, int S, float z, string cu, float cv) =>
    int   N    = 0
    float Neff = na
    float mS   = na
    float mB   = na
    float pC   = na
    float net  = na
    float lo   = na
    float hi   = na
    float ex   = na
    float exLo = na
    float exHi = na
    if b > a
        array<float> v   = array.new<float>()
        array<int>   pMap = array.new<int>(b - a + 1, -1)
        for i = a to b
            float x = r.get(i)
            if not na(x) and ok.get(i)
                pMap.set(i - a, v.size())
                v.push(x)
        array<int> pos = array.new<int>()
        float costSum = 0.0
        for i in sig
            if i >= a and i <= b
                int p = pMap.get(i - a)
                if p >= 0
                    pos.push(p)
                    costSum += cu == "Price" ? cv / prices.get(i) : cv / 100.0
        int L = v.size()
        N := pos.size()
        if N >= 2 and L > N
            mB := v.avg()
            float sd = v.stdev(false)
            float s0 = 0.0
            for p in pos
                s0 += v.get(p)
            mS := s0 / N
            int Sx = math.max(100, math.min(S, int(2000000 / N)))
            array<float> sm = array.new<float>()
            int below = 0
            for jj = 1 to Sx
                int k = int(math.floor(jj * L / (Sx + 1.0)))
                if k > 0
                    float s = 0.0
                    for p in pos
                        s += v.get((p + k) % L)
                    float mm = s / N
                    sm.push(mm)
                    if mm < mS
                        below += 1
            int used = sm.size()
            if used > 0
                pC := below * 100.0 / used
                float seC = sm.stdev(false)
                float seI = sd / math.sqrt(N)
                Neff := seC > 0 ? math.min(float(N), N * math.pow(seI / seC, 2)) : float(N)
                net := mS - costSum / N
                lo  := net - z * seC
                hi  := net + z * seC
                ex   := mS - mB - costSum / N          // excess over random after costs (trendless market)
                exLo := ex - z * seC
                exHi := ex + z * seC
    [N, Neff, mS, mB, pC, net, lo, hi, ex, exLo, exHi]

// z for a one-sided test with p (Abramowitz–Stegun 26.2.23, error < 0.0005)
zOf(float p) =>
    float t = math.sqrt(-2.0 * math.log(p))
    t - (2.515517 + 0.802853 * t + 0.010328 * t * t) / (1.0 + 1.432788 * t + 0.189269 * t * t + 0.001308 * t * t * t)

verdict(float Neff, float pC, float lo, float hi, float exLo, float thrHi, float thrLo, int minN) =>
    string v = "INCONCLUSIVE"
    color  c = color.gray
    if na(pC) or na(Neff) or Neff < minN
        v := "INCONCLUSIVE · too little evidence"
    else if pC >= thrHi and lo > 0
        if exLo > 0
            v := "PASSED"
            c := color.lime
        else
            v := "PASSED · trend-assisted"
            c := color.new(#9ACD32, 0)
    else if hi < 0
        v := "FALSIFIED · certain loss"
        c := color.red
    else if pC <= thrLo
        v := "FALSIFIED · worse than random"
        c := color.red
    else if pC >= thrHi
        v := "INCONCLUSIVE · edge without profit"
        c := color.orange
    else if lo > 0
        v := "INCONCLUSIVE · profit from trend only"
        c := color.orange
    [v, c]

// ═════════════════════ TABLE ═════════════════════
posOf(string s) =>
    switch s
        "Top right" => position.top_right
        "Bottom right" => position.bottom_right
        "Top left"  => position.top_left
        => position.bottom_left

sizeOf(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"    => size.large
        => size.small

fmtP(float x) => na(x) ? "–" : str.tostring(x * 100, "0.0000")

fillCol(table tb, int c, string head, bool locked, int N, float Neff, float mS, float mB, float pC, float net, float lo, float hi, float ex, float exLo, float exHi, string v, color vc, ts) =>
    table.cell(tb, c, 0, head, text_color = color.silver, text_size = ts)
    if locked
        for r = 1 to 9
            table.cell(tb, c, r, "🔒", text_color = color.gray, text_size = ts)
    else
        table.cell(tb, c, 1, str.tostring(N), text_color = color.white, text_size = ts)
        table.cell(tb, c, 2, na(Neff) ? "–" : str.tostring(Neff, "#"), text_color = color.white, text_size = ts)
        table.cell(tb, c, 3, fmtP(mS), text_color = color.white, text_size = ts)
        table.cell(tb, c, 4, fmtP(mB), text_color = color.white, text_size = ts)
        table.cell(tb, c, 5, na(pC) ? "–" : str.tostring(pC, "#.#"), text_color = color.yellow, text_size = ts)
        table.cell(tb, c, 6, fmtP(net), text_color = color.white, text_size = ts)
        table.cell(tb, c, 7, fmtP(lo) + " … " + fmtP(hi), text_color = color.white, text_size = ts)
        table.cell(tb, c, 8, fmtP(ex) + "  (" + fmtP(exLo) + " … " + fmtP(exHi) + ")", text_color = color.white, text_size = ts)
        table.cell(tb, c, 9, v, text_color = color.black, bgcolor = vc, text_size = ts)

if barstate.islastconfirmedhistory
    int n = rL.size()
    // OOS boundary
    int startIdx = autoStart and firstValid > 0 ? firstValid : 0
    if useStart
        for i = 0 to n - 1
            if tm.get(i) >= startT
                startIdx := math.max(startIdx, i)
                break
    // OOS percentage is taken from the data after the start only
    int  pctIdx = startIdx + int((n - startIdx) * (1.0 - oosPct / 100.0))
    bool byDate = oosMode == "Fixed date"
    int  oosIdx = pctIdx
    bool fallback = false
    if byDate
        oosIdx := -1
        for i = 0 to n - 1
            if tm.get(i) >= oosT
                oosIdx := i
                break
        fallback := oosIdx < startIdx + 3 * hold or oosIdx > n - 3 * hold
        if fallback
            oosIdx := pctIdx
    if showMk
        line.new(tm.get(oosIdx), low, tm.get(oosIdx), high, xloc = xloc.bar_time, extend = extend.both, color = color.new(color.blue, 30), style = line.style_dashed, width = 1)
    int isEnd = oosIdx - hold              // embargo: an IS trade must not end inside the OOS

    bool  both  = useL and useS
    int   kTest = both ? 2 : 1
    float alpha = 0.05 / kTest
    float thrHi = 100.0 - alpha * 100.0
    float thrLo = alpha * 100.0
    float z     = zOf(alpha)

    int cols = 1 + (useL ? 2 : 0) + (useS ? 2 : 0)
    var table tb = table.new(posOf(tPos), 5, 14, bgcolor = color.new(color.black, 15), border_width = 1)
    ts = sizeOf(tSize)

    table.cell(tb, 0, 0, "Metric",                    text_color = color.silver, text_size = ts)
    table.cell(tb, 0, 1, "Trades (N)",                text_color = color.white, text_size = ts)
    table.cell(tb, 0, 2, "Effective N (declustered)", text_color = color.white, text_size = ts)
    table.cell(tb, 0, 3, "Signal avg % (gross)",      text_color = color.white, text_size = ts)
    table.cell(tb, 0, 4, "Random avg %",              text_color = color.white, text_size = ts)
    table.cell(tb, 0, 5, "Percentile vs random",      text_color = color.white, text_size = ts)
    table.cell(tb, 0, 6, "Net avg % (after costs)",   text_color = color.white, text_size = ts)
    table.cell(tb, 0, 7, "Net interval %",            text_color = color.white, text_size = ts)
    table.cell(tb, 0, 8, "Excess after costs % (no trend)", text_color = color.white, text_size = ts)
    table.cell(tb, 0, 9, "Verdict",                   text_color = color.white, text_size = ts)

    int c = 1
    if useL
        [N1, E1, m1, b1, p1, t1, l1, h1, x1, xl1, xh1] = evalSeg(rL, sL, px, fOk, startIdx, isEnd, nShift, z, costUnit, costVal)
        [v1, vc1] = verdict(E1, p1, l1, h1, xl1, thrHi, thrLo, minNeff)
        fillCol(tb, c, "LONG · IS (diagnostic)", false, N1, E1, m1, b1, p1, t1, l1, h1, x1, xl1, xh1, v1, vc1, ts)
        c += 1
        if unlock
            [N2, E2, m2, b2, p2, t2, l2, h2, x2, xl2, xh2] = evalSeg(rL, sL, px, fOk, oosIdx, n - 1, nShift, z, costUnit, costVal)
            [v2, vc2] = verdict(E2, p2, l2, h2, xl2, thrHi, thrLo, minNeff)
            fillCol(tb, c, "LONG · OOS (verdict)", false, N2, E2, m2, b2, p2, t2, l2, h2, x2, xl2, xh2, v2, vc2, ts)
        else
            fillCol(tb, c, "LONG · OOS (verdict)", true, 0, na, na, na, na, na, na, na, na, na, na, "", color.gray, ts)
        c += 1
    if useS
        [N3, E3, m3, b3, p3, t3, l3, h3, x3, xl3, xh3] = evalSeg(rS, sS, px, fOk, startIdx, isEnd, nShift, z, costUnit, costVal)
        [v3, vc3] = verdict(E3, p3, l3, h3, xl3, thrHi, thrLo, minNeff)
        fillCol(tb, c, "SHORT · IS (diagnostic)", false, N3, E3, m3, b3, p3, t3, l3, h3, x3, xl3, xh3, v3, vc3, ts)
        c += 1
        if unlock
            [N4, E4, m4, b4, p4, t4, l4, h4, x4, xl4, xh4] = evalSeg(rS, sS, px, fOk, oosIdx, n - 1, nShift, z, costUnit, costVal)
            [v4, vc4] = verdict(E4, p4, l4, h4, xl4, thrHi, thrLo, minNeff)
            fillCol(tb, c, "SHORT · OOS (verdict)", false, N4, E4, m4, b4, p4, t4, l4, h4, x4, xl4, xh4, v4, vc4, ts)
        else
            fillCol(tb, c, "SHORT · OOS (verdict)", true, 0, na, na, na, na, na, na, na, na, na, na, "", color.gray, ts)

    string modeTxt = isA ? "Mode A · horizon " + str.tostring(H) + " bars" : "Mode B · TP " + str.tostring(tpM) + "× / SL " + str.tostring(slM) + "× ATR, max " + str.tostring(maxHold)
    string oosTxt  = "OOS from " + str.format_time(tm.get(oosIdx), "yyyy-MM-dd", syminfo.timezone) + (byDate ? (fallback ? "  ⚠ date outside history → last " + str.tostring(oosPct) + " %" : " (fixed date)") : " (last " + str.tostring(oosPct) + " %)") + " · threshold " + str.tostring(thrHi) + (both ? " (both directions)" : "")
    string costTxt = costVal == 0 ? "⚠ Costs = 0 → tradability is optimistic" : "Costs " + str.tostring(costVal) + (costUnit == "Price" ? " (price)" : " %") + " per trade · swaps not included"
    string sigTxt  = (useL or useS) ? "Baseline: " + (useF ? "filtered bars only · signals outside the filter are excluded" : "all bars") + (startIdx > 0 ? " · data from " + str.format_time(tm.get(startIdx), "yyyy-MM-dd", syminfo.timezone) : "") + " · verdict from OOS only" : "⚠ No direction is enabled"
    if cols > 1
        table.cell(tb, 0, 10,  modeTxt, text_color = color.silver, text_size = ts, text_halign = text.align_left)
        table.merge_cells(tb, 0, 10, cols - 1, 10)
        table.cell(tb, 0, 11, oosTxt, text_color = fallback ? color.orange : color.silver, text_size = ts, text_halign = text.align_left)
        table.merge_cells(tb, 0, 11, cols - 1, 11)
        table.cell(tb, 0, 12, costTxt, text_color = costVal == 0 ? color.orange : color.silver, text_size = ts, text_halign = text.align_left)
        table.merge_cells(tb, 0, 12, cols - 1, 12)
        table.cell(tb, 0, 13, sigTxt, text_color = color.silver, text_size = ts, text_halign = text.align_left)
        table.merge_cells(tb, 0, 13, cols - 1, 13)
    else
        table.cell(tb, 0, 10, sigTxt, text_color = color.orange, text_size = ts)

// ═════════════════════ VISUALS ═════════════════════
plotshape(showMk and useL and newL[1] and (not useF or fAct[1]), "LONG entry",  shape.triangleup,   location.belowbar, color.new(color.lime, 0), size = size.tiny)
plotshape(showMk and useS and newS[1] and (not useF or fAct[1]), "SHORT entry", shape.triangledown, location.abovebar, color.new(color.red, 0),  size = size.tiny)
````
