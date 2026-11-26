# Smart Scalper PRO v6

- url: https://www.tradingview.com/script/PvrHw3HU-Smart-Scalper-PRO-v6/
- type: indicator
- pine_id: PUB;17875bd098f34ba6942813c0f00d1ae7
- version: 1.0

## Description

M5 indicator that generates signals based on trend with 50EMA, 200EMA and liquidity.

## Source Code

````pine
//@version=6
indicator("Smart Scalper PRO (Liquidity + BOS + RR) v6", overlay=true)

// === INPUTS ===
fastEMA = input.int(50, "Fast EMA")
slowEMA = input.int(200, "Slow EMA")
rr = input.float(2.0, "Risk:Reward", step=0.1)
sessionNY = input.session("0800-1200", "NY Session")

// === EMA ===
ema50 = ta.ema(close, fastEMA)
ema200 = ta.ema(close, slowEMA)

plot(ema50, color=color.orange)
plot(ema200, color=color.blue)

// === HTF (H1) ===
ema50_HTF = request.security(syminfo.tickerid, "60", ta.ema(close, fastEMA))
ema200_HTF = request.security(syminfo.tickerid, "60", ta.ema(close, slowEMA))

bullHTF = ema50_HTF > ema200_HTF
bearHTF = ema50_HTF < ema200_HTF

// === SESSION ===
inSession = not na(time(timeframe.period, sessionNY))

// === TREND ===
bullTrend = ema50 > ema200
bearTrend = ema50 < ema200

bullCross = ta.crossover(ema50, ema200)
bearCross = ta.crossunder(ema50, ema200)

// === TRACK FIRST PULLBACK ===
var bool waitBull = false
var bool waitBear = false

if bullCross
    waitBull := true
    waitBear := false

if bearCross
    waitBear := true
    waitBull := false

// === PIN BAR (STRICT) ===
candleRange = high - low
lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)

bullPin = lowerWick >= candleRange * 0.66 and close > open
bearPin = upperWick >= candleRange * 0.66 and close < open

// === ENGULFING ===
bullEngulf = close > open and close[1] < open[1] and close > open[1] and open < close[1]
bearEngulf = close < open and close[1] > open[1] and close < open[1] and open > close[1]

// === TOUCH EMA ===
touchEMA = low <= ema50 and high >= ema50

// === LIQUIDITY (basic equal highs/lows sweep) ===
equalHigh = high[1] == high[2]
equalLow = low[1] == low[2]

liqSweepBuy = low < low[1] and equalLow
liqSweepSell = high > high[1] and equalHigh

// === BOS (basic) ===
bosBull = high > high[1]
bosBear = low < low[1]

// === FINAL CONDITIONS ===
buySignal = waitBull and bullTrend and bullHTF and inSession and touchEMA and (bullPin or bullEngulf) and liqSweepBuy and bosBull
sellSignal = waitBear and bearTrend and bearHTF and inSession and touchEMA and (bearPin or bearEngulf) and liqSweepSell and bosBear

// Reset after entry
if buySignal
    waitBull := false

if sellSignal
    waitBear := false

// === SIGNALS ===
plotshape(buySignal, location=location.belowbar, color=color.green, style=shape.arrowup, size=size.small)
plotshape(sellSignal, location=location.abovebar, color=color.red, style=shape.arrowdown, size=size.small)

// === RR BOXES ===
var box rrBox = na

if buySignal
    sl = low
    tp = close + (close - sl) * rr
    rrBox := box.new(bar_index, tp, bar_index + 10, sl, border_color=color.green, bgcolor=color.new(color.green, 85))

if sellSignal
    sl = high
    tp = close - (sl - close) * rr
    rrBox := box.new(bar_index, sl, bar_index + 10, tp, border_color=color.red, bgcolor=color.new(color.red, 85))

// === ALERTS ===
alertcondition(buySignal, "BUY", "Smart Scalper PRO BUY")
alertcondition(sellSignal, "SELL", "Smart Scalper PRO SELL")
````
