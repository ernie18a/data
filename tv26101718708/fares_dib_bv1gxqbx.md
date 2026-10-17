# Fares Dib 

- url: https://www.tradingview.com/script/bv1gXQBx-Fares-Dib/
- type: indicator
- pine_id: PUB;21e9c366ab394352a677248d56aa65d2
- version: 1.0

## Description

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

// =========================
// فريم 5 دقائق فقط
// =========================
is5m = timeframe.period == "5"

// =========================
// الشمعة السابقة
// =========================
prevBull = close[1] > open[1]
prevBear = close[1] < open[1]

prevBody = math.abs(close[1] - open[1])

prevLowerWick = math.min(open[1], close[1]) - low[1]
prevUpperWick = high[1] - math.max(open[1], close[1])

// =========================
// الشمعة الحالية
// =========================
currLowerWick = math.min(open, close) - low
currUpperWick = high - math.max(open, close)

// =========================
// شروط الإشارات
// =========================
strongBullReject = prevBear and prevLowerWick > prevBody and prevLowerWick > currLowerWick
strongBearReject = prevBull and prevUpperWick > prevBody and prevUpperWick > currUpperWick

buySignal = is5m and strongBullReject and close > open
sellSignal = is5m and strongBearReject and close < open

// =========================
// مستويات الدخول والخروج
// =========================
buyEntry = close
buySL = low[1]
buyRisk = buyEntry - buySL
buyTP2 = buyEntry + buyRisk * 2

sellEntry = close
sellSL = high[1]
sellRisk = sellSL - sellEntry
sellTP2 = sellEntry - sellRisk * 2

// =========================
// إدارة صفقة واحدة
// =========================
var bool tradeActive = false
var bool tradeIsBuy = false

var float activeSL = na
var float activeTP2 = na

// إشارات جديدة فقط عند عدم وجود صفقة
newBuySignal = buySignal and not tradeActive
newSellSignal = sellSignal and not tradeActive

// فتح شراء
if newBuySignal
    tradeActive := true
    tradeIsBuy := true
    activeSL := buySL
    activeTP2 := buyTP2

// فتح بيع
if newSellSignal
    tradeActive := true
    tradeIsBuy := false
    activeSL := sellSL
    activeTP2 := sellTP2

// =========================
// الإغلاق (مضمون بدون أخطاء)
// =========================
longExit  = tradeActive and tradeIsBuy and (low <= activeSL or high >= activeTP2)
shortExit = tradeActive and not tradeIsBuy and (high >= activeSL or low <= activeTP2)

if longExit or shortExit
    tradeActive := false
    activeSL := na
    activeTP2 := na

// =========================
// الرسوم البيانية
// =========================
plotshape(newBuySignal, title="BUY", location=location.belowbar,
     style=shape.labelup, color=color.green, text="BUY")

plotshape(newSellSignal, title="SELL", location=location.abovebar,
     style=shape.labeldown, color=color.red, text="SELL")

plot(tradeActive ? activeSL : na, title="SL",
     color=color.red, linewidth=2, style=plot.style_linebr)

plot(tradeActive ? activeTP2 : na, title="TP2",
     color=color.lime, linewidth=2, style=plot.style_linebr)

// =========================
// التنبيهات
// =========================
alertcondition(newBuySignal, title="BUY Signal", message="BUY Signal 5M")
alertcondition(newSellSignal, title="SELL Signal", message="SELL Signal 5M")
````
