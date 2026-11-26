# Mark Flow Signals Pro Beta

- url: https://www.tradingview.com/script/V61hMFc2-Mark-Flow-Signals-Pro-Beta/
- type: indicator
- pine_id: PUB;74028fbc56ec4e929d231efca228e9df
- version: 1.0

## Description

This is the new and improved script for buy and sell

## Source Code

````pine
//@version=5
indicator("WaveFlow Signals Pro", overlay=true)

// ===== INPUTS =====
htf = input.timeframe("240", "Higher Timeframe")
emaLen = input.int(20, "EMA Length")
bbLen = input.int(20, "Band Length")
bbMult = input.float(2.0, "Band Multiplier")

showEMA = input.bool(true, "Show EMA")
showBands = input.bool(true, "Show Bands")
showSignals = input.bool(true, "Show Signals")
showBG = input.bool(true, "Show Background")

// ===== EMA =====
ema20 = ta.ema(close, emaLen)

// ===== BAND CALCULATIONS =====
basis = ta.sma(close, bbLen)
dev = ta.stdev(close, bbLen) * bbMult

upperBand = basis + dev
lowerBand = basis - dev

upperMid = basis + (dev * 0.5)
lowerMid = basis - (dev * 0.5)

// ===== HIGHER TIMEFRAME TREND =====
htfEMA = request.security(syminfo.tickerid, htf, ta.ema(close, emaLen))

bullTrend = htfEMA > htfEMA[1]
bearTrend = htfEMA < htfEMA[1]

// ===== BUY CONDITIONS =====
// Longs ONLY allowed if HTF EMA20 trending UP

touchedLower = low <= lowerBand

closeBackAboveLower = close > lowerMid and close[1] <= lowerMid[1]

buySignal = bullTrend and touchedLower and closeBackAboveLower

// ===== SELL CONDITIONS =====
// Shorts ONLY allowed if HTF EMA20 trending DOWN

touchedUpper = high >= upperBand

closeBackBelowUpper = close < upperMid and close[1] >= upperMid[1]

sellSignal = bearTrend and touchedUpper and closeBackBelowUpper

// ===== EMA PLOT =====
plot(showEMA ? ema20 : na, title="EMA 20", color=color.white, linewidth=2)

// ===== BAND PLOTS =====
u1 = plot(showBands ? upperBand : na, color=color.green)
u2 = plot(showBands ? upperMid : na, color=color.new(color.green, 40))

l1 = plot(showBands ? lowerBand : na, color=color.red)
l2 = plot(showBands ? lowerMid : na, color=color.new(color.red, 40))

fill(u1, u2, color=color.new(color.green, 85))
fill(l1, l2, color=color.new(color.red, 85))

// ===== SIGNAL LABELS =====
plotshape(buySignal and showSignals, title="BUY", style=shape.labelup, location=location.belowbar, color=color.lime, text="BUY", textcolor=color.black, size=size.small)

plotshape(sellSignal and showSignals, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.white, size=size.small)

// ===== BACKGROUND =====
bgcolor(showBG ? bullTrend ? color.new(color.green, 92) : bearTrend ? color.new(color.red, 92) : na : na)

// ===== ALERTS =====
alertcondition(buySignal, title="BUY ALERT", message="WaveFlow BUY Signal")

alertcondition(sellSignal, title="SELL ALERT", message="WaveFlow SELL Signal")
````
