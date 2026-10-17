# Dip Finder: EMA50 + RSI + MACD

- url: https://www.tradingview.com/script/kThgENmL-Dip-Finder-EMA50-RSI-MACD/
- type: indicator
- pine_id: PUB;f999a14c3b08444f87946fe664d97388
- version: 1.0

## Description

Dip‑buy indicator that combines EMA 50, EMA 200, RSI and MACD on higher timeframes to highlight oversold pullbacks in uptrends and signal when downside momentum is starting to reverse.

## Source Code

````pine
//@version=6
indicator("Dip Finder: EMA50 + RSI + MACD", shorttitle="Dip Finder", overlay=true)

// Inputs
groupTrend = "Trend / EMA"
emaLen = input.int(50, "EMA Length", minval=1, group=groupTrend)
useEma200Filter = input.bool(true, "Require price above EMA 200", group=groupTrend)
ema200Len = input.int(200, "EMA 200 Length", minval=1, group=groupTrend)
minPctBelowEma50 = input.float(2.0, "Min % below EMA 50 to count as dip", step=0.1, group=groupTrend)

groupRSI = "RSI"
rsiLen = input.int(14, "RSI Length", minval=1, group=groupRSI)
rsiOversold = input.int(35, "RSI dip threshold", minval=1, maxval=50, group=groupRSI)
requireRsiCurlUp = input.bool(true, "Require RSI rising vs prior bar", group=groupRSI)

groupMACD = "MACD"
macdFast = input.int(12, "MACD Fast", minval=1, group=groupMACD)
macdSlow = input.int(26, "MACD Slow", minval=1, group=groupMACD)
macdSignal = input.int(9, "MACD Signal", minval=1, group=groupMACD)
requireMacdBelowZero = input.bool(true, "Require MACD below zero", group=groupMACD)
requireHistogramRising = input.bool(true, "Require histogram rising", group=groupMACD)

groupSignals = "Signal Mode"
signalMode = input.string("Confirmed reversal", "Signal type", options=["Early dip", "Confirmed reversal"], group=groupSignals)

groupDisplay = "Display"
showBg = input.bool(true, "Highlight dip zones", group=groupDisplay)
showLabels = input.bool(true, "Show chart labels", group=groupDisplay)

// Calculations
ema50 = ta.ema(close, emaLen)
ema200 = ta.ema(close, ema200Len)
rsi = ta.rsi(close, rsiLen)
[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSignal)

pctBelowEma50 = ((ema50 - close) / ema50) * 100.0

trendOk = useEma200Filter ? close > ema200 : true
dipByPrice = close < ema50 and pctBelowEma50 >= minPctBelowEma50

rsiDip = rsi <= rsiOversold
rsiCurlUp = requireRsiCurlUp ? rsi > rsi[1] : true

macdCrossUp = ta.crossover(macdLine, signalLine)
macdBelowZero = requireMacdBelowZero ? (macdLine < 0 and signalLine < 0) : true
histRising = requireHistogramRising ? histLine > histLine[1] : true

earlyDip = trendOk and dipByPrice and rsiDip
confirmedReversal = trendOk and dipByPrice and rsiDip and rsiCurlUp and macdCrossUp and macdBelowZero and histRising

// Plots
plot(ema50, "EMA 50", color=color.orange, linewidth=2)
plot(useEma200Filter ? ema200 : na, "EMA 200", color=color.blue, linewidth=2)

bgcolor(showBg and earlyDip ? color.new(color.yellow, 88) : na, title="Early Dip Zone")
bgcolor(showBg and confirmedReversal ? color.new(color.green, 84) : na, title="Confirmed Dip Zone")

plotshape(showLabels and signalMode == "Early dip" and earlyDip, title="Early Dip",
     style=shape.triangleup, location=location.belowbar, color=color.yellow, size=size.small, text="DIP")

plotshape(showLabels and signalMode == "Confirmed reversal" and confirmedReversal, title="Confirmed Dip",
     style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.small, text="BUY DIP")

// Alerts
alertcondition(earlyDip, title="Early Dip Detected",
     message="Early dip detected on {{ticker}} | Close={{close}} | RSI oversold and price below EMA50")

alertcondition(confirmedReversal, title="Confirmed Dip Reversal",
     message="Confirmed dip reversal on {{ticker}} | Close={{close}} | RSI + MACD reversal + EMA dip setup")

alertcondition(macdCrossUp and macdBelowZero, title="MACD Bullish Cross Below Zero",
     message="MACD bullish cross below zero on {{ticker}}")

alertcondition(rsi <= rsiOversold, title="RSI Oversold",
     message="RSI is oversold on {{ticker}}")
````
