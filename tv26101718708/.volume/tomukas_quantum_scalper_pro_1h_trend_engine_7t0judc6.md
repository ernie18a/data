# Tomukas Quantum Scalper [PRO] | 1H Trend Engine

- url: https://www.tradingview.com/script/7T0JUDc6-Tomukas-Quantum-Scalper-PRO-1H-Trend-Engine/
- type: strategy
- pine_id: PUB;054d52fb104c42e6804bd77020fe9579
- version: 1.0

## Description

Tomukas Quantum Scalper [PRO] is built around one core principle: trade with the higher-timeframe trend instead of chasing every move.

The strategy uses the 1-hour trend as its directional filter, then waits for momentum, pullback, and confirmation to align before entering. Multiple conditions—including trend structure, momentum, strength, and volatility—work together to reduce low-quality signals and focus on cleaner opportunities.

Designed for active traders who value discipline over frequency, the script emphasizes confirmation rather than prediction. It is suitable for forward testing, optimization, and integration into a structured trading plan.

Features
• 1H trend direction filter
• Momentum confirmation
• Pullback-based entries
• ADX and RSI filtering
• MACD confirmation
• ATR-based trade management
• Strategy backtesting

This script is intended as a decision-support tool and should be optimized for the market and timeframe you trade before being used in live conditions.

## Source Code

````pine
//@version=6
strategy("Tomukas Premium Signals Only", overlay=true, pyramiding=0, process_orders_on_close=true)

fastEMA  = input.int(3, "EMA Fast")
slowEMA  = input.int(6, "EMA Slow")
pullEMA  = input.int(25, "Pullback EMA")
trendEMA = input.int(50, "Trend EMA")
macroEMA = input.int(200, "Macro EMA")

rsiLen  = input.int(14, "RSI Length")
rsiBuy  = input.int(55, "RSI Buy Above")
rsiSell = input.int(45, "RSI Sell Below")

adxLen = input.int(14, "ADX Length")
adxMin = input.float(22.0, "Min ADX")

atrLen = input.int(14, "ATR Length")
slATR  = input.float(1.2, "Stop ATR")
tpATR  = input.float(1.8, "Take Profit ATR")
trailATR = input.float(1.0, "Trail ATR")

volLen = input.int(20, "Volume MA")
useVol = input.bool(true, "Use Volume Filter")

ema3   = ta.ema(close, fastEMA)
ema6   = ta.ema(close, slowEMA)
ema25  = ta.ema(close, pullEMA)
ema50  = ta.ema(close, trendEMA)
ema200 = ta.ema(close, macroEMA)

[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)
[plusDI, minusDI, adx] = ta.dmi(adxLen, adxLen)

rsi = ta.rsi(close, rsiLen)
atr = ta.atr(atrLen)
volMA = ta.sma(volume, volLen)
volOk = not useVol or volume > volMA

bullTrend = close > ema50 and ema50 > ema200
bearTrend = close < ema50 and ema50 < ema200

longPullback = low <= ema25 or low <= ema50
shortPullback = high >= ema25 or high >= ema50

longSignal =
     bullTrend and
     longPullback and
     ta.crossover(ema3, ema6) and
     ta.crossover(macdLine, signalLine) and
     rsi > rsiBuy and
     plusDI > minusDI and
     adx > adxMin and
     volOk

shortSignal =
     bearTrend and
     shortPullback and
     ta.crossunder(ema3, ema6) and
     ta.crossunder(macdLine, signalLine) and
     rsi < rsiSell and
     minusDI > plusDI and
     adx > adxMin and
     volOk

if longSignal
    strategy.close("Short")
    strategy.entry("Long", strategy.long)

if shortSignal
    strategy.close("Long")
    strategy.entry("Short", strategy.short)

if strategy.position_size > 0
    strategy.exit("Long Exit", "Long", stop=strategy.position_avg_price - atr * slATR, limit=strategy.position_avg_price + atr * tpATR, trail_points=atr * trailATR)

if strategy.position_size < 0
    strategy.exit("Short Exit", "Short", stop=strategy.position_avg_price + atr * slATR, limit=strategy.position_avg_price - atr * tpATR, trail_points=atr * trailATR)

plotshape(longSignal, title="BUY", style=shape.labelup, text="BUY", location=location.belowbar, color=color.rgb(0,255,209), textcolor=color.black, size=size.small)
plotshape(shortSignal, title="SELL", style=shape.labeldown, text="SELL", location=location.abovebar, color=color.rgb(255,0,170), textcolor=color.white, size=size.small)

bgcolor(bullTrend ? color.new(color.rgb(0,255,209), 96) : bearTrend ? color.new(color.rgb(255,0,170), 96) : na)
````
