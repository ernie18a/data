# Mean Reversion at or under 200MA

- url: https://www.tradingview.com/script/ERAn3ljA-Mean-Reversion-at-or-under-200MA/
- type: strategy
- pine_id: PUB;20c48e333ea04fb4aabb4d59812c36c0
- version: 1.0

## Description

This strategy is based on the 30 minute of the S&P futures chart, MES

A Long Buy will be executed if, the EMA 9 or price comes down to or under the 200 MA, AND THEN the slope of the ema 9 subsequently changes from negative to positive.

The buy will be executed either; at a retest of the local lows (defined by the lowest wick between the most recent red candle that is subsequently followed by a green candle) (a retest is defined as 70% retrace from the local highs (inversely defined from local lows) to the local lows), or if a retest of the lows fails to occur, a market order will be executed at the local highs.

With a fixed position size of 10 contracts, the take profits will be established as such; 2 contracts sold up 6 points of profit, the next two will be sold up 10 points of profit, and the remaining 2 contracts will be sold for 20 points of profit. As soon as the first trim is made, a stop loss is placed at break even. Further, as soon as the second trim is made, the stop loss will be moved to +5 profit points. 

In the instance that the ema 9 returns to downward sloping, stop orders will be executed. This will trigger sells either at local lows or local highs.

Kind of just made this for a class project, but the logic is sound, and the results are formidable thus far - enjoy :)

## Source Code

````pine
//@version=5
strategy(title="MES 30m EMA9/200 Retest (Dynamic Cap)", overlay=true)

// ==========================
// Timeframe lock
// ==========================
if timeframe.period != "30"
    runtime.error("Use 30-minute timeframe only")

// ==========================
// Indicators
// ==========================
ema9 = ta.ema(close, 9)
sma200 = ta.sma(close, 200)
atr = ta.atr(14)

plot(ema9, color=color.blue)
plot(sma200, color=color.orange)

// ==========================
// EMA slope
// ==========================
emaSlope = ema9 - ema9[1]

slopeUp = emaSlope > 0 and emaSlope[1] <= 0
slopeDown = emaSlope < 0 and emaSlope[1] >= 0

// ==========================
// STRUCTURE
// ==========================
isLocalLow = close > open and close[1] < open[1]
isLocalHigh = close < open and close[1] > open[1]

var float trackedLow = na
var float trackedHigh = na

if isLocalLow
    trackedLow := math.min(low, low[1])

if isLocalHigh
    trackedHigh := math.max(high, high[1])

// ==========================
// ARM LOGIC (your original edge)
// ==========================
var bool armed = false

touchEvent = ema9 <= sma200 or close <= sma200

if touchEvent
    armed := true

longSetup = armed and slopeUp

if longSetup
    armed := false

// ==========================
// 🔥 DYNAMIC RETEST ZONE (UPDATED LOGIC)
// ==========================

// cap upper boundary depending on regime
upperCap = ema9 < sma200 ? math.min(trackedHigh, sma200) : sma200

// now define retrace range dynamically
retestPrice = not na(trackedLow) and not na(upperCap) ?
     trackedLow + (upperCap - trackedLow) * 0.30 : na

// zone logic
inRetestZone = not na(retestPrice) and low <= upperCap and high >= retestPrice

// confirmation (kept from your edge)
reclaimMomentum = close > ema9 or close > high[1]

// ==========================
// ENTRY
// ==========================
if longSetup and strategy.position_size == 0
    if inRetestZone and reclaimMomentum
        strategy.entry("Long", strategy.long, qty=10)
    else if close > sma200 and reclaimMomentum
        strategy.entry("Long", strategy.long, qty=10)

// ==========================
// MANAGEMENT (UNCHANGED EDGE)
// ==========================
entry = strategy.position_avg_price

if strategy.position_size > 0 and not slopeDown

    strategy.exit("TP1", "Long", qty=6, limit=entry + 6)
    strategy.exit("TP2", "Long", qty=2, limit=entry + 10)
    strategy.exit("TP3", "Long", qty=2, limit=entry + 20)

    if strategy.position_size <= 4 and strategy.position_size > 2
        strategy.exit("BE_Stop", "Long", stop=entry)

    if strategy.position_size <= 2
        strategy.exit("Trail_Stop", "Long", stop=entry + 5)

// ==========================
// DEFENSIVE MODE
// ==========================
if strategy.position_size > 0 and slopeDown
    strategy.cancel("TP1")
    strategy.cancel("TP2")
    strategy.cancel("TP3")
    strategy.cancel("BE_Stop")
    strategy.cancel("Trail_Stop")

    strategy.exit("DEF", "Long",
         stop=trackedLow - atr * 0.5,
         limit=trackedHigh)

// ==========================
// VISUALS
// ==========================
plot(retestPrice, color=color.purple)
plot(upperCap, color=color.red)
````
