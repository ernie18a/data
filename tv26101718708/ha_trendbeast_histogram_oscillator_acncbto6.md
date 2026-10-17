# HA TrendBeast Histogram Oscillator

- url: https://www.tradingview.com/script/ACNCBto6-HA-TrendBeast-Histogram-Oscillator/
- type: indicator
- pine_id: PUB;f661b4dd3b4f45cfa0ad6c13bf67b36d
- version: 1.0

## Description

[b]HA TrendBeast Histogram Oscillator[/b]

HA TrendBeast is a momentum oscillator built from a double-smoothed synthetic Heikin Ashi trend, classified into four distinct momentum states using a dedicated signal line — going beyond a simple directional histogram to show you not just where the trend is, but whether it's roaring or running out of breath.

[b]Calculation:[/b]

Raw open/close are smoothed using a selectable MA (RMA/EMA/SMA/WMA/HMA).
Smoothed prices are converted into synthetic Heikin Ashi open/close values to filter noise and reveal the underlying trend.
The HA values are smoothed a second time, producing lag-reduced trend values.
The histogram equals smoothed HA close minus smoothed HA open, plotted as oscillating columns around a zero line.
A signal line (SMA of the histogram) tracks the histogram's own momentum for confirmation.

[b]The TrendBeast difference — 4-state classification:[/b]

Instead of plain positive/negative coloring, each bar is classified by combining trend direction (above/below zero) with momentum relative to the signal line:

*Strong Bull (dark teal) — bullish trend, still accelerating
*Weakening Bull (light teal) — bullish trend starting to fade
*Strong Bear (dark red) — bearish trend, still accelerating
*Weakening Bear (light red) — bearish trend starting to fade

This lets you catch early signs of trend exhaustion instead of only reacting after a full reversal.

Alerts: zero-line trend flips (bullish/bearish) plus separate momentum-fading alerts when the histogram crosses its own signal line against the current trend direction.

Usage: Watch for color shifts from strong to weak shades as an early warning that a trend leg may be losing steam. Zero-line crosses mark potential trend changes; signal-line crosses within a trend mark momentum shifts. Best combined with price action or a trend filter rather than used as a standalone entry signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartTrader-X

//@version=6
indicator(title="Heikin Ashi TrendBeast", shorttitle="HA TrendBeast Histogram Oscillator", timeframe="", timeframe_gaps=true)

baseLength    = input.int(10, title="MA Length (Stage 1)")
refineLength  = input.int(10, title="MA Length (Stage 2)")
smoothMode    = input.string("EMA", title="MA Type", options=["RMA", "EMA", "SMA", "WMA", "HMA"])
trigLength    = input.int(5, title="Signal Line Length")

// ---- MA dispatcher, clamped to >= 0 ----
calcSmooth(src, length, mode) =>
    val = switch mode
        "RMA" => ta.rma(src, length)
        "EMA" => ta.ema(src, length)
        "SMA" => ta.sma(src, length)
        "WMA" => ta.wma(src, length)
        "HMA" => ta.hma(src, length)
        => ta.ema(src, length)
    math.max(val, 0.0)

// ---- Stage 1: smooth raw price ----
basePriceOpen  = calcSmooth(open,  baseLength, smoothMode)
basePriceClose = calcSmooth(close, baseLength, smoothMode)

synthClose = (basePriceOpen + basePriceClose) / 2
var float synthOpen = na
synthOpen := na(synthOpen[1]) ? (basePriceOpen + basePriceClose) / 2 : (synthOpen[1] + synthClose[1]) / 2

// ---- Stage 2: refine the synthetic HA values ----
refinedOpen  = calcSmooth(synthOpen,  refineLength, smoothMode)
refinedClose = calcSmooth(synthClose, refineLength, smoothMode)

// ---- Core histogram value ----
momentumBar = refinedClose - refinedOpen

// ---- Signal line: smoothed version of momentumBar, for crossover confirmation ----
trigLine = ta.sma(momentumBar, trigLength)

// ---- 4-state momentum classification ----
bullState       = momentumBar > 0
strongBullState = bullState and momentumBar > trigLine
weakBullState   = bullState and momentumBar <= trigLine
bearState       = momentumBar <= 0
strongBearState = bearState and momentumBar < trigLine
weakBearState   = bearState and momentumBar >= trigLine

barColor = strongBullState ? #009688 : weakBullState ? #80CBC4 : strongBearState ? #F44336 : #FFAB91

plot(momentumBar, "Smoothed HA Momentum", color=barColor, style=plot.style_columns)
plot(trigLine, "Signal", color=color.new(color.gray, 40), linewidth=1)

// ---- Alerts on state transitions ----
bullFading   = ta.crossunder(momentumBar, trigLine) and momentumBar > 0
bearFading   = ta.crossover(momentumBar, trigLine) and momentumBar < 0
flipToBull   = ta.crossover(momentumBar, 0)
flipToBear   = ta.crossunder(momentumBar, 0)

alertcondition(flipToBull, title="Trend flipped bullish", message="Smoothed HA Momentum crossed above zero")
alertcondition(flipToBear, title="Trend flipped bearish", message="Smoothed HA Momentum crossed below zero")
alertcondition(bullFading, title="Bullish momentum weakening", message="Bullish trend losing momentum vs signal line")
alertcondition(bearFading, title="Bearish momentum weakening", message="Bearish trend losing momentum vs signal line")
````
