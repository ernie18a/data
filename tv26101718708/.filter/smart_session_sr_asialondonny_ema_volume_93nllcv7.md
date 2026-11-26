# Smart Session S&R (Asia/London/NY) + EMA + Volume

- url: https://www.tradingview.com/script/93NLlCv7-Smart-Session-S-R-Asia-London-NY-EMA-Volume/
- type: indicator
- pine_id: PUB;11a84789eb7543068581a594aaf3a4bd
- version: 1.0

## Description

Best works in all time frames,  this is my first indicator on levels and price action from previous candles taken one hour support and resistance from session 1st candle and 20 and 200 EMA. We can see bullish candles if it is closes five minute candle above resistance from one hour and below support red colour candidate five minutes also same you can check back test and try with minimum lot, thank you.

## Source Code

````pine
//@version=6
indicator("Smart Session S&R (Asia/London/NY) + EMA + Volume", overlay=true, max_lines_count=500)

// =====================
// EMA SETTINGS
// =====================
ema20 = ta.ema(close, 20)
ema200 = ta.ema(close, 200)

plot(ema20, "EMA 20", color=color.orange, linewidth=2)
plot(ema200, "EMA 200", color=color.blue, linewidth=2)

// =====================
// SESSION SETTINGS (UTC)
// =====================
asiaHour   = input.int(0,  "Asia Session Start (UTC)")
londonHour = input.int(8,  "London Session Start (UTC)")
nyHour     = input.int(13, "New York Session Start (UTC)")

// =====================
// SESSION DETECTION
// =====================
asiaStart   = hour(time, "UTC") == asiaHour and minute(time) == 0
londonStart = hour(time, "UTC") == londonHour and minute(time) == 0
nyStart     = hour(time, "UTC") == nyHour and minute(time) == 0

// =====================
// SESSION LEVELS
// =====================
var float asiaSup = na
var float asiaRes = na

var float londonSup = na
var float londonRes = na

var float nySup = na
var float nyRes = na

if asiaStart
    asiaRes := math.max(open, close)
    asiaSup := math.min(open, close)

if londonStart
    londonRes := math.max(open, close)
    londonSup := math.min(open, close)

if nyStart
    nyRes := math.max(open, close)
    nySup := math.min(open, close)

// =====================
// PLOTS
// =====================
plot(asiaRes, "Asia Resistance", color=color.red, linewidth=2)
plot(asiaSup, "Asia Support", color=color.green, linewidth=2)

plot(londonRes, "London Resistance", color=color.maroon, linewidth=2)
plot(londonSup, "London Support", color=color.lime, linewidth=2)

plot(nyRes, "NY Resistance", color=color.purple, linewidth=2)
plot(nySup, "NY Support", color=color.aqua, linewidth=2)

// =====================
// VOLUME CONFIRMATION
// =====================
volAvg = ta.sma(volume, 20)
highVol = volume > volAvg * 1.2

// =====================
// PRICE ACTION
// =====================
bullishBreak = close > high[1] and close > open
bearishBreak = close < low[1] and close < open

// =====================
// TREND FILTER
// =====================
bullTrend = close > ema20 and ema20 > ema200
bearTrend = close < ema20 and ema20 < ema200

// =====================
// BREAKOUT CONDITIONS
// =====================
highestRes = math.max(math.max(asiaRes, londonRes), nyRes)
lowestSup  = math.min(math.min(asiaSup, londonSup), nySup)

buySignal =
 bullTrend and
 close > highestRes and
 bullishBreak and
 highVol

sellSignal =
 bearTrend and
 close < lowestSup and
 bearishBreak and
 highVol

// =====================
// RETEST CONDITIONS
// =====================
buyRetest =
 bullTrend and
 low <= highestRes and
 close > highestRes

sellRetest =
 bearTrend and
 high >= lowestSup and
 close < lowestSup

// =====================
// SIGNALS
// =====================
plotshape(buySignal,
     title="BUY Breakout",
     location=location.belowbar,
     color=color.green,
     style=shape.labelup,
     text="BUY")

plotshape(sellSignal,
     title="SELL Breakdown",
     location=location.abovebar,
     color=color.red,
     style=shape.labeldown,
     text="SELL")

plotshape(buyRetest,
     title="BUY Retest",
     location=location.belowbar,
     color=color.lime,
     style=shape.triangleup,
     size=size.small)

plotshape(sellRetest,
     title="SELL Retest",
     location=location.abovebar,
     color=color.orange,
     style=shape.triangledown,
     size=size.small)

// =====================
// ALERTS
// =====================
alertcondition(buySignal, "BUY", "Bullish breakout confirmed")
alertcondition(sellSignal, "SELL", "Bearish breakdown confirmed")
alertcondition(buyRetest, "BUY Retest", "Bullish retest detected")
alertcondition(sellRetest, "SELL Retest", "Bearish retest detected")
````
