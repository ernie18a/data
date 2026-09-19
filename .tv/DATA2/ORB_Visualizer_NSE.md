<!-- tradingview-pine-id: PUB;ffafcea01b804dacbac4e9097969d982 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# ORB Visualizer NSE

Source: https://www.tradingview.com/script/vUHHSles-ORB-Visualizer-NSE/

## Description

ORB Visualizer — Opening Range Breakout for Indian Markets

A clean, non-repainting ORB indicator for Indian stocks on 15-minute charts. Automatically marks the opening range and signals first breakouts.

[h2]Overview[/h2]
This indicator identifies the Opening Range (first 15-min candle: 9:30–9:45 IST) and visualizes it with a shaded zone, extending high/low/mid lines, and breakout signal arrows.

[h2]Features[/h2]
• ORB Zone Box — shaded area marking the opening range
• ORB High / Low / Mid Lines — key intraday levels extending across the session
• BUY / SELL Signals — first breakout above ORB High (green ▲) or below ORB Low (red ▼)
• Info Table — real-time ORB High, Low, Mid, and Range values in the top-right corner
• Auto-Reset — ORB recalculates at the start of each new trading session

[h2]How to use[/h2]
1. Apply to any Indian stock (NSE/BSE) on a 15-minute timeframe
2. The ORB zone draws automatically between 9:30–9:45 IST
3. A green ▲ BUY signal fires when price closes above ORB High
4. A red ▼ SELL signal fires when price closes below ORB Low
5. Only the first breakout per direction is shown (no repeated signals)

[h2]Customizable Inputs[/h2]
• Session start/end hour and minute — adapt to any market hours
• Toggle ORB Mid Line, Labels, and Formation Background
• Full color customization for all ORB levels

[h2]Tips[/h2]
• Best on liquid stocks (NIFTY 50, BANK NIFTY constituents)
• ORB Mid line acts as an intraday pivot
• Combine with volume for higher-probability breakouts
• Non-repainting — signals only on confirmed candle closes

[h2]Technical[/h2]
• Pine Script v6 | Indicator (not a strategy)
• Timezone: Asia/Kolkata (IST)
• Default session: 9:15–15:15 IST

---

## Source Code

````pine
//@version=6
indicator("ORB Visualizer NSE", shorttitle="ORB NSE", overlay=true, max_boxes_count=50, max_lines_count=50, max_labels_count=50)

// ══════════════════════════════════════════
//  ORB VISUALIZER — Opening Range Breakout
//  Configurable ORB start time & duration
// ══════════════════════════════════════════

// === INPUTS — ORB Timing ===
orbStartHour    = input.int(9,      "ORB Start Hour (IST)",       minval=0, maxval=23, group="ORB Timing")
orbStartMinute  = input.int(30,     "ORB Start Minute (IST)",     minval=0, maxval=59, group="ORB Timing")
orbDurationMins = input.int(15,     "ORB Duration (minutes)",     minval=1, maxval=60,  group="ORB Timing")
sessionEndHour  = input.int(15,     "Session End Hour (IST)",     minval=0, maxval=23, group="ORB Timing")
sessionEndMinute= input.int(15,     "Session End Minute (IST)",   minval=0, maxval=59, group="ORB Timing")

// === INPUTS — Display ===
showMidLine     = input.bool(true,  "Show ORB Mid Line",          group="Display")
showLabels      = input.bool(true,  "Show Labels",                group="Display")
showBackground  = input.bool(true,  "Show ORB Formation BG",      group="Display")
orbZoneColor    = input.color(color.new(color.blue, 85),  "ORB Zone Color",   group="Colors")
orbHighColor    = input.color(color.green,                "ORB High Color",   group="Colors")
orbLowColor     = input.color(color.red,                  "ORB Low Color",    group="Colors")
orbMidColor     = input.color(color.new(color.yellow, 30), "ORB Mid Color",   group="Colors")

// === TIME FUNCTIONS (IST) ===
istHour(time_val)   => hour(time_val,   "Asia/Kolkata")
istMinute(time_val) => minute(time_val, "Asia/Kolkata")

// === ORB END TIME (calculated from start + duration) ===
orbEndMinuteTotal = orbStartHour * 60 + orbStartMinute + orbDurationMins
orbEndHourCalc    = orbEndMinuteTotal / 60
orbEndMinuteCalc  = orbEndMinuteTotal % 60

// === SESSION DETECTION ===
isNewSession = ta.change(time("D", "Asia/Kolkata")) != 0

// Check if current bar is within ORB formation window
currentMinuteTotal = istHour(time) * 60 + istMinute(time)
orbStartTotal      = orbStartHour * 60 + orbStartMinute
orbEndTotal        = orbEndHourCalc * 60 + orbEndMinuteCalc
sessionEndTotal    = sessionEndHour * 60 + sessionEndMinute

isOrbCandle  = currentMinuteTotal >= orbStartTotal and currentMinuteTotal < orbEndTotal
isOrbDone    = currentMinuteTotal == orbEndTotal
isInSession  = currentMinuteTotal >= orbStartTotal and currentMinuteTotal <= sessionEndTotal

// === ORB CALCULATION ===
var float orbHigh    = na
var float orbLow     = na
var float orbMid     = na
var bool  orbSet     = false
var int   orbBar     = na
var bool  tradedLong = false
var bool  tradedShort = false

// Reset ORB at start of each new trading day
if isNewSession
    orbHigh     := na
    orbLow      := na
    orbMid      := na
    orbSet      := false
    orbBar      := na
    tradedLong  := false
    tradedShort := false

// Track highest high and lowest low during ORB formation window
if isOrbCandle
    if na(orbHigh) or high > orbHigh
        orbHigh := high
    if na(orbLow) or low < orbLow
        orbLow  := low
    orbMid  := (orbHigh + orbLow) / 2
    orbBar  := bar_index

// Lock ORB when formation window ends
if isOrbDone and not orbSet
    orbSet := true
    orbMid := (orbHigh + orbLow) / 2

// === DRAWING ===
var box   orbBox       = na
var line  orbHighLine  = na
var line  orbLowLine   = na
var line  orbMidLine   = na
var label orbHighLabel = na
var label orbLowLabel  = na
var label orbMidLabel  = na

// Draw ORB zone box when ORB is locked
if orbSet and isOrbDone
    orbBox      := box.new(bar_index, orbHigh, bar_index + 1, orbLow, border_color=color(na), bgcolor=orbZoneColor)
    orbHighLine := line.new(bar_index, orbHigh, bar_index + 1, orbHigh, color=orbHighColor, width=1)
    orbLowLine  := line.new(bar_index, orbLow,  bar_index + 1, orbLow,  color=orbLowColor,  width=1)
    if showMidLine
        orbMidLine := line.new(bar_index, orbMid, bar_index + 1, orbMid, color=orbMidColor, width=1, style=line.style_dashed)

// Extend ORB lines and box to the right each bar during session
if orbSet and isInSession and not isOrbDone
    box.set_right(orbBox, bar_index + 5)
    line.set_x2(orbHighLine, bar_index + 5)
    line.set_x2(orbLowLine, bar_index + 5)
    if showMidLine and not na(orbMidLine)
        line.set_x2(orbMidLine, bar_index + 5)

// Update labels at the right edge
if orbSet and isInSession and showLabels
    label.delete(orbHighLabel)
    label.delete(orbLowLabel)
    label.delete(orbMidLabel)
    orbHighLabel := label.new(bar_index + 5, orbHigh, "ORB High " + str.tostring(orbHigh, format.mintick), style=label.style_label_left, color=orbHighColor, textcolor=color.white, size=size.small)
    orbLowLabel  := label.new(bar_index + 5, orbLow,  "ORB Low "  + str.tostring(orbLow,  format.mintick), style=label.style_label_left, color=orbLowColor,  textcolor=color.white, size=size.small)
    if showMidLine
        orbMidLabel := label.new(bar_index + 5, orbMid, "ORB Mid " + str.tostring(orbMid, format.mintick), style=label.style_label_left, color=orbMidColor, textcolor=color.white, size=size.small)

// Background highlight during ORB formation
bgcolor(showBackground and isOrbCandle ? color.new(color.blue, 85) : na, title="ORB Formation")

// === BREAKOUT SIGNALS ===
// Only trigger on FIRST breakout per direction, after ORB is locked, during session
breakoutUp   = orbSet and isInSession and not tradedLong  and close > orbHigh and not isOrbDone
breakoutDown = orbSet and isInSession and not tradedShort and close < orbLow  and not isOrbDone

if breakoutUp
    tradedLong := true
if breakoutDown
    tradedShort := true

plotshape(breakoutUp,   title="ORB Breakout Long",  location=location.belowbar, color=orbHighColor, style=shape.triangleup,   size=size.small, text="BUY")
plotshape(breakoutDown, title="ORB Breakout Short", location=location.abovebar, color=orbLowColor,  style=shape.triangledown, size=size.small, text="SELL")

// === INFO TABLE ===
var table infoTable = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 80), border_width=1, border_color=color.gray)
if orbSet and isInSession
    table.cell(infoTable, 0, 0, "ORB High",    text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 0, str.tostring(orbHigh, format.mintick), text_color=orbHighColor, text_size=size.small)
    table.cell(infoTable, 0, 1, "ORB Low",     text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(orbLow, format.mintick),  text_color=orbLowColor,  text_size=size.small)
    table.cell(infoTable, 0, 2, "ORB Mid",     text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(orbMid, format.mintick),  text_color=orbMidColor,  text_size=size.small)
    table.cell(infoTable, 0, 3, "ORB Range",   text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(orbHigh - orbLow, format.mintick), text_color=color.white, text_size=size.small)
````
