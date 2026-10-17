# Moving Average High Low Breakout

- url: https://www.tradingview.com/script/pOKiDvrC-Moving-Average-High-Low-Breakout/
- type: indicator
- pine_id: PUB;baefdd573b7c4be79a180fbae18eaac3
- version: 1.0

## Description

[b]Moving Average High Low Breakout[/b]

[b]Overview[/b]
[image]https://www.tradingview.com/x/ZmoNbNnZ/[/image]

Moving Average High Low Breakout is an adaptive trend-analysis indicator designed to identify potential price breakouts using dynamically calculated moving-average ranges, trend filtering, and volatility-based confirmation.

The indicator combines an adaptive Simple Moving Average (SMA), rolling high-low boundaries, a broader trend reference, and volatility-adjusted signal conditions. Its gradient candle-coloring system provides an intuitive visual representation of price positioning and directional momentum.

By adapting its calculations to changing price behavior, Moving Average High Low Breakout helps traders analyze potential breakout opportunities while maintaining a clear view of the prevailing market structure.

[b]Features[/b]

[list]
[*][b]Adaptive Moving Average[/b] — Dynamically adjusts the moving-average calculation length according to the calculated price efficiency ratio.
[*][b]Dynamic High-Low Boundaries[/b] — Tracks the highest and lowest values of the adaptive moving average over the selected lookback period.
[*][b]Trend Filtering[/b] — Incorporates a longer-period moving average to help contextualize breakout conditions within the broader price trend.
[*][b]Volatility-Based Confirmation[/b] — Uses standard deviation and a configurable volatility factor to establish additional signal thresholds.
[*][b]Enhanced Breakout Conditions[/b] — Identifies potential bullish and bearish breakout events through price crossovers and volatility-adjusted filtering.
[*][b]Gradient Candle Coloring[/b] — Displays a continuous transition between bearish, neutral, and bullish colors according to the combined price-position and trend-strength calculations.
[*][b]Adjustable Gradient Smoothing[/b] — Uses EMA smoothing to create more gradual candle-color transitions.
[*][b]Dynamic Trend Fill[/b] — Highlights the relationship between price and the central trend reference with translucent bullish and bearish shading.
[*][b]Customizable Parameters[/b] — Offers control over the lookback period, trend moving average, sensitivity, volatility factor, filter strength, gradient smoothness, and color palette.
[/list]

[b]How It Works[/b]

[b]1. Adaptive Calculation[/b]

The indicator calculates a price efficiency ratio and uses it to determine an adaptive moving-average length. This length influences how the moving average responds to recent price changes.

[b]2. Dynamic Range Construction[/b]

The highest and lowest values of the adaptive moving average form the initial boundaries. These boundaries are then adjusted using the efficiency ratio, user-defined sensitivity, and the longer-term trend moving average.

[b]3. Breakout Detection[/b]

Potential signals are generated when price crosses the adjusted boundaries and satisfies the additional volatility-based threshold conditions.

[list]
[*][b]Bullish Signal:[/b] Triggered when the source crosses above the adjusted lower boundary and exceeds the required volatility-adjusted threshold.
[*][b]Bearish Signal:[/b] Triggered when the source crosses below the adjusted upper boundary and falls below the required volatility-adjusted threshold.
[/list]

[b]4. Momentum Gradient[/b]

The candle-coloring system combines the source's position within the adjusted range with its distance from the trend moving average, normalized by ATR.

[list]
[*][b]Bullish Momentum:[/b] Candles transition toward the selected bullish color as the combined gradient becomes more positive.
[*][b]Bearish Momentum:[/b] Candles transition toward the selected bearish color as the combined gradient becomes more negative.
[*][b]Neutral Conditions:[/b] Colors remain closer to the neutral shade when the combined gradient approaches zero.
[/list]

[b]5. Trend Visualization[/b]

The midpoint of the adjusted high and low boundaries serves as the central trend reference. A translucent fill distinguishes the price's position above or below this reference.

[b]Settings Guide[/b]

[list]
[*][b]Lookback Period:[/b] Sets the primary calculation period for the efficiency ratio and dynamic range.
[*][b]Source:[/b] Selects the price series used for calculations.
[*][b]Trend MA Length:[/b] Controls the period of the broader trend reference.
[*][b]Sensitivity:[/b] Adjusts the weighting between the adaptive range and the trend moving average.
[*][b]Volatility Factor:[/b] Controls the standard-deviation-based volatility threshold.
[*][b]Filter Strength:[/b] Adjusts the effective threshold applied to the breakout conditions. Higher values reduce the threshold and may allow more signals.
[*][b]Gradient Smoothness:[/b] Controls EMA smoothing of the candle-color gradient. Higher values generally produce slower color transitions.
[*][b]Bullish Color:[/b] Defines the color associated with positive gradient values.
[*][b]Bearish Color:[/b] Defines the color associated with negative gradient values.
[*][b]Neutral Color:[/b] Sets the transition color around neutral momentum.
[/list]

[b]Suggested Usage[/b]

Moving Average High Low Breakout can be used to study potential breakout conditions, changing directional pressure, and the relationship between price and its adaptive trend structure.

Traders may combine its signals with support and resistance, market structure, volume, or higher-timeframe trend analysis to obtain additional context before making trading decisions.

[b]Important Notes[/b]

This indicator uses price-based calculations and programmed threshold conditions. Its signals identify potential breakout events, not guaranteed continuation or reversal patterns. The indicator should be tested across relevant markets and timeframes before practical use.

[b]Disclaimer:[/b] For educational and informational purposes only. This indicator does not constitute financial or investment advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeuraAlgo

//@version=6
indicator('Moving Average High Low Breakout', overlay = true)

groupMain = "Main Settings"
// Parametrs
length = input.int(21, title = 'Lookback Period',group = groupMain)
src = input.source(close,"Source",group = groupMain)
trend_ma_length = input.int(50, title = 'Trend MA Length',group = groupMain)
sensitivity = input.float(0.5, title = 'Sensitivity', minval = 0.1, maxval = 1.0,group = groupMain)
volatility_factor = input.float(1.5, title = 'Volatility Factor', minval = 0.1, maxval = 3.0,group = groupMain)
filter_strength = input.int(2, title = 'Filter Strength', minval = 1, maxval = 10,group = groupMain)

groupGradient = "Bar Strength"

smoothness = input.int(5, "Gradient Smoothness",
     minval = 1, maxval = 20, group = groupGradient)

groupArt = "Art"
bullColor = input.color(#00dc78, "Bullish Color", group = groupArt)
bearColor = input.color(#ace5dc, "Bearish Color", group = groupArt)
neutralColor = input.color(color.gray, "Neutral Color", group = groupArt)

// Efficieny Ratio Calculation
change = math.abs(src - src[1])
volatility = math.sum(change, length)
efficiency_ratio = na(volatility) or volatility == 0 ? 0 : change / volatility

// Adaptive Length Calculation
adaptive_length = math.round(length * efficiency_ratio)
adaptive_length := math.max(adaptive_length, 1) // Ensure minimum length of 1

// Adaptive SMA Calculation
ama = ta.sma(src, adaptive_length)

// Dynamic High-Low Calculation
highestHigh = ta.highest(ama, length)
lowestLow = ta.lowest(ama, length)

// Trend Filter Calculation
trend_ma = ta.sma(src, trend_ma_length)

// Dynamic Weight System (AI-Inspired)
weight = efficiency_ratio * sensitivity + 1 - sensitivity
adjustedHigh = highestHigh * weight + trend_ma * (1 - weight)
adjustedLow = lowestLow * weight + trend_ma * (1 - weight)

// Volatility-Based Dynamic Thresholds
volatility_threshold = ta.stdev(src, adaptive_length) * volatility_factor

// Enhanced Signal Logic with Filter
buySignal = ta.crossover(src, adjustedLow) and src > adjustedLow + volatility_threshold / filter_strength
sellSignal = ta.crossunder(src, adjustedHigh) and src < adjustedHigh - volatility_threshold / filter_strength

trend = (adjustedHigh+adjustedLow)/2

// Normaliz adaptive range
rangeSize = math.max(adjustedHigh - adjustedLow, syminfo.mintick)
pricePosition = (src - adjustedLow) / rangeSize

// Trend strength
atrValue = math.max(ta.atr(14), syminfo.mintick)
trendStrength = (src - trend_ma) / atrValue

// Combined gradient value
rawGradient = math.max(-1.0, math.min(1.0,
     (pricePosition - 0.5) * 1.2 + trendStrength * 0.3))

// Smooth gradient using an adjustable EMA
smoothedGradient = ta.ema(rawGradient, smoothness)

// Red → Gray → Green
barGradient = smoothedGradient >= 0 ?
     color.from_gradient(smoothedGradient, 0.0, 1.0, neutralColor, bullColor) :
     color.from_gradient(smoothedGradient, -1.0, 0.0, bearColor, neutralColor)

// Apply candle colors
barcolor(barGradient, title = "Adaptive Gradient Bars")
t = plot(trend,display = display.none)
c = plot(close,display = display.none)


//────────────────────────────────────
// FILLS
//────────────────────────────────────
//fill(plot1, plot2, top_value, bottom_value, top_color, bottom_color, title, display, fillgaps, editable) → void
//────────────────────────────────────
// TREND FILL
//────────────────────────────────────

// Dynamic gradient fill
fillColor = smoothedGradient >= 0 ?
     color.from_gradient(smoothedGradient, 0.0, 1.0,
         color.new(neutralColor, 90), color.new(bullColor, 75)) :
     color.from_gradient(smoothedGradient, -1.0, 0.0,
         color.new(bearColor, 75), color.new(neutralColor, 90))

fill(
     t,
     c,
     trend,
     close,
     chart.bg_color,
     close< trend?color.new(bearColor,80):na,
     editable = false
)

fill(
     t,
     c,
     trend,
     close,
     chart.bg_color,
     close> trend?color.new(bullColor,80):na,
     editable = false
)

// Plot High, Low, and Trend MA
//plot(adjustedHigh, color = color.red, linewidth = 2, title = 'Adjusted High')
//plot(adjustedLow, color = color.green, linewidth = 2, title = 'Adjusted Low')
//plot(trend_ma, color = color.blue, linewidth = 2, title = 'Trend MA')

// Plot Enhanced Buy and Sell Signals
plotshape(buySignal, style = shape.xcross, color = #ffffff00, text = '▲', textcolor = color.new(bullColor, 0), size = size.tiny, location = location.belowbar)
plotshape(sellSignal, style = shape.xcross, color = #ffffff00, text = '▼', textcolor = color.new(bearColor, 0), size = size.tiny, location = location.abovebar)
````
