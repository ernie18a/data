# VOLUME RECOVERY

- url: https://www.tradingview.com/script/guuvLJWj-VOLUME-RECOVERY/
- type: indicator
- pine_id: PUB;ea2719645383494eb1928941ccbb45c0
- version: 1.0

## Description

Absolutely — here’s the updated version with that added in naturally:

VOLUME RECOVERY is a 4-candle volume pattern designed to highlight moments when market participation fades and then returns with strength.

The setup begins with Candle 1 as the reference volume. Candles 2 and 3 must both print lower volume than Candle 1, showing a temporary drop in activity. Candle 4 then confirms the recovery by printing higher volume than both Candle 3 and Candle 1.

When the pattern is confirmed, the signal is plotted back on Candle 1:

Green Candle 1: bullish marker below the candle
Red Candle 1: bearish marker above the candle

An optional Same Color setting can require Candle 1 and Candle 4 to match direction, helping filter for cleaner continuation-style setups.

This indicator is great for getting extra insight into possible market direction by showing where volume contracts, resets, and then returns with stronger participation. It can help highlight areas where buyers or sellers may be regaining control and where directional momentum may be building.

## Source Code

````pine
//@version=6
indicator("VOLUME RECOVERY", shorttitle="VOL RECOVERY", overlay=true)

//====================================================
// SETTINGS
//====================================================

requireSameColor = input.bool(
     false,
     "Require Candle 1 & Candle 4 Same Color",
     display=display.none
)

//====================================================
// CANDLE MAP
//
// Candle 1 = [3]
// Candle 2 = [2]
// Candle 3 = [1]
// Candle 4 = [0]
//====================================================

//====================================================
// VOLUME CONDITIONS
//====================================================

// Candle 2 volume must be lower than Candle 1
candle2LowerThan1 =
     volume[2] < volume[3]

// Candle 3 volume must be lower than Candle 1
candle3LowerThan1 =
     volume[1] < volume[3]

// Candle 4 volume must be higher than Candle 3
candle4HigherThan3 =
     volume > volume[1]

// Candle 4 volume must be higher than Candle 1
candle4HigherThan1 =
     volume > volume[3]

//====================================================
// CANDLE COLORS
//====================================================

// Candle 1
candle1Green =
     close[3] > open[3]

candle1Red =
     close[3] < open[3]

// Candle 4
candle4Green =
     close > open

candle4Red =
     close < open

//====================================================
// SAME COLOR CONDITION
//
// If setting is OFF:
// Candle colors do not matter.
//
// If setting is ON:
// Green C1 requires Green C4.
// Red C1 requires Red C4.
//====================================================

sameColor =
     (candle1Green and candle4Green) or
     (candle1Red and candle4Red)

colorCondition =
     not requireSameColor or sameColor

//====================================================
// COMPLETE VOLUME RECOVERY PATTERN
//====================================================

volumeRecoveryPattern =
     candle2LowerThan1 and
     candle3LowerThan1 and
     candle4HigherThan3 and
     candle4HigherThan1 and
     colorCondition

//====================================================
// CONFIRMED SIGNALS
//
// Signal confirms when Candle 4 closes.
//====================================================

greenSignal =
     volumeRecoveryPattern and
     candle1Green and
     barstate.isconfirmed

redSignal =
     volumeRecoveryPattern and
     candle1Red and
     barstate.isconfirmed

//====================================================
// ARROWS ON CANDLE 1
//
// Green Candle 1 = arrow below.
//
// Red Candle 1 = arrow above.
//
// offset = -3 because detection completes
// when Candle 4 closes.
//====================================================

plotshape(
     greenSignal,
     title="Bullish Volume Recovery",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.tiny,
     offset=-3
)

plotshape(
     redSignal,
     title="Bearish Volume Recovery",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny,
     offset=-3
)

//====================================================
// ALERTS
//====================================================

alertcondition(
     greenSignal,
     title="Bullish Volume Recovery",
     message="Bullish Volume Recovery pattern detected."
)

alertcondition(
     redSignal,
     title="Bearish Volume Recovery",
     message="Bearish Volume Recovery pattern detected."
)
````
