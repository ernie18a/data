# RSI Divergence Options Helper

- url: https://www.tradingview.com/script/i8ezYNC1-RSI-Divergence-Options-Helper/
- type: indicator
- pine_id: PUB;5b601fb8006f4e31a61c5a38a7358205
- version: 1.0

## Description

Bullish divergence: wait for the green signal, then enter on a confirmation candle or break of the short-term high.

Bearish divergence: wait for the red signal, then enter on a rejection candle or break of the short-term low.

Stop placement: put the stop just beyond the swing low for long trades or swing high for shorts.

Profit target: start with the nearest structure level, then trail or scale to 2R.

Good settings for you
SPY/QQQ/IWM: 1H script, 15M confirmation.

Mag 7: 1H script, 15M confirmation, fewer trades.

0DTE: use the 15M only for timing after the 1H signal.

7DTE to 30DTE: the 1H signal is usually the cleaner anchor.

Important note
This script is built on confirmed pivots, so signals appear after the swing is validated, which helps reduce false signals but means you will always get a delay.

For options, that delay is usually a good tradeoff because you want higher-confidence setups, not the earliest possible tick.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gringa507

//@version=6

plot(close)
//@version=6
indicator("RSI Divergence Options Helper", overlay=true, max_lines_count=300, max_labels_count=300)

// Inputs
rsiLen         = input.int(14, "RSI Length", minval=1)
leftBars       = input.int(5, "Pivot Left Bars", minval=1)
rightBars      = input.int(5, "Pivot Right Bars", minval=1)
minBarsApart   = input.int(5, "Min Bars Between Pivots", minval=1)
maxBarsApart   = input.int(80, "Max Bars Between Pivots", minval=2)
useOBOSFilter  = input.bool(true, "Use Overbought/Oversold Filter")
rsiOB          = input.float(70, "RSI Overbought")
rsiOS          = input.float(30, "RSI Oversold")
showLabels     = input.bool(true, "Show Entry Labels")
showStops      = input.bool(true, "Show Stop Levels")
confirmMode    = input.bool(true, "Require Candle Confirmation")
confirmLookback = input.int(3, "Confirmation Lookback Bars", minval=1, maxval=10)

// RSI
rsi = ta.rsi(close, rsiLen)

// Price pivots
pLow  = ta.pivotlow(low, leftBars, rightBars)
pHigh = ta.pivothigh(high, leftBars, rightBars)

// State
var float prevPriceLow = na
var float prevRsiLow   = na
var int   prevLowBar   = na

var float prevPriceHigh = na
var float prevRsiHigh   = na
var int   prevHighBar   = na

bullSignal = false
bearSignal = false

// Bullish divergence
if not na(pLow)
    currBar   = bar_index - rightBars
    currPrice = low[rightBars]
    currRsi   = rsi[rightBars]

    if not na(prevPriceLow)
        barsBetween = currBar - prevLowBar
        bullDiv = currPrice < prevPriceLow and currRsi > prevRsiLow and barsBetween >= minBarsApart and barsBetween <= maxBarsApart
        rsiOk = not useOBOSFilter or (prevRsiLow < rsiOS or currRsi < rsiOS)

        if bullDiv and rsiOk
            bullSignal := true
            line.new(prevLowBar, prevPriceLow, currBar, currPrice, color=color.lime, width=2)
            if showLabels
                label.new(currBar, currPrice, "Bull Div", style=label.style_label_up, color=color.lime, textcolor=color.white)
            if showStops
                line.new(currBar, currPrice, currBar + 10, currPrice, color=color.new(color.red, 0), style=line.style_dashed, width=1)

    prevPriceLow := currPrice
    prevRsiLow   := currRsi
    prevLowBar   := currBar

// Bearish divergence
if not na(pHigh)
    currBar   = bar_index - rightBars
    currPrice = high[rightBars]
    currRsi   = rsi[rightBars]

    if not na(prevPriceHigh)
        barsBetween = currBar - prevHighBar
        bearDiv = currPrice > prevPriceHigh and currRsi < prevRsiHigh and barsBetween >= minBarsApart and barsBetween <= maxBarsApart
        rsiOk = not useOBOSFilter or (prevRsiHigh > rsiOB or currRsi > rsiOB)

        if bearDiv and rsiOk
            bearSignal := true
            line.new(prevHighBar, prevPriceHigh, currBar, currPrice, color=color.red, width=2)
            if showLabels
                label.new(currBar, currPrice, "Bear Div", style=label.style_label_down, color=color.red, textcolor=color.white)
            if showStops
                line.new(currBar, currPrice, currBar + 10, currPrice, color=color.new(color.lime, 0), style=line.style_dashed, width=1)

    prevPriceHigh := currPrice
    prevRsiHigh   := currRsi
    prevHighBar   := currBar

// Candle confirmation
bullConfirm = false
bearConfirm = false

bullConfirm := bullSignal and (not confirmMode or ta.lowest(close, confirmLookback) > ta.lowest(low, confirmLookback))
bearConfirm := bearSignal and (not confirmMode or ta.highest(close, confirmLookback) < ta.highest(high, confirmLookback))

plotshape(bullConfirm, title="Bull Entry", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="BUY")
plotshape(bearConfirm, title="Bear Entry", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL")

alertcondition(bullConfirm, title="Bullish Divergence Entry", message="Bullish RSI divergence entry on {{ticker}} {{interval}}")
alertcondition(bearConfirm, title="Bearish Divergence Entry", message="Bearish RSI divergence entry on {{ticker}} {{interval}}")
````
