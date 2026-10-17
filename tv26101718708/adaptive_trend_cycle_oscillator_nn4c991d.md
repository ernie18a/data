# Adaptive Trend Cycle Oscillator

- url: https://www.tradingview.com/script/Nn4c991d-Adaptive-Trend-Cycle-Oscillator/
- type: indicator
- pine_id: PUB;32701615886f43e0a13206121b0080c2
- version: 3.0

## Description

Adaptive Trend Cycle Oscillator

A bounded cycle-timing oscillator that does two things most cycle tools don't: it tunes its own period to the market's measured rhythm, and it scores its own signals forward on your chart in plain language — so you can see at a glance whether to act or wait.

What it is. A 0-100-style cycle line (shown −100…+100) that highlights up-phases and down-phases and marks turns out of oversold/overbought. A dashboard translates the current state into a one-word verdict and an honest conviction read.

Why these parts are combined (not a mashup for show). Three classical ideas are fused because each fixes the previous one's flaw. A trend-difference line (fast average minus slow average) captures direction but is unbounded and late at turns. Running it through a double stochastic normalization bounds it and sharpens the cyclical phase, so reversals show sooner with less whipsaw. The remaining weakness is the fixed normalization length — real cycles stretch and compress — so the length is set from a measured dominant cycle (autocorrelation of a band-passed price), making the oscillator self-tuning. The three only work as one tool; separately each is incomplete.

How it works. (1) Dominant cycle: band-pass filter → autocorrelation across lags → Fourier transform → power spectrum → dominant period via its centre of gravity. (2) Oscillator: trend-difference → stochastic over the measured period → smooth → stochastic → smooth. (3) Calibration: each signal is labelled by a triple barrier — a profit target and an equal stop in ATR units, plus a time limit — so a "win" means the target was reached before the stop. Results split into in-sample and recent out-of-sample, with a confidence interval and a multiple-testing check.

How to use. Read the Verdict row first (Long/Short signal, Watch, or Wait). Check Conviction — it only reads "High" when that signal type shows a positive edge that survives the statistical test on this symbol; otherwise treat the signal as context. Green wave above the mid line is an up-phase, red below is a down-phase; shaded bands are extremes. Best used alongside your own trend and risk plan, not alone.

What's original. The self-tuning period, the forward triple-barrier calibration with an out-of-sample split, and a conviction read that openly admits when there's no proven edge — rather than presenting every signal as equally reliable.

Inputs. Price source (change it to use any market), reading mode (Simple/Pro), cycle and self-tuning controls, signal zones, full calibration settings, and an auto-adapting dashboard that stays legible on dark or light charts. Defaults are tuned for NSE:NIFTY1! intraday.

Honesty & limitations. Edge figures are computed on this chart's own history with overlapping windows and no costs — context, not a guaranteed backtest; past behaviour doesn't predict the future, and the cycle estimate lags at regime shifts.

Disclaimer: for research and education only. Not financial advice. Trading carries risk of loss; manage your own positions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// ADAPTIVE TREND CYCLE OSCILLATOR — Self-Tuning Period & Forward-Calibrated                   v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.1 — Robustness + house-standard pass:
//        • Cycle-engine guard (shared with the Dominant Cycle family): the self-tuning
//          autocorrelation periodogram now uses a one-time DFT trig table instead of calling
//          math.cos/math.sin thousands of times per bar — identical output, far lighter, so it no
//          longer risks the calculation-timeout on deep history / very low timeframes.
//        • Added a warm-up guard: while adaptive, signals are held (dashboard shows "warming up")
//          until the periodogram has enough history to tune the cycle meaningfully.
//        • Added the MPL-2.0 licence header, an EXP_ Data-Window export bus, and a round-trip COST
//          model (Net R): conviction now requires a signal that also survives trading costs.
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   A bounded 0-100 cycle-timing oscillator that turns earlier and cleaner than a plain momentum
//   line, with two things most cycle oscillators lack: (1) it MEASURES the market's current
//   dominant cycle and tunes itself to it instead of using a fixed length, and (2) it scores its
//   own signals forward on the very chart you are viewing, in plain language, so a non-technical
//   reader can see at a glance whether to act or wait.
//
// WHY THESE PARTS ARE COMBINED (read this if you think it is a mashup)
//   Three classical ideas are fused because each fixes a flaw in the previous one:
//     • A trend-difference line (fast average minus slow average) captures direction but is
//       unbounded and lags at turns.
//     • Passing it through a DOUBLE stochastic normalization bounds it to 0-100 and sharpens the
//       cyclical phase, so reversals register sooner with less whipsaw than a single oscillator.
//     • A FIXED normalization length is the remaining weak point — real cycles lengthen and
//       shorten — so the length is set from a measured DOMINANT CYCLE (autocorrelation of a
//       band-passed price), making the whole oscillator self-tuning.
//   None of the three alone does the job; together they form one coherent timing tool, not a
//   stack of separate studies. A forward-calibration layer then measures, honestly, whether the
//   resulting turns actually pay on this symbol.
//
// HOW IT WORKS
//   1) Dominant cycle: band-pass (high-pass + smoother) → autocorrelation across lags → discrete
//      Fourier transform → power spectrum → dominant period via its centre of gravity.
//   2) Oscillator: trend-difference → stochastic over the measured period → smooth → stochastic →
//      smooth → 0-100 line. Signals: cross up out of oversold (long), down out of overbought (short).
//   3) Calibration: every signal is labelled by a TRIPLE BARRIER (a profit target and a stop, both
//      in ATR units, plus a time limit). A signal "wins" only if the profit barrier is touched
//      before the stop within the time limit — far more realistic than a close-to-close return.
//      Results are split into in-sample and a recent out-of-sample window, optionally de-overlapped,
//      and a confidence interval with a multiple-testing check tells you if any edge is real.
//
// HOW TO USE (plain language)
//   • Read the VERDICT row first. "Long signal / Short signal" = a fresh turn just fired.
//     "Watch" = approaching a zone. "Wait" = no edge or mid-range.
//   • The CONVICTION row tells you if that signal type has a positive, statistically-surviving
//     edge on THIS chart. Low conviction = treat as context only.
//   • Green wave above the mid line = up-phase; red below = down-phase. Shaded bands = extremes.
//   • This is a timing/context tool, best used with your own trend and risk plan — not alone.
//
// NON-REPAINT  Reads confirmed closes; calibration logs and resolves only on barstate.isconfirmed.
//
// PERFORMANCE  The self-tuning periodogram uses nested loops and is heavy on deep history / very
//   low timeframes. If the script is slow, turn "Self-tuning cycle" off or lower "Max period".
//
// CONCEPT CREDIT (technical attributions)
//   This script combines long-established, public-domain technical and quantitative techniques:
//   trend-difference momentum and the double-stochastic cycle treatment from classical technical
//   analysis; a band-pass / autocorrelation periodogram dominant-cycle estimator from the digital-
//   signal-processing tradition applied to markets; triple-barrier outcome labelling from standard
//   supervised-labelling practice in quantitative finance; the Wilson score interval for the
//   proportion confidence bound; and the Bonferroni adjustment for multiple testing. Credit is due
//   to the originators of each technique within those fields. This is an original implementation
//   combining them into one self-tuning, forward-calibrated tool.
//
// DISCLAIMER  For research and education only. The edge figures are computed on this chart's own
//   history with overlapping windows and no costs — they are context, not a guaranteed backtest,
//   and past behaviour does not predict the future. The dominant-cycle estimate is approximate and
//   lags at regime shifts. Nothing here is financial advice. Trading carries risk of loss; size
//   and manage your own positions.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Adaptive Trend Cycle Oscillator", "ATC Osc", overlay = false, max_lines_count = 100, max_labels_count = 200)

// ──────────────────────────────────────────────────────────────────────────────────────────────
// INPUTS  (defaults tuned for NSE:NIFTY1! intraday; change the source to use any market)
// ──────────────────────────────────────────────────────────────────────────────────────────────
gMain    = "1 · General"
srcPrice = input.source(close, "Price source", group = gMain, tooltip = "Raw data the oscillator reads. Default close. Change for any symbol/market — this script is asset-agnostic.")
audience = input.string("Simple (plain language)", "Reading mode", options = ["Simple (plain language)", "Pro (full detail)"], group = gMain, tooltip = "Simple shows a verdict and conviction in words. Pro shows every number.")

gCycle   = "2 · Cycle engine"
fastLen  = input.int(23, "Fast average", minval = 2,  maxval = 100, group = gCycle)
slowLen  = input.int(50, "Slow average", minval = 5,  maxval = 200, group = gCycle)
factor   = input.float(0.5, "Responsiveness", minval = 0.1, maxval = 1.0, step = 0.05, group = gCycle, tooltip = "Higher = faster, more reactive. Lower = smoother.")
useSS    = input.bool(true, "Low-lag smoothing", group = gCycle, tooltip = "Use a low-lag filter for the averages instead of a standard EMA — fewer late turns. On by default.")

gAdapt   = "3 · Self-tuning period"
useAdapt = input.bool(true, "Self-tuning cycle", group = gAdapt, tooltip = "Measure the live dominant cycle and tune the oscillator to it. On by default. Turn off for speed or to use a fixed length.")
cycLen   = input.int(10, "Fixed period (when self-tuning off)", minval = 3, maxval = 50, group = gAdapt)
minPer   = input.int(10, "Min period", minval = 6,  maxval = 20, group = gAdapt)
maxPer   = input.int(48, "Max period", minval = 20, maxval = 60, group = gAdapt)
hpPer    = input.int(48, "Band-pass length", minval = 20, maxval = 120, group = gAdapt)
ssRoof   = input.int(10, "Band-pass smoothing", minval = 4, maxval = 30, group = gAdapt)
avgLen   = input.int(3,  "Autocorrelation average", minval = 1, maxval = 10, group = gAdapt)

gCyc2    = "3b · Cycle-strength gate (optional)"
cycGate  = input.bool(false, "Gate signals by cycle strength", group = gCyc2, tooltip = "OFF = original behaviour (default). ON = fire turns only when a real dominant cycle is present (strong autocorrelation at the cycle period). Cycle-timing signals are unreliable in trends or when no clear cycle exists. Watch the calibration Edge to confirm it helps.")
cycThr   = input.float(0.30, "Min cycle strength", minval = 0.0, maxval = 0.95, step = 0.05, group = gCyc2)

gSig     = "4 · Signal zones"
osLvl    = input.int(25, "Oversold level",   minval = 1, maxval = 49, group = gSig)
obLvl    = input.int(75, "Overbought level", minval = 51, maxval = 99, group = gSig)

gCal     = "5 · Forward calibration"
calOn    = input.bool(true, "Run forward calibration", group = gCal, tooltip = "Score signals forward on this chart. On by default — it is the core honesty feature.")
calHor   = input.int(10, "Time limit (bars)", minval = 2, maxval = 200, group = gCal)
barrierK = input.float(1.0, "Profit/stop size × ATR", minval = 0.1, maxval = 10.0, step = 0.1, group = gCal, tooltip = "A signal wins if price reaches the profit target (this many ATRs) before hitting the equal-sized stop, within the time limit.")
atrLen   = input.int(14, "ATR length", minval = 2, maxval = 100, group = gCal)
oosBars  = input.int(1500, "Out-of-sample window (recent bars)", minval = 100, maxval = 20000, group = gCal, tooltip = "Signals inside the last N bars are scored separately as out-of-sample.")
uniqOn   = input.bool(true, "Non-overlapping sampling", group = gCal, tooltip = "Skip a signal if the previous same-side one was within one time-limit — reduces double-counting.")
calMinN  = input.int(20, "Min sample for rating", minval = 5, maxval = 500, group = gCal)
costR    = input.float(0.30, "Round-trip cost (R) — subtracted for NET", minval = 0.0, maxval = 3.0, step = 0.05, group = gCal, tooltip = "Round-trip cost (brokerage + STT + slippage + optimistic fill) as a fraction of the barrier risk (Profit/stop × ATR). The barrier is symmetric 1:1, so gross expectancy in R = 2·hit% − 1; Net R subtracts this cost, and CONVICTION now requires the edge to survive it. On 1m NIFTY futures costs eat a large share of R, so a gross edge that ignores them is not tradeable.")

gUI      = "6 · Dashboard & appearance"
showTbl  = input.bool(true, "Show dashboard", group = gUI)
tblPos   = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = gUI)
dashTheme= input.string("Auto (match chart)", "Color theme", options = ["Auto (match chart)","Dark","Light"], group = gUI, tooltip = "Auto reads the chart background brightness and adapts table, text and line colors for visibility on any theme.")
tintBg   = input.bool(true, "Tint pane in extremes", group = gUI)
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
f_stoch(float s, int len) =>
    ll = ta.lowest(s, len)
    hh = ta.highest(s, len)
    hh == ll ? 0.0 : (s - ll) / (hh - ll) * 100.0
f_ss(float s, simple int len) =>
    f  = 1.414 * math.pi / math.max(len, 1)
    a1 = math.exp(-f)
    c2 = 2 * a1 * math.cos(f)
    c3 = -a1 * a1
    c1 = 1 - c2 - c3
    var float v = na
    v := na(v[1]) or na(v[2]) ? s : c1 * (s + nz(s[1])) / 2 + c2 * nz(v[1]) + c3 * nz(v[2])
    v
f_wilson(int w, int n, float z) =>
    if n <= 0
        na
    else
        p = w / n
        (p + z*z/(2*n) - z*math.sqrt(p*(1-p)/n + z*z/(4*n*n))) / (1 + z*z/n) * 100.0
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

// ── DOMINANT CYCLE (band-pass + autocorrelation periodogram) ──────────────────────────────────
hpA = (math.cos(0.707*2*math.pi/hpPer) + math.sin(0.707*2*math.pi/hpPer) - 1) / math.cos(0.707*2*math.pi/hpPer)
var float hpf = 0.0
hpf := na(hpf[1]) or na(hpf[2]) ? 0.0 : (1 - hpA/2)*(1 - hpA/2)*(srcPrice - 2*nz(srcPrice[1]) + nz(srcPrice[2])) + 2*(1 - hpA)*nz(hpf[1]) - (1 - hpA)*(1 - hpA)*nz(hpf[2])
filt = f_ss(hpf, ssRoof)

var corr  = array.new_float(maxPer + 1, 0.0)
var sqSum = array.new_float(maxPer + 1, 0.0)
var rPwr  = array.new_float(maxPer + 1, 0.0)
var float domCycle = 20.0

// One-time DFT trig table. cos(2π·n/period) and sin(2π·n/period) depend ONLY on the integers
// (period, n) — never on price — so they are constant for a given Min/Max period. Building them
// once on the first bar replaces thousands of math.cos/math.sin calls PER BAR in the spectrum loop
// below (this script's heaviest cost) with plain array reads and identical output. Indexed
// period*(maxPer+1)+n. Rebuilt automatically if the period inputs change.
var float[] cosTab = na
var float[] sinTab = na
if barstate.isfirst
    int tabN = (maxPer + 1) * (maxPer + 1)
    cosTab := array.new_float(tabN, 0.0)
    sinTab := array.new_float(tabN, 0.0)
    for period = minPer to maxPer
        for n = 0 to maxPer
            int idx = period * (maxPer + 1) + n
            array.set(cosTab, idx, math.cos(2*math.pi*n/period))
            array.set(sinTab, idx, math.sin(2*math.pi*n/period))

if useAdapt
    for lag = 0 to maxPer
        float Sx = 0.0
        float Sy = 0.0
        float Sxx = 0.0
        float Syy = 0.0
        float Sxy = 0.0
        for count = 0 to avgLen - 1
            X = nz(filt[count])
            Y = nz(filt[lag + count])
            Sx += X
            Sy += Y
            Sxx += X * X
            Syy += Y * Y
            Sxy += X * Y
        denom = (avgLen*Sxx - Sx*Sx) * (avgLen*Syy - Sy*Sy)
        float c = denom > 0 ? (avgLen*Sxy - Sx*Sy) / math.sqrt(denom) : 0.0
        array.set(corr, lag, c)
    for period = minPer to maxPer
        float cosP = 0.0
        float sinP = 0.0
        int base = period * (maxPer + 1)
        for n = avgLen to maxPer
            cc = array.get(corr, n)
            cosP += cc * array.get(cosTab, base + n)
            sinP += cc * array.get(sinTab, base + n)
        array.set(sqSum, period, cosP*cosP + sinP*sinP)
    for period = minPer to maxPer
        prev = array.get(rPwr, period)
        cur  = array.get(sqSum, period)
        array.set(rPwr, period, 0.2*cur + 0.8*prev)
    float maxPwr = 0.0
    for period = minPer to maxPer
        maxPwr := math.max(maxPwr, array.get(rPwr, period))
    float Spx = 0.0
    float Sp  = 0.0
    for period = minPer to maxPer
        pw = maxPwr > 0 ? array.get(rPwr, period) / maxPwr : 0.0
        if pw >= 0.5
            Spx += period * pw
            Sp  += pw
    domCycle := Sp > 0 ? Spx / Sp : nz(domCycle[1], 20.0)
    domCycle := math.max(minPer, math.min(maxPer, domCycle))

cycAdapt = int(math.round(domCycle))
cycUsed  = useAdapt ? math.max(minPer, math.min(maxPer, cycAdapt)) : cycLen
float cycStr = math.max(0.0, array.get(corr, int(cycUsed)))   // autocorrelation at the used period = cycle strength
bool  cycOk = not cycGate or cycStr >= cycThr

// ── OSCILLATOR ────────────────────────────────────────────────────────────────────────────────
emaFast = ta.ema(srcPrice, fastLen)
emaSlow = ta.ema(srcPrice, slowLen)
ssFast  = f_ss(srcPrice, fastLen)
ssSlow  = f_ss(srcPrice, slowLen)
maFast  = useSS ? ssFast : emaFast
maSlow  = useSS ? ssSlow : emaSlow
trendDiff = maFast - maSlow

k1 = f_stoch(trendDiff, cycUsed)
var float d1 = na
d1 := na(d1[1]) ? k1 : d1[1] + factor * (k1 - d1[1])
k2 = f_stoch(d1, cycUsed)
var float osc = na
osc := na(osc[1]) ? k2 : osc[1] + factor * (k2 - osc[1])
oscC = (osc - 50) * 2

wCol = osc >= 50 ? upC : dnC
// ta.crossover/crossunder are stateful — hoist them to top level so the warm-up guard never
// short-circuits them (they must run every bar), then compose the gated signal from the results.
bool xUp = ta.crossover(osc, osLvl)
bool xDn = ta.crossunder(osc, obLvl)
// Robustness: while adaptive, hold signals until the periodogram has enough history to be meaningful.
bool cycleReady = not useAdapt or bar_index >= maxPer + avgLen + ssRoof * 2
buySig  = cycleReady and xUp and cycOk
sellSig = cycleReady and xDn and cycOk
phaseTxt = not cycleReady ? "Warming up" : osc > obLvl ? "Overbought" : osc < osLvl ? "Oversold" : osc >= 50 ? "Up-phase" : "Down-phase"

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
buyStars  = f_stars(f_wilson(buyW, buyN, 1.96),  baseUp, buyN)
sellStars = f_stars(f_wilson(sellW, sellN, 1.96), baseDn, sellN)
buySurv  = (buyN  >= calMinN and not na(baseUp)) and (f_wilson(buyW, buyN, 2.24)  > baseUp)
sellSurv = (sellN >= calMinN and not na(baseDn)) and (f_wilson(sellW, sellN, 2.24) > baseDn)

// COST MODEL (Net R on the symmetric 1:1 barrier)
float buyNetR  = na(buyHit)  ? na : (2.0 * buyHit  / 100.0 - 1.0) - costR
float sellNetR = na(sellHit) ? na : (2.0 * sellHit / 100.0 - 1.0) - costR

// ── PLAIN-LANGUAGE VERDICT + CONVICTION ──────────────────────────────────────────────────────
longConv  = buyN  >= calMinN and not na(buyEdge)  and buyEdge  > 0 and buySurv  and not na(buyNetR)  and buyNetR  > 0
shortConv = sellN >= calMinN and not na(sellEdge) and sellEdge > 0 and sellSurv and not na(sellNetR) and sellNetR > 0
verdict = not cycleReady ? "WARMING UP — gathering data" : buySig ? "LONG SIGNAL" : sellSig ? "SHORT SIGNAL" : osc < osLvl ? "WATCH — long setup" : osc > obLvl ? "WATCH — short setup" : "WAIT"
vCol    = buySig ? upC : sellSig ? dnC : (osc < osLvl ? upC : osc > obLvl ? dnC : flatC)
convTxt = (buySig and longConv) or (sellSig and shortConv) ? "High — edge survives test" : (buySig or sellSig) ? "Low — context only" : longConv or shortConv ? "Setups have edge here" : "No proven edge here"
convCol = ((buySig and longConv) or (sellSig and shortConv)) ? upC : flatC

// ── PLOTS (theme-aware) ──────────────────────────────────────────────────────────────────────
obMapped = (obLvl - 50) * 2
osMapped = (osLvl - 50) * 2
pObIn  = plot(obMapped, "OB edge", color.new(dnC, 35), 1)
pObOut = plot(100.0,    "OB cap",  color.new(dnC, 100), display = display.none)
fill(pObIn, pObOut, 100.0, 50.0, color.new(dnC, 18), color.new(dnC, 92), title = "Overbought zone")
pOsIn  = plot(osMapped, "OS edge", color.new(upC, 35), 1)
pOsOut = plot(-100.0,   "OS cap",  color.new(upC, 100), display = display.none)
fill(pOsIn, pOsOut, -50.0, -100.0, color.new(upC, 92), color.new(upC, 18), title = "Oversold zone")
plot(0, "Mid", gridC, 1)
bgcolor(tintBg ? (osc > obLvl ? color.new(dnC, 92) : osc < osLvl ? color.new(upC, 92) : na) : na, title = "Extreme tint")

plot(oscC, "Cycle glow", color.new(wCol, 70), 8)
plot(oscC, "Cycle", color.new(wCol, 0), 2)

showDots = audience == "Pro (full detail)"
plotshape(buySig  ? osMapped : na, "Buy",  shape.triangleup,   location.absolute, color.new(upC,0), size = size.small)
plotshape(sellSig ? obMapped : na, "Sell", shape.triangledown, location.absolute, color.new(dnC,0), size = size.small)
plotshape(buySig,  "Buy mark",  shape.triangleup,   location.belowbar, color.new(upC,0), size = size.tiny, force_overlay = true)
plotshape(sellSig, "Sell mark", shape.triangledown, location.abovebar, color.new(dnC,0), size = size.tiny, force_overlay = true)

// ── DASHBOARD ───────────────────────────────────────────────────────────────────────────────
simple = audience == "Simple (plain language)"
var table st = table.new(f_pos(tblPos), 2, 14, frame_width = 1, border_width = 1)
if showTbl and barstate.islast
    color hdr   = color.new(upC, 0)
    color phCol = osc>obLvl?dnC : osc<osLvl?upC : osc>=50?upC:dnC
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)
    int r = 0
    table.cell(st, 0, r, "Adaptive Trend Cycle", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, r, str.upper(phaseTxt), text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Verdict", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, verdict, text_color = vCol, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Conviction", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, calOn ? convTxt : "calibration off", text_color = convCol, bgcolor = panelBg, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Cycle (bars)", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, (useAdapt ? str.tostring(cycUsed) + " self-tuned" : str.tostring(cycLen) + " fixed"), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    if not simple
        table.cell(st, 0, r, "Oscillator", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, str.tostring(osc,"#") + "/100", text_color = phCol, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Smoothing", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, useSS ? "Low-lag" : "EMA", text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
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
    if cycGate
        table.cell(st, 0, r, "Cycle gate", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, (cycOk ? "cycle " : "weak ") + str.tostring(cycStr, "0.00"), text_color = cycOk ? upC : txtSub, bgcolor = panelBg, text_size = size.tiny)
        r += 1
    table.cell(st, 0, r, "Note", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, "context, not advice", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)

// ── GENERIC EXPORTS (for use from other scripts) ─────────────────────────────────────────────
plot(osc,       "EXP_Oscillator",  color.new(color.gray,100), display = display.data_window)
plot(oscC,      "EXP_OscBounded",  color.new(color.gray,100), display = display.data_window)
plot(domCycle,  "EXP_CyclePeriod", color.new(color.gray,100), display = display.data_window)
plot(buySig?1:0,  "EXP_BuySignal",  color.new(color.gray,100), display = display.data_window)
plot(sellSig?1:0, "EXP_SellSignal", color.new(color.gray,100), display = display.data_window)
plot(buySig?1:sellSig?-1:0, "EXP_Signal", color.new(color.gray,100), display = display.data_window)
plot(buyEdge,   "EXP_LongEdge",    color.new(color.gray,100), display = display.data_window)
plot(sellEdge,  "EXP_ShortEdge",   color.new(color.gray,100), display = display.data_window)
plot(na(buyNetR)  ? na : buyNetR,  "EXP_LongNetR",  color.new(color.gray,100), display = display.data_window)
plot(na(sellNetR) ? na : sellNetR, "EXP_ShortNetR", color.new(color.gray,100), display = display.data_window)

alertcondition(buySig,  "Long signal",  "Adaptive Trend Cycle: turn up out of oversold")
alertcondition(sellSig, "Short signal", "Adaptive Trend Cycle: turn down out of overbought")
alertcondition(ta.crossover(osc, 50),  "Crossed above mid", "Adaptive Trend Cycle crossed above 50")
alertcondition(ta.crossunder(osc, 50), "Crossed below mid", "Adaptive Trend Cycle crossed below 50")
````
