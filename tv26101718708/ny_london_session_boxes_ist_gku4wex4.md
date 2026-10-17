# NY & London Session Boxes (IST)

- url: https://www.tradingview.com/script/gKU4weX4-NY-London-Session-Boxes-IST/
- type: indicator
- pine_id: PUB;79c0bf3f4558482395415dc8f9111547
- version: 1.0

## Description

# NY & London Session Boxes (IST)

This TradingView Pine Script indicator automatically highlights the London and New York trading sessions using colored boxes based on Indian Standard Time (IST).

## Features

* 🟩 London Session Box: 1:00 PM to 4:00 PM IST
* 🟥 New York Session Box: 7:30 PM to 12:00 AM IST
* Automatically tracks and displays the session's highest high and lowest low.
* Dynamically expands the box as the session progresses.
* Clean visual representation for identifying session ranges and important trading zones.
* Fully customizable timezone input (default: Asia/Kolkata).

This indicator is useful for traders who analyze session-based price action, liquidity, breakouts, and market structure while working in IST.

## Source Code

````pine
//@version=6
indicator("NY & London Session Boxes (IST)", overlay=true, max_boxes_count=500)

//=========================
// SESSION SETTINGS (IST)
//=========================
nySession  = input.session("1930-0000", "New York Session (IST)")
lonSession = input.session("1300-1600", "London Session (IST)")
tz = input.string("Asia/Kolkata", "Timezone")

//=========================
// SESSION CHECK
//=========================
inNY  = not na(time(timeframe.period, nySession, tz))
inLON = not na(time(timeframe.period, lonSession, tz))

//=========================
// VARIABLES
//=========================
var box nyBox = na
var box lonBox = na

var float nyHigh = na
var float nyLow  = na

var float lonHigh = na
var float lonLow  = na

//=========================
// NEW YORK SESSION
//=========================
nyStart = inNY and not inNY[1]
nyEnd   = not inNY and inNY[1]

if nyStart
    nyHigh := high
    nyLow := low
    nyBox := box.new(bar_index, high, bar_index, low,
         bgcolor=color.new(color.red, 85),
         border_color=color.red)

if inNY
    nyHigh := math.max(nyHigh, high)
    nyLow := math.min(nyLow, low)

    box.set_right(nyBox, bar_index)
    box.set_top(nyBox, nyHigh)
    box.set_bottom(nyBox, nyLow)

//=========================
// LONDON SESSION
//=========================
lonStart = inLON and not inLON[1]
lonEnd   = not inLON and inLON[1]

if lonStart
    lonHigh := high
    lonLow := low
    lonBox := box.new(bar_index, high, bar_index, low,
         bgcolor=color.new(color.green, 85),
         border_color=color.green)

if inLON
    lonHigh := math.max(lonHigh, high)
    lonLow := math.min(lonLow, low)

    box.set_right(lonBox, bar_index)
    box.set_top(lonBox, lonHigh)
    box.set_bottom(lonBox, lonLow)
````
