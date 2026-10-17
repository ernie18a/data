# Gagan NDX 15M Strict Pro Indicator

- url: https://www.tradingview.com/script/xuvrn8Ga-Gagan-NDX-15M-Strict-Pro-Indicator/
- type: indicator
- pine_id: PUB;7cea8560529946e297dfe2f6db8278f8
- version: 1.0

## Description

This indicator is designed for NDX / US Tech 100 15-minute chart trading. It combines VWAP, EMA 9, EMA 20, EMA 50, RSI, MACD, ATR, and candle strength filters to identify higher-quality CALL and PUT setups.

Features:
VWAP trend confirmation
EMA 9 / EMA 20 / EMA 50 trend filter
RSI momentum filter
MACD confirmation
Strong candle filter
ATR-based stop loss and take profit guide
CALL and PUT alert conditions

This indicator is built for cleaner signals and fewer trades. It is not financial advice and does not guarantee profit. Traders should always use proper risk management and wait for candle close confirmation before entering any trade.

## Source Code

````pine
//@version=6
indicator("Gagan NDX 15M Strict Pro Indicator", overlay=true)

// Core indicators
vwapLine = ta.vwap(hlc3)
ema9  = ta.ema(close, 9)
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
rsi   = ta.rsi(close, 14)
atr   = ta.atr(14)

// MACD
[macdLine, signalLine, hist] = ta.macd(close, 12, 26, 9)

// Strict trend filters
strongBull = close > vwapLine and ema9 > ema20 and ema20 > ema50 and rsi > 55 and hist > 0
strongBear = close < vwapLine and ema9 < ema20 and ema20 < ema50 and rsi < 45 and hist < 0

// Avoid weak candles
body = math.abs(close - open)
candleRange = high - low
strongCandle = candleRange > 0 and body / candleRange >= 0.55

// Signals only on first strict confirmation
callSignal = strongBull and strongCandle and not strongBull[1]
putSignal  = strongBear and strongCandle and not strongBear[1]

// ATR stop/target guide
callSL = close - atr * 1.3
callTP = close + atr * 2.0
putSL  = close + atr * 1.3
putTP  = close - atr * 2.0

plot(vwapLine, "VWAP", color=color.blue, linewidth=2)
plot(ema9, "EMA 9", color=color.yellow, linewidth=2)
plot(ema20, "EMA 20", color=color.orange, linewidth=2)
plot(ema50, "EMA 50", color=color.white, linewidth=2)

plotshape(callSignal, title="STRICT CALL", style=shape.labelup, text="STRICT CALL", location=location.belowbar, color=color.green, textcolor=color.white)
plotshape(putSignal, title="STRICT PUT", style=shape.labeldown, text="STRICT PUT", location=location.abovebar, color=color.red, textcolor=color.white)

bgcolor(strongBull ? color.new(color.green, 90) : strongBear ? color.new(color.red, 90) : na)

plot(callSignal ? callSL : na, "CALL SL", color=color.red, style=plot.style_linebr)
plot(callSignal ? callTP : na, "CALL TP", color=color.green, style=plot.style_linebr)
plot(putSignal ? putSL : na, "PUT SL", color=color.red, style=plot.style_linebr)
plot(putSignal ? putTP : na, "PUT TP", color=color.green, style=plot.style_linebr)

alertcondition(callSignal, title="STRICT CALL Alert", message="STRICT CALL: Strong 15M trend confirmed")
alertcondition(putSignal, title="STRICT PUT Alert", message="STRICT PUT: Strong 15M trend confirmed")
````
