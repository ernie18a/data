# ELITE SYSTEM PRO (Clean Final)

- url: https://www.tradingview.com/script/vD5Ka407-ELITE-SYSTEM-PRO-Clean-Final/
- type: indicator
- pine_id: PUB;00655a2363564b69908f46c66801ff86
- version: 1.0

## Description

This is a script using the moving averages. 9,21 and 50 day.  Combined with the stochastic to indicate when to buy or sell.  To be used on the higher time frames.

## Source Code

````pine
//@version=6
indicator('ELITE SYSTEM PRO (Clean Final)', overlay = true)

// === INPUTS ===
fastLength = input.int(9, 'Fast SMA')
slowLength = input.int(21, 'Slow SMA')
trendLength = input.int(50, 'Trend SMA')
rsiLength = input.int(14, 'RSI Length')
swingLookback = input.int(5, 'Swing Lookback')
minScore = input.int(5, 'Minimum Score')

// === NY SESSION ===
inSession = not na(time(timeframe.period, '0930-1600'))

// === INDICATORS ===
smaFast = ta.sma(close, fastLength)
smaSlow = ta.sma(close, slowLength)
trendMA = ta.sma(close, trendLength)
rsi = ta.rsi(close, rsiLength)

// === HTF TREND ===
htfClose = request.security(syminfo.tickerid, '60', close)
htfMA = request.security(syminfo.tickerid, '60', ta.sma(close, 50))
htfBull = htfClose > htfMA
htfBear = htfClose < htfMA

// === STOCH ===
k = ta.stoch(close, high, low, 10)

// === SWINGS ===
swingLow = low == ta.lowest(low, swingLookback)
swingHigh = high == ta.highest(high, swingLookback)

var float prevLow = na
var float prevKLow = na
var float prevHigh = na
var float prevKHigh = na

if swingLow
    prevLow := low
    prevKLow := k
    prevKLow

if swingHigh
    prevHigh := high
    prevKHigh := k
    prevKHigh

bullishDiv = swingLow and not na(prevLow[1]) and low < prevLow[1] and k > prevKLow[1]
bearishDiv = swingHigh and not na(prevHigh[1]) and high > prevHigh[1] and k < prevKHigh[1]

// === SIGNAL CONDITIONS ===
bullishCross = ta.crossover(smaFast, smaSlow)
bearishCross = ta.crossunder(smaFast, smaSlow)

trendBull = close > trendMA
trendBear = close < trendMA

atr = ta.atr(14)
validVolatility = atr > ta.sma(atr, 20)

pullbackBuy = close > smaFast and low <= smaFast
pullbackSell = close < smaFast and high >= smaFast

// === SCORING ===
buyScore = (bullishCross ? 1 : 0) + (rsi > 50 ? 1 : 0) + (bullishDiv ? 1 : 0) + (trendBull ? 1 : 0) + (htfBull ? 1 : 0) + (validVolatility ? 1 : 0) + (pullbackBuy ? 1 : 0)

sellScore = (bearishCross ? 1 : 0) + (rsi < 50 ? 1 : 0) + (bearishDiv ? 1 : 0) + (trendBear ? 1 : 0) + (htfBear ? 1 : 0) + (validVolatility ? 1 : 0) + (pullbackSell ? 1 : 0)

// === FINAL SIGNALS ===
buySignal = buyScore >= minScore and inSession
sellSignal = sellScore >= minScore and inSession

// === PLOTS ===
plot(smaFast, color = color.blue, title = 'SMA 9')
plot(smaSlow, color = color.orange, title = 'SMA 21')
plot(trendMA, color = color.yellow, title = 'Trend SMA 50')

plotshape(series = buySignal, location = location.belowbar, color = color.green, style = shape.labelup, text = 'BUY')
plotshape(series = sellSignal, location = location.abovebar, color = color.red, style = shape.labeldown, text = 'SELL')

// === ALERTS ===
alertcondition(buySignal, title = 'ELITE BUY', message = 'Elite Buy Signal (NY Session)')
alertcondition(sellSignal, title = 'ELITE SELL', message = 'Elite Sell Signal (NY Session)')
````
