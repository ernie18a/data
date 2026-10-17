# Sessions + 15 min Opening Range Boxes (Denver Time) by Jason G

- url: https://www.tradingview.com/script/PdBSWhZv-Sessions-15-min-Opening-Range-Boxes-Denver-Time-by-Jason-G/
- type: indicator
- pine_id: PUB;439fd532c2834700a620cfeddf6e4306
- version: 1.0

## Description

Session box and 15 min opening candle box. Use Fixed range profile on opening candle and ICT concept for forcasting and entry.

## Source Code

````pine
//@version=5
indicator("Sessions + Opening Range Boxes (Denver Time) by Jason G", overlay=true, max_boxes_count=500, max_labels_count=500)

//====================================================
// TIMEZONE
//====================================================
string TZ = "America/Denver"

//====================================================
// SESSION INPUTS
//====================================================
asiaSession      = input.session("1800-0000", "Asia Session")
londonSession    = input.session("0100-0729", "London Session")
newYorkSession   = input.session("0730-1600", "New York Session")

// Opening Range Sessions (15 Minutes)
asiaOpenRange    = input.session("1800-1815", "Asia Opening Range")
londonOpenRange  = input.session("0100-0115", "London Opening Range")
nyOpenRange      = input.session("0730-0745", "NY Opening Range")

//====================================================
// COLORS
//====================================================
asiaColor     = color.new(color.blue, 85)
londonColor   = color.new(color.yellow, 85)
nyColor       = color.new(color.green, 85)
openingColor  = color.new(color.orange, 80)

//====================================================
// SESSION DETECTION
//====================================================
inAsia         = not na(time(timeframe.period, asiaSession, TZ))
inLondon       = not na(time(timeframe.period, londonSession, TZ))
inNY           = not na(time(timeframe.period, newYorkSession, TZ))

inAsiaOpen     = not na(time(timeframe.period, asiaOpenRange, TZ))
inLondonOpen   = not na(time(timeframe.period, londonOpenRange, TZ))
inNYOpen       = not na(time(timeframe.period, nyOpenRange, TZ))

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
         textcolor=color.new(color.blue, 20),
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
         textcolor=color.new(color.yellow, 10),
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
         textcolor=color.new(color.green, 20),
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
// ASIA OPENING RANGE BOX (15 MIN)
//====================================================
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
         bgcolor=openingColor,
         border_color=color.orange,
         border_width=3)

if inAsiaOpen
    asiaOpenHigh := math.max(asiaOpenHigh, high)
    asiaOpenLow := math.min(asiaOpenLow, low)

    box.set_right(asiaOpenBox, bar_index)
    box.set_top(asiaOpenBox, asiaOpenHigh)
    box.set_bottom(asiaOpenBox, asiaOpenLow)

//====================================================
// LONDON OPENING RANGE BOX (15 MIN)
//====================================================
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
         bgcolor=openingColor,
         border_color=color.orange,
         border_width=3)

if inLondonOpen
    londonOpenHigh := math.max(londonOpenHigh, high)
    londonOpenLow := math.min(londonOpenLow, low)

    box.set_right(londonOpenBox, bar_index)
    box.set_top(londonOpenBox, londonOpenHigh)
    box.set_bottom(londonOpenBox, londonOpenLow)

//====================================================
// NY OPENING RANGE BOX (7:30 → 7:45)
//====================================================
var box nyOpenBox = na
var float nyOpenHigh = na
var float nyOpenLow = na

if inNYOpen and not inNYOpen[1]
    nyOpenHigh := high
    nyOpenLow := low

    nyOpenBox := box.new(
         left=bar_index,
         right=bar_index,
         top=high,
         bottom=low,
         bgcolor=openingColor,
         border_color=color.orange,
         border_width=3)

if inNYOpen
    nyOpenHigh := math.max(nyOpenHigh, high)
    nyOpenLow := math.min(nyOpenLow, low)

    box.set_right(nyOpenBox, bar_index)
    box.set_top(nyOpenBox, nyOpenHigh)
    box.set_bottom(nyOpenBox, nyOpenLow)
````
