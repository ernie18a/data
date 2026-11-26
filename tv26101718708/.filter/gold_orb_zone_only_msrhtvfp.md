# Gold ORB Zone Only

- url: https://www.tradingview.com/script/mSrHtVFP-Gold-ORB-Zone-Only/
- type: indicator
- pine_id: PUB;93d89142f98f44e1a74c443943cb1320
- version: 2.0

## Description

The indicator is designed to serve as a liquidity and directional reference zone for XAU/USD traders. Instead of generating entries, it highlights the most important price range established during the first 15 minutes of the New York session, allowing traders to combine the zone with their own market structure concepts such as:

BOS (Break of Structure)
CHOCH (Change of Character)
Fair Value Gaps
Retests of the ORB boundaries
Summary

A clean, non-signaling Gold ORB indicator that marks the 8:30–8:45 AM New York opening range as a shaded zone and removes all unnecessary visual elements so traders can focus purely on price action and market structure.

## Source Code

````pine
//@version=6
indicator("Gold ORB Zone Only (6:30 AM PT)", overlay=true)

orbSession = input.session("0630-0645", "ORB Session")
tz = input.string("America/Los_Angeles", "Timezone")

inOrb = not na(time(timeframe.period, orbSession, tz))
newDay = ta.change(time("D")) != 0

var float orbHigh = na
var float orbLow = na

// Reset each day
if newDay
    orbHigh := na
    orbLow := na

// Build ORB range
if inOrb
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)

// Hidden boundaries
pHigh = plot(orbHigh, display=display.none)
pLow = plot(orbLow, display=display.none)

// Shaded ORB zone only
fill(pHigh, pLow)
````
