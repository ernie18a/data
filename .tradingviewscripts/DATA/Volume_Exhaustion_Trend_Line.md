<!-- tradingview-pine-id: PUB;40d1afc6136d4a4b96ef7bff6acda658 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Exhaustion Trend Line

Source: https://www.tradingview.com/script/WTtXmPBE/

## Description

Volume Exhaustion Trend Line

OVERVIEW

This indicator plots a trend line that switches position relative to price based on a specific shift in volume behavior at swing highs and swing lows: when a series of pivots that were previously confirmed by volume above its moving average suddenly gets followed by one or more pivots with volume below its moving average, in the direction of the prevailing trend. This break in the volume pattern is treated as an early warning that the current trend may be losing the participation that was driving it.

HOW IT WORKS

1. Swing highs and swing lows are detected using a fractal pivot: a configurable number of bars on the left validates the structural significance of the pivot, and a configurable number of bars on the right confirms it. Fewer right-side bars means faster (but slightly less certain) confirmation.

2. Trend direction is determined purely from price structure, not from a moving average: the trend is bullish when both the most recent swing high and swing low are higher than the previous ones (higher highs / higher lows), and bearish when both are lower (lower highs / lower lows).

3. Each confirmed pivot is classified as "strong" or "weak" by comparing the volume on that exact pivot bar against a simple moving average of volume.

4. The indicator watches for the transition point: while the trend is bullish, if a swing high forms with weak volume right after a swing high that had strong volume, an exhaustion warning state is triggered. It stays active for as long as new swing highs keep forming with weak volume. If a strong-volume high reappears, or the trend structure changes, the warning resets. The same logic applies in mirror for swing lows inside a bearish trend.

5. A line is plotted around price using a moving average offset by a multiple of ATR. In a bullish trend with no active warning, the line sits below price (green). As soon as the warning triggers, the line jumps above price (red) for as long as the warning stays active. The mirror applies in a bearish trend: line above price (red) normally, dropping below price (green) when a weak-volume low breaks a prior strong-volume pattern. The area between the line and price is filled with the corresponding color for visual clarity.

INPUTS

- Left Bars (structural strength): bars to the left required to validate the pivot's significance.
- Right Bars (confirmation delay): bars to the right required to confirm the pivot. Lower values react faster; higher values produce more reliable pivots.
- Volume MA Length: moving average length used as the volume reference for classifying a pivot as strong or weak.
- Line MA Length: moving average length used as the basis for the plotted line.
- ATR Length / ATR Multiplier: control how far the line sits from the moving average basis, in both its normal and warning position.
- Bullish / Bearish Colors: colors for the line and fill in each state.

HOW TO USE IT

Line below price, green: the market is in a structurally confirmed uptrend and recent highs are still backed by above-average volume.

Line jumps above price, red, while price is still trending up: recent high(s) were not backed by above-average volume after previously being backed by it. Treat this as a signal to pay closer attention to that area for a possible loss of upside momentum, not as an automatic sell trigger.

Mirror logic applies in a downtrend: line above price (red) normally, dropping below price (green) when recent lows stop being confirmed by above-average volume after previously being confirmed by it, suggesting selling pressure may be fading.

This indicator identifies a condition, it does not generate entries or exits on its own. It is meant to be combined with your own structure, level, and risk analysis.

LIMITATIONS

- Pivots require Right Bars to pass before they can be confirmed, so every line change is applied with a delay equal to that setting relative to when the actual high/low occurred. Once plotted, it does not repaint or move retroactively.
- Volume shown on non-centralized markets (forex, CFDs, spot metals) is broker/feed-reported tick volume, not centralized traded volume. Interpret weak/strong volume readings on these instruments with that in mind.
- Like any structure-based tool, results vary by instrument, timeframe, and the settings used.

---

## Source Code

````pine
//@version=6
indicator("Volume Exhaustion Trend Line", shorttitle="Vol Exhaustion MA", overlay=true, max_bars_back=5000)

// ---------------- Inputs ----------------
leftBars    = input.int(20, "Left Bars (structural strength)", minval=1, group="Pivot Detection")
rightBars   = input.int(1, "Right Bars (confirmation delay)", minval=1, group="Pivot Detection")
volMaLength = input.int(20, "Volume MA Length", minval=1, group="Pivot Detection")

maLength    = input.int(20, "Line MA Length", minval=1, group="Line")
atrLength   = input.int(14, "ATR Length", minval=1, group="Line")
atrMult     = input.float(1.5, "ATR Multiplier (offset from price)", minval=0.1, step=0.1, group="Line")

bullColor   = input.color(color.lime, "Bullish (line below price) Color", group="Colors")
bearColor   = input.color(color.red, "Bearish (line above price) Color", group="Colors")

// ---------------- Volume reference ----------------
volMA = ta.sma(volume, volMaLength)

// ---------------- Line construction ----------------
basis     = ta.sma(close, maLength)
atrVal    = ta.atr(atrLength)
upperBand = basis + atrMult * atrVal
lowerBand = basis - atrMult * atrVal

// ---------------- Pivot detection ----------------
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

// ---------------- Persistent state ----------------
var float lastHigh         = float(na)
var float prevHigh         = float(na)
var float lastLow          = float(na)
var float prevLow          = float(na)
var string trend           = "none"
var bool lastHighWasStrong = false
var bool lastLowWasStrong  = false
var bool hasLastHigh       = false
var bool hasLastLow        = false
var bool pendingUp         = false
var bool pendingDown       = false

// ---------------- New pivot high ----------------
if not na(ph)
    pivotVolume = volume[rightBars]
    pivotVolMA  = volMA[rightBars]
    isWeak      = pivotVolume < pivotVolMA
    trendBefore = trend

    if trendBefore == "up"
        if isWeak
            if pendingUp or (hasLastHigh and lastHighWasStrong)
                pendingUp := true
        else
            pendingUp := false
    else
        pendingUp := false

    lastHighWasStrong := not isWeak
    hasLastHigh := true
    prevHigh := lastHigh
    lastHigh := ph

    if not na(prevHigh) and not na(lastLow) and not na(prevLow)
        newTrend = trend
        if lastHigh > prevHigh and lastLow > prevLow
            newTrend := "up"
        else if lastHigh < prevHigh and lastLow < prevLow
            newTrend := "down"
        else
            newTrend := "none"
        if newTrend != "up"
            pendingUp := false
        if newTrend != "down"
            pendingDown := false
        trend := newTrend

// ---------------- New pivot low ----------------
if not na(pl)
    pivotVolume = volume[rightBars]
    pivotVolMA  = volMA[rightBars]
    isWeak      = pivotVolume < pivotVolMA
    trendBefore = trend

    if trendBefore == "down"
        if isWeak
            if pendingDown or (hasLastLow and lastLowWasStrong)
                pendingDown := true
        else
            pendingDown := false
    else
        pendingDown := false

    lastLowWasStrong := not isWeak
    hasLastLow := true
    prevLow := lastLow
    lastLow := pl

    if not na(prevHigh) and not na(lastHigh) and not na(prevLow)
        newTrend = trend
        if lastHigh > prevHigh and lastLow > prevLow
            newTrend := "up"
        else if lastHigh < prevHigh and lastLow < prevLow
            newTrend := "down"
        else
            newTrend := "none"
        if newTrend != "up"
            pendingUp := false
        if newTrend != "down"
            pendingDown := false
        trend := newTrend

// ---------------- Line value (recalculated every bar) ----------------
var float lineValue = float(na)

if trend == "up"
    lineValue := pendingUp ? upperBand : lowerBand
else if trend == "down"
    lineValue := pendingDown ? lowerBand : upperBand

plotColor = na(lineValue) ? color.gray : (lineValue < close ? bullColor : bearColor)
fillColor = na(lineValue) ? color.new(color.gray, 100) : (lineValue < close ? color.new(bullColor, 85) : color.new(bearColor, 85))

linePlot  = plot(lineValue, "Volume Exhaustion Line", color=plotColor, linewidth=2, style=plot.style_line)
closePlot = plot(close, "Close (fill anchor)", display=display.none)

fill(linePlot, closePlot, color=fillColor)
````
