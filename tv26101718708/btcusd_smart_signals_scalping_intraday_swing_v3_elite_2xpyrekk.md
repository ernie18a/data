# BTCUSD Smart Signals scalping, intraday, swing V3 ELITE

- url: https://www.tradingview.com/script/2XPYrEKk-BTCUSD-Smart-Signals-scalping-intraday-swing-V3-ELITE/
- type: indicator
- pine_id: PUB;216599be245641b8b1a6acd65561d18f
- version: 4.0

## Description

BTCUSD Smart Signals scalping, intraday, swing V3 ELITE

## Source Code

````pine
//@version=5
indicator("BTC Intraday EMA AI Strategy FINAL", overlay=true, max_labels_count=500)

// ===================== INPUTS ===================== //
useEMA20  = input.bool(true, "Use EMA 20")
useEMA50  = input.bool(true, "Use EMA 50")
useEMA200 = input.bool(true, "Use EMA 200")

ema20_len  = input.int(20, "EMA 20 Length")
ema50_len  = input.int(50, "EMA 50 Length")
ema200_len = input.int(200, "EMA 200 Length")

pullbackCandles = input.int(3, "Max Pullback Candles", minval=1, maxval=5)
wickThreshold   = input.float(0.3, "Wick Strength Filter", step=0.1)

showArrows   = input.bool(true, "Show Trend Arrows")
enableAlerts = input.bool(true, "Enable Alerts")

// ===================== EMA ===================== //
ema20  = ta.ema(close, ema20_len)
ema50  = ta.ema(close, ema50_len)
ema200 = ta.ema(close, ema200_len)

// Plot EMAs
plot(useEMA20 ? ema20 : na, color=color.blue, title="EMA 20")
plot(useEMA50 ? ema50 : na, color=color.green, title="EMA 50")
plot(useEMA200 ? ema200 : na, color=color.orange, title="EMA 200")

// ===================== TREND CONDITIONS ===================== //
bullTrend = (not useEMA20 or close > ema20) and (not useEMA50 or ema20 > ema50) and (not useEMA200 or ema50 > ema200)
bearTrend = (not useEMA20 or close < ema20) and (not useEMA50 or ema20 < ema50) and (not useEMA200 or ema50 < ema200)

// ===================== CANDLE LOGIC ===================== //
bearishCandle = close < open
bullishCandle = close > open

upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low
bodySize  = math.abs(close - open)

bullishRejection = bodySize > 0 and lowerWick > bodySize * wickThreshold
bearishRejection = bodySize > 0 and upperWick > bodySize * wickThreshold

// ===================== PULLBACK LOGIC ===================== //
pullbackLong  = false
pullbackShort = false

for i = 1 to pullbackCandles
    pullbackLong  := pullbackLong  or (close[i] < open[i] and close[i] > ema20)
    pullbackShort := pullbackShort or (close[i] > open[i] and close[i] < ema20)

// ===================== ENTRY CONDITIONS ===================== //
longCondition  = bullTrend and pullbackLong and bullishRejection and close > ema20
shortCondition = bearTrend and pullbackShort and bearishRejection and close < ema20

// ===================== TRADE MANAGEMENT ===================== //
var int tradeCount = 0
var bool inTrade   = false
var bool longTrade = false

// ENTRY
if longCondition and not inTrade
    tradeCount += 1
    inTrade := true
    longTrade := true
    label.new(bar_index, low, "Trade " + str.tostring(tradeCount) + " LONG 🚀", style=label.style_label_up, color=color.green, textcolor=color.white)

if shortCondition and not inTrade
    tradeCount += 1
    inTrade := true
    longTrade := false
    label.new(bar_index, high, "Trade " + str.tostring(tradeCount) + " SHORT 🔻", style=label.style_label_down, color=color.red, textcolor=color.white)

// EXIT
exitLong  = inTrade and longTrade and close < ema20
exitShort = inTrade and not longTrade and close > ema20

if exitLong or exitShort
    label.new(bar_index, close, "Exit Trade " + str.tostring(tradeCount) + " ❌", style=label.style_label_left, color=color.yellow, textcolor=color.black)
    inTrade := false

// ===================== TREND ARROWS ===================== //
plotshape(showArrows and inTrade and longTrade, location=location.belowbar, style=shape.triangleup, color=color.green, size=size.tiny)
plotshape(showArrows and inTrade and not longTrade, location=location.abovebar, style=shape.triangledown, color=color.red, size=size.tiny)

// ===================== ALERTS ===================== //
alertcondition(enableAlerts and longCondition, title="LONG Signal", message="BTC LONG 🚀")
alertcondition(enableAlerts and shortCondition, title="SHORT Signal", message="BTC SHORT 🔻")
````
