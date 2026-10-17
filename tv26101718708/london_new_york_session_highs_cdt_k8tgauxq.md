# London & New York Session Highs (CDT)

- url: https://www.tradingview.com/script/K8tgaUXQ-London-New-York-Session-Highs-CDT/
- type: indicator
- pine_id: PUB;19ac595b449e42e39b6b9c3b13c8f0f3
- version: 1.0

## Description

London & New York Session Highs — Central Time

This indicator automatically identifies and marks the highs formed during the London and New York trading sessions, using Central Time (America/Chicago) as the reference timezone.

The script is designed to make important session highs easy to identify on the chart and can be useful for traders watching for liquidity levels, breakouts, sweeps, and intraday price reactions.

Features:

Automatically tracks the London session high.

Automatically tracks the New York session high.

Uses Central Time and automatically adjusts between CDT and CST.

London and New York highs are displayed with separate colors.

Session-high lines remain visible after the session ends.

Optional shaded backgrounds make the London and New York sessions easy to identify.

Session times and visual settings can be adjusted through the indicator inputs.

Default session times:

London: 2:00 AM – 5:00 AM Central Time

New York: 7:00 AM – 10:00 AM Central Time

The indicator is intended as a visual tool for identifying important intraday reference levels. It does not generate buy or sell signals and does not predict future price movement.

## Source Code

````pine
//@version=6
indicator("London & New York Session Highs (CDT)", overlay=true)

// ─────────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────────

string TZ = "America/Chicago"

// London session: 2:00 AM - 5:00 AM Central Time
string londonSession = input.session("0200-0500", "London Session")

// New York session: 7:00 AM - 10:00 AM Central Time
string newYorkSession = input.session("0700-1000", "New York Session")

showLondon = input.bool(true, "Show London High")
showNewYork = input.bool(true, "Show New York High")

londonColor = input.color(color.blue, "London High Color")
newYorkColor = input.color(color.red, "New York High Color")

lineWidth = input.int(2, "Line Width", minval=1, maxval=5)

// ─────────────────────────────────────────────
// SESSION DETECTION
// ─────────────────────────────────────────────

inLondon = not na(time(timeframe.period, londonSession, TZ))
inNewYork = not na(time(timeframe.period, newYorkSession, TZ))

// Detect the first candle of each session
newLondonSession = inLondon and not inLondon[1]
newNewYorkSession = inNewYork and not inNewYork[1]

// ─────────────────────────────────────────────
// LONDON HIGH
// ─────────────────────────────────────────────

var float londonHigh = na
var line londonLine = na

if newLondonSession
    londonHigh := high
    
    if showLondon
        londonLine := line.new(
             bar_index,
             londonHigh,
             bar_index,
             londonHigh,
             color=londonColor,
             width=lineWidth
         )

else if inLondon
    londonHigh := math.max(londonHigh, high)

    if showLondon and not na(londonLine)
        line.set_y1(londonLine, londonHigh)
        line.set_y2(londonLine, londonHigh)

// Extend London high after session ends
if showLondon and not na(londonLine)
    line.set_x2(londonLine, bar_index)

// ─────────────────────────────────────────────
// NEW YORK HIGH
// ─────────────────────────────────────────────

var float newYorkHigh = na
var line newYorkLine = na

if newNewYorkSession
    newYorkHigh := high
    
    if showNewYork
        newYorkLine := line.new(
             bar_index,
             newYorkHigh,
             bar_index,
             newYorkHigh,
             color=newYorkColor,
             width=lineWidth
         )

else if inNewYork
    newYorkHigh := math.max(newYorkHigh, high)

    if showNewYork and not na(newYorkLine)
        line.set_y1(newYorkLine, newYorkHigh)
        line.set_y2(newYorkLine, newYorkHigh)

// Extend New York high after session ends
if showNewYork and not na(newYorkLine)
    line.set_x2(newYorkLine, bar_index)

// ─────────────────────────────────────────────
// SESSION BACKGROUND
// ─────────────────────────────────────────────

bgcolor(inLondon ? color.new(londonColor, 92) : na)
bgcolor(inNewYork ? color.new(newYorkColor, 92) : na)
````
