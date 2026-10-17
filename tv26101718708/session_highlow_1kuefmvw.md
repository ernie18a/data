# Session High/Low 

- url: https://www.tradingview.com/script/1KueFMvw-Session-High-Low/
- type: indicator
- pine_id: PUB;af2296dd9c52475885f6f89b58e0e318
- version: 1.0

## Description

Session High/Low Indicator Description
This indicator for TradingView (Pine Script v6) automatically identifies and plots the highest and lowest price levels reached during specific trading sessions. It is designed to help traders visualize key liquidity zones and potential breakout levels throughout the trading day.

Key Features
Three Customizable Sessions:
Track up to three distinct trading periods (defaulted to Asia, London, and New York). You can toggle each session on or off individually.

Manual Timezone Input:
Instead of relying on hard-coded exchange times, you can manually enter your preferred timezone (e.g., UTC+2, Europe/Berlin, or America/New_York) directly in the settings. This ensures the lines align perfectly with your local chart time.

Flexible Time Ranges:
Start and end times for each session are fully adjustable using the HHMM format (e.g., 1530 for 15:30).

Dynamic Line Plotting:
The script detects the exact bar where a session high or low occurred and draws a horizontal line from that point, extending it forward for a user-defined number of candles.

Visual Customization:
Adjust the colors for each session and set a global line width to match your chart’s aesthetic.

How It Works
Monitoring: During the defined session window, the script continuously tracks the price.

Detection: It saves the highest high, the lowest low, and the specific bar indices where these extremes were reached.

Drawing: Once the session ends, the script deletes any temporary markers and draws the final, extended lines. This provides a clean look at the previous session's range, which often acts as support or resistance in subsequent sessions.

Typical Use Cases
Breakout Trading: Watching for price to break the previous Asia high or low during the London open.

Liquidity Sweeps: Identifying where stop-loss orders might be clustered at session extremes.

Daily Bias: Using the relationship between different session ranges to determine the market's trend direction.

## Source Code

````pine
//@version=6
indicator("Session High/Low", overlay=true, max_lines_count=50)

// ==========================================
// INPUTS: ALLGEMEIN
// ==========================================
grp_gen      = "Allgemeine Einstellungen"
lineLength   = input.int(500, "Linienlaenge (Kerzen)", minval=1, group=grp_gen)
lineWidth    = input.int(1, "Linienbreite (global)", minval=1, maxval=4, group=grp_gen)
timezone     = input.string("UTC+2", "Zeitzone (z.B. UTC+1, UTC+2, America/New_York)", group=grp_gen)

// ==========================================
// INPUTS: SESSION ZEITEN & FARBEN
// ==========================================
grp_asia     = "Asien Session"
showAsia     = input.bool(true, "Zeige Asien", group=grp_asia)
asiaStart    = input.string("0200", "Start (HHMM)", group=grp_asia)
asiaEnd      = input.string("0855", "Ende (HHMM)", group=grp_asia)
colorAsia    = input.color(color.red, "Farbe", group=grp_asia)

grp_london   = "London Session"
showLondon   = input.bool(true, "Zeige London", group=grp_london)
londonStart  = input.string("0900", "Start (HHMM)", group=grp_london)
londonEnd    = input.string("1400", "Ende (HHMM)", group=grp_london)
colorLondon  = input.color(color.blue, "Farbe", group=grp_london)

grp_ny       = "New York Session"
showNY       = input.bool(true, "Zeige New York", group=grp_ny)
nyStart      = input.string("1530", "Start (HHMM)", group=grp_ny)
nyEnd        = input.string("2300", "Ende (HHMM)", group=grp_ny)
colorNY      = input.color(color.orange, "Farbe", group=grp_ny)

// ==========================================
// FUNKTIONEN
// ==========================================
// Kombiniert Start und Ende für die time-Funktion
get_session_str(s, e) => s + "-" + e

in_session(s, e) => 
    not na(time(timeframe.period, get_session_str(s, e), timezone))

new_session(s, e) => 
    in_session(s, e) and not in_session(s, e)[1]

end_session(s, e) => 
    not in_session(s, e) and in_session(s, e)[1]

// ==========================================
// LOGIK: ASIEN
// ==========================================
var float asiaHigh         = na
var float asiaLow          = na
var int   asiaHighBarIndex = na
var int   asiaLowBarIndex  = na
var line  asiaHighLine     = na
var line  asiaLowLine      = na

if new_session(asiaStart, asiaEnd)
    asiaHigh         := high
    asiaLow          := low
    asiaHighBarIndex := bar_index
    asiaLowBarIndex  := bar_index
else if in_session(asiaStart, asiaEnd)
    if high > nz(asiaHigh, 0)
        asiaHigh         := high
        asiaHighBarIndex := bar_index
    if low < nz(asiaLow, 999999)
        asiaLow          := low
        asiaLowBarIndex  := bar_index

if end_session(asiaStart, asiaEnd) and showAsia
    line.delete(asiaHighLine)
    line.delete(asiaLowLine)
    asiaHighLine := line.new(asiaHighBarIndex, asiaHigh, asiaHighBarIndex + lineLength, asiaHigh, color=colorAsia, width=lineWidth)
    asiaLowLine  := line.new(asiaLowBarIndex, asiaLow, asiaLowBarIndex + lineLength, asiaLow, color=colorAsia, width=lineWidth)

// ==========================================
// LOGIK: LONDON
// ==========================================
var float londonHigh         = na
var float londonLow          = na
var int   londonHighBarIndex = na
var int   londonLowBarIndex  = na
var line  londonHighLine     = na
var line  londonLowLine      = na

if new_session(londonStart, londonEnd)
    londonHigh         := high
    londonLow          := low
    londonHighBarIndex := bar_index
    londonLowBarIndex  := bar_index
else if in_session(londonStart, londonEnd)
    if high > nz(londonHigh, 0)
        londonHigh         := high
        londonHighBarIndex := bar_index
    if low < nz(londonLow, 999999)
        londonLow          := low
        londonLowBarIndex  := bar_index

if end_session(londonStart, londonEnd) and showLondon
    line.delete(londonHighLine)
    line.delete(londonLowLine)
    londonHighLine := line.new(londonHighBarIndex, londonHigh, londonHighBarIndex + lineLength, londonHigh, color=colorLondon, width=lineWidth)
    londonLowLine  := line.new(londonLowBarIndex, londonLow, londonLowBarIndex + lineLength, londonLow, color=colorLondon, width=lineWidth)

// ==========================================
// LOGIK: NEW YORK
// ==========================================
var float nyHigh         = na
var float nyLow          = na
var int   nyHighBarIndex = na
var int   nyLowBarIndex  = na
var line  nyHighLine     = na
var line  nyLowLine      = na

if new_session(nyStart, nyEnd)
    nyHigh         := high
    nyLow          := low
    nyHighBarIndex := bar_index
    nyLowBarIndex  := bar_index
else if in_session(nyStart, nyEnd)
    if high > nz(nyHigh, 0)
        nyHigh         := high
        nyHighBarIndex := bar_index
    if low < nz(nyLow, 999999)
        nyLow          := low
        nyLowBarIndex  := bar_index

if end_session(nyStart, nyEnd) and showNY
    line.delete(nyHighLine)
    line.delete(nyLowLine)
    nyHighLine := line.new(nyHighBarIndex, nyHigh, nyHighBarIndex + lineLength, nyHigh, color=colorNY, width=lineWidth)
    nyLowLine  := line.new(nyLowBarIndex, nyLow, nyLowBarIndex + lineLength, nyLow, color=colorNY, width=lineWidth)
````
