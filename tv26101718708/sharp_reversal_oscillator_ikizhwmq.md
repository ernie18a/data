# Sharp Reversal Oscillator

- url: https://www.tradingview.com/script/iKIZHWMQ-Sharp-Reversal-Oscillator/
- type: indicator
- pine_id: PUB;cef861e7ea6949fb873bee8e15124a3b
- version: 3.0

## Description

Sharp Reversal Oscillator

A reversal-timing oscillator that re-shapes price into a near-Gaussian form so turning points snap into sharp, clear extremes instead of rounded, ambiguous ones — then scores its own turns forward on your chart, in plain language, so you can see at a glance whether to act or wait.

Why these parts are combined (not a mashup for show). Three steps are stacked, each fixing the previous one's flaw. Raw price excursions are fat-tailed, so it's unclear where an extreme really is; a distribution-normalizing transform stretches values near the edges, turning a compressed extreme into a clear spike. But that transform is easily biased by trend — in a strong move it pins to one side — so the input is first band-pass cleaned (slow trend and fastest noise removed), leaving the tradable swing it should sharpen. The normalization window is then set from the market's measured dominant cycle rather than a fixed guess, so it stays tuned as cycles stretch and compress. The three only work as one tool.

How it works. Band-pass clean → locate price within its recent range, scaled to (−1, 1) → distribution-normalizing transform, smoothed → signal when the line crosses its one-bar trigger from an extreme. The window optionally follows a dominant cycle measured by autocorrelation of the band-passed price. Each signal is then labelled by a triple barrier — a profit target and an equal stop in ATR units, plus a time limit — so a "win" means the target was hit before the stop. Results split into in-sample and recent out-of-sample, with a confidence interval and a multiple-testing check.

How to use. Read the Verdict row (Long/Short signal, Watch, or Wait). Check Conviction — it reads "High" only when that signal type shows a positive edge that survives the statistical test on this symbol; otherwise treat it as context. Green wave above zero is up-pressure, red below is down; shaded bands are extremes; the faint line is the trigger. Best used with your own trend and risk plan, not alone.

What's original. The band-pass-cleaned input, the self-tuning window, the forward triple-barrier calibration with an out-of-sample split, and a conviction read that openly admits when there's no proven edge — instead of presenting every signal as equally reliable.
Inputs. Price source (change it for any market), reading mode (Simple/Pro), engine and self-tuning controls, extreme level, full calibration settings, and an auto-adapting dashboard legible on dark or light charts. Defaults are tuned for NSE:NIFTY1! intraday.

Honesty & limitations. Edge figures are computed on this chart's own history with overlapping windows and no costs — context, not a guaranteed backtest; past behaviour doesn't predict the future, and the cycle estimate lags at regime shifts.

Disclaimer: for research and education only. Not financial advice. Trading carries risk of loss; manage your own positions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// SHARP REVERSAL OSCILLATOR — Distribution-Normalized & Forward-Calibrated                    v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.1 — Robustness + house-standard pass:
//        • Cycle-engine guard (shared with the Dominant Cycle family): the self-tuning
//          autocorrelation periodogram now uses a one-time DFT trig table instead of calling
//          math.cos/math.sin thousands of times per bar — identical output, far lighter, so it no
//          longer risks the calculation-timeout on deep history / very low timeframes.
//        • Added a warm-up guard: while adaptive, signals are held (dashboard shows "warming up")
//          until the periodogram has enough history to tune the window meaningfully.
//        • Added the MPL-2.0 licence header, an EXP_ Data-Window export bus, and a round-trip COST
//          model (Net R): conviction now requires a signal that also survives trading costs.
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   A reversal-timing oscillator that re-shapes price into a near-Gaussian form so turning points
//   snap into sharp, well-defined extremes instead of rounded, ambiguous ones. It adds two things
//   most versions of this idea lack: the input is first band-pass cleaned so the sharpening is not
//   fooled by trend, and every signal is scored forward on the chart you are viewing — in plain
//   language — so a non-technical reader can tell at a glance whether to act or wait.
//
// WHY THESE PARTS ARE COMBINED (read this if you think it is a mashup)
//   Three steps are stacked because each fixes the previous one's flaw:
//     • Raw price excursions are fat-tailed, so it is unclear where an extreme really is. A
//       distribution-normalizing transform y = 0.5·ln((1+x)/(1-x)) stretches values near the
//       edges, turning a compressed extreme into a clear spike — crisper peaks and troughs.
//     • But that transform is easily biased by trend: in a strong move it pins to one side. So the
//       input is first put through a BAND-PASS (high-pass + smoother) that removes the slow trend
//       and the fastest noise, leaving the tradable swing the transform should sharpen.
//     • The normalization window is then set from the market's MEASURED dominant cycle instead of
//       a fixed guess, so the oscillator stays tuned as cycles stretch and compress.
//   The three only work as one tool; separately each is incomplete. A forward-calibration layer
//   then measures, honestly, whether the sharpened turns actually pay on this symbol.
//
// HOW IT WORKS
//   1) Clean: band-pass filter the price (high-pass + low-lag smoother).
//   2) Normalize: position within its recent range, scaled to (-1, 1), lightly smoothed.
//   3) Sharpen: the distribution-normalizing transform, smoothed; signal = the line crossing its
//      own one-bar trigger from an extreme.
//   4) Self-tune (optional): the range window follows a measured dominant cycle (autocorrelation
//      of the band-passed price).
//   5) Calibrate: each signal is labelled by a TRIPLE BARRIER (profit target + equal stop in ATR
//      units, plus a time limit); a "win" means the target is reached before the stop. Results
//      split into in-sample and recent out-of-sample, with a confidence interval and a
//      multiple-testing check.
//
// HOW TO USE (plain language)
//   • Read the VERDICT row first: Long/Short signal = a fresh sharpened turn; Watch = at an
//     extreme; Wait = mid-range / no edge.
//   • The CONVICTION row says whether that signal type has a positive, statistically-surviving
//     edge on THIS chart. Low conviction = treat as context only.
//   • Green wave above zero = up-pressure, red below = down; shaded bands are extremes; the faint
//     line is the trigger. Best used with your own trend and risk plan, not alone.
//
// NON-REPAINT  Reads confirmed closes; calibration logs and resolves only on barstate.isconfirmed.
//
// PERFORMANCE  The self-tuning periodogram uses nested loops and is heavy on deep history / very
//   low timeframes. Turn "Self-tuning window" off or lower "Max period" if the script is slow.
//
// CONCEPT CREDIT (technical attributions)
//   This script combines established, public-domain techniques: a distribution-normalizing
//   transform applied to a range-located price (classical signal-processing applied to markets);
//   a band-pass / autocorrelation periodogram dominant-cycle estimator from the same tradition;
//   triple-barrier outcome labelling from standard supervised-labelling practice in quantitative
//   finance; the Wilson score interval for the proportion bound; and the Bonferroni adjustment for
//   multiple testing. Credit is due to the originators of each technique. This is an original
//   implementation combining them into one self-tuning, forward-calibrated tool.
//
// DISCLAIMER  For research and education only. Edge figures are computed on this chart's own
//   history with overlapping windows and no costs — context, not a guaranteed backtest, and past
//   behaviour does not predict the future. Nothing here is financial advice. Trading carries risk
//   of loss; size and manage your own positions.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Sharp Reversal Oscillator", "Sharp Rev", overlay = false, max_lines_count = 100, max_labels_count = 200)

// ──────────────────────────────────────────────────────────────────────────────────────────────
// INPUTS  (defaults tuned for NSE:NIFTY1! intraday; change the source to use any market)
// ──────────────────────────────────────────────────────────────────────────────────────────────
gMain    = "1 · General"
srcPrice = input.source(hl2, "Price source", group = gMain, tooltip = "Raw data the oscillator reads. Default HL2. Change for any symbol/market — this script is asset-agnostic.")
audience = input.string("Simple (plain language)", "Reading mode", options = ["Simple (plain language)", "Pro (full detail)"], group = gMain, tooltip = "Simple shows a verdict and conviction in words. Pro shows every number.")

gEng     = "2 · Oscillator engine"
len      = input.int(9, "Range length (fixed fallback)", minval = 2, maxval = 100, group = gEng, tooltip = "Used when self-tuning is OFF.")
smoothA  = input.float(0.33, "Range smoothing", minval = 0.1, maxval = 0.9, step = 0.01, group = gEng)
smoothB  = input.float(0.5,  "Output smoothing", minval = 0.1, maxval = 0.9, step = 0.01, group = gEng)
useRoof  = input.bool(true, "Clean input (band-pass)", group = gEng, tooltip = "Remove trend and noise before sharpening, so the transform is not biased by strong trends. On by default.")

gAdapt   = "3 · Self-tuning window"
useAdapt = input.bool(true, "Self-tuning range window", group = gAdapt, tooltip = "Set the range length from the measured dominant cycle. On by default. Turn off for speed or a fixed length.")
minPer   = input.int(8,  "Min period", minval = 5,  maxval = 20, group = gAdapt)
maxPer   = input.int(48, "Max period", minval = 20, maxval = 60, group = gAdapt)
hpPer    = input.int(48, "Band-pass length", minval = 20, maxval = 120, group = gAdapt)
ssRoof   = input.int(10, "Band-pass smoothing", minval = 4, maxval = 30, group = gAdapt)
avgLen   = input.int(3,  "Autocorrelation average", minval = 1, maxval = 10, group = gAdapt)

gReg     = "3b · Regime gate (optional)"
regimeGate = input.bool(false, "Gate reversals by regime", group = gReg, tooltip = "OFF = original behaviour (default). ON = fire reversals only in the chosen regime — reversal signals have edge in RANGES, not strong trends. Watch the calibration Edge to confirm it helps on your instrument.")
gateMode = input.string("Ranging only", "Gate mode", options = ["Ranging only","Trending only"], group = gReg)
erLen    = input.int(20, "Regime length (efficiency)", minval = 5, maxval = 100, group = gReg)
erThresh = input.float(0.30, "Trend threshold", minval = 0.1, maxval = 0.9, step = 0.05, group = gReg, tooltip = "Efficiency ratio above this = trending; below = ranging.")

gSig     = "4 · Signal"
extLvl   = input.float(1.5, "Extreme level", minval = 0.5, maxval = 5.0, step = 0.1, group = gSig, tooltip = "A turn only counts as a signal when it fires from beyond this extreme.")

gCal     = "5 · Forward calibration"
calOn    = input.bool(true, "Run forward calibration", group = gCal, tooltip = "Score signals forward on this chart. On by default — the core honesty feature.")
calHor   = input.int(10, "Time limit (bars)", minval = 2, maxval = 200, group = gCal)
barrierK = input.float(1.0, "Profit/stop size × ATR", minval = 0.1, maxval = 10.0, step = 0.1, group = gCal, tooltip = "A signal wins if price reaches the profit target (this many ATRs) before the equal-sized stop, within the time limit.")
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
showTrig = input.bool(true, "Show trigger line", group = gUI)
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
trigC      = darkUI ? color.new(color.gray, 30) : color.new(color.gray, 25)

// ── HELPERS ───────────────────────────────────────────────────────────────────────────────────
f_pos(string s) => s=="Top Left"?position.top_left : s=="Bottom Right"?position.bottom_right : s=="Bottom Left"?position.bottom_left : position.top_right
f_tanh(float x) =>
    float xc = math.max(-10.0, math.min(10.0, x))
    float e = math.exp(2 * xc)
    (e - 1) / (e + 1)
f_squash(float x, float k) => 100.0 * f_tanh(x / math.max(k, 0.0001))
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

// ── BAND-PASS CLEAN + DOMINANT CYCLE (autocorrelation periodogram) ───────────────────────────
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
winUsed  = useAdapt ? math.max(minPer, math.min(maxPer, cycAdapt)) : len

// ── OSCILLATOR ────────────────────────────────────────────────────────────────────────────────
locSrc = useRoof ? filt : srcPrice
hh = ta.highest(locSrc, winUsed)
ll = ta.lowest(locSrc, winUsed)
raw = hh == ll ? 0.0 : (locSrc - ll) / (hh - ll) - 0.5
var float val = na
val := na(val[1]) ? 0.0 : smoothA * (2 * raw) + (1 - smoothA) * nz(val[1])
val := math.max(math.min(val, 0.999), -0.999)
var float fish = na
fish := na(fish[1]) ? 0.0 : smoothB * 0.5 * math.log((1 + val) / (1 - val)) + (1 - smoothB) * nz(fish[1])
trigger = nz(fish[1])
// Adaptive display scale: fit the wave to its own recent magnitude so it fills the pane
// without saturating against the rails on any symbol or timeframe.
fishAbs   = math.abs(fish)
scaleRaw  = ta.percentile_linear_interpolation(fishAbs, 200, 90)
dispScale = math.max(1.0, nz(scaleRaw, 2.0)) * 1.25
fishDisp = f_squash(fish, dispScale)
trigDisp = f_squash(trigger, dispScale)
extDisp  = f_squash(extLvl, dispScale)

wCol = fish >= trigger ? upC : dnC
float erChg = math.abs(close - close[erLen])
float erVol = math.sum(math.abs(close - close[1]), erLen)
float erVal = erVol > 0 ? erChg / erVol : 0.0
bool  trending = erVal > erThresh
bool  ranging  = not trending
bool  regOk = not regimeGate or (gateMode == "Trending only" ? trending : ranging)
// ta.crossover/crossunder are stateful — hoist them to top level so the warm-up guard never
// short-circuits them (they must run every bar), then compose the gated signal from the results.
bool xUp = ta.crossover(fish, trigger)
bool xDn = ta.crossunder(fish, trigger)
// Robustness: while adaptive, hold signals until the periodogram has enough history to be meaningful.
bool cycleReady = not useAdapt or bar_index >= maxPer + avgLen + ssRoof * 2
buySig  = cycleReady and xUp and fish < -extLvl and regOk
sellSig = cycleReady and xDn and fish > extLvl and regOk
phaseTxt = not cycleReady ? "Warming up" : fish > extLvl ? "Overbought" : fish < -extLvl ? "Oversold" : fish >= trigger ? "Rising" : "Falling"

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
verdict = not cycleReady ? "WARMING UP — gathering data" : buySig ? "LONG SIGNAL" : sellSig ? "SHORT SIGNAL" : fish < -extLvl ? "WATCH — long setup" : fish > extLvl ? "WATCH — short setup" : "WAIT"
vCol    = buySig ? upC : sellSig ? dnC : (fish < -extLvl ? upC : fish > extLvl ? dnC : flatC)
convTxt = (buySig and longConv) or (sellSig and shortConv) ? "High — edge survives test" : (buySig or sellSig) ? "Low — context only" : longConv or shortConv ? "Setups have edge here" : "No proven edge here"
convCol = ((buySig and longConv) or (sellSig and shortConv)) ? upC : flatC

// ── PLOTS (theme-aware) ──────────────────────────────────────────────────────────────────────
pObIn  = plot(extDisp,  "OB edge", color.new(dnC, 35), 1)
pObOut = plot(100.0,    "OB cap",  color.new(dnC, 100), display = display.none)
fill(pObIn, pObOut, 100.0, 50.0, color.new(dnC, 18), color.new(dnC, 92), title = "Overbought zone")
pOsIn  = plot(-extDisp, "OS edge", color.new(upC, 35), 1)
pOsOut = plot(-100.0,   "OS cap",  color.new(upC, 100), display = display.none)
fill(pOsIn, pOsOut, -50.0, -100.0, color.new(upC, 92), color.new(upC, 18), title = "Oversold zone")
plot(0, "Zero", gridC, 1)
bgcolor(tintBg ? (fish > extLvl ? color.new(dnC, 92) : fish < -extLvl ? color.new(upC, 92) : na) : na, title = "Extreme tint")

plot(showTrig ? trigDisp : na, "Trigger", trigC, 1)
plot(fishDisp, "Reversal glow", color.new(wCol, 70), 8)
plot(fishDisp, "Reversal", color.new(wCol, 0), 2)

plotshape(buySig  ? fishDisp : na, "Buy",  shape.triangleup,   location.absolute, color.new(upC,0), size = size.small)
plotshape(sellSig ? fishDisp : na, "Sell", shape.triangledown, location.absolute, color.new(dnC,0), size = size.small)
plotshape(buySig,  "Buy mark",  shape.triangleup,   location.belowbar, color.new(upC,0), size = size.tiny, force_overlay = true)
plotshape(sellSig, "Sell mark", shape.triangledown, location.abovebar, color.new(dnC,0), size = size.tiny, force_overlay = true)

// ── DASHBOARD ───────────────────────────────────────────────────────────────────────────────
simple = audience == "Simple (plain language)"
var table st = table.new(f_pos(tblPos), 2, 14, frame_width = 1, border_width = 1)
if showTbl and barstate.islast
    color hdr   = color.new(upC, 0)
    color phCol = fish>extLvl?dnC : fish<-extLvl?upC : fish>=trigger?upC:dnC
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)
    int r = 0
    table.cell(st, 0, r, "Sharp Reversal", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, r, str.upper(phaseTxt), text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Verdict", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, verdict, text_color = vCol, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Conviction", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, calOn ? convTxt : "calibration off", text_color = convCol, bgcolor = panelBg, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Window (bars)", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, (useAdapt ? str.tostring(winUsed) + " self-tuned" : str.tostring(len) + " fixed"), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    if not simple
        table.cell(st, 0, r, "Oscillator", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, str.tostring(fish,"0.00"), text_color = phCol, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Input", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, useRoof ? "Band-pass cleaned" : "Raw", text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
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
    if regimeGate
        table.cell(st, 0, r, "Regime gate", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, (trending ? "TRENDING" : "RANGING") + " · " + gateMode, text_color = trending ? dnC : upC, bgcolor = panelBg, text_size = size.tiny)
        r += 1
    table.cell(st, 0, r, "Note", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, "context, not advice", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)

// ── GENERIC EXPORTS (for use from other scripts) ─────────────────────────────────────────────
plot(fish,      "EXP_Oscillator",  color.new(color.gray,100), display = display.data_window)
plot(trigger,   "EXP_Trigger",     color.new(color.gray,100), display = display.data_window)
plot(fishDisp,  "EXP_OscBounded",  color.new(color.gray,100), display = display.data_window)
plot(domCycle,  "EXP_CyclePeriod", color.new(color.gray,100), display = display.data_window)
plot(buySig?1:0,  "EXP_BuySignal",  color.new(color.gray,100), display = display.data_window)
plot(sellSig?1:0, "EXP_SellSignal", color.new(color.gray,100), display = display.data_window)
plot(buySig?1:sellSig?-1:0, "EXP_Signal", color.new(color.gray,100), display = display.data_window)
plot(buyEdge,   "EXP_LongEdge",    color.new(color.gray,100), display = display.data_window)
plot(sellEdge,  "EXP_ShortEdge",   color.new(color.gray,100), display = display.data_window)
plot(na(buyNetR)  ? na : buyNetR,  "EXP_LongNetR",  color.new(color.gray,100), display = display.data_window)
plot(na(sellNetR) ? na : sellNetR, "EXP_ShortNetR", color.new(color.gray,100), display = display.data_window)

alertcondition(buySig,  "Long signal",  "Sharp Reversal: bullish turn from oversold extreme")
alertcondition(sellSig, "Short signal", "Sharp Reversal: bearish turn from overbought extreme")
alertcondition(ta.crossover(fish, 0),  "Crossed above zero", "Sharp Reversal crossed above zero")
alertcondition(ta.crossunder(fish, 0), "Crossed below zero", "Sharp Reversal crossed below zero")
````
