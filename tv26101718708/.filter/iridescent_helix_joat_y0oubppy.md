# Iridescent Helix [JOAT]

- url: https://www.tradingview.com/script/y0OuBPpY-Iridescent-Helix-JOAT/
- type: indicator
- pine_id: PUB;24cabdca48014e32bcb0af71563862d3
- version: 1.0

## Description

[b]Iridescent Helix [JOAT][/b]

Iridescent Helix is a composite momentum oscillator that lives in a sub-pane and projects cross-pane visuals onto the price chart. The composite blends three orthogonal momentum legs into a single normalized score in the range -100 to +100. Above the math, it adds a layered iridescent ribbon, a breath-opacity histogram, gradient overbought / oversold zones, cross-pane iridescent candle recoloring, and an in-pane pivot divergence engine.

[image]https://www.tradingview.com/x/uEfcPfcY/[/image]

[b]What makes it different[/b]
[list]
[*] The composite blends three independent momentum lenses: a volume-weighted-median price distance, a Connors-style triple RSI, and a clamped volume Z-score. Smoothed with a Hull Moving Average to reduce phase lag while preserving sensitivity.
[*] The visual stack uses seven plot layers per direction, hue-rotated through the bull or bear accent gradient, each layer at a different transparency and linewidth, producing a depth effect that single-color ribbons cannot match.
[*] A breath-opacity histogram fades columns when momentum is decelerating and brightens them when momentum is accelerating, giving an at-a-glance read of momentum derivative.
[*] An in-pane pivot divergence engine detects regular and hidden divergences and projects both as in-pane markers and as price-to-price connector lines on the price chart.
[/list]

[b]How it works[/b]
[list=1]
[*] Volume-weighted median over a rolling window. Sort close prices ascending, accumulate volumes in that order. The price at which cumulative volume crosses half of total volume is the weighted median.
[*] Composite equals 0.50 times the normalized distance from the volume-weighted median, plus 0.35 times the normalized Connors RSI, plus 0.15 times the clamped volume Z.
[*] Hull-smoothed and scaled to centi-percent, clamped to the range -100 to +100. EMA(21) signal line drawn alongside.
[*] Pivot divergence detection compares price pivots against composite pivots, gated to a 5-to-60-bar window between successive pivots.
[*] Right-edge labels in the pane (composite, signal, volume Z) and on the price chart (cross-pane regime status).
[/list]

[b]Reading the chart[/b]
[list]
[*] [b]In-pane[/b]: seven-layer iridescent ribbon, breath-opacity histogram, volume-modulated zero line, overbought / oversold guide lines with gradient fills when the composite breaches them, composite-to-signal ribbon fill.
[*] [b]Cross-pane[/b]: iridescent candle recolor on price, divergence connector lines between price pivots, subtle reversal dots at extreme reversal closes, soft regime tint background when the composite is clearly above or below zero.
[*] [b]Right-edge label cluster[/b]: the pane shows current composite (with percentile rank), signal line, and volume Z. The price chart shows a single IRH summary label with composite value, percentile, and regime tag.
[*] A right-edge state block lists current regime, zone (overbought, oversold, neutral), and bars since the last zero cross.
[/list]

[b]Signals[/b]
[list]
[*] Bull / bear zero cross (composite re-crosses zero)
[*] Overbought / oversold reversal (composite crosses back from an extreme)
[*] Volume surge (volume Z above two)
[*] Momentum acceleration / deceleration above a user-tunable threshold
[*] Regular and hidden divergence detection (bull / bear pairs)
[/list]
All gated on barstate.isconfirmed or barstate.ishistory. No future references. No lookahead_on.

[b]Inputs[/b]
[list]
[*] [b]Composite[/b]: VW median length, volume Z length, overbought / oversold levels, divergence lookback, percentile envelope length.
[*] [b]Visual[/b]: bullish / bearish / accent / magenta colors, toggles for ribbon, histogram, iridescent candles, cross-pane reversal dots, divergence dots, percentile envelope, cross-pane regime tint.
[*] [b]Labels[/b]: pane right-edge cluster, pane state block, cross-pane IRH label, divergence lines, divergence labels, OB/OS event labels, zero-cross events, acceleration events.
[*] [b]Dashboard[/b]: position, size.
[*] [b]Alerts[/b]: acceleration magnitude threshold.
[/list]

[b]How traders use this[/b]
[list]
[*] [b]Trend continuation[/b]: open positions in the direction of the composite when it crosses zero from the appropriate side and the volume Z confirms.
[*] [b]Reversion plays[/b]: take fades when the composite reaches an extreme zone and momentum begins decelerating (histogram fades), particularly when supported by a regular divergence connector on the price chart.
[*] [b]Hidden divergence[/b]: in a clear trend, a hidden divergence is a continuation signal and can be used to add to existing positions on a pullback.
[*] [b]Cross-system confirmation[/b]: feed the composite into other JOAT scripts (for example Position Architect) as a signal source by connecting plots in the chart UI.
[/list]

[b]Limitations[/b]
[list]
[*] The composite is a normalized smoothed reading, not a leading indicator. It quantifies present momentum strength and direction rather than predicting future direction.
[*] Connors RSI and volume Z need warm-up bars before they stabilize.
[*] Pivot divergence detection inherits the right-bar delay of pivot identification (the pivot is only confirmed several bars after the actual extreme).
[*] HMA smoothing introduces a few bars of warm-up where the composite is unavailable.
[/list]

[b]Compatibility[/b]
Pine Script v6 open-source indicator (pane). Any symbol, any timeframe. Cross-pane elements use force_overlay=true. No request.security calls. Non-repainting (divergence pivots are confirmed-bar gated).

[b]Defaults[/b]
Mint and red defaults, plus cyan (bull accent) and magenta (bear accent) hue-rotation targets. Top-right medium dashboard. All visualizations on. For fast intraday work, shorten the VW median length and the divergence lookback.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Iridescent Helix [JOAT]", "IRH [JOAT]", overlay=false, explicit_plot_zorder=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ════════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════════
g_comp   = "Composite"
g_visual = "Visual"
g_labels = "Labels"
g_dash   = "Dashboard"
g_alerts = "Alerts"

vwLen        = input.int(21,    "Volume-Weighted Median Length", minval=2,                group=g_comp,   tooltip="Lookback for the rolling volume-weighted median.")
volZLen      = input.int(50,    "Volume Z Length",               minval=2,                group=g_comp,   tooltip="Lookback for the volume Z-score and the zero-line brightness.")
obLevel      = input.float(70.0,"Overbought Level",              minval=10, maxval=100,  step=5, group=g_comp, tooltip="Composite threshold for the overbought zone.")
osLevel      = input.float(-70.0,"Oversold Level",               maxval=-10, minval=-100, step=5, group=g_comp, tooltip="Composite threshold for the oversold zone.")
divLookback  = input.int(34,    "Divergence Lookback",           minval=5,  maxval=200,   group=g_comp, tooltip="Pivot window for composite/price divergence detection.")
pctLen       = input.int(100,   "Percentile Envelope Length",    minval=20, maxval=500,   group=g_comp, tooltip="Lookback for the 5th–95th percentile envelope behind the composite.")

bullColor    = input.color(#00ffbb, "Bullish",                         inline="cBull",   group=g_visual, tooltip="Primary bullish color — JOAT brand mint.")
bearColor    = input.color(#ff1100, "Bearish",                         inline="cBull",   group=g_visual, tooltip="Primary bearish color — JOAT brand red.")
accentColor  = input.color(#00bbff, "Iridescent Accent (bull side)",   inline="cAccent", group=g_visual, tooltip="Hue-rotation target for the bull ribbon layers.")
magentaColor = input.color(#ff00bb, "Iridescent Accent (bear side)",   inline="cAccent", group=g_visual, tooltip="Hue-rotation target for the bear ribbon layers.")
showRibbon   = input.bool(true, "Show Iridescent Ribbon",                            group=g_visual, tooltip="Toggle the 7-layer iridescent ribbon stack.")
showHist     = input.bool(true, "Show Breath Histogram",                             group=g_visual, tooltip="Toggle the breath-opacity histogram columns.")
showCandles  = input.bool(true, "Iridescent Candles on Price",                       group=g_visual, tooltip="Recolor price candles by composite value via cross-pane plotcandle.")
showCross    = input.bool(true, "Cross-pane Reversal Dots",                          group=g_visual, tooltip="Subtle dot markers on the price chart at extreme reversals.")
showDiv      = input.bool(true, "Show Divergence Dots",                              group=g_visual, tooltip="Dots in the oscillator pane at composite/price pivot divergences.")
showPctBand  = input.bool(true, "Show Percentile Envelope",                          group=g_visual, tooltip="Faint 5th–95th percentile band behind the composite plot.")
showRegTint  = input.bool(true, "Cross-pane Regime Tint",                            group=g_visual, tooltip="Atmospheric soft tint on the price chart for bull/bear regimes.")

// Label clusters (cross-pane + pane)
showRightEdge   = input.bool(true, "Right-edge Label Cluster (pane)",                group=g_labels, tooltip="Three persistent labels at the pane right edge — composite, signal, volume-Z.")
showStateBlock  = input.bool(true, "Right-edge State Block (pane)",                  group=g_labels, tooltip="Regime / zone / bars-since-cross block at the pane right edge.")
showCrossIRH    = input.bool(true, "Cross-pane IRH Label (price)",                   group=g_labels, tooltip="Persistent IRH composite label on the price chart at the right edge.")
showDivLines    = input.bool(true, "Cross-pane Divergence Lines",                    group=g_labels, tooltip="Draw price-to-price divergence lines on the price chart between pivots.")
showDivLabels   = input.bool(true, "Cross-pane Divergence Labels",                   group=g_labels, tooltip="Drop REG/HID BULL/BEAR DIV labels at the current pivot end.")
showOBOSLabels  = input.bool(true, "OB/OS Event Labels",                             group=g_labels, tooltip="Pane + cross-pane labels when overbought/oversold reversals fire.")
showCrossEvents = input.bool(true, "Zero-cross Event Labels (pane)",                 group=g_labels, tooltip="Drop a label at every bull / bear zero cross.")
showAccelEvents = input.bool(true, "Acceleration Event Labels (pane)",               group=g_labels, tooltip="Drop a label when |Δcomposite| exceeds the acceleration threshold.")

showDash     = input.bool(true, "Show Dashboard",                                    group=g_dash,   tooltip="Toggle the institutional dashboard panel.")
dashPos      = input.string("top_right", "Dashboard Position",
     options=["top_right","top_center","top_left","middle_right","middle_center","middle_left","bottom_right","bottom_center","bottom_left"],
     group=g_dash, tooltip="Anchor the dashboard to any of the 9 chart positions.")
dashSize     = input.string("Medium", "Dashboard Size",
     options=["Tiny","Small","Medium","Large"],
     group=g_dash, tooltip="Cell text size for the dashboard.")

accelThresh  = input.float(15.0, "Accel/Decel Magnitude (per bar)", minval=1.0, step=0.5, group=g_alerts, tooltip="Per-bar |Δcomposite| threshold for momentum-acceleration alerts.")

// ════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════
posFromString(string s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"   ? position.top_center    :
     s == "top_right"    ? position.top_right     :
     s == "middle_left"  ? position.middle_left   :
     s == "middle_center"? position.middle_center :
     s == "middle_right" ? position.middle_right  :
     s == "bottom_left"  ? position.bottom_left   :
     s == "bottom_center"? position.bottom_center :
     position.bottom_right

sizeFromString(string s) =>
    s == "Tiny"   ? size.tiny    :
     s == "Small" ? size.small   :
     s == "Large" ? size.large   :
     size.normal

// Iridescent layer color — interpolates baseCol to accentCol with stepped transparency.
f_layerColor(color baseCol, color accentCol, int i) =>
    layerHue   = color.from_gradient(i / 6.0, 0.0, 1.0, baseCol, accentCol)
    color.new(layerHue, 20 + i * 10)

f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

// FIFO trim a label array to a cap, deleting overflow from the front.
f_trimLabels(array<label> arr, int cap) =>
    while arr.size() > cap
        old = arr.shift()
        if not na(old)
            label.delete(old)

// FIFO trim a line array to a cap.
f_trimLines(array<line> arr, int cap) =>
    while arr.size() > cap
        old = arr.shift()
        if not na(old)
            line.delete(old)

// Signed-tinted color helper (semi-transparent).
f_signColor(float v, int alpha) =>
    v > 0.0 ? color.new(bullColor, alpha) : v < 0.0 ? color.new(bearColor, alpha) : color.new(chart.fg_color, alpha)

// ════════════════════════════════════════════════════════════════════
// CORE CALCULATIONS
// ════════════════════════════════════════════════════════════════════

// 1) Volume-weighted median over vwLen via sort_indices + cum-volume walk.
var float[] vwPrices  = array.new_float()
var float[] vwVolumes = array.new_float()

vwPrices.unshift(close)
vwVolumes.unshift(volume)

while vwPrices.size() > vwLen
    vwPrices.pop()
while vwVolumes.size() > vwLen
    vwVolumes.pop()

totalVol  = vwVolumes.sum()
wMid      = totalVol / 2.0
sortedIdx = vwPrices.sort_indices(order.ascending)
float wMedian = na

if totalVol > 0
    cnt = 0.0
    for i = 0 to vwPrices.size() - 1
        idx = sortedIdx.get(i)
        cnt += vwVolumes.get(idx)
        if cnt >= wMid
            wMedian := vwPrices.get(idx)
            break

rangeBase = math.max(ta.ema(high - low, 14), syminfo.mintick)
cmom      = na(wMedian) ? 0.0 : (close - wMedian) / rangeBase

// 2) Connors-style triple RSI = avg of price RSI, streak RSI, ROC percent-rank.
r1 = ta.rsi(close, 3)

// Connors streak — resets to +1/-1 on direction flip, otherwise accumulates.
var float streak = 0.0
prevStreak = nz(streak[1])
streak := close > close[1] ? (prevStreak >= 0 ? prevStreak + 1 : 1.0) : close < close[1] ? (prevStreak <= 0 ? prevStreak - 1 : -1.0) : 0.0
r2 = ta.rsi(streak, 2)

roc1   = ta.roc(close, 1)
rocPct = ta.percentrank(roc1, 100)

cRSI = (nz(r1, 50.0) + nz(r2, 50.0) + nz(rocPct, 50.0)) / 3.0

// 3) Volume Z-score, soft-clamped downstream.
volMean = ta.sma(volume, volZLen)
volStd  = ta.stdev(volume, volZLen)
volZ    = (volume - volMean) / math.max(volStd, 1e-8)

// Composite blend — weights 0.50 / 0.35 / 0.15, HMA-7 smoothed, clamped.
composite_raw = 0.5 * cmom + 0.35 * (cRSI - 50.0) / 50.0 + 0.15 * f_clamp(volZ / 3.0, -1.0, 1.0)
composite     = ta.hma(composite_raw, 7) * 100.0
composite     := na(composite) ? na : f_clamp(composite, -100.0, 100.0)
signal_line   = ta.ema(composite, 21)

// Percentile rank of composite vs last 100 bars (for dashboard intelligence).
compPctRank = ta.percentrank(composite, 100)

// Composite percentile envelope — 5th / 95th over pctLen bars (rolling).
compPct05 = ta.percentile_linear_interpolation(composite, pctLen, 5)
compPct95 = ta.percentile_linear_interpolation(composite, pctLen, 95)

// ATR for cross-pane vertical offsets on the price chart.
atr14 = ta.atr(14)

// ════════════════════════════════════════════════════════════════════
// SIGNAL ENGINE
// ════════════════════════════════════════════════════════════════════
confirmedBar = barstate.isconfirmed or barstate.ishistory

bullCross  = ta.crossover(composite, 0)        and confirmedBar
bearCross  = ta.crossunder(composite, 0)       and confirmedBar
obReversal = ta.crossunder(composite, obLevel) and composite[1] >= obLevel and confirmedBar
osReversal = ta.crossover(composite, osLevel)  and composite[1] <= osLevel and confirmedBar
volSurge   = volZ > 2.0                        and confirmedBar

// Per-bar momentum acceleration (composite Δ exceeds threshold).
compDelta  = nz(composite - composite[1])
accelUp    = compDelta >  accelThresh and confirmedBar
accelDown  = compDelta < -accelThresh and confirmedBar

// Composite/Price divergence — pivot-confirmed, distance-gated.
// Regular + Hidden, with prior-pivot bar/price stored for cross-pane line drawing.
pvHi = ta.pivothigh(composite, 5, 5)
pvLo = ta.pivotlow(composite, 5, 5)
var float lastPvHi      = na
var float lastPvHiPrice = na
var int   lastPvHiBar   = na
var float lastPvLo      = na
var float lastPvLoPrice = na
var int   lastPvLoBar   = na

// Divergence outputs — regular and hidden.
bool bearDivReg = false
bool bullDivReg = false
bool bearDivHid = false
bool bullDivHid = false

// Pivot-anchor snapshots for the divergence line that will be drawn on
// confirmation. We capture them inside the pivot branch and consume them in
// the visuals block below.
float divFromPrice = na
float divToPrice   = na
int   divFromBar   = na
int   divToBar     = na

if not na(pvHi)
    pvHiBar  = bar_index - 5
    refPrice = high[5]
    if not na(lastPvHi) and (pvHiBar - nz(lastPvHiBar, 0)) <= divLookback
        if pvHi < lastPvHi and refPrice > lastPvHiPrice
            bearDivReg   := true
            divFromBar   := lastPvHiBar
            divToBar     := pvHiBar
            divFromPrice := lastPvHiPrice
            divToPrice   := refPrice
        if pvHi > lastPvHi and refPrice < lastPvHiPrice
            bearDivHid   := true
            divFromBar   := lastPvHiBar
            divToBar     := pvHiBar
            divFromPrice := lastPvHiPrice
            divToPrice   := refPrice
    lastPvHi      := pvHi
    lastPvHiPrice := refPrice
    lastPvHiBar   := pvHiBar

if not na(pvLo)
    pvLoBar  = bar_index - 5
    refPrice = low[5]
    if not na(lastPvLo) and (pvLoBar - nz(lastPvLoBar, 0)) <= divLookback
        if pvLo > lastPvLo and refPrice < lastPvLoPrice
            bullDivReg   := true
            divFromBar   := lastPvLoBar
            divToBar     := pvLoBar
            divFromPrice := lastPvLoPrice
            divToPrice   := refPrice
        if pvLo < lastPvLo and refPrice > lastPvLoPrice
            bullDivHid   := true
            divFromBar   := lastPvLoBar
            divToBar     := pvLoBar
            divFromPrice := lastPvLoPrice
            divToPrice   := refPrice
    lastPvLo      := pvLo
    lastPvLoPrice := refPrice
    lastPvLoBar   := pvLoBar

bearDivSig = (bearDivReg or bearDivHid) and confirmedBar
bullDivSig = (bullDivReg or bullDivHid) and confirmedBar

// Bars since the last zero cross (either direction).
var int barsSinceCross = 0
barsSinceCross := (bullCross or bearCross) ? 0 : barsSinceCross + 1

// Regime classification for tint + state block.
regimeBull = composite >  30.0
regimeBear = composite < -30.0
regimeStr  = regimeBull ? "BULL" : regimeBear ? "BEAR" : "NEUTRAL"
zoneStr    = composite >= obLevel ? "OB" : composite <= osLevel ? "OS" : "Neutral"

// ════════════════════════════════════════════════════════════════════
// VISUALS — drawn back-to-front:
//   percentile envelope, zero line, OB/OS hlines, gradient zone fills,
//   histogram, 7-layer ribbon, composite/signal ribbon, cross-pane
//   candles, cross-pane reversal dots, in-pane divergence dots, regime
//   tint, persistent label clusters, divergence connector lines.
// ════════════════════════════════════════════════════════════════════

// F. Composite percentile envelope (pane background).
pPct05 = plot(showPctBand ? compPct05 : na, "Pct 05", color=color.new(chart.fg_color, 92), display=display.none)
pPct95 = plot(showPctBand ? compPct95 : na, "Pct 95", color=color.new(chart.fg_color, 92), display=display.none)
fill(pPct05, pPct95, color=showPctBand ? color.new(chart.fg_color, 92) : na, title="Percentile Envelope")

// Volume-modulated zero line.
normVol   = volume / math.max(ta.sma(volume, volZLen), 1.0)
zeroColor = color.from_gradient(normVol, 1.0, 2.0, color.new(chart.fg_color, 90), color.new(chart.fg_color, 0))
plot(0, "Zero", color=zeroColor, linewidth=3)

// Overbought / Oversold horizontal lines.
hline(obLevel, "OB", color=color.new(bearColor, 70), linestyle=hline.style_dashed)
hline(osLevel, "OS", color=color.new(bullColor, 70), linestyle=hline.style_dashed)

// Gradient zone fills.
obFillTop  = composite > obLevel ? composite : obLevel
osFillBot  = composite < osLevel ? composite : osLevel

obBasePlot = plot(obLevel,   "OB Base",   display=display.none)
obTopPlot  = plot(obFillTop, "OB Top",    display=display.none)
osBasePlot = plot(osLevel,   "OS Base",   display=display.none)
osBotPlot  = plot(osFillBot, "OS Bottom", display=display.none)

obTopColor = obFillTop > obLevel
     ? color.from_gradient(obFillTop, obLevel, math.max(obLevel * 1.5, obLevel + 1.0), color.new(bearColor, 100), color.new(bearColor, 0))
     : color.new(bearColor, 100)
osBotColor = osFillBot < osLevel
     ? color.from_gradient(osFillBot, math.min(osLevel * 1.5, osLevel - 1.0), osLevel, color.new(bullColor, 0), color.new(bullColor, 100))
     : color.new(bullColor, 100)

fill(obBasePlot, obTopPlot, obFillTop, obLevel,  obTopColor, color.new(bearColor, 100), title="OB Fill")
fill(osBasePlot, osBotPlot, osLevel,   osFillBot, color.new(bullColor, 100), osBotColor, title="OS Fill")

// Breath-opacity histogram — fades when |composite| loses momentum.
histAbs     = math.abs(composite)
histAbsPrev = nz(math.abs(composite[1]), histAbs)
histTrans   = histAbs < histAbsPrev ? 75 : 25
histColor   = composite >= 0 ? color.new(bullColor, histTrans) : color.new(bearColor, histTrans)
plot(showHist ? composite : na, "Histogram", color=histColor, style=plot.style_columns, linewidth=4)

// 7-layer iridescent ribbon — hue-rotated stack, tapered linewidth.
bullActive = composite > 0 and showRibbon
bearActive = composite < 0 and showRibbon

color L0col = bullActive ? f_layerColor(bullColor, accentColor, 0) : bearActive ? f_layerColor(bearColor, magentaColor, 0) : na
color L1col = bullActive ? f_layerColor(bullColor, accentColor, 1) : bearActive ? f_layerColor(bearColor, magentaColor, 1) : na
color L2col = bullActive ? f_layerColor(bullColor, accentColor, 2) : bearActive ? f_layerColor(bearColor, magentaColor, 2) : na
color L3col = bullActive ? f_layerColor(bullColor, accentColor, 3) : bearActive ? f_layerColor(bearColor, magentaColor, 3) : na
color L4col = bullActive ? f_layerColor(bullColor, accentColor, 4) : bearActive ? f_layerColor(bearColor, magentaColor, 4) : na
color L5col = bullActive ? f_layerColor(bullColor, accentColor, 5) : bearActive ? f_layerColor(bearColor, magentaColor, 5) : na
color L6col = bullActive ? f_layerColor(bullColor, accentColor, 6) : bearActive ? f_layerColor(bearColor, magentaColor, 6) : na

plot(showRibbon ? composite : na, "Iris Layer 0", color=L0col, linewidth=2)
plot(showRibbon ? composite : na, "Iris Layer 1", color=L1col, linewidth=3)
plot(showRibbon ? composite : na, "Iris Layer 2", color=L2col, linewidth=4)
plot(showRibbon ? composite : na, "Iris Layer 3", color=L3col, linewidth=5)
plot(showRibbon ? composite : na, "Iris Layer 4", color=L4col, linewidth=4)
plot(showRibbon ? composite : na, "Iris Layer 5", color=L5col, linewidth=3)
plot(showRibbon ? composite : na, "Iris Layer 6", color=L6col, linewidth=2)

// Composite + signal ribbon (signal line invisible; used as fill anchor).
pComp = plot(composite,    "Composite", color=color.new(chart.fg_color, 60), linewidth=2)
pSig  = plot(signal_line,  "Signal",    color=color.new(color.white, 100))

ribbonStrength = math.min(math.abs(composite - signal_line) / math.max(obLevel, 1.0), 1.0)
ribbonState    = composite >= signal_line ? 1 : -1
ribbonColor    = ribbonState == 1
     ? color.from_gradient(ribbonStrength, 0.0, 1.0, color.new(bullColor, 80), color.new(bullColor, 0))
     : color.from_gradient(ribbonStrength, 0.0, 1.0, color.new(bearColor, 80), color.new(bearColor, 0))
fill(pComp, pSig, ribbonColor, title="Composite/Signal Ribbon")

// Cross-pane iridescent candle recolor.
candleColor = color.from_gradient(composite, -100, 100, bearColor, bullColor)
plotcandle(open, high, low, close, "Helix Candles",
     color         = showCandles ? candleColor : na,
     wickcolor     = showCandles ? candleColor : na,
     bordercolor   = showCandles ? candleColor : na,
     force_overlay = true)

// Cross-pane subtle reversal dots — no text, no arrows.
plotchar(osReversal and showCross ? close : na, "OS Reversal Marker", char=".", location=location.absolute, color=bullColor, size=size.tiny, force_overlay=true)
plotchar(obReversal and showCross ? close : na, "OB Reversal Marker", char=".", location=location.absolute, color=bearColor, size=size.tiny, force_overlay=true)

// In-pane divergence dots (oscillator pane).
plotchar(bullDivSig and showDiv ? osLevel : na, "Bull Divergence", char=".", location=location.absolute, color=bullColor, size=size.small)
plotchar(bearDivSig and showDiv ? obLevel : na, "Bear Divergence", char=".", location=location.absolute, color=bearColor, size=size.small)

// I. Cross-pane regime tint — atmospheric only, very low alpha.
regimeTint = showRegTint
     ? (regimeBull ? color.new(bullColor, 96) : regimeBear ? color.new(bearColor, 96) : na)
     : na
bgcolor(regimeTint, title="Regime Tint", force_overlay=true)

// ════════════════════════════════════════════════════════════════════
// PERSISTENT LABEL / LINE STATE
// ════════════════════════════════════════════════════════════════════

// A. Pane right-edge labels cluster (composite, signal, volZ).
var label paneCompLabel = na
var label paneSigLabel  = na
var label paneVolZLabel = na

// B. Cross-pane composite label on price chart.
var label priceIRHLabel = na

// J. Right-edge state block on pane (regime / zone / bars-since-cross).
var label paneRegimeLabel = na
var label paneZoneLabel   = na
var label paneBarsLabel   = na

// C / D. Cross-pane divergence connector lines + price labels.
var array<line>  divLines       = array.new<line>()
var array<label> divPriceLabels = array.new<label>()

// E. OB/OS event labels — pane + cross-pane.
var array<label> obosPaneLabels  = array.new<label>()
var array<label> obosPriceLabels = array.new<label>()

// G. Zero-cross event labels (pane).
var array<label> crossEventLabels = array.new<label>()

// H. Acceleration timeline labels (pane).
var array<label> accelLabels = array.new<label>()

// ════════════════════════════════════════════════════════════════════
// CROSS-PANE DIVERGENCE LINES + LABELS  (sections C / D)
// ════════════════════════════════════════════════════════════════════
divEvent = (bullDivReg or bullDivHid or bearDivReg or bearDivHid) and confirmedBar and not na(divFromBar) and not na(divToBar)

if divEvent and showDivLines
    color divCol = bullDivReg ? bullColor : bullDivHid ? bullColor : bearDivReg ? bearColor : bearColor
    string divStyle = (bullDivHid or bearDivHid) ? line.style_dashed : line.style_solid
    line ln = line.new(divFromBar, divFromPrice, divToBar, divToPrice,
         xloc          = xloc.bar_index,
         color         = color.new(divCol, 25),
         style         = divStyle,
         width         = 2,
         force_overlay = true)
    divLines.push(ln)
    f_trimLines(divLines, 10)

if divEvent and showDivLabels
    string divTag = bullDivReg ? "REG BULL DIV" : bullDivHid ? "HID BULL DIV" : bearDivReg ? "REG BEAR DIV" : "HID BEAR DIV"
    bool   divBull = bullDivReg or bullDivHid
    color  divLblBg = color.new(divBull ? bullColor : bearColor, 30)
    string divStyleLbl = divBull ? label.style_label_up : label.style_label_down
    label lb = label.new(divToBar, divToPrice,
         text          = divTag + "  " + str.tostring(divToPrice, format.mintick),
         xloc          = xloc.bar_index,
         yloc          = yloc.price,
         color         = divLblBg,
         textcolor     = color.white,
         style         = divStyleLbl,
         size          = size.small,
         force_overlay = true)
    divPriceLabels.push(lb)
    f_trimLabels(divPriceLabels, 10)

// ════════════════════════════════════════════════════════════════════
// OB/OS EVENT LABELS  (section E)
// ════════════════════════════════════════════════════════════════════
if (obReversal or osReversal) and showOBOSLabels
    bool   obEvent  = obReversal
    string paneTxt  = obEvent ? "OB reject " + str.tostring(composite, "0") : "OS reject " + str.tostring(composite, "0")
    string priceTxt = obEvent ? "OB " + str.tostring(close, format.mintick) : "OS " + str.tostring(close, format.mintick)
    color  obosCol  = obEvent ? bearColor : bullColor

    label lbPane = label.new(bar_index, obEvent ? obLevel : osLevel,
         text      = paneTxt,
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = color.new(obosCol, 30),
         textcolor = color.white,
         style     = obEvent ? label.style_label_down : label.style_label_up,
         size      = size.small)
    obosPaneLabels.push(lbPane)
    f_trimLabels(obosPaneLabels, 15)

    label lbPrice = label.new(bar_index, close,
         text          = priceTxt,
         xloc          = xloc.bar_index,
         yloc          = yloc.price,
         color         = color.new(obosCol, 30),
         textcolor     = color.white,
         style         = obEvent ? label.style_label_down : label.style_label_up,
         size          = size.small,
         force_overlay = true)
    obosPriceLabels.push(lbPrice)
    f_trimLabels(obosPriceLabels, 15)

// ════════════════════════════════════════════════════════════════════
// ZERO-CROSS EVENT LABELS  (section G)
// ════════════════════════════════════════════════════════════════════
if (bullCross or bearCross) and showCrossEvents
    bool   isBull = bullCross
    string crossTxt = (isBull ? "Bull cross  bar " : "Bear cross  bar ") + str.tostring(bar_index)
    color  crossCol = isBull ? bullColor : bearColor
    label lbX = label.new(bar_index, 0.0,
         text      = crossTxt,
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = color.new(crossCol, 35),
         textcolor = color.white,
         style     = isBull ? label.style_label_up : label.style_label_down,
         size      = size.tiny)
    crossEventLabels.push(lbX)
    f_trimLabels(crossEventLabels, 20)

// ════════════════════════════════════════════════════════════════════
// ACCELERATION TIMELINE LABELS  (section H)
// ════════════════════════════════════════════════════════════════════
if (accelUp or accelDown) and showAccelEvents
    bool   isUp = accelUp
    string accelTxt = (isUp ? "Accel up " : "Accel dn ") + str.tostring(compDelta, "+0;-0")
    color  accelCol = isUp ? bullColor : bearColor
    float  accelY   = isUp ? math.min(composite + 10.0, 95.0) : math.max(composite - 10.0, -95.0)
    label lbA = label.new(bar_index, accelY,
         text      = accelTxt,
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         color     = color.new(accelCol, 40),
         textcolor = color.white,
         style     = isUp ? label.style_label_down : label.style_label_up,
         size      = size.tiny)
    accelLabels.push(lbA)
    f_trimLabels(accelLabels, 15)

// ════════════════════════════════════════════════════════════════════
// RIGHT-EDGE PERSISTENT LABEL CLUSTERS  (sections A / B / J)
// ════════════════════════════════════════════════════════════════════
if barstate.islast
    // A. Pane right-edge cluster — composite, signal, volZ.
    if showRightEdge
        string compTxt  = "Composite " + str.tostring(composite, "+0;-0") + "  pct " + str.tostring(nz(compPctRank), "0") + "%"
        string sigTxt   = "Signal " + str.tostring(signal_line, "+0;-0")
        string volZTxt  = "VolZ " + str.tostring(volZ, "+0.0;-0.0")
        color  compBg   = f_signColor(composite, 30)
        color  sigBg    = f_signColor(signal_line, 40)
        color  volZBg   = f_signColor(volZ, 45)

        if na(paneCompLabel)
            paneCompLabel := label.new(bar_index + 5, composite, compTxt,
                 xloc=xloc.bar_index, yloc=yloc.price,
                 color=compBg, textcolor=color.white,
                 style=label.style_label_left, size=size.small)
        else
            label.set_xy(paneCompLabel, bar_index + 5, composite)
            label.set_text(paneCompLabel, compTxt)
            label.set_color(paneCompLabel, compBg)

        float sigY = math.max(math.min(signal_line, 90.0), -90.0)
        if na(paneSigLabel)
            paneSigLabel := label.new(bar_index + 5, sigY, sigTxt,
                 xloc=xloc.bar_index, yloc=yloc.price,
                 color=sigBg, textcolor=color.white,
                 style=label.style_label_left, size=size.small)
        else
            label.set_xy(paneSigLabel, bar_index + 5, sigY)
            label.set_text(paneSigLabel, sigTxt)
            label.set_color(paneSigLabel, sigBg)

        float volZY = composite + (composite >= 0 ? -22.0 : 22.0)
        volZY := math.max(math.min(volZY, 90.0), -90.0)
        if na(paneVolZLabel)
            paneVolZLabel := label.new(bar_index + 5, volZY, volZTxt,
                 xloc=xloc.bar_index, yloc=yloc.price,
                 color=volZBg, textcolor=color.white,
                 style=label.style_label_left, size=size.small)
        else
            label.set_xy(paneVolZLabel, bar_index + 5, volZY)
            label.set_text(paneVolZLabel, volZTxt)
            label.set_color(paneVolZLabel, volZBg)

    // J. Pane state block — regime, zone, bars-since-cross.
    if showStateBlock
        color regimeBg = regimeBull ? color.new(bullColor, 30) : regimeBear ? color.new(bearColor, 30) : color.new(chart.fg_color, 70)
        color zoneBg   = composite >= obLevel ? color.new(bearColor, 30) : composite <= osLevel ? color.new(bullColor, 30) : color.new(chart.fg_color, 70)
        color barsBg   = color.new(chart.fg_color, 65)

        if na(paneRegimeLabel)
            paneRegimeLabel := label.new(bar_index + 12, 70.0, "Regime  " + regimeStr,
                 xloc=xloc.bar_index, yloc=yloc.price,
                 color=regimeBg, textcolor=color.white,
                 style=label.style_label_left, size=size.small)
        else
            label.set_xy(paneRegimeLabel, bar_index + 12, 70.0)
            label.set_text(paneRegimeLabel, "Regime  " + regimeStr)
            label.set_color(paneRegimeLabel, regimeBg)

        if na(paneZoneLabel)
            paneZoneLabel := label.new(bar_index + 12, 40.0, "Zone  " + zoneStr,
                 xloc=xloc.bar_index, yloc=yloc.price,
                 color=zoneBg, textcolor=color.white,
                 style=label.style_label_left, size=size.small)
        else
            label.set_xy(paneZoneLabel, bar_index + 12, 40.0)
            label.set_text(paneZoneLabel, "Zone  " + zoneStr)
            label.set_color(paneZoneLabel, zoneBg)

        if na(paneBarsLabel)
            paneBarsLabel := label.new(bar_index + 12, 10.0, "Bars since cross  " + str.tostring(barsSinceCross),
                 xloc=xloc.bar_index, yloc=yloc.price,
                 color=barsBg, textcolor=color.white,
                 style=label.style_label_left, size=size.small)
        else
            label.set_xy(paneBarsLabel, bar_index + 12, 10.0)
            label.set_text(paneBarsLabel, "Bars since cross  " + str.tostring(barsSinceCross))
            label.set_color(paneBarsLabel, barsBg)

    // B. Cross-pane IRH composite label on price chart.
    if showCrossIRH
        string irhTxt = "IRH " + str.tostring(composite, "+0;-0") + "  pct " + str.tostring(nz(compPctRank), "0") + "%  " + regimeStr
        color  irhBg  = regimeBull ? color.new(bullColor, 25) : regimeBear ? color.new(bearColor, 25) : color.new(chart.fg_color, 60)
        float  irhY   = close + nz(atr14, 0.0) * 1.5

        if na(priceIRHLabel)
            priceIRHLabel := label.new(bar_index + 30, irhY, irhTxt,
                 xloc=xloc.bar_index, yloc=yloc.price,
                 color=irhBg, textcolor=color.white,
                 style=label.style_label_left, size=size.small,
                 force_overlay=true)
        else
            label.set_xy(priceIRHLabel, bar_index + 30, irhY)
            label.set_text(priceIRHLabel, irhTxt)
            label.set_color(priceIRHLabel, irhBg)

// ════════════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════════════
var table dash = table.new(posFromString(dashPos), 2, 10,
     bgcolor      = #111118,
     border_color = #252535,
     border_width = 1,
     frame_color  = #252535,
     frame_width  = 1)

f_regime(float c) =>
    c >  20.0 ? "BULL" : c < -20.0 ? "BEAR" : "NEUTRAL"

f_regimeBg(float c) =>
    c >  20.0 ? color.new(bullColor, 60) : c < -20.0 ? color.new(bearColor, 60) : color.new(chart.fg_color, 80)

f_zone(float c, float ob, float os) =>
    c >= ob ? "OVERBOUGHT" : c <= os ? "OVERSOLD" : "NEUTRAL"

f_zoneBg(float c, float ob, float os) =>
    c >= ob ? color.new(bearColor, 60) : c <= os ? color.new(bullColor, 60) : color.new(chart.fg_color, 80)

f_compBg(float c) =>
    c >  0.0 ? color.new(bullColor, 70) : c < 0.0 ? color.new(bearColor, 70) : color.new(chart.fg_color, 80)

if barstate.islast and showDash
    dash := table.new(posFromString(dashPos), 2, 10,
         bgcolor      = #111118,
         border_color = #252535,
         border_width = 1,
         frame_color  = #252535,
         frame_width  = 1)
    txtSize = sizeFromString(dashSize)

    table.cell(dash, 0, 0, "Iridescent Helix [JOAT]", text_color=color.white, bgcolor=color.new(bullColor, 30), text_size=txtSize, text_halign=text.align_center)
    table.cell(dash, 1, 0, "",                         text_color=color.white, bgcolor=color.new(bullColor, 30), text_size=txtSize, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "Composite",                                       text_color=chart.fg_color, bgcolor=#1a1a26,         text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(nz(composite), "0.0") + " / 100",     text_color=color.white,    bgcolor=f_compBg(nz(composite)), text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 2, "VW Median d",                                     text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(close - nz(wMedian, close), format.mintick), text_color=color.white, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 3, "Connors RSI",                                     text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(cRSI, "0.0"),                          text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 4, "Volume Z",                                        text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(volZ, "0.00"),                         text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 5, "Regime",                                          text_color=chart.fg_color, bgcolor=#1a1a26,                       text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 5, f_regime(nz(composite)),                            text_color=color.white,    bgcolor=f_regimeBg(nz(composite)),     text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 6, "Zone",                                            text_color=chart.fg_color, bgcolor=#1a1a26,                                  text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 6, f_zone(nz(composite), obLevel, osLevel),            text_color=color.white,    bgcolor=f_zoneBg(nz(composite), obLevel, osLevel), text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 7, "Percentile (100)",                                text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(nz(compPctRank), "0") + "%",          text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 8, "Bars Since Cross",                                text_color=chart.fg_color, bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(barsSinceCross),                       text_color=color.white,    bgcolor=#1a1a26, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 9, "@JackOfAllTrades", text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize, text_halign=text.align_center)
    table.cell(dash, 1, 9, "",                 text_color=color.new(#9090b0, 60), bgcolor=#111118, text_size=txtSize, text_halign=text.align_center)
    table.merge_cells(dash, 0, 9, 1, 9)

// ════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════
alertcondition(bullCross,   title="IRH Bull Cross",        message="IRH [JOAT] — Bull zero cross")
alertcondition(bearCross,   title="IRH Bear Cross",        message="IRH [JOAT] — Bear zero cross")
alertcondition(obReversal,  title="IRH OB Reversal",       message="IRH [JOAT] — Overbought reversal")
alertcondition(osReversal,  title="IRH OS Reversal",       message="IRH [JOAT] — Oversold reversal")
alertcondition(volSurge,    title="IRH Volume Surge",      message="IRH [JOAT] — Volume Z surge")
alertcondition(accelUp,     title="IRH Accel Up",          message="IRH [JOAT] — Momentum acceleration up")
alertcondition(accelDown,   title="IRH Accel Down",        message="IRH [JOAT] — Momentum acceleration down")
alertcondition(bullDivSig,  title="IRH Bull Divergence",   message="IRH [JOAT] — Bullish divergence")
alertcondition(bearDivSig,  title="IRH Bear Divergence",   message="IRH [JOAT] — Bearish divergence")
````
