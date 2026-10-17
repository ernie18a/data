# Sessions UTC+1 (Full Width Boxes)

- url: https://www.tradingview.com/script/uSmzQefS-Sessions-UTC-1-Full-Width-Boxes/
- type: indicator
- pine_id: PUB;1abdda2cb13a4792927d8df393c75fd4
- version: 1.0

## Description

session times that split the trading day into 3 sessions and track highs and lows

## Source Code

````pine
//@version=6
indicator("Sessions UTC+1 (Full Width Boxes)", overlay=true)

// === SESSION TIMES ===
asia     = "0000-0800"
london   = "0800-1300"
newyork  = "1300-2200"

// session lengths in minutes
asiaLen   = 8 * 60
londonLen = 6 * 60
nyLen     = 9 * 60

// convert to bars
barsInSession(lenMinutes) =>
    math.round(lenMinutes / timeframe.multiplier)

// === DETECTION ===
inAsia    = not na(time(timeframe.period, asia, "UTC+1"))
inLondon  = not na(time(timeframe.period, london, "UTC+1"))
inNY      = not na(time(timeframe.period, newyork, "UTC+1"))

asiaStart = inAsia and not inAsia[1]
lonStart  = inLondon and not inLondon[1]
nyStart   = inNY and not inNY[1]

// === STORAGE ===
var float aHigh = na
var float aLow  = na
var float lHigh = na
var float lLow  = na
var float nHigh = na
var float nLow  = na

var box aBox = na
var box lBox = na
var box nBox = na

// === ASIA ===
if asiaStart
    aHigh := high
    aLow  := low
    bars = barsInSession(asiaLen)

    aBox := box.new(
        left = bar_index,
        right = bar_index + bars,
        top = aHigh,
        bottom = aLow,
        bgcolor = color.new(color.blue, 85),
        border_color = color.blue
    )

if inAsia
    aHigh := math.max(aHigh, high)
    aLow  := math.min(aLow, low)

    box.set_top(aBox, aHigh)
    box.set_bottom(aBox, aLow)


// === LONDON ===
if lonStart
    lHigh := high
    lLow  := low
    bars = barsInSession(londonLen)

    lBox := box.new(
        left = bar_index,
        right = bar_index + bars,
        top = lHigh,
        bottom = lLow,
        bgcolor = color.new(color.green, 85),
        border_color = color.green
    )

if inLondon
    lHigh := math.max(lHigh, high)
    lLow  := math.min(lLow, low)

    box.set_top(lBox, lHigh)
    box.set_bottom(lBox, lLow)


// === NEW YORK ===
if nyStart
    nHigh := high
    nLow  := low
    bars = barsInSession(nyLen)

    nBox := box.new(
        left = bar_index,
        right = bar_index + bars,
        top = nHigh,
        bottom = nLow,
        bgcolor = color.new(color.red, 85),
        border_color = color.red
    )

if inNY
    nHigh := math.max(nHigh, high)
    nLow  := math.min(nLow, low)

    box.set_top(nBox, nHigh)
    box.set_bottom(nBox, nLow)
````
