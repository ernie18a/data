# Time Anchored VWAP

- url: https://www.tradingview.com/script/uNOi8L5c-Time-Anchored-VWAP/
- type: indicator
- pine_id: PUB;1725961f29a646818e87a621a42a8275
- version: 1.0

## Description

Custom Time Anchored VWAP resets VWAP every user-defined interval instead of once per session, allowing precise intraday fair value tracking across repeating market cycles. Includes optional standard deviation bands and customizable anchor timing for scalping, momentum, and session-based trading.

• Fully customizable VWAP reset interval
• Anchors VWAP every X minutes
• Built-in standard deviation bands
• Clean institutional-style visualization

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © seeyeahslater

//@version=6
indicator("Time Anchored VWAP", overlay=true)

//────────────────────
// INPUTS
//────────────────────
anchorMinutes = input.int(60, "Anchor Reset Every (Minutes)", minval=1)
showBands     = input.bool(true, "Show Standard Deviation Bands")
bandMult      = input.float(1.0, "Band Multiplier", step=0.1)

//────────────────────
// TIME RESET LOGIC
//────────────────────

// Current time in milliseconds
currTime = time

// Convert anchor minutes to milliseconds
anchorMs = anchorMinutes * 60 * 1000

// Detect new anchor period
newAnchor = math.floor(currTime / anchorMs) != math.floor(currTime[1] / anchorMs)

//────────────────────
// VWAP CALCULATION
//────────────────────

tp = hlc3

var float cumulativePV = na
var float cumulativeVol = na
var float cumulativeVar = na

if newAnchor
    cumulativePV  := tp * volume
    cumulativeVol := volume
    cumulativeVar := volume * math.pow(tp, 2)
else
    cumulativePV  += tp * volume
    cumulativeVol += volume
    cumulativeVar += volume * math.pow(tp, 2)

// VWAP
vwapValue = cumulativePV / cumulativeVol

// Weighted variance
variance = math.max((cumulativeVar / cumulativeVol) - math.pow(vwapValue, 2), 0)
stdev = math.sqrt(variance)

// Bands
upperBand = vwapValue + (stdev * bandMult)
lowerBand = vwapValue - (stdev * bandMult)

//────────────────────
// PLOTS
//────────────────────

plot(vwapValue,
     title="Anchored VWAP",
     color=color.white,
     linewidth=2)

plot(showBands ? upperBand : na,
     title="Upper Band",
     color=color.new(#00FFAA, 0),
     linewidth=1)

plot(showBands ? lowerBand : na,
     title="Lower Band",
     color=color.new(#FF3B3B, 0),
     linewidth=1)

// Fill between bands
fill(
     plot(showBands ? upperBand : na, display=display.none),
     plot(showBands ? lowerBand : na, display=display.none),
     color=color.new(color.gray, 92)
)

//────────────────────
// BACKGROUND MARKER
//────────────────────

bgcolor(newAnchor ? color.new(#E040FB, 92) : na)
````
