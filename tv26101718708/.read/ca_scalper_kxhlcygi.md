# C.A Scalper 

- url: https://www.tradingview.com/script/KxhlcYgi-C-A-Scalper/
- type: indicator
- pine_id: PUB;f3fbb0f89cca4930a8eccf8dd9e5dbc5
- version: 1.0

## Description

C.A Scalper helps to scalp futuresC.A Scalper helps to scalp futuresC.A Scalper helps to scalp futuresC.A Scalper helps to scalp futures

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CirisAshley
//@version=6
indicator("Sniper Scalping System (A+ Only) CLEAN", overlay=true)

// === DAILY RESET ===
isNewDay = ta.change(time("D")) != 0

var float open15 = na
var float close15 = na

if isNewDay
    open15 := na
    close15 := na

if na(open15)
    open15 := open
    close15 := close

bullish = close15 > open15
bearish = close15 < open15

bgcolor(bullish ? color.new(color.green, 94) : bearish ? color.new(color.red, 94) : na)

// === EMA TREND ===
ema9 = ta.ema(close, 9)
ema21 = ta.ema(close, 21)

trendUp = ema9 > ema21 and close > ema21
trendDown = ema9 < ema21 and close < ema21

emaColor = trendUp ? color.green : trendDown ? color.red : color.gray

plot(ema9, color=emaColor, linewidth=2)
plot(ema21, color=emaColor, linewidth=2)

// === SUPPORT / RESISTANCE ===
lookback = 15
resistance = ta.highest(high, lookback)
support = ta.lowest(low, lookback)

plot(resistance, color=color.orange)
plot(support, color=color.yellow)

// === RSI FILTER ===
rsi = ta.rsi(close, 14)
rsiBull = rsi > 65
rsiBear = rsi < 35

// === ORDER BLOCKS ===
bullishOB = close[1] < open[1] and close > high[1]
bearishOB = close[1] > open[1] and close < low[1]

var float bullTop = na
var float bullBottom = na
var float bearTop = na
var float bearBottom = na

if bullishOB
    bullTop := high[1]
    bullBottom := low[1]

if bearishOB
    bearTop := high[1]
    bearBottom := low[1]

inBullOB = not na(bullTop) and close >= bullBottom and close <= bullTop
inBearOB = not na(bearTop) and close <= bearTop and close >= bearBottom

// === LOCATION FILTER ===
nearSupport = close <= support * 1.002
nearResistance = close >= resistance * 0.998

// === A+ ENTRY CONDITIONS ===
longSignal = (
bullish and
trendUp and
rsiBull and
ta.crossover(close, ema9) and
(nearSupport or inBullOB)
)

shortSignal = (
bearish and
trendDown and
rsiBear and
ta.crossunder(close, ema9) and
(nearResistance or inBearOB)
)

// === SIGNALS ===
plotshape(longSignal, location=location.belowbar, style=shape.triangleup, size=size.small, color=color.green)
plotshape(shortSignal, location=location.abovebar, style=shape.triangledown, size=size.small, color=color.red)
````
