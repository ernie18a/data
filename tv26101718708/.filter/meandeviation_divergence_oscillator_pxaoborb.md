# Mean-Deviation Divergence Oscillator

- url: https://www.tradingview.com/script/pxaobOrB-Mean-Deviation-Divergence-Oscillator/
- type: indicator
- pine_id: PUB;9d934481de4a4add8d20832fb3edc571
- version: 4.0

## Description

Mean-Deviation Divergence Oscillator

A bounded oscillator that measures how far the typical price has stretched from its own recent mean, scaled by how much it normally deviates — so a reading tells you "how unusual is this move," not just "how big." That normalization makes its swings comparable across calm and volatile regimes and well suited to divergence. It adds higher-timeframe confirmation and a plain-language forward-calibration layer, so you can see at a glance whether a divergence is corroborated and whether it has actually paid on this symbol.

Why this construction (not a mashup for show). Each part fixes a flaw in naive divergence. Raw distance-from-mean isn't comparable across regimes — dividing by the average absolute deviation (with the conventional 0.015 scaling, chosen so that roughly 70–80% of readings fall within ±100) makes the oscillator regime-comparable, which is the whole reason it's a good divergence base. Higher-timeframe confirmation removes single-timeframe noise. Forward calibration removes blind faith: instead of assuming a divergence "should" reverse price, it measures whether it actually has, with realistic profit/stop outcomes. The normalized oscillator, the divergence engine, the MTF check and the calibration form one coherent tool.

How it works. Oscillator = (typical price − its moving average) ÷ (0.015 × mean absolute deviation), soft-bounded to a clean ±100 pane that auto-fits its own recent magnitude. Divergence is detected from confirmed price pivots versus the oscillator (regular and optional hidden). With MTF confirmation on, a divergence counts only if a same-direction divergence is also present on the chosen higher timeframe. Each signal is then labelled by a triple barrier — a profit target and equal stop in ATR units plus a time limit — split into in-sample and recent out-of-sample, with a confidence interval and a multiple-testing check.

How to use. Read the Verdict row (Bull/Bear divergence confirmed, "unconfirmed," or Wait) and the Conviction row, which reads "High" only when that divergence type shows a positive edge that survives the test on this symbol. A divergence is a reversal warning, not a trend signal — pair it with your own entry trigger and risk plan.

What's original. Higher-timeframe divergence confirmation on a mean-deviation normalized oscillator, the forward triple-barrier calibration with an out-of-sample split, and a conviction read that openly admits when there's no proven edge.

Inputs. Price/High/Low sources (change them for any market), reading mode (Simple/Pro), engine length and deviation scale, divergence and HTF-confirm controls, full calibration settings, and an auto-adapting dashboard legible on dark or light charts. Defaults are tuned for NSE:NIFTY1! intraday.

Honesty & limitations. Edge figures are computed on this chart's own history with overlapping windows and no costs — context, not a guaranteed backtest; past behaviour doesn't predict the future. Divergence is inherently early and can persist before price turns.

Disclaimer: for research and education only. Not financial advice. Trading carries risk of loss; manage your own positions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// MEAN-DEVIATION DIVERGENCE OSCILLATOR — Normalized Distance, MTF-Confirmed & Forward-Calibrated  v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.1 — Correctness + house-standard pass:
//        • Hoisted the HTF-divergence ta.valuewhen calls out of a short-circuiting `and` so they
//          run on every bar (Pine requirement for series functions; clears CW10004 and removes
//          wrong higher-timeframe confirmations that the skipped calls could produce).
//        • Clamped the auto HTF map so Daily/Weekly charts still request a genuinely higher frame.
//        • Added the MPL-2.0 licence header, an EXP_ Data-Window export bus, and a round-trip COST
//          model: a Net-R read where conviction now requires the edge to survive costs.
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   A bounded oscillator that measures how far the typical price has stretched from its own recent
//   mean, scaled by how much it normally deviates — so a reading is "how unusual is this move,"
//   not just "how big." That normalization is what makes its swings comparable across regimes and
//   well suited to divergence. It adds optional higher-timeframe confirmation and a plain-language
//   forward-calibration layer, so a non-technical reader can tell at a glance whether a divergence
//   is corroborated and whether it has actually paid on this symbol.
//
// WHY THIS CONSTRUCTION (read this if you think it is a mashup)
//   Each part fixes a flaw in naive divergence:
//     • Raw distance-from-mean is not comparable across calm and volatile regimes. Dividing by the
//       average absolute deviation (with the conventional 0.015 scaling, chosen so that roughly
//       70–80% of readings fall within ±100) makes the oscillator regime-comparable, which is the
//       whole reason it is a good divergence base.
//     • Higher-timeframe confirmation removes single-timeframe noise: a divergence that also shows
//       on a higher timeframe is far less likely to be a fluke.
//     • Forward calibration removes blind faith: instead of assuming a divergence "should" reverse
//       price, it measures whether it actually has, with realistic profit/stop outcomes.
//   The normalized oscillator, the divergence engine, the MTF check and the calibration form one
//   coherent tool — none alone is sufficient, which is why they are combined.
//
// HOW IT WORKS
//   Oscillator = (typical price − its moving average) ÷ (0.015 × mean absolute deviation), then
//   soft-bounded to a clean ±100 pane. Divergence is detected from CONFIRMED price pivots versus
//   the oscillator (regular and optional hidden). With MTF confirmation on, a divergence counts as
//   "confirmed" only if a same-direction divergence is also present on the chosen higher timeframe.
//   Each signal is then labelled by a TRIPLE BARRIER (profit target and equal stop in ATR units,
//   plus a time limit), split into in-sample and recent out-of-sample, with a confidence interval
//   and a multiple-testing check.
//
// HOW TO USE (plain language)
//   • Read the VERDICT row: Bull/Bear divergence (confirmed) = a corroborated signal just formed;
//     "unconfirmed" = present on this timeframe only; Wait = none.
//   • The CONVICTION row says whether that divergence type has a positive, statistically-surviving
//     edge on THIS chart. Low conviction = treat as context only.
//   • A divergence is a REVERSAL warning, not a trend signal — pair it with your own entry trigger
//     and risk plan. Best used alongside structure, not alone.
//
// NON-REPAINT  Pivots confirm pivot-length bars after the fact and never move. The higher-timeframe
//   read uses confirmed values only (no lookahead). Calibration logs and resolves on
//   barstate.isconfirmed only.
//
// CONCEPT CREDIT (technical attributions)
//   This script combines established, public-domain techniques: a mean-deviation normalized
//   distance oscillator from classical technical analysis; price-versus-oscillator divergence;
//   multi-timeframe confirmation; triple-barrier outcome labelling from standard supervised-
//   labelling practice in quantitative finance; the Wilson score interval for the proportion bound;
//   and the Bonferroni adjustment for multiple testing. Credit is due to the originators of each
//   technique. This is an original implementation combining them into one MTF-confirmed,
//   forward-calibrated divergence tool.
//
// DISCLAIMER  For research and education only. Edge figures are computed on this chart's own
//   history with overlapping windows and no costs — context, not a guaranteed backtest, and past
//   behaviour does not predict the future. Nothing here is financial advice. Trading carries risk
//   of loss; size and manage your own positions.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Mean-Deviation Divergence Oscillator", "MD Div", overlay = false, max_lines_count = 200, max_labels_count = 300)

// R1 · honest-stats standardization — the Wilson confidence math (and hit-rate) is now routed through the
// published calibration library, byte-identical to the prior local helper, so the oscillator, the divergence
// marks and every calibration number are UNCHANGED — only where the math is computed moves into the library.
// Pinned to the exact published v2 version so a later library update can't silently change this script.
import Market_Logic_India/ml_calib/2 as calib

// ──────────────────────────────────────────────────────────────────────────────────────────────
// INPUTS  (defaults tuned for NSE:NIFTY1! intraday; change the sources to use any market)
// ──────────────────────────────────────────────────────────────────────────────────────────────
gMain    = "1 · General"
srcPrice = input.source(hlc3, "Price source", group = gMain, tooltip = "Typical price by default (HLC3). Change the sources for any symbol/market — this script is asset-agnostic.")
srcHigh  = input.source(high, "High source",  group = gMain)
srcLow   = input.source(low,  "Low source",   group = gMain)
audience = input.string("Simple (plain language)", "Reading mode", options = ["Simple (plain language)", "Pro (full detail)"], group = gMain, tooltip = "Simple shows a verdict and conviction in words. Pro shows every number.")

gEng     = "2 · Oscillator engine"
len      = input.int(20, "Length", minval = 2, maxval = 200, group = gEng)
scaleK   = input.float(0.015, "Deviation scale", minval = 0.005, maxval = 0.05, step = 0.001, group = gEng, tooltip = "Conventional 0.015 keeps ~70–80% of readings within ±100. Lower = wider swings.")

gDiv     = "3 · Divergence"
pivLen   = input.int(5,  "Pivot length", minval = 1, maxval = 50, group = gDiv, tooltip = "Bars left and right that define a swing pivot. Larger = fewer, stronger pivots.")
divLook  = input.int(60, "Max bars between pivots", minval = 5, maxval = 300, group = gDiv)
showHid  = input.bool(true, "Hidden divergences", group = gDiv, tooltip = "Also detect hidden (trend-continuation) divergence, not just regular (reversal).")
drawLines= input.bool(true, "Draw divergence lines", group = gDiv)

gMTF     = "4 · Higher-timeframe confirm"
useMTF   = input.bool(true, "Require HTF agreement", group = gMTF, tooltip = "A divergence counts as 'confirmed' only if the higher timeframe also shows same-direction divergence. On by default.")
htfMode  = input.string("Auto (≈4–6×)", "Higher timeframe", options = ["Auto (≈4–6×)","Chart","5","15","30","60","120","240","D","W"], group = gMTF, tooltip = "Auto maps to a scalper-friendly multiple of your chart timeframe.")

gSig     = "5 · Zones"
obLvl    = input.float(50, "Overbought (bounded)", minval = 10, maxval = 95, group = gSig)
osLvl    = input.float(-50, "Oversold (bounded)", minval = -95, maxval = -10, group = gSig)

gCal     = "6 · Forward calibration"
calOn    = input.bool(true, "Run forward calibration", group = gCal, tooltip = "Score divergences forward on this chart. On by default — the core honesty feature.")
calHor   = input.int(15, "Time limit (bars)", minval = 2, maxval = 200, group = gCal)
barrierK = input.float(1.0, "Profit/stop size × ATR", minval = 0.1, maxval = 10.0, step = 0.1, group = gCal, tooltip = "A divergence wins if price reaches the profit target (this many ATRs) before the equal-sized stop, within the time limit.")
atrLen   = input.int(14, "ATR length", minval = 2, maxval = 100, group = gCal)
oosBars  = input.int(1500, "Out-of-sample window (recent bars)", minval = 100, maxval = 20000, group = gCal, tooltip = "Signals inside the last N bars are scored separately as out-of-sample.")
uniqOn   = input.bool(true, "Non-overlapping sampling", group = gCal, tooltip = "Skip a signal if the previous same-side one was within one time-limit — reduces double-counting.")
calMinN  = input.int(15, "Min sample for rating", minval = 5, maxval = 500, group = gCal)
costR    = input.float(0.30, "Round-trip cost (R) — subtracted for NET", minval = 0.0, maxval = 3.0, step = 0.05, group = gCal, tooltip = "Round-trip cost (brokerage + STT + slippage + optimistic fill) as a fraction of the barrier risk (Profit/stop × ATR). The barrier is symmetric 1:1, so gross expectancy in R = 2·hit% − 1; Net R subtracts this cost, and CONVICTION now requires the edge to survive it. On 1m NIFTY futures costs eat a large share of R, so a gross edge that ignores them is not tradeable.")

gUI      = "7 · Dashboard & appearance"
showTbl  = input.bool(true, "Show dashboard", group = gUI)
tblPos   = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = gUI)
dashTheme= input.string("Auto (match chart)", "Color theme", options = ["Auto (match chart)","Dark","Light"], group = gUI, tooltip = "Auto reads the chart background brightness and adapts table, text and line colors for visibility on any theme.")
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
f_htf() =>
    float tfm = timeframe.in_seconds(timeframe.period) / 60.0
    htfMode != "Auto (≈4–6×)" ? (htfMode=="Chart"?timeframe.period:htfMode) : tfm<=1?"5" : tfm<=2?"10" : tfm<=3?"15" : tfm<=5?"15" : tfm<=15?"60" : tfm<=30?"120" : tfm<=60?"240" : tfm<=240?"D" : tfm<=1440?"W" : "M"
f_md(float src, simple int n, simple float k) =>
    ma = ta.sma(src, n)
    md = ta.dev(src, n)
    md != 0 ? (src - ma) / (k * md) : 0.0

// ── OSCILLATOR ────────────────────────────────────────────────────────────────────────────────
raw = f_md(srcPrice, len, scaleK)
// Adaptive display scale: fit the wave to its own recent magnitude so it fills the pane
// without saturating against the rails on spiky symbols/timeframes.
absRaw    = math.abs(raw)
scaleRaw  = ta.percentile_linear_interpolation(absRaw, 200, 85)
dispScale = math.max(50.0, nz(scaleRaw, 150.0)) * 1.30
osc = f_squash(raw, dispScale)

// ── DIVERGENCE (chart timeframe) — detected on the raw reading (stable), drawn on the display ──
ph = ta.pivothigh(srcHigh, pivLen, pivLen)
pl = ta.pivotlow(srcLow, pivLen, pivLen)
phC = not na(ph)
plC = not na(pl)
curX = bar_index - pivLen
oH=raw[pivLen], pHh=srcHigh[pivLen], oHy=osc[pivLen]
poH=ta.valuewhen(phC, raw[pivLen],1), ppH=ta.valuewhen(phC, srcHigh[pivLen],1), pxH=ta.valuewhen(phC, bar_index-pivLen,1)
poHy=ta.valuewhen(phC, osc[pivLen],1)
bearReg = phC and pHh>ppH and oH<poH and (curX-pxH<=divLook)
bearHid = showHid and phC and pHh<ppH and oH>poH and (curX-pxH<=divLook)
oL=raw[pivLen], pLl=srcLow[pivLen], oLy=osc[pivLen]
poL=ta.valuewhen(plC, raw[pivLen],1), ppL=ta.valuewhen(plC, srcLow[pivLen],1), pxL=ta.valuewhen(plC, bar_index-pivLen,1)
poLy=ta.valuewhen(plC, osc[pivLen],1)
bullReg = plC and pLl<ppL and oL>poL and (curX-pxL<=divLook)
bullHid = showHid and plC and pLl>ppL and oL<poL and (curX-pxL<=divLook)

// ── HIGHER-TIMEFRAME DIVERGENCE STATE (confirmed values only) ────────────────────────────────
htfTf = f_htf()
[hRaw, hHigh, hLow] = request.security(syminfo.tickerid, htfTf, [raw, srcHigh, srcLow], lookahead = barmerge.lookahead_off)
hph = ta.pivothigh(hHigh, 2, 2)
hpl = ta.pivotlow(hLow, 2, 2)
hphC = not na(hph)
hplC = not na(hpl)
// STATEFUL HOIST: ta.valuewhen must run every bar. Behind the short-circuiting `and` (hphC/hplC are
// true only on the HTF pivot bars) it was skipped on most bars, corrupting its series. Evaluate the
// four calls unconditionally at top level, then use the results in the boolean.
float vwHiHigh = ta.valuewhen(hphC, hHigh[2], 1)
float vwHiRaw  = ta.valuewhen(hphC, hRaw[2], 1)
float vwLoLow  = ta.valuewhen(hplC, hLow[2], 1)
float vwLoRaw  = ta.valuewhen(hplC, hRaw[2], 1)
hBearRaw = hphC and hHigh[2] > vwHiHigh and hRaw[2] < vwHiRaw
hBullRaw = hplC and hLow[2]  < vwLoLow  and hRaw[2] > vwLoRaw
var bool htfBear = false
var bool htfBull = false
htfBear := hBearRaw ? true : hBullRaw ? false : htfBear
htfBull := hBullRaw ? true : hBearRaw ? false : htfBull

// ── COMBINE ──────────────────────────────────────────────────────────────────────────────────
bullDivRaw = bullReg or bullHid
bearDivRaw = bearReg or bearHid
bullConf = bullDivRaw and (not useMTF or htfBull)
bearConf = bearDivRaw and (not useMTF or htfBear)
buySig  = bullConf
sellSig = bearConf

var line[] divLines = array.new_line()
if drawLines and bearConf
    ln = line.new(int(pxH), poHy, curX, oHy, color = color.new(dnC,25), width = 2)
    array.push(divLines, ln)
if drawLines and bullConf
    ln = line.new(int(pxL), poLy, curX, oLy, color = color.new(upC,25), width = 2)
    array.push(divLines, ln)
if array.size(divLines) > 14
    line.delete(array.shift(divLines))

phaseTxt = osc > obLvl ? "Overbought" : osc < osLvl ? "Oversold" : osc >= 0 ? "Bullish" : "Bearish"
wCol = osc >= 0 ? upC : dnC

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

// NET-OF-COST expectancy in R. The barrier is symmetric 1:1, so gross R = 2·hit% − 1; subtract cost.
float buyNetR  = na(buyHit)  ? na : (2.0 * buyHit  / 100.0 - 1.0) - costR
float sellNetR = na(sellHit) ? na : (2.0 * sellHit / 100.0 - 1.0) - costR

// ── PLAIN-LANGUAGE VERDICT + CONVICTION — now requires the edge to clear base (Wilson) AND survive cost ──
longConv  = buyN  >= calMinN and not na(buyEdge)  and buyEdge  > 0 and buySurv  and not na(buyNetR)  and buyNetR  > 0
shortConv = sellN >= calMinN and not na(sellEdge) and sellEdge > 0 and sellSurv and not na(sellNetR) and sellNetR > 0
verdict = bullConf ? "BULL DIVERGENCE" : bearConf ? "BEAR DIVERGENCE" : (bullDivRaw and useMTF) ? "Bull div — unconfirmed" : (bearDivRaw and useMTF) ? "Bear div — unconfirmed" : "WAIT"
vCol    = bullConf ? upC : bearConf ? dnC : bullDivRaw ? upC : bearDivRaw ? dnC : flatC
convTxt = (bullConf and longConv) or (bearConf and shortConv) ? "High — edge survives test" : (bullConf or bearConf) ? "Low — context only" : longConv or shortConv ? "Divergences have edge here" : "No proven edge here"
convCol = ((bullConf and longConv) or (bearConf and shortConv)) ? upC : flatC

// ── PLOTS (theme-aware) ──────────────────────────────────────────────────────────────────────
pObIn  = plot(obLvl,  "OB edge", color.new(dnC, 45), 1)
pObOut = plot(100.0,  "OB cap",  color.new(dnC, 100), display = display.none)
fill(pObIn, pObOut, 100.0, 50.0, color.new(dnC, 30), color.new(dnC, 95), title = "Overbought zone")
pOsIn  = plot(osLvl,  "OS edge", color.new(upC, 45), 1)
pOsOut = plot(-100.0, "OS cap",  color.new(upC, 100), display = display.none)
fill(pOsIn, pOsOut, -50.0, -100.0, color.new(upC, 95), color.new(upC, 30), title = "Oversold zone")
plot(0, "Zero", gridC, 1)

plot(osc, "Oscillator glow", color.new(wCol, 70), 8)
plot(osc, "Oscillator", color.new(wCol, 0), 2)

plotshape(bullConf ? oLy : na, "Bull div", shape.circle, location.absolute, color.new(upC,0), offset = -pivLen, size = size.tiny)
plotshape(bearConf ? oHy : na, "Bear div", shape.circle, location.absolute, color.new(dnC,0), offset = -pivLen, size = size.tiny)
plotshape(buySig,  "Buy mark",  shape.triangleup,   location.belowbar, color.new(upC,0), size = size.tiny, force_overlay = true)
plotshape(sellSig, "Sell mark", shape.triangledown, location.abovebar, color.new(dnC,0), size = size.tiny, force_overlay = true)

// ── DASHBOARD ───────────────────────────────────────────────────────────────────────────────
simple = audience == "Simple (plain language)"
var table st = table.new(f_pos(tblPos), 2, 13, frame_width = 1, border_width = 1)
if showTbl and barstate.islast
    color hdr   = color.new(upC, 0)
    color phCol = osc>obLvl?dnC : osc<osLvl?upC : osc>=0?upC:dnC
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)
    int r = 0
    table.cell(st, 0, r, "Mean-Deviation Div", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, r, str.upper(phaseTxt), text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Verdict", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, verdict, text_color = vCol, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Conviction", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, calOn ? convTxt : "calibration off", text_color = convCol, bgcolor = panelBg, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "HTF confirm", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, useMTF ? (str.upper(htfTf) + (htfBull ? " · bull" : htfBear ? " · bear" : " · none")) : "off", text_color = htfBull?upC:htfBear?dnC:txtMain, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    if not simple
        table.cell(st, 0, r, "Reading", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, str.tostring(raw,"#"), text_color = phCol, bgcolor = panelBg, text_size = size.tiny)
        r += 1
    if calOn
        string baseTxt = (na(baseUp) or na(baseDn)) ? "warming up" : "up " + str.tostring(baseUp,"0") + "%  dn " + str.tostring(baseDn,"0") + "%"
        string buyTxt  = buyN  < calMinN ? "warming " + str.tostring(buyN)  : "win " + str.tostring(buyHit,"0")  + "%  edge " + (nz(buyEdge)>=0?"+":"")  + str.tostring(buyEdge,"0")  + "  (" + str.tostring(buyN) + ")"
        string sellTxt = sellN < calMinN ? "warming " + str.tostring(sellN) : "win " + str.tostring(sellHit,"0") + "%  edge " + (nz(sellEdge)>=0?"+":"") + str.tostring(sellEdge,"0") + "  (" + str.tostring(sellN) + ")"
        table.cell(st, 0, r, "Base " + str.tostring(calHor) + "b", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, baseTxt, text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Bull " + buyStars, text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, buyTxt, text_color = buyN<calMinN?flatC:upC, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Bear " + sellStars, text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, sellTxt, text_color = sellN<calMinN?flatC:dnC, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        string netTxt = (na(buyNetR) or na(sellNetR)) ? "warming" : "L " + (buyNetR>=0?"+":"") + str.tostring(buyNetR,"0.00") + " · S " + (sellNetR>=0?"+":"") + str.tostring(sellNetR,"0.00") + " R  (cost " + str.tostring(costR,"0.00") + ")"
        color netCol = (na(buyNetR) or na(sellNetR)) ? flatC : (buyNetR > 0 or sellNetR > 0) ? upC : dnC
        table.cell(st, 0, r, "Net R", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, netTxt, text_color = netCol, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        if not simple
            string buyOTxt = buyNo  < calMinN ? "warming " + str.tostring(buyNo)  : "win " + str.tostring(buyHitO,"0")  + "%  (" + str.tostring(buyNo) + ")"
            string selOTxt = sellNo < calMinN ? "warming " + str.tostring(sellNo) : "win " + str.tostring(sellHitO,"0") + "%  (" + str.tostring(sellNo) + ")"
            table.cell(st, 0, r, "Out-of-sample", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
            table.cell(st, 1, r, "Bu " + buyOTxt + " · Be " + selOTxt, text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
            r += 1
            table.cell(st, 0, r, "Multi-test", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
            table.cell(st, 1, r, "bull " + (buySurv?"survives":"no") + " · bear " + (sellSurv?"survives":"no"), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
            r += 1
    table.cell(st, 0, r, "Note", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, "reversal warning, not advice", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)

// ── EXPORTS (Data Window — consume from other scripts via input.source()) ────────────────────
plot(raw,       "EXP_Reading",     color.new(color.gray,100), display = display.data_window)
plot(osc,       "EXP_OscBounded",  color.new(color.gray,100), display = display.data_window)
plot(bullConf ? 1 : bearConf ? -1 : 0, "EXP_Signal", color.new(color.gray,100), display = display.data_window)   // +1 bull div · -1 bear div · 0
plot(bullConf?1:0, "EXP_BullDiv",  color.new(color.gray,100), display = display.data_window)
plot(bearConf?1:0, "EXP_BearDiv",  color.new(color.gray,100), display = display.data_window)
plot(htfBull?1:htfBear?-1:0, "EXP_HtfBias", color.new(color.gray,100), display = display.data_window)
plot(buyEdge,   "EXP_BullEdge",    color.new(color.gray,100), display = display.data_window)
plot(sellEdge,  "EXP_BearEdge",    color.new(color.gray,100), display = display.data_window)
plot(na(buyNetR)  ? na : buyNetR,  "EXP_BullNetR", color.new(color.gray,100), display = display.data_window)
plot(na(sellNetR) ? na : sellNetR, "EXP_BearNetR", color.new(color.gray,100), display = display.data_window)

alertcondition(bullConf, "Bull divergence", "Mean-Deviation Divergence: confirmed bullish divergence")
alertcondition(bearConf, "Bear divergence", "Mean-Deviation Divergence: confirmed bearish divergence")
alertcondition(ta.crossover(raw, 0),  "Crossed above zero", "Mean-Deviation oscillator above zero")
alertcondition(ta.crossunder(raw, 0), "Crossed below zero", "Mean-Deviation oscillator below zero")
````
