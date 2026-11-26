# XAUUSD ATR V5 Sniper System

- url: https://www.tradingview.com/script/o3601lV9/
- type: indicator
- pine_id: PUB;b0da11fc0309448d8100f8f123a8e359
- version: 1.0

## Description

使用方式（一定要照做）
你每天只做：
開盤 → 看有沒有訊號
有 → 做
沒有 → 關掉畫面

## Source Code

````pine
//@version=5
indicator("XAUUSD ATR V5 Sniper System", overlay=true)

// ===== INPUT =====
atrS_len = input.int(5)
atrL_len = input.int(13)
emaLen = input.int(20)

// ===== ATR =====
atrS = ta.atr(atrS_len)
atrL = ta.atr(atrL_len)
r = atrS / atrL

// ===== EMA =====
ema = ta.ema(close, emaLen)

// ===== HTF TREND =====
htf_close = request.security(syminfo.tickerid, "15", close)
htf_ema   = request.security(syminfo.tickerid, "15", ta.ema(close, emaLen))

htf_up = htf_close > htf_ema and htf_ema > htf_ema[1]
htf_dn = htf_close < htf_ema and htf_ema < htf_ema[1]

// ===== STRUCTURE =====
hh = ta.highest(high, 15)
ll = ta.lowest(low, 15)

// ===== STRONG CANDLE =====
body = math.abs(close - open)
strongBull = close > open and body > atrS * 0.4
strongBear = close < open and body > atrS * 0.4

// ===== SESSION FILTER（台灣時間）=====
hourTW = (timenow / 1000 / 60 / 60 + 8) % 24
sessionOK = (hourTW >= 15 and hourTW <= 18) or (hourTW >= 20 and hourTW <= 23)

// ===== BEST ZONE =====
bestATR = r >= 0.7 and r <= 1.1

// ===== SNIPER ENTRY =====
longCond =
     bestATR and
     sessionOK and
     htf_up and
     close > hh[1] and
     strongBull

shortCond =
     bestATR and
     sessionOK and
     htf_dn and
     close < ll[1] and
     strongBear

// ===== ONE TRADE PER DAY =====
var bool tradedToday = false
newDay = ta.change(time("D"))

if newDay
    tradedToday := false

longSignal  = longCond and not tradedToday
shortSignal = shortCond and not tradedToday

if longSignal or shortSignal
    tradedToday := true

// ===== STOP / TP =====
longSL  = close - atrS * 1.0
shortSL = close + atrS * 1.0

riskLong  = close - longSL
riskShort = shortSL - close

longTP = close + riskLong * 2
shortTP = close - riskShort * 2

// ===== PLOT =====
plotshape(longSignal, location=location.belowbar, color=color.lime, style=shape.triangleup, size=size.large, text="SNIPER BUY")
plotshape(shortSignal, location=location.abovebar, color=color.red, style=shape.triangledown, size=size.large, text="SNIPER SELL")

plot(longSignal ? longSL : na, color=color.orange, linewidth=2)
plot(longSignal ? longTP : na, color=color.blue, linewidth=2)

plot(shortSignal ? shortSL : na, color=color.orange, linewidth=2)
plot(shortSignal ? shortTP : na, color=color.blue, linewidth=2)

// ===== BG =====
bgcolor(bestATR ? color.new(color.green, 90) : color.new(color.red, 90))
````
