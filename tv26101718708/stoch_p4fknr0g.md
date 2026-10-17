# Stoch

- url: https://www.tradingview.com/script/P4FKNr0G-Stoch/
- type: indicator
- pine_id: PUB;4e9ebda776214700ac09833052852e76
- version: 2.0

## Description

Stoch — A Refined Stochastic Oscillator with Structural Divergence Detection

This is a ground-up rebuild of the classic Stochastic oscillator, designed around one core idea: divergence lines should only ever connect real structural turning points — never cut through a pivot that should have invalidated them.

Two Divergence Detection Modes

Live — flags divergences almost immediately as price and the oscillator turn, ideal for fast-moving markets.
Confirmed — waits for a fully validated pivot before drawing anything, trading speed for certainty.

Switch between them any time; every other setting works identically in both modes.

Structurally Validated Lines
Rather than connecting to the nearest matching pivot (a common source of messy, overlapping divergence lines), this script searches back through multiple prior pivots and only accepts a connection where every pivot in between is properly ordered — guaranteeing the line always sits on the true outer envelope of the pattern. On top of that, every candidate line is checked against actual price action: a candle wick is allowed to poke through, but a candle close breaching the line invalidates it, so oscillator divergences are always backed by a coherent price story, not an artifact of the math.

Smart Cleanup
As new, farther-reaching divergences form, older redundant lines are automatically deleted rather than left cluttering the chart — so you're always looking at the most current, most meaningful connection.

Regular + Hidden Divergence, Fully Customizable
Both divergence types get independent color, line style, line width, and an option to project the divergence line directly onto the price chart — useful for visually confirming what the oscillator is picking up on.

Two Layers of Crossing Signals

Standard Crossing Signals fire only when K and D cross deep in oversold/overbought territory — an adjustable threshold keeps these meaningful instead of firing on every minor wiggle.
Divergence Follow-Through Signals are a second, independent signal type that only fires when a K/D cross happens within a few bars after a divergence — a way to catch the moment a spotted divergence actually starts playing out, with its own threshold, its own bar-window, and its own colors.

Money Flow, Redesigned
A gradient-shaded Money Flow ribbon fades smoothly to the zero line instead of using a flat fill, giving a cleaner read on bullish/bearish pressure at a glance.

Fully Open Customization
Overbought/Oversold lines, two fully custom adjustable reference lines, K/D colors, the fill between them, and every signal color are exposed as inputs — build the exact visual language that works for you.

Alerts for Everything That Matters
Regular and Hidden Divergence (bullish and bearish), a combined "Any Divergence" alert, both signal layers individually and combined, plus a Money Flow zero-cross alert — all wired up and ready to go straight from TradingView's alert dialog.

## Source Code

````pine
//@version=6
indicator(title = 'Stoch', max_lines_count = 500, max_labels_count = 500)

//===================================================================
//=== Divergence - Pivot Settings (Mode + Lookbacks, shared by K/D and PPO) ===
//===================================================================
detectionMode = input.string('Live', title = 'Divergence Detection Mode', options = ['Live', 'Confirmed'], group = 'Divergence - Pivots', tooltip = 'Live: detects divergence as price moves (fast but less stable)\nConfirmed: waits for pivot validation (slower but more reliable)')
lbL = input.int(5, title = 'Pivot Left Lookback', group = 'Divergence - Pivots')
lbR = input.int(5, title = 'Pivot Right Lookback (Confirmed mode only)', group = 'Divergence - Pivots')
liveLbR = input.int(1, title = 'Live Right Lookback', minval = 1, maxval = 10, group = 'Divergence - Pivots', tooltip = 'How many bars must confirm a turn before Live mode marks it as a pivot. Higher = cleaner lines but slower; Lower = faster but noisier.')
pivotDepth = input.int(6, title = 'Pivots to Look Back', minval = 1, maxval = 8, group = 'Divergence - Pivots', tooltip = 'How many prior pivots a new pivot can connect back to. Only the farthest structurally and price-valid pivot is used, which keeps lines on the outside of the pattern instead of cutting through intermediate pivots. Live mode forms pivots more often than Confirmed mode, so it may need a higher value here to reach the same meaningful swing points.')
rangeUpper = input.int(60, title = 'Max of Lookback Range', group = 'Divergence - Pivots')
rangeLower = input.int(5, title = 'Min of Lookback Range', group = 'Divergence - Pivots')
delOldDiv = input.bool(true, title = 'Delete Superseded Divergence Lines', group = 'Divergence - Pivots', tooltip = 'When a new divergence line reaches back to the same or an earlier pivot than an existing one, the older, now-redundant line is removed. Any follow-up crossing signal marker attached to that line is removed too.')
onlyTrending = input.bool(false, title = 'Only Trending Divergences', group = 'Divergence - Pivots', tooltip = 'Only draws bullish divergences while price is above its 200 EMA, and bearish divergences while price is below it.')
priceTolerancePct = input.float(0.05, title = 'Price Wick Tolerance (%)', minval = 0, maxval = 5, step = 0.05, group = 'Divergence - Pivots', tooltip = 'Every divergence line, whether or not Show on Chart is enabled, must also form a valid line on price. A candle wick crossing that line is always ignored. A candle close crossing it invalidates the pivot unless the close is within this percentage of the line, which allows a small buffer for near-misses. A pivot that fails this check is skipped in favor of a nearer one that passes.')

//===================================================================
//=== Divergence - Regular (Bullish/Bearish colors split, style+width shared) ===
//===================================================================
showReg = input.bool(true, title = 'Show', group = 'Divergence - Regular')
showRegChart = input.bool(true, title = 'Show on Chart', group = 'Divergence - Regular')
regBullColor = input.color(color.new(#00ffdd, 0), title = 'Bullish Color', group = 'Divergence - Regular', inline = 'regcolor')
regBearColor = input.color(color.new(#00ffdd, 0), title = 'Bearish Color', group = 'Divergence - Regular', inline = 'regcolor')
regStyleStr = input.string('Solid', title = 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Divergence - Regular')
regWidth = input.int(1, title = 'Line Width', minval = 1, maxval = 5, group = 'Divergence - Regular')

//===================================================================
//=== Divergence - Hidden (Bullish/Bearish colors split, style+width shared) ===
//===================================================================
showHid = input.bool(true, title = 'Show', group = 'Divergence - Hidden')
showHidChart = input.bool(false, title = 'Show on Chart', group = 'Divergence - Hidden')
hidBullColor = input.color(color.new(#00ffdd, 0), title = 'Bullish Color', group = 'Divergence - Hidden', inline = 'hidcolor')
hidBearColor = input.color(color.new(#00ffdd, 0), title = 'Bearish Color', group = 'Divergence - Hidden', inline = 'hidcolor')
hidStyleStr = input.string('Dotted', title = 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Divergence - Hidden')
hidWidth = input.int(1, title = 'Line Width', minval = 1, maxval = 5, group = 'Divergence - Hidden')

//===================================================================
//=== Percentile Rank Divergence (colors always match the line itself) ===
//===================================================================
showPPOReg = input.bool(true, title = 'Show Regular', group = 'Percentile Rank Divergence')
showPPORegChart = input.bool(true, title = 'Show on Chart (Regular)', group = 'Percentile Rank Divergence')
showPPOHid = input.bool(false, title = 'Show Hidden', group = 'Percentile Rank Divergence')
showPPOHidChart = input.bool(false, title = 'Show on Chart (Hidden)', group = 'Percentile Rank Divergence')

//===================================================================
//=== Overbought/Oversold ===
//===================================================================
showOB = input.bool(true, title = 'Show', group = 'Overbought')
valOB = input.float(60, title = 'Value', group = 'Overbought')
colorOB = input.color(color.new(#2e2e2e, 0), title = 'Color', group = 'Overbought')

showOS = input.bool(true, title = 'Show', group = 'Oversold')
valOS = input.float(-60, title = 'Value', group = 'Oversold')
colorOS = input.color(color.new(#2e2e2e, 0), title = 'Color', group = 'Oversold')

//===================================================================
//=== Custom Lines ===
//===================================================================
lineStyle(str) =>
    str == 'Dashed' ? line.style_dashed : str == 'Dotted' ? line.style_dotted : line.style_solid

showCustom1 = input.bool(false, title = 'Show', group = 'Custom Line 1')
valCustom1 = input.float(40, title = 'Value', group = 'Custom Line 1')
colorCustom1 = input.color(color.new(#ffffff, 75), title = 'Color', group = 'Custom Line 1')
styleCustom1Str = input.string('Dotted', title = 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Custom Line 1')
widthCustom1 = input.int(1, title = 'Width', minval = 1, maxval = 5, group = 'Custom Line 1')

showCustom2 = input.bool(false, title = 'Show', group = 'Custom Line 2')
valCustom2 = input.float(-40, title = 'Value', group = 'Custom Line 2')
colorCustom2 = input.color(color.new(#ffffff, 75), title = 'Color', group = 'Custom Line 2')
styleCustom2Str = input.string('Dotted', title = 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Custom Line 2')
widthCustom2 = input.int(1, title = 'Width', minval = 1, maxval = 5, group = 'Custom Line 2')

//===================================================================
//=== Display ===
//===================================================================
showLevelLabels = input.bool(false, title = 'Show Level Line Price Labels', group = 'Display', tooltip = 'Shows/hides the price-scale labels for Overbought, Oversold, Custom Line 1, Custom Line 2, and the Zero line. Oscillator and signal labels always stay visible.')
labelDisp = showLevelLabels ? display.all : display.pane

//===================================================================
//=== Fill (the shaded area between K and D, drawn behind both lines) ===
//===================================================================
showFill = input.bool(true, title = 'Show', group = 'Fill')
fillColor1 = input.color(color.new(#00ffdd, 81), title = 'Color 1', group = 'Fill')
fillColor2 = input.color(color.new(#9c9c9c, 84), title = 'Color 2', group = 'Fill')

//===================================================================
//=== Stochastic ===
//===================================================================
periodK = input.int(14, title = '%K Length', minval = 1, group = 'Stochastic')
smoothK = input.int(4, title = '%K Smoothing', minval = 1, group = 'Stochastic')
periodD = input.int(3, title = '%D Smoothing', minval = 1, group = 'Stochastic')
kColor = input.color(color.new(#00ffdd, 0), title = 'K Color (Solid Mode)', group = 'Stochastic')
dColor = input.color(color.new(#b8b8b8, 0), title = 'D Color', group = 'Stochastic')

//===================================================================
//=== Stochastic Spectrum ===
//===================================================================
kColorTypeStr = input.string('Spectrum', title = 'K Line Color Mode', options = ['Solid', 'Spectrum'], group = 'Stochastic Spectrum')
kSpLo = input.color(color.new(#00ffdd, 0), title = 'Spectrum 0', group = 'Stochastic Spectrum')
kSp25 = input.color(color.new(#80deea, 0), title = 'Spectrum 25', group = 'Stochastic Spectrum')
kSpMid = input.color(color.new(#5b9cf6, 0), title = 'Spectrum 50', group = 'Stochastic Spectrum')
kSp75 = input.color(color.new(#80deea, 0), title = 'Spectrum 75', group = 'Stochastic Spectrum')
kSpHi = input.color(color.new(#00ffdd, 0), title = 'Spectrum 100', group = 'Stochastic Spectrum')
kLineWidth = input.int(2, title = 'K Line Width', minval = 1, maxval = 5, group = 'Stochastic Spectrum')

//===================================================================
//=== Money Flow ===
//===================================================================
showMoneyFlow = input.bool(true, title = 'Show', group = 'Money Flow')
mfBullColor = input.color(color.new(#4a4a4a, 31), title = 'Bullish Color', group = 'Money Flow')
mfBearColor = input.color(color.new(#4a4a4a, 31), title = 'Bearish Color', group = 'Money Flow')
zeroLineColor = input.color(color.new(#4a4a4a, 31), title = 'Zero Line Color', group = 'Money Flow')

//===================================================================
//=== Percentile Rank Line (PPO-based) ===
//===================================================================
showPctRank = input.bool(true, title = 'Show', group = 'Percentile Rank Line')
pctRankShort = input.float(0.3, title = 'Short Gamma', minval = 0.01, maxval = 0.99, step = 0.01, group = 'Percentile Rank Line')
pctRankLong = input.float(0.5, title = 'Long Gamma', minval = 0.01, maxval = 0.99, step = 0.01, group = 'Percentile Rank Line')
pctRankLookback = input.int(144, title = 'Percentile Lookback', minval = 1, group = 'Percentile Rank Line')
pctRankColor = input.color(color.new(#90bff9, 50), title = 'Color', group = 'Percentile Rank Line')
pctRankWidth = input.int(1, title = 'Width', minval = 1, maxval = 5, group = 'Percentile Rank Line')

//===================================================================
//=== Background Signal (K vs D state as a background wash) ===
//===================================================================
showBgSignal = input.bool(false, title = 'Show', group = 'Background Signal')
bgColorBull = input.color(color.new(#636363, 75), title = 'K Above/Equal D Color', group = 'Background Signal')
bgColorBear = input.color(color.new(#000000, 50), title = 'K Below D Color', group = 'Background Signal')

//===================================================================
//=== Trend Signals (%K cross of fixed levels, filtered by 200 EMA) ===
//===================================================================
showTrendSignal = input.bool(true, title = 'Show', group = 'Trend Signals', tooltip = 'Buy fires when %K crosses above the Buy Threshold while price is above its 200 EMA. Sell fires when %K crosses below the Sell Threshold while price is below its 200 EMA. Shown as a background wash and available as a TradingView alert. Note: %K here is on the standard 0-100 stochastic scale, so these thresholds behave like Oversold/Overbought at 40/60 rather than the usual 20/80.')
trendBuyThresh = input.int(20, title = 'Buy Threshold', minval = 0, maxval = 100, group = 'Trend Signals')
trendSellThresh = input.int(80, title = 'Sell Threshold', minval = 0, maxval = 100, group = 'Trend Signals')
trendBuyColor = input.color(color.new(#90bff9, 94), title = 'Buy Color', group = 'Trend Signals')
trendSellColor = input.color(color.new(#90bff9, 94), title = 'Sell Color', group = 'Trend Signals')

//===================================================================
//=== Signals ===
//===================================================================
showCrossSignal = input.bool(true, title = 'Show', group = 'Signals')
crossZone = input.float(50, title = 'Crossing Zone Threshold', minval = 10, maxval = 75, step = 5, group = 'Signals', tooltip = 'Crossing Up only fires when K and D are both below -Threshold (oversold). Crossing Down only fires when both are above +Threshold (overbought).')
crossUpColor = input.color(color.new(#00ffbb, 0), title = 'Crossing Up Color', group = 'Signals')
crossDownColor = input.color(color.new(#00ffbb, 0), title = 'Crossing Down Color', group = 'Signals')

//===================================================================
//=== Divergence Signals (crossings that follow shortly after a divergence) ===
//===================================================================
showDivSignal = input.bool(true, title = 'Show', group = 'Divergence Signals')
divSignalZone = input.float(20, title = 'Crossing Zone Threshold', minval = 10, maxval = 75, step = 5, group = 'Divergence Signals', tooltip = 'Independent of the regular Signals threshold. A cross-up must clear -Threshold (both K and D) following a bullish divergence; a cross-down must clear +Threshold following a bearish divergence.')
divSignalBars = input.int(3, title = 'Bars After Divergence', minval = 1, maxval = 20, group = 'Divergence Signals', tooltip = 'How many bars after a divergence line is drawn the follow-up crossing signal is allowed to fire.')
divSignalSizeStr = input.string('Tiny', title = 'Marker Size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = 'Divergence Signals', tooltip = 'Defaults to Tiny to visually match the size of the regular Crossing Up/Down dots.')
divSignalVertOffset = input.float(3.0, title = 'Marker Vertical Offset', minval = -20, maxval = 20, step = 0.5, group = 'Divergence Signals', tooltip = 'Text-based markers do not vertically center on their anchor point the way shape markers do, so this nudges them down to visually sit on the D line. Since this is a fixed value on the oscillator\'s -100/100 scale rather than a pixel offset, the ideal amount may shift slightly at different zoom levels.')
divUpColor = input.color(color.new(#b2ebf2, 0), title = 'Crossing Up Color', group = 'Divergence Signals')
divDownColor = input.color(color.new(#b2ebf2, 0), title = 'Crossing Down Color', group = 'Divergence Signals')

getLabelSize(str) =>
    str == 'Small' ? size.small : str == 'Normal' ? size.normal : str == 'Large' ? size.large : str == 'Huge' ? size.huge : size.tiny

divSignalSize = getLabelSize(divSignalSizeStr)

//===================================================================
//=== Color Mapping ===
//===================================================================
mapColor5Point(val, v0, v25, v50, v75, v100, c0, c25, c50, c75, c100) =>
    val <= v25 ? color.from_gradient(val, v0, v25, c0, c25) :
     val <= v50 ? color.from_gradient(val, v25, v50, c25, c50) :
     val <= v75 ? color.from_gradient(val, v50, v75, c50, c75) :
     color.from_gradient(val, v75, v100, c75, c100)

var array<color> kColorMap = array.new_color()
if barstate.isfirst and kColorTypeStr == 'Spectrum'
    for i = 0 to 100
        array.push(kColorMap, mapColor5Point(i, 0, 25, 50, 75, 100, kSpLo, kSp25, kSpMid, kSp75, kSpHi))

getKColor(kValue) =>
    kColorTypeStr == 'Spectrum' ?
     array.get(kColorMap, math.round(math.max(0, math.min(100, kValue)))) :
     kColor

//===================================================================
//=== Overbought/Oversold drawing ===
//===================================================================
plot(showOB ? valOB : na, title = 'overbought', color = colorOB, style = plot.style_line, linewidth = 2, display = labelDisp)
plot(showOS ? valOS : na, title = 'oversold', color = colorOS, style = plot.style_line, linewidth = 2, display = labelDisp)
//
//===================================================================
//=== Custom Lines drawing (dotted/dashed line + a near-invisible plot overlay to host the price-scale label) ===
//===================================================================
var line custom1Line = na
var line custom2Line = na
if not na(custom1Line)
    line.delete(custom1Line)
if not na(custom2Line)
    line.delete(custom2Line)
if showCustom1
    custom1Line := line.new(bar_index - 1, valCustom1, bar_index, valCustom1, xloc = xloc.bar_index, extend = extend.both, color = colorCustom1, style = lineStyle(styleCustom1Str), width = widthCustom1)
if showCustom2
    custom2Line := line.new(bar_index - 1, valCustom2, bar_index, valCustom2, xloc = xloc.bar_index, extend = extend.both, color = colorCustom2, style = lineStyle(styleCustom2Str), width = widthCustom2)

plot(showCustom1 ? valCustom1 : na, title = 'Custom Line 1 Label', color = color.new(colorCustom1, 90), linewidth = 1, trackprice = true, display = showLevelLabels ? display.all : display.none)
plot(showCustom2 ? valCustom2 : na, title = 'Custom Line 2 Label', color = color.new(colorCustom2, 90), linewidth = 1, trackprice = true, display = showLevelLabels ? display.all : display.none)
//
//===================================================================
//=== Money Flow ===
//===================================================================
m = ta.sma(hlc3, 5)
f = ta.sma(math.abs(hlc3 - m), 5)
i = (hlc3 - m) / (0.015 * f)
mf = ta.sma(i, 60)

mfColor = mf > 0 ? mfBullColor : mfBearColor
zeroLine = plot(showMoneyFlow ? 0 : na, title = 'zero', color = zeroLineColor, linewidth = 1, display = labelDisp, trackprice = true)
mfLine = plot(showMoneyFlow ? mf : na, title = 'mfi', color = mfColor, linewidth = 2)
fill(mfLine, zeroLine, mf, 0, mfColor, color.new(mfColor, 100), title = 'Money Flow Fade')
//
//===================================================================
//=== Percentile Rank Line ===
//===================================================================
lag(g, p) =>
    var float L0 = na
    var float L1 = na
    var float L2 = na
    var float L3 = na
    L0 := (1 - g) * p + g * nz(L0[1])
    L1 := -g * L0 + nz(L0[1]) + g * nz(L1[1])
    L2 := -g * L1 + nz(L1[1]) + g * nz(L2[1])
    L3 := -g * L2 + nz(L2[1]) + g * nz(L3[1])
    (L0 + 2 * L1 + 2 * L2 + L3) / 6

lmas = lag(pctRankShort, hl2)
lmal = lag(pctRankLong, hl2)
ppoT = (lmas - lmal) / lmal * 100
pctRankT = ta.percentrank(ppoT, pctRankLookback)
pctRankOsc = (pctRankT - 50) * 2.0

plot(showPctRank ? pctRankOsc : na, title = 'Percentile Rank Line', color = pctRankColor, linewidth = pctRankWidth)
//
//===================================================================
//=== Stochastic K/D (fill drawn first via invisible anchors so it sits behind the lines) ===
//===================================================================
kRaw = ta.sma(ta.stoch(close, high, low, periodK), smoothK)
dRaw = ta.sma(kRaw, periodD)
osc = (kRaw - 50) * 2.0
dOsc = (dRaw - 50) * 2.0

kAnchor = plot(osc, title = 'K Anchor', display = display.none)
dAnchor = plot(dOsc, title = 'D Anchor', display = display.none)
fill(kAnchor, dAnchor, color = showFill ? (kRaw > dRaw ? fillColor1 : fillColor2) : na, title = 'Fill')

kLine = plot(osc, title = 'K', color = getKColor(kRaw), linewidth = kLineWidth)
dLine = plot(dOsc, title = 'D', color = dColor, linewidth = 1)

bgcolor(showBgSignal ? (kRaw >= dRaw ? bgColorBull : bgColorBear) : na, title = 'Background Signal')
//
//===================================================================
//=== Trend Signals ===
//===================================================================
trendEMA = ta.ema(close, 200)
trendBuySignal = showTrendSignal and close > trendEMA and ta.crossover(kRaw, trendBuyThresh)
trendSellSignal = showTrendSignal and close < trendEMA and ta.crossunder(kRaw, trendSellThresh)

bgcolor(trendBuySignal ? trendBuyColor : na, title = 'Trend Buy Signal')
bgcolor(trendSellSignal ? trendSellColor : na, title = 'Trend Sell Signal')
//
//===================================================================
//=== Divergence Logic (K/D oscillator) ===
//===================================================================
divLineStyle(str) =>
    str == 'Dashed' ? line.style_dashed : str == 'Dotted' ? line.style_dotted : line.style_solid

regStyle = divLineStyle(regStyleStr)
hidStyle = divLineStyle(hidStyleStr)

type Pivot
    float price
    float ind
    int ndx

type DivRecord
    line ln
    line lnChart
    int ndx1
    label sigMarker

const int MAX_PIV = 8

var array<Pivot> lowPivots = array.new<Pivot>()
var array<Pivot> highPivots = array.new<Pivot>()

var array<DivRecord> regBullRecords = array.new<DivRecord>()
var array<DivRecord> hidBullRecords = array.new<DivRecord>()
var array<DivRecord> regBearRecords = array.new<DivRecord>()
var array<DivRecord> hidBearRecords = array.new<DivRecord>()

var int lastBullDivBar = na
var int lastBearDivBar = na
var DivRecord lastBullSigRecord = na
var DivRecord lastBearSigRecord = na

addPivot(arr, newP) =>
    array.unshift(arr, newP)
    if array.size(arr) > MAX_PIV
        array.pop(arr)

// Removes existing lines of this type whose anchor pivot is at or after the new
// line's anchor, since the new line already reaches back at least as far. Also
// removes any follow-up crossing signal marker that was attached to that line.
supersede(array<DivRecord> arr, int newNdx1) =>
    if array.size(arr) > 0
        for idx = array.size(arr) - 1 to 0
            rec = array.get(arr, idx)
            if rec.ndx1 < newNdx1
                break
            line.delete(rec.ln)
            if not na(rec.lnChart)
                line.delete(rec.lnChart)
            if not na(rec.sigMarker)
                label.delete(rec.sigMarker)
            array.remove(arr, idx)

// Always applied when selecting a pivot to connect to, whether or not Show on
// Chart is enabled. Walks the candles between the two pivots and rejects the
// pivot if a candle's close breaches the projected price line beyond the
// tolerance. Wicks are ignored entirely.
checkPriceEnvelope(startBar, startPrice, endBar, endPrice, isLow) =>
    valid = true
    len = endBar - startBar
    if len > 1
        slope = (endPrice - startPrice) / len
        for offset = 1 to len - 1
            checkBar = startBar + offset
            barsAgo = bar_index - checkBar
            projected = startPrice + slope * offset
            c = close[barsAgo]
            if isLow and c < projected * (1 - priceTolerancePct / 100)
                valid := false
                break
            if not isLow and c > projected * (1 + priceTolerancePct / 100)
                valid := false
                break
    valid

effLbR = detectionMode == 'Live' ? liveLbR : lbR
trendEMA200 = trendEMA

plFound = not na(ta.pivotlow(osc, lbL, effLbR))
phFound = not na(ta.pivothigh(osc, lbL, effLbR))

bool regBullCond = false
bool hidBullCond = false
bool bullRecordCreated = false

if plFound
    curLowOsc = osc[effLbR]
    curLowPrice = low[effLbR]
    curLowBar = bar_index[effLbR]

    int regDepth = na
    int hidDepth = na

    maxD = math.min(pivotDepth, array.size(lowPivots))
    if maxD > 0
        for d = maxD to 1
            far = array.get(lowPivots, d - 1)
            bars = curLowBar - far.ndx
            if bars >= rangeLower and bars <= rangeUpper
                structureOK = true
                belowInterm = true
                if d >= 2
                    for k = 0 to d - 2
                        interK = array.get(lowPivots, k)
                        if interK.ind <= far.ind
                            structureOK := false
                        if curLowOsc >= interK.ind
                            belowInterm := false
                if structureOK and belowInterm
                    if na(regDepth) and curLowOsc > far.ind and curLowPrice < far.price
                        if checkPriceEnvelope(far.ndx, far.price, curLowBar, curLowPrice, true)
                            regDepth := d
                    if na(hidDepth) and curLowOsc < far.ind and curLowPrice > far.price
                        if checkPriceEnvelope(far.ndx, far.price, curLowBar, curLowPrice, true)
                            hidDepth := d

    regBullCond := not na(regDepth) and (not onlyTrending or close > trendEMA200)
    hidBullCond := not na(hidDepth) and (not onlyTrending or close > trendEMA200)

    if regBullCond
        far1 = array.get(lowPivots, regDepth - 1)
        if showReg
            newLn = line.new(far1.ndx, far1.ind, curLowBar, curLowOsc, color = regBullColor, width = regWidth, style = regStyle)
            newLnChart = line(na)
            if showRegChart
                newLnChart := line.new(far1.ndx, far1.price, curLowBar, curLowPrice, color = regBullColor, width = regWidth, style = regStyle, force_overlay = true)
            newRecord = DivRecord.new(newLn, newLnChart, far1.ndx, label(na))
            if delOldDiv
                supersede(regBullRecords, far1.ndx)
            array.push(regBullRecords, newRecord)
            lastBullSigRecord := newRecord
            bullRecordCreated := true

    if hidBullCond
        far2 = array.get(lowPivots, hidDepth - 1)
        if showHid
            newLn2 = line.new(far2.ndx, far2.ind, curLowBar, curLowOsc, color = hidBullColor, width = hidWidth, style = hidStyle)
            newLnChart2 = line(na)
            if showHidChart
                newLnChart2 := line.new(far2.ndx, far2.price, curLowBar, curLowPrice, color = hidBullColor, width = hidWidth, style = hidStyle, force_overlay = true)
            newRecord2 = DivRecord.new(newLn2, newLnChart2, far2.ndx, label(na))
            if delOldDiv
                supersede(hidBullRecords, far2.ndx)
            array.push(hidBullRecords, newRecord2)
            lastBullSigRecord := newRecord2
            bullRecordCreated := true

    if regBullCond or hidBullCond
        lastBullDivBar := bar_index
        if not bullRecordCreated
            lastBullSigRecord := na

    addPivot(lowPivots, Pivot.new(curLowPrice, curLowOsc, curLowBar))

bool regBearCond = false
bool hidBearCond = false
bool bearRecordCreated = false

if phFound
    curHighOsc = osc[effLbR]
    curHighPrice = high[effLbR]
    curHighBar = bar_index[effLbR]

    int regDepthH = na
    int hidDepthH = na

    maxDH = math.min(pivotDepth, array.size(highPivots))
    if maxDH > 0
        for d = maxDH to 1
            farH = array.get(highPivots, d - 1)
            barsH = curHighBar - farH.ndx
            if barsH >= rangeLower and barsH <= rangeUpper
                structureOKH = true
                aboveInterm = true
                if d >= 2
                    for k = 0 to d - 2
                        interKH = array.get(highPivots, k)
                        if interKH.ind >= farH.ind
                            structureOKH := false
                        if curHighOsc <= interKH.ind
                            aboveInterm := false
                if structureOKH and aboveInterm
                    if na(regDepthH) and curHighOsc < farH.ind and curHighPrice > farH.price
                        if checkPriceEnvelope(farH.ndx, farH.price, curHighBar, curHighPrice, false)
                            regDepthH := d
                    if na(hidDepthH) and curHighOsc > farH.ind and curHighPrice < farH.price
                        if checkPriceEnvelope(farH.ndx, farH.price, curHighBar, curHighPrice, false)
                            hidDepthH := d

    regBearCond := not na(regDepthH) and (not onlyTrending or close < trendEMA200)
    hidBearCond := not na(hidDepthH) and (not onlyTrending or close < trendEMA200)

    if regBearCond
        far3 = array.get(highPivots, regDepthH - 1)
        if showReg
            newLn3 = line.new(far3.ndx, far3.ind, curHighBar, curHighOsc, color = regBearColor, width = regWidth, style = regStyle)
            newLnChart3 = line(na)
            if showRegChart
                newLnChart3 := line.new(far3.ndx, far3.price, curHighBar, curHighPrice, color = regBearColor, width = regWidth, style = regStyle, force_overlay = true)
            newRecord3 = DivRecord.new(newLn3, newLnChart3, far3.ndx, label(na))
            if delOldDiv
                supersede(regBearRecords, far3.ndx)
            array.push(regBearRecords, newRecord3)
            lastBearSigRecord := newRecord3
            bearRecordCreated := true

    if hidBearCond
        far4 = array.get(highPivots, hidDepthH - 1)
        if showHid
            newLn4 = line.new(far4.ndx, far4.ind, curHighBar, curHighOsc, color = hidBearColor, width = hidWidth, style = hidStyle)
            newLnChart4 = line(na)
            if showHidChart
                newLnChart4 := line.new(far4.ndx, far4.price, curHighBar, curHighPrice, color = hidBearColor, width = hidWidth, style = hidStyle, force_overlay = true)
            newRecord4 = DivRecord.new(newLn4, newLnChart4, far4.ndx, label(na))
            if delOldDiv
                supersede(hidBearRecords, far4.ndx)
            array.push(hidBearRecords, newRecord4)
            lastBearSigRecord := newRecord4
            bearRecordCreated := true

    if regBearCond or hidBearCond
        lastBearDivBar := bar_index
        if not bearRecordCreated
            lastBearSigRecord := na

    addPivot(highPivots, Pivot.new(curHighPrice, curHighOsc, curHighBar))

alertRegBull = detectionMode == 'Live' ? (regBullCond and barstate.isconfirmed) : regBullCond
alertHidBull = detectionMode == 'Live' ? (hidBullCond and barstate.isconfirmed) : hidBullCond
alertRegBear = detectionMode == 'Live' ? (regBearCond and barstate.isconfirmed) : regBearCond
alertHidBear = detectionMode == 'Live' ? (hidBearCond and barstate.isconfirmed) : hidBearCond
//
//===================================================================
//=== Divergence Logic (Percentile Rank / PPO line) ===
//===================================================================
regPpoColor = pctRankColor
hidPpoColor = pctRankColor
regPpoStyle = line.style_solid
hidPpoStyle = line.style_dotted
ppoWidth = pctRankWidth

var array<Pivot> lowPivotsPpo = array.new<Pivot>()
var array<Pivot> highPivotsPpo = array.new<Pivot>()

var array<DivRecord> regBullRecordsPpo = array.new<DivRecord>()
var array<DivRecord> hidBullRecordsPpo = array.new<DivRecord>()
var array<DivRecord> regBearRecordsPpo = array.new<DivRecord>()
var array<DivRecord> hidBearRecordsPpo = array.new<DivRecord>()

plFoundPpo = not na(ta.pivotlow(pctRankOsc, lbL, effLbR))
phFoundPpo = not na(ta.pivothigh(pctRankOsc, lbL, effLbR))

bool regBullCondPpo = false
bool hidBullCondPpo = false

if plFoundPpo
    curLowOscP = pctRankOsc[effLbR]
    curLowPriceP = low[effLbR]
    curLowBarP = bar_index[effLbR]

    int regDepthP = na
    int hidDepthP = na

    maxDP = math.min(pivotDepth, array.size(lowPivotsPpo))
    if maxDP > 0
        for d = maxDP to 1
            farP = array.get(lowPivotsPpo, d - 1)
            barsP = curLowBarP - farP.ndx
            if barsP >= rangeLower and barsP <= rangeUpper
                structureOKP = true
                belowIntermP = true
                if d >= 2
                    for k = 0 to d - 2
                        interKP = array.get(lowPivotsPpo, k)
                        if interKP.ind <= farP.ind
                            structureOKP := false
                        if curLowOscP >= interKP.ind
                            belowIntermP := false
                if structureOKP and belowIntermP
                    if na(regDepthP) and curLowOscP > farP.ind and curLowPriceP < farP.price
                        if checkPriceEnvelope(farP.ndx, farP.price, curLowBarP, curLowPriceP, true)
                            regDepthP := d
                    if na(hidDepthP) and curLowOscP < farP.ind and curLowPriceP > farP.price
                        if checkPriceEnvelope(farP.ndx, farP.price, curLowBarP, curLowPriceP, true)
                            hidDepthP := d

    regBullCondPpo := not na(regDepthP) and (not onlyTrending or close > trendEMA200)
    hidBullCondPpo := not na(hidDepthP) and (not onlyTrending or close > trendEMA200)

    if regBullCondPpo and showPPOReg
        farP1 = array.get(lowPivotsPpo, regDepthP - 1)
        newLnP = line.new(farP1.ndx, farP1.ind, curLowBarP, curLowOscP, color = regPpoColor, width = ppoWidth, style = regPpoStyle)
        newLnChartP = line(na)
        if showPPORegChart
            newLnChartP := line.new(farP1.ndx, farP1.price, curLowBarP, curLowPriceP, color = regPpoColor, width = ppoWidth, style = regPpoStyle, force_overlay = true)
        if delOldDiv
            supersede(regBullRecordsPpo, farP1.ndx)
        array.push(regBullRecordsPpo, DivRecord.new(newLnP, newLnChartP, farP1.ndx, label(na)))

    if hidBullCondPpo and showPPOHid
        farP2 = array.get(lowPivotsPpo, hidDepthP - 1)
        newLnP2 = line.new(farP2.ndx, farP2.ind, curLowBarP, curLowOscP, color = hidPpoColor, width = ppoWidth, style = hidPpoStyle)
        newLnChartP2 = line(na)
        if showPPOHidChart
            newLnChartP2 := line.new(farP2.ndx, farP2.price, curLowBarP, curLowPriceP, color = hidPpoColor, width = ppoWidth, style = hidPpoStyle, force_overlay = true)
        if delOldDiv
            supersede(hidBullRecordsPpo, farP2.ndx)
        array.push(hidBullRecordsPpo, DivRecord.new(newLnP2, newLnChartP2, farP2.ndx, label(na)))

    addPivot(lowPivotsPpo, Pivot.new(curLowPriceP, curLowOscP, curLowBarP))

bool regBearCondPpo = false
bool hidBearCondPpo = false

if phFoundPpo
    curHighOscP = pctRankOsc[effLbR]
    curHighPriceP = high[effLbR]
    curHighBarP = bar_index[effLbR]

    int regDepthPH = na
    int hidDepthPH = na

    maxDPH = math.min(pivotDepth, array.size(highPivotsPpo))
    if maxDPH > 0
        for d = maxDPH to 1
            farPH = array.get(highPivotsPpo, d - 1)
            barsPH = curHighBarP - farPH.ndx
            if barsPH >= rangeLower and barsPH <= rangeUpper
                structureOKPH = true
                aboveIntermP = true
                if d >= 2
                    for k = 0 to d - 2
                        interKPH = array.get(highPivotsPpo, k)
                        if interKPH.ind >= farPH.ind
                            structureOKPH := false
                        if curHighOscP <= interKPH.ind
                            aboveIntermP := false
                if structureOKPH and aboveIntermP
                    if na(regDepthPH) and curHighOscP < farPH.ind and curHighPriceP > farPH.price
                        if checkPriceEnvelope(farPH.ndx, farPH.price, curHighBarP, curHighPriceP, false)
                            regDepthPH := d
                    if na(hidDepthPH) and curHighOscP > farPH.ind and curHighPriceP < farPH.price
                        if checkPriceEnvelope(farPH.ndx, farPH.price, curHighBarP, curHighPriceP, false)
                            hidDepthPH := d

    regBearCondPpo := not na(regDepthPH) and (not onlyTrending or close < trendEMA200)
    hidBearCondPpo := not na(hidDepthPH) and (not onlyTrending or close < trendEMA200)

    if regBearCondPpo and showPPOReg
        farP3 = array.get(highPivotsPpo, regDepthPH - 1)
        newLnP3 = line.new(farP3.ndx, farP3.ind, curHighBarP, curHighOscP, color = regPpoColor, width = ppoWidth, style = regPpoStyle)
        newLnChartP3 = line(na)
        if showPPORegChart
            newLnChartP3 := line.new(farP3.ndx, farP3.price, curHighBarP, curHighPriceP, color = regPpoColor, width = ppoWidth, style = regPpoStyle, force_overlay = true)
        if delOldDiv
            supersede(regBearRecordsPpo, farP3.ndx)
        array.push(regBearRecordsPpo, DivRecord.new(newLnP3, newLnChartP3, farP3.ndx, label(na)))

    if hidBearCondPpo and showPPOHid
        farP4 = array.get(highPivotsPpo, hidDepthPH - 1)
        newLnP4 = line.new(farP4.ndx, farP4.ind, curHighBarP, curHighOscP, color = hidPpoColor, width = ppoWidth, style = hidPpoStyle)
        newLnChartP4 = line(na)
        if showPPOHidChart
            newLnChartP4 := line.new(farP4.ndx, farP4.price, curHighBarP, curHighPriceP, color = hidPpoColor, width = ppoWidth, style = hidPpoStyle, force_overlay = true)
        if delOldDiv
            supersede(hidBearRecordsPpo, farP4.ndx)
        array.push(hidBearRecordsPpo, DivRecord.new(newLnP4, newLnChartP4, farP4.ndx, label(na)))

    addPivot(highPivotsPpo, Pivot.new(curHighPriceP, curHighOscP, curHighBarP))

alertPpoDiv = (regBullCondPpo or hidBullCondPpo or regBearCondPpo or hidBearCondPpo)
//
//===================================================================
//=== Crossing Signals ===
//===================================================================
kdCrossUp = ta.crossover(osc, dOsc)
kdCrossDown = ta.crossunder(osc, dOsc)

buy = kdCrossUp and osc < -crossZone and dOsc < -crossZone
sell = kdCrossDown and osc > crossZone and dOsc > crossZone

divBuySignal = showDivSignal and kdCrossUp and osc < -divSignalZone and dOsc < -divSignalZone and not na(lastBullDivBar) and (bar_index - lastBullDivBar) <= divSignalBars
divSellSignal = showDivSignal and kdCrossDown and osc > divSignalZone and dOsc > divSignalZone and not na(lastBearDivBar) and (bar_index - lastBearDivBar) <= divSignalBars

plot(showCrossSignal and buy and not divBuySignal ? dOsc : na, title = 'crossing up', color = crossUpColor, style = plot.style_circles, linewidth = 3)
plot(showCrossSignal and sell and not divSellSignal ? dOsc : na, title = 'crossing down', color = crossDownColor, style = plot.style_circles, linewidth = 3)

if divBuySignal
    sigMarkerUp = label.new(bar_index, dOsc - divSignalVertOffset, text = '●', style = label.style_none, color = color.new(color.black, 100), textcolor = divUpColor, size = divSignalSize)
    if not na(lastBullSigRecord)
        lastBullSigRecord.sigMarker := sigMarkerUp

if divSellSignal
    sigMarkerDown = label.new(bar_index, dOsc - divSignalVertOffset, text = '●', style = label.style_none, color = color.new(color.black, 100), textcolor = divDownColor, size = divSignalSize)
    if not na(lastBearSigRecord)
        lastBearSigRecord.sigMarker := sigMarkerDown
//
//===================================================================
//=== Alerts ===
//===================================================================
alertcondition(buy, title = 'Buy', message = 'Stoch: Buy signal (K/D cross up in oversold)')
alertcondition(sell, title = 'Sell', message = 'Stoch: Sell signal (K/D cross down in overbought)')
alertcondition(divBuySignal, title = 'Divergence Buy Signal', message = 'Stoch: Buy signal following a bullish divergence')
alertcondition(divSellSignal, title = 'Divergence Sell Signal', message = 'Stoch: Sell signal following a bearish divergence')
alertcondition(divBuySignal or divSellSignal, title = 'Any Divergence Signal', message = 'Stoch: Divergence signal detected')
alertcondition(alertRegBull, title = 'Regular Bullish Divergence', message = 'Stoch: Regular Bullish Divergence detected')
alertcondition(alertHidBull, title = 'Hidden Bullish Divergence', message = 'Stoch: Hidden Bullish Divergence detected')
alertcondition(alertRegBear, title = 'Regular Bearish Divergence', message = 'Stoch: Regular Bearish Divergence detected')
alertcondition(alertHidBear, title = 'Hidden Bearish Divergence', message = 'Stoch: Hidden Bearish Divergence detected')
alertcondition(alertRegBull or alertHidBull or alertRegBear or alertHidBear, title = 'Any Divergence', message = 'Stoch: Divergence detected')
alertcondition(alertPpoDiv, title = 'Percentile Rank Divergence', message = 'Stoch: Percentile Rank divergence detected')
alertcondition(ta.cross(mf, 0), title = 'Money Flow Zero Cross', message = 'Stoch: Money Flow crossed zero line')
alertcondition(trendBuySignal, title = 'Stochastic Buy Signal', message = '{{ticker}} Stochastic Buy Signal on the {{interval}} chart')
alertcondition(trendSellSignal, title = 'Stochastic Sell Signal', message = '{{ticker}} Stochastic Sell Signal on the {{interval}} chart')
//
````
