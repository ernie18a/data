# FALSE BREAK RECLAIM

- url: https://www.tradingview.com/script/5zEc0QPU-FALSE-BREAK-RECLAIM/
- type: indicator
- pine_id: PUB;4063a941bef3445fa6bfad5e9ec73a19
- version: 1.0

## Description

FALSE BREAK RECLAIM is a 4-candle pattern indicator designed to identify potential false breaks and level reclaims around a prior candle’s high or low.

For a bullish setup, Candle 2 closes below Candle 1’s low, Candle 3 closes back above that level, and Candle 4 trades back into or through Candle 1’s low but closes back above it. This suggests the downside break failed and the level was reclaimed.

For a bearish setup, Candle 2 closes above Candle 1’s high, Candle 3 closes back below that level, and Candle 4 trades back into or through Candle 1’s high but closes back below it. This suggests the upside break failed and the level was reclaimed.

The indicator can also use an optional volume confirmation filter, requiring Candle 3’s volume to be greater than Candle 1’s volume before a signal is allowed.
Signals are plotted back on Candle 1, marking the original level that was broken, reclaimed, and then rejected.

This indicator can be useful for spotting potential liquidity sweeps, failed breakouts, support/resistance reclaims, and reversal setups.

## Source Code

````pine
//@version=6
indicator(
     title="FALSE BREAK RECLAIM",
     shorttitle="FALSE BREAK RECLAIM",
     overlay=true
)

//====================================================================
// FALSE BREAK RECLAIM
//====================================================================
//
// EXACTLY 4 CONSECUTIVE CANDLES:
//
// Candle 1 = 3 bars ago
// Candle 2 = 2 bars ago
// Candle 3 = 1 bar ago
// Candle 4 = current candle
//
//====================================================================


//====================================================================
// SETTINGS
//====================================================================

//--------------------------------------------------------------------
// OPTIONAL VOLUME FILTER
//
// ON:
//
// Candle 3 volume MUST be greater than
// Candle 1 volume.
//
// OFF:
//
// Volume is ignored.
//--------------------------------------------------------------------

requireCandle3HigherVolume = input.bool(
     true,
     title="Require Candle 3 Volume > Candle 1",
     display=display.none
)


//--------------------------------------------------------------------
// MARKER DISTANCE
//--------------------------------------------------------------------

markerDistancePercent = input.float(
     defval=20.0,
     title="Marker Distance %",
     minval=0.0,
     maxval=500.0,
     step=5.0,
     display=display.none
)


//--------------------------------------------------------------------
// COLORS
//--------------------------------------------------------------------

bullishColor = input.color(
     defval=color.lime,
     title="Bullish Signal Color",
     display=display.none
)

bearishColor = input.color(
     defval=color.red,
     title="Bearish Signal Color",
     display=display.none
)


//====================================================================
// CANDLE MAPPING
//====================================================================
//
// Candle 1 = [3]
// Candle 2 = [2]
// Candle 3 = [1]
// Candle 4 = current candle
//
//====================================================================


//====================================================================
// CANDLE 1 DATA
//====================================================================

candle1High =
     high[3]

candle1Low =
     low[3]

candle1Range =
     candle1High -
     candle1Low

candle1Volume =
     volume[3]


//====================================================================
// CANDLE 2 DATA
//====================================================================

candle2Close =
     close[2]


//====================================================================
// CANDLE 3 DATA
//====================================================================

candle3Close =
     close[1]

candle3Volume =
     volume[1]


//====================================================================
// CANDLE 4 DATA
//====================================================================

candle4High =
     high

candle4Low =
     low

candle4Close =
     close


//====================================================================
// OPTIONAL VOLUME CONDITION
//====================================================================
//
// FILTER OFF:
//
// Always passes.
//
// FILTER ON:
//
// Candle 3 Volume > Candle 1 Volume
//
//====================================================================

volumeCondition =
     not requireCandle3HigherVolume or
     (
         not na(candle1Volume) and
         not na(candle3Volume) and
         candle3Volume > candle1Volume
     )


//====================================================================
// BULLISH FALSE BREAK RECLAIM
//====================================================================
//
// Candle 1 LOW creates the reference level.
//
// Candle 2:
// Must CLOSE BELOW Candle 1 LOW.
//
// Candle 3:
// Must CLOSE BACK ABOVE Candle 1 LOW.
//
// Candle 4:
// LOW must touch or trade below Candle 1 LOW.
//
// Candle 4:
// Must CLOSE BACK ABOVE Candle 1 LOW.
//
// OPTIONAL:
//
// Candle 3 Volume > Candle 1 Volume.
//
//====================================================================


//--------------------------------------------------------------------
// BULLISH RULE 1
//--------------------------------------------------------------------

candle2BullBreak =
     candle2Close <
     candle1Low


//--------------------------------------------------------------------
// BULLISH RULE 2
//--------------------------------------------------------------------

candle3BullReclaim =
     candle3Close >
     candle1Low


//--------------------------------------------------------------------
// BULLISH RULE 3
//--------------------------------------------------------------------

candle4BullTouches =
     candle4Low <=
     candle1Low


//--------------------------------------------------------------------
// BULLISH RULE 4
//--------------------------------------------------------------------

candle4BullClosesAbove =
     candle4Close >
     candle1Low


//====================================================================
// FINAL BULLISH SIGNAL
//====================================================================

bullishSignal =
     barstate.isconfirmed and
     candle2BullBreak and
     candle3BullReclaim and
     candle4BullTouches and
     candle4BullClosesAbove and
     volumeCondition


//====================================================================
// BEARISH FALSE BREAK RECLAIM
//====================================================================
//
// EXACT OPPOSITE:
//
// Candle 1 HIGH creates the reference level.
//
// Candle 2:
// Must CLOSE ABOVE Candle 1 HIGH.
//
// Candle 3:
// Must CLOSE BACK BELOW Candle 1 HIGH.
//
// Candle 4:
// HIGH must touch or trade above Candle 1 HIGH.
//
// Candle 4:
// Must CLOSE BACK BELOW Candle 1 HIGH.
//
// OPTIONAL:
//
// Candle 3 Volume > Candle 1 Volume.
//
//====================================================================


//--------------------------------------------------------------------
// BEARISH RULE 1
//--------------------------------------------------------------------

candle2BearBreak =
     candle2Close >
     candle1High


//--------------------------------------------------------------------
// BEARISH RULE 2
//--------------------------------------------------------------------

candle3BearReclaim =
     candle3Close <
     candle1High


//--------------------------------------------------------------------
// BEARISH RULE 3
//--------------------------------------------------------------------

candle4BearTouches =
     candle4High >=
     candle1High


//--------------------------------------------------------------------
// BEARISH RULE 4
//--------------------------------------------------------------------

candle4BearClosesBelow =
     candle4Close <
     candle1High


//====================================================================
// FINAL BEARISH SIGNAL
//====================================================================

bearishSignal =
     barstate.isconfirmed and
     candle2BearBreak and
     candle3BearReclaim and
     candle4BearTouches and
     candle4BearClosesBelow and
     volumeCondition


//====================================================================
// MARKER DISTANCE
//====================================================================

markerDistance =
     candle1Range *
     (
         markerDistancePercent /
         100.0
     )


//====================================================================
// BULLISH MARKER LOCATION
//====================================================================

bullishMarkerPrice =
     candle1Low -
     markerDistance


//====================================================================
// BEARISH MARKER LOCATION
//====================================================================

bearishMarkerPrice =
     candle1High +
     markerDistance


//====================================================================
// BULLISH ARROW
//
// Signal confirms on Candle 4.
//
// Arrow is placed BELOW Candle 1.
//
// Arrow points UP toward Candle 1.
//====================================================================

plotshape(
     series=bullishSignal ?
         bullishMarkerPrice :
         na,
     title="Bullish False Break Reclaim",
     style=shape.triangleup,
     location=location.absolute,
     offset=-3,
     color=bullishColor,
     size=size.tiny
)


//====================================================================
// BEARISH ARROW
//
// Signal confirms on Candle 4.
//
// Arrow is placed ABOVE Candle 1.
//
// Arrow points DOWN toward Candle 1.
//====================================================================

plotshape(
     series=bearishSignal ?
         bearishMarkerPrice :
         na,
     title="Bearish False Break Reclaim",
     style=shape.triangledown,
     location=location.absolute,
     offset=-3,
     color=bearishColor,
     size=size.tiny
)


//====================================================================
// ALERTS
//====================================================================

alertcondition(
     condition=bullishSignal,
     title="Bullish False Break Reclaim",
     message="Bullish False Break Reclaim: Candle 2 closed below Candle 1 low, Candle 3 reclaimed above it, Candle 4 touched Candle 1 low and closed back above it."
)

alertcondition(
     condition=bearishSignal,
     title="Bearish False Break Reclaim",
     message="Bearish False Break Reclaim: Candle 2 closed above Candle 1 high, Candle 3 reclaimed below it, Candle 4 touched Candle 1 high and closed back below it."
)
````
