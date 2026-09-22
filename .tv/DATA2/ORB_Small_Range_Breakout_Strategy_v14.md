<!-- tradingview-pine-id: PUB;f65cd7feae894e378b6d95d1f5727985 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ORB Small Range Breakout Strategy v1.4

Source: https://www.tradingview.com/script/BPqrxgtc-Gecko-ORB-Small-Range-Breakout-Strategy-v1-4/

## Description

**ORB Small Range Breakout Strategy**

This strategy trades breakouts of the opening range, but only when that range is small or medium relative to price — the idea being that a tight, low-volatility opening range has more room left to run than one that has already made a large move.

**How it works**

1. **Opening Range (ORB):** The script builds a high/low range over a configurable start and end time (default 08:00–08:25, exchange-local time). This window is fully configurable, so the script works on any market/session — LSE, JSE, or otherwise — without modification.
2. **Classification:** Once the opening range closes, its size is measured as a percentage of the opening price and classified as SMALL, MEDIUM, or LARGE based on two adjustable thresholds. Only SMALL and MEDIUM ranges are considered tradeable; LARGE ranges are skipped for that session.
3. **Entry:** Within a configurable entry window after the opening range closes (default cutoff 11:00), a long is triggered on a close above the range high, and a short on a close below the range low — one trade per session, first breakout only.
4. **Stop/Target:** The stop is placed at the opposite side of the opening range. Take-profit can be set to a fixed R-multiple, a projection of the opening range's size, or disabled entirely (stop-only).
5. **Session close:** Optionally, any open position is force-closed at a configurable time of day.

**Inputs**

- Opening Range start/end time
- Entry cutoff time
- SMALL/LARGE classification thresholds (%)
- Take-profit mode (R-multiple, ORB projection, or none) and multiplier
- Optional end-of-session exit time

**Notes**

- The opening range and entry window are drawn on the chart (box + lines) each session so you can visually verify what the strategy is reacting to.
- This script does not use repainting logic — all decisions are based on confirmed price action within the defined windows.
- Backtest results shown in the Strategy Tester do not account for slippage or commissions unless configured in the strategy properties; please set these to match your broker before drawing conclusions from the equity curve.
- This script is provided for educational and informational purposes only. Past performance, whether real or simulated, is not indicative of future results. Nothing here constitutes financial advice — always test thoroughly and understand the logic before using any strategy with real capital.

---

## Source Code

````pine
//@version=6
strategy("ORB Small Range Breakout Strategy v1.4", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500, pyramiding=0)

// Automatically resolves to the loaded symbol's own exchange timezone
// (Europe/London for LSE, Africa/Johannesburg for JSE, etc.)
tz = syminfo.timezone

// Inputs
smallThreshold = input.float(0.50, "Small ORB threshold %")
largeThreshold = input.float(1.00, "Large ORB threshold %")

orbStartHour   = input.int(8, "Opening Range Start Hour", minval=0, maxval=23, group="Opening Range")
orbStartMinute = input.int(0, "Opening Range Start Minute", minval=0, maxval=59, group="Opening Range")
orbEndHour     = input.int(8, "Opening Range End Hour", minval=0, maxval=23, group="Opening Range")
orbEndMinute   = input.int(25, "Opening Range End Minute", minval=0, maxval=59, group="Opening Range")

cutoffHour     = input.int(11, "Entry Cutoff Hour", minval=0, maxval=23, group="Entry Window")
cutoffMinute   = input.int(0, "Entry Cutoff Minute", minval=0, maxval=59, group="Entry Window")

tpMode = input.string("R Multiple", "Take Profit Mode", options=["R Multiple", "ORB Projection", "No TP"])
rMultiple = input.float(2.0, "R Multiple TP", step=0.25)
orbProjectionMult = input.float(2.0, "ORB Projection Multiplier", step=0.25)

useSessionExit = input.bool(true, "Close open trade at session time?")
exitHour = input.int(16, "Exit Hour (exchange local time)", minval=0, maxval=23)
exitMinute = input.int(0, "Exit Minute", minval=0, maxval=59)

// Exchange-local time, via syminfo.timezone
h = hour(time, tz)
m = minute(time, tz)

// --- Build TradingView session strings from the hour/minute inputs, e.g. "0800-0825" ---
pad2(n) =>
    n < 10 ? "0" + str.tostring(n) : str.tostring(n)

orbSessionStr    = pad2(orbStartHour) + pad2(orbStartMinute) + "-" + pad2(orbEndHour) + pad2(orbEndMinute)
entrySessionStr  = pad2(orbEndHour) + pad2(orbEndMinute) + "-" + pad2(cutoffHour) + pad2(cutoffMinute)

// time(...) returns the bar's timestamp when it falls inside the session, na otherwise.
// This is TradingView's own session engine, so it correctly handles any timeframe
// and doesn't rely on a bar landing on an exact minute.
isOrbBar   = not na(time(timeframe.period, orbSessionStr, tz))
isEntryBar = not na(time(timeframe.period, entrySessionStr, tz))

isFirstOrbBar = isOrbBar and not isOrbBar[1]   // transition INTO the ORB window
isDrawBar     = isOrbBar[1] and not isOrbBar   // transition OUT of the ORB window (ORB just finished)

// ORB state
var float orbHigh = na
var float orbLow = na
var float openingPrice = na
var int   orbStartBar = na
var bool  drawn = false
var bool  breakoutDone = false
var bool  orbIsSmall = false
var bool  orbIsTradeable = false
var float orbPercent = na
var bool  exitedToday = false

if isFirstOrbBar
    orbHigh := high
    orbLow := low
    openingPrice := open
    orbStartBar := bar_index
    drawn := false
    breakoutDone := false
    orbIsSmall := false
    orbIsTradeable := false
    orbPercent := na
    exitedToday := false

if isOrbBar
    orbHigh := math.max(orbHigh, high)
    orbLow := math.min(orbLow, low)

bgcolor(isOrbBar ? color.new(color.yellow, 85) : na)

// Draw/classify ORB
if isDrawBar and not na(orbHigh) and not na(orbLow)
    rangeSize = orbHigh - orbLow
    orbPercent := rangeSize / openingPrice * 100

    orbIsSmall := orbPercent < smallThreshold
    isLarge = orbPercent >= largeThreshold

    // SMALL and MEDIUM are tradeable, LARGE is rejected
    orbIsTradeable := not isLarge

    classification = orbIsSmall ? "SMALL" : isLarge ? "LARGE" : "MEDIUM"

    boxColour = orbIsSmall ? color.new(color.green, 70) : isLarge ? color.new(color.red, 70) : color.new(color.orange, 70)
    labelColour = orbIsSmall ? color.green : isLarge ? color.red : color.orange

    // Cosmetic estimate of how far to extend the ORB lines/box across the entry window
    entryDurationMinutes = (cutoffHour * 60 + cutoffMinute) - (orbEndHour * 60 + orbEndMinute)
    barsForEntryWindow = math.max(1, math.round(entryDurationMinutes / (timeframe.in_seconds() / 60)))
    orbLineEndBar = bar_index + barsForEntryWindow

    box.new(orbStartBar, orbHigh, bar_index, orbLow, bgcolor=boxColour, border_color=color.blue)
    line.new(orbStartBar, orbHigh, orbLineEndBar, orbHigh, width=2, color=color.blue)
    line.new(orbStartBar, orbLow, orbLineEndBar, orbLow, width=2, color=color.blue)

    labelText = "ORB"
    labelText += "\n" + str.tostring(orbPercent, "#.##") + "%"
    labelText += "\n" + classification
    labelText += "\nH " + str.tostring(orbHigh)
    labelText += "\nL " + str.tostring(orbLow)

    label.new(bar_index, orbHigh, labelText, style=label.style_label_down, color=labelColour, textcolor=color.white)

    drawn := true

// Entry conditions — inEntryWindow now comes directly from the configurable session
longBreakout  = drawn and orbIsTradeable and not breakoutDone and isEntryBar and close > orbHigh
shortBreakout = drawn and orbIsTradeable and not breakoutDone and isEntryBar and close < orbLow

orbRange = orbHigh - orbLow

if longBreakout
    longEntry = close
    longStop = orbLow
    longRisk = longEntry - longStop

    longTP = switch tpMode
        "R Multiple" => longEntry + longRisk * rMultiple
        "ORB Projection" => orbHigh + orbRange * orbProjectionMult
        => na

    strategy.entry("Long", strategy.long)

    if tpMode == "No TP"
        strategy.exit("Long Exit", "Long", stop=longStop)
    else
        strategy.exit("Long Exit", "Long", stop=longStop, limit=longTP)

    label.new(bar_index, low, "LONG\n" + str.tostring(close), style=label.style_label_up, color=color.green, textcolor=color.white)

    breakoutDone := true

if shortBreakout
    shortEntry = close
    shortStop = orbHigh
    shortRisk = shortStop - shortEntry

    shortTP = switch tpMode
        "R Multiple" => shortEntry - shortRisk * rMultiple
        "ORB Projection" => orbLow - orbRange * orbProjectionMult
        => na

    strategy.entry("Short", strategy.short)

    if tpMode == "No TP"
        strategy.exit("Short Exit", "Short", stop=shortStop)
    else
        strategy.exit("Short Exit", "Short", stop=shortStop, limit=shortTP)

    label.new(bar_index, high, "SHORT\n" + str.tostring(close), style=label.style_label_down, color=color.red, textcolor=color.white)

    breakoutDone := true

// Session exit — fires on/after the target time rather than only on an exact
// minute match, and only once per day, so it can't get skipped by a data gap
sessionExit = useSessionExit and not exitedToday and (h > exitHour or (h == exitHour and m >= exitMinute))

if sessionExit
    strategy.close_all(comment="Session Exit")
    exitedToday := true

// Visuals
plotshape(longBreakout, title="Long Breakout", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny)
plotshape(shortBreakout, title="Short Breakout", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)
````
