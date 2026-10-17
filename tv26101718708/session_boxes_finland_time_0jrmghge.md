# Session Boxes Finland Time

- url: https://www.tradingview.com/script/0JrMGHge-Session-Boxes-Finland-Time/
- type: indicator
- pine_id: PUB;1cc5972e903048d8b40ce9eab16f3068
- version: 1.0

## Description

this indicitor show the the forex Session based on finland time.

## Source Code

````pine
//@version=6
indicator("Session Boxes Finland Time", overlay = true)

// Timezone
string TZ = "Europe/Helsinki"

// Sessions
asiaSession    = not na(time(timeframe.period, "0200-1100", TZ))
londonSession  = not na(time(timeframe.period, "1000-1900", TZ))
newyorkSession = not na(time(timeframe.period, "1500-2359", TZ))

// Variables
var box asiaBox = na
var box londonBox = na
var box nyBox = na

var float asiaHigh = na
var float asiaLow = na

var float londonHigh = na
var float londonLow = na

var float nyHigh = na
var float nyLow = na

// ================= ASIA =================
if asiaSession and not asiaSession[1]
    asiaHigh := high
    asiaLow := low
    
    asiaBox := box.new(
         left = bar_index,
         right = bar_index,
         top = high,
         bottom = low,
         bgcolor = color.new(color.aqua, 88),
         border_color = color.new(color.aqua, 50))

if asiaSession
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

    box.set_right(asiaBox, bar_index)
    box.set_top(asiaBox, asiaHigh)
    box.set_bottom(asiaBox, asiaLow)

if asiaSession and not asiaSession[1]
    label.new(
         bar_index,
         asiaLow,
         "AS",
         style = label.style_label_up,
         size = size.tiny,
         color = color.new(color.aqua, 0),
         textcolor = color.white)

// ================= LONDON =================
if londonSession and not londonSession[1]
    londonHigh := high
    londonLow := low
    
    londonBox := box.new(
         left = bar_index,
         right = bar_index,
         top = high,
         bottom = low,
         bgcolor = color.new(color.green, 88),
         border_color = color.new(color.green, 50))

if londonSession
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)

    box.set_right(londonBox, bar_index)
    box.set_top(londonBox, londonHigh)
    box.set_bottom(londonBox, londonLow)

if londonSession and not londonSession[1]
    label.new(
         bar_index,
         londonLow,
         "LO",
         style = label.style_label_up,
         size = size.tiny,
         color = color.new(color.green, 0),
         textcolor = color.white)

// ================= NEW YORK =================
if newyorkSession and not newyorkSession[1]
    nyHigh := high
    nyLow := low
    
    nyBox := box.new(
         left = bar_index,
         right = bar_index,
         top = high,
         bottom = low,
         bgcolor = color.new(color.orange, 88),
         border_color = color.new(color.orange, 50))

if newyorkSession
    nyHigh := math.max(nyHigh, high)
    nyLow := math.min(nyLow, low)

    box.set_right(nyBox, bar_index)
    box.set_top(nyBox, nyHigh)
    box.set_bottom(nyBox, nyLow)

if newyorkSession and not newyorkSession[1]
    label.new(
         bar_index,
         nyLow,
         "NY",
         style = label.style_label_up,
         size = size.tiny,
         color = color.new(color.orange, 0),
         textcolor = color.white)
````
