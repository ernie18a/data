# Kane's Gold/Silver ORB

- url: https://www.tradingview.com/script/7WTYXcAx-Kane-s-Gold-Silver-ORB/
- type: indicator
- pine_id: PUB;6c95189f807543dba9e32767c21e61fd
- version: 1.0

## Description

Kane's Gold/Silver ORB

A clean Opening Range Breakout (ORB) indicator designed specifically for Gold and Silver traders.

This indicator automatically plots and extends the key opening ranges commonly used by precious metals traders:

• 8:00am EST 5-Minute ORB
• 8:20am EST 30-Minute ORB
• 6:00pm EST 5-Minute ORB
• 6:00pm EST 15-Minute ORB

Features:

• Session boxes with customizable colors and opacity
• Dashed midpoint levels for each opening range
• Automatic range extension throughout the trading session
• Restricted to Gold and Silver products only
• Supports GC, MGC, SI, and SIL contracts
• Clear visual separation between overnight and regular-session opening ranges
• Lightweight and uncluttered chart design

The opening range often serves as an important reference for trend direction, support and resistance, liquidity sweeps, and breakout opportunities. This indicator keeps those key levels visible throughout the session so traders can focus on price action rather than manually drawing ranges.

Created for traders who want a clean, chart-focused ORB tool tailored specifically to Gold and Silver trading.

## Source Code

````pine
//@version=5
indicator("Kane's Gold/Silver ORB", overlay=true, max_boxes_count=100, max_lines_count=200)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tz = input.string("America/New_York", "Timezone")

show800_5     = input.bool(true, "8:00am EST (5 min) - ends 1:30pm EST")
show820_30    = input.bool(true, "8:20am EST (30 min) - ends 1:30pm EST")
show600_5     = input.bool(true, "6:00pm EST (5 min) - ends 3:00am EST")
show600_15    = input.bool(true, "6:00pm EST (15 min) - ends 3:00am EST")

showBoxes     = input.bool(true, "Show ORB Session Boxes")
showMidpoints = input.bool(true, "Show ORB Midpoints")

grayOpacity   = input.int(7, "Gray ORB Body Opacity %", minval=0, maxval=100)
purpleOpacity = input.int(3, "Purple ORB Body Opacity %", minval=0, maxval=100)

color800      = input.color(color.gray, "8:00am EST Color")
color820      = input.color(color.fuchsia, "8:20am EST Color")
color600_5    = input.color(color.blue, "6:00pm EST Color")
color600_15   = input.color(color.orange, "6:00pm 15min EST Color")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Gold / Silver Only Filter
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isGoldSilver =
     syminfo.root == "GC"  or
     syminfo.root == "MGC" or
     syminfo.root == "SI"  or
     syminfo.root == "SIL"

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
orb800_5      = "0800-0805"
extend800     = "0800-1330"

orb820_30     = "0820-0850"
extend820     = "0820-1330"

orb600_5      = "1800-1805"
extend600_5   = "1800-0300"

orb600_15     = "1800-1815"
extend600_15  = "1800-0300"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Draw ORBs — Gold & Silver Only
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if isGoldSilver
    f_orb(show800_5,  orb800_5,  extend800,    color800,    grayOpacity)
    f_orb(show820_30, orb820_30, extend820,    color820,    purpleOpacity)
    f_orb(show600_5,  orb600_5,  extend600_5,  color600_5,  purpleOpacity)
    f_orb(show600_15, orb600_15, extend600_15, color600_15, purpleOpacity)
````
