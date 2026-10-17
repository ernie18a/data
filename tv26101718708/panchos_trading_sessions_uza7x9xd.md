# Panchos Trading Sessions

- url: https://www.tradingview.com/script/uZA7x9xD-Panchos-Trading-Sessions/
- type: indicator
- pine_id: PUB;e0ba39033cdb4017804b22a1f819630b
- version: 1.0

## Description

A Simple Session Indicator with local Time Settings especially for German Traders, to identify London, New York or Asia Trading Sessions quickly.

## Source Code

````pine
//@version=6
indicator("Panchos Trading Sessions", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─────────────────────
// Settings
// ─────────────────────
showAsia      = input.bool(true, "Asia", group="Sessions")
showLondon    = input.bool(true, "London", group="Sessions")
showNewYork   = input.bool(true, "New York", group="Sessions")
showDayHours  = input.bool(true, "German Day Trading Hours", group="Sessions")
showOverlap   = input.bool(true, "Highlight Overlaps", group="Sessions")

asiaSession   = input.session("0900-1500:1234567", "Asia Local Time", group="Session Times")
londonSession = input.session("0800-1700:1234567", "London Local Time", group="Session Times")
nySession     = input.session("0930-1600:1234567", "New York Local Time", group="Session Times")
daySession    = input.session("0800-2200:1234567", "Germany Day Hours", group="Session Times")

asiaTZ        = input.string("Asia/Tokyo", "Asia Timezone", group="Timezones")
londonTZ      = input.string("Europe/London", "London Timezone", group="Timezones")
nyTZ          = input.string("America/New_York", "New York Timezone", group="Timezones")
germanyTZ     = input.string("Europe/Berlin", "German Timezone", group="Timezones")

showBoxes     = input.bool(true, "Show Boxes", group="Style")
showLines     = input.bool(true, "Show Open / Close Lines", group="Style")
showLabels    = input.bool(true, "Show Labels", group="Style")

boxTransp     = input.int(91, "Box Transparency", minval=0, maxval=100, group="Style")
overlapTransp = input.int(86, "Overlap Transparency", minval=0, maxval=100, group="Style")
lineTransp    = input.int(45, "Line Transparency", minval=0, maxval=100, group="Style")

asiaCol       = input.color(color.rgb(120, 130, 145), "Asia Color", group="Minimal Colors")
londonCol     = input.color(color.rgb(95, 110, 105), "London Color", group="Minimal Colors")
nyCol         = input.color(color.rgb(135, 115, 105), "New York Color", group="Minimal Colors")
dayCol        = input.color(color.rgb(140, 140, 140), "Day Hours Color", group="Minimal Colors")
overlapCol    = input.color(color.rgb(170, 145, 95), "Overlap Color", group="Minimal Colors")

// ─────────────────────
// Session detection
// ─────────────────────
isIntraday = timeframe.isintraday

inAsia    = isIntraday and showAsia and not na(time(timeframe.period, asiaSession, asiaTZ))
inLondon  = isIntraday and showLondon and not na(time(timeframe.period, londonSession, londonTZ))
inNewYork = isIntraday and showNewYork and not na(time(timeframe.period, nySession, nyTZ))
inDay     = isIntraday and showDayHours and not na(time(timeframe.period, daySession, germanyTZ))

overlapCount = (inAsia ? 1 : 0) + (inLondon ? 1 : 0) + (inNewYork ? 1 : 0)
inOverlap = showOverlap and overlapCount >= 2

bgcolor(inDay ? color.new(dayCol, 96) : na)
bgcolor(inOverlap ? color.new(overlapCol, overlapTransp) : na)

// ─────────────────────
// Helper logic per session
// ─────────────────────

// Asia
var box asiaBox = na
var float asiaHigh = na
var float asiaLow = na

asiaStart = inAsia and not inAsia[1]
asiaEnd   = not inAsia and inAsia[1]

if asiaStart
    asiaHigh := high
    asiaLow := low
    if showBoxes
        asiaBox := box.new(bar_index, high, bar_index, low, bgcolor=color.new(asiaCol, boxTransp), border_color=color.new(asiaCol, 65))
    if showLines
        line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(asiaCol, lineTransp), style=line.style_dotted)
    if showLabels
        label.new(bar_index, high, "Asia", style=label.style_label_down, textcolor=color.new(color.white, 0), color=color.new(asiaCol, 35), size=size.tiny)

if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)
    if showBoxes and not na(asiaBox)
        box.set_right(asiaBox, bar_index)
        box.set_top(asiaBox, asiaHigh)
        box.set_bottom(asiaBox, asiaLow)

if asiaEnd and showLines
    line.new(bar_index - 1, low[1], bar_index - 1, high[1], extend=extend.both, color=color.new(asiaCol, lineTransp), style=line.style_dashed)


// London
var box londonBox = na
var float londonHigh = na
var float londonLow = na

londonStart = inLondon and not inLondon[1]
londonEnd   = not inLondon and inLondon[1]

if londonStart
    londonHigh := high
    londonLow := low
    if showBoxes
        londonBox := box.new(bar_index, high, bar_index, low, bgcolor=color.new(londonCol, boxTransp), border_color=color.new(londonCol, 65))
    if showLines
        line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(londonCol, lineTransp), style=line.style_dotted)
    if showLabels
        label.new(bar_index, high, "London", style=label.style_label_down, textcolor=color.new(color.white, 0), color=color.new(londonCol, 35), size=size.tiny)

if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)
    if showBoxes and not na(londonBox)
        box.set_right(londonBox, bar_index)
        box.set_top(londonBox, londonHigh)
        box.set_bottom(londonBox, londonLow)

if londonEnd and showLines
    line.new(bar_index - 1, low[1], bar_index - 1, high[1], extend=extend.both, color=color.new(londonCol, lineTransp), style=line.style_dashed)


// New York
var box nyBox = na
var float nyHigh = na
var float nyLow = na

nyStart = inNewYork and not inNewYork[1]
nyEnd   = not inNewYork and inNewYork[1]

if nyStart
    nyHigh := high
    nyLow := low
    if showBoxes
        nyBox := box.new(bar_index, high, bar_index, low, bgcolor=color.new(nyCol, boxTransp), border_color=color.new(nyCol, 65))
    if showLines
        line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(nyCol, lineTransp), style=line.style_dotted)
    if showLabels
        label.new(bar_index, high, "New York", style=label.style_label_down, textcolor=color.new(color.white, 0), color=color.new(nyCol, 35), size=size.tiny)

if inNewYork
    nyHigh := math.max(nyHigh, high)
    nyLow := math.min(nyLow, low)
    if showBoxes and not na(nyBox)
        box.set_right(nyBox, bar_index)
        box.set_top(nyBox, nyHigh)
        box.set_bottom(nyBox, nyLow)

if nyEnd and showLines
    line.new(bar_index - 1, low[1], bar_index - 1, high[1], extend=extend.both, color=color.new(nyCol, lineTransp), style=line.style_dashed)


// Warning
if barstate.islast and not isIntraday
    label.new(bar_index, high, "Use Panchos Trading Sessions on intraday timeframes.", style=label.style_label_down)
````
