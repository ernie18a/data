# Kane's Indices ORB

- url: https://www.tradingview.com/script/CidzwUwH-Kane-s-Indices-ORB/
- type: indicator
- pine_id: PUB;0911081b8820476f81f645f043486321
- version: 1.0

## Description

**Kane’s Indices ORB** plots key intraday opening range levels for index futures using clean session boxes and midpoint structure.

Includes:

* 8:00 AM EST Premarket ORB (15m)
* 9:30 AM EST Opening ORB (30m)
* 9:30 AM EST 15-Minute ORB Level
* Midpoint lines
* Session box extensions
* Custom colors & visibility toggles
* Ultra-light default ORB opacity (3%) for reduced chart clutter

Designed for:

* ES / MES
* NQ / MNQ
* YM / MYM
* RTY / M2K

Best used on intraday timeframes for:

* Opening range breakouts
* Liquidity sweeps
* Trend continuation entries
* Reversal reactions around key session ranges

Built with a clean institutional-style layout focused on visibility without obstructing price action.

## Source Code

````pine
//@version=6
indicator("Kane's Indices ORB", overlay=true, max_boxes_count=100, max_lines_count=200)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tz = input.string("America/New_York", "Timezone")

show8am      = input.bool(true,  "8:00am EST (15 min)")
show930_30   = input.bool(true,  "9:30am EST (30 min)")
show930_15   = input.bool(true,  "9:30am EST (15 min level)")
show600_5    = input.bool(false, "6:00pm EST (5 min)")
show600_15   = input.bool(false, "6:00pm EST (15 min) - ends 3:00am EST")

showBoxes     = input.bool(true, "Show ORB Session Boxes")
showMidpoints = input.bool(true, "Show ORB Midpoints")

grayOpacity   = input.int(7, "Gray ORB Body Opacity %", minval=0, maxval=100)
purpleOpacity = input.int(3, "Purple ORB Body Opacity %", minval=0, maxval=100)

color8am      = input.color(color.gray, "8:00am EST Color")
color930      = input.color(color.fuchsia, "9:30am EST Color")
color930_15   = input.color(color.purple, "9:30am EST 15min Color")
color600_5    = input.color(color.blue, "6:00pm EST Color")
color600_15   = input.color(color.orange, "6:00pm 15min EST Color")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helper Functions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_inSession(_session) =>
    not na(time(timeframe.period, _session, tz))

f_newSession(_session) =>
    f_inSession(_session) and not f_inSession(_session)[1]

f_transp(_opacityPercent) =>
    100 - _opacityPercent

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORB Function
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_orb(_enabled, _orbSession, _extendSession, _orbColor, _opacity) =>
    var float orbHigh = na
    var float orbLow = na
    var box orbBox = na
    var line orbMid = na

    inOrb = f_inSession(_orbSession)
    newOrb = f_newSession(_orbSession)
    inExtend = f_inSession(_extendSession)

    if _enabled
        if newOrb
            orbHigh := high
            orbLow := low

            orbBox := box.new(
                 bar_index,
                 orbHigh,
                 bar_index,
                 orbLow,
                 bgcolor=color.new(_orbColor, f_transp(_opacity)),
                 border_color=_orbColor)

            orbMid := line.new(
                 bar_index,
                 (orbHigh + orbLow) / 2,
                 bar_index,
                 (orbHigh + orbLow) / 2,
                 color=_orbColor,
                 style=line.style_dashed)

        if inOrb
            orbHigh := math.max(orbHigh, high)
            orbLow := math.min(orbLow, low)

            if showBoxes and not na(orbBox)
                box.set_top(orbBox, orbHigh)
                box.set_bottom(orbBox, orbLow)
                box.set_right(orbBox, bar_index)

            if showMidpoints and not na(orbMid)
                line.set_y1(orbMid, (orbHigh + orbLow) / 2)
                line.set_y2(orbMid, (orbHigh + orbLow) / 2)
                line.set_x2(orbMid, bar_index)

        if not inOrb and inExtend
            if showBoxes and not na(orbBox)
                box.set_right(orbBox, bar_index)

            if showMidpoints and not na(orbMid)
                line.set_x2(orbMid, bar_index)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Session Times
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
orb8am       = "0800-0815"
extend8am    = "0800-1330"

orb930_30    = "0930-1000"
extend930    = "0930-1600"

orb930_15    = "0930-0945"
extend930_15 = "0930-1600"

orb600_5     = "1800-1805"
extend600_5  = "1800-0300"

orb600_15    = "1800-1815"
extend600_15 = "1800-0300"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Draw ORBs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_orb(show8am,    orb8am,    extend8am,    color8am,    grayOpacity)
f_orb(show930_30, orb930_30, extend930,    color930,    purpleOpacity)
f_orb(show930_15, orb930_15, extend930_15, color930_15, purpleOpacity)
f_orb(show600_5,  orb600_5,  extend600_5,  color600_5,  purpleOpacity)
f_orb(show600_15, orb600_15, extend600_15, color600_15, purpleOpacity)
````
