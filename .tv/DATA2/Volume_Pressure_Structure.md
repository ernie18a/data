<!-- tradingview-pine-id: PUB;bd2e703b8e334c32a257506c67b97e91 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Pressure Structure

Source: https://www.tradingview.com/script/Tx2cgVyn-Volume-Pressure-Structure/

## Description

Volume Pressure Structure transforms traditional volume analysis into a visual framework for reading buyer and seller pressure.

The indicator combines relative volume, candle behavior, price structure, and volume expansion to highlight when market participation is strengthening and directional pressure is becoming more significant.

Key visual elements include:

Buy Pressure — highlights periods where bullish price behavior is supported by volume.
Sell Pressure — highlights periods where bearish price behavior is supported by volume.
Volume Expansion — identifies periods when participation increases significantly compared with average volume.
Market Structure — uses the broader price position to help distinguish bullish and bearish conditions.
BUY / SELL Signals — marks potential directional conditions when volume pressure and market structure align.

The result is a cleaner way to interpret volume beyond simply watching histogram bars. Instead of asking only “How much volume is there?”, the indicator helps visualize “Which side appears to be gaining pressure, and is that pressure supported by increased participation?”

Use the signals as a contextual tool alongside price action, market structure, and other forms of technical analysis. The indicator does not predict future price movement or guarantee trading outcomes.

---

## Source Code

````pine
//@version=6
indicator("Volume Pressure Structure", shorttitle="VPS", overlay=false, max_labels_count=500)

//──────────────────────────────────────────────────────────────────────────────
// INPUTS
//──────────────────────────────────────────────────────────────────────────────
groupVolume = "Volume Analysis"
volumeLength = input.int(20, "Volume Average Length", minval=5, group=groupVolume)
relativeVolumeThreshold = input.float(1.5, "High Volume Threshold", minval=1.0, step=0.1, group=groupVolume)

groupStructure = "Market Structure"
trendLength = input.int(50, "Trend EMA Length", minval=10, group=groupStructure)
pressureLength = input.int(5, "Pressure Smoothing", minval=1, group=groupStructure)

groupSignal = "Signal"
signalStrength = input.int(2, "Minimum Signal Strength", minval=1, maxval=3, group=groupSignal)
showSignals = input.bool(true, "Show BUY / SELL Signals", group=groupSignal)
showBackground = input.bool(true, "Show Pressure Background", group=groupSignal)

//──────────────────────────────────────────────────────────────────────────────
// VOLUME
//──────────────────────────────────────────────────────────────────────────────
volumeAverage = ta.sma(volume, volumeLength)
relativeVolume = volumeAverage > 0 ? volume / volumeAverage : 0.0

highVolume = relativeVolume >= relativeVolumeThreshold

//──────────────────────────────────────────────────────────────────────────────
// CANDLE PRESSURE
// Converts candle position/range into directional pressure.
// This is a price-based volume pressure proxy, not exchange order-flow delta.
//──────────────────────────────────────────────────────────────────────────────
candleRange = math.max(high - low, syminfo.mintick)
candlePosition = ((close - low) / candleRange) * 2.0 - 1.0

bodyPressure = close > open ? 1.0 : close < open ? -1.0 : 0.0

rawPressure = (candlePosition + bodyPressure) / 2.0
pressure = ta.ema(rawPressure, pressureLength)

// Volume-weighted directional pressure
volumePressure = pressure * relativeVolume

//──────────────────────────────────────────────────────────────────────────────
// TREND STRUCTURE
//──────────────────────────────────────────────────────────────────────────────
trendEMA = ta.ema(close, trendLength)

bullishStructure = close > trendEMA
bearishStructure = close < trendEMA

//──────────────────────────────────────────────────────────────────────────────
// PRESSURE STATES
//──────────────────────────────────────────────────────────────────────────────
strongBullPressure = volumePressure > 1.0
bullPressure = volumePressure > 0.0
bearPressure = volumePressure < 0.0
strongBearPressure = volumePressure < -1.0

//──────────────────────────────────────────────────────────────────────────────
// VOLUME EXPANSION
//──────────────────────────────────────────────────────────────────────────────
volumeExpansion = relativeVolume > relativeVolumeThreshold and
     relativeVolume > relativeVolume[1]

//──────────────────────────────────────────────────────────────────────────────
// SIGNAL STRENGTH
//──────────────────────────────────────────────────────────────────────────────
bullStrength = 0
bullStrength += bullishStructure ? 1 : 0
bullStrength += bullPressure ? 1 : 0
bullStrength += highVolume ? 1 : 0
bullStrength += volumeExpansion ? 1 : 0

bearStrength = 0
bearStrength += bearishStructure ? 1 : 0
bearStrength += bearPressure ? 1 : 0
bearStrength += highVolume ? 1 : 0
bearStrength += volumeExpansion ? 1 : 0

//──────────────────────────────────────────────────────────────────────────────
// SIGNAL CONDITIONS
//──────────────────────────────────────────────────────────────────────────────
buyCondition =
     bullStrength >= signalStrength and
     bullishStructure and
     bullPressure

sellCondition =
     bearStrength >= signalStrength and
     bearishStructure and
     bearPressure

buySignal = buyCondition and not buyCondition[1]
sellSignal = sellCondition and not sellCondition[1]

//──────────────────────────────────────────────────────────────────────────────
// VISUAL VOLUME
//──────────────────────────────────────────────────────────────────────────────
strongBuyColor = color.rgb(0, 200, 120)
buyColor = color.rgb(80, 170, 120)
strongSellColor = color.rgb(240, 70, 70)
sellColor = color.rgb(190, 100, 100)

volumeColor =
     strongBullPressure and highVolume ? strongBuyColor :
     bullPressure ? buyColor :
     strongBearPressure and highVolume ? strongSellColor :
     sellColor

plot(
     volume,
     title="Volume",
     style=plot.style_columns,
     color=volumeColor
)

// Volume average
plot(
     volumeAverage,
     title="Volume Average",
     color=color.new(color.white, 25),
     linewidth=2
)

//──────────────────────────────────────────────────────────────────────────────
// RELATIVE VOLUME PANEL
//──────────────────────────────────────────────────────────────────────────────
relativeVolumeDisplay = relativeVolume * volumeAverage

plot(
     relativeVolumeDisplay,
     title="Relative Volume",
     color=color.new(color.yellow, 70),
     linewidth=1,
     display=display.none
)

//──────────────────────────────────────────────────────────────────────────────
// SIGNAL BACKGROUND
//──────────────────────────────────────────────────────────────────────────────
backgroundColor =
     buyCondition ? color.new(strongBuyColor, 90) :
     sellCondition ? color.new(strongSellColor, 90) :
     na

bgcolor(showBackground ? backgroundColor : na)

//──────────────────────────────────────────────────────────────────────────────
// BUY / SELL LABELS
//──────────────────────────────────────────────────────────────────────────────
plotshape(
     showSignals and buySignal,
     title="BUY",
     style=shape.labelup,
     location=location.bottom,
     color=strongBuyColor,
     text="BUY",
     textcolor=color.white,
     size=size.small
)

plotshape(
     showSignals and sellSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.top,
     color=strongSellColor,
     text="SELL",
     textcolor=color.white,
     size=size.small
)

//──────────────────────────────────────────────────────────────────────────────
// ALERTS
//──────────────────────────────────────────────────────────────────────────────
alertcondition(
     buySignal,
     title="Volume Pressure BUY",
     message="Vertex Volume Pressure Structure: BUY pressure detected."
)

alertcondition(
     sellSignal,
     title="Volume Pressure SELL",
     message="Vertex Volume Pressure Structure: SELL pressure detected."
)
````
