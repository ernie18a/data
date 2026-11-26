# NQ.TRADES V4.6 (Clean + ICT Sessions)

- url: https://www.tradingview.com/script/Z0AEW9O7-NQ-TRADES-V4-6-Clean-ICT-Sessions/
- type: indicator
- pine_id: PUB;c2f39e3841fe4ff7b813d423cc877d43
- version: 1.0

## Description

trade helper , a+ setups, buys and sells dhrthrhrgrthhhgtyhbtebcbbtyebybhbvsdbfbvdfb

## Source Code

````pine
//@version=5
indicator("NQ.TRADES V4.6 (Clean + ICT Sessions)", overlay=true)

// === TIME SESSIONS ===
// Adjust if needed for your timezone
asiaSession = (hour >= 18 or hour < 0)   // 6PM–12AM EST
londonSession = (hour >= 2 and hour < 5) // 2AM–5AM EST

// === TRACK SESSION HIGHS/LOWS ===
var float asiaHigh = na
var float asiaLow = na
var float londonHigh = na
var float londonLow = na

// Reset sessions
if (hour == 18)
    asiaHigh := high
    asiaLow := low

if (hour == 2)
    londonHigh := high
    londonLow := low

// Update session levels
if asiaSession
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

if londonSession
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)

// Plot sessions
plot(asiaHigh, color=color.blue, linewidth=2, title="Asia High")
plot(asiaLow, color=color.blue, linewidth=2, title="Asia Low")

plot(londonHigh, color=color.purple, linewidth=2, title="London High")
plot(londonLow, color=color.purple, linewidth=2, title="London Low")

// === BASIC DATA ===
priceRange = high - low
body = close - open
vol = volume

// === DELTA ===
delta = priceRange != 0 ? vol * (body / priceRange) : 0
deltaEMA = ta.ema(delta, 5)

buyPressure = delta > deltaEMA
sellPressure = delta < deltaEMA

// === TREND (HIDDEN) ===
fastMA = ta.ema(close, 20)
slowMA = ta.ema(close, 50)

bullish = fastMA > slowMA
bearish = fastMA < slowMA
chop = math.abs(fastMA - slowMA) < syminfo.mintick * 50

// === SWEEPS ===
sweepHigh = high > ta.highest(high, 10)[1]
sweepLow = low < ta.lowest(low, 10)[1]

// === TRAPS ===
trapShort = sweepHigh and close < open
trapLong = sweepLow and close > open

// === ENTRIES ===
shortEntry = bearish and trapShort and sellPressure
longEntry = bullish and trapLong and buyPressure

// === VISUALS ===

// Background bias
bgcolor(bullish ? color.new(color.green, 90) : bearish ? color.new(color.red, 90) : na)

// Chop filter
bgcolor(chop ? color.new(color.yellow, 85) : na)

// Entries
plotshape(shortEntry, location=location.abovebar,
     color=color.red, style=shape.labeldown, text="SELL")

plotshape(longEntry, location=location.belowbar,
     color=color.green, style=shape.labelup, text="BUY")

// Traps
plotshape(trapShort, location=location.abovebar,
     color=color.orange, style=shape.triangledown, size=size.small)

plotshape(trapLong, location=location.belowbar,
     color=color.orange, style=shape.triangleup, size=size.small)
````
