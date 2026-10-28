# NQ 24hr High/Low from 18:00 EST

- url: https://www.tradingview.com/script/EyArI5io-NQ-24hr-High-Low-from-18-00-EST/
- type: indicator
- pine_id: PUB;e3da47488d5b4885854db83407371cb9
- version: 1.0

## Description

What This Script Does
This Pine Script creates 24-hour High and Low levels for NQ (Nasdaq 100 E-mini Futures), with the trading day defined as starting at 18:00 EST (when the evening futures session opens).
Instead of using the regular calendar day (midnight to midnight), it resets the high and low every day at 6:00 PM Eastern Time. This is a common way futures traders view the market, since NQ trades nearly 24 hours a day.
Key Features

Current Session Levels: It shows the highest high and lowest low reached since the most recent 18:00 EST. These levels update in real time as new price action comes in.
Historical Levels: It also draws the 24-hour High and Low from previous days. These historical lines are visible on the chart so you can see where price reacted in prior sessions.
No Extending Historical Lines: Unlike some scripts that draw lines all the way across the chart, this version draws each day’s High and Low only for the duration of that specific 24-hour period. The lines stop when the next session begins. This keeps the chart cleaner while still showing historical context.

Why Traders Use This
Many futures traders (especially day traders and swing traders) treat 18:00 EST as the start of the new trading day. This script helps them quickly see:

Where the high and low of the current 24-hour period are.
How price behaved relative to previous days’ highs and lows.
Key levels where the market may react (support/resistance) based on the prior 24-hour ranges.

In Simple Terms
Think of it as drawing a fresh “box” every day at 6:00 PM EST that shows the highest and lowest price reached during that 24-hour window. You can see both the current box (which is still moving) and all the previous boxes from earlier days.

## Source Code

````pine
//@version=6
indicator("NQ 24hr High/Low from 18:00 EST", shorttitle="NQ 24h H/L", overlay=true, max_lines_count=500)

// ─────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────
showHigh     = input.bool(true, "Show 24hr High")
showLow      = input.bool(true, "Show 24hr Low")
lineWidth    = input.int(2, "Line Width", minval=1, maxval=5)
highColor    = input.color(color.new(#00C853, 0), "24hr High Color")
lowColor     = input.color(color.new(#FF1744, 0), "24hr Low Color")

// ─────────────────────────────────────────────────────────────
// SESSION SETUP
// ─────────────────────────────────────────────────────────────
sessionStart = "1800-1800"
tz           = "America/New_York"

isNewSession = ta.change(time("D", sessionStart, tz)) != 0

// ─────────────────────────────────────────────────────────────
// STATE VARIABLES
// ─────────────────────────────────────────────────────────────
var float sessionHigh     = na
var float sessionLow      = na
var int   prevSessionStartBar = na
var float prevHigh        = na
var float prevLow         = na

// ─────────────────────────────────────────────────────────────
// SESSION LOGIC
// ─────────────────────────────────────────────────────────────
if isNewSession
    // Save previous session values before resetting
    prevHigh := sessionHigh
    prevLow  := sessionLow

    // Draw historical line for the previous session (stops at end of that session)
    if not na(prevHigh) and showHigh and not na(prevSessionStartBar)
        line.new(prevSessionStartBar, prevHigh, bar_index[1], prevHigh, 
                 color=highColor, width=lineWidth)

    if not na(prevLow) and showLow and not na(prevSessionStartBar)
        line.new(prevSessionStartBar, prevLow, bar_index[1], prevLow, 
                 color=lowColor, width=lineWidth)

    // Start new session
    sessionHigh := high
    sessionLow  := low
    prevSessionStartBar := bar_index

else
    // Update current session high/low
    sessionHigh := math.max(nz(sessionHigh, high), high)
    sessionLow  := math.min(nz(sessionLow, low), low)

// ─────────────────────────────────────────────────────────────
// CURRENT SESSION LINES (Real-time, extend to right)
// ─────────────────────────────────────────────────────────────
plot(sessionHigh, "Current 24hr High", color=highColor, linewidth=lineWidth)
plot(sessionLow,  "Current 24hr Low",  color=lowColor,  linewidth=lineWidth)
````
