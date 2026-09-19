<!-- tradingview-pine-id: PUB;58d5dce4ffa54d248ea935d4f0eb864b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# 3 Candle Manipulation

Source: https://www.tradingview.com/script/ee2X40CI-3-Candle-Manipulation/

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

---

## Source Code

````pine
//@version=6
indicator("3 Candle Manipulation", shorttitle="3 Candle Manipulation", overlay=true)

//====================================================================
// SETTINGS
//====================================================================

groupVolume = "Volume Filter"

useVolumePreference = input.bool(
     true,
     "Require Candle 3 Higher Volume",
     group=groupVolume
     )

//====================================================================
// CANDLE COLORS
//====================================================================

// Current candle = Candle 3
// Previous candle = Candle 2
// Two candles back = Candle 1

candle1Green = close[2] > open[2]
candle1Red   = close[2] < open[2]

candle2Green = close[1] > open[1]
candle2Red   = close[1] < open[1]

candle3Green = close > open
candle3Red   = close < open

//====================================================================
// THREE-CANDLE PATTERNS
//====================================================================

// RED → GREEN → RED

redGreenRed =
     candle1Red and
     candle2Green and
     candle3Red

// GREEN → RED → GREEN

greenRedGreen =
     candle1Green and
     candle2Red and
     candle3Green

//====================================================================
// VOLUME CONDITION
//====================================================================

// If volume preference is ON:
// Candle 3 volume must be higher than Candle 2.
//
// If volume preference is OFF:
// Volume is ignored.

volumeCondition =
     not useVolumePreference or
     volume > volume[1]

//====================================================================
// FINAL SIGNALS
//====================================================================

// GREEN → RED → GREEN

greenSignal =
     barstate.isconfirmed and
     greenRedGreen and
     volumeCondition

// RED → GREEN → RED

redSignal =
     barstate.isconfirmed and
     redGreenRed and
     volumeCondition

//====================================================================
// GREEN ARROW
//====================================================================

// Candle 3 is green.
// Arrow BELOW Candle 3.

plotshape(
     greenSignal,
     title="Green Red Green",
     style=shape.arrowup,
     location=location.belowbar,
     color=color.lime,
     size=size.tiny
     )

//====================================================================
// RED ARROW
//====================================================================

// Candle 3 is red.
// Arrow ABOVE Candle 3.

plotshape(
     redSignal,
     title="Red Green Red",
     style=shape.arrowdown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny
     )

//====================================================================
// ALERTS
//====================================================================

alertcondition(
     greenSignal,
     title="Green Red Green",
     message="GREEN-RED-GREEN 3 Candle Manipulation pattern detected"
     )

alertcondition(
     redSignal,
     title="Red Green Red",
     message="RED-GREEN-RED 3 Candle Manipulation pattern detected"
     )
````
