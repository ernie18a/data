# Anchored VWAP Pro

- url: https://www.tradingview.com/script/FnthnPpW-Anchored-VWAP-Pro/
- type: indicator
- pine_id: PUB;23b5d6844d9c4421be8df058a85aead7
- version: 1.0

## Description

[b]#Anchored VWAP Pro[/b]
by: MasterTonyTA

[b]## What it does[/b]


VERY SIMPLE MARK TOPS MARK BOTTOMS- SUPPORT AND RESISTANCE SHOWN

ANCHORED VWAP SHOWS YOU IMPORTANT LEVELS TO KEEP AN EYE TO FLIP, REJECT, OR HOLD

Two anchored VWAPs (top and bottom) with **color memory** — each line stays colored while holding as S/R, turns gray when broken — plus **real-time triangles** marking every wick rejection at the top and bounce at the bottom. Anchors can be set manually via the date/time input in settings, or dragged directly on the chart for fast experimentation.

---

[b]## How it's calculated[/b]

**VWAP** (close-based, cumulative from anchor):

```
VWAP = Σ(close × volume) / Σ(volume)
```

Starts at the user-selected anchor bar and accumulates forward.

[b]**Color logic:**[/b]
- **Top VWAP** — red while `close < VWAP` (resistance holding), gray when `close > VWAP` (broken)
- **Bottom VWAP** — green while `close > VWAP` (support holding), gray when `close < VWAP` (broken)

[b]**Triangles** (wick-based, fires same bar):[/b]
- **🔻 Top Rejection** — `high ≥ Top VWAP` and `close < Top VWAP`
- **🔺 Bottom Bounce** — `low ≤ Bottom VWAP` and `close > Bottom VWAP`

---

[b]## How to trade with it[/b]

1. **Anchor the top** to a major swing high — the red line is dynamic resistance from that pivot.
2. **Anchor the bottom** to a major swing low — the green line is dynamic support from that pivot.
3. **Read the state:**
   - Red top + green bottom = price inside a dynamic channel, fade the edges
   - Top turns gray = resistance broken, look for retest as new support
   - Bottom turns gray = support broken, look for retest as new resistance
4. **Trade the triangles:**
   - 🔻 = short the rejection, stop above the wick
   - 🔺 = long the bounce, stop below the wick

Best anchors are pivots that already matter — major highs, major lows, capitulation candles. Drag the anchor to test different points; the right one is where price clearly respects the line.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MasterTonyTA
//@version=6
indicator('Anchored VWAP Pro', overlay = true)

// ============================================================================
//                === INPUTS ===
// ============================================================================

// --- TOP ANCHOR (resistance) ---
bool  showTop       = input.bool(true, "Show Top Anchor VWAP", group = "Top Anchor (Resistance)")
int   topAnchorTime = input.time(timestamp("2024-01-01"), "Anchor Date/Time", group = "Top Anchor (Resistance)")
color topHoldColor  = input.color(color.new(#ff0000, 0), "Color: Holding (price below)", group = "Top Anchor (Resistance)")
color topBreakColor = input.color(color.new(#888888, 0), "Color: Broken (price above)",  group = "Top Anchor (Resistance)")

// --- BOTTOM ANCHOR (support) ---
bool  showBot       = input.bool(true, "Show Bottom Anchor VWAP", group = "Bottom Anchor (Support)")
int   botAnchorTime = input.time(timestamp("2024-01-01"), "Anchor Date/Time", group = "Bottom Anchor (Support)")
color botHoldColor  = input.color(color.new(#00ff00, 0), "Color: Holding (price above)", group = "Bottom Anchor (Support)")
color botBreakColor = input.color(color.new(#888888, 0), "Color: Broken (price below)",  group = "Bottom Anchor (Support)")

// --- Display ---
int    lineWidth    = input.int(2, "Line Width", minval = 1, maxval = 5, group = "Display")
bool   showTriangles= input.bool(true, "Show Rejection/Bounce Triangles 🔺🔻", group = "Display")

// ============================================================================
//                === ANCHOR TIMESTAMPS ===
// ============================================================================


bool topActive = time >= topAnchorTime
bool botActive = time >= botAnchorTime

// ============================================================================
//                === VWAP CALCULATIONS (close-based) ===
// ============================================================================

// --- TOP ANCHOR VWAP ---
var float topSumPV  = 0.0
var float topSumV   = 0.0
var float topVWAP   = na

if topActive and not topActive[1]
    // First bar of anchor — initialize
    topSumPV := close * volume
    topSumV  := volume
else if topActive
    topSumPV += close * volume
    topSumV  += volume

if topActive and topSumV > 0
    topVWAP := topSumPV / topSumV

// --- BOTTOM ANCHOR VWAP ---
var float botSumPV  = 0.0
var float botSumV   = 0.0
var float botVWAP   = na

if botActive and not botActive[1]
    botSumPV := close * volume
    botSumV  := volume
else if botActive
    botSumPV += close * volume
    botSumV  += volume

if botActive and botSumV > 0
    botVWAP := botSumPV / botSumV

// ============================================================================
//                === COLOR LOGIC (state-based) ===
// ============================================================================

// Top anchor: red (holding) while price below, gray (broken) while above
color topColor = na(topVWAP) ? na : (close < topVWAP ? topHoldColor : topBreakColor)

// Bottom anchor: green (holding) while price above, gray (broken) while below
color botColor = na(botVWAP) ? na : (close > botVWAP ? botHoldColor : botBreakColor)

// ============================================================================
//                === PLOTS ===
// ============================================================================

plot(showTop and topActive ? topVWAP : na, title = "Top Anchor VWAP", color = topColor, linewidth = lineWidth, style = plot.style_line)
plot(showBot and botActive ? botVWAP : na, title = "Bottom Anchor VWAP", color = botColor, linewidth = lineWidth, style = plot.style_line)

// ============================================================================
//                === REJECTION / BOUNCE TRIANGLES ===
// ============================================================================

// TOP REJECTION: price wick touches/exceeds top VWAP from below, but closes back below
// Means: high >= topVWAP AND close < topVWAP AND close < open (red candle preferred but not required)
bool topRejection = showTriangles and showTop and topActive and not na(topVWAP) and high >= topVWAP and close < topVWAP and close < topVWAP[1]

// BOTTOM BOUNCE: price wick touches/goes below bottom VWAP from above, but closes back above
// Means: low <= botVWAP AND close > botVWAP
bool botBounce = showTriangles and showBot and botActive and not na(botVWAP) and low <= botVWAP and close > botVWAP and close > botVWAP[1]

// Plots (red down triangle at top rejection, green up triangle at bottom bounce)
plotshape(topRejection ? high : na, title = "🔻 Top Rejection", style = shape.triangledown, location = location.abovebar, color = color.new(#ff0000, 0), size = size.tiny)

plotshape(botBounce ? low : na, title = "🔺 Bottom Bounce", style = shape.triangleup, location = location.belowbar, color = color.new(#00ff00, 0), size = size.tiny)
````
