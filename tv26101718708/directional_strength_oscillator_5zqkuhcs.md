# Directional Strength Oscillator

- url: https://www.tradingview.com/script/5zqkuhCs-Directional-Strength-Oscillator/
- type: indicator
- pine_id: PUB;d1d746217dc34d6d8b486c2e3984a53f
- version: 5.0

## Description

Directional Strength Oscillator

A signed trend-strength oscillator that reads the tug-of-war between upward and downward movement and prints one line — positive in uptrends, negative in downtrends, crossing zero at trend changes. Unlike a plain directional reading, it dims itself when price is only chopping, flags weakening trends through divergence, and scores its own signals forward on your chart in plain language.

Why these parts are combined (not a mashup for show). Each part answers what the previous one leaves open. Up-movement vs down-movement relative to true range gives a clean, bounded read of who's winning and by how much — but it can read "strong" inside noisy, non-trending chop. A trend-efficiency filter (net travel over total path) measures whether price is actually going somewhere; folding it into the line removes the false-strong chop. A divergence check (price makes a new extreme while strength does not) flags weakening trends the raw line would miss. Together they form one directional-strength tool.

How it works. Up-movement = |high − prior low|, down-movement = |low − prior high|; each is summed over the length and divided by summed true range to get the up and down lines. Their difference is the raw strength; it's standardized, soft-bounded to ±100, then scaled by a 0–1 trend-efficiency factor. Signals are zero-crosses gated by a minimum quality, plus divergence against price (measured on the undimmed strength). Each signal is then labelled by a triple barrier — a profit target and equal stop in ATR units plus a time limit — so a "win" means the target hit before the stop. Results split into in-sample and recent out-of-sample, with a confidence interval and a multiple-testing check.

How to use. Read the Verdict row (Long/Short signal, Watch, or Wait) and the Conviction row, which reads "High" only when that signal type shows a positive edge that survives the test on this symbol. Green line above zero = uptrend in control, red below = downtrend; shaded bands = strong trend; the trend-quality % tells you how clean the move is. Best used with your own entry and risk plan, not alone.

What's original. The trend-quality gate that removes false-strong chop, integrated divergence on the undimmed line, the forward triple-barrier calibration with an out-of-sample split, and a conviction read that openly admits when there's no proven edge.

Inputs. High/Low sources (change them for any market), reading mode (Simple/Pro), engine, quality-gate, divergence and full calibration settings, and an auto-adapting dashboard legible on dark or light charts. Defaults are tuned for NSE:NIFTY1! intraday.

Honesty & limitations. Edge figures are computed on this chart's own history with overlapping windows and no costs — context, not a guaranteed backtest; past behaviour doesn't predict the future.

Disclaimer: for research and education only. Not financial advice. Trading carries risk of loss; manage your own positions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// DIRECTIONAL STRENGTH OSCILLATOR — Quality-Gated & Forward-Calibrated                         v1.3
//  v1.3 (R1 · honest-stats standardization): robust-z via ml_robuststats/2 and the Wilson confidence math via
//    ml_calib/2 — both byte-identical to the prior local helpers, so the oscillator, the divergence marks and
//    every calibration number are UNCHANGED. Imports pinned to the exact published v2 versions.
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.2 — Two additive normalization options over v1.1 — the strength engine, the trend-quality
//        gate, the divergence check and the entire forward-calibration harness (triple-barrier,
//        out-of-sample split, Wilson interval, Bonferroni, Net-R cost model) are unchanged:
//        • Wave A — robust normalization (default ON): standardization is selectable (group 2) —
//          classic mean/stdev z-score, or a robust median/MAD z (default) that a few violent bars
//          can't distort. Set "Normalization method" to "Classic (mean/stdev)" to restore v1.1.
//        • Wave D · U8 — 3-window extreme consensus (opt-in, default OFF): the z can be taken as
//          the MEDIAN of the z at half, one and double the normalization window, so a reading is
//          extreme only when short, medium and long windows agree. "Extreme normalization" =
//          "Single window" (default) reproduces v1.1's single-window behaviour.
// v1.1 — Correctness + house-standard pass:
//        • Hoisted the two ta.barssince calls out of the `useHold ? … : …` ternary and the
//          short-circuiting `and` so they run on every bar (Pine requirement for series functions;
//          clears CW10004 and removes wrong hold-timing that the skipped counters could produce).
//        • Added the MPL-2.0 licence header, an EXP_ Data-Window export bus, and a round-trip COST
//          model (Net R): conviction now requires an edge that also survives trading costs.
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   A signed trend-strength oscillator. It measures the tug-of-war between upward and downward
//   directional movement (relative to the bar's true range) and prints one line that is positive
//   in uptrends, negative in downtrends, and crosses zero at trend changes. It adds two things a
//   plain directional-movement reading lacks: a TREND-QUALITY gate that dims the line when price
//   is just chopping (so "strong" means strong AND clean), and a forward-calibration layer that
//   scores its own crosses on the chart you are viewing — in plain language — so a non-technical
//   reader can tell at a glance whether to act or wait.
//
// WHY THESE PARTS ARE COMBINED (read this if you think it is a mashup)
//   Each part answers a question the previous one leaves open:
//     • Up-movement vs down-movement relative to true range gives a clean, bounded read of WHO is
//       winning and BY HOW MUCH — but it can read "strong" inside noisy, non-trending chop.
//     • A trend-EFFICIENCY filter (net travel over total path) measures whether price is actually
//       going somewhere; multiplying it into the strength reading removes the false-strong chop.
//     • A divergence check (price makes a new extreme while directional strength does not) flags
//       weakening trends the raw line would miss.
//   Together they form one directional-strength tool, not a stack of separate studies. A forward-
//   calibration layer then measures, honestly, whether the resulting signals pay on this symbol.
//
// HOW IT WORKS
//   Up-movement = |high - prior low|, down-movement = |low - prior high|; each is summed over the
//   length and divided by summed true range to get the positive and negative directional lines.
//   Their difference is the raw strength; it is standardized and soft-bounded to +/-100, then
//   scaled by a 0..1 trend-efficiency factor. Signals: the line crossing zero (trend flip), gated
//   by a minimum quality; plus optional divergence of the line against price.
//
// HOW TO USE (plain language)
//   • Read the VERDICT row: Long/Short signal = a quality-confirmed trend flip; Watch = a flip
//     with weak quality; Wait = mid-range / chop.
//   • The CONVICTION row says whether that signal type has a positive, statistically-surviving
//     edge on THIS chart. Low conviction = treat as context only.
//   • Green line above zero = uptrend in control; red below = downtrend; shaded bands = strong
//     trend. Best used with your own entry and risk plan, not alone.
//
// NON-REPAINT  Reads confirmed closes; calibration logs and resolves only on barstate.isconfirmed.
//
// CONCEPT CREDIT (technical attributions)
//   This script combines established, public-domain techniques: a directional-movement /
//   true-range strength pair from classical technical analysis; a trend-efficiency (net-over-path)
//   quality filter; price-vs-oscillator divergence; triple-barrier outcome labelling from standard
//   supervised-labelling practice in quantitative finance; the Wilson score interval for the
//   proportion bound; and the Bonferroni adjustment for multiple testing. Credit is due to the
//   originators of each technique. This is an original implementation combining them into one
//   quality-gated, forward-calibrated tool.
//
// DISCLAIMER  For research and education only. Edge figures are computed on this chart's own
//   history with overlapping windows and no costs — context, not a guaranteed backtest, and past
//   behaviour does not predict the future. Nothing here is financial advice. Trading carries risk
//   of loss; size and manage your own positions.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Directional Strength Oscillator", "Dir Str", overlay = false, max_lines_count = 100, max_labels_count = 200)

// R1 · honest-stats standardization — robust-z and the Wilson confidence math are now routed through the
// published calibration libraries (one engine across the divergence family). Both are byte-identical to the
// prior local f_robZ / f_wilson, so the oscillator, the divergence marks and every calibration number are
// UNCHANGED — only where the math is computed moves into the libraries. Pinned to the exact published v2
// versions so a later library update can't silently change this script.
import Market_Logic_India/ml_calib/2        as calib
import Market_Logic_India/ml_robuststats/2  as rstat


// ──────────────────────────────────────────────────────────────────────────────────────────────
// INPUTS  (defaults tuned for NSE:NIFTY1! intraday; change the sources to use any market)
// ──────────────────────────────────────────────────────────────────────────────────────────────
gMain    = "1 · General"
srcHigh  = input.source(high, "High source", group = gMain, tooltip = "Raw high the engine reads. Change for any symbol/market — this script is asset-agnostic.")
srcLow   = input.source(low,  "Low source",  group = gMain)
audience = input.string("Simple (plain language)", "Reading mode", options = ["Simple (plain language)", "Pro (full detail)"], group = gMain, tooltip = "Simple shows a verdict and conviction in words. Pro shows every number.")

gEng     = "2 · Strength engine"
len      = input.int(14,  "Directional length", minval = 2, maxval = 200, group = gEng)
normLen  = input.int(100, "Normalization window", minval = 20, maxval = 500, group = gEng)
zMode    = input.string("Robust (MAD, Wave A)", "Normalization method", options = ["Classic (mean/stdev)","Robust (MAD, Wave A)"], group = gEng, tooltip = "Classic = mean/stdev z-score. Robust (default) = median/MAD z — outlier-resistant, so a few violent bars don't distort the scale. A/B via the calibration Edge.")
zWinMode = input.string("Single window", "Extreme normalization (Wave D · U8)", options = ["Single window","3-window consensus"], group = gEng, tooltip = "Single window = the one Normalization window above (original). 3-window consensus = z is the MEDIAN of the z at half, one and double that window, so a reading is extreme only when short, medium and long agree. Default Single so nothing changes unless you opt in.")

gQual    = "3 · Trend-quality gate"
useQual  = input.bool(true, "Dim strength in chop", group = gQual, tooltip = "Scale the line by trend efficiency (net travel over total path) so 'strong' means strong AND clean. On by default.")
erLen    = input.int(14, "Efficiency length", minval = 3, maxval = 100, group = gQual)
qualMin  = input.float(0.30, "Min quality to signal", minval = 0.0, maxval = 1.0, step = 0.05, group = gQual, tooltip = "Zero-cross signals only fire when trend efficiency is at least this high.")

gHold    = "3b · Whipsaw filter (optional)"
useHold  = input.bool(false, "Require trend flip to hold", group = gHold, tooltip = "OFF = original (signal fires on the zero-cross). ON = fire only after the flip has held for N bars — fewer whipsaws, slightly later. Watch the calibration Edge to confirm it helps.")
holdBars = input.int(2, "Hold bars", minval = 1, maxval = 20, group = gHold)

gDiv     = "4 · Divergence"
showDiv  = input.bool(true, "Detect divergence", group = gDiv, tooltip = "Flag when price makes a new extreme but directional strength does not — a weakening-trend warning.")
pivLen   = input.int(5,  "Pivot length", minval = 1, maxval = 50, group = gDiv)
divLook  = input.int(60, "Max bars between pivots", minval = 5, maxval = 300, group = gDiv)

gSig     = "5 · Signal zones"
strZone  = input.float(50, "Strong-trend zone", minval = 20, maxval = 90, group = gSig)

gCal     = "6 · Forward calibration"
calOn    = input.bool(true, "Run forward calibration", group = gCal, tooltip = "Score signals forward on this chart. On by default — the core honesty feature.")
calHor   = input.int(10, "Time limit (bars)", minval = 2, maxval = 200, group = gCal)
barrierK = input.float(1.0, "Profit/stop size × ATR", minval = 0.1, maxval = 10.0, step = 0.1, group = gCal, tooltip = "A signal wins if price reaches the profit target (this many ATRs) before the equal-sized stop, within the time limit.")
atrLen   = input.int(14, "ATR length", minval = 2, maxval = 100, group = gCal)
oosBars  = input.int(1500, "Out-of-sample window (recent bars)", minval = 100, maxval = 20000, group = gCal, tooltip = "Signals inside the last N bars are scored separately as out-of-sample.")
uniqOn   = input.bool(true, "Non-overlapping sampling", group = gCal, tooltip = "Skip a signal if the previous same-side one was within one time-limit — reduces double-counting.")
calMinN  = input.int(20, "Min sample for rating", minval = 5, maxval = 500, group = gCal)
costR    = input.float(0.30, "Round-trip cost (R) — subtracted for NET", minval = 0.0, maxval = 3.0, step = 0.05, group = gCal, tooltip = "Round-trip cost (brokerage + STT + slippage + optimistic fill) as a fraction of the barrier risk (Profit/stop × ATR). The barrier is symmetric 1:1, so gross expectancy in R = 2·hit% − 1; Net R subtracts this cost, and CONVICTION now requires the edge to survive it. On 1m NIFTY futures costs eat a large share of R, so a gross edge that ignores them is not tradeable.")

gUI      = "7 · Dashboard & appearance"
showTbl  = input.bool(true, "Show dashboard", group = gUI)
tblPos   = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = gUI)
dashTheme= input.string("Auto (match chart)", "Color theme", options = ["Auto (match chart)","Dark","Light"], group = gUI, tooltip = "Auto reads the chart background brightness and adapts table, text and line colors for visibility on any theme.")
tintBg   = input.bool(true, "Tint pane in strong trend", group = gUI)
colUp    = input.color(#2ebd85, "Up color",   inline = "c", group = gUI)
colDn    = input.color(#f6465d, "Down color", inline = "c", group = gUI)

// ──────────────────────────────────────────────────────────────────────────────────────────────
// THEME  (single source of truth — every table, text and line color derives from here)
// ──────────────────────────────────────────────────────────────────────────────────────────────
bgc        = chart.bg_color
lumaV      = na(bgc) ? 0.0 : color.r(bgc)*0.299 + color.g(bgc)*0.587 + color.b(bgc)*0.114
darkUI     = dashTheme=="Dark" ? true : dashTheme=="Light" ? false : (na(bgc) or lumaV < 140)
panelBg    = darkUI ? color.rgb(17,22,28)    : color.rgb(244,246,248)
rowAlt     = darkUI ? color.rgb(25,31,39)    : color.rgb(232,236,240)
txtMain    = darkUI ? color.rgb(236,239,243) : color.rgb(16,20,24)
txtSub     = darkUI ? color.rgb(154,166,178) : color.rgb(74,82,91)
frameC     = darkUI ? color.rgb(58,70,84)    : color.rgb(196,204,212)
upC        = darkUI ? colUp : color.rgb(22,151,106)
dnC        = darkUI ? colDn : color.rgb(200,42,64)
flatC      = darkUI ? color.rgb(120,130,140) : color.rgb(122,130,139)
gridC      = darkUI ? color.new(color.gray, 55) : color.new(color.gray, 45)

// ── HELPERS ───────────────────────────────────────────────────────────────────────────────────
f_pos(string s) => s=="Top Left"?position.top_left : s=="Bottom Right"?position.bottom_right : s=="Bottom Left"?position.bottom_left : position.top_right
f_zscore(float s, int len) =>
    sd = ta.stdev(s, len)
    mn = ta.sma(s, len)
    sd == 0 ? 0.0 : (s - mn) / sd
f_tanh(float x) =>
    float xc = math.max(-10.0, math.min(10.0, x))
    float e = math.exp(2 * xc)
    (e - 1) / (e + 1)
f_squash(float x, float k) => 100.0 * f_tanh(x / math.max(k, 0.0001))
f_stars(float wl, float base, int n) =>
    n < calMinN or na(wl) or na(base) ? "n/a" : wl > base+5 ? "★★★" : wl > base ? "★★" : wl > base-5 ? "★" : "—"
f_firstHit(float up, float lo, int hor) =>
    int fh = 0
    bool done = false
    for i = 0 to hor - 1
        off = hor - 1 - i
        if not done
            hi = high[off]
            ll = low[off]
            bu = hi >= up
            bd = ll <= lo
            if bu and bd
                fh := 2
                done := true
            else if bu
                fh := 1
                done := true
            else if bd
                fh := -1
                done := true
    fh

// ── ENGINE ──────────────────────────────────────────────────────────────────────────────────
vmPlus  = math.abs(srcHigh - srcLow[1])
vmMinus = math.abs(srcLow - srcHigh[1])
trS     = ta.tr(true)
sumTr   = math.sum(trS, len)
viPlus  = sumTr != 0 ? math.sum(vmPlus, len) / sumTr : 0.0
viMinus = sumTr != 0 ? math.sum(vmMinus, len) / sumTr : 0.0
spread  = viPlus - viMinus
// U8 (Wave D): z at three windows (unconditional), select by mode, optional median consensus.
int   _wS = math.max(5, int(normLen / 2))
int   _wL = int(normLen * 2)
float _zcS = f_zscore(spread, _wS), _zcM = f_zscore(spread, normLen), _zcL = f_zscore(spread, _wL)
float _zrS = rstat.robZ(spread, _wS),  _zrM = rstat.robZ(spread, normLen),  _zrL = rstat.robZ(spread, _wL)
bool  _uCl = zMode == "Classic (mean/stdev)"
float _zS = _uCl ? _zcS : _zrS
float _zM = _uCl ? _zcM : _zrM
float _zL = _uCl ? _zcL : _zrL
float _zMed = _zS + _zM + _zL - math.min(_zS, math.min(_zM, _zL)) - math.max(_zS, math.max(_zM, _zL))
spreadZ = zWinMode == "Single window" ? _zM : _zMed
rawLine = f_squash(spreadZ * 33, 100)

// Trend-quality (efficiency ratio): net travel over total path, 0..1
netMove  = math.abs(close - close[erLen])
pathMove = math.sum(math.abs(close - close[1]), erLen)
effRatio = pathMove > 0 ? netMove / pathMove : 0.0
quality  = useQual ? effRatio : 1.0
osc      = rawLine * (useQual ? (0.35 + 0.65*effRatio) : 1.0)   // dim, but never fully zero, in chop

zcUp   = ta.crossover(osc, 0)
zcDn   = ta.crossunder(osc, 0)
// ta.barssince must run every bar — hoisted out of the useHold ternary / short-circuiting `and`.
int barsSinceNonPos = ta.barssince(osc <= 0)   // bars since osc was last ≤ 0
int barsSinceNonNeg = ta.barssince(osc >= 0)   // bars since osc was last ≥ 0
buySig  = (useHold ? (osc > 0 and barsSinceNonPos == holdBars) : zcUp) and quality >= qualMin
sellSig = (useHold ? (osc < 0 and barsSinceNonNeg == holdBars) : zcDn) and quality >= qualMin
strong  = math.abs(osc) > strZone
phaseTxt = osc >= 0 ? (strong ? "Strong up" : "Up") : (strong ? "Strong down" : "Down")
wCol    = osc >= 0 ? upC : dnC

// ── DIVERGENCE (price vs directional strength) ───────────────────────────────────────────────
ph = ta.pivothigh(srcHigh, pivLen, pivLen)
pl = ta.pivotlow(srcLow, pivLen, pivLen)
phC = not na(ph)
plC = not na(pl)
curX = bar_index - pivLen
oHd=rawLine[pivLen], pHh=srcHigh[pivLen], oHy=osc[pivLen]
poH=ta.valuewhen(phC, rawLine[pivLen],1), ppH=ta.valuewhen(phC, srcHigh[pivLen],1), pxH=ta.valuewhen(phC, bar_index-pivLen,1)
bearDiv = showDiv and phC and pHh>ppH and oHd<poH and (curX-pxH<=divLook)
oLd=rawLine[pivLen], pLl=srcLow[pivLen], oLy=osc[pivLen]
poL=ta.valuewhen(plC, rawLine[pivLen],1), ppL=ta.valuewhen(plC, srcLow[pivLen],1), pxL=ta.valuewhen(plC, bar_index-pivLen,1)
bullDiv = showDiv and plC and pLl<ppL and oLd>poL and (curX-pxL<=divLook)

// ── CALIBRATION (triple-barrier + OOS + uniqueness + Bonferroni) ─────────────────────────────
atrSeries = ta.atr(atrLen)
var int buyN = 0
var int buyW = 0
var int buyNo = 0
var int buyWo = 0
var int sellN = 0
var int sellW = 0
var int sellNo = 0
var int sellWo = 0
var int baseN = 0
var int baseW = 0
var int lastBuyBar = -1000000
var int lastSellBar = -1000000

canEval = calOn and barstate.isconfirmed and not na(close[calHor]) and not na(atrSeries[calHor])
if canEval
    entryB = close[calHor]
    aB = atrSeries[calHor]
    fhB = f_firstHit(entryB + barrierK*aB, entryB - barrierK*aB, calHor)
    baseN += 1
    baseW += (fhB == 1 or (fhB == 0 and close > entryB)) ? 1 : 0
    if buySig[calHor]
        sigBar = bar_index[calHor]
        okB = (not uniqOn) or (sigBar - lastBuyBar >= calHor)
        if okB
            win = fhB == 1 or (fhB == 0 and close > entryB)
            buyN += 1
            buyW += win ? 1 : 0
            if sigBar >= last_bar_index - oosBars
                buyNo += 1
                buyWo += win ? 1 : 0
            lastBuyBar := sigBar
    if sellSig[calHor]
        sigBarS = bar_index[calHor]
        okS = (not uniqOn) or (sigBarS - lastSellBar >= calHor)
        if okS
            winS = fhB == -1 or (fhB == 0 and close < entryB)
            sellN += 1
            sellW += winS ? 1 : 0
            if sigBarS >= last_bar_index - oosBars
                sellNo += 1
                sellWo += winS ? 1 : 0
            lastSellBar := sigBarS

baseUp  = baseN > 0 ? baseW / baseN * 100.0 : na
baseDn  = baseN > 0 ? 100.0 - baseUp : na
buyHit  = buyN  > 0 ? buyW  / buyN  * 100.0 : na
sellHit = sellN > 0 ? sellW / sellN * 100.0 : na
buyHitO = buyNo  > 0 ? buyWo  / buyNo  * 100.0 : na
sellHitO= sellNo > 0 ? sellWo / sellNo * 100.0 : na
buyEdge  = (not na(buyHit)  and not na(baseUp)) ? buyHit  - baseUp : na
sellEdge = (not na(sellHit) and not na(baseDn)) ? sellHit - baseDn : na
buyStars  = f_stars(calib.wilsonLo(buyW, buyN, 1.96),  baseUp, buyN)
sellStars = f_stars(calib.wilsonLo(sellW, sellN, 1.96), baseDn, sellN)
buySurv  = (buyN  >= calMinN and not na(baseUp)) and (calib.wilsonLo(buyW, buyN, 2.24)  > baseUp)
sellSurv = (sellN >= calMinN and not na(baseDn)) and (calib.wilsonLo(sellW, sellN, 2.24) > baseDn)

// ── COST MODEL (Net R on the symmetric 1:1 barrier) ───────────────────────────────────────────
float buyNetR  = na(buyHit)  ? na : (2.0 * buyHit  / 100.0 - 1.0) - costR
float sellNetR = na(sellHit) ? na : (2.0 * sellHit / 100.0 - 1.0) - costR

// ── PLAIN-LANGUAGE VERDICT + CONVICTION ──────────────────────────────────────────────────────
longConv  = buyN  >= calMinN and not na(buyEdge)  and buyEdge  > 0 and buySurv  and not na(buyNetR)  and buyNetR  > 0
shortConv = sellN >= calMinN and not na(sellEdge) and sellEdge > 0 and sellSurv and not na(sellNetR) and sellNetR > 0
verdict = buySig ? "LONG SIGNAL" : sellSig ? "SHORT SIGNAL" : (zcUp or zcDn) ? "WATCH — weak quality" : bullDiv ? "WATCH — bull divergence" : bearDiv ? "WATCH — bear divergence" : "WAIT"
vCol    = buySig ? upC : sellSig ? dnC : (zcUp or bullDiv) ? upC : (zcDn or bearDiv) ? dnC : flatC
convTxt = (buySig and longConv) or (sellSig and shortConv) ? "High — edge survives test" : (buySig or sellSig) ? "Low — context only" : longConv or shortConv ? "Flips have edge here" : "No proven edge here"
convCol = ((buySig and longConv) or (sellSig and shortConv)) ? upC : flatC

// ── PLOTS (theme-aware) ──────────────────────────────────────────────────────────────────────
pObIn  = plot(strZone,  "Strong up edge", color.new(upC, 45), 1)
pObOut = plot(100.0,    "Up cap",  color.new(upC, 100), display = display.none)
fill(pObIn, pObOut, 100.0, 50.0, color.new(upC, 30), color.new(upC, 95), title = "Strong-up zone")
pOsIn  = plot(-strZone, "Strong dn edge", color.new(dnC, 45), 1)
pOsOut = plot(-100.0,   "Dn cap",  color.new(dnC, 100), display = display.none)
fill(pOsIn, pOsOut, -50.0, -100.0, color.new(dnC, 95), color.new(dnC, 30), title = "Strong-down zone")
plot(0, "Zero", gridC, 1)
bgcolor(tintBg ? (osc > strZone ? color.new(upC, 92) : osc < -strZone ? color.new(dnC, 92) : na) : na, title = "Strong-trend tint")

plot(osc, "Strength glow", color.new(wCol, 70), 8)
plot(osc, "Strength", color.new(wCol, 0), 2)

plotshape(buySig  ? osc : na, "Buy",  shape.triangleup,   location.absolute, color.new(upC,0), size = size.small)
plotshape(sellSig ? osc : na, "Sell", shape.triangledown, location.absolute, color.new(dnC,0), size = size.small)
plotshape(bullDiv ? oLy : na, "Bull div", shape.circle, location.absolute, color.new(upC,0), offset = -pivLen, size = size.tiny)
plotshape(bearDiv ? oHy : na, "Bear div", shape.circle, location.absolute, color.new(dnC,0), offset = -pivLen, size = size.tiny)
plotshape(bullDiv, "Bull div (price)", shape.xcross, location.belowbar, color.new(upC,0), offset = -pivLen, size = size.tiny, force_overlay = true)
plotshape(bearDiv, "Bear div (price)", shape.xcross, location.abovebar, color.new(dnC,0), offset = -pivLen, size = size.tiny, force_overlay = true)
plotshape(buySig,  "Buy mark",  shape.triangleup,   location.belowbar, color.new(upC,0), size = size.tiny, force_overlay = true)
plotshape(sellSig, "Sell mark", shape.triangledown, location.abovebar, color.new(dnC,0), size = size.tiny, force_overlay = true)

// ── DASHBOARD ───────────────────────────────────────────────────────────────────────────────
simple = audience == "Simple (plain language)"
var table st = table.new(f_pos(tblPos), 2, 14, frame_width = 1, border_width = 1)
if showTbl and barstate.islast
    color hdr   = color.new(upC, 0)
    color phCol = osc>=0?upC:dnC
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)
    int r = 0
    table.cell(st, 0, r, "Directional Strength", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, r, str.upper(phaseTxt), text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Verdict", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, verdict, text_color = vCol, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Conviction", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, calOn ? convTxt : "calibration off", text_color = convCol, bgcolor = panelBg, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Trend quality", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, str.tostring(quality*100,"#") + "%" + (quality>=qualMin?"":" (low)"), text_color = quality>=qualMin?txtMain:flatC, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    if not simple
        table.cell(st, 0, r, "Strength", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, str.tostring(osc,"#"), text_color = phCol, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Up / Down line", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, str.tostring(viPlus,"0.00") + " / " + str.tostring(viMinus,"0.00"), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
    if calOn
        string baseTxt = (na(baseUp) or na(baseDn)) ? "warming up" : "up " + str.tostring(baseUp,"0") + "%  dn " + str.tostring(baseDn,"0") + "%"
        string buyTxt  = buyN  < calMinN ? "warming " + str.tostring(buyN)  : "win " + str.tostring(buyHit,"0")  + "%  edge " + (nz(buyEdge)>=0?"+":"")  + str.tostring(buyEdge,"0")  + "  (" + str.tostring(buyN) + ")"
        string sellTxt = sellN < calMinN ? "warming " + str.tostring(sellN) : "win " + str.tostring(sellHit,"0") + "%  edge " + (nz(sellEdge)>=0?"+":"") + str.tostring(sellEdge,"0") + "  (" + str.tostring(sellN) + ")"
        table.cell(st, 0, r, "Base " + str.tostring(calHor) + "b", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, baseTxt, text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Long " + buyStars, text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, buyTxt, text_color = buyN<calMinN?flatC:upC, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Short " + sellStars, text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, sellTxt, text_color = sellN<calMinN?flatC:dnC, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        string netTxt = (na(buyNetR) or na(sellNetR)) ? "warming" : "L " + (buyNetR>=0?"+":"") + str.tostring(buyNetR,"0.00") + " · S " + (sellNetR>=0?"+":"") + str.tostring(sellNetR,"0.00") + " R  (cost " + str.tostring(costR,"0.00") + ")"
        color netCol = (na(buyNetR) or na(sellNetR)) ? flatC : (buyNetR > 0 or sellNetR > 0) ? upC : dnC
        table.cell(st, 0, r, "Net R", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, netTxt, text_color = netCol, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        if not simple
            string buyOTxt = buyNo  < calMinN ? "warming " + str.tostring(buyNo)  : "win " + str.tostring(buyHitO,"0")  + "%  (" + str.tostring(buyNo) + ")"
            string selOTxt = sellNo < calMinN ? "warming " + str.tostring(sellNo) : "win " + str.tostring(sellHitO,"0") + "%  (" + str.tostring(sellNo) + ")"
            table.cell(st, 0, r, "Out-of-sample", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
            table.cell(st, 1, r, "L " + buyOTxt + " · S " + selOTxt, text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
            r += 1
            table.cell(st, 0, r, "Multi-test", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
            table.cell(st, 1, r, "long " + (buySurv?"survives":"no") + " · short " + (sellSurv?"survives":"no"), text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
            r += 1
    if useHold
        table.cell(st, 0, r, "Whipsaw filter", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, "hold " + str.tostring(holdBars) + "b", text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
        r += 1
    table.cell(st, 0, r, "Note", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, "context, not advice", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)

// ── GENERIC EXPORTS (for use from other scripts) ─────────────────────────────────────────────
plot(osc,        "EXP_Oscillator",  color.new(color.gray,100), display = display.data_window)
plot(viPlus,     "EXP_UpLine",      color.new(color.gray,100), display = display.data_window)
plot(viMinus,    "EXP_DownLine",    color.new(color.gray,100), display = display.data_window)
plot(quality,    "EXP_TrendQuality",color.new(color.gray,100), display = display.data_window)
plot(buySig?1:0,  "EXP_BuySignal",  color.new(color.gray,100), display = display.data_window)
plot(sellSig?1:0, "EXP_SellSignal", color.new(color.gray,100), display = display.data_window)
plot(buySig?1:sellSig?-1:0, "EXP_Signal", color.new(color.gray,100), display = display.data_window)
plot(bullDiv?1:bearDiv?-1:0, "EXP_Divergence", color.new(color.gray,100), display = display.data_window)
plot(buyEdge,   "EXP_LongEdge",    color.new(color.gray,100), display = display.data_window)
plot(sellEdge,  "EXP_ShortEdge",   color.new(color.gray,100), display = display.data_window)
plot(na(buyNetR)  ? na : buyNetR,  "EXP_LongNetR",  color.new(color.gray,100), display = display.data_window)
plot(na(sellNetR) ? na : sellNetR, "EXP_ShortNetR", color.new(color.gray,100), display = display.data_window)

alertcondition(buySig,  "Long signal",  "Directional Strength: quality-confirmed flip up through zero")
alertcondition(sellSig, "Short signal", "Directional Strength: quality-confirmed flip down through zero")
alertcondition(bullDiv, "Bull divergence", "Directional Strength: bullish divergence vs price")
alertcondition(bearDiv, "Bear divergence", "Directional Strength: bearish divergence vs price")
alertcondition(ta.crossover(osc, strZone),   "Strong uptrend",   "Directional Strength: entered strong-up zone")
alertcondition(ta.crossunder(osc, -strZone), "Strong downtrend", "Directional Strength: entered strong-down zone")
````
