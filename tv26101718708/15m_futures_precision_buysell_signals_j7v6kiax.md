# 15m Futures Precision Buy/Sell Signals

- url: https://www.tradingview.com/script/j7V6kiaX-15m-Futures-Precision-Buy-Sell-Signals/
- type: indicator
- pine_id: PUB;a8781fa7738746fabc526bc58d0ac433
- version: 1.0

## Description

It’s built for 15-minute futures charts and gives cleaner BUY / SELL signals by combining:

21/55 EMA trend direction
1-hour 200 EMA higher-timeframe trend filter
RSI momentum confirmation
MACD momentum confirmation
ATR volatility filter
ATR-based stop and target levels
Optional regular-session filter

## Source Code

````pine
//@version=6
indicator("15m Futures Precision Buy/Sell Signals", shorttitle="15m Futures Signals", overlay=true, max_labels_count=500)
// Designed for 15-minute futures charts.
// Use alerts on confirmed candle closes to reduce intrabar false signals.
groupTrend = "Trend Filters"
fastEmaLen = input.int(21, "Fast EMA", minval=1, group=groupTrend)
slowEmaLen = input.int(55, "Slow EMA", minval=1, group=groupTrend)
htf = input.timeframe("60", "Higher Timeframe", group=groupTrend)
htfEmaLen = input.int(200, "Higher Timeframe EMA", minval=1, group=groupTrend)
groupMomentum = "Momentum Filters"
rsiLen = input.int(14, "RSI Length", minval=1, group=groupMomentum)
rsiBuyLevel = input.float(52.0, "RSI Buy Threshold", minval=1, maxval=99, step=0.5, group=groupMomentum)
rsiSellLevel = input.float(48.0, "RSI Sell Threshold", minval=1, maxval=99, step=0.5, group=groupMomentum)
macdFast = input.int(12, "MACD Fast", minval=1, group=groupMomentum)
macdSlow = input.int(26, "MACD Slow", minval=1, group=groupMomentum)
macdSignal = input.int(9, "MACD Signal", minval=1, group=groupMomentum)
groupVolatility = "Volatility And Risk"
atrLen = input.int(14, "ATR Length", minval=1, group=groupVolatility)
minAtrPercent = input.float(0.08, "Minimum ATR %", minval=0.0, step=0.01, group=groupVolatility)
stopAtrMult = input.float(1.5, "Stop ATR Multiple", minval=0.1, step=0.1, group=groupVolatility)
targetAtrMult = input.float(2.5, "Target ATR Multiple", minval=0.1, step=0.1, group=groupVolatility)
groupSession = "Session"
useSession = input.bool(true, "Use Session Filter", group=groupSession)
tradeSession = input.session("0930-1600", "Trading Session", group=groupSession)
fastEma = ta.ema(close, fastEmaLen)
slowEma = ta.ema(close, slowEmaLen)
htfEma = request.security(syminfo.tickerid, htf, ta.ema(close, htfEmaLen), barmerge.gaps_off, barmerge.lookahead_off)
rsi = ta.rsi(close, rsiLen)
[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSignal)
atr = ta.atr(atrLen)
atrPercent = atr / close * 100.0
inSession = not useSession or not na(time(timeframe.period, tradeSession))
enoughVolatility = atrPercent >= minAtrPercent
bullTrend = fastEma > slowEma and close > htfEma
bearTrend = fastEma < slowEma and close < htfEma
bullMomentum = rsi > rsiBuyLevel and macdLine > signalLine and histLine > histLine[1]
bearMomentum = rsi < rsiSellLevel and macdLine < signalLine and histLine < histLine[1]
buySignal = barstate.isconfirmed and inSession and enoughVolatility and bullTrend and bullMomentum and ta.crossover(close, fastEma)
sellSignal = barstate.isconfirmed and inSession and enoughVolatility and bearTrend and bearMomentum and ta.crossunder(close, fastEma)
longStop = buySignal ? close - atr * stopAtrMult : na
longTarget = buySignal ? close + atr * targetAtrMult : na
shortStop = sellSignal ? close + atr * stopAtrMult : na
shortTarget = sellSignal ? close - atr * targetAtrMult : na
plot(fastEma, "Fast EMA", color=color.new(color.teal, 0), linewidth=2)
plot(slowEma, "Slow EMA", color=color.new(color.orange, 0), linewidth=2)
plot(htfEma, "HTF EMA", color=color.new(color.gray, 15), linewidth=2)
plotshape(buySignal, title="Buy Signal", style=shape.labelup, location=location.belowbar, color=color.new(color.lime, 0), text="BUY", textcolor=color.black, size=size.small)
plotshape(sellSignal, title="Sell Signal", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), text="SELL", textcolor=color.white, size=size.small)
plot(longStop, "Long Stop", color=color.new(color.red, 0), style=plot.style_linebr, linewidth=2)
plot(longTarget, "Long Target", color=color.new(color.lime, 0), style=plot.style_linebr, linewidth=2)
plot(shortStop, "Short Stop", color=color.new(color.red, 0), style=plot.style_linebr, linewidth=2)
plot(shortTarget, "Short Target", color=color.new(color.lime, 0), style=plot.style_linebr, linewidth=2)
barcolor(buySignal ? color.new(color.lime, 65) : sellSignal ? color.new(color.red, 65) : na)
alertcondition(buySignal, title="15m Futures Buy", message="BUY signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal, title="15m Futures Sell", message="SELL signal on {{ticker}} {{interval}} at {{close}}")
````
