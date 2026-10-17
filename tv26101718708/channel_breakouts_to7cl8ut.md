# Channel Breakouts

- url: https://www.tradingview.com/script/To7cL8ut-Channel-Breakouts/
- type: indicator
- pine_id: PUB;64adf4d0354e43cdada408de576e1f30
- version: 1.0

## Description

[b]Channel Breakouts[/b]

[b]Overview[/b]

Channel Breakouts is a price-action analysis indicator designed to visualize dynamic support and resistance zones, assess directional market momentum, and highlight potential reversal opportunities.

The indicator uses confirmed pivot highs and lows to construct a step-based channel structure. An ATR-based trend detection system evaluates changes in the channel midpoint, while a continuous momentum gradient provides a visual representation of bullish and bearish pressure.

By combining market structure, volatility-adjusted trend analysis, and reversal markers, Channel Breakouts offers a unified framework for studying changing market conditions.

[b]Core Features[/b]

[list]
[*][b]Pivot-Based Channel Construction[/b] — Uses confirmed pivot highs and lows to define the upper and lower channel boundaries.
[*][b]Dynamic Channel Midpoint[/b] — Calculates a central reference from recent pivot levels to help visualize the evolving market structure.
[*][b]ATR-Based Trend Detection[/b] — Classifies channel direction as bullish, bearish, or sideways according to midpoint movement relative to ATR.
[*][b]Momentum Gradient Candle Coloring[/b] — Colors candles along a continuous bearish-to-bullish gradient based on normalized channel momentum.
[*][b]Visual Channel Zones[/b] — Displays shaded regions between the midpoint and channel boundaries for clearer structural analysis.
[*][b]Potential Reversal Markers[/b] — Identifies specific bullish and bearish candle-reversal conditions around the channel boundaries.
[*][b]Customizable Sensitivity[/b] — Adjust pivot lookback, ATR length, sideways threshold, momentum length, and gradient sensitivity.
[*][b]Configurable Color Scheme[/b] — Customize bullish, bearish, and sideways trend colors to suit your chart layout.
[/list]

[b]How It Works[/b]

[b]1. Pivot-Based Market Structure[/b]

The indicator identifies confirmed pivot highs and lows using the selected pivot lookback period. Recent pivot values are used to construct the upper channel, lower channel, and midpoint.

Because pivots require subsequent bars for confirmation, channel updates occur after the relevant pivot has been confirmed.

[b]2. ATR-Based Trend Classification[/b]

The change in the channel midpoint is compared with a configurable ATR-based threshold to classify market conditions.

[list]
[*][b]Bullish Trend:[/b] The midpoint rises beyond the positive ATR threshold.
[*][b]Bearish Trend:[/b] The midpoint falls beyond the negative ATR threshold.
[*][b]Sideways Conditions:[/b] Midpoint movement remains within the defined threshold.
[/list]

The midpoint line changes color according to this classification, helping traders distinguish directional movement from relatively flat conditions.

[b]3. Momentum Gradient[/b]

Channel midpoint movement is measured over the selected momentum period and normalized against ATR. The normalized value is then mapped to a continuous color gradient.

[list]
[*][b]Bullish Momentum:[/b] Candle colors shift toward the selected bullish color as positive momentum increases.
[*][b]Bearish Momentum:[/b] Candle colors shift toward the selected bearish color as negative momentum increases.
[*][b]Intermediate Momentum:[/b] Colors transition gradually between the bullish and bearish extremes.
[/list]

[b]4. Potential Reversal Conditions[/b]

The indicator marks specific two-candle reversal patterns involving the channel boundaries.

[list]
[*][b]Bearish Reversal:[/b] The previous candle closes bullish after trading above the upper channel, followed by a bearish candle.
[*][b]Bullish Reversal:[/b] The previous candle closes bearish after trading below the lower channel, followed by a bullish candle.
[/list]

These markers highlight potential reversal conditions, not confirmed changes in the prevailing trend.

[b]Settings Guide[/b]

[list]
[*][b]Pivot Lookback:[/b] Controls the left and right bar periods used to confirm pivot highs and lows. Higher values generally produce fewer, more widely spaced confirmed pivots.
[*][b]Enable Trend-Based Colors:[/b] Provides a trend-color setting; in the current code, this input is not connected to the candle-coloring calculation.
[*][b]ATR Length:[/b] Sets the ATR calculation period used for trend classification and momentum normalization.
[*][b]Sideways Threshold:[/b] Controls the ATR-based threshold for distinguishing directional midpoint movement from sideways conditions.
[*][b]Gradient Lookback:[/b] Reserved for gradient lookback configuration; this input is not currently used in the calculations.
[*][b]Momentum Length:[/b] Determines how many bars apart the channel midpoint values are compared.
[*][b]Gradient Sensitivity:[/b] Controls how quickly momentum values approach the bullish or bearish color extremes.
[*][b]Bullish, Bearish, and Sideways Colors:[/b] Customize the indicator's trend and momentum palette.
[/list]

[b]Suggested Usage[/b]

Channel Breakouts can be used to study market structure, identify areas of potential support and resistance, monitor directional momentum, and observe possible reversals near channel boundaries.

For additional confirmation, traders may combine the channel with price action, volume analysis, higher-timeframe trends, or other technical indicators.

[b]Important Notes[/b]

Pivot-based channels depend on confirmed historical price structure and may update as new pivots are confirmed. Reversal markers identify predefined candle conditions and do not guarantee a reversal or breakout.

The indicator is an analytical tool rather than a standalone trading system. Always evaluate market context and apply appropriate risk management.

[b]Disclaimer:[/b] For educational and informational purposes only. This indicator does not constitute financial or investment advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Trading_Box

//@version=6
indicator('Channel Breakouts', overlay = true)

groupChannel = 'Channel Settings'
groupTrend = 'Trend Detection'
groupGradient = 'Momentum Gradient'
groupColors = 'Color Settings'


pivotLookback = input.int(6, 'Pivot Lookback', minval = 1, group = groupChannel)
enableTrendColors = input.bool(true, 'Enable Trend-Based Colors', group = groupTrend)
atrPeriod = input.int(14, 'ATR Length', minval = 1, group = groupTrend)
sidewaysThreshold = input.float(0.2, 'Sideways Threshold (ATR)', minval = 0.01, step = 0.05, group = groupTrend)

gradientLookback = input.int(100, 'Gradient Lookback', minval = 10, group = groupGradient)
momentumPeriod = input.int(10, 'Momentum Length', minval = 1, group = groupGradient)
gradientSensitivity = input.float(2.0, 'Gradient Sensitivity', minval = 0.1, step = 0.1, group = groupGradient)

bullishColor = input.color(color.green, 'Bullish Color', group = groupColors)
bearishColor = input.color(color.red, 'Bearish Color', group = groupColors)
sidewaysColor = input.color(color.gray, 'Sideways Color', group = groupColors)

pivotHigh = ta.pivothigh(high, pivotLookback, pivotLookback)
pivotLow = ta.pivotlow(low, pivotLookback, pivotLookback)

var float pivotHigh1 = 0.0
var float pivotHigh2 = 0.0
var float pivotHigh3 = 0.0
var float pivotHigh4 = 0.0
var float pivotHigh5 = 0.0

var float pivotLow1 = 0.0
var float pivotLow2 = 0.0
var float pivotLow3 = 0.0
var float pivotLow4 = 0.0
var float pivotLow5 = 0.0

var float previousPivotHigh = 2.0
var float previousPivotLow = 0.0

if not na(pivotHigh)
    pivotHigh5 := pivotHigh4
    pivotHigh4 := pivotHigh3
    pivotHigh3 := pivotHigh2
    pivotHigh2 := pivotHigh1
    pivotHigh1 := pivotHigh
    previousPivotHigh := pivotHigh1
    previousPivotHigh

if not na(pivotLow)
    pivotLow5 := pivotLow4
    pivotLow4 := pivotLow3
    pivotLow3 := pivotLow2
    pivotLow2 := pivotLow1
    pivotLow1 := pivotLow
    previousPivotLow := pivotLow1
    previousPivotLow

channelHigh = math.max(pivotHigh2, pivotHigh1)
channelLow = math.min(pivotLow2, pivotLow1)
channelMidpoint = math.avg(pivotHigh2, pivotHigh1, pivotLow2, pivotLow1)

atrValue = ta.atr(atrPeriod)
midpointChange = channelMidpoint - channelMidpoint[1]
trendColor = midpointChange > atrValue * sidewaysThreshold ? bullishColor : midpointChange < -atrValue * sidewaysThreshold ? bearishColor : sidewaysColor

momentumValue = atrValue > 0 ? (channelMidpoint - channelMidpoint[momentumPeriod]) / atrValue : 0.0
normalizedMomentum = math.max(-1.0, math.min(1.0, momentumValue / gradientSensitivity))
momentumBarColor = color.from_gradient(normalizedMomentum, -1.0, 1.0, bearishColor, bullishColor)

barcolor(momentumBarColor)

midpointPlot = plot(channelMidpoint, title = 'Channel Midpoint', color = trendColor, style = plot.style_stepline)
upperChannelPlot = plot(channelHigh, title = 'Upper Channel', color = bearishColor, style = plot.style_stepline)
lowerChannelPlot = plot(channelLow, title = 'Lower Channel', color = bullishColor, style = plot.style_stepline)

fill(midpointPlot, lowerChannelPlot, channelMidpoint, channelLow / 100 * 95, chart.bg_color, color.new(bullishColor, 0), editable = false)
fill(midpointPlot, upperChannelPlot, channelMidpoint, channelHigh / 100 * 105, chart.bg_color, color.new(bearishColor, 0), editable = false)

bearishReversalSignal = high[1] > channelHigh[1] and close[1] > open[1] and close < open
bullishReversalSignal = low[1] < channelLow[1] and close[1] < open[1] and close > open
plotshape(bearishReversalSignal, title = 'Bearish Reversal', style = shape.triangledown, location = location.abovebar, color = bearishColor, size = size.tiny, editable = false)
plotshape(bullishReversalSignal, title = 'Bullish Reversal', style = shape.triangleup, location = location.belowbar, color = bullishColor, size = size.tiny, editable = false)
````
