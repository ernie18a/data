# Elaris Doji Finder Pro

- url: https://www.tradingview.com/script/1RUzMDuw-Elaris-Doji-Finder-Pro/
- type: indicator
- pine_id: PUB;3eecec9608bb42d192a3a37f961d0ca7
- version: 1.0

## Description

Elaris Doji Finder Pro is a professional-grade candlestick analysis indicator designed to detect high-quality Doji formations with advanced context filtering, signal scoring, and clean visual confirmations.

Unlike basic Doji detectors that simply highlight small candle bodies, this indicator evaluates market structure, volatility, wick behavior, trend context, and optional volume confirmation to help traders identify stronger indecision and potential reversal zones.

The indicator supports multiple Doji types including Neutral Doji, Long-Legged Doji, Dragonfly Doji, and Gravestone Doji while providing a premium TradingView experience with customizable visuals, signal quality scoring, smart dashboards, and non-repainting confirmed signals.

━━━━━━━━━━━━━━━━━━
FEATURES
━━━━━━━━━━━━━━━━━━

• Detects multiple Doji candle types
• Advanced candle body and wick analysis
• ATR-based volatility filtering
• EMA trend context filtering
• Volume confirmation system
• Swing support & resistance proximity filter
• Bullish / bearish contextual bias detection
• Signal quality scoring engine
• Professional dashboard interface
• Dark mode and light mode support
• Clean labels and compact signal markers
• Fully customizable settings
• Optimized for crypto, forex, indices, and stocks
• Non-repainting candle-close confirmation mode
• Built-in alert conditions

━━━━━━━━━━━━━━━━━━
SUPPORTED DOJI TYPES
━━━━━━━━━━━━━━━━━━

• Neutral Doji
Classic indecision candle with a very small body.

• Long-Legged Doji
High-volatility indecision candle with extended upper and lower wicks.

• Dragonfly Doji
Bullish rejection-style Doji often appearing near local lows or support zones.

• Gravestone Doji
Bearish rejection-style Doji often appearing near local highs or resistance zones.

━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━

Bullish Doji signals may become more effective when:
• Appearing near support
• Forming after strong sell pressure
• Confirmed by rising volume
• Appearing against an extended downtrend

Bearish Doji signals may become more effective when:
• Appearing near resistance
• Forming after strong buying pressure
• Confirmed by elevated volume
• Appearing after aggressive trend extensions

The signal quality score can help filter weaker setups and focus on higher-probability Doji structures.

━━━━━━━━━━━━━━━━━━
NON-REPAINTING
━━━━━━━━━━━━━━━━━━

This indicator can operate in non-repainting mode when “Confirm Signals On Candle Close” is enabled. Signals are confirmed only after candle close.

━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━

This indicator is designed for educational and analytical purposes only. Always use proper risk management and combine candlestick signals with broader market context before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ElarisGroup

//@version=6
indicator(
     "Elaris Doji Finder Pro",
     shorttitle = "Elaris Doji Pro",
     overlay = true,
     max_labels_count = 500,
     max_lines_count = 100,
     max_bars_back = 500
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupCore = "Core Doji Detection"

maxBodyPct = input.float(10.0, "Max Body % Of Candle Range", minval = 0.1, maxval = 40, step = 0.1, group = groupCore)
minRangeAtr = input.float(0.10, "Min Candle Range vs ATR", minval = 0.0, maxval = 5.0, step = 0.05, group = groupCore)
atrLen = input.int(14, "ATR Length", minval = 1, group = groupCore)
confirmOnClose = input.bool(true, "Confirm Signals On Candle Close", group = groupCore)

groupTypes = "Doji Types"

showNeutral = input.bool(true, "Classic / Neutral Doji", group = groupTypes)
showLongLegged = input.bool(true, "Long-Legged Doji", group = groupTypes)
showDragonfly = input.bool(true, "Dragonfly Doji", group = groupTypes)
showGravestone = input.bool(true, "Gravestone Doji", group = groupTypes)

longWickPct = input.float(35.0, "Long Wick Minimum %", minval = 5, maxval = 90, step = 1, group = groupTypes)
smallWickPct = input.float(15.0, "Small Wick Maximum %", minval = 1, maxval = 50, step = 1, group = groupTypes)

groupFilters = "Signal Quality Filters"

useTrendFilter = input.bool(false, "Use EMA Trend Context", group = groupFilters)
emaLen = input.int(200, "EMA Length", minval = 1, group = groupFilters)

useVolumeFilter = input.bool(false, "Use Volume Confirmation", group = groupFilters)
volLen = input.int(20, "Volume MA Length", minval = 1, group = groupFilters)
volMult = input.float(1.0, "Volume Multiplier", minval = 0.1, step = 0.1, group = groupFilters)

useSrFilter = input.bool(false, "Use Swing S/R Proximity Filter", group = groupFilters)
pivotLen = input.int(5, "Swing Pivot Length", minval = 2, maxval = 30, group = groupFilters)
srAtrDist = input.float(0.50, "Max Distance From S/R In ATR", minval = 0.05, step = 0.05, group = groupFilters)

groupVisual = "Visual Design"

theme = input.string("Dark", "Theme", options = ["Dark", "Light"], group = groupVisual)
showLabels = input.bool(true, "Show Signal Labels", group = groupVisual)
showShapes = input.bool(true, "Show Compact Shapes", group = groupVisual)
showEma = input.bool(false, "Show EMA", group = groupVisual)
showDashboard = input.bool(true, "Show Dashboard", group = groupVisual)

bullColor = input.color(color.lime, "Bullish Doji Color", group = groupVisual)
bearColor = input.color(color.red, "Bearish Doji Color", group = groupVisual)
neutralColor = input.color(color.orange, "Neutral Doji Color", group = groupVisual)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANDLE METRICS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
candleRange = high - low
body = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bodyPct = candleRange > 0 ? body / candleRange * 100 : 100
upperPct = candleRange > 0 ? upperWick / candleRange * 100 : 0
lowerPct = candleRange > 0 ? lowerWick / candleRange * 100 : 0

atr = ta.atr(atrLen)
rangeOk = candleRange >= atr * minRangeAtr
bodyOk = bodyPct <= maxBodyPct

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DOJI TYPE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isDragonfly = bodyOk and lowerPct >= longWickPct and upperPct <= smallWickPct
isGravestone = bodyOk and upperPct >= longWickPct and lowerPct <= smallWickPct
isLongLegged = bodyOk and upperPct >= longWickPct and lowerPct >= longWickPct
isNeutral = bodyOk and not isDragonfly and not isGravestone and not isLongLegged

validType =
     (showDragonfly and isDragonfly) or
     (showGravestone and isGravestone) or
     (showLongLegged and isLongLegged) or
     (showNeutral and isNeutral)

dojiType =
     isDragonfly ? "Dragonfly" :
     isGravestone ? "Gravestone" :
     isLongLegged ? "Long-Legged" :
     isNeutral ? "Neutral" :
     "None"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONTEXT FILTERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema = ta.ema(close, emaLen)
trendBull = close > ema
trendBear = close < ema

volMa = ta.sma(volume, volLen)
volumeOk = not useVolumeFilter or volume >= volMa * volMult

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

var float lastResistance = na
var float lastSupport = na

if not na(pivotHigh)
    lastResistance := pivotHigh

if not na(pivotLow)
    lastSupport := pivotLow

nearSupport = not na(lastSupport) and math.abs(low - lastSupport) <= atr * srAtrDist
nearResistance = not na(lastResistance) and math.abs(high - lastResistance) <= atr * srAtrDist
srOk = not useSrFilter or nearSupport or nearResistance

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL BIAS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullishDoji = isDragonfly or nearSupport or close > open
bearishDoji = isGravestone or nearResistance or close < open

trendOk =
     not useTrendFilter or
     bullishDoji and trendBear or
     bearishDoji and trendBull or
     isLongLegged

rawSignal = validType and rangeOk and volumeOk and srOk and trendOk
signal = confirmOnClose ? rawSignal and barstate.isconfirmed : rawSignal

bullSignal = signal and bullishDoji and not bearishDoji
bearSignal = signal and bearishDoji and not bullishDoji
neutralSignal = signal and not bullSignal and not bearSignal

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL QUALITY SCORE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bodyScore = math.max(0, 40 - bodyPct)
wickScore = isLongLegged ? 25 : isDragonfly or isGravestone ? 30 : 15
volumeScore = volumeOk and useVolumeFilter ? 15 : 5
srScore = useSrFilter and (nearSupport or nearResistance) ? 20 : 5

scoreRaw = bodyScore + wickScore + volumeScore + srScore
score = math.min(100, math.round(scoreRaw))

quality =
     score >= 80 ? "A+" :
     score >= 65 ? "A" :
     score >= 50 ? "B" :
     "C"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showEma ? ema : na, "EMA Context", color = color.new(color.blue, 0), linewidth = 2)

plotshape(showShapes and bullSignal, title = "Bullish Doji", style = shape.triangleup, location = location.belowbar, color = bullColor, size = size.small, text = "DOJI")
plotshape(showShapes and bearSignal, title = "Bearish Doji", style = shape.triangledown, location = location.abovebar, color = bearColor, size = size.small, text = "DOJI")
plotshape(showShapes and neutralSignal, title = "Neutral Doji", style = shape.circle, location = location.abovebar, color = neutralColor, size = size.tiny)

if showLabels and signal
    labelText = dojiType + "\nScore: " + str.tostring(score) + " / " + quality
    labelColor = bullSignal ? bullColor : bearSignal ? bearColor : neutralColor
    labelStyle = bullSignal ? label.style_label_up : label.style_label_down
    labelY = bullSignal ? low : high
    label.new(
         bar_index,
         labelY,
         labelText,
         style = labelStyle,
         color = color.new(labelColor, 0),
         textcolor = color.white,
         size = size.small
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COUNTERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int totalSignals = 0
var int bullCount = 0
var int bearCount = 0
var int neutralCount = 0
var string lastSignalType = "None"
var int lastScore = na

if signal
    totalSignals += 1
    bullCount += bullSignal ? 1 : 0
    bearCount += bearSignal ? 1 : 0
    neutralCount += neutralSignal ? 1 : 0
    lastSignalType := dojiType
    lastScore := score

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
darkMode = theme == "Dark"
dashBg = darkMode ? color.new(color.black, 10) : color.new(color.white, 5)
dashText = darkMode ? color.white : color.black
dashBorder = darkMode ? color.new(color.white, 75) : color.new(color.black, 75)

var table dash = table.new(position.top_right, 2, 7, border_width = 1, border_color = dashBorder)

if showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 6)

    table.cell(dash, 0, 0, "Elaris Doji Pro", bgcolor = dashBg, text_color = dashText)
    table.cell(dash, 1, 0, "Live", bgcolor = dashBg, text_color = color.lime)

    table.cell(dash, 0, 1, "Last Type", bgcolor = dashBg, text_color = dashText)
    table.cell(dash, 1, 1, lastSignalType, bgcolor = dashBg, text_color = dashText)

    table.cell(dash, 0, 2, "Last Score", bgcolor = dashBg, text_color = dashText)
    table.cell(dash, 1, 2, na(lastScore) ? "N/A" : str.tostring(lastScore), bgcolor = dashBg, text_color = dashText)

    table.cell(dash, 0, 3, "Bullish", bgcolor = dashBg, text_color = dashText)
    table.cell(dash, 1, 3, str.tostring(bullCount), bgcolor = dashBg, text_color = bullColor)

    table.cell(dash, 0, 4, "Bearish", bgcolor = dashBg, text_color = dashText)
    table.cell(dash, 1, 4, str.tostring(bearCount), bgcolor = dashBg, text_color = bearColor)

    table.cell(dash, 0, 5, "Neutral", bgcolor = dashBg, text_color = dashText)
    table.cell(dash, 1, 5, str.tostring(neutralCount), bgcolor = dashBg, text_color = neutralColor)

    table.cell(dash, 0, 6, "Total Signals", bgcolor = dashBg, text_color = dashText)
    table.cell(dash, 1, 6, str.tostring(totalSignals), bgcolor = dashBg, text_color = dashText)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(signal, "Any Doji Signal", "Elaris Doji Pro: Doji signal detected.")
alertcondition(bullSignal, "Bullish Doji Signal", "Elaris Doji Pro: Bullish Doji detected.")
alertcondition(bearSignal, "Bearish Doji Signal", "Elaris Doji Pro: Bearish Doji detected.")
alertcondition(neutralSignal, "Neutral Doji Signal", "Elaris Doji Pro: Neutral Doji detected.")

alertcondition(isDragonfly and signal, "Dragonfly Doji", "Elaris Doji Pro: Dragonfly Doji detected.")
alertcondition(isGravestone and signal, "Gravestone Doji", "Elaris Doji Pro: Gravestone Doji detected.")
alertcondition(isLongLegged and signal, "Long-Legged Doji", "Elaris Doji Pro: Long-Legged Doji detected.")
````
