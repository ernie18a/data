# DDT Aggression

- url: https://www.tradingview.com/script/shDeqHWA-DDT-Aggression/
- type: indicator
- pine_id: PUB;e53a61e903b44ebdb0b21e8c578812a6
- version: 1.0

## Description

DDT Aggression

The DDT Aggression indicator is designed to highlight moments of abnormal market participation.

Most candles represent normal market activity. DDT Aggression focuses on the moments where participation becomes significantly larger than normal, often revealing areas where buyers or sellers are becoming unusually aggressive.

The purpose of the indicator is not to generate buy or sell signals.

Its purpose is to draw attention to areas that deserve a closer look.

Key Features

▪️ Identifies candles with abnormal participation.

▪️ Combines vector candle characteristics with extreme delta behavior.

▪️ Helps highlight areas where market participants become overly aggressive.

▪️ Works across all markets and timeframes.

▪️ Clean and minimal design with no unnecessary chart clutter.

How It Is Used

A DDT Aggression signal does not mean price will reverse.

A DDT Aggression signal simply means that something unusual happened.

The indicator is most powerful when combined with market context.

For example:

▪️ Aggression at a range low may indicate potential absorption.

▪️ Aggression at a range high may indicate potential distribution.

▪️ Aggression after a liquidity sweep may reveal trapped participants.

▪️ Aggression during a trend may confirm strong continuation.

The signal itself is not the trade.

The signal highlights a location that deserves attention.

Best Practices

▪️ Combine with market structure analysis.

▪️ Use alongside liquidity and range concepts.

▪️ Pay attention to aggression signals forming at key supply and demand zones.

▪️ Wait for confirmation before executing trades.

▪️ Focus on the location of the signal, not the signal itself.

The DDT Philosophy

Most indicators attempt to predict what will happen next.

DDT Aggression focuses on identifying moments where participation becomes abnormal.

It helps traders recognize areas where meaningful activity enters the market, allowing them to combine that information with structure, liquidity, and confirmation before making a decision.

The goal is not prediction.

The goal is understanding.

Process over outcome.

## Source Code

````pine
//@version=6
indicator("DDT Aggression", shorttitle="DDT Aggression", overlay=true, max_lines_count=500)

import TradingView/ta/8

// Settings
deltaLookback = input.int(50, "Delta Average Lookback", minval=10)
deltaMultiplier = input.float(4.0, "Extreme Delta Multiplier", minval=2.0, step=0.5)

markerOffset = input.float(0.08, "Marker Offset %", minval=0.01, maxval=1.0, step=0.01)
markerLength = input.float(0.12, "Marker Length %", minval=0.01, maxval=1.0, step=0.01)

// DDT Colors
ddtBull = color.rgb(26, 90, 255)
ddtBear = color.red

// Lower Timeframe Selection
var lowerTimeframe = switch
    timeframe.isseconds  => "1S"
    timeframe.isintraday => "1"
    timeframe.isdaily    => "5"
    => "60"

// Volume Delta
[openVolume, maxVolume, minVolume, lastVolume] = ta.requestVolumeDelta(lowerTimeframe)

// Separate Positive / Negative Delta Logic
positiveDelta = lastVolume > 0 ? lastVolume : 0.0
negativeDelta = lastVolume < 0 ? math.abs(lastVolume) : 0.0

positiveCount = lastVolume > 0 ? 1.0 : 0.0
negativeCount = lastVolume < 0 ? 1.0 : 0.0

sumPositiveDelta = math.sum(positiveDelta, deltaLookback)
sumNegativeDelta = math.sum(negativeDelta, deltaLookback)

sumPositiveCount = math.sum(positiveCount, deltaLookback)
sumNegativeCount = math.sum(negativeCount, deltaLookback)

avgPositiveDelta = sumPositiveDelta / math.max(sumPositiveCount, 1)
avgNegativeDelta = sumNegativeDelta / math.max(sumNegativeCount, 1)

isExtremeBullDelta = lastVolume > 0 and lastVolume >= avgPositiveDelta * deltaMultiplier
isExtremeBearDelta = lastVolume < 0 and math.abs(lastVolume) >= avgNegativeDelta * deltaMultiplier

// DDT Aggression Logic
isBullAggression = isExtremeBullDelta
isBearAggression = isExtremeBearDelta

offset = close * markerOffset / 100
length = close * markerLength / 100

// Vertical wick-extension markers
if isBullAggression
    line.new(
         x1=bar_index,
         y1=low - offset,
         x2=bar_index,
         y2=low - offset - length,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=ddtBull,
         width=2
     )

if isBearAggression
    line.new(
         x1=bar_index,
         y1=high + offset,
         x2=bar_index,
         y2=high + offset + length,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=ddtBear,
         width=2
     )

// Alerts
alertcondition(isBullAggression, title="DDT Bull Aggression", message="{{ticker}} DDT Bull Aggression on {{interval}}")
alertcondition(isBearAggression, title="DDT Bear Aggression", message="{{ticker}} DDT Bear Aggression on {{interval}}")
alertcondition(isBullAggression or isBearAggression, title="DDT Aggression", message="{{ticker}} DDT Aggression on {{interval}}")

// Volume Data Check
var cumVol = 0.0
cumVol += nz(volume)

if barstate.islast and cumVol == 0
    runtime.error("The data vendor doesn't provide volume data for this symbol.")
````
