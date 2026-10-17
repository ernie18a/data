# Zypheron  Session Highlighter

- url: https://www.tradingview.com/script/fLBB1zP7/
- type: indicator
- pine_id: PUB;f85e846d1cff47359a378d5f46113ed5
- version: 1.0

## Description

🌍 ZYPHERON – SESSION HIGHLIGHTER
Liquidity. Structure. Edge.

Automatically identifies and marks the three major trading sessions 
directly on your chart — clean, minimal and always accurate.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Asia, London & New York session start lines
✅ Session High & Low automatically locked at next session open
✅ Clean dashed H/L lines — no chart clutter
✅ Fully customizable colors and UTC times
✅ Works on all timeframes and instruments

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Each session is marked with a vertical line at its open.
The High and Low of each session are frozen the moment 
the next session begins — giving you clean liquidity levels 
to watch for the rest of the trading day.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ Start/End hours fully adjustable (UTC)
🎨 Custom colors per session
📏 Works best on 5min – 1H charts

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PART OF THE ZYPHERON SUITE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This is a free script. Follow for more tools built around 
Liquidity & Structure trading.

🔗 More scripts coming daily.

## Source Code

````pine
//@version=6
indicator("Zypheron – Session Highlighter", shorttitle="ZYPHERON SESSIONS", overlay=true, max_lines_count=500, max_labels_count=200)

// ═══════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════

var g_asia = "🌏 Asia Session"
showAsia  = input.bool(true, "Show Asia",        group=g_asia)
asiaStart = input.int(0,     "Start Hour (UTC)", group=g_asia, minval=0, maxval=23)
asiaEnd   = input.int(9,     "End Hour (UTC)",   group=g_asia, minval=0, maxval=23)
asiaColor = input.color(color.new(#FFD700, 0),   "Asia Color", group=g_asia)

var g_lon = "🇬🇧 London Session"
showLondon = input.bool(true, "Show London",      group=g_lon)
lonStart   = input.int(7,    "Start Hour (UTC)",  group=g_lon, minval=0, maxval=23)
lonEnd     = input.int(16,   "End Hour (UTC)",    group=g_lon, minval=0, maxval=23)
lonColor   = input.color(color.new(#4FC3F7, 0),   "London Color", group=g_lon)

var g_ny = "🗽 New York Session"
showNY   = input.bool(true, "Show New York",      group=g_ny)
nyStart  = input.int(13,    "Start Hour (UTC)",   group=g_ny, minval=0, maxval=23)
nyEnd    = input.int(22,    "End Hour (UTC)",      group=g_ny, minval=0, maxval=23)
nyColor  = input.color(color.new(#EF5350, 0),     "New York Color", group=g_ny)

lineWidth = input.int(2,   "Line Width",          minval=1, maxval=4)
hlExtend  = input.int(50,  "High/Low Line Extend (Bars)", minval=10, maxval=200)

// ═══════════════════════════════════════════════════════════
//  SESSION DETECTION
// ═══════════════════════════════════════════════════════════
barHour = hour(time, "UTC")

inSession(startH, endH) =>
    startH < endH ? barHour >= startH and barHour < endH : barHour >= startH or barHour < endH

inAsia   = inSession(asiaStart, asiaEnd)
inLondon = inSession(lonStart,  lonEnd)
inNY     = inSession(nyStart,   nyEnd)

asiaStarted  = inAsia   and not inAsia[1]
lonStarted   = inLondon and not inLondon[1]
nyStarted    = inNY     and not inNY[1]

// ═══════════════════════════════════════════════════════════
//  TRACK HIGH/LOW — einfrieren sobald nächste Session startet
// ═══════════════════════════════════════════════════════════
var float asiaH = na
var float asiaL = na
var float lonH  = na
var float lonL  = na
var float nyH   = na
var float nyL   = na

// Asia: nur tracken solange London noch nicht gestartet ist
if asiaStarted
    asiaH := high
    asiaL := low
if inAsia and not inLondon
    asiaH := math.max(asiaH, high)
    asiaL := math.min(asiaL, low)

// London: nur tracken solange NY noch nicht gestartet ist
if lonStarted
    lonH := high
    lonL := low
if inLondon and not inNY
    lonH := math.max(lonH, high)
    lonL := math.min(lonL, low)

// NY: tracken bis Session-Ende
if nyStarted
    nyH := high
    nyL := low
if inNY
    nyH := math.max(nyH, high)
    nyL := math.min(nyL, low)

// ═══════════════════════════════════════════════════════════
//  DRAW SESSION START LINES
// ═══════════════════════════════════════════════════════════
if showAsia and asiaStarted
    line.new(bar_index, low * 0.9999, bar_index, high * 1.0001,
         color=asiaColor, width=lineWidth, style=line.style_solid, extend=extend.both)
    label.new(bar_index, high, "ASIA",
         style=label.style_label_down, color=asiaColor, textcolor=color.black, size=size.small)

if showLondon and lonStarted
    line.new(bar_index, low * 0.9999, bar_index, high * 1.0001,
         color=lonColor, width=lineWidth, style=line.style_solid, extend=extend.both)
    label.new(bar_index, high, "LONDON",
         style=label.style_label_down, color=lonColor, textcolor=color.black, size=size.small)

if showNY and nyStarted
    line.new(bar_index, low * 0.9999, bar_index, high * 1.0001,
         color=nyColor, width=lineWidth, style=line.style_solid, extend=extend.both)
    label.new(bar_index, high, "NEW YORK",
         style=label.style_label_down, color=nyColor, textcolor=color.black, size=size.small)

// ═══════════════════════════════════════════════════════════
//  DRAW HH/LL — beim Start der nächsten Session
// ═══════════════════════════════════════════════════════════
var line asiaHLine = na
var line asiaLLine = na
var label asiaHLbl = na
var label asiaLLbl = na
var line lonHLine  = na
var line lonLLine  = na
var label lonHLbl  = na
var label lonLLbl  = na
var line nyHLine   = na
var line nyLLine   = na
var label nyHLbl   = na
var label nyLLbl   = na

// Asia HH/LL → zeichnen wenn London startet, löschen wenn Asia startet
if showAsia
    if lonStarted and not na(asiaH)
        if not na(asiaHLine)
            line.delete(asiaHLine)
        if not na(asiaLLine)
            line.delete(asiaLLine)
        if not na(asiaHLbl)
            label.delete(asiaHLbl)
        if not na(asiaLLbl)
            label.delete(asiaLLbl)
        asiaHLine := line.new(bar_index, asiaH, bar_index + hlExtend, asiaH, color=asiaColor, width=1, style=line.style_dashed)
        asiaLLine := line.new(bar_index, asiaL, bar_index + hlExtend, asiaL, color=asiaColor, width=1, style=line.style_dashed)
        asiaHLbl  := label.new(bar_index + hlExtend, asiaH, "Asia HH", style=label.style_label_left, color=color.new(asiaColor, 20), textcolor=color.black, size=size.tiny)
        asiaLLbl  := label.new(bar_index + hlExtend, asiaL, "Asia LL",  style=label.style_label_left, color=color.new(asiaColor, 20), textcolor=color.black, size=size.tiny)
    if asiaStarted
        if not na(asiaHLine)
            line.delete(asiaHLine)
        if not na(asiaLLine)
            line.delete(asiaLLine)
        if not na(asiaHLbl)
            label.delete(asiaHLbl)
        if not na(asiaLLbl)
            label.delete(asiaLLbl)

// London HH/LL → zeichnen wenn NY startet, löschen wenn London startet
if showLondon
    if nyStarted and not na(lonH)
        if not na(lonHLine)
            line.delete(lonHLine)
        if not na(lonLLine)
            line.delete(lonLLine)
        if not na(lonHLbl)
            label.delete(lonHLbl)
        if not na(lonLLbl)
            label.delete(lonLLbl)
        lonHLine := line.new(bar_index, lonH, bar_index + hlExtend, lonH, color=lonColor, width=1, style=line.style_dashed)
        lonLLine := line.new(bar_index, lonL, bar_index + hlExtend, lonL, color=lonColor, width=1, style=line.style_dashed)
        lonHLbl  := label.new(bar_index + hlExtend, lonH, "London HH", style=label.style_label_left, color=color.new(lonColor, 20), textcolor=color.black, size=size.tiny)
        lonLLbl  := label.new(bar_index + hlExtend, lonL, "London LL",  style=label.style_label_left, color=color.new(lonColor, 20), textcolor=color.black, size=size.tiny)
    if lonStarted
        if not na(lonHLine)
            line.delete(lonHLine)
        if not na(lonLLine)
            line.delete(lonLLine)
        if not na(lonHLbl)
            label.delete(lonHLbl)
        if not na(lonLLbl)
            label.delete(lonLLbl)

// NY HH/LL → zeichnen wenn nächster Asia startet, löschen wenn NY startet
if showNY
    if asiaStarted and not na(nyH)
        if not na(nyHLine)
            line.delete(nyHLine)
        if not na(nyLLine)
            line.delete(nyLLine)
        if not na(nyHLbl)
            label.delete(nyHLbl)
        if not na(nyLLbl)
            label.delete(nyLLbl)
        nyHLine := line.new(bar_index, nyH, bar_index + hlExtend, nyH, color=nyColor, width=1, style=line.style_dashed)
        nyLLine := line.new(bar_index, nyL, bar_index + hlExtend, nyL, color=nyColor, width=1, style=line.style_dashed)
        nyHLbl  := label.new(bar_index + hlExtend, nyH, "NY HH", style=label.style_label_left, color=color.new(nyColor, 20), textcolor=color.black, size=size.tiny)
        nyLLbl  := label.new(bar_index + hlExtend, nyL, "NY LL",  style=label.style_label_left, color=color.new(nyColor, 20), textcolor=color.black, size=size.tiny)
    if nyStarted
        if not na(nyHLine)
            line.delete(nyHLine)
        if not na(nyLLine)
            line.delete(nyLLine)
        if not na(nyHLbl)
            label.delete(nyHLbl)
        if not na(nyLLbl)
            label.delete(nyLLbl)

// ═══════════════════════════════════════════════════════════
//  INFO TABLE
// ═══════════════════════════════════════════════════════════
var table t = table.new(position.bottom_right, 2, 4,
     bgcolor=color.new(#0a0a0a, 60),
     border_color=color.new(#333333, 0),
     border_width=1, frame_color=color.new(#444444, 0), frame_width=1)

if barstate.islast
    table.cell(t, 0, 0, "ZYPHERON SESSIONS", text_color=color.white, text_size=size.small, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 1, 0, "UTC",               text_color=color.new(#00e676, 0), text_size=size.small, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 0, 1, "🌏 Asia",    text_color=asiaColor, text_size=size.tiny)
    table.cell(t, 1, 1, str.tostring(asiaStart) + ":00 – " + str.tostring(asiaEnd) + ":00", text_color=color.white, text_size=size.tiny)
    table.cell(t, 0, 2, "🇬🇧 London",  text_color=lonColor,  text_size=size.tiny)
    table.cell(t, 1, 2, str.tostring(lonStart)  + ":00 – " + str.tostring(lonEnd)  + ":00", text_color=color.white, text_size=size.tiny)
    table.cell(t, 0, 3, "🗽 New York", text_color=nyColor,   text_size=size.tiny)
    table.cell(t, 1, 3, str.tostring(nyStart)   + ":00 – " + str.tostring(nyEnd)   + ":00", text_color=color.white, text_size=size.tiny)
````
