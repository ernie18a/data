# SAR/ATR Trend-Extension Oscillator

- url: https://www.tradingview.com/script/jRQC3dmp-SAR-ATR-Trend-Extension-Oscillator/
- type: indicator
- pine_id: PUB;97ca29af0f054b8786d4bb4c4c6887de
- version: 3.0

## Description

SAR/ATR Trend-Extension Oscillator

WHAT THIS INDICATOR IS

The SAR/ATR Trend-Extension Oscillator measures, in a single line, how far price has stretched away from its Parabolic SAR trailing reference, and it expresses that distance in units of volatility rather than raw price. The output is a signed oscillator: it rises into positive (green) territory as an uptrend extends and falls into negative (red) territory as a downtrend extends. The further the value sits from the zero line, the more stretched the current move is relative to its own recent volatility.

It is built as ONE coherent reading. Parabolic SAR and Average True Range (ATR) are not plotted side by side; they are fused mathematically into the oscillator value. Three further elements - a rolling statistical standardization, an ADX regime filter and a higher-timeframe trend filter - qualify and contextualize that value rather than adding separate indicators to the pane.

WHY THESE COMPONENTS ARE COMBINED (and how they work together)

Each ingredient is included to solve a specific weakness of the one before it.

1) Parabolic SAR provides trend direction and a trailing stop level, but on its own it only tells you which side of the trend you are on. The raw gap between price and SAR is measured in price points, which cannot be compared between a low-priced stock and a high-valued index, or between a quiet and a volatile session. So SAR alone cannot answer "how stretched is this move."

2) ATR answers that. By dividing the SAR-to-price gap by ATR, the distance becomes volatility-relative: "price is X average true ranges beyond its SAR." This SAR-divided-by-ATR step is the core of the indicator and produces information that neither Parabolic SAR nor ATR shows alone - a bounded, cross-market measure of trend extension that reads consistently across symbols and timeframes.

3) Rolling standardization (Z-Score, or robust median/MAD) fixes a subtler problem: even an ATR-normalized value has a distribution that drifts over time, so one fixed threshold means different things in different conditions. Standardizing the value over a lookback window rescales it so the +/-2 and +/-3 reference levels keep a stable statistical meaning. A "Raw" mode (the plain volatility-normalized value, no rescaling) is also available.

4) ADX regime filter. Parabolic SAR is prone to repeated false flips in sideways markets. ADX measures trend strength, so the indicator suppresses buy/sell flags whenever ADX is below a user threshold (a ranging market) and shades the background to show it. ADX is never drawn on the oscillator; it only gates the signals.

5) Higher-timeframe filter. The same SAR direction is read from a higher, confirmed timeframe and used to filter out crossings that fight the dominant trend. It is the identical calculation applied to a larger context, not a different indicator.

6) Divergence. Because the oscillator is a measure of trend extension, a price high paired with a lower oscillator high (or a price low paired with a higher oscillator low) indicates the trend is extending less forcefully. Regular and hidden divergences are detected from confirmed pivots and drawn with connecting lines and labels.

Putting it together, the plotted value is one number: sign(SAR trend) x (SAR-to-price gap / ATR), optionally standardized and clamped to limit single-bar spikes.
A buy or sell flag is raised only when that oscillator crosses the Signal level AND the ADX regime AND the higher-timeframe direction agree. Everything feeds one question: is price extending, in a genuine trend, in line with the larger trend?

WHAT MAKES IT ORIGINAL

This is not Parabolic SAR with an ATR drawn next to it. It transforms the SAR trailing stop into a continuous, signed, volatility-normalized and statistically standardized extension oscillator, then wraps that single value in regime and higher-timeframe gating plus divergence logic. The resulting "how stretched is this trend, on a comparable scale" reading does not exist in either source indicator.

HOW TO USE IT

- Choose a normalization mode: Raw, Z-Score, or Robust (median/MAD, least sensitive to spikes).
- Read color and distance: green = uptrend extension, red = downtrend extension; the further from zero, the more extended. The Signal, Warning and Extreme levels mark progressively stretched zones.
- Treat the triangle markers (a Signal-level cross that agrees with the ADX regime and the higher-timeframe bias) as points to investigate, not as automatic entries.
- Use divergences as early warning that extension is fading, and the on-pane dashboard for trend, regime, higher-timeframe bias and ATR-based stop/target context. The stop and target figures are reference levels only.
- All parameters - SAR step and maximum, ATR period and smoothing type, the standardization window, every threshold, the ADX threshold and the higher timeframe - are adjustable.

REPAINTING

Signals confirm on bar close by default and do not repaint. The higher-timeframe filter reads the previous closed higher-timeframe bar, so it does not look ahead. Divergence labels appear a few bars after the pivot they confirm; that lag is inherent to honest pivot detection and is expected behavior.

ATTRIBUTION

This implementation builds on the original concept of combining Parabolic SAR with ATR. The volatility normalization, statistical standardization, regime and higher-timeframe filtering, divergence detection and alerting described above are part of this independent implementation.

DISCLAIMER
This script is provided for research and educational purposes only. It is not financial advice and makes no guarantee of profitability or accuracy. Indicators describe past and present price behavior; they do not predict future prices, and no indicator works in all conditions. Trading involves substantial risk of loss. Always test on historical and out-of-sample data and make your own independent decisions. The author accepts no liability for any use of this script.

## Source Code

````pine
//@version=6
// ═════════════════════════════════════════════════════════════════════════════
// SAR/ATR Trend-Extension Oscillator
// ─────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   A single oscillator that measures how far price has "extended" beyond its
//   Parabolic SAR trailing reference, expressed in volatility (ATR) units. This is
//   NOT a set of indicators shown side by side: Parabolic SAR and ATR are fused
//   into one derived value, and the other parts (statistical standardization, an
//   ADX regime filter, a higher-timeframe trend filter, and divergence detection)
//   are decision-support layers built around that single value.
//
// WHY THESE COMPONENTS ARE COMBINED  (mashup rationale)
//   Parabolic SAR alone gives only a binary trend direction and a trailing stop
//   level. The raw gap between price and SAR is measured in price points, which is
//   not comparable between, say, a 20-price stock and a 23,000-point index, or
//   between a calm and a volatile session. ATR fixes exactly this: dividing the
//   SAR-to-price gap by ATR turns that distance into a volatility-relative number
//   ("the move is X average ranges beyond its SAR"). This SAR / ATR fusion is the
//   core of the tool and yields information neither input shows alone — a bounded,
//   cross-market measure of how stretched a trend is.
//
//   Even an ATR-normalized value has a shifting distribution, so one fixed level
//   means different things in different markets. The optional Z-Score / robust
//   (median-MAD) standardization rescales the value over a rolling window so the
//   +/-2 and +/-3 levels keep a consistent statistical meaning across symbols and
//   timeframes.
//
//   The remaining modules QUALIFY the oscillator's signals; they do not plot extra
//   indicators on the pane:
//     - ADX regime filter: Parabolic SAR whipsaws in sideways markets, so signals
//       that occur while ADX is below the threshold (ranging) are suppressed and
//       the background is shaded. ADX only gates; it is never plotted.
//     - Higher-timeframe filter: the same SAR direction is read from a higher,
//       confirmed (non-repainting) timeframe, filtering out counter-trend crosses.
//     - Divergence: because the oscillator measures trend extension, a price high
//       against a lower oscillator high (or the inverse) flags fading extension.
//       Regular and hidden divergences are detected from confirmed pivots.
//
// HOW THE PARTS WORK TOGETHER
//   The plotted oscillator is ONE number:
//       sign(SAR trend) x (SAR-to-price gap / ATR), optionally standardized and
//       winsorized to limit single-bar spikes.
//   A buy/sell flag is raised only when that oscillator crosses the Signal level
//   AND the ADX regime AND the higher-timeframe direction all agree. Divergences
//   and the ATR-based stop/target figures in the dashboard add context. Every
//   module feeds one question: is price extending, in a genuine trend, in line
//   with the larger trend?
//
// UNIVERSAL ACROSS MARKETS (configurable data source)
//   The trend comparison and the extension measurement read from user-selectable
//   inputs (Price Source / High Source / Low Source). Defaults are close, high and
//   low, but any series can be chosen from the dropdown — including the output of
//   another indicator on the chart — so the engine can be pointed at whatever data
//   suits the instrument you trade. Combined with the ATR normalization and the
//   optional statistical rescaling, the readings stay comparable across stocks,
//   futures, forex, crypto and indices on any timeframe. (Parabolic SAR and ATR are
//   intrinsically built from the bar's high/low/close, so those internals always
//   use standard OHLC; the configurable sources govern the price/extension layer.)
//
// WHAT MAKES IT ORIGINAL
//   It is not Parabolic SAR with an ATR drawn beside it. It converts the SAR stop
//   into a continuous, signed, volatility-normalized and statistically standardized
//   extension oscillator, then wraps it in regime/HTF gating and divergence logic.
//   The result — a bounded "how stretched is this trend" reading that is comparable
//   across assets — does not exist in either source indicator.
//
// HOW TO USE
//   - Choose a mode: Raw (the plain volatility-normalized value, no statistical
//     rescaling), Z-Score, or Robust (median/MAD, least sensitive to spikes).
//   - Optionally change Price/High/Low Source so the engine reads the series that
//     best fits the asset or data you are analysing.
//   - Green = uptrend extension, red = downtrend extension; further from zero =
//     more stretched. Levels mark Signal / Warning / Extreme zones.
//   - Triangles mark Signal-level crossings that agree with the ADX regime and the
//     higher-timeframe bias, and can trigger alerts. Treat them as points to
//     investigate, not automatic entries.
//   - Use divergences as early warning of fading extension; use the dashboard for
//     trend / regime / HTF / risk context. ATR stop & target are reference only.
//   - SAR step/max, ATR period & smoothing, the window, thresholds, the ADX
//     threshold and the higher timeframe are all configurable.
//
// NOTES
//   - Signals confirm on bar close by default (non-repainting). The HTF filter uses
//     the previous closed HTF bar. Divergence prints a few bars after the pivot it
//     confirms — that lag is inherent to honest pivot detection.
//
// DISCLAIMER
//   For research and educational purposes only. NOT financial advice and NO
//   guarantee of profitability or accuracy. Indicators describe price behavior;
//   they do not predict the future. Trading carries risk of loss. Test on
//   out-of-sample data and make your own decisions. The author accepts no
//   liability for any use of this script.
// ═════════════════════════════════════════════════════════════════════════════
indicator("SAR/ATR Trend-Extension Oscillator", "SAR-ATR TX", overlay = false,
     max_lines_count = 200, max_labels_count = 300)

// ─────────────── Groups ───────────────
g_src  = "Data Source"
g_core = "Core (SAR / ATR)"
g_disp = "Display & Normalization"
g_lvl  = "Threshold Levels"
g_reg  = "Regime Filter (ADX)"
g_htf  = "Higher-Timeframe Filter"
g_div  = "Divergence"
g_sig  = "Signals & Alerts"
g_risk = "Risk Context (ATR stop / target)"
g_vis  = "Visuals"

// ─────────────── Data source inputs ───────────────
srcPrice = input.source(close, "Price source (trend & extension)", group = g_src,
     tooltip = "Series compared against SAR for trend direction and used for the risk-context price. Default = close. Pick any series (e.g. hl2, ohlc4, or another indicator's output) so the tool fits the asset/market you trade.")
srcHigh  = input.source(high, "High source (upside extension)", group = g_src,
     tooltip = "Series used to measure how far an uptrend has extended beyond SAR. Default = high.")
srcLow   = input.source(low,  "Low source (downside extension)", group = g_src,
     tooltip = "Series used to measure how far a downtrend has extended beyond SAR. Default = low.")

// ─────────────── Core inputs ───────────────
pstep     = input.float(0.02, "SAR step (start & increment)", step = 0.01, minval = 0.0, group = g_core)
pMax      = input.float(0.20, "SAR maximum",                  step = 0.01, minval = 0.0, group = g_core)
atrPeriod = input.int(7, "ATR period", minval = 1, group = g_core)
atrMethod = input.string("SMA", "ATR smoothing",
     options = ["SMA", "Wilder (RMA)", "EMA"], group = g_core,
     tooltip = "Moving-average type applied to True Range to form the ATR. SMA = simple moving average; Wilder (RMA) = Wilder's smoothed average (the classic ATR); EMA = exponential moving average.")

// ─────────────── Display / normalization inputs ───────────────
displayMode = input.string("Z-Score (statistical)", "Oscillator mode",
     options = ["Raw (ATR-normalized)", "Z-Score (statistical)", "Robust Z (median/MAD)"], group = g_disp,
     tooltip = "Raw = original behavior. Z-Score standardizes the extension over a rolling window. Robust Z uses median/MAD — less sensitive to fat tails and outliers.")
modeRaw  = displayMode == "Raw (ATR-normalized)"
modeRob  = displayMode == "Robust Z (median/MAD)"
useStat  = not modeRaw                                  // statistical (sigma-style) scale
statLen  = input.int(200, "Statistical window", minval = 20, group = g_disp)
clampVal = input.float(10.0, "Winsorize / clamp magnitude", minval = 1.0, group = g_disp,
     tooltip = "Caps the raw extension before stats so a single spike can't dominate.")
vizStyle = input.string("Gradient area + glow", "Visual style",
     options = ["Gradient area + glow", "Histogram", "Line"], group = g_disp)
emaOn    = input.bool(false, "Show signal EMA", inline = "ema", group = g_disp)
emaLen   = input.int(5, "len", inline = "ema", minval = 1, group = g_disp)

// ─────────────── Threshold levels (per mode) ───────────────
sigRaw  = input.float(2.5, "Signal", inline = "raw", group = g_lvl)
warnRaw = input.float(5.0, "Warn",   inline = "raw", group = g_lvl)
extRaw  = input.float(7.0, "Extreme",inline = "raw", group = g_lvl, tooltip = "Levels used in Raw mode.")
sigZ    = input.float(1.5, "Signal", inline = "z", group = g_lvl)
warnZ   = input.float(2.0, "Warn",   inline = "z", group = g_lvl)
extZ    = input.float(3.0, "Extreme",inline = "z", group = g_lvl, tooltip = "Levels used in Z-Score / Robust modes (in sigma).")
sigLevel  = useStat ? sigZ  : sigRaw
warnLevel = useStat ? warnZ : warnRaw
extLevel  = useStat ? extZ  : extRaw

// ─────────────── Regime filter ───────────────
useRegime = input.bool(true, "Filter signals by regime", group = g_reg)
adxThresh = input.float(20.0, "ADX trend threshold", minval = 0.0, group = g_reg)
diLen     = input.int(14, "DI length", minval = 1, group = g_reg)
adxSm     = input.int(14, "ADX smoothing", minval = 1, group = g_reg)
shadeRange= input.bool(true, "Shade ranging regime", group = g_reg)

// ─────────────── Higher-timeframe filter ───────────────
useHTF = input.bool(true, "Filter signals by HTF trend", group = g_htf)
htfRes = input.timeframe("240", "Higher timeframe", group = g_htf,
     tooltip = "Set equal to or higher than your chart timeframe. Uses confirmed HTF bars (non-repainting).")

// ─────────────── Divergence ───────────────
useDiv  = input.bool(true, "Detect divergences", group = g_div)
showReg = input.bool(true,  "Regular", inline = "dv", group = g_div)
showHid = input.bool(false, "Hidden",  inline = "dv", group = g_div)
pivL    = input.int(5, "Pivot left",  minval = 1, group = g_div)
pivR    = input.int(5, "Pivot right", minval = 1, group = g_div)
maxPiv  = input.int(60, "Max bars between pivots", minval = 5, group = g_div)

// ─────────────── Signals & alerts ───────────────
confirmClose = input.bool(true, "Confirm signals on bar close (non-repainting)", group = g_sig)
useAlert     = input.bool(false, "Fire dynamic alert() messages (webhooks)", group = g_sig)

// ─────────────── Risk context ───────────────
showRisk = input.bool(true, "Show ATR stop / target in dashboard", group = g_risk)
atrMult  = input.float(2.0, "Stop = ATR ×", minval = 0.1, step = 0.1, group = g_risk)
rMult    = input.float(2.0, "Target = R ×", minval = 0.1, step = 0.1, group = g_risk,
     tooltip = "Reward-to-risk multiple of the ATR stop distance. These are reference levels only.")

// ─────────────── Visuals ───────────────
colBull  = input.color(#2ebd85, "Uptrend color",   group = g_vis)   // green
colBear  = input.color(#f6465d, "Downtrend color", group = g_vis)   // red
showTable= input.bool(true, "Show dashboard", group = g_vis)

// ═════════════════════════════════════════════════════════════════════════════
// CORE CALCULATION
//   SAR and ATR are intrinsically OHLC-based (built-in functions). The configurable
//   sources govern the trend comparison and the extension distance only.
// ═════════════════════════════════════════════════════════════════════════════
sar = ta.sar(pstep, pstep, pMax)
tr  = ta.tr(true)
atr = atrMethod == "Wilder (RMA)" ? ta.rma(tr, atrPeriod) : atrMethod == "EMA" ? ta.ema(tr, atrPeriod) : ta.sma(tr, atrPeriod)

valid    = not na(atr) and atr != 0.0
trendDir = valid ? (srcPrice > sar ? 1 : srcPrice < sar ? -1 : 0) : 0

// Signed magnitude of the SAR extension, normalized by ATR, winsorized
ext     = trendDir == 1 ? (srcHigh - sar) : trendDir == -1 ? (sar - srcLow) : 0.0
rawMag  = valid ? math.max(0.0, math.min(ext / atr, clampVal)) : 0.0
rawSigned = rawMag * trendDir

// Standard Z-Score of the extension magnitude (then re-signed by trend)
zMean = ta.sma(rawMag, statLen)
zSd   = ta.stdev(rawMag, statLen)
zMag  = (not na(zSd) and zSd != 0) ? (rawMag - zMean) / zSd : 0.0
zSigned = zMag * trendDir

// Robust Z-Score via median / MAD (0.6745 scales MAD to a sigma-equivalent)
med    = ta.percentile_linear_interpolation(rawMag, statLen, 50)
mad    = ta.percentile_linear_interpolation(math.abs(rawMag - med), statLen, 50)
robMag = (not na(mad) and mad != 0) ? 0.6745 * (rawMag - med) / mad : 0.0
robSigned = robMag * trendDir

plotOsc = modeRaw ? rawSigned : modeRob ? robSigned : zSigned

// Warming-up: statistical modes need a full window before readings are trustworthy
warmReq  = useStat ? statLen : atrPeriod
warmedUp = bar_index >= warmReq

// ─────────────── Regime ───────────────
[diP, diM, adx] = ta.dmi(diLen, adxSm)
trending = adx >= adxThresh

// ─────────────── Higher timeframe (non-repainting: previous confirmed HTF bar) ───
htfDir = nz(request.security(syminfo.tickerid, htfRes,
     (math.sign(srcPrice - ta.sar(pstep, pstep, pMax)))[1], lookahead = barmerge.lookahead_off))

// ═════════════════════════════════════════════════════════════════════════════
// PLOTS
// ═════════════════════════════════════════════════════════════════════════════
// ── Style flags & color intensity (stronger reading = more saturated) ──
isGrad = vizStyle == "Gradient area + glow"
isHist = vizStyle == "Histogram"
isLine = vizStyle == "Line"
baseCol   = trendDir == 1 ? colBull : trendDir == -1 ? colBear : color.gray
intensity = math.min(math.abs(plotOsc) / math.max(extLevel, 0.0001), 1.0)

// Histogram style
plot(plotOsc, "Histogram", style = plot.style_histogram, linewidth = 2,
     color = isHist ? color.new(baseCol, int(math.round(55 * (1 - intensity)))) : na)

// Gradient area style (fills to the zero line, opacity scales with strength)
plot(isGrad ? plotOsc : na, "Area", style = plot.style_area,
     color = color.new(baseCol, int(math.round(92 - intensity * 30))), display = display.pane)

// Glow + crisp line (used by Gradient and Line styles)
showLine = isGrad or isLine
plot(showLine ? plotOsc : na, "Glow outer", style = plot.style_line, linewidth = 8, color = color.new(baseCol, 88), display = display.pane)
plot(showLine ? plotOsc : na, "Glow inner", style = plot.style_line, linewidth = 4, color = color.new(baseCol, 68), display = display.pane)
plot(showLine ? plotOsc : na, "Line",       style = plot.style_line, linewidth = 2, color = color.new(baseCol, 0), display = display.pane)

// Optional EMA signal line
plot(emaOn ? ta.ema(plotOsc, emaLen) : na, "Signal EMA", color = color.new(color.orange, 0), linewidth = 1, display = display.pane)

hline(0, "Zero", color = color.new(color.gray, 50))
plot( warnLevel, "Warn +",    color = color.new(color.gray, 60), linewidth = 1, display = display.pane)
plot(-warnLevel, "Warn -",    color = color.new(color.gray, 60), linewidth = 1, display = display.pane)
plot( extLevel,  "Extreme +", color = color.new(color.gray, 35), linewidth = 1, display = display.pane)
plot(-extLevel,  "Extreme -", color = color.new(color.gray, 35), linewidth = 1, display = display.pane)

bgcolor(useRegime and shadeRange and not trending ? color.new(color.gray, 92) : na, title = "Ranging regime")

// ═════════════════════════════════════════════════════════════════════════════
// DIVERGENCE (pivot-based, confirmed -> non-repainting)
// ═════════════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(plotOsc, pivL, pivR)
pl = ta.pivotlow(plotOsc, pivL, pivR)
phFound = not na(ph)
plFound = not na(pl)

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
            c = bullReg ? colBull : color.new(colBull, 45)
            line.new(pLbar, pLosc, bIdx, oVal, color = c, width = 1)
            label.new(bIdx, oVal, bullReg ? "Bull" : "H-Bull", yloc = yloc.price,
                 style = label.style_label_up, color = color.new(c, 82), textcolor = c, size = size.tiny)
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
            c = bearReg ? colBear : color.new(colBear, 45)
            line.new(pHbar, pHosc, bIdx, oVal, color = c, width = 1)
            label.new(bIdx, oVal, bearReg ? "Bear" : "H-Bear", yloc = yloc.price,
                 style = label.style_label_down, color = color.new(c, 82), textcolor = c, size = size.tiny)
    pHosc := oVal
    pHprice := pVal
    pHbar := bIdx

// ═════════════════════════════════════════════════════════════════════════════
// SIGNALS
// ═════════════════════════════════════════════════════════════════════════════
longFilter  = (not useRegime or trending) and (not useHTF or htfDir >= 0)
shortFilter = (not useRegime or trending) and (not useHTF or htfDir <= 0)
sigConfirm  = (not confirmClose) or barstate.isconfirmed
buySig  = ta.crossover(plotOsc,  sigLevel) and longFilter  and sigConfirm and warmedUp
sellSig = ta.crossunder(plotOsc, -sigLevel) and shortFilter and sigConfirm and warmedUp

plotshape(buySig,  "Buy",  style = shape.triangleup,   location = location.bottom, color = color.new(colBull, 0), size = size.tiny)
plotshape(sellSig, "Sell", style = shape.triangledown, location = location.top,    color = color.new(colBear, 0), size = size.tiny)

// ─────────────── Alerts ───────────────
alertcondition(buySig,  "Buy Signal",          "SAR-ATR TX BUY signal")
alertcondition(sellSig, "Sell Signal",         "SAR-ATR TX SELL signal")
alertcondition(bullReg, "Bullish Divergence",  "SAR-ATR TX regular bullish divergence")
alertcondition(bearReg, "Bearish Divergence",  "SAR-ATR TX regular bearish divergence")

if useAlert and barstate.isconfirmed
    if buySig
        alert("SAR-ATR TX BUY | " + syminfo.ticker + " | " + timeframe.period + " | osc=" + str.tostring(plotOsc, "#.##") + " | adx=" + str.tostring(adx, "#.#"), alert.freq_once_per_bar_close)
    if sellSig
        alert("SAR-ATR TX SELL | " + syminfo.ticker + " | " + timeframe.period + " | osc=" + str.tostring(plotOsc, "#.##") + " | adx=" + str.tostring(adx, "#.#"), alert.freq_once_per_bar_close)

// ═════════════════════════════════════════════════════════════════════════════
// RISK CONTEXT (ATR stop / R-target reference levels — informational only)
// ═════════════════════════════════════════════════════════════════════════════
riskDist  = atrMult * atr
stopLvl   = trendDir == 1 ? srcPrice - riskDist : trendDir == -1 ? srcPrice + riskDist : na
tgtLvl    = trendDir == 1 ? srcPrice + riskDist * rMult : trendDir == -1 ? srcPrice - riskDist * rMult : na

// ═════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════
// Theme override: Auto reads the chart background; Dark / Light force a palette.
dashTheme = input.string("Auto (match chart)", "Dashboard theme",
     options = ["Auto (match chart)", "Dark", "Light"], group = g_vis,
     tooltip = "Auto detects the chart's background brightness and keeps the panel legible on any theme. Dark/Light force the panel regardless of the chart.")

var table dash = table.new(position.top_right, 2, 10, frame_width = 1, border_width = 1)
if barstate.islast and showTable
    // ── Theme-adaptive palette ─────────────────────────────────────────────
    // Cells are fully OPAQUE so the panel never washes out against the chart.
    // "Auto" computes the perceived brightness (luma) of the chart background and
    // flips to a dark or light scheme so text always has contrast.
    bgc    = chart.bg_color
    luma   = na(bgc) ? 0.0 : color.r(bgc) * 0.299 + color.g(bgc) * 0.587 + color.b(bgc) * 0.114
    darkUI = dashTheme == "Dark" ? true : dashTheme == "Light" ? false : (na(bgc) or luma < 140)

    panelBg = darkUI ? color.rgb(17, 22, 28)  : color.rgb(244, 246, 248)   // primary row
    rowAlt  = darkUI ? color.rgb(25, 31, 39)  : color.rgb(232, 236, 240)   // zebra row
    txtMain = darkUI ? color.white            : color.rgb(16, 20, 24)      // values
    txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)    // labels
    frameC  = darkUI ? color.rgb(58, 70, 84)  : color.rgb(196, 204, 212)   // frame / grid
    // Bull/Bear/Warn tuned so the saturated text stays readable on either scheme.
    bullC = darkUI ? colBull : color.rgb(22, 151, 106)
    bearC = darkUI ? colBear : color.rgb(210, 45, 68)
    warnC = darkUI ? color.orange : color.rgb(201, 123, 0)
    flatC = darkUI ? color.gray : color.rgb(122, 130, 139)
    hdr   = color.new(colBull, 0)   // solid green header, white text reads on both

    table.set_frame_color(dash, frameC)
    table.set_border_color(dash, frameC)

    modeLbl = modeRaw ? "Raw" : modeRob ? "Robust Z" : "Z-Score"
    table.cell(dash, 0, 0, "SAR/ATR TX", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(dash, 1, 0, modeLbl, text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(dash, 0, 1, "Trend", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dash, 1, 1, trendDir == 1 ? "▲ Up" : trendDir == -1 ? "▼ Down" : "– Flat",
         text_color = trendDir == 1 ? bullC : trendDir == -1 ? bearC : flatC, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dash, 0, 2, "Oscillator", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(dash, 1, 2, str.tostring(plotOsc, "#.##"), text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
    table.cell(dash, 0, 3, "Regime", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dash, 1, 3, (trending ? "Trend " : "Range ") + str.tostring(adx, "#"),
         text_color = trending ? bullC : warnC, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dash, 0, 4, "HTF bias", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(dash, 1, 4, htfDir > 0 ? "Bull" : htfDir < 0 ? "Bear" : "Flat",
         text_color = htfDir > 0 ? bullC : htfDir < 0 ? bearC : flatC, bgcolor = panelBg, text_size = size.tiny)
    table.cell(dash, 0, 5, "Signal", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dash, 1, 5, buySig ? "BUY" : sellSig ? "SELL" : "—",
         text_color = buySig ? bullC : sellSig ? bearC : flatC, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(dash, 0, 6, "Status", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(dash, 1, 6, warmedUp ? "Ready" : "Warming " + str.tostring(bar_index) + "/" + str.tostring(warmReq),
         text_color = warmedUp ? bullC : warnC, bgcolor = panelBg, text_size = size.tiny)
    if showRisk
        table.cell(dash, 0, 7, "Risk (ATR×)", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(dash, 1, 7, str.tostring(riskDist, format.mintick), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(dash, 0, 8, "Stop", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(dash, 1, 8, na(stopLvl) ? "—" : str.tostring(stopLvl, format.mintick), text_color = bearC, bgcolor = panelBg, text_size = size.tiny)
        table.cell(dash, 0, 9, "Target", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(dash, 1, 9, na(tgtLvl) ? "—" : str.tostring(tgtLvl, format.mintick), text_color = bullC, bgcolor = rowAlt, text_size = size.tiny)
````
