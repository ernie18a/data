# 3 Candle Manipulation

- url: https://www.tradingview.com/script/ee2X40CI-3-Candle-Manipulation/
- type: indicator
- pine_id: PUB;58d5dce4ffa54d248ea935d4f0eb864b
- version: 2.0

## Description

3 CANDLE MANIPULATION

This indicator looks for:

GREEN → RED → GREEN
or
RED → GREEN → RED

The middle candle represents a temporary change in control.

The 3rd candle shows the original side taking control back.

GREEN → RED → GREEN
= Possible failed seller takeover
= Green arrow below Candle 3

RED → GREEN → RED
= Possible failed buyer takeover
= Red arrow above Candle 3

OPTIONAL VOLUME FILTER:

When ON:
Candle 3 must have higher volume than Candle 2.

When OFF:
Volume is ignored.

Simple idea:

Candle 2 = ATTEMPT
Candle 3 = REJECTION

The pattern can help identify possible traps, rejection, failed reversals, and quick shifts in market control.

## Source Code

````pine
//@version=6
indicator("3 CANDLE MANIPULATION", overlay=true)

//====================================================
// SETTINGS
//====================================================

requireC3HigherThanC2 = input.bool(
     true,
     "Require Candle 3 Volume > Candle 2",
     display=display.none
)

requireC3PercentHigherThanC1 = input.bool(
     false,
     "Require Candle 3 % Higher Volume Than Candle 1",
     display=display.none
)

c3PercentHigherThanC1 = input.float(
     50.0,
     "Candle 3 Volume % Higher Than Candle 1",
     minval=0.0,
     step=5.0,
     display=display.none
)

//====================================================
// CANDLE MAP
//
// Candle 1 = [2]
// Candle 2 = [1]
// Candle 3 = [0]
//====================================================

//====================================================
// CANDLE COLORS
//====================================================

candle1Green = close[2] > open[2]
candle1Red   = close[2] < open[2]

candle2Green = close[1] > open[1]
candle2Red   = close[1] < open[1]

candle3Green = close > open
candle3Red   = close < open

//====================================================
// 3-CANDLE PATTERNS
//====================================================

greenRedGreen =
     candle1Green and
     candle2Red and
     candle3Green

redGreenRed =
     candle1Red and
     candle2Green and
     candle3Red

//====================================================
// VOLUME FILTER #1
//
// Optional:
// Candle 3 volume must be higher than Candle 2.
//====================================================

c3HigherThanC2 =
     not requireC3HigherThanC2 or
     volume > volume[1]

//====================================================
// VOLUME FILTER #2
//
// Optional:
// Candle 3 must be X% higher volume than Candle 1.
//
// Example:
// Candle 1 = 1,000 volume
// Setting = 50%
// Candle 3 must be at least 1,500 volume.
//====================================================

requiredC3Volume =
     volume[2] *
     (1.0 + c3PercentHigherThanC1 / 100.0)

c3PercentCondition =
     not requireC3PercentHigherThanC1 or
     volume >= requiredC3Volume

//====================================================
// COMPLETE VOLUME CONDITION
//====================================================

volumeCondition =
     c3HigherThanC2 and
     c3PercentCondition

//====================================================
// FINAL SIGNALS
//====================================================

bullishSignal =
     greenRedGreen and
     volumeCondition and
     barstate.isconfirmed

bearishSignal =
     redGreenRed and
     volumeCondition and
     barstate.isconfirmed

//====================================================
// SIGNALS ON CANDLE 3
//====================================================

plotshape(
     bullishSignal,
     title="Bullish 3 Candle Manipulation",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.tiny
)

plotshape(
     bearishSignal,
     title="Bearish 3 Candle Manipulation",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny
)

//====================================================
// ALERTS
//====================================================

alertcondition(
     bullishSignal,
     title="Bullish 3 Candle Manipulation",
     message="Bullish GREEN-RED-GREEN 3 Candle Manipulation detected."
)

alertcondition(
     bearishSignal,
     title="Bearish 3 Candle Manipulation",
     message="Bearish RED-GREEN-RED 3 Candle Manipulation detected."
)
````
