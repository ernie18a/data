# Squeeze Momentum with Divergence

- url: https://www.tradingview.com/script/Rl0oQpSo-Squeeze-Momentum-with-Divergence/
- type: indicator
- pine_id: PUB;46465a4602d24b68927d004ebd797115
- version: 1.0

## Description

Squeeze Momentum Divergence is a modified version of the open-source “Squeeze Momentum Indicator [LazyBear]” originally published by LazyBear on TradingView.

Original indicator by LazyBear:
https://www.tradingview.com/script/nqQ1DT5a-Squeeze-Momentum-Indicator-LazyBear/

The original indicator uses Bollinger Bands, Keltner Channels, and a linear-regression momentum histogram to identify squeeze conditions and momentum direction.

This version keeps the core squeeze momentum logic and adds a custom divergence-detection system. The indicator can detect regular bullish divergence, regular bearish divergence, hidden bullish divergence, and hidden bearish divergence between price and the squeeze momentum value.

Main additions in this version:
- Updated and restructured for Pine Script v6
- Regular bullish and bearish divergence detection
- Hidden bullish and bearish divergence detection
- Divergence lines in the indicator pane
- Optional divergence labels and lines on the price chart
- Signal line for momentum smoothing
- Alerts for bullish divergence, bearish divergence, squeeze start, and squeeze release

Credit:
The original Squeeze Momentum Indicator was created by LazyBear. This version adds custom divergence logic, additional visual tools, and alert conditions while keeping proper attribution to the original author.

## Source Code

````pine
//@version=6
// -----------------------------------------------------------------------------
// Credits / Attribution
// This script is based on the open-source "Squeeze Momentum Indicator [LazyBear]"
// originally published by LazyBear on TradingView.
// Original script: https://www.tradingview.com/script/nqQ1DT5a-Squeeze-Momentum-Indicator-LazyBear/
//
// Original concept:
// - Squeeze detection using Bollinger Bands and Keltner Channels
// - Linear-regression momentum histogram
//
// My additions / modifications:
// - Converted and restructured the script for Pine Script v6
// - Added regular bullish and bearish divergence detection
// - Added hidden bullish and bearish divergence detection
// - Added divergence lines in the indicator pane
// - Added optional divergence labels/lines on the price chart
// - Added a signal line
// - Added alert conditions for divergences and squeeze states
//
// This publication credits the original author and is intended to follow
// TradingView's open-source reuse rules.
// -----------------------------------------------------------------------------
indicator("Squeeze Momentum V2 with Divergence", shorttitle="SQZ Divergence", overlay=false)

// --- Constants ---
color BULL_COLOR      = #089981
color BEAR_COLOR      = #f23645
color NEUTRAL_COLOR   = #5b9cf6
color SQZ_ON_COLOR    = #000000
color SQZ_OFF_COLOR   = #787b86
color NO_SQZ_COLOR    = #2196f3

// --- Inputs ---
groupSqz = "Squeeze Settings"
lengthBB    = input.int(20, "BB Length", minval=1, group=groupSqz)
multBB      = input.float(2.0, "BB MultFactor", minval=0.1, step=0.1, group=groupSqz)
lengthKC    = input.int(20, "KC Length", minval=1, group=groupSqz)
multKC      = input.float(1.5, "KC MultFactor", minval=0.1, step=0.1, group=groupSqz)
useTrueRange = input.bool(true, "Use TrueRange (KC)", group=groupSqz)

groupSignal = "Signal Settings"
signalPeriod = input.int(5, "Signal Length", minval=1, group=groupSignal)

groupDiv = "Divergence Settings"
showDiv         = input.bool(true, "Show Divergences in Pane", group=groupDiv)
showPriceDiv    = input.bool(true, "Show Divergences on Price Chart", group=groupDiv)
lookbackRight   = input.int(5, "Pivot Lookback Right", minval=1, group=groupDiv, tooltip="Number of bars to the right of a pivot")
lookbackLeft    = input.int(5, "Pivot Lookback Left", minval=1, group=groupDiv, tooltip="Number of bars to the left of a pivot")
rangeUpper      = input.int(60, "Max Lookback Range", minval=1, group=groupDiv, tooltip="Maximum bars to look back for divergence")
rangeLower      = input.int(5, "Min Lookback Range", minval=1, group=groupDiv, tooltip="Minimum bars to look back for divergence")

// --- Squeeze Logic ---
source = close

// BB
basis = ta.sma(source, lengthBB)
dev   = multBB * ta.stdev(source, lengthBB)
upperBB = basis + dev
lowerBB = basis - dev

// KC
ma      = ta.sma(source, lengthKC)
trRange = useTrueRange ? ta.tr : (high - low)
rangema = ta.sma(trRange, lengthKC)
upperKC = ma + rangema * multKC
lowerKC = ma - rangema * multKC

sqzOn  = (lowerBB > lowerKC) and (upperBB < upperKC)
sqzOff = (lowerBB < lowerKC) and (upperBB > upperKC)
noSqz  = not sqzOn and not sqzOff

// Momentum Value
highestHigh = ta.highest(high, lengthKC)
lowestLow   = ta.lowest(low, lengthKC)
avgValue    = math.avg(math.avg(highestHigh, lowestLow), ta.sma(close, lengthKC))
val         = ta.linreg(source - avgValue, lengthKC, 0)
sig         = ta.sma(val, signalPeriod)

// Colors
valColor = val > 0 ? (val > nz(val[1]) ? BULL_COLOR : color.new(BULL_COLOR, 50)) : (val < nz(val[1]) ? BEAR_COLOR : color.new(BEAR_COLOR, 50))
sqzColor = noSqz ? NO_SQZ_COLOR : sqzOn ? SQZ_ON_COLOR : SQZ_OFF_COLOR

// --- Divergence Detection ---
// Pivot Points
pTop = ta.pivothigh(val, lookbackLeft, lookbackRight)
pBot = ta.pivotlow(val, lookbackLeft, lookbackRight)

// Regular Bullish
bullDiv = false
if not na(pBot)
    for i = rangeLower to rangeUpper
        if not na(pBot[i]) and val[lookbackRight] > val[i + lookbackRight] and low[lookbackRight] < low[i + lookbackRight]
            bullDiv := true
            if showDiv
                line.new(bar_index[i + lookbackRight], val[i + lookbackRight], bar_index[lookbackRight], val[lookbackRight], color=BULL_COLOR, width=2)
            if showPriceDiv
                line.new(bar_index[i + lookbackRight], low[i + lookbackRight], bar_index[lookbackRight], low[lookbackRight], color=BULL_COLOR, width=2, force_overlay=true)
                label.new(bar_index[lookbackRight], low[lookbackRight], "Bull", color=color.new(BULL_COLOR, 100), textcolor=BULL_COLOR, style=label.style_label_up, size=size.small, force_overlay=true)
            break

// Regular Bearish
bearDiv = false
if not na(pTop)
    for i = rangeLower to rangeUpper
        if not na(pTop[i]) and val[lookbackRight] < val[i + lookbackRight] and high[lookbackRight] > high[i + lookbackRight]
            bearDiv := true
            if showDiv
                line.new(bar_index[i + lookbackRight], val[i + lookbackRight], bar_index[lookbackRight], val[lookbackRight], color=BEAR_COLOR, width=2)
            if showPriceDiv
                line.new(bar_index[i + lookbackRight], high[i + lookbackRight], bar_index[lookbackRight], high[lookbackRight], color=BEAR_COLOR, width=2, force_overlay=true)
                label.new(bar_index[lookbackRight], high[lookbackRight], "Bear", color=color.new(BEAR_COLOR, 100), textcolor=BEAR_COLOR, style=label.style_label_down, size=size.small, force_overlay=true)
            break

// Hidden Bullish
hiddenBullDiv = false
if not na(pBot)
    for i = rangeLower to rangeUpper
        if not na(pBot[i]) and val[lookbackRight] < val[i + lookbackRight] and low[lookbackRight] > low[i + lookbackRight]
            hiddenBullDiv := true
            if showPriceDiv
                label.new(bar_index[lookbackRight], low[lookbackRight], "H-Bull", color=color.new(BULL_COLOR, 100), textcolor=BULL_COLOR, style=label.style_label_up, size=size.tiny, force_overlay=true)
            break

// Hidden Bearish
hiddenBearDiv = false
if not na(pTop)
    for i = rangeLower to rangeUpper
        if not na(pTop[i]) and val[lookbackRight] > val[i + lookbackRight] and high[lookbackRight] < high[i + lookbackRight]
            hiddenBearDiv := true
            if showPriceDiv
                label.new(bar_index[lookbackRight], high[lookbackRight], "H-Bear", color=color.new(BEAR_COLOR, 100), textcolor=BEAR_COLOR, style=label.style_label_down, size=size.tiny, force_overlay=true)
            break

// --- Visuals ---
// Zero line and Squeeze dots
plot(0, "Squeeze Dots", sqzColor, 2, plot.style_cross)

// Main Histogram
pVal = plot(val, "Momentum", valColor, 2, plot.style_columns)
pZero = plot(0, "Zero Line", color.new(chart.fg_color, 80))

// Vertical Gradient Fill
fill(pVal, pZero, math.max(val, 0), math.min(val, 0), val > 0 ? BULL_COLOR : color.new(chart.bg_color, 100), val > 0 ? color.new(chart.bg_color, 100) : BEAR_COLOR)

// Signal Line
plot(sig, "Signal", color.new(chart.fg_color, 30), 1)

// Divergence Shapes in Indicator Pane
plotshape(showDiv and bullDiv ? val[lookbackRight] : na, "Bull Div", shape.labelup, location.absolute, BULL_COLOR, -lookbackRight, "Bull", chart.fg_color, size=size.tiny)
plotshape(showDiv and bearDiv ? val[lookbackRight] : na, "Bear Div", shape.labeldown, location.absolute, BEAR_COLOR, -lookbackRight, "Bear", chart.fg_color, size=size.tiny)
plotshape(showDiv and hiddenBullDiv ? val[lookbackRight] : na, "Hidden Bull", shape.diamond, location.absolute, BULL_COLOR, -lookbackRight, "H-Bull", chart.fg_color, size=size.tiny)
plotshape(showDiv and hiddenBearDiv ? val[lookbackRight] : na, "Hidden Bear", shape.diamond, location.absolute, BEAR_COLOR, -lookbackRight, "H-Bear", chart.fg_color, size=size.tiny)

// Alerts
alertcondition(bullDiv, "Regular Bullish Divergence", "Bullish divergence detected on SQZ")
alertcondition(bearDiv, "Regular Bearish Divergence", "Bearish divergence detected on SQZ")
alertcondition(sqzOn, "Squeeze Started", "BB has entered KC")
alertcondition(sqzOff, "Squeeze Released", "BB has exited KC")
````
