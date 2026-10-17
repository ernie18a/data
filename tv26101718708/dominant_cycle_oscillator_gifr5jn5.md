# Dominant Cycle Oscillator

- url: https://www.tradingview.com/script/Gifr5jN5-Dominant-Cycle-Oscillator/
- type: indicator
- pine_id: PUB;cf7c132587d745fc8fccc04cb8db31e8
- version: 4.0

## Description

Dominant Cycle Oscillator

A cycle tool that measures the market's current dominant cycle length directly from the data — rather than assuming a fixed period — then reads where price sits inside that cycle (its phase) and how strong the cycle is (its power). It answers three things a fixed-length oscillator can't: how long the cycle is right now, where we are within it, and whether a tradable cycle even exists.

Why these parts are combined (not a mashup for show). Each is required by the previous one. A band-pass filter isolates the tradable cycle band from slow trend and fast noise — you can't measure a cycle cleanly without first removing what isn't cyclical. An autocorrelation periodogram turns that cleaned series into a power spectrum and reports the dominant period as the spectrum's centre of gravity. A cycle-strength read — how far the dominant peak stands above the spectral noise floor — says whether that period is real or noise, so signals are suppressed when no cycle exists. Forward calibration then measures whether the cycle turns actually pay on this symbol.

How it works. Band-pass (high-pass + low-lag smoother) → autocorrelation across lags → discrete Fourier transform → power spectrum → dominant period via its centre of gravity. The cleaned cycle is normalized into a ±100 phase wave. A long fires when the phase turns up from a trough with a real cycle present, a short when it turns down from a peak; each side fires at most once per swing. Every signal is labelled by a triple barrier — a profit target and equal stop in ATR units plus a time limit — split into in-sample and recent out-of-sample, with a confidence interval and a multiple-testing check.

How to use. Read the Verdict (Long/Short, Weak cycle, or Wait) and the Conviction, which reads "High" only when that turn type shows a positive edge that survives the test on this symbol — otherwise it openly says "context only" or "no proven edge here." The dashboard shows the measured cycle length and its strength. Best used with your own trend and risk plan, not alone.

Honesty & limitations. The dominant-cycle estimate is approximate and lags at regime shifts. Edge figures are computed on this chart's own history with overlapping windows and no costs — context, not a guaranteed backtest; past behaviour doesn't predict the future. Non-repainting. The periodogram is computationally heavy on deep history / very low timeframes.

Disclaimer: for research and education only. Not financial advice. Trading carries risk of loss; manage your own positions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// DOMINANT CYCLE OSCILLATOR — Measured Period, Phase & Forward-Calibrated                     v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.1 — Robustness + house-standard pass:
//        • Added a warm-up / data-sufficiency guard: the autocorrelation periodogram needs a full
//          band-pass + correlation window before its output is meaningful, so on fresh listings,
//          illiquid symbols and the deep-history / low-timeframe start the script now DEGRADES
//          GRACEFULLY — it reports "warming up" and holds signals instead of firing on half-filled
//          buffers. (The one-time DFT trig table already caps per-bar cost; see the note below it.)
//        • Added the MPL-2.0 licence header, an EXP_ Data-Window export bus, and a round-trip COST
//          model (Net R): conviction now requires a cycle turn that also survives trading costs.
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   A cycle tool that MEASURES the market's current dominant cycle length directly from the data —
//   rather than assuming a fixed period — then reads where price sits inside that cycle (its phase)
//   and how strong the cycle is (its power). It answers three questions a fixed-length oscillator
//   cannot: how long is the cycle right now, where are we within it, and is a cycle even present
//   (or is price trending / random)? It scores its own cycle-phase turns forward on the chart you
//   are viewing, in plain language, so a non-technical reader can tell whether to act or wait.
//
// WHY THESE PARTS ARE COMBINED (read this if you think it is a mashup)
//   Each part is required by the previous one:
//     • A band-pass filter isolates the tradable cycle band from slow trend and fast noise — you
//       cannot measure a cycle cleanly without first removing what is not cyclical.
//     • An autocorrelation periodogram turns that cleaned series into a power spectrum and reports
//       the dominant period as the spectrum's centre of gravity — the measurement itself.
//     • A cycle-strength (power) read says whether the measured period is meaningful or noise, so
//       signals can be suppressed when no real cycle exists.
//     • Forward calibration then measures whether the cycle-phase turns actually pay on THIS symbol,
//       with realistic profit/stop outcomes — instead of assuming cycles must be tradeable.
//   The filter, the periodogram, the strength gate and the calibration form one coherent cycle
//   tool — none alone is sufficient.
//
// HOW IT WORKS
//   1) Band-pass: high-pass filter + low-lag smoother isolate the cycle band.
//   2) Periodogram: autocorrelation across lags -> discrete Fourier transform -> power spectrum ->
//      dominant period via the spectrum's centre of gravity.
//   3) Phase: the cleaned cycle is normalized into a -100..+100 phase wave; cycle strength is the
//      normalized spectral power at the dominant period.
//   4) Signals: phase turning up from a trough (long) / down from a peak (short), gated by a
//      minimum cycle strength so flat / trending regimes do not fire.
//   5) Calibration: each signal is labelled by a TRIPLE BARRIER (profit target + equal stop in ATR
//      units, plus a time limit), split into in-sample and recent out-of-sample, with a confidence
//      interval and a multiple-testing check.
//
// HOW TO USE (plain language)
//   • Read the VERDICT row: Long/Short = a cycle turn just fired with a real cycle present; Weak
//     cycle = no tradable rhythm right now; Wait = mid-phase.
//   • The CONVICTION row says whether that turn type has a positive, statistically-surviving edge
//     on THIS chart. Low conviction = treat as context only.
//   • The dashboard shows the measured cycle length and its strength. Green wave = cycle up-half,
//     red = down-half. Best used with your own trend and risk plan, not alone.
//
// NON-REPAINT  Reads confirmed closes; calibration logs and resolves only on barstate.isconfirmed.
//
// PERFORMANCE  The periodogram uses nested loops and is heavy on deep history / very low
//   timeframes. Lower "Max period" or raise the chart timeframe if the script runs slow.
//
// CONCEPT CREDIT (technical attributions)
//   This script combines established, public-domain techniques: a band-pass / autocorrelation-
//   periodogram dominant-cycle estimator (John Ehlers' adaptation of digital-signal-processing
//   methods to markets — roofing filter, Super Smoother and autocorrelation periodogram);
//   spectral power as a cycle-strength measure; triple-barrier outcome labelling from
//   standard supervised-labelling practice in quantitative finance; the Wilson score interval for
//   the proportion bound; and the Bonferroni adjustment for multiple testing. Credit is due to the
//   originators of each technique. This is an original implementation combining them into one
//   forward-calibrated cycle tool.
//
// DISCLAIMER  For research and education only. Edge figures are computed on this chart's own
//   history with overlapping windows and no costs — context, not a guaranteed backtest, and past
//   behaviour does not predict the future. The dominant-cycle estimate is approximate and lags at
//   regime shifts. Nothing here is financial advice. Trading carries risk of loss; size your own.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Dominant Cycle Oscillator", "Dom Cycle", overlay = false)

// INPUTS  (defaults tuned for NSE:NIFTY1! intraday; change the source to use any market)
gMain    = "1 · General"
srcPrice = input.source(close, "Price source", group = gMain, tooltip = "Raw data the engine reads. Change for any symbol/market — this script is asset-agnostic.")
audience = input.string("Simple (plain language)", "Reading mode", options = ["Simple (plain language)", "Pro (full detail)"], group = gMain, tooltip = "Simple shows a verdict and conviction in words. Pro shows every number.")

gCyc     = "2 · Cycle measurement"
minPer   = input.int(8,  "Min period", minval = 5,  maxval = 20, group = gCyc)
maxPer   = input.int(48, "Max period", minval = 20, maxval = 60, group = gCyc)
hpPer    = input.int(48, "Band-pass length", minval = 20, maxval = 120, group = gCyc)
ssRoof   = input.int(10, "Band-pass smoothing", minval = 4, maxval = 30, group = gCyc)
avgLen   = input.int(3,  "Autocorrelation average", minval = 1, maxval = 10, group = gCyc)

gSig     = "3 · Signal"
strMin   = input.float(0.3, "Min cycle strength to signal", minval = 0.0, maxval = 1.0, step = 0.05, group = gSig, tooltip = "Phase turns only fire when the measured cycle is at least this strong — suppresses signals in trending / random regimes.")

gCal     = "4 · Forward calibration"
calOn    = input.bool(true, "Run forward calibration", group = gCal, tooltip = "Score signals forward on this chart. On by default — the core honesty feature.")
calHor   = input.int(10, "Time limit (bars)", minval = 2, maxval = 200, group = gCal)
barrierK = input.float(1.0, "Profit/stop size × ATR", minval = 0.1, maxval = 10.0, step = 0.1, group = gCal, tooltip = "A signal wins if price reaches the profit target (this many ATRs) before the equal-sized stop, within the time limit.")
atrLen   = input.int(14, "ATR length", minval = 2, maxval = 100, group = gCal)
oosBars  = input.int(1500, "Out-of-sample window (recent bars)", minval = 100, maxval = 20000, group = gCal, tooltip = "Signals inside the last N bars are scored separately as out-of-sample.")
uniqOn   = input.bool(true, "Non-overlapping sampling", group = gCal, tooltip = "Skip a signal if the previous same-side one was within one time-limit — reduces double-counting.")
calMinN  = input.int(20, "Min sample for rating", minval = 5, maxval = 500, group = gCal)
costR    = input.float(0.30, "Round-trip cost (R) — subtracted for NET", minval = 0.0, maxval = 3.0, step = 0.05, group = gCal, tooltip = "Round-trip cost (brokerage + STT + slippage + optimistic fill) as a fraction of the barrier risk (Profit/stop × ATR). The barrier is symmetric 1:1, so gross expectancy in R = 2·hit% − 1; Net R subtracts this cost, and CONVICTION now requires the edge to survive it. On 1m NIFTY futures costs eat a large share of R, so a gross edge that ignores them is not tradeable.")

gUI      = "5 · Dashboard & appearance"
showTbl  = input.bool(true, "Show dashboard", group = gUI)
tblPos   = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = gUI)
dashTheme= input.string("Auto (match chart)", "Color theme", options = ["Auto (match chart)","Dark","Light"], group = gUI, tooltip = "Auto reads the chart background brightness and adapts table, text and line colors for visibility on any theme.")
tintBg   = input.bool(true, "Tint pane when cycle is weak", group = gUI)
colUp    = input.color(#2ebd85, "Up color",   inline = "c", group = gUI)
colDn    = input.color(#f6465d, "Down color", inline = "c", group = gUI)

// THEME
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

// HELPERS
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

// BAND-PASS + DOMINANT CYCLE (autocorrelation periodogram)
hpA = (math.cos(0.707*2*math.pi/hpPer) + math.sin(0.707*2*math.pi/hpPer) - 1) / math.cos(0.707*2*math.pi/hpPer)
var float hpf = 0.0
hpf := na(hpf[1]) or na(hpf[2]) ? 0.0 : (1 - hpA/2)*(1 - hpA/2)*(srcPrice - 2*nz(srcPrice[1]) + nz(srcPrice[2])) + 2*(1 - hpA)*nz(hpf[1]) - (1 - hpA)*(1 - hpA)*nz(hpf[2])
filt = f_ss(hpf, ssRoof)

var corr  = array.new_float(maxPer + 1, 0.0)
var sqSum = array.new_float(maxPer + 1, 0.0)
var rPwr  = array.new_float(maxPer + 1, 0.0)
var float domCycle = 20.0
var float cycPower = 0.0

// One-time DFT trig table. cos(2π·n/period) and sin(2π·n/period) depend ONLY on
// the integers (period, n) — never on price — so they are constant for a given
// Min/Max period. Building them once on the first bar replaces ~3,800–6,500
// math.cos/math.sin calls PER BAR in the spectrum loop below (this script's
// heaviest cost) with plain array reads and identical output. Indexed
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
// Cycle strength = how far the dominant peak stands above the average spectral power
// (a flat spectrum -> 0; a sharp dominant peak -> near 1). Replaces the old saturating proxy.
float sumPwr = 0.0
for period = minPer to maxPer
    sumPwr += array.get(rPwr, period)
float meanPwr = sumPwr / (maxPer - minPer + 1)
cycPower := maxPwr > 0 ? math.max(0.0, math.min(1.0, 1.0 - meanPwr / maxPwr)) : 0.0

cycUsed = int(math.round(domCycle))

// PHASE WAVE
absF      = math.abs(filt)
scaleRaw  = ta.percentile_linear_interpolation(absF, 200, 85)
dispScale = math.max(0.0001, nz(scaleRaw, 1.0)) * 1.2
wave      = f_squash(filt, dispScale)
waveSm    = ta.sma(wave, 2)

strong   = cycPower >= strMin
chgNow   = ta.change(waveSm)
chgPrev  = ta.change(waveSm[1])
// A trough/peak fires only from a meaningful extreme, and only ONCE per swing:
// after a long fires at a trough it disarms until the wave swings back up through zero
// (and vice-versa). This locks signals to the measured cycle instead of firing on noise.
turnLvl  = 35.0
trough   = chgNow > 0 and chgPrev <= 0 and waveSm < -turnLvl
peak     = chgNow < 0 and chgPrev >= 0 and waveSm >  turnLvl
var bool longArmed  = true
var bool shortArmed = true
// Robustness guard — degrade gracefully until the spectrum has enough history to be meaningful.
// (band-pass roofing lag + autocorrelation window). Before this, hold signals rather than fire on
// half-filled buffers; the dashboard reports "warming up".
int   warmBars   = maxPer + avgLen + ssRoof * 2
bool  cycleReady = bar_index >= warmBars
buySig  = cycleReady and strong and trough and longArmed
sellSig = cycleReady and strong and peak   and shortArmed
longArmed  := buySig  ? false : (waveSm > 0 ? true : longArmed)
shortArmed := sellSig ? false : (waveSm < 0 ? true : shortArmed)
phaseTxt = not cycleReady ? "Warming up" : not strong ? "Weak cycle" : wave >= 0 ? "Up-phase" : "Down-phase"
wCol = wave >= 0 ? upC : dnC
// value-add: is the rhythm BUILDING or FADING, and how mature is the current half-cycle?
// A rising cycle strength = the rhythm is establishing (turns more reliable); a fading one warns
// the cycle is dissolving. Phase age = bars since the wave last crossed zero (early = room to run).
cycRising = cycPower >= nz(cycPower[3], cycPower)
var int phaseAge = 0
phaseAge := (wave >= 0) == (nz(wave[1], wave) >= 0) ? phaseAge + 1 : 0

// CALIBRATION
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
var int baseWdn = 0
var int lastBuyBar = -1000000
var int lastSellBar = -1000000

canEval = calOn and barstate.isconfirmed and not na(close[calHor]) and not na(atrSeries[calHor])
if canEval
    entryB = close[calHor]
    aB = atrSeries[calHor]
    fhB = f_firstHit(entryB + barrierK*aB, entryB - barrierK*aB, calHor)
    upOutcome = fhB == 1 or (fhB == 0 and close > entryB)
    dnOutcome = fhB == -1 or (fhB == 0 and close < entryB)
    baseN += 1
    baseW += upOutcome ? 1 : 0
    baseWdn += dnOutcome ? 1 : 0
    if buySig[calHor]
        sigBar = bar_index[calHor]
        okB = (not uniqOn) or (sigBar - lastBuyBar >= calHor)
        if okB
            buyN += 1
            buyW += upOutcome ? 1 : 0
            if sigBar >= last_bar_index - oosBars
                buyNo += 1
                buyWo += upOutcome ? 1 : 0
            lastBuyBar := sigBar
    if sellSig[calHor]
        sigBarS = bar_index[calHor]
        okS = (not uniqOn) or (sigBarS - lastSellBar >= calHor)
        if okS
            sellN += 1
            sellW += dnOutcome ? 1 : 0
            if sigBarS >= last_bar_index - oosBars
                sellNo += 1
                sellWo += dnOutcome ? 1 : 0
            lastSellBar := sigBarS

baseUp  = baseN > 0 ? baseW / baseN * 100.0 : na
baseDn  = baseN > 0 ? baseWdn / baseN * 100.0 : na
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

// VERDICT + CONVICTION
longConv  = buyN  >= calMinN and not na(buyEdge)  and buyEdge  > 0 and buySurv  and not na(buyNetR)  and buyNetR  > 0
shortConv = sellN >= calMinN and not na(sellEdge) and sellEdge > 0 and sellSurv and not na(sellNetR) and sellNetR > 0
verdict = not cycleReady ? "WARMING UP — gathering data" : not strong ? "WEAK CYCLE — stand aside" : buySig ? "LONG — cycle turning up" : sellSig ? "SHORT — cycle turning down" : "WAIT"
vCol    = not strong ? flatC : buySig ? upC : sellSig ? dnC : flatC
convTxt = (buySig and longConv) or (sellSig and shortConv) ? "High — edge survives test" : (buySig or sellSig) ? "Low — context only" : longConv or shortConv ? "Cycle turns have edge here" : "No proven edge here"
convCol = ((buySig and longConv) or (sellSig and shortConv)) ? upC : flatC

// PLOTS
plot(0, "Zero", gridC, 1)
bgcolor(tintBg and not strong ? color.new(flatC, 90) : na, title = "Weak-cycle tint")
plot(wave, "Phase glow", color.new(wCol, 70), 8)
plot(wave, "Phase", color.new(wCol, 0), 2)

plotshape(buySig  ? wave : na, "Buy",  shape.triangleup,   location.absolute, color.new(upC,0), size = size.small)
plotshape(sellSig ? wave : na, "Sell", shape.triangledown, location.absolute, color.new(dnC,0), size = size.small)
plotshape(buySig,  "Buy mark",  shape.triangleup,   location.belowbar, color.new(upC,0), size = size.tiny, force_overlay = true)
plotshape(sellSig, "Sell mark", shape.triangledown, location.abovebar, color.new(dnC,0), size = size.tiny, force_overlay = true)

// DASHBOARD
simple = audience == "Simple (plain language)"
var table st = table.new(f_pos(tblPos), 2, 13, frame_width = 1, border_width = 1)
if showTbl and barstate.islast
    color hdr   = color.new(upC, 0)
    color phCol = wave>=0?upC:dnC
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)
    int r = 0
    table.cell(st, 0, r, "Dominant Cycle", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, r, str.upper(phaseTxt), text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Verdict", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, verdict, text_color = vCol, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Conviction", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, calOn ? convTxt : "calibration off", text_color = convCol, bgcolor = panelBg, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Cycle length", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, str.tostring(cycUsed) + " bars · " + str.tostring(phaseAge) + "b in", text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Cycle strength", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, str.tostring(cycPower*100,"#") + "% " + (cycRising?"↑ building":"↓ fading") + (strong?"":" (weak)"), text_color = strong?txtMain:flatC, bgcolor = panelBg, text_size = size.tiny)
    r += 1
    if calOn
        string baseTxt = (na(baseUp) or na(baseDn)) ? "warming up" : "up " + str.tostring(baseUp,"0") + "%  dn " + str.tostring(baseDn,"0") + "%"
        string buyTxt  = buyN  < calMinN ? "warming " + str.tostring(buyN)  : "win " + str.tostring(buyHit,"0")  + "%  edge " + (nz(buyEdge)>=0?"+":"")  + str.tostring(buyEdge,"0")  + "  (" + str.tostring(buyN) + ")"
        string sellTxt = sellN < calMinN ? "warming " + str.tostring(sellN) : "win " + str.tostring(sellHit,"0") + "%  edge " + (nz(sellEdge)>=0?"+":"") + str.tostring(sellEdge,"0") + "  (" + str.tostring(sellN) + ")"
        table.cell(st, 0, r, "Base " + str.tostring(calHor) + "b", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, baseTxt, text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Long " + buyStars, text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, buyTxt, text_color = buyN<calMinN?flatC:upC, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Short " + sellStars, text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
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
            table.cell(st, 1, r, "L " + buyOTxt + " · S " + selOTxt, text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
            r += 1
            table.cell(st, 0, r, "Multi-test", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
            table.cell(st, 1, r, "long " + (buySurv?"survives":"no") + " · short " + (sellSurv?"survives":"no"), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
            r += 1
    table.cell(st, 0, r, "Note", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, "context, not advice", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)

// GENERIC EXPORTS
plot(domCycle, "EXP_CyclePeriod",  color.new(color.gray,100), display = display.data_window)
plot(cycPower, "EXP_CycleStrength",color.new(color.gray,100), display = display.data_window)
plot(phaseAge, "EXP_PhaseAge",     color.new(color.gray,100), display = display.data_window)
plot(wave,     "EXP_PhaseWave",    color.new(color.gray,100), display = display.data_window)
plot(buySig?1:0,  "EXP_BuySignal",  color.new(color.gray,100), display = display.data_window)
plot(sellSig?1:0, "EXP_SellSignal", color.new(color.gray,100), display = display.data_window)
plot(buySig?1:sellSig?-1:0, "EXP_Signal", color.new(color.gray,100), display = display.data_window)
plot(buyEdge,   "EXP_LongEdge",    color.new(color.gray,100), display = display.data_window)
plot(sellEdge,  "EXP_ShortEdge",   color.new(color.gray,100), display = display.data_window)
plot(na(buyNetR)  ? na : buyNetR,  "EXP_LongNetR",  color.new(color.gray,100), display = display.data_window)
plot(na(sellNetR) ? na : sellNetR, "EXP_ShortNetR", color.new(color.gray,100), display = display.data_window)

alertcondition(buySig,  "Long signal",  "Dominant Cycle: cycle turning up with a real cycle present")
alertcondition(sellSig, "Short signal", "Dominant Cycle: cycle turning down with a real cycle present")
alertcondition(ta.crossover(wave, 0),  "Phase up",   "Dominant Cycle phase crossed above zero")
alertcondition(ta.crossunder(wave, 0), "Phase down", "Dominant Cycle phase crossed below zero")
````
