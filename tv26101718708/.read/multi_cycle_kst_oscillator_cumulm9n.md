# Multi Cycle KST Oscillator

- url: https://www.tradingview.com/script/CuMuLM9N-Multi-Cycle-KST-Oscillator/
- type: indicator
- pine_id: PUB;6d759d1c97ba43e2b6c3d9888e70eeea
- version: 1.0

## Description

Multi-Cycle KST Oscillator — Publication Description

What it does

The Multi-Cycle KST Oscillator is a momentum oscillator built on the Know Sure Thing (KST) — a summed, weighted blend of four smoothed Rate-of-Change series. The standard KST plots one line. This script computes three KSTs at short, intermediate and long cycle lengths, reads their alignment, and wraps the plotted short-term KST in five decision-support modules so the momentum reading is filtered, contextualized and scored rather than read at face value. A single 0–100 Confidence value summarizes everything, and the oscillator line is colored by it.

Why these components are combined (the reason for the mashup)

KST on its own is a momentum (rate-of-change) factor, and it lags by construction. Adding more momentum tools such as RSI, MACD or Stochastic would only restate the same information. So every module added here is deliberately orthogonal to momentum — each answers a question the KST cannot answer by itself:


Long-term KST direction — the regime gate. A slower KST decides which side to trade. Short-term buy crosses are only trusted when the long-term cycle is rising, short crosses only when it is falling. This is the core of the multi-cycle idea: trade the shorter cycle in the direction of the longer one.
ADX/DMI regime filter — trade only in a real trend. Momentum crosses whipsaw in sideways markets, so signals are suppressed and the background is shaded while ADX is below threshold.
Higher-timeframe filter — alignment with the bigger picture. The same momentum direction is read from a higher, confirmed (non-repainting) timeframe to drop counter-trend crosses.
Price/KST divergence — early warning. Because the oscillator measures momentum, a price high against a lower oscillator high (or the inverse) flags fading momentum before the signal-line cross. Regular and hidden divergences are detected from confirmed pivots.
Efficiency-Ratio conviction scaler — how much to trust it now. A Kaufman Efficiency Ratio scales the Confidence up in clean trends and down in chop. It is a magnitude scaler, never a direction vote, so it cannot double-count momentum.


How the parts work together

Each module feeds one combined output. The plotted oscillator is the short-term KST (optionally standardized). A Buy or Sell is raised only when the short-term KST crosses its signal line AND the long-term cycle agrees AND the regime and higher-timeframe filters agree AND Confidence clears its threshold. Confidence itself is a weighted vote across the four orthogonal inputs (KST-vs-signal, long-term direction, price location, divergence), scaled by the Efficiency Ratio and clamped to 0–100. Divergence labels and the ATR stop/target are context around that one decision.

What makes it original

It is not a KST with other indicators drawn beside it. It turns a single KST line into a three-cycle alignment model with a long-term regime gate, then standardizes the result so its bands carry a consistent statistical meaning across instruments, and fuses five orthogonal checks into one bounded Confidence reading with explicit buy/sell gating. The combined output — "is momentum turning, in a real trend, in line with the larger cycle, and how much should I trust it" — does not exist in the source indicator.

How to use it


Pick an Oscillator mode: Raw (native KST), Z-Score, or Robust Z (median/MAD, least sensitive to spikes).
Green = up-cycle momentum, red = down-cycle; further from zero and brighter = stronger and higher conviction. Warn / Extreme bands mark stretched readings.
Buy / Sell triangles fire only when the cross, the long-term gate, the regime and higher-timeframe filters, and the Confidence threshold all agree. Treat them as points to investigate, not automatic entries.
Use divergences as early warning of fading momentum, and the two dashboards for the full read: right panel = Bias, Confidence, Signal, Cycle alignment, Oscillator; left panel = Long-term KST, Regime, Divergence, ATR Stop and Target.
The dashboards adapt to your chart's background brightness so both stay legible on dark or light themes.


Settings and defaults

Inputs are grouped and numbered: Data Source, the three KST cycles, Normalization & Display, Threshold Bands, Confirmation Filters, Divergence, Confidence Engine, Risk Targets, Signals & Alerts, and Visuals & Dashboard. Defaults follow the classic KST values and are tuned for NSE NIFTY on intraday charts. Because the Price / High / Low sources are user-selectable, the engine works on any instrument or even another indicator's output — for other assets, adjust the ROC/SMA lengths, the higher timeframe and the ATR period to suit.

Concept credit

The Know Sure Thing (KST) oscillator was created by Martin J. Pring. This script is an original multi-cycle implementation built around that public concept and is not affiliated with, nor endorsed by, its originator.

Honest limitations

KST is lagging by construction; this confirms moves, it does not predict them. Confidence (0–100) is an ordinal heuristic for how aligned the components are — it is not a probability or a win rate. Divergence is computed on confirmed pivots and therefore prints a few bars after the pivot forms; that latency is inherent to honest pivot detection. Signals confirm on bar close (non-repainting) by default, and the higher-timeframe filter uses the previous confirmed higher-timeframe bar. Backtest any settings on your own market before relying on them.

Disclaimer

For research and educational purposes only. This is not financial advice, not an investment recommendation, and not a solicitation to trade. Indicators describe past price behavior; they do not predict the future. Trading involves substantial risk of loss. Test on out-of-sample data and make your own decisions. The author accepts no liability for any use of this script.

## Source Code

````pine
//@version=6
// ═════════════════════════════════════════════════════════════════════════════
// MULTI-CYCLE KST OSCILLATOR
// ─────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   A momentum oscillator built on the Know Sure Thing (KST) — a summed, weighted
//   blend of four smoothed Rate-of-Change series. The standard KST plots a single
//   line; this implementation computes THREE KSTs at short, intermediate and long
//   cycle lengths and reads their alignment, then wraps the plotted short-term KST
//   in five orthogonal decision-support modules so the momentum read is filtered,
//   contextualized and scored rather than taken at face value.
//
// WHY THE COMPONENTS ARE COMBINED  (mashup rationale)
//   KST alone is a momentum (rate-of-change) factor and lags by construction.
//   Adding more momentum tools (RSI, MACD, Stochastic) would double-count the same
//   information. Every added module is deliberately ORTHOGONAL to momentum so each
//   contributes something the KST cannot show by itself:
//     1. Long-term KST direction  -> regime GATE: which side to trade.
//     2. ADX/DMI regime filter    -> trade only when a trend actually exists.
//     3. Higher-timeframe filter  -> drop counter-trend crosses (non-repainting).
//     4. Price/KST divergence     -> early warning before the signal-line cross.
//     5. Efficiency-Ratio scaler  -> how much to trust the reading right now.
//   A 0-100 Confidence value fuses these into one number, and the oscillator line
//   is colored by it (dim = low conviction, bright = high).
//
// NORMALIZATION
//   Raw KST scale is instrument-dependent, so a fixed band means different things on
//   different symbols. Optional Z-Score / Robust (median-MAD) standardization rescales
//   the oscillator over a rolling window so the Warn / Extreme bands keep a consistent
//   statistical meaning across markets and timeframes.
//
// UNIVERSAL ACROSS MARKETS
//   Price / High / Low sources are user-selectable, so the engine can be pointed at
//   any instrument or even another indicator's output. Defaults are tuned for NSE
//   NIFTY on intraday charts; adjust the ROC/SMA lengths, higher timeframe and ATR
//   for other assets.
//
// CONCEPT CREDIT
//   The Know Sure Thing (KST) oscillator was created by Martin J. Pring. This is an
//   original multi-cycle implementation built around that public concept and is not
//   affiliated with, nor endorsed by, its originator.
//
// HONESTY NOTES
//   - KST is lagging; this confirms moves, it does not predict them.
//   - Confidence (0-100) is an ordinal heuristic, NOT a probability or win rate.
//   - Divergence prints a few bars after the pivot it confirms — inherent to honest
//     pivot detection, not a bug. Signals confirm on bar close (non-repainting).
//
// DISCLAIMER
//   For research and educational purposes only. NOT financial advice and NO guarantee
//   of profitability or accuracy. Indicators describe past price behavior; they do not
//   predict the future. Trading carries risk of loss. Test on out-of-sample data and
//   make your own decisions. The author accepts no liability for any use of this script.
// ═════════════════════════════════════════════════════════════════════════════
indicator("Multi-Cycle KST Oscillator", "MC KST", overlay = false,
     max_lines_count = 500, max_labels_count = 300)

// ═════════════════════════════════════════════════════════════════════════════
// 1 · DATA SOURCE  (configure for any market)
// ═════════════════════════════════════════════════════════════════════════════
g1 = "1 · Data Source"
srcPrice = input.source(close, "Price source (KST & trend)", group = g1,
     tooltip = "Series the KSTs are built from. Default = close. Choose any series (hl2, ohlc4, or another indicator's output) so the engine fits the instrument you trade.")
srcHigh  = input.source(high, "High source (bearish divergence)", group = g1)
srcLow   = input.source(low,  "Low source (bullish divergence)",  group = g1)

// ═════════════════════════════════════════════════════════════════════════════
// 2 · KST CYCLES  (short = plotted, intermediate & long = context / gate)
// ═════════════════════════════════════════════════════════════════════════════
g2 = "2 · Short-term KST (plotted)"
sR1 = input.int(10, "ROC 1", minval = 1, group = g2, inline = "r")
sR2 = input.int(15, "ROC 2", minval = 1, group = g2, inline = "r")
sR3 = input.int(20, "ROC 3", minval = 1, group = g2, inline = "r")
sR4 = input.int(30, "ROC 4", minval = 1, group = g2, inline = "r")
sS1 = input.int(10, "SMA 1", minval = 1, group = g2, inline = "s")
sS2 = input.int(10, "SMA 2", minval = 1, group = g2, inline = "s")
sS3 = input.int(10, "SMA 3", minval = 1, group = g2, inline = "s")
sS4 = input.int(15, "SMA 4", minval = 1, group = g2, inline = "s")
sSigLen = input.int(9, "Signal SMA", minval = 1, group = g2)

g3 = "3 · Intermediate KST"
iR1 = input.int(20, "ROC 1", minval = 1, group = g3, inline = "r")
iR2 = input.int(30, "ROC 2", minval = 1, group = g3, inline = "r")
iR3 = input.int(40, "ROC 3", minval = 1, group = g3, inline = "r")
iR4 = input.int(65, "ROC 4", minval = 1, group = g3, inline = "r")
iS1 = input.int(10, "SMA 1", minval = 1, group = g3, inline = "s")
iS2 = input.int(10, "SMA 2", minval = 1, group = g3, inline = "s")
iS3 = input.int(10, "SMA 3", minval = 1, group = g3, inline = "s")
iS4 = input.int(15, "SMA 4", minval = 1, group = g3, inline = "s")

g4 = "4 · Long-term KST (regime gate)"
lR1 = input.int(40,  "ROC 1", minval = 1, group = g4, inline = "r")
lR2 = input.int(65,  "ROC 2", minval = 1, group = g4, inline = "r")
lR3 = input.int(75,  "ROC 3", minval = 1, group = g4, inline = "r")
lR4 = input.int(100, "ROC 4", minval = 1, group = g4, inline = "r")
lS1 = input.int(15, "SMA 1", minval = 1, group = g4, inline = "s")
lS2 = input.int(15, "SMA 2", minval = 1, group = g4, inline = "s")
lS3 = input.int(15, "SMA 3", minval = 1, group = g4, inline = "s")
lS4 = input.int(20, "SMA 4", minval = 1, group = g4, inline = "s")

// ═════════════════════════════════════════════════════════════════════════════
// 5 · NORMALIZATION & DISPLAY
// ═════════════════════════════════════════════════════════════════════════════
g5 = "5 · Normalization & Display"
displayMode = input.string("Z-Score (statistical)", "Oscillator mode",
     options = ["Raw (native KST)", "Z-Score (statistical)", "Robust Z (median/MAD)"], group = g5,
     tooltip = "Raw = native KST (scale varies per symbol). Z-Score standardizes the short-term KST over a rolling window. Robust Z uses median/MAD, less sensitive to outliers.")
modeRaw = displayMode == "Raw (native KST)"
modeRob = displayMode == "Robust Z (median/MAD)"
useStat = not modeRaw
statLen = input.int(200, "Statistical window", minval = 20, group = g5)
vizStyle = input.string("Gradient area + glow", "Visual style",
     options = ["Gradient area + glow", "Histogram", "Line"], group = g5)
showIT = input.bool(true, "Plot intermediate KST", inline = "x", group = g5)
showLT = input.bool(true, "Plot long-term KST",    inline = "x", group = g5)

// ═════════════════════════════════════════════════════════════════════════════
// 6 · THRESHOLD BANDS
// ═════════════════════════════════════════════════════════════════════════════
g6 = "6 · Threshold Bands"
warnRaw = input.float(100.0, "Warn (Raw)", inline = "raw", group = g6)
extRaw  = input.float(200.0, "Extreme (Raw)", inline = "raw", group = g6,
     tooltip = "Bands used in Raw mode (native KST units; adjust per instrument).")
warnZ   = input.float(2.0, "Warn (Z)", inline = "z", group = g6)
extZ    = input.float(3.0, "Extreme (Z)", inline = "z", group = g6,
     tooltip = "Bands used in Z-Score / Robust modes (in sigma).")
warnLevel = useStat ? warnZ : warnRaw
extLevel  = useStat ? extZ  : extRaw

// ═════════════════════════════════════════════════════════════════════════════
// 7 · CONFIRMATION FILTERS
// ═════════════════════════════════════════════════════════════════════════════
g7 = "7 · Confirmation Filters"
maType = input.string("EMA", "Trend MA type", options = ["EMA", "SMA"], inline = "ma", group = g7)
maLen  = input.int(50, "len", minval = 1, inline = "ma", group = g7)
useRegime  = input.bool(true, "Regime filter (ADX)", inline = "adx", group = g7)
adxThresh  = input.float(20.0, "ADX >=", minval = 0.0, inline = "adx", group = g7)
diLen      = input.int(14, "DI length", minval = 1, inline = "adx2", group = g7)
adxSm      = input.int(14, "ADX smooth", minval = 1, inline = "adx2", group = g7)
shadeRange = input.bool(true, "Shade ranging regime", group = g7)
useHTF = input.bool(true, "Higher-timeframe filter", inline = "htf", group = g7)
htfRes = input.timeframe("D", "TF", inline = "htf", group = g7,
     tooltip = "Higher-timeframe directional bias (non-repainting, previous confirmed bar). Default Daily suits NIFTY intraday charts. Set equal to or higher than your chart timeframe.")

// ═════════════════════════════════════════════════════════════════════════════
// 8 · DIVERGENCE
// ═════════════════════════════════════════════════════════════════════════════
g8 = "8 · Divergence"
useDiv  = input.bool(true, "Detect divergences", group = g8)
showReg = input.bool(true, "Regular", inline = "d", group = g8)
showHid = input.bool(true, "Hidden",  inline = "d", group = g8)
pivL    = input.int(5, "Pivot left",  minval = 1, inline = "p", group = g8)
pivR    = input.int(5, "Pivot right", minval = 1, inline = "p", group = g8)
maxPiv  = input.int(60, "Max bars between pivots", minval = 5, group = g8)

// ═════════════════════════════════════════════════════════════════════════════
// 9 · CONFIDENCE ENGINE
// ═════════════════════════════════════════════════════════════════════════════
g9 = "9 · Confidence Engine"
erLen  = input.int(20, "Efficiency-Ratio length", minval = 2, group = g9)
convLo = input.float(0.70, "Conviction at chop",        minval = 0.1, step = 0.05, inline = "c", group = g9)
convHi = input.float(1.30, "Conviction at clean trend", minval = 0.1, step = 0.05, inline = "c", group = g9)
wST = input.int(30, "Weight KST/signal",  minval = 0, inline = "w1", group = g9)
wLT = input.int(30, "Weight long-term",   minval = 0, inline = "w1", group = g9)
wPL = input.int(20, "Weight price-loc",   minval = 0, inline = "w2", group = g9)
wDV = input.int(20, "Weight divergence",  minval = 0, inline = "w2", group = g9)
confThresh = input.int(55, "Confirmed-signal confidence", minval = 0, maxval = 100, group = g9)

// ═════════════════════════════════════════════════════════════════════════════
// 10 · RISK TARGETS (ATR)
// ═════════════════════════════════════════════════════════════════════════════
g10 = "10 · Risk Targets (ATR)"
atrLen  = input.int(14, "ATR period", minval = 1, group = g10)
atrMult = input.float(2.0, "Stop = ATR ×", minval = 0.1, step = 0.1, inline = "rk", group = g10)
rMult   = input.float(2.0, "Target = R ×", minval = 0.1, step = 0.1, inline = "rk", group = g10,
     tooltip = "Reward-to-risk multiple of the ATR stop distance. Reference levels only.")

// ═════════════════════════════════════════════════════════════════════════════
// 11 · SIGNALS & ALERTS
// ═════════════════════════════════════════════════════════════════════════════
g11 = "11 · Signals & Alerts"
confirmClose = input.bool(true, "Confirm on bar close (non-repainting)", group = g11)
useAlert     = input.bool(true, "Fire dynamic alert() messages (webhooks)", group = g11)

// ═════════════════════════════════════════════════════════════════════════════
// 12 · VISUALS & DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════
g12 = "12 · Visuals & Dashboard"
colBull   = input.color(#2ebd85, "Uptrend color",   inline = "col", group = g12)
colBear   = input.color(#f6465d, "Downtrend color", inline = "col", group = g12)
showTable = input.bool(true, "Show dashboards", group = g12)
dashTheme = input.string("Auto (match chart)", "Dashboard theme",
     options = ["Auto (match chart)", "Dark", "Light"], group = g12,
     tooltip = "Auto detects the chart background brightness and keeps both panels legible on any theme. Dark/Light force a palette.")

// ═════════════════════════════════════════════════════════════════════════════
// KST ENGINE  — weighted sum of four smoothed Rate-of-Change series (weights 1..4)
// ═════════════════════════════════════════════════════════════════════════════
f_kst(s, r1, r2, r3, r4, m1, m2, m3, m4) => ta.sma(ta.roc(s, r1), m1) * 1.0 + ta.sma(ta.roc(s, r2), m2) * 2.0 + ta.sma(ta.roc(s, r3), m3) * 3.0 + ta.sma(ta.roc(s, r4), m4) * 4.0

stKST = f_kst(srcPrice, sR1, sR2, sR3, sR4, sS1, sS2, sS3, sS4)
itKST = f_kst(srcPrice, iR1, iR2, iR3, iR4, iS1, iS2, iS3, iS4)
ltKST = f_kst(srcPrice, lR1, lR2, lR3, lR4, lS1, lS2, lS3, lS4)
stSigRaw = ta.sma(stKST, sSigLen)

// ── Normalization ──
// The oscillator AND its signal line share the SHORT-term KST's statistics, so the
// crossover relationship is preserved. Context cycles are normalized on their own
// statistics purely for display scaling.
zMean = ta.sma(stKST, statLen)
zSd   = ta.stdev(stKST, statLen)
medST = ta.percentile_linear_interpolation(stKST, statLen, 50)
madST = ta.percentile_linear_interpolation(math.abs(stKST - medST), statLen, 50)

f_applyST(x) =>
    modeRaw ? x : modeRob ? ((not na(madST) and madST != 0) ? 0.6745 * (x - medST) / madST : 0.0) : ((not na(zSd) and zSd != 0) ? (x - zMean) / zSd : 0.0)

f_normOwn(x) =>
    m  = ta.sma(x, statLen)
    sd = ta.stdev(x, statLen)
    md = ta.percentile_linear_interpolation(x, statLen, 50)
    ad = ta.percentile_linear_interpolation(math.abs(x - md), statLen, 50)
    modeRaw ? x : modeRob ? ((not na(ad) and ad != 0) ? 0.6745 * (x - md) / ad : 0.0) : ((not na(sd) and sd != 0) ? (x - m) / sd : 0.0)

plotOsc = f_applyST(stKST)
sigLine = f_applyST(stSigRaw)
itPlot  = f_normOwn(itKST)
ltPlot  = f_normOwn(ltKST)

warmReq  = useStat ? statLen : math.max(sR4, sS4) + sSigLen
warmedUp = bar_index >= warmReq

// ═════════════════════════════════════════════════════════════════════════════
// CONTEXT: price location, cycle alignment, regime, conviction, HTF, risk
// ═════════════════════════════════════════════════════════════════════════════
trendMA = maType == "EMA" ? ta.ema(close, maLen) : ta.sma(close, maLen)
priceUp = close > trendMA

stBull = plotOsc > sigLine
ltUp   = ltKST > ltKST[1]
ltDn   = ltKST < ltKST[1]
allBull = stKST > 0 and itKST > 0 and ltKST > 0
allBear = stKST < 0 and itKST < 0 and ltKST < 0

[diP, diM, adx] = ta.dmi(diLen, adxSm)
trending = adx >= adxThresh

erChange  = math.abs(close - close[erLen])
erVol     = math.sum(math.abs(close - close[1]), erLen)
er        = erVol != 0.0 ? erChange / erVol : 0.0
convScale = convLo + er * (convHi - convLo)

htfDir = nz(request.security(syminfo.tickerid, htfRes,
     math.sign(stKST - stSigRaw)[1], lookahead = barmerge.lookahead_off))

atr      = ta.atr(atrLen)
riskDist = atrMult * atr

// ═════════════════════════════════════════════════════════════════════════════
// DIVERGENCE  (pivot-based on the plotted oscillator, confirmed -> non-repainting)
// ═════════════════════════════════════════════════════════════════════════════
phFound = not na(ta.pivothigh(plotOsc, pivL, pivR))
plFound = not na(ta.pivotlow(plotOsc, pivL, pivR))

var float pLosc = na
var float pLprice = na
var int   pLbar = na
var float pHosc = na
var float pHprice = na
var int   pHbar = na

bullReg = false
bullHid = false
bearReg = false
bearHid = false

if plFound
    oVal = plotOsc[pivR]
    pVal = srcLow[pivR]
    bIdx = bar_index - pivR
    if useDiv and not na(pLosc) and (bIdx - pLbar) <= maxPiv
        bullReg := showReg and oVal > pLosc and pVal < pLprice
        bullHid := showHid and oVal < pLosc and pVal > pLprice
        if bullReg or bullHid
            line.new(pLbar, pLosc, bIdx, oVal, color = color.new(colBull, 88), width = 8)
            line.new(pLbar, pLosc, bIdx, oVal, color = color.new(colBull, 68), width = 4)
            line.new(pLbar, pLosc, bIdx, oVal, color = color.new(colBull, bullHid ? 35 : 0), width = 2)
            label.new(bIdx, oVal, bullReg ? "Bull" : "H-Bull", yloc = yloc.price,
                 style = label.style_label_up, color = color.new(colBull, 78), textcolor = color.new(colBull, 0), size = size.tiny)
    pLosc := oVal
    pLprice := pVal
    pLbar := bIdx

if phFound
    oVal = plotOsc[pivR]
    pVal = srcHigh[pivR]
    bIdx = bar_index - pivR
    if useDiv and not na(pHosc) and (bIdx - pHbar) <= maxPiv
        bearReg := showReg and oVal < pHosc and pVal > pHprice
        bearHid := showHid and oVal > pHosc and pVal < pHprice
        if bearReg or bearHid
            line.new(pHbar, pHosc, bIdx, oVal, color = color.new(colBear, 88), width = 8)
            line.new(pHbar, pHosc, bIdx, oVal, color = color.new(colBear, 68), width = 4)
            line.new(pHbar, pHosc, bIdx, oVal, color = color.new(colBear, bearHid ? 35 : 0), width = 2)
            label.new(bIdx, oVal, bearReg ? "Bear" : "H-Bear", yloc = yloc.price,
                 style = label.style_label_down, color = color.new(colBear, 78), textcolor = color.new(colBear, 0), size = size.tiny)
    pHosc := oVal
    pHprice := pVal
    pHbar := bIdx

// ═════════════════════════════════════════════════════════════════════════════
// CONFIDENCE ENGINE  (orthogonal votes, weighted, scaled by conviction)
// ═════════════════════════════════════════════════════════════════════════════
vST = stBull ? 1.0 : -1.0
vLT = ltUp ? 1.0 : ltDn ? -1.0 : 0.0
vPL = priceUp ? 1.0 : -1.0
vDV = (bullReg or bullHid) ? 1.0 : (bearReg or bearHid) ? -1.0 : 0.0
wSum = math.max(1, wST + wLT + wPL + wDV)
rawScore = (vST * wST + vLT * wLT + vPL * wPL + vDV * wDV) / wSum * 100.0
dir  = rawScore >= 0 ? 1 : -1
conf = math.min(100.0, math.abs(rawScore) * convScale)

// ═════════════════════════════════════════════════════════════════════════════
// PLOTS
// ═════════════════════════════════════════════════════════════════════════════
isGrad = vizStyle == "Gradient area + glow"
isHist = vizStyle == "Histogram"
isLine = vizStyle == "Line"
baseCol   = dir > 0 ? colBull : colBear
intensity = math.min(math.abs(plotOsc) / math.max(extLevel, 0.0001), 1.0)

plot(plotOsc, "Histogram", style = plot.style_histogram, linewidth = 2,
     color = isHist ? color.new(baseCol, int(math.round(55 * (1 - intensity)))) : na)
plot(isGrad ? plotOsc : na, "Area", style = plot.style_area,
     color = color.new(baseCol, int(math.round(92 - intensity * 30))), display = display.pane)

showLine = isGrad or isLine
plot(showLine ? plotOsc : na, "Glow outer", style = plot.style_line, linewidth = 8, color = color.new(baseCol, 88), display = display.pane)
plot(showLine ? plotOsc : na, "Glow inner", style = plot.style_line, linewidth = 4, color = color.new(baseCol, 68), display = display.pane)
plot(showLine ? plotOsc : na, "KST",        style = plot.style_line, linewidth = 2, color = color.new(baseCol, 0), display = display.pane)

plot(sigLine, "Signal", color = color.new(color.orange, 0), linewidth = 1, display = display.pane)
plot(showIT ? itPlot : na, "Intermediate KST", color = color.new(color.blue, 35), display = display.pane)
plot(showLT ? ltPlot : na, "Long-term KST",    color = color.new(color.purple, 35), display = display.pane)

hline(0, "Zero", color = color.new(color.gray, 50))
plot( warnLevel, "Warn +",    color = color.new(color.gray, 60), linewidth = 1, display = display.pane)
plot(-warnLevel, "Warn -",    color = color.new(color.gray, 60), linewidth = 1, display = display.pane)
plot( extLevel,  "Extreme +", color = color.new(color.gray, 35), linewidth = 1, display = display.pane)
plot(-extLevel,  "Extreme -", color = color.new(color.gray, 35), linewidth = 1, display = display.pane)

bgcolor(useRegime and shadeRange and not trending ? color.new(color.gray, 92) : na, title = "Ranging regime")

// ═════════════════════════════════════════════════════════════════════════════
// SIGNALS
// ═════════════════════════════════════════════════════════════════════════════
longFilter  = (not useRegime or trending) and (not useHTF or htfDir >= 0)
shortFilter = (not useRegime or trending) and (not useHTF or htfDir <= 0)
sigConfirm  = (not confirmClose) or barstate.isconfirmed
buySig  = ta.crossover(plotOsc, sigLine)  and ltUp and longFilter  and conf >= confThresh and sigConfirm and warmedUp
sellSig = ta.crossunder(plotOsc, sigLine) and ltDn and shortFilter and conf >= confThresh and sigConfirm and warmedUp

plotshape(buySig,  "Buy",  style = shape.triangleup,   location = location.bottom, color = color.new(colBull, 0), size = size.small)
plotshape(sellSig, "Sell", style = shape.triangledown, location = location.top,    color = color.new(colBear, 0), size = size.small)

alertcondition(buySig,  "Buy Signal",         "MC KST BUY signal")
alertcondition(sellSig, "Sell Signal",        "MC KST SELL signal")
alertcondition(bullReg, "Bullish Divergence", "MC KST regular bullish divergence")
alertcondition(bearReg, "Bearish Divergence", "MC KST regular bearish divergence")
alertcondition(allBull, "All Cycles Bull",    "MC KST: short, intermediate and long-term all bullish")
alertcondition(allBear, "All Cycles Bear",    "MC KST: short, intermediate and long-term all bearish")

if useAlert and barstate.isconfirmed
    if buySig
        alert("MC KST BUY | " + syminfo.ticker + " | " + timeframe.period + " | osc=" + str.tostring(plotOsc, "#.##") + " | conf=" + str.tostring(conf, "#"), alert.freq_once_per_bar_close)
    if sellSig
        alert("MC KST SELL | " + syminfo.ticker + " | " + timeframe.period + " | osc=" + str.tostring(plotOsc, "#.##") + " | conf=" + str.tostring(conf, "#"), alert.freq_once_per_bar_close)

stopLvl = dir == 1 ? close - riskDist : close + riskDist
tgtLvl  = dir == 1 ? close + riskDist * rMult : close - riskDist * rMult

// ═════════════════════════════════════════════════════════════════════════════
// DASHBOARDS  — right = the decision (top 5), left = context + risk (next 5)
//   Theme-adaptive: opaque cells with a palette chosen from the chart-background
//   brightness, so both panels stay legible on any chart theme.
// ═════════════════════════════════════════════════════════════════════════════
var table dashR = table.new(position.top_right, 2, 6, frame_width = 1, border_width = 1)
var table dashL = table.new(position.top_left,  2, 6, frame_width = 1, border_width = 1)
if barstate.islast and showTable
    bgc    = chart.bg_color
    luma   = na(bgc) ? 0.0 : color.r(bgc) * 0.299 + color.g(bgc) * 0.587 + color.b(bgc) * 0.114
    darkUI = dashTheme == "Dark" ? true : dashTheme == "Light" ? false : (na(bgc) or luma < 140)

    panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
    rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
    txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
    txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
    frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
    bullC   = darkUI ? colBull : color.rgb(22, 151, 106)
    bearC   = darkUI ? colBear : color.rgb(210, 45, 68)
    warnC   = darkUI ? color.orange : color.rgb(201, 123, 0)
    flatC   = darkUI ? color.gray : color.rgb(122, 130, 139)
    hdr     = color.new(colBull, 0)

    table.set_frame_color(dashR, frameC)
    table.set_border_color(dashR, frameC)
    table.set_frame_color(dashL, frameC)
    table.set_border_color(dashL, frameC)
    modeLbl = modeRaw ? "Raw" : modeRob ? "Robust Z" : "Z-Score"

    // RIGHT — the decision (top 5)
    table.cell(dashR, 0, 0, "MC KST", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(dashR, 1, 0, modeLbl, text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(dashR, 0, 1, "Bias", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dashR, 1, 1, dir == 1 ? "▲ Long" : "▼ Short", text_color = dir == 1 ? bullC : bearC, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dashR, 0, 2, "Confidence", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(dashR, 1, 2, str.tostring(math.round(conf)) + " / 100", text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
    table.cell(dashR, 0, 3, "Signal", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dashR, 1, 3, buySig ? "BUY" : sellSig ? "SELL" : "—", text_color = buySig ? bullC : sellSig ? bearC : flatC, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dashR, 0, 4, "Cycle align", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(dashR, 1, 4, allBull ? "ALL BULL" : allBear ? "ALL BEAR" : "Mixed", text_color = allBull ? bullC : allBear ? bearC : flatC, bgcolor = panelBg, text_size = size.tiny)
    table.cell(dashR, 0, 5, "Oscillator", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dashR, 1, 5, str.tostring(plotOsc, "#.##"), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)

    // LEFT — context + risk (next 5)
    table.cell(dashL, 0, 0, "Context", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(dashL, 1, 0, warmedUp ? "Ready" : "Warming", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(dashL, 0, 1, "Long-term KST", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dashL, 1, 1, ltUp ? "▲ Rising" : ltDn ? "▼ Falling" : "– Flat", text_color = ltUp ? bullC : ltDn ? bearC : flatC, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dashL, 0, 2, "Regime", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(dashL, 1, 2, (trending ? "Trend " : "Range ") + str.tostring(adx, "#"), text_color = trending ? bullC : warnC, bgcolor = panelBg, text_size = size.tiny)
    table.cell(dashL, 0, 3, "Divergence", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dashL, 1, 3, (bullReg or bullHid) ? "Bullish" : (bearReg or bearHid) ? "Bearish" : "None", text_color = (bullReg or bullHid) ? bullC : (bearReg or bearHid) ? bearC : flatC, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dashL, 0, 4, "Stop (ATR)", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(dashL, 1, 4, str.tostring(stopLvl, format.mintick), text_color = bearC, bgcolor = panelBg, text_size = size.tiny)
    table.cell(dashL, 0, 5, "Target", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dashL, 1, 5, str.tostring(tgtLvl, format.mintick), text_color = bullC, bgcolor = rowAlt, text_size = size.tiny)
````
