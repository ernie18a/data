# EMA Reversal Squeeze K8E

- url: https://www.tradingview.com/script/v3eaNX52-EMA-Reversal-Squeeze-K8E/
- type: indicator
- pine_id: PUB;e2eed79399a74801a5b4537e1ca2c20f
- version: 2.0

## Description

EMA Reversal Squeeze K8E

The EMA Reversal Squeeze K8E is designed to identify potential momentum reversals by detecting a specific sequence of EMA compression and directional flipping.

Works on lower time frames only

The indicator monitors the 9 EMA, 20 EMA, and 50 EMA internally and looks for situations where the three averages come tightly together before reversing their order.

How LONG signals work

A LONG setup begins when:

EMA 9 < EMA 20 < EMA 50
All three EMAs are within 1 point of each other
The EMAs compress further to within 0.5 points
The EMA structure then flips to EMA 9 > EMA 20 > EMA 50
The final flip occurs while the EMAs remain within 1 point

The indicator then prints a LONG signal on the first qualifying candle.

How SHORT signals work

A SHORT setup is the exact opposite:

EMA 9 > EMA 20 > EMA 50
All three EMAs are within 1 point
The EMAs compress to within 0.5 points
The EMA structure flips to EMA 9 < EMA 20 < EMA 50
The final flip occurs while the EMAs remain within 1 point

The indicator then prints a SHORT signal on the first qualifying candle.

Why the squeeze matters

The idea behind the setup is that when the 9, 20, and 50 EMAs become extremely compressed, the market is showing a period of reduced separation between short-, medium-, and longer-term momentum.

When that compression is followed by a complete EMA order reversal, it can indicate that momentum is transitioning to the opposite direction.

The EMA lines are intentionally hidden from the chart so the indicator provides clean LONG and SHORT signals without clutter.

Note: This indicator is a technical analysis tool and should not be considered financial advice. Signals should be evaluated alongside price action, market structure, volatility, session levels, and your own risk-management rules.

## Source Code

````pine
//@version=6
indicator("EMA Reversal Squeeze K8E", overlay=true)

//====================================================
// INPUT
//====================================================
ema9Length  = input.int(9, "EMA 9 Length", minval=1)
ema20Length = input.int(20, "EMA 20 Length", minval=1)
ema50Length = input.int(50, "EMA 50 Length", minval=1)

outerDistance = input.float(1.0, "Maximum EMA Distance", minval=0.01, step=0.05)
tightDistance = input.float(0.5, "Tight Compression Distance", minval=0.01, step=0.05)

//====================================================
// EMAs
//====================================================
ema9  = ta.ema(close, ema9Length)
ema20 = ta.ema(close, ema20Length)
ema50 = ta.ema(close, ema50Length)

//====================================================
// EMA RANGE
// Measures the distance from the highest EMA
// to the lowest EMA
//====================================================
emaRange = math.max(ema9, math.max(ema20, ema50)) -
           math.min(ema9, math.min(ema20, ema50))

within1Point = emaRange <= outerDistance
withinHalfPoint = emaRange <= tightDistance

//====================================================
// EMA ALIGNMENTS
//====================================================

// Initial SHORT setup:
// EMA 9 > EMA 20 > EMA 50
bearishStack =
     ema9 > ema20 and
     ema20 > ema50

// Initial LONG setup:
// EMA 9 < EMA 20 < EMA 50
bullishStack =
     ema9 < ema20 and
     ema20 < ema50

//====================================================
// SETUP STATES
//====================================================
var bool shortSetup = false
var bool shortCompressed = false

var bool longSetup = false
var bool longCompressed = false

//====================================================
// INITIAL SHORT SETUP
// EMA 9 > EMA 20 > EMA 50
// AND all EMAs within 1 point
//====================================================
if bearishStack and within1Point
    shortSetup := true

//====================================================
// SHORT COMPRESSION
// Must tighten to within 0.5 points
//====================================================
if shortSetup and withinHalfPoint
    shortCompressed := true

//====================================================
// INITIAL LONG SETUP
// EMA 9 < EMA 20 < EMA 50
// AND all EMAs within 1 point
//====================================================
if bullishStack and within1Point
    longSetup := true

//====================================================
// LONG COMPRESSION
// Must tighten to within 0.5 points
//====================================================
if longSetup and withinHalfPoint
    longCompressed := true

//====================================================
// SHORT SIGNAL
//
// Initial:
// EMA 9 > EMA 20 > EMA 50
//
// Then:
// EMAs compress within 0.5
//
// Then:
// EMA 9 < EMA 20 < EMA 50
//
// Signal must occur while still within 1 point
//====================================================
shortSignal =
     shortSetup and
     shortCompressed and
     bullishStack and
     within1Point

//====================================================
// LONG SIGNAL
//
// Initial:
// EMA 9 < EMA 20 < EMA 50
//
// Then:
// EMAs compress within 0.5
//
// Then:
// EMA 9 > EMA 20 > EMA 50
//
// Signal must occur while still within 1 point
//====================================================
longSignal =
     longSetup and
     longCompressed and
     bearishStack and
     within1Point

//====================================================
// ONLY SIGNAL ON THE FIRST FLIP CANDLE
//====================================================
shortSignalOnce = shortSignal and not shortSignal[1]
longSignalOnce  = longSignal and not longSignal[1]

//====================================================
// RESET AFTER SIGNAL
//====================================================
if shortSignalOnce
    shortSetup := false
    shortCompressed := false
    longSetup := false
    longCompressed := false

if longSignalOnce
    longSetup := false
    longCompressed := false
    shortSetup := false
    shortCompressed := false

//====================================================
// CANCEL INCOMPLETE SETUPS
//====================================================
if shortSetup and not within1Point and not shortCompressed
    shortSetup := false

if longSetup and not within1Point and not longCompressed
    longSetup := false

//====================================================
// LONG / SHORT LABELS
//====================================================
plotshape(
     longSignalOnce,
     title="LONG",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="LONG",
     textcolor=color.white,
     size=size.small
)

plotshape(
     shortSignalOnce,
     title="SHORT",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SHORT",
     textcolor=color.white,
     size=size.small
)

//====================================================
// ALERTS
//====================================================
alertcondition(
     longSignalOnce,
     title="LONG Signal",
     message="LONG: EMA compression followed by bullish flip."
)

alertcondition(
     shortSignalOnce,
     title="SHORT Signal",
     message="SHORT: EMA compression followed by bearish flip."
)
````
