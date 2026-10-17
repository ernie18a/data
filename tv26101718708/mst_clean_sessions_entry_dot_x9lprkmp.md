# MST Clean Sessions + Entry Dot

- url: https://www.tradingview.com/script/x9LPrkmp-MST-Clean-Sessions-Entry-Dot/
- type: indicator
- pine_id: PUB;688d85802d764470a4c6f6a75c1e0dea
- version: 1.0

## Description

Helps identify Asia, London, New York session, works best on 1m TF, 5m TF for entry spotted, use 4H, 1H to spot the trend, Uptrend look for buy entry, downtrend look for sell entry.

## Source Code

````pine
//@version=5
indicator("MST Clean Sessions + Entry Dot", overlay=true, max_boxes_count=10, max_labels_count=10)

//====================
// SESSIONS
//====================
asiaSession   = input.session("2000-0200", "Asia")
londonSession = input.session("0300-0600", "London")
nySession     = input.session("0930-1200", "New York")

inAsia   = not na(time(timeframe.period, asiaSession, "America/New_York"))
inLondon = not na(time(timeframe.period, londonSession, "America/New_York"))
inNY     = not na(time(timeframe.period, nySession, "America/New_York"))

//====================
// COLORS
//====================
asiaColor   = color.new(color.blue, 85)
londonColor = color.new(color.green, 85)
nyColor     = color.new(color.red, 85)

//====================
// ASIA BOX + NAME
//====================
var float asiaHigh = na
var float asiaLow  = na
var box asiaBox    = na
var label asiaName = na

if inAsia and not inAsia[1]
    asiaHigh := high
    asiaLow  := low
    asiaBox := box.new(bar_index, high, bar_index, low, bgcolor=asiaColor)
    asiaName := label.new(bar_index, high, "ASIA", style=label.style_label_down, color=color.blue, textcolor=color.white)

if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow  := math.min(asiaLow, low)
    box.set_right(asiaBox, bar_index)
    box.set_top(asiaBox, asiaHigh)
    box.set_bottom(asiaBox, asiaLow)
    label.set_xy(asiaName, bar_index, asiaHigh)

//====================
// LONDON BOX + NAME
//====================
var float londonHigh = na
var float londonLow  = na
var box londonBox    = na
var label londonName = na

if inLondon and not inLondon[1]
    londonHigh := high
    londonLow  := low
    londonBox := box.new(bar_index, high, bar_index, low, bgcolor=londonColor)
    londonName := label.new(bar_index, high, "LONDON", style=label.style_label_down, color=color.green, textcolor=color.white)

if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow  := math.min(londonLow, low)
    box.set_right(londonBox, bar_index)
    box.set_top(londonBox, londonHigh)
    box.set_bottom(londonBox, londonLow)
    label.set_xy(londonName, bar_index, londonHigh)

//====================
// NY BOX + NAME
//====================
var float nyHigh = na
var float nyLow  = na
var box nyBox    = na
var label nyName = na

if inNY and not inNY[1]
    nyHigh := high
    nyLow  := low
    nyBox := box.new(bar_index, high, bar_index, low, bgcolor=nyColor)
    nyName := label.new(bar_index, high, "NEW YORK", style=label.style_label_down, color=color.red, textcolor=color.white)

if inNY
    nyHigh := math.max(nyHigh, high)
    nyLow  := math.min(nyLow, low)
    box.set_right(nyBox, bar_index)
    box.set_top(nyBox, nyHigh)
    box.set_bottom(nyBox, nyLow)
    label.set_xy(nyName, bar_index, nyHigh)

//====================
// MINIMAL ENTRY LOGIC
//====================

// Liquidity sweep (simple + clean)
bullSweep = low < low[1]
bearSweep = high > high[1]

// Rejection candle
bullReject = close > open
bearReject = close < open

// Engulf confirmation
bullEngulf = close > high[1]
bearEngulf = close < low[1]

// FINAL ENTRY (your style)
buy  = bullSweep and bullReject and bullEngulf
sell = bearSweep and bearReject and bearEngulf

//====================
// ENTRY DOT (MINIMAL)
//====================
plotshape(buy,  style=shape.circle, location=location.belowbar, color=color.green, size=size.tiny)
plotshape(sell, style=shape.circle, location=location.abovebar, color=color.red, size=size.tiny)

//====================
// ALERTS
//====================
alertcondition(buy, "BUY", "Entry Buy")
alertcondition(sell, "SELL", "Entry Sell")
````
