# fares Dib

- url: https://www.tradingview.com/script/4oubJNbP-fares-Dib/
- type: indicator
- pine_id: PUB;42c16c20dc81429f89f64707c0103caa
- version: 1.0

## Description

5M Rejection Wick Strategy

This indicator identifies potential reversal opportunities on the 5-minute timeframe based on rejection wick analysis.

BUY Signal:
- Previous candle is bearish.
- Lower wick is larger than the candle body.
- Previous lower wick is larger than the current lower wick.
- Current candle closes bullish.

SELL Signal:
- Previous candle is bullish.
- Upper wick is larger than the candle body.
- Previous upper wick is larger than the current upper wick.
- Current candle closes bearish.

The indicator also plots:
- Stop Loss (SL)
- Take Profit 1 (1:1 Risk Reward)
- Take Profit 2 (1:2 Risk Reward)

Designed for educational and analytical purposes only. Always perform your own risk management and market analysis before trading.

## Source Code

````pine
//@version=6
indicator("5M Rejection Wick Strategy", overlay=true)

// التحقق من فريم 5 دقائق
is5m = timeframe.isminutes and timeframe.multiplier == 5

// الشمعة السابقة
prevBull = close[1] > open[1]
prevBear = close[1] < open[1]

// جسم الشمعة السابقة
prevBody = math.abs(close[1] - open[1])

// الذيول السابقة
prevLowerWick = math.min(open[1], close[1]) - low[1]
prevUpperWick = high[1] - math.max(open[1], close[1])

// الذيول الحالية
currLowerWick = math.min(open, close) - low
currUpperWick = high - math.max(open, close)

// شروط الإشارات
strongBullReject = prevBear and prevLowerWick > prevBody and prevLowerWick > currLowerWick
strongBearReject = prevBull and prevUpperWick > prevBody and prevUpperWick > currUpperWick

buySignal = is5m and strongBullReject and close > open
sellSignal = is5m and strongBearReject and close < open

// مستويات الشراء
buyEntry = close
buySL = low[1]
buyRisk = buyEntry - buySL
buyTP1 = buyEntry + buyRisk
buyTP2 = buyEntry + buyRisk * 2

// مستويات البيع
sellEntry = close
sellSL = high[1]
sellRisk = sellSL - sellEntry
sellTP1 = sellEntry - sellRisk
sellTP2 = sellEntry - sellRisk * 2

// إشارات BUY و SELL
plotshape(buySignal, title="BUY", location=location.belowbar, style=shape.labelup, color=color.green, text="BUY")
plotshape(sellSignal, title="SELL", location=location.abovebar, style=shape.labeldown, color=color.red, text="SELL")

// خطوط الأهداف والوقف
plot(buySignal ? buySL : na, title="Buy SL", color=color.red, linewidth=2, style=plot.style_linebr)
plot(buySignal ? buyTP1 : na, title="Buy TP1", color=color.green, linewidth=1, style=plot.style_linebr)
plot(buySignal ? buyTP2 : na, title="Buy TP2", color=color.lime, linewidth=2, style=plot.style_linebr)

plot(sellSignal ? sellSL : na, title="Sell SL", color=color.red, linewidth=2, style=plot.style_linebr)
plot(sellSignal ? sellTP1 : na, title="Sell TP1", color=color.green, linewidth=1, style=plot.style_linebr)
plot(sellSignal ? sellTP2 : na, title="Sell TP2", color=color.lime, linewidth=2, style=plot.style_linebr)

// التنبيهات
alertcondition(buySignal, title="BUY Signal", message="BUY Signal 5M")
alertcondition(sellSignal, title="SELL Signal", message="SELL Signal 5M")
````
