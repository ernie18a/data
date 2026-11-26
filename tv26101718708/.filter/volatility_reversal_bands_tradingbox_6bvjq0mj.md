# Volatility Reversal Bands [Trading_Box]

- url: https://www.tradingview.com/script/6BVjQ0mJ-Volatility-Reversal-Bands-Trading-Box/
- type: indicator
- pine_id: PUB;3180ead0db1d4633b1d74751bdb362e1
- version: 1.0

## Description

[b]Volatility Reversal Bands[/b]

Volatility Reversal Bands is a trend-following and volatility-based market analysis tool designed to help traders identify the current directional environment, visualize expanding volatility zones, and spot potential bullish or bearish reversal conditions.

The indicator combines a configurable moving-average trend foundation with standard-deviation volatility bands and ATR-based expansion zones. The result is a layered structure that provides a visual representation of trend direction, volatility expansion, and price extremes.

[b]Core Concept[/b]
The indicator begins with a configurable moving average applied to the selected price source. This foundation is further smoothed to create the Trend Basis, which acts as the central reference line.

Around this basis, the indicator builds multiple volatility layers using standard deviation and Average True Range (ATR). These layers progressively expand away from the Trend Basis, creating a structured view of normal volatility, expanded volatility, and more extreme price conditions.

[b]Trend System[/b]
The Trend System measures the rate of change of the Trend Basis relative to ATR.
The resulting trend strength is normalized against market volatility and classified into three 
general conditions:

[list=1]
[*]Bullish Trend — positive trend strength above the selected threshold. 
[*]Bearish Trend — negative trend strength below the selected threshold. 
[*]Neutral Trend — trend strength remains between the bullish and bearish thresholds.
[/list]

The Trend Basis is dynamically colored using a gradient between the selected bearish and bullish colors. This allows the line to visually transition through different levels of directional momentum instead of relying only on a fixed bullish/bearish color.

[b]Reversal Bands[/b]
The primary reversal bands are derived from the standard deviation of the selected source.
Upper Reversal Band — represents an elevated volatility area above the Trend Basis. Price interaction with this region can indicate an extended bullish move and an area where bearish reversal conditions may develop.

Lower Reversal Band — represents an elevated volatility area below the Trend Basis. Price interaction with this region can indicate an extended bearish move and an area where bullish reversal conditions may develop.

[b]ATR Expansion Zones[/b]
The indicator adds two additional ATR-based expansion layers outside the primary reversal bands.

These zones help visualize progressively stronger deviations from the Trend Basis:
Primary Band → Expansion Band → Extreme Band
The layered structure can be useful for identifying when price is moving deeper into a volatility expansion rather than remaining within its normal trading range.

[b]Reversal Signals[/b]
The indicator includes optional bullish and bearish reversal markers.
Bullish Reversal: 
1. The previous candle trades below the lower reversal band. 
2. The previous candle closes below its open. 
3. The current candle closes above its open.
Bearish Reversal: 
1. The previous candle trades above the upper reversal band. 
2. The previous candle closes above its open. 
3. The current candle closes below its open.
These signals are intended as confirmation tools, not standalone entry systems.

[b]Visual Interpretation[/b]
Trend Basis — shows the underlying smoothed directional structure.
Dynamic Gradient — provides a visual representation of changing trend strength.
Primary Reversal Bands — highlight areas of elevated deviation from the trend basis.
Expansion Bands — show increasing volatility expansion.
Extreme Bands — highlight more significant deviations from the central trend structure.
Reversal Markers — identify specific two-candle reversal conditions.

[b]Customization[/b]
The indicator provides separate controls for:
• Trend length 
• Moving-average type 
• Source • Trend smoothing 
• Trend threshold • Band sensitivity 
• ATR expansion length 
• ATR expansion multiplier 
• Bullish and bearish colors 
• Band visibility 
• Bar coloring 
• Bullish reversal signals 
• Bearish reversal signals

The moving-average engine supports SMA, EMA, SMMA (RMA), WMA, and VWMA.

[b]How Traders Can Use It[/b]
Volatility Reversal Bands can be used as a market-structure and confirmation tool alongside price action, trend analysis, support/resistance, momentum indicators, or other technical frameworks.

A common workflow is to first identify the broader directional environment using the Trend Basis and its gradient, then observe how price interacts with the volatility bands.
Example bullish workflow: Bullish Environment → Price reaches lower volatility zone → Bullish reversal confirmation
Example bearish workflow: Bearish Environment → Price reaches upper volatility zone → Bearish reversal confirmation
The bands can also be used to visually distinguish ordinary price movement from stronger volatility expansion.

[b]Important Note[/b]
Volatility Reversal Bands is a technical analysis tool and does not predict future price movements. Reversal signals represent predefined price and volatility conditions and should not be interpreted as guaranteed buy or sell recommendations.
Market conditions can change rapidly, and traders should consider risk management, market structure, liquidity, timeframe, and additional confirmation before making trading decisions.

## Source Code

````pine

//@version=6
indicator("Volatility Reversal Bands", overlay=true, max_labels_count=500)

groupTrend = "Trend System"
groupBands = "Reversal Bands"
groupVisual = "Visual Settings"
groupSignals = "Reversal Signals"

trendLength = input.int(34, "Trend Length", minval=1, group=groupTrend)
trendMaType = input.string("SMA", "Trend MA Type", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=groupTrend)
trendSource = input.source(close, "Trend Source", group=groupTrend)
trendSmoothLength = input.int(14, "Trend Smoothing", minval=1, group=groupTrend)
trendThreshold = input.float(1.0, "Trend Threshold", minval=0.0, step=0.1, group=groupTrend)

bandSensitivity = input.float(3.0, "Band Sensitivity", minval=0.001, maxval=50, step=0.1, group=groupBands)
bandAtrLength = input.int(30, "ATR Expansion Length", minval=1, group=groupBands)
bandAtrMultiplier = input.float(0.8, "ATR Expansion Multiplier", minval=0.0, step=0.1, group=groupBands)

bullColor = input.color(color.teal, "Bullish Color", group=groupVisual)
bearColor = input.color(color.red, "Bearish Color", group=groupVisual)
showBands = input.bool(true, "Show Reversal Bands", group=groupVisual)
showBarColors = input.bool(true, "Color Price Bars", group=groupVisual)

showSignals = input.bool(true, "Show Reversal Signals", group=groupSignals)
showBullishSignal = input.bool(true, "Show Bullish Signals", group=groupSignals)
showBearishSignal = input.bool(true, "Show Bearish Signals", group=groupSignals)


getMovingAverage(source, length, maType) =>
    switch maType
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)

baseMovingAverage = getMovingAverage(trendSource, trendLength, trendMaType)
trendBasis = ta.ema(baseMovingAverage, trendSmoothLength)

bandDeviation = bandSensitivity * ta.stdev(trendSource, trendLength)
upperBand = ta.ema(trendBasis + bandDeviation, trendSmoothLength)
lowerBand = ta.ema(trendBasis - bandDeviation, trendSmoothLength)
atrExpansion = ta.atr(bandAtrLength) * bandAtrMultiplier
upperBandOuter = upperBand + atrExpansion
lowerBandOuter = lowerBand - atrExpansion
upperBandExtreme = upperBandOuter + atrExpansion
lowerBandExtreme = lowerBandOuter - atrExpansion

trendAtr = ta.atr(14)
trendStrength = trendAtr != 0 ? (trendBasis - trendBasis[1]) / (0.1 * trendAtr) : 0.0
isBearishTrend = trendStrength < -trendThreshold
isBullishTrend = trendStrength > trendThreshold
isNeutralTrend = not isBullishTrend and not isBearishTrend

trendColor = color.from_gradient(trendStrength, -trendThreshold, trendThreshold, bearColor, bullColor)

plot(trendBasis, "Trend Basis", color=trendColor, linewidth=2)
upperPlot = plot(showBands ? upperBand : na, "Upper Reversal Band", color=color.new(bearColor, 75))
lowerPlot = plot(showBands ? lowerBand : na, "Lower Reversal Band", color=color.new(bullColor, 75))
upperOuterPlot = plot(showBands ? upperBandOuter : na, "Upper Expansion Band", color=color.new(bearColor, 60))
lowerOuterPlot = plot(showBands ? lowerBandOuter : na, "Lower Expansion Band", color=color.new(bullColor, 60))
upperExtremePlot = plot(showBands ? upperBandExtreme : na, "Upper Extreme Band", color=color.new(bearColor, 0))
lowerExtremePlot = plot(showBands ? lowerBandExtreme : na, "Lower Extreme Band", color=color.new(bullColor, 0))

fill(upperPlot, upperOuterPlot, color=color.new(bearColor, 90), title="Upper Inner Zone")
fill(lowerPlot, lowerOuterPlot, color=color.new(bullColor, 90), title="Lower Inner Zone")
fill(upperOuterPlot, upperExtremePlot, color=color.new(bearColor, 80), title="Upper Outer Zone")
fill(lowerOuterPlot, lowerExtremePlot, color=color.new(bullColor, 80), title="Lower Outer Zone")

bearishReversal = high[1] > upperBand[1] and close[1] > open[1] and close < open
bullishReversal = low[1] < lowerBand[1] and close[1] < open[1] and close > open

plotshape(showSignals and showBearishSignal and bearishReversal, "Bearish Reversal", shape.triangledown, location.abovebar, bearColor, size=size.tiny, editable=false)
plotshape(showSignals and showBullishSignal and bullishReversal, "Bullish Reversal", shape.triangleup, location.belowbar, bullColor, size=size.tiny, editable=false)

barcolor(showBarColors ? trendColor : na)

alertcondition(bullishReversal, "Bullish Reversal", "TrendFlow: Bullish reversal detected.")
alertcondition(bearishReversal, "Bearish Reversal", "TrendFlow: Bearish reversal detected.")
````
