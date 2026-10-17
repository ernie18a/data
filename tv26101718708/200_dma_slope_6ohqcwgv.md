# 200 DMA Slope %

- url: https://www.tradingview.com/script/6oHqCwgV-200-DMA-Slope/
- type: indicator
- pine_id: PUB;bda89e96336c48aab537c449caac60fc
- version: 1.0

## Description

[b]200 DMA Slope %[/b]

The [b]200 DMA Slope %[/b] indicator measures the [b]rate of change of the 200-day moving average[/b], helping traders identify whether long-term trend strength is [b]accelerating, flattening, or deteriorating[/b].

Instead of simply asking:

“Is price above or below the 200 DMA?”

This indicator answers the equally important question:

“Is the 200 DMA itself rising or falling?”

[b]How It Works[/b]

The indicator calculates the[b] percentage change in the 200-day moving average over a user-defined lookback period[/b].

Formula:

Slope % =
((200 DMA Today − 200 DMA X Bars Ago) ÷ 200 DMA X Bars Ago) × 100

A positive reading indicates a [b]rising long-term trend[/b], while a negative reading signals a declining trend.

[b]Default Settings[/b]
Moving Average Length: 200
Slope Lookback: 20 bars
Smoothing Length: 5

[b]Interpretation[/b]

[b]Above 0[/b]

The 200 DMA is rising
Long-term trend is strengthening

[b]Near 0[/b]

Trend is flattening
Potential transition or consolidation phase
[b]
Below 0[/b]

The 200 DMA is declining
Long-term trend may be weakening

[b]Suggested Use
[/b]
This indicator pairs especially well with a [b]Distance From 200 DMA indicator[/b].

Together they can help answer two critical questions:

How extended is price from the long-term trend?
Is the long-term trend strengthening or rolling over?

Examples:

Price far above 200 DMA + slope accelerating → strong momentum regime
Price extended but slope flattening → caution / possible exhaustion
Price below 200 DMA + negative slope → weaker long-term trend

This tool is designed to help traders better visualize [b]trend quality[/b], not just trend direction.

## Source Code

````pine
//@version=6
indicator("200 DMA Slope %", shorttitle="200DMA Slope", overlay=false)

// Inputs
maLength      = input.int(200, "Moving Average Length", minval=1)
slopeLookback = input.int(20, "Slope Lookback", minval=1)
maType        = input.string("SMA", "Moving Average Type", options=["SMA", "EMA"])

// Moving average
ma = maType == "SMA" ? ta.sma(close, maLength) : ta.ema(close, maLength)

// Slope as percent change over lookback period
slopePct = ((ma - ma[slopeLookback]) / ma[slopeLookback]) * 100

// Colors
slopeColor =
     slopePct > 0 ? color.new(color.lime, 0) :
     slopePct < 0 ? color.new(color.red, 0) :
     color.new(color.gray, 0)

// Plot
plot(slopePct, title="200 DMA Slope %", style=plot.style_columns, color=slopeColor, linewidth=2)

// Zero line
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)

// Optional smoothing
showSmoothed = input.bool(true, "Show Smoothed Signal")
smoothLength = input.int(5, "Smoothing Length", minval=1)

smoothedSlope = ta.sma(slopePct, smoothLength)

plot(showSmoothed ? smoothedSlope : na, title="Smoothed Slope", color=color.white, linewidth=2)
````
