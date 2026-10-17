# Uptrick: Dynamic Trend Matrix

- url: https://www.tradingview.com/script/3uaaKWpT-Uptrick-Dynamic-Trend-Matrix/
- type: indicator
- pine_id: PUB;a839360528fe433385078773fb9793ec
- version: 1.0

## Description

[b][i]Overview[/i][/b]
Dynamic Trend Matrix is an open-source trend-following overlay designed to help traders read market direction, trend strength, pullback areas, and optional take-profit progress from one chart-based tool. It is built to provide a structured view of trend conditions without relying on a single crossover or one isolated signal.

[b][i]Introduction[/i][/b]
The script combines EMA-based trend structure, ATR-based volatility bands, a dynamic trailing engine, candle coloring, signal labels, X-marker re-entry logic, take-profit markers, alerts, and a compact dashboard. Its goal is to make trend conditions easier to interpret by separating the main trend state, pressure confirmation, pullback behavior, and target tracking into clear visual components.

[b][i]Originality & Uniqueness[/i][/b]
Dynamic Trend Matrix uses a custom trend state model that blends moving-average alignment, smoothed slope pressure, ATR volatility boundaries, adaptive trailing logic, visual strength coloring, and staged take-profit tracking.

Instead of only showing a basic moving average crossover or a simple band break, the script organizes trend information into multiple layers. The trend flip logic identifies directional changes, the pressure filter evaluates whether EMA structure supports the active side, the trail helps show the active trend boundary, and the X markers highlight pullback interactions near the trend trail.

This layered design allows users to view both trend direction and trend quality, while keeping the chart visually organized.

[b][i]How It Works[/i][/b]
The script calculates fast, base, and slow EMA trend components from the selected source. These moving averages are used to measure directional structure and help determine whether the market is showing bullish, bearish, or mixed pressure.

ATR-based bands are then built around the base trend. A long trend state is triggered when price breaks above the upper ATR band, while a short trend state is triggered when price breaks below the lower ATR band. Once a trend state is active, the script maintains a dynamic trailing level that adjusts with volatility and trend direction.

Trend pressure is confirmed when the EMA structure and smoothed slope agree with the active trend. Trend strength is calculated by comparing the distance between the fast and slow trend components against ATR. This strength reading is used for dashboard values and optional candle coloring.

The take-profit system uses the active signal price and either risk from the trail or ATR from entry to create up to three visual target levels. These levels are for chart reference only and are not automated trade management.

[b][i]Inputs[/i][/b]
The main settings allow users to adjust the trend lengths, smoothing, ATR length, ATR multiplier, visual style, candle coloring method, signal confirmation, label appearance, X-marker behavior, take-profit calculation mode, dashboard position, and alert options.

The default settings are intended to provide a balanced trend-following view, but users should adjust them based on the market, timeframe, and volatility conditions they are studying.

[b][i]Features[/i][/b]
[list]
[*] Dynamic trend flip detection using ATR-adjusted band breaks.
[*] EMA-based trend structure using fast, base, and slow trend components.
[*] Smoothed slope pressure filter to help distinguish stronger trend alignment from mixed conditions.
[*] Adaptive trail that follows the active trend and adjusts with volatility.
[*] Multiple visual modes, including bands, trend trail, and candles only.
[*] Candle coloring based on either latest trend direction or trend strength.
[*] Optional gradient visuals to make active trend zones easier to read.
[*] Optional outer bands for additional volatility context.
[*] Long and short signal labels with optional bar-close confirmation.
[*] X-marker re-entry logic for pullback touches near the dynamic trail.
[*] Configurable X-marker behavior, including first valid marker only or every valid marker.
[*] Optional take-profit markers with one, two, or three target levels.
[*] Take-profit calculations based on either risk from trail or ATR from entry.
[*] Dashboard showing trend state, pressure, strength, trail value, visual mode, and TP state.
[*] Alert conditions for long signals, short signals, X markers, and take-profit hits.
[/list]

[b][i]How To Use[/i][/b]
Add the indicator to a standard candlestick chart and select the visual mode that best fits your workflow. The Bands mode provides a broader view of volatility zones around the trend basis. The Trend Trail mode focuses more directly on the active trailing level. Candles Only mode keeps the chart cleaner while still showing trend-based candle colors.

Long and short labels can be used as potential trend-change signals. The trail can be used as a visual reference for the active trend boundary. X markers are designed to show valid pullback interactions near the trail after a trend has already been established.

The dashboard provides a quick summary of current conditions, including trend state, pressure, strength, trail value, visual mode, and TP progress. Users who prefer confirmed signals can keep bar-close confirmation enabled. Users who want faster realtime feedback can disable confirmation, but signals may be less stable before the candle closes.

[b][i]Limitations[/i][/b]
This indicator is not a complete trading system and does not guarantee profitable results. It does not include position sizing, stop-loss execution, order management, commissions, slippage, or full strategy backtesting.

Signals may appear late during fast reversals because the model uses EMAs, smoothing, ATR bands, and trend confirmation. Sideways, choppy, or low-volatility markets may produce false flips, mixed pressure readings, or less useful pullback markers.

Take-profit markers are visual reference levels only. They do not guarantee that a trade should be entered, held, exited, or managed in a specific way. Users should test settings across different symbols, sessions, and timeframes before relying on the script for live decision-making.

The script does not use request.security(), lookahead, or negative plot offsets. With bar-close confirmation enabled, Long, Short, X-marker, and TP signals are confirmed after the candle closes. If confirmation is disabled, realtime signals may appear or change before the candle closes. The script should be used on standard chart types because non-standard charts can affect signal behavior.

[b][i]Conclusion[/i][/b]
Dynamic Trend Matrix is designed to provide a clean visual framework for reading trend direction, trend pressure, pullback context, and staged target progress. It can help organize trend-following analysis, but it should be used alongside market structure, risk management, and broader chart context.

[quote]Disclaimer
This script is for educational and informational purposes only. It does not provide financial advice, investment advice, trading advice, or guaranteed outcomes. Trading involves risk, and users are responsible for their own analysis, decisions, and risk management.[/quote]

## Source Code

````pine
// This work is licensed under an Attribution-ShareAlike 4.0 International License (CC BY-SA 4.0)
// https://creativecommons.org/licenses/by-sa/4.0/
//@version=6

//    ██╗   ██╗██████╗ ████████╗██████╗ ██╗ ██████╗██╗  ██╗
//    ██║   ██║██╔══██╗╚══██╔══╝██╔══██╗██║██╔════╝██║ ██╔╝
//    ██║   ██║██████╔╝   ██║   ██████╔╝██║██║     █████╔╝ 
//    ██║   ██║██╔═══╝    ██║   ██╔══██╗██║██║     ██╔═██╗ 
//    ╚██████╔╝██║        ██║   ██║  ██║██║╚██████╗██║  ██╗
//     ╚═════╝ ╚═╝        ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝

indicator("Uptrick: Dynamic Trend Matrix",
     shorttitle="DTM",
     overlay=true,
     max_lines_count=500,
     max_labels_count=500)

// ─────────────────────────────────────
// Colors
// ─────────────────────────────────────
bullMain = color.new(#5CF0D7, 0)
bearMain = color.new(#B32AC3, 0)
textCol = color.white
neutralCol = color.rgb(110, 110, 125)

blackBg = color.rgb(3, 3, 6)
blackCell = color.rgb(8, 8, 12)
blackAlt = color.rgb(12, 12, 18)
blackSection = color.rgb(15, 15, 22)
softFrame = color.new(color.white, 62)
softBorder = color.new(color.white, 94)

// ─────────────────────────────────────
// Inputs
// ─────────────────────────────────────
grpCore = "━━━━━━━━ CORE ━━━━━━━━"
grpVisual = "━━━━━━━━ VISUALS ━━━━━━━━"
grpSignals = "━━━━━━━━ SIGNALS ━━━━━━━━"
grpTP = "━━━━━━━━ TAKE PROFITS ━━━━━━━━"
grpDash = "━━━━━━━━ DASHBOARD / ALERTS ━━━━━━━━"

src = input.source(close, "Source", group=grpCore)
fastLen = input.int(8, "Fast Length", minval=2, group=grpCore)
baseLen = input.int(21, "Base Length", minval=2, group=grpCore)
slowLen = input.int(55, "Slow Length", minval=5, group=grpCore)
slopeLen = input.int(5, "Slope Length", minval=1, group=grpCore)
smoothLen = input.int(3, "Smoothing", minval=1, group=grpCore)
atrLen = input.int(10, "ATR Length", minval=1, group=grpCore)
atrMult = input.float(2.0, "ATR Multiplier", minval=0.1, step=0.1, group=grpCore)

visualModel = input.string("Bands", "Visual Mode", options=["Bands", "Trend Trail", "Candles Only"], group=grpVisual)
showPlotCandles = input.bool(true, "Use Plot Candles", group=grpVisual)
candleMode = input.string("Latest Signal", "Candle Coloring", options=["Latest Signal", "Trend Strength"], group=grpVisual)
showGradient = input.bool(true, "Show Gradient", group=grpVisual)
showOuterBands = input.bool(true, "Show Outer Bands", group=grpVisual)
trailWidth = input.int(2, "Trail Width", minval=1, maxval=5, group=grpVisual)

showSignals = input.bool(true, "Show Long / Short Labels", group=grpSignals)
confirmSignals = input.bool(true, "Confirm Signals On Bar Close", group=grpSignals)
labelStyleMode = input.string("Cool Font", "Label Style", options=["Cool Font", "Plain", "Symbols"], group=grpSignals)
signalAtrGap = input.float(0.75, "Label Distance", minval=0.0, step=0.05, group=grpSignals)
lblSize = input.string("small", "Label Size", options=["tiny", "small", "normal", "large", "huge"], group=grpSignals)
reentryMode = input.string("First X Only", "X Markers", options=["Off", "First X Only", "Every Valid X"], group=grpSignals)

showTPs = input.bool(true, "Show TP Signals", group=grpTP)
tpMode = input.string("Risk From Trail", "TP Calculation", options=["Risk From Trail", "ATR From Entry"], group=grpTP)
tpCount = input.string("3 TPs", "TP Count", options=["1 TP", "2 TPs", "3 TPs"], group=grpTP)
tp1Mult = input.float(1.0, "TP1 Multiplier", minval=0.1, step=0.1, group=grpTP)
tp2Mult = input.float(2.0, "TP2 Multiplier", minval=0.1, step=0.1, group=grpTP)
tp3Mult = input.float(3.0, "TP3 Multiplier", minval=0.1, step=0.1, group=grpTP)

showTable = input.bool(true, "Show Dashboard", group=grpDash)
dashPos = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDash)
enableAlerts = input.bool(true, "Enable Alerts", group=grpDash)

// ─────────────────────────────────────
// Helpers
// ─────────────────────────────────────
clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

mixColor(color c1, color c2, float t) =>
    float weight = clamp(t, 0.0, 1.0)
    int r = int(color.r(c1) + (color.r(c2) - color.r(c1)) * weight)
    int g = int(color.g(c1) + (color.g(c2) - color.g(c1)) * weight)
    int b = int(color.b(c1) + (color.b(c2) - color.b(c1)) * weight)
    color.rgb(r, g, b)

toSize(string s) =>
    s == "tiny" ? size.tiny :
     s == "small" ? size.small :
     s == "normal" ? size.normal :
     s == "large" ? size.large : size.huge

toPosition(string s) =>
    s == "Top Left" ? position.top_left :
     s == "Bottom Right" ? position.bottom_right :
     s == "Bottom Left" ? position.bottom_left : position.top_right

longText() =>
    labelStyleMode == "Cool Font" ? "𝓛𝓸𝓷𝓰" :
     labelStyleMode == "Symbols" ? "▲" :
     "Long"

shortText() =>
    labelStyleMode == "Cool Font" ? "𝓢𝓱𝓸𝓻𝓽" :
     labelStyleMode == "Symbols" ? "▼" :
     "Short"

formatPrice(float x) =>
    na(x) ? "n/a" : str.tostring(x, format.mintick)

maxTPCount() =>
    tpCount == "1 TP" ? 1 :
     tpCount == "2 TPs" ? 2 : 3

signalAllowed() =>
    not confirmSignals or barstate.isconfirmed

// ─────────────────────────────────────
// Trend core
// ─────────────────────────────────────
fastTrend = ta.ema(src, fastLen)
baseTrend = ta.ema(src, baseLen)
slowTrend = ta.ema(src, slowLen)

trendSpread = fastTrend - slowTrend
trendSpreadSmooth = ta.ema(trendSpread, smoothLen)

slopeRaw = baseTrend - baseTrend[slopeLen]
slopeSmooth = ta.ema(slopeRaw, smoothLen)

atr = ta.atr(atrLen)

trendStrengthRaw = atr == 0.0 ? 0.0 : math.abs(trendSpreadSmooth) / atr
trendStrength = clamp(trendStrengthRaw, 0.0, 3.0) / 3.0

bullPressure = fastTrend > baseTrend and baseTrend > slowTrend and slopeSmooth > 0
bearPressure = fastTrend < baseTrend and baseTrend < slowTrend and slopeSmooth < 0

upperBandRaw = baseTrend + atr * atrMult
lowerBandRaw = baseTrend - atr * atrMult

upperBand = ta.ema(upperBandRaw, 4)
lowerBand = ta.ema(lowerBandRaw, 4)

upperOuterBand = ta.ema(baseTrend + atr * atrMult * 1.45, 4)
lowerOuterBand = ta.ema(baseTrend - atr * atrMult * 1.45, 4)

// ─────────────────────────────────────
// Trail engine
// ─────────────────────────────────────
var int trend = 0
var float trail = na

rawLongFlip = close > upperBandRaw[1] and trend != 1
rawShortFlip = close < lowerBandRaw[1] and trend != -1

longSignal = rawLongFlip and signalAllowed()
shortSignal = rawShortFlip and signalAllowed()

if longSignal
    trend := 1
    trail := lowerBandRaw
else if shortSignal
    trend := -1
    trail := upperBandRaw
else
    if trend == 1
        trail := math.max(nz(trail[1], lowerBandRaw), lowerBandRaw)
    else if trend == -1
        trail := math.min(nz(trail[1], upperBandRaw), upperBandRaw)
    else
        trail := baseTrend

trailSmooth = ta.ema(trail, 5)

confirmedLong = trend == 1 and bullPressure
confirmedShort = trend == -1 and bearPressure

// ─────────────────────────────────────
// X marker logic
// ─────────────────────────────────────
rawLongReentry = trend == 1 and close > trailSmooth and low <= trailSmooth and bullPressure and not longSignal
rawShortReentry = trend == -1 and close < trailSmooth and high >= trailSmooth and bearPressure and not shortSignal

var bool reentryUsed = false

if longSignal or shortSignal
    reentryUsed := false

allowReentry = reentryMode != "Off"
allowEvery = reentryMode == "Every Valid X"

longReentry = allowReentry and rawLongReentry and signalAllowed() and (allowEvery or not reentryUsed)
shortReentry = allowReentry and rawShortReentry and signalAllowed() and (allowEvery or not reentryUsed)

if longReentry or shortReentry
    reentryUsed := true

// ─────────────────────────────────────
// TP engine
// ─────────────────────────────────────
var int activeSide = 0
var int entryBar = na
var float entryPrice = na
var float entryRisk = na
var float tp1 = na
var float tp2 = na
var float tp3 = na
var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false

if longSignal
    activeSide := 1
    entryBar := bar_index
    entryPrice := close
    entryRisk := tpMode == "Risk From Trail" ? math.max(close - lowerBandRaw, syminfo.mintick) : atr
    tp1 := entryPrice + entryRisk * tp1Mult
    tp2 := entryPrice + entryRisk * tp2Mult
    tp3 := entryPrice + entryRisk * tp3Mult
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false

if shortSignal
    activeSide := -1
    entryBar := bar_index
    entryPrice := close
    entryRisk := tpMode == "Risk From Trail" ? math.max(upperBandRaw - close, syminfo.mintick) : atr
    tp1 := entryPrice - entryRisk * tp1Mult
    tp2 := entryPrice - entryRisk * tp2Mult
    tp3 := entryPrice - entryRisk * tp3Mult
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false

maxTP = maxTPCount()
tpReady = showTPs and signalAllowed() and not na(entryPrice) and not na(entryBar) and bar_index > entryBar

newTP1 = tpReady and maxTP >= 1 and not tp1Hit and ((activeSide == 1 and high >= tp1) or (activeSide == -1 and low <= tp1))
newTP2 = tpReady and maxTP >= 2 and not tp2Hit and ((activeSide == 1 and high >= tp2) or (activeSide == -1 and low <= tp2))
newTP3 = tpReady and maxTP >= 3 and not tp3Hit and ((activeSide == 1 and high >= tp3) or (activeSide == -1 and low <= tp3))

tpTextColor = activeSide == 1 ? bullMain : activeSide == -1 ? bearMain : textCol

if newTP1
    tp1Hit := true
    label.new(bar_index, activeSide == 1 ? tp1 + atr * 0.22 : tp1 - atr * 0.22,
         text="①",
         style=label.style_none,
         size=size.large,
         color=color.new(tpTextColor, 100),
         textcolor=tpTextColor)

if newTP2
    tp2Hit := true
    label.new(bar_index, activeSide == 1 ? tp2 + atr * 0.44 : tp2 - atr * 0.44,
         text="②",
         style=label.style_none,
         size=size.large,
         color=color.new(tpTextColor, 100),
         textcolor=tpTextColor)

if newTP3
    tp3Hit := true
    label.new(bar_index, activeSide == 1 ? tp3 + atr * 0.66 : tp3 - atr * 0.66,
         text="③",
         style=label.style_none,
         size=size.large,
         color=color.new(tpTextColor, 100),
         textcolor=tpTextColor)

// ─────────────────────────────────────
// Colors
// ─────────────────────────────────────
trendColor = trend == 1 ? bullMain : trend == -1 ? bearMain : neutralCol

strengthColor = trend == 1 ? mixColor(neutralCol, bullMain, trendStrength) :
     trend == -1 ? mixColor(neutralCol, bearMain, trendStrength) :
     neutralCol

barCol = candleMode == "Trend Strength" ? strengthColor : trendColor

targetSide = trend == 1 ? 1.0 : trend == -1 ? -1.0 : 0.0
transitionAlpha = 2.0 / 15.0

var float visualSide = 0.0
var bool visualReady = false

if not visualReady and trend != 0
    visualSide := targetSide
    visualReady := true
else
    visualSide := visualSide + (targetSide - visualSide) * transitionAlpha

rawBullWeight = clamp((visualSide + 1.0) / 2.0, 0.0, 1.0)
rawBearWeight = clamp((1.0 - visualSide) / 2.0, 0.0, 1.0)

// ─────────────────────────────────────
// Visuals
// ─────────────────────────────────────
showBasisVisual = visualModel != "Candles Only"
showBandVisual = visualModel == "Bands"
showTrailVisual = visualModel == "Trend Trail"

isBull = trend == 1
isBear = trend == -1

basisCol = showBasisVisual ? color.new(trendColor, 88) : color.new(trendColor, 100)

upperBandCol = showBandVisual and isBear ? color.new(trendColor, int(100.0 - rawBearWeight * 85.0)) : color.new(trendColor, 100)
lowerBandCol = showBandVisual and isBull ? color.new(trendColor, int(100.0 - rawBullWeight * 85.0)) : color.new(trendColor, 100)

upperOuterBandCol = showBandVisual and showOuterBands and isBear ? color.new(trendColor, int(100.0 - rawBearWeight * 55.0)) : color.new(trendColor, 100)
lowerOuterBandCol = showBandVisual and showOuterBands and isBull ? color.new(trendColor, int(100.0 - rawBullWeight * 55.0)) : color.new(trendColor, 100)

upperGradTop = showGradient and showBandVisual and isBear ? color.new(trendColor, int(100.0 - rawBearWeight * 32.0)) : color.new(trendColor, 100)
lowerGradBottom = showGradient and showBandVisual and isBull ? color.new(trendColor, int(100.0 - rawBullWeight * 32.0)) : color.new(trendColor, 100)

upperOuterFillTop = showGradient and showBandVisual and showOuterBands and isBear ? color.new(trendColor, 82) : color.new(trendColor, 100)
lowerOuterFillBottom = showGradient and showBandVisual and showOuterBands and isBull ? color.new(trendColor, 82) : color.new(trendColor, 100)

trailCol = showTrailVisual ? color.new(trendColor, 0) : color.new(trendColor, 100)
trailGradCol = showTrailVisual and showGradient ? color.new(trendColor, 74) : color.new(trendColor, 100)

// ─────────────────────────────────────
// Plots
// ─────────────────────────────────────
barcolor(na)

plotcandle(open, high, low, close,
     title="Dynamic Trend Candles",
     color=showPlotCandles ? barCol : na,
     wickcolor=showPlotCandles ? barCol : na,
     bordercolor=showPlotCandles ? barCol : na)

pMid = plot(baseTrend, "Adaptive Trend Basis", color=basisCol, linewidth=1)
pUpperOuter = plot(upperOuterBand, "Upper Outer Band", color=upperOuterBandCol, linewidth=1)
pUpper = plot(upperBand, "Upper Trend Band", color=upperBandCol, linewidth=1)
pLower = plot(lowerBand, "Lower Trend Band", color=lowerBandCol, linewidth=1)
pLowerOuter = plot(lowerOuterBand, "Lower Outer Band", color=lowerOuterBandCol, linewidth=1)

pTrail = plot(trailSmooth, "Dynamic Trend Trail", color=trailCol, linewidth=trailWidth, style=plot.style_linebr)

fill(pUpper, pMid, upperBand, baseTrend, upperGradTop, color.new(trendColor, 100))
fill(pMid, pLower, baseTrend, lowerBand, color.new(trendColor, 100), lowerGradBottom)

fill(pUpperOuter, pUpper, upperOuterBand, upperBand, upperOuterFillTop, color.new(trendColor, 100))
fill(pLower, pLowerOuter, lowerBand, lowerOuterBand, color.new(trendColor, 100), lowerOuterFillBottom)

trailTop = trend == -1 ? trailSmooth : baseTrend
trailBottom = trend == 1 ? trailSmooth : baseTrend

pTrailTop = plot(trailTop, "Trail Gradient Top", color=color.new(trendColor, 100), display=display.none)
pTrailBottom = plot(trailBottom, "Trail Gradient Bottom", color=color.new(trendColor, 100), display=display.none)

fill(pTrailTop, pTrailBottom, trailTop, trailBottom, trailGradCol, color.new(trendColor, 100))

// ─────────────────────────────────────
// Labels
// ─────────────────────────────────────
labelSize = toSize(lblSize)
signalGap = atr * signalAtrGap

if showSignals and longSignal
    label.new(bar_index, low - signalGap,
         text=longText(),
         style=label.style_label_up,
         size=labelSize,
         color=bullMain,
         textcolor=color.black)

if showSignals and shortSignal
    label.new(bar_index, high + signalGap,
         text=shortText(),
         style=label.style_label_down,
         size=labelSize,
         color=bearMain,
         textcolor=color.white)

if longReentry
    label.new(bar_index, low - signalGap * 0.55,
         text="✕",
         style=label.style_label_up,
         size=size.normal,
         color=color.new(bullMain, 75),
         textcolor=bullMain)

if shortReentry
    label.new(bar_index, high + signalGap * 0.55,
         text="✕",
         style=label.style_label_down,
         size=size.normal,
         color=color.new(bearMain, 75),
         textcolor=bearMain)

// ─────────────────────────────────────
// Dashboard
// ─────────────────────────────────────
tablePos = toPosition(dashPos)

var table dash = table.new(tablePos, 2, 9,
     bgcolor=blackBg,
     frame_color=softFrame,
     frame_width=1,
     border_color=softBorder,
     border_width=1)

var bool mergedDash = false

if not mergedDash
    table.merge_cells(dash, 0, 0, 1, 0)
    table.merge_cells(dash, 0, 1, 1, 1)
    table.merge_cells(dash, 0, 5, 1, 5)
    mergedDash := true

cell(int col, int row, string txt, color bg, color txtColor) =>
    table.cell(dash, col, row, txt, text_color=txtColor, bgcolor=bg, text_size=size.small)

cellCenter(int col, int row, string txt, color bg, color txtColor) =>
    table.cell(dash, col, row, txt, text_color=txtColor, bgcolor=bg, text_size=size.small, text_halign=text.align_center)

trendText = trend == 1 ? "LONG" : trend == -1 ? "SHORT" : "NEUTRAL"
pressureText = confirmedLong ? "STRONG" : confirmedShort ? "STRONG" : "MIXED"
strengthText = str.tostring(math.round(trendStrength * 100)) + "%"
trailText = formatPrice(trailSmooth)

tpState = not showTPs ? "OFF" :
     (tp1Hit ? "①✓ " : "①○ ") +
     (maxTP >= 2 ? (tp2Hit ? "②✓ " : "②○ ") : "") +
     (maxTP >= 3 ? (tp3Hit ? "③✓" : "③○") : "")

if showTable and barstate.islast
    cellCenter(0, 0, "DYNAMIC TREND MATRIX", blackBg, textCol)
    cellCenter(0, 1, "TREND CORE", blackSection, color.new(color.white, 5))

    cell(0, 2, "State", blackCell, color.new(color.white, 12))
    cellCenter(1, 2, trendText, blackAlt, trendColor)

    cell(0, 3, "Pressure", blackAlt, color.new(color.white, 12))
    cellCenter(1, 3, pressureText, blackCell, trendColor)

    cell(0, 4, "Strength", blackCell, color.new(color.white, 12))
    cellCenter(1, 4, strengthText, blackAlt, color.white)

    cellCenter(0, 5, "TRADE MODEL", blackSection, color.new(color.white, 5))

    cell(0, 6, "Visual", blackCell, color.new(color.white, 12))
    cellCenter(1, 6, visualModel, blackAlt, color.white)

    cell(0, 7, "Trail", blackAlt, color.new(color.white, 12))
    cellCenter(1, 7, trailText, blackCell, color.white)

    cell(0, 8, "TP State", blackCell, color.new(color.white, 12))
    cellCenter(1, 8, tpState, blackAlt, tpTextColor)

if not showTable and barstate.islast
    table.clear(dash, 0, 0, 1, 8)

// ─────────────────────────────────────
// Alerts
// ─────────────────────────────────────
alertcondition(enableAlerts and longSignal, title="Long Signal", message="Dynamic Trend Matrix: Long signal")
alertcondition(enableAlerts and shortSignal, title="Short Signal", message="Dynamic Trend Matrix: Short signal")
alertcondition(enableAlerts and longReentry, title="Long X Marker", message="Dynamic Trend Matrix: Long X marker")
alertcondition(enableAlerts and shortReentry, title="Short X Marker", message="Dynamic Trend Matrix: Short X marker")
alertcondition(enableAlerts and newTP1, title="TP1 Signal", message="Dynamic Trend Matrix: TP1 signal")
alertcondition(enableAlerts and newTP2, title="TP2 Signal", message="Dynamic Trend Matrix: TP2 signal")
alertcondition(enableAlerts and newTP3, title="TP3 Signal", message="Dynamic Trend Matrix: TP3 signal")
````
