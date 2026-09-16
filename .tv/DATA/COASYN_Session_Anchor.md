<!-- tradingview-pine-id: PUB;4b3614ec75ee46589fe0421d63781c60 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# COASYN Session Anchor

Source: https://www.tradingview.com/script/JsV8FFVS-Coasyn-Session-Anchor/

## Description

Coasyn Session Anchor

Coasyn Session Anchor is an intraday session-reference tool for marking important FX trading-session events directly on the chart.

The indicator can track:

Tokyo Open
Tokyo Close
Europe Open
London Open
New York Open
New York Close

Each enabled event can create:

a vertical timing marker showing when the session event occurred
a horizontal price anchor extending from that event
an optional label identifying the session

The indicator does not generate trade signals, determine market direction, or execute orders.

Its purpose is to provide consistent session timing and price-reference levels.

How to use it

Open the indicator settings and first choose your Anchor Timezone.

The default is:

Etc/UTC

All session times entered in the indicator are interpreted using this timezone.

For each session event, you can:

Enable or disable the event.
Enter the event time using HH:MM format.

For example:

00:00
07:00
08:00
13:30

Session times

The default configuration is:

Tokyo Open — 00:00

Tokyo Close — 09:00

Europe Open — 07:00

London Open — 08:00

New York Open — 13:30

New York Close — 21:00

These times are fully editable.

If your preferred session definition, broker convention, daylight-saving adjustment, or operating timezone is different, change the values in the settings.

Horizontal anchor price

The Horizontal Anchor Price setting determines which price is used when a session event occurs.

Event Open
Uses the chart bar's opening price when the session anchor is detected.

Event Close
Uses the chart bar's closing price.

The resulting level extends to the right as a reference for later price interaction.

Vertical session markers

Enable:

Show Vertical Session Timing Lines

to draw a vertical line at each enabled session event.

This provides a visual reference for when major trading sessions begin or end.

Horizontal session levels

Enable:

Show Horizontal Anchor Levels

to extend the selected event price across the chart.

These levels can be used to observe how price behaves relative to prior session participation points.

The indicator does not assign bullish or bearish meaning to those levels.

Labels

Enable:

Show Anchor Labels

to identify each session directly on the chart.

Labels include:

TOKYO OPEN

TOKYO CLOSE

EUROPE OPEN

LONDON OPEN

NY OPEN

NY CLOSE

Historical anchors

By default, Keep Historical Anchors is disabled.

When disabled, each session event keeps only its most recent anchor.

For example, when the next London Open occurs, the previous London Open anchor is removed and replaced with the new one.

Enable Keep Historical Anchors if you want previous session anchors to remain visible.

Be aware that keeping large amounts of historical session data can create substantially more chart objects.

Display controls

The indicator allows you to configure:

session colors
line width
horizontal levels
vertical timing markers
labels
historical anchors

Each major session can use its own color so different session events remain easy to distinguish.

Example workflow

A trader operating during the London and New York sessions might enable:

Europe Open
London Open
New York Open

while disabling session events they do not use.

The chart will then maintain timing and price anchors for those specific events.

This makes it easier to observe whether price is trading:

above or below a session-opening reference
back through a prior session level
around the transition between trading sessions

The interpretation remains entirely with the trader.

Timeframe note

Coasyn Session Anchor is designed primarily for intraday charts.

The precision of an anchor depends on the chart timeframe.

On lower intraday timeframes, the bar containing the configured session time will generally provide a more precise representation of that event.

On larger chart intervals, one candle may span multiple session events, so the event price should be treated as a broader reference rather than an exact tick-level session price.

Important

Coasyn Session Anchor is an informational charting tool only.

It does not provide:

buy or sell signals
trade entries
targets
stop placement
position sizing
automated execution
directional recommendations

It provides time and price anchors around the session events selected by the user.

Built by Coasyn Market Systems.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Coasyn

//@version=6
indicator("COASYN Session Anchor", overlay=true, max_lines_count=500, max_labels_count=500)

// COASYN SESSION ANCHOR FRAMEWORK
// Session participation anchors: one horizontal level and one vertical timing marker per enabled event.
// Each anchor updates only when that specific session event occurs again.

// Inputs
groupTime = "Session Timezone"
tzInput = input.string("Etc/UTC", "Anchor timezone", group=groupTime)

groupSessions = "Session Anchors"
showTokyoOpen  = input.bool(true,  "Tokyo Open",   group=groupSessions, inline="tokyoOpen")
tokyoOpenHHMM  = input.string("00:00", "",         group=groupSessions, inline="tokyoOpen")

showTokyoClose = input.bool(true,  "Tokyo Close",  group=groupSessions, inline="tokyoClose")
tokyoCloseHHMM = input.string("09:00", "",         group=groupSessions, inline="tokyoClose")

showEuropeOpen = input.bool(true,  "Europe Open",  group=groupSessions, inline="europeOpen")
europeOpenHHMM = input.string("07:00", "",         group=groupSessions, inline="europeOpen")

showLondonOpen = input.bool(true,  "London Open",  group=groupSessions, inline="londonOpen")
londonOpenHHMM = input.string("08:00", "",         group=groupSessions, inline="londonOpen")

showNYOpen     = input.bool(true,  "NY Open",      group=groupSessions, inline="nyOpen")
nyOpenHHMM     = input.string("13:30", "",         group=groupSessions, inline="nyOpen")

showNYClose    = input.bool(false, "NY Close",     group=groupSessions, inline="nyClose")
nyCloseHHMM    = input.string("21:00", "",         group=groupSessions, inline="nyClose")

groupStyle = "Surface"
anchorPriceMode = input.string("Event open", "Horizontal anchor price", options=["Event open", "Event close"], group=groupStyle)
keepHistory = input.bool(false, "Keep historical anchors", group=groupStyle)
showVerticals = input.bool(true, "Show vertical session timing lines", group=groupStyle)
showHorizontals = input.bool(true, "Show horizontal anchor levels", group=groupStyle)
showLabels = input.bool(true, "Show anchor labels", group=groupStyle)
lineWidth = input.int(1, "Line width", minval=1, maxval=4, group=groupStyle)

tokyoColor  = input.color(color.new(color.rgb(126, 87, 194), 0), "Tokyo", group=groupStyle, inline="colors1")
europeColor = input.color(color.new(color.rgb(0, 150, 136), 0), "Europe", group=groupStyle, inline="colors1")
londonColor = input.color(color.new(color.rgb(245, 124, 0), 0), "London", group=groupStyle, inline="colors2")
nyColor     = input.color(color.new(color.rgb(41, 98, 255), 0), "New York", group=groupStyle, inline="colors2")
closeColor  = input.color(color.new(color.rgb(120, 120, 120), 0), "Close", group=groupStyle)

// Helpers
f_validTime(string hhmm) =>
    str.length(hhmm) == 5 and str.substring(hhmm, 2, 3) == ":"

f_hour(string hhmm) =>
    f_validTime(hhmm) ? int(str.tonumber(str.substring(hhmm, 0, 2))) : 0

f_minute(string hhmm) =>
    f_validTime(hhmm) ? int(str.tonumber(str.substring(hhmm, 3, 5))) : 0

f_anchorTime(string hhmm) =>
    timestamp(tzInput, year(time, tzInput), month(time, tzInput), dayofmonth(time, tzInput), f_hour(hhmm), f_minute(hhmm))

f_hit(string hhmm) =>
    int anchor = f_anchorTime(hhmm)
    f_validTime(hhmm) and not na(time[1]) and time >= anchor and time[1] < anchor

f_anchorPrice() =>
    anchorPriceMode == "Event open" ? open : close

f_label(string txt, float y, color c) =>
    label.new(x=bar_index, y=y, text=txt, style=label.style_label_left, color=color.new(c, 12), textcolor=color.white, size=size.tiny)

// Persistent objects
var line tokyoOpenH = na
var line tokyoOpenV = na
var label tokyoOpenL = na

var line tokyoCloseH = na
var line tokyoCloseV = na
var label tokyoCloseL = na

var line europeOpenH = na
var line europeOpenV = na
var label europeOpenL = na

var line londonOpenH = na
var line londonOpenV = na
var label londonOpenL = na

var line nyOpenH = na
var line nyOpenV = na
var label nyOpenL = na

var line nyCloseH = na
var line nyCloseV = na
var label nyCloseL = na

// Tokyo Open
if showTokyoOpen and f_hit(tokyoOpenHHMM)
    float y = f_anchorPrice()
    if not keepHistory
        if not na(tokyoOpenH)
            line.delete(tokyoOpenH)
        if not na(tokyoOpenV)
            line.delete(tokyoOpenV)
        if not na(tokyoOpenL)
            label.delete(tokyoOpenL)
    if showHorizontals
        tokyoOpenH := line.new(bar_index, y, bar_index + 1, y, extend=extend.right, color=tokyoColor, width=lineWidth, style=line.style_solid)
    if showVerticals
        tokyoOpenV := line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(tokyoColor, 10), width=lineWidth, style=line.style_solid)
    if showLabels
        tokyoOpenL := f_label("TOKYO OPEN", y, tokyoColor)

// Tokyo Close
if showTokyoClose and f_hit(tokyoCloseHHMM)
    float y = f_anchorPrice()
    if not keepHistory
        if not na(tokyoCloseH)
            line.delete(tokyoCloseH)
        if not na(tokyoCloseV)
            line.delete(tokyoCloseV)
        if not na(tokyoCloseL)
            label.delete(tokyoCloseL)
    if showHorizontals
        tokyoCloseH := line.new(bar_index, y, bar_index + 1, y, extend=extend.right, color=closeColor, width=lineWidth, style=line.style_dashed)
    if showVerticals
        tokyoCloseV := line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(closeColor, 10), width=lineWidth, style=line.style_dashed)
    if showLabels
        tokyoCloseL := f_label("TOKYO CLOSE", y, closeColor)

// Europe Open
if showEuropeOpen and f_hit(europeOpenHHMM)
    float y = f_anchorPrice()
    if not keepHistory
        if not na(europeOpenH)
            line.delete(europeOpenH)
        if not na(europeOpenV)
            line.delete(europeOpenV)
        if not na(europeOpenL)
            label.delete(europeOpenL)
    if showHorizontals
        europeOpenH := line.new(bar_index, y, bar_index + 1, y, extend=extend.right, color=europeColor, width=lineWidth, style=line.style_solid)
    if showVerticals
        europeOpenV := line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(europeColor, 10), width=lineWidth, style=line.style_solid)
    if showLabels
        europeOpenL := f_label("EUROPE OPEN", y, europeColor)

// London Open
if showLondonOpen and f_hit(londonOpenHHMM)
    float y = f_anchorPrice()
    if not keepHistory
        if not na(londonOpenH)
            line.delete(londonOpenH)
        if not na(londonOpenV)
            line.delete(londonOpenV)
        if not na(londonOpenL)
            label.delete(londonOpenL)
    if showHorizontals
        londonOpenH := line.new(bar_index, y, bar_index + 1, y, extend=extend.right, color=londonColor, width=lineWidth, style=line.style_solid)
    if showVerticals
        londonOpenV := line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(londonColor, 10), width=lineWidth, style=line.style_solid)
    if showLabels
        londonOpenL := f_label("LONDON OPEN", y, londonColor)

// New York Open
if showNYOpen and f_hit(nyOpenHHMM)
    float y = f_anchorPrice()
    if not keepHistory
        if not na(nyOpenH)
            line.delete(nyOpenH)
        if not na(nyOpenV)
            line.delete(nyOpenV)
        if not na(nyOpenL)
            label.delete(nyOpenL)
    if showHorizontals
        nyOpenH := line.new(bar_index, y, bar_index + 1, y, extend=extend.right, color=nyColor, width=lineWidth, style=line.style_solid)
    if showVerticals
        nyOpenV := line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(nyColor, 10), width=lineWidth, style=line.style_solid)
    if showLabels
        nyOpenL := f_label("NY OPEN", y, nyColor)

// New York Close
if showNYClose and f_hit(nyCloseHHMM)
    float y = f_anchorPrice()
    if not keepHistory
        if not na(nyCloseH)
            line.delete(nyCloseH)
        if not na(nyCloseV)
            line.delete(nyCloseV)
        if not na(nyCloseL)
            label.delete(nyCloseL)
    if showHorizontals
        nyCloseH := line.new(bar_index, y, bar_index + 1, y, extend=extend.right, color=closeColor, width=lineWidth, style=line.style_dashed)
    if showVerticals
        nyCloseV := line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(closeColor, 10), width=lineWidth, style=line.style_dashed)
    if showLabels
        nyCloseL := f_label("NY CLOSE", y, closeColor)
````
