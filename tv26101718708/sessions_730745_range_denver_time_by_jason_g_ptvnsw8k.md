# Sessions + 7:30-7:45 Range (Denver Time) by Jason G

- url: https://www.tradingview.com/script/pTvnSW8k-Sessions-7-30-7-45-Range-Denver-Time-by-Jason-G/
- type: indicator
- pine_id: PUB;078443de1fbd4f6cb2e71b6efeaea01c
- version: 2.0

## Description

this indicator is for 15 mins open candles and must use the fixed volume range profile and ICT concept for forecasting entry.

## Source Code

````pine
//@version=5
indicator("Sessions + 7:30-7:45 Range (Denver Time) by Jason G", overlay=true, max_boxes_count=500, max_labels_count=500)

//====================================================
// TIMEZONE
//====================================================
string TZ = "America/Denver"

//====================================================
// SESSION INPUTS (DENVER TIME)
//====================================================
asiaSession   = input.session("1800-0000", "Asia Session")
londonSession = input.session("0100-0729", "London Session")
nySession     = input.session("0730-1600", "New York Session")

// 7:30AM → 7:45AM RANGE
rangeSession  = input.session("0730-0750", "7:30-7:50 Range")

//====================================================
// COLORS
//====================================================
asiaColor   = color.new(color.blue, 85)
londonColor = color.new(color.yellow, 85)
nyColor     = color.new(color.green, 85)
rangeColor  = color.new(color.orange, 80)

//====================================================
// SESSION DETECTION
//====================================================
inAsia   = not na(time(timeframe.period, asiaSession, TZ))
inLondon = not na(time(timeframe.period, londonSession, TZ))
inNY     = not na(time(timeframe.period, nySession, TZ))
inRange  = not na(time(timeframe.period, rangeSession, TZ))

//====================================================
// ASIA SESSION BOX
//====================================================
var box asiaBox = na
var label asiaLabel = na
var float asiaHigh = na
var float asiaLow = na

if inAsia and not inAsia[1]
    asiaHigh := high
    asiaLow := low

    asiaBox := box.new(
         left=bar_index,
         right=bar_index,
         top=high,
         bottom=low,
         bgcolor=asiaColor,
         border_color=color.blue,
         border_width=2)

    asiaLabel := label.new(
         x=bar_index,
         y=(high + low)/2,
         text="ASIA",
         style=label.style_none,
         textcolor=color.new(color.blue, 25),
         size=size.huge)

if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

    box.set_right(asiaBox, bar_index)
    box.set_top(asiaBox, asiaHigh)
    box.set_bottom(asiaBox, asiaLow)

    label.set_xy(
         asiaLabel,
         math.floor((box.get_left(asiaBox) + box.get_right(asiaBox))/2),
         (asiaHigh + asiaLow)/2)

//====================================================
// LONDON SESSION BOX
//====================================================
var box londonBox = na
var label londonLabel = na
var float londonHigh = na
var float londonLow = na

if inLondon and not inLondon[1]
    londonHigh := high
    londonLow := low

    londonBox := box.new(
         left=bar_index,
         right=bar_index,
         top=high,
         bottom=low,
         bgcolor=londonColor,
         border_color=color.yellow,
         border_width=2)

    londonLabel := label.new(
         x=bar_index,
         y=(high + low)/2,
         text="LONDON",
         style=label.style_none,
         textcolor=color.new(color.yellow, 20),
         size=size.huge)

if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)

    box.set_right(londonBox, bar_index)
    box.set_top(londonBox, londonHigh)
    box.set_bottom(londonBox, londonLow)

    label.set_xy(
         londonLabel,
         math.floor((box.get_left(londonBox) + box.get_right(londonBox))/2),
         (londonHigh + londonLow)/2)

//====================================================
// ORANGE 7:30 → 7:55 RANGE BOX
//====================================================
var box rangeBox = na
var float rangeHigh = na
var float rangeLow = na

if inRange and not inRange[1]
    rangeHigh := high
    rangeLow := low

    rangeBox := box.new(
         left=bar_index,
         right=bar_index,
         top=high,
         bottom=low,
         bgcolor=rangeColor,
         border_color=color.orange,
         border_width=3)

if inRange
    rangeHigh := math.max(rangeHigh, high)
    rangeLow := math.min(rangeLow, low)

    box.set_right(rangeBox, bar_index)
    box.set_top(rangeBox, rangeHigh)
    box.set_bottom(rangeBox, rangeLow)

//====================================================
// NEW YORK SESSION BOX
//====================================================
var box nyBox = na
var label nyLabel = na
var float nyHigh = na
var float nyLow = na

if inNY and not inNY[1]
    nyHigh := high
    nyLow := low

    nyBox := box.new(
         left=bar_index,
         right=bar_index,
         top=high,
         bottom=low,
         bgcolor=nyColor,
         border_color=color.green,
         border_width=2)

    nyLabel := label.new(
         x=bar_index,
         y=(high + low)/2,
         text="NEW YORK",
         style=label.style_none,
         textcolor=color.new(color.green, 25),
         size=size.huge)

if inNY
    nyHigh := math.max(nyHigh, high)
    nyLow := math.min(nyLow, low)

    box.set_right(nyBox, bar_index)
    box.set_top(nyBox, nyHigh)
    box.set_bottom(nyBox, nyLow)

    label.set_xy(
         nyLabel,
         math.floor((box.get_left(nyBox) + box.get_right(nyBox))/2),
         (nyHigh + nyLow)/2)
 //====================================================
// ASIA OPENING 15-MIN RANGE BOX (ORANGE)
//====================================================
asiaOpenRange = input.session("1800-1815", "Asia Opening Range")

inAsiaOpen = not na(time(timeframe.period, asiaOpenRange, TZ))

var box asiaOpenBox = na
var float asiaOpenHigh = na
var float asiaOpenLow = na

if inAsiaOpen and not inAsiaOpen[1]
    asiaOpenHigh := high
    asiaOpenLow := low

    asiaOpenBox := box.new(
         left=bar_index,
         right=bar_index,
         top=high,
         bottom=low,
         bgcolor=color.new(color.orange, 80),
         border_color=color.orange,
         border_width=2)

if inAsiaOpen
    asiaOpenHigh := math.max(asiaOpenHigh, high)
    asiaOpenLow := math.min(asiaOpenLow, low)

    box.set_right(asiaOpenBox, bar_index)
    box.set_top(asiaOpenBox, asiaOpenHigh)
    box.set_bottom(asiaOpenBox, asiaOpenLow)


//====================================================
// LONDON OPENING 15-MIN RANGE BOX (ORANGE)
//====================================================
londonOpenRange = input.session("0100-0115", "London Opening Range")

inLondonOpen = not na(time(timeframe.period, londonOpenRange, TZ))

var box londonOpenBox = na
var float londonOpenHigh = na
var float londonOpenLow = na

if inLondonOpen and not inLondonOpen[1]
    londonOpenHigh := high
    londonOpenLow := low

    londonOpenBox := box.new(
         left=bar_index,
         right=bar_index,
         top=high,
         bottom=low,
         bgcolor=color.new(color.orange, 80),
         border_color=color.orange,
         border_width=2)

if inLondonOpen
    londonOpenHigh := math.max(londonOpenHigh, high)
    londonOpenLow := math.min(londonOpenLow, low)

    box.set_right(londonOpenBox, bar_index)
    box.set_top(londonOpenBox, londonOpenHigh)
    box.set_bottom(londonOpenBox, londonOpenLow)
````
