<!-- tradingview-pine-id: PUB;a2c25de6510a4faba0568461a1926ecf -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Kill Zones (lstrihic)

Source: https://www.tradingview.com/script/dw8zDTWw-Kill-Zones-lstrihic/

## Description

A clean and lightweight ICT-style Kill Zones indicator for TradingView.

It automatically highlights the major trading sessions directly on the chart:

Asian Kill Zone
London Kill Zone
New York AM Kill Zone
New York PM Kill Zone
Daily Open reference line

Each session is displayed as a dynamically expanding box that tracks the session high and low while the session is active.

Features
Fully configurable session times
Selectable timezone
Individual enable/disable controls for each Kill Zone
Optional weekend filtering
Customizable box color, transparency, border style and labels
Automatic pruning of older sessions to keep the chart clean
Configurable Daily Open line
Optional alerts when a Kill Zone opens
Designed for intraday charts up to 15 minutes
Automatically handles timezone and DST changes through TradingView's timezone system
Default Sessions

Using America/New_York:

Asian: 19:00–23:00
London: 02:00–05:00
New York AM: 07:00–10:00
New York PM: 13:30–16:00

All session times can be changed from the indicator settings.

Usage

The indicator is intended to provide simple session context without cluttering the chart. It can be used alongside price action, liquidity concepts, order flow, VWAP, market structure or other trading tools.

Kill Zones should not be treated as standalone trade signals. They identify periods where liquidity and market activity may be more relevant for intraday trading.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © lstrihic

//@version=6
indicator("Kill Zones (lstrihic)", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────

// Sessions
grpSess  = "Sessions"
tz       = input.string("America/New_York", "Timezone", options=["America/New_York","UTC","Europe/London","Asia/Tokyo"], group=grpSess)
sAsian   = input.session("1900-2300", "Asian KZ",    group=grpSess, tooltip="Default 19:00–23:00 ET. Classic ICT alt is 20:00–00:00 ET.")
sLondon  = input.session("0200-0500", "London KZ",   group=grpSess)
sNYAM    = input.session("0700-1000", "New York AM", group=grpSess)
sNYPM    = input.session("1330-1600", "New York PM", group=grpSess)

showAsian  = input.bool(true, "Asian",  inline="enable1", group=grpSess)
showLondon = input.bool(true, "London", inline="enable1", group=grpSess)
showNYAM   = input.bool(true, "NY AM",  inline="enable2", group=grpSess)
showNYPM   = input.bool(true, "NY PM",  inline="enable2", group=grpSess)
skipWknd   = input.bool(true, "Skip weekends", group=grpSess)

// Visuals
grpVis       = "Visuals"
boxColor     = input.color(color.gray, "Box color", group=grpVis)
fillTransp   = input.int(92, "Fill transparency",   minval=0, maxval=100, group=grpVis, tooltip="0 = opaque, 100 = invisible")
borderTransp = input.int(70, "Border transparency", minval=0, maxval=100, group=grpVis)
txtTransp    = input.int(50, "Label transparency",  minval=0, maxval=100, group=grpVis)
borderStyle  = input.string("dotted", "Box border style", options=["solid","dashed","dotted"], group=grpVis)
lblSize      = input.string("normal", "Label size", options=["tiny","small","normal","large"], group=grpVis)
maxSessions  = input.int(50, "Max sessions kept per zone", minval=5, maxval=500, group=grpVis, tooltip="Older boxes are pruned to keep the chart tidy and stay under Pine's drawing limits.")

// Day open line
grpDay        = "Day Open"
showDayOpen   = input.bool(true, "Show day-open line", group=grpDay)
dayLineClr    = input.color(color.gray, "Color", group=grpDay)
dayLineTrnsp  = input.int(70, "Transparency", minval=0, maxval=100, group=grpDay)
dayLineStyle  = input.string("dashed", "Style", options=["solid","dashed","dotted"], group=grpDay)

// Alerts
alertOnOpen = input.bool(false, "Alert on session open", group="Alerts")

// ─── HELPERS ───────────────────────────────────────────────────────────────

isTFValid  = timeframe.in_seconds() <= 900   // ≤ 15min
isWeekend  = dayofweek == dayofweek.saturday or dayofweek == dayofweek.sunday
sessActive = isTFValid and not (skipWknd and isWeekend)

lblSizeConst = switch lblSize
    "tiny"  => size.tiny
    "small" => size.small
    "large" => size.large
    => size.normal

lineStyle(string s) =>
    switch s
        "solid"  => line.style_solid
        "dotted" => line.style_dotted
        => line.style_dashed

borderStyleConst = lineStyle(borderStyle)
dayStyleConst    = lineStyle(dayLineStyle)

fillClr   = color.new(boxColor, fillTransp)
borderClr = color.new(boxColor, borderTransp)
txtClr    = color.new(boxColor, txtTransp)

// ─── ZONE TYPE ─────────────────────────────────────────────────────────────

type Zone
    string name
    string sess
    bool   enabled
    array<box>   boxes
    array<label> labels
    box    curBox  = na
    label  curLbl  = na
    float  hi      = na
    float  lo      = na
    bool   active  = false

method update(Zone z) =>
    if not z.enabled or not sessActive
        z.active := false
    else
        inSess = not na(time(timeframe.period, z.sess, tz))
        if inSess and not z.active
            // Session opened
            z.hi     := high
            z.lo     := low
            z.curBox := box.new(bar_index, high, bar_index, low, border_color=borderClr, bgcolor=fillClr, border_style=borderStyleConst)
            z.curLbl := label.new(bar_index, high, z.name, style=label.style_none, textcolor=txtClr, size=lblSizeConst)
            array.push(z.boxes,  z.curBox)
            array.push(z.labels, z.curLbl)
            // Prune oldest sessions to respect the user-set lookback
            while array.size(z.boxes) > maxSessions
                box.delete(array.shift(z.boxes))
                label.delete(array.shift(z.labels))
            if alertOnOpen and barstate.isconfirmed
                alert(z.name + " kill zone opened", alert.freq_once_per_bar_close)
        else if inSess and z.active
            // Session continues — extend box & re-center label
            z.hi := math.max(z.hi, high)
            z.lo := math.min(z.lo, low)
            box.set_top(z.curBox,    z.hi)
            box.set_bottom(z.curBox, z.lo)
            box.set_right(z.curBox,  bar_index)
            label.set_x(z.curLbl, math.round(math.avg(box.get_left(z.curBox), bar_index)))
            label.set_y(z.curLbl, z.hi)
        z.active := inSess

// Initialise zones once. Inputs are captured on first bar; they refresh on every script rerun.
var array<Zone> zones = array.from(
     Zone.new("Asian",   sAsian,  showAsian,  array.new<box>(), array.new<label>()),
     Zone.new("London",  sLondon, showLondon, array.new<box>(), array.new<label>()),
     Zone.new("NY AM",   sNYAM,   showNYAM,   array.new<box>(), array.new<label>()),
     Zone.new("NY PM",   sNYPM,   showNYPM,   array.new<box>(), array.new<label>())
 )

for z in zones
    z.update()

// ─── DAY OPEN LINE ────────────────────────────────────────────────────────

var array<line> dayLines = array.new<line>()
newDay = ta.change(dayofmonth(time, tz)) != 0   // day boundary in user-selected tz

if showDayOpen and newDay and isTFValid
    ln = line.new(bar_index, high, bar_index, low, extend=extend.both, color=color.new(dayLineClr, dayLineTrnsp), style=dayStyleConst, width=1)
    array.push(dayLines, ln)
    while array.size(dayLines) > maxSessions
        line.delete(array.shift(dayLines))
````
