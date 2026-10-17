# Kane's Oil ORB

- url: https://www.tradingview.com/script/OOnR8qgN-Kane-s-Oil-ORB/
- type: indicator
- pine_id: PUB;29483c3a88284572bb4a8c129ac8abda
- version: 1.0

## Description

**Kane’s Oil ORB** plots key opening range levels for Oil futures using clean session boxes and midpoint structure designed for intraday trading.

Includes:

* 7:00 AM EST ORB (5m) extending through 2:30 PM EST
* 9:00 AM EST ORB (5m) extending through 2:30 PM EST
* 6:00 PM EST ORB (5m) extending through 3:00 AM EST
* Midpoint lines
* Session box extensions
* Custom colors & visibility toggles
* Ultra-light default ORB opacity (3%) for reduced chart clutter

Designed for:

* Crude Oil Futures (CL / MCL)

Best used on intraday timeframes for:

* Opening range breakouts
* Liquidity sweeps
* Trend continuation setups
* Reversal reactions around key session ranges

Built with a clean institutional-style layout focused on visibility without obstructing price action.

## Source Code

````pine
//@version=6
indicator("Kane's Oil ORB", overlay=true, max_boxes_count=100, max_lines_count=200)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tz = input.string("America/New_York", "Timezone")

show700_5   = input.bool(true, "7:00am EST (5 min) - ends 2:30pm EST")
show900_5   = input.bool(true, "9:00am EST (5 min) - ends 2:30pm EST")
show600_5   = input.bool(true, "6:00pm EST (5 min) - ends 3:00am EST")

showBoxes     = input.bool(true, "Show ORB Session Boxes")
showMidpoints = input.bool(true, "Show ORB Midpoints")

fillOpacity = input.int(3, "ORB Body Opacity %", minval=0, maxval=100)

color700 = input.color(color.gray, "7:00am EST Color")
color900 = input.color(color.aqua, "9:00am EST Color")
color600 = input.color(color.blue, "6:00pm EST Color")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
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
orb700      = "0700-0705"
extend700   = "0700-1430"

orb900      = "0900-0905"
extend900   = "0900-1430"

orb600      = "1800-1805"
extend600   = "1800-0300"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Draw ORBs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_orb(show700_5, orb700, extend700, color700, fillOpacity)
f_orb(show900_5, orb900, extend900, color900, fillOpacity)
f_orb(show600_5, orb600, extend600, color600, fillOpacity)
````
