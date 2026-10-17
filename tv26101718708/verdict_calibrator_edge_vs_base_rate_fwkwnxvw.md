# Verdict Calibrator  Edge vs Base Rate

- url: https://www.tradingview.com/script/fwKwNXVw-Verdict-Calibrator-Edge-vs-Base-Rate/
- type: indicator
- pine_id: PUB;1e4c6c7fdb95402f86ef33c197f82c5c
- version: 1.0

## Description

Overview

A meta-tool that answers one honest question about any signal: does it actually beat chance?

Point it at another indicator's output (via the source input) or use a built-in reference signal, and it forward-tests every long/short call with a triple-barrier outcome, compares the hit rate to the unconditional base rate of the same move, and only calls an edge "proven" when a confidence-interval lower bound clears that base rate. It splits the result by side (long vs short) and by regime (trend vs range).

It grades a signal; it does not make one.

Why this exists

Most "win rate" readouts are misleading. 60% right means nothing until you know how often the same move happened anyway — if price rose 60% of the time regardless, your signal has an edge of exactly zero. And a 60% on 12 samples is noise, not evidence.

This tool is built so it can only ever say "no proven edge" when there isn't one. The base-rate comparison and the significance gate make false confidence structurally hard to produce.

Why these parts are ONE tool


Signal as a parameter. Connect any plot on your chart through the source input, or pick a built-in reference. The signal is an input, not baked in — so you can audit your indicators, not just this one. The ten built-ins span the families traders actually use:


FamilyBuilt-insTrend-followMA cross · MACD cross · Supertrend flipMomentumRSI 50-cross · Stochastic crossBreakoutDonchian breakout · VWAP crossMean-reversionRSI 30/70 reversal · Bollinger fadeControlRandom (coin flip)


The random control — the tool's own self-test. A deterministic coin flip that by construction has no edge. Grade it and the verdict should read "Not proven" with an Edge near zero. If a random signal ever comes back "PROVEN", the harness is broken — distrust the tool, not the market. No other calibrator on TradingView ships with a falsification test built in. It is also the single fastest way for a sceptical user to satisfy themselves that this thing is honest.
Triple-barrier outcome. From each signal: did price reach +target, −target, or neither within the horizon? A well-defined outcome, not a vague "did it go up eventually".
Base-rate comparison. The honest yardstick — the unconditional rate of the same outcome, matched to the signal's own side and regime mix. Edge = Hit% − Base%, never raw Hit%.
Significance gate. A score-interval lower bound must clear the base rate before an edge is called proven — which matters most at small samples, exactly where point estimates lie.
Regime and side split. Edge is reported for long vs short and trend vs range separately, because a real edge usually lives in one and not the other.


Remove any one and the tool can be fooled into reporting confidence it hasn't earned.

How to use it

Pick the signal (external source or a built-in), set the outcome (horizon + target in ATR), and read the verdict: PROVEN +X% ★ / Not proven / Gathering data.

The two plotted lines are the running Hit % (of the signal) and Base % (unconditional) — the gap between them IS the edge, and you can watch it stabilise as samples accumulate. Switch the dashboard to Pro to see where the edge lives (long/short, trend/range).

If it says "no proven edge", believe it. That's the tool working, not failing.

Data & scope

Works on any symbol and timeframe — it needs only OHLC, no volume. Give it enough history to reach the minimum sample count, or the verdict will honestly read "Gathering data". Because the base rate is measured on the same chart, the yardstick always matches the instrument you're on.

Non-repainting & honest limits

Confirmed-bar reads; samples log at the signal bar and resolve on closed bars.

This is an in-sample, forward-from-signal study aid — NOT a walk-forward backtest. No costs or slippage. Overlapping forward windows correlate samples (the minimum-gap setting mitigates this; it does not eliminate it). Small-n edges are provisional even when starred. A proven in-sample edge is not a guarantee out-of-sample. Nothing here predicts price.

Concept credits

Built on standard, published techniques — triple-barrier forward labelling (M. López de Prado), base-rate / skill-vs-chance evaluation (a long tradition in forecast verification), the efficiency-ratio regime read (Perry Kaufman), and the Wilson score interval for a proportion (Edwin B. Wilson). The signal-agnostic intake, the coupling and the plain-language verdict are this script's own. No third-party Pine code is reused.

Disclaimer

Research and educational tool only. Not financial advice, no recommendation, no guarantee of results. Indicators describe past behaviour; they do not predict the future. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                   MPL-2.0
// VERDICT CALIBRATOR — EDGE vs BASE RATE                                                      v1.0
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   A meta-tool that answers one honest question about ANY signal: does it actually beat chance?
//   Point it at another indicator's output (via the source input) or use a built-in reference
//   signal, and it forward-tests every long/short call with a triple-barrier outcome, compares the
//   hit rate to the unconditional BASE RATE of the same move, and only calls an edge "proven" when
//   a confidence-interval lower bound clears that base rate. It splits the result by side (long vs
//   short) and by regime (trend vs range). It grades a signal; it does not make one.
//
// WHY THIS EXISTS
//   Most "win rate" readouts are misleading: 60% right means nothing until you know how often the
//   same move happened anyway, and a 60% on 12 samples is noise. This tool is built so it can only
//   ever say "no proven edge" when there isn't one — the base-rate comparison and the significance
//   gate make false confidence structurally hard to produce.
//
// WHAT MAKES IT DIFFERENT  (why these parts are ONE tool)
//   - SIGNAL AS A PARAMETER: connect any plot on your chart through the source input, or select a
//     built-in reference as a baseline. The signal is an input, not baked in — so you can audit
//     YOUR indicators, not just this one. The ten built-ins span the families traders actually use:
//        TREND-FOLLOW   MA cross · MACD cross · Supertrend flip
//        MOMENTUM       RSI 50-cross · Stochastic cross
//        BREAKOUT       Donchian breakout · VWAP cross
//        MEAN-REVERSION RSI 30/70 reversal · Bollinger fade
//        CONTROL        Random (coin flip)
//   - THE RANDOM CONTROL: a deterministic coin flip that BY CONSTRUCTION has no edge. It is the
//     tool's own self-test. Grade it and the verdict should read "Not proven" with an Edge near
//     zero. If a random signal ever comes back "PROVEN", the harness is broken — distrust the tool,
//     not the market. No other calibrator ships with a falsification test built in.
//   - TRIPLE-BARRIER OUTCOME: from each signal, did price reach +target, −target, or neither within
//     the horizon? A well-defined outcome, not "did it go up eventually".
//   - BASE-RATE COMPARISON: the honest yardstick — the unconditional rate of the same outcome, so
//     Edge = Hit% − Base%, never raw Hit%.
//   - SIGNIFICANCE GATE: a score-interval lower bound must clear the base rate before an edge is
//     called proven, which is honest at small samples where point estimates lie.
//   - REGIME + SIDE SPLIT: edge is reported for long vs short and for trend vs range separately,
//     because a real edge usually lives in one and not the other.
//
// HOW TO USE
//   Pick the signal (external source or built-in), set the outcome (horizon + target in ATR), and
//   read the verdict: PROVEN +X% ★ / Not proven / Gathering data. The two lines are the running
//   Hit% (of the signal) and Base% (unconditional) — the gap between them IS the edge, and you can
//   watch it stabilize. Use the Pro table to see where the edge lives (long/short, trend/range). If
//   it says "no proven edge", believe it. This audits signals; it is not itself a trade signal.
//
// DATA / SCOPE
//   Works on any symbol and timeframe — it needs only OHLC (no volume). Give it enough history to
//   reach the minimum sample count, or the verdict will honestly read "Gathering data". Because the
//   base rate is measured on the same chart, the yardstick always matches the instrument you are on.
//
// EXPORTS  (Data Window — consume from other scripts via input.source())
//   EXP_HitPct · EXP_BasePct · EXP_Edge · EXP_Samples · EXP_Proven · EXP_WilsonLow · EXP_FireDir
//
// NON-REPAINT / HONESTY
//   Confirmed-bar reads; samples log at the signal bar and resolve on closed bars. This is an
//   IN-SAMPLE, forward-from-signal study aid — NOT a walk-forward backtest: no costs or slippage,
//   overlapping forward windows correlate samples (a minimum gap mitigates, it does not eliminate),
//   small-n edges are provisional even when starred, and a proven in-sample edge is not a guarantee
//   out-of-sample. Nothing here predicts price.
//
// CONCEPT CREDIT
//   Built on standard, published techniques — triple-barrier forward labelling, base-rate (skill vs
//   chance) evaluation, an efficiency-ratio regime read, and a score-interval lower bound for a
//   proportion. Full author credits are in the published description. The signal-agnostic intake,
//   the coupling and the plain-language verdict are this script's own. No third-party Pine code is
//   reused. Not affiliated with, nor endorsed by, any third party.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice, NO recommendation, NO guarantee of
//   results. Indicators describe past behaviour; they do not predict the future. Trading carries
//   risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Verdict Calibrator — Edge vs Base Rate", "Calibrator", overlay = false, max_labels_count = 100, max_bars_back = 500)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
g0        = "01 · Signal to grade"
sigMode   = input.string("MA cross", "Signal", group = g0,
     options = ["External source",
                "MA cross", "MACD cross", "Supertrend flip",
                "RSI 50-cross", "RSI 30/70 reversal", "Stochastic cross",
                "Breakout", "VWAP cross", "Bollinger fade",
                "Random (control)"],
     tooltip = "Starts on MA cross so the tool works immediately. Switch to 'External source' and connect any indicator's plot to grade YOUR signal. The built-ins span the main families traders actually use: TREND-FOLLOW (MA / MACD / Supertrend), MOMENTUM (RSI / Stochastic), BREAKOUT (Donchian / VWAP), MEAN-REVERSION (RSI reversal / Bollinger fade) — and RANDOM, a coin-flip control that SHOULD show no edge. If Random ever reads 'proven', distrust the harness, not the market.")
extSrc    = input.source(close, "External signal source", group = g0, tooltip = "Connect the plot of any indicator here (or a raw series).")
extDirMode= input.string("Above/below its own mean", "External read", options = ["Above/below its own mean","Above/below level","Rising/falling (slope)"], group = g0, tooltip = "Above/below its own mean = AUTO-CENTRES any series, so you do not need to know whether it is a 0-centred oscillator or a 0-100 one. Use the fixed level only when you know it (e.g. 50 for RSI).")
extLevel  = input.float(0.0, "Signal level (fixed-level mode only)", group = g0, tooltip = "Only used by 'Above/below level'. Long when the source is above this, short when below. 0 for a centred oscillator, 50 for an RSI-type. If unsure, use the auto-centred mode instead.")
extMeanLen= input.int(100, "Auto-centre window", minval = 10, maxval = 1000, group = g0, tooltip = "Lookback for the source's own mean when using the auto-centred read.")
maFast    = input.int(20, "MA cross — fast", minval = 2, maxval = 200, group = g0)
maSlow    = input.int(50, "MA cross — slow", minval = 3, maxval = 400, group = g0)
rsiLen    = input.int(14, "RSI length", minval = 2, maxval = 200, group = g0)
brkLen    = input.int(20, "Breakout length", minval = 3, maxval = 300, group = g0)
gB        = "01b · Built-in signal parameters"
macdF     = input.int(12, "MACD fast", minval = 2, maxval = 200, group = gB, inline = "md")
macdS     = input.int(26, "MACD slow", minval = 3, maxval = 400, group = gB, inline = "md")
macdSig   = input.int(9,  "MACD signal", minval = 1, maxval = 100, group = gB, inline = "md")
stAtr     = input.int(10, "Supertrend ATR", minval = 2, maxval = 100, group = gB, inline = "st")
stFac     = input.float(3.0, "Supertrend factor", minval = 0.5, maxval = 10.0, step = 0.1, group = gB, inline = "st")
rsiOb     = input.int(70, "RSI overbought", minval = 51, maxval = 95, group = gB, inline = "rl")
rsiOs     = input.int(30, "RSI oversold",  minval = 5,  maxval = 49, group = gB, inline = "rl")
stoK      = input.int(14, "Stoch %K", minval = 2, maxval = 200, group = gB, inline = "so")
stoD      = input.int(3,  "Stoch %D", minval = 1, maxval = 50,  group = gB, inline = "so")
stoSm     = input.int(3,  "Stoch smooth", minval = 1, maxval = 50, group = gB, inline = "so")
bbLen     = input.int(20, "Bollinger length", minval = 3, maxval = 300, group = gB, inline = "bb")
bbMult    = input.float(2.0, "Bollinger mult", minval = 0.5, maxval = 6.0, step = 0.1, group = gB, inline = "bb")

g1        = "02 · Outcome (triple-barrier)"
horizon   = input.int(20, "Horizon (bars)", minval = 2, maxval = 200, group = g1)
kATR      = input.float(1.0, "Target move (× ATR)", minval = 0.1, maxval = 10.0, step = 0.1, group = g1)
atrLen    = input.int(14, "ATR length", minval = 2, maxval = 100, group = g1)
outMode   = input.string("Net move", "Outcome test", options = ["Net move","Favorable touch"], group = g1, tooltip = "Net move (endpoint): did price END the horizon at least the target in the signal's direction (strict). Favorable touch: did it merely TOUCH it (lenient).")

g2        = "03 · Significance & sampling"
confLvl   = input.string("95%", "Confidence", options = ["90%","95%","99%"], group = g2)
minN      = input.int(30, "Min samples to rate", minval = 5, maxval = 1000, group = g2)
minGap    = input.int(5, "Min bars between samples", minval = 1, maxval = 100, group = g2, tooltip = "De-overlaps signals so back-to-back bars aren't counted as independent samples.")

g3        = "04 · Regime split"
regimeOn  = input.bool(true, "Split by trend / range", group = g3)
erLen     = input.int(20, "Regime length", minval = 5, maxval = 100, group = g3)
erThresh  = input.float(0.30, "Trend threshold", minval = 0.1, maxval = 0.9, step = 0.05, group = g3, tooltip = "Efficiency ratio above this at entry = trending; below = ranging.")

g4        = "05 · Display & theme"
showPanel = input.bool(true, "Show verdict panel", group = g4)
dashMode  = input.string("Compact", "Dashboard detail", options = ["Compact","Pro"], group = g4, tooltip = "Compact (default) = the verdict panel alone. Pro = adds the side x regime breakdown, so you can see WHERE the edge lives.")
showLegend= input.bool(true, "Show legend / key", group = g4)
showMarks = input.bool(true, "Mark signal fires", group = g4)
showOvl   = input.bool(true, "Mark fires on price (overlay)", group = g4, tooltip = "Mirror the graded signal's fires onto the price chart, so you can see what is being graded.")
theme     = input.string("Auto", "Theme", options = ["Auto","Dark","Light"], group = g4)
bool showPro = dashMode == "Pro"

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                      PALETTE / THEME / HELPERS
// ═════════════════════════════════════════════════════════════════════════════════════════
GRN = #2ebd85
RED = #f6465d
YEL = #ffd600
f_luma(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
isLight  = theme == "Light" or (theme == "Auto" and f_luma(chart.bg_color) > 140)
txtCol   = isLight ? color.new(#0b0f14, 0) : color.new(#e8edf2, 0)
mutCol   = isLight ? color.new(#5b6673, 0) : color.new(#8b95a1, 0)
rowA     = isLight ? color.new(#f2f4f7, 0) : color.new(#11161c, 0)
rowB     = isLight ? color.new(#e7ebf0, 0) : color.new(#171d24, 0)
hdrCol   = isLight ? color.new(#d9dee5, 0) : color.new(#0c1116, 0)
frameCol = isLight ? color.new(#c8cfd8, 0) : color.new(#2a323c, 0)
float zc = confLvl == "90%" ? 1.645 : confLvl == "99%" ? 2.576 : 1.96

f_wilsonLow(float p, int nn) =>
    float r = na
    if not na(p) and nn > 0
        float denom = 1.0 + zc * zc / nn
        float centre = p + zc * zc / (2.0 * nn)
        float margin = zc * math.sqrt(p * (1.0 - p) / nn + zc * zc / (4.0 * nn * nn))
        r := (centre - margin) / denom
    r

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              SIGNAL → DIRECTION → FIRE (min-gap de-overlapped)
// ═════════════════════════════════════════════════════════════════════════════════════════
float rsiV = ta.rsi(close, rsiLen)
float emaF = ta.ema(close, maFast)
float emaS = ta.ema(close, maSlow)
float hh = ta.highest(high, brkLen)[1]
float ll = ta.lowest(low, brkLen)[1]
var int brkState = 0
brkState := close > hh ? 1 : close < ll ? -1 : brkState

float extRef = ta.sma(extSrc, extMeanLen)
int extDir = extDirMode == "Rising/falling (slope)" ? (extSrc > extSrc[1] ? 1 : extSrc < extSrc[1] ? -1 : 0) : extDirMode == "Above/below its own mean" ? (not na(extRef) and extSrc > extRef ? 1 : not na(extRef) and extSrc < extRef ? -1 : 0) : (extSrc > extLevel ? 1 : extSrc < extLevel ? -1 : 0)
// ── built-in reference engines (all computed unconditionally: Pine evaluates every branch anyway,
//    and keeping them at global scope avoids conditional-ta pitfalls) ──
[macdLine, macdSigLine, _mh] = ta.macd(close, macdF, macdS, macdSig)
[stVal, stDir] = ta.supertrend(stFac, stAtr)

float kFast = ta.sma(ta.stoch(close, high, low, stoK), stoSm)
float dSlow = ta.sma(kFast, stoD)

float bbBasis = ta.sma(close, bbLen)
float bbDev   = bbMult * ta.stdev(close, bbLen)
float bbUp    = bbBasis + bbDev
float bbLo    = bbBasis - bbDev
// mean-reversion state: FADE the band — long after tagging the lower band, short after the upper
var int bbState = 0
bbState := close < bbLo ? 1 : close > bbUp ? -1 : bbState

// RSI reversal (mean-reversion): long when leaving oversold, short when leaving overbought
var int rsiRevState = 0
rsiRevState := (rsiV[1] < rsiOs and rsiV >= rsiOs) ? 1 : (rsiV[1] > rsiOb and rsiV <= rsiOb) ? -1 : rsiRevState

float vwapV = ta.vwap(hlc3)

// Random control: a deterministic hash of bar_index — reproducible, never repaints, and by
// construction carries NO edge. It exists to prove the harness cannot manufacture one.
f_hash(int n) =>
    float x = math.sin(n * 12.9898) * 43758.5453
    x - math.floor(x)
int randDir = f_hash(bar_index) > 0.5 ? 1 : -1

int rawDir = sigMode == "External source"      ? extDir :
   sigMode == "MA cross"            ? (emaF > emaS ? 1 : emaF < emaS ? -1 : 0) :
   sigMode == "MACD cross"          ? (macdLine > macdSigLine ? 1 : macdLine < macdSigLine ? -1 : 0) :
   sigMode == "Supertrend flip"     ? (stDir < 0 ? 1 : -1) :
   sigMode == "RSI 50-cross"        ? (rsiV > 50 ? 1 : rsiV < 50 ? -1 : 0) :
   sigMode == "RSI 30/70 reversal"  ? rsiRevState :
   sigMode == "Stochastic cross"    ? (kFast > dSlow ? 1 : kFast < dSlow ? -1 : 0) :
   sigMode == "Breakout"            ? brkState :
   sigMode == "VWAP cross"          ? (close > vwapV ? 1 : close < vwapV ? -1 : 0) :
   sigMode == "Bollinger fade"      ? bbState :
   sigMode == "Random (control)"    ? randDir : 0

int fireRaw = (rawDir == 1 and rawDir[1] != 1) ? 1 : (rawDir == -1 and rawDir[1] != -1) ? -1 : 0
var int lastFire = -100000
bool gapOk = bar_index - lastFire >= minGap
int fireDir = (fireRaw != 0 and gapOk) ? fireRaw : 0
if fireDir != 0
    lastFire := bar_index

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              OUTCOME (triple-barrier) + REGIME AT ENTRY
// ═════════════════════════════════════════════════════════════════════════════════════════
float atr = ta.atr(atrLen)
float erChange = math.abs(close - close[erLen])
float erVol = math.sum(math.abs(close - close[1]), erLen)
float er = erVol > 0 ? erChange / erVol : 0.0
bool trending = er > erThresh

float entry = close[horizon]
float atrE = atr[horizon]
float thr = kATR * atrE
float hiWin = ta.highest(high, horizon)
float loWin = ta.lowest(low, horizon)
float mv = close - entry
bool upOut = outMode == "Net move" ? (mv >= thr) : (hiWin >= entry + thr)
bool dnOut = outMode == "Net move" ? (mv <= -thr) : (loWin <= entry - thr)

// ═════════════════════════════════════════════════════════════════════════════════════════
//         ACCUMULATORS  (per regime × side ; plus per-regime unconditional base rate)
// ═════════════════════════════════════════════════════════════════════════════════════════
var int btN = 0
var int btH = 0
var int stN = 0
var int stH = 0
var int brN = 0
var int brH = 0
var int srN = 0
var int srH = 0
var int resT = 0
var int buT = 0
var int bdT = 0
var int resR = 0
var int buR = 0
var int bdR = 0

// The accumulators below are all var SCALARS, which Pine rolls back between intrabar ticks — so they
// were already safe from tick-compounding. The explicit confirmed-bar gate is kept anyway: it makes
// the intent unambiguous, and it guards against a future edit introducing an array accumulator here
// (array contents are NOT rolled back, which is the classic way this kind of harness gets corrupted).
bool warm = bar_index > horizon + erLen + atrLen + 5
if warm and barstate.isconfirmed and not na(entry) and not na(thr) and thr > 0
    bool inTrend = trending[horizon]
    // unconditional base rate, split by regime
    if inTrend
        resT += 1
        buT += upOut ? 1 : 0
        bdT += dnOut ? 1 : 0
    else
        resR += 1
        buR += upOut ? 1 : 0
        bdR += dnOut ? 1 : 0
    // signal samples
    int d = fireDir[horizon]
    if d != 0
        bool hit = d > 0 ? upOut : dnOut
        if inTrend
            if d > 0
                btN += 1
                btH += hit ? 1 : 0
            else
                stN += 1
                stH += hit ? 1 : 0
        else
            if d > 0
                brN += 1
                brH += hit ? 1 : 0
            else
                srN += 1
                srH += hit ? 1 : 0

// per-regime unconditional up/down outcome rates
float upR_T = resT > 0 ? buT / float(resT) : na
float dnR_T = resT > 0 ? bdT / float(resT) : na
float upR_R = resR > 0 ? buR / float(resR) : na
float dnR_R = resR > 0 ? bdR / float(resR) : na

// running OVERALL hit vs matched base (as % series, for the plot)
int   allN = btN + stN + brN + srN
int   allH = btH + stH + brH + srH
float allSB = btN * nz(upR_T) + stN * nz(dnR_T) + brN * nz(upR_R) + srN * nz(dnR_R)
float hitRun  = allN > 0 ? allH / float(allN) * 100.0 : na
float baseRun = allN > 0 ? allSB / float(allN) * 100.0 : na
float wlOverall = f_wilsonLow(allN > 0 ? allH / float(allN) : na, allN)
bool  sigOverall = not na(wlOverall) and not na(baseRun) and (wlOverall * 100.0) > baseRun
float edgeOverall = (na(hitRun) or na(baseRun)) ? na : hitRun - baseRun

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        PLOTS
// ═════════════════════════════════════════════════════════════════════════════════════════
color hitCol = na(edgeOverall) ? mutCol : sigOverall ? GRN : edgeOverall > 0 ? YEL : RED
hline(50, "50%", color.new(chart.fg_color, 70), hline.style_dotted)
plot(baseRun, "Base rate %", color.new(mutCol, 10), 1)
plot(hitRun,  "Signal hit %", color.new(hitCol, 0), 2)
plotshape(showMarks and fireDir > 0, "Long fire",  shape.triangleup,   location.bottom, color.new(GRN, 0), size = size.tiny)
plotshape(showMarks and fireDir < 0, "Short fire", shape.triangledown, location.top,    color.new(RED, 0), size = size.tiny)
// mirror the graded signal's fires onto the price chart, so you can see WHAT is being graded
plotshape(showOvl and fireDir > 0, "Long fire (price)",  shape.triangleup,   location.belowbar, color.new(GRN, 0), size = size.tiny, force_overlay = true)
plotshape(showOvl and fireDir < 0, "Short fire (price)", shape.triangledown, location.abovebar, color.new(RED, 0), size = size.tiny, force_overlay = true)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                    VERDICT PANEL
// ═════════════════════════════════════════════════════════════════════════════════════════
var table pan = table.new(position.top_right, 2, 7, border_width = 1, border_color = frameCol, frame_color = frameCol, frame_width = 1)
f_row(int r, string k, string v, color vc) =>
    color bg = r % 2 == 0 ? rowA : rowB
    table.cell(pan, 0, r, k, text_size = size.small, text_color = mutCol, text_halign = text.align_left,  bgcolor = bg)
    table.cell(pan, 1, r, v, text_size = size.small, text_color = vc,     text_halign = text.align_right, bgcolor = bg)
if showPanel and barstate.islast
    string sigName = sigMode == "External source" ? "External" : sigMode
    // Diagnostic: distinguish "still warming up" from "this signal never actually fires".
    // A constant-direction source (e.g. raw close vs level 0 — always above) produces ZERO samples
    // forever, which would otherwise read as an innocent "Gathering data".
    bool  ranLong = bar_index > horizon + erLen + atrLen + 200
    bool  stuck   = allN == 0 and ranLong
    string verdict = stuck ? "SIGNAL NEVER FIRES" : allN < minN ? "Gathering data" : sigOverall ? "PROVEN " + str.tostring(edgeOverall, "+0.0") + "% ★" : "Not proven"
    color  vCol = stuck ? YEL : allN < minN ? mutCol : sigOverall ? GRN : RED
    string useTxt = stuck ? "check source / read mode" : sigOverall ? "clears base rate — verify out-of-sample" : allN < minN ? "need more samples / history" : "no proven edge — context only"
    table.cell(pan, 0, 0, "VERDICT CALIBRATOR", text_size = size.small, text_color = txtCol, text_halign = text.align_left,  bgcolor = hdrCol)
    table.cell(pan, 1, 0, sigName, text_size = size.small, text_color = txtCol, text_halign = text.align_right, bgcolor = hdrCol)
    f_row(1, "Verdict", verdict, vCol)
    f_row(2, "Samples", str.tostring(allN) + " / " + str.tostring(minN), allN >= minN ? txtCol : mutCol)
    f_row(3, "Hit %", na(hitRun) ? "—" : str.tostring(hitRun, "0.0") + "%", txtCol)
    f_row(4, "Base %", na(baseRun) ? "—" : str.tostring(baseRun, "0.0") + "%", mutCol)
    f_row(5, "Edge", na(edgeOverall) ? "—" : str.tostring(edgeOverall, "+0.0;-0.0") + "%" + (sigOverall ? " ★" : ""), na(edgeOverall) ? mutCol : sigOverall ? GRN : edgeOverall > 0 ? YEL : RED)
    f_row(6, "Use", useTxt, sigOverall ? GRN : mutCol)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              BREAKDOWN TABLE (side × regime)
// ═════════════════════════════════════════════════════════════════════════════════════════
var table pro = table.new(position.bottom_right, 6, 7, border_width = 1, border_color = frameCol, frame_color = frameCol, frame_width = 1)
f_head(int col, string s) => table.cell(pro, col, 0, s, text_size = size.small, text_color = txtCol, text_halign = text.align_center, bgcolor = hdrCol)
f_proRow(int r, string lbl, float sn, float sh, float sb) =>
    color bg = r % 2 == 0 ? rowA : rowB
    float hitR = sn > 0 ? sh / sn : na
    float baseR = sn > 0 ? sb / sn : na
    float edge = (na(hitR) or na(baseR)) ? na : (hitR - baseR) * 100.0
    float wl = f_wilsonLow(hitR, int(sn))
    bool  sg = not na(wl) and not na(baseR) and wl > baseR
    color eCol = na(edge) ? mutCol : sg ? GRN : edge > 0 ? YEL : RED
    table.cell(pro, 0, r, lbl, text_size = size.small, text_color = mutCol, text_halign = text.align_left, bgcolor = bg)
    table.cell(pro, 1, r, str.tostring(int(sn)), text_size = size.small, text_color = sn >= minN ? txtCol : mutCol, text_halign = text.align_center, bgcolor = bg)
    table.cell(pro, 2, r, na(hitR) ? "—" : str.tostring(hitR * 100.0, "0"), text_size = size.small, text_color = txtCol, text_halign = text.align_center, bgcolor = bg)
    table.cell(pro, 3, r, na(baseR) ? "—" : str.tostring(baseR * 100.0, "0"), text_size = size.small, text_color = mutCol, text_halign = text.align_center, bgcolor = bg)
    table.cell(pro, 4, r, na(edge) ? "—" : str.tostring(edge, "+0;-0"), text_size = size.small, text_color = eCol, text_halign = text.align_center, bgcolor = bg)
    table.cell(pro, 5, r, sg ? "★" : "·", text_size = size.small, text_color = sg ? GRN : mutCol, text_halign = text.align_center, bgcolor = bg)
if showPro and barstate.islast
    f_head(0, "SEGMENT")
    f_head(1, "n")
    f_head(2, "Hit")
    f_head(3, "Base")
    f_head(4, "Edge")
    f_head(5, "★")
    f_proRow(1, "Overall", allN, allH, allSB)
    f_proRow(2, "Long", btN + brN, btH + brH, btN * nz(upR_T) + brN * nz(upR_R))
    f_proRow(3, "Short", stN + srN, stH + srH, stN * nz(dnR_T) + srN * nz(dnR_R))
    if regimeOn
        f_proRow(4, "Trend", btN + stN, btH + stH, btN * nz(upR_T) + stN * nz(dnR_T))
        f_proRow(5, "Range", brN + srN, brH + srH, brN * nz(upR_R) + srN * nz(dnR_R))

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       LEGEND / KEY
// ═════════════════════════════════════════════════════════════════════════════════════════
var table lgd = table.new(position.bottom_left, 2, 6, border_width = 1, border_color = frameCol, frame_color = frameCol, frame_width = 1)
f_lgd(int r, string sw, color swc, string txt) =>
    color bg = r % 2 == 0 ? rowA : rowB
    table.cell(lgd, 0, r, sw,  text_size = size.tiny, text_color = swc,    text_halign = text.align_center, bgcolor = bg)
    table.cell(lgd, 1, r, txt, text_size = size.tiny, text_color = mutCol, text_halign = text.align_left,   bgcolor = bg)
if showLegend and barstate.islast
    table.cell(lgd, 0, 0, "KEY", text_size = size.tiny, text_color = txtCol, bgcolor = hdrCol)
    table.cell(lgd, 1, 0, "what you're looking at", text_size = size.tiny, text_color = txtCol, text_halign = text.align_left, bgcolor = hdrCol)
    f_lgd(1, "━━", hitCol, "Signal Hit % — how often the graded signal was right")
    f_lgd(2, "━━", mutCol, "Base % — how often it happened ANYWAY (the yardstick)")
    f_lgd(3, "↕",  YEL,    "The GAP between the two lines IS the edge")
    f_lgd(4, "▲▼", GRN,    "The graded signal firing long / short")
    f_lgd(5, "★",  GRN,    "Edge clears the base rate at the confidence level")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                  EXPORTS  (Data Window — consume elsewhere via input.source())
// ═════════════════════════════════════════════════════════════════════════════════════════
color exC = color.new(color.gray, 100)
plot(hitRun,                          "EXP_HitPct",   exC, display = display.data_window)
plot(baseRun,                         "EXP_BasePct",  exC, display = display.data_window)
plot(edgeOverall,                     "EXP_Edge",     exC, display = display.data_window)
plot(allN,                            "EXP_Samples",  exC, display = display.data_window)
plot(sigOverall ? 1 : 0,              "EXP_Proven",   exC, display = display.data_window)
plot(na(wlOverall) ? na : wlOverall * 100.0, "EXP_WilsonLow", exC, display = display.data_window)
plot(fireDir,                         "EXP_FireDir",  exC, display = display.data_window)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(fireDir > 0, "Signal long", "Verdict Calibrator: graded signal fired long.")
alertcondition(fireDir < 0, "Signal short", "Verdict Calibrator: graded signal fired short.")
````
