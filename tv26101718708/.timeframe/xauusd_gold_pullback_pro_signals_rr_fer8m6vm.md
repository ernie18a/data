# XAUUSD Gold Pullback PRO - Signals + RR

- url: https://www.tradingview.com/script/FEr8m6vM-XAUUSD-Gold-Pullback-PRO-Signals-RR/
- type: indicator
- pine_id: PUB;7bd5b62943b9439486131a789f013f7c
- version: 1.0

## Description

Trade XAUUSD Gold Pullback PRO - Signal with Risk & Reward. Use this signal to trade gold confidently to grow $500 account to $50,000 in less than a year.

## Source Code

````pine
//@version=6
indicator("XAUUSD Gold Pullback PRO - Signals + RR", overlay=true, max_labels_count=500, max_lines_count=500)

// === INPUTS ===
riskReward   = input.float(2.0, "Target Risk Reward", minval=1.0, maxval=5.0)
adxMin       = input.float(25, "Minimum ADX")
atrLen       = input.int(14, "ATR Length")
atrSL        = input.float(1.5, "ATR Stop Multiplier")

emaFastLen   = input.int(21, "Fast EMA")
emaSlowLen   = input.int(50, "Slow EMA")
emaTrendLen  = input.int(200, "Trend EMA")

htf          = input.timeframe("60", "Higher Timeframe Trend")
cooldownBars = input.int(5, "Cooldown After Exit")

showLast1HLevels = input.bool(true, "Show Last 1H High / Low")
showDashboard    = input.bool(true, "Show Dashboard")

// === INDICATORS ===
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
ema200  = ta.ema(close, emaTrendLen)
vwapVal = ta.vwap(close)

atr = ta.atr(atrLen)
[plusDI, minusDI, adx] = ta.dmi(14, 14)

// === 1H TREND ===
htfClose  = request.security(syminfo.tickerid, htf, close)
htfEma50  = request.security(syminfo.tickerid, htf, ta.ema(close, 50))
htfEma200 = request.security(syminfo.tickerid, htf, ta.ema(close, 200))

htfBull = htfClose > htfEma200 and htfEma50 > htfEma200
htfBear = htfClose < htfEma200 and htfEma50 < htfEma200

// === LAST 1H HIGH / LOW ===
last1HHigh = request.security(syminfo.tickerid, "60", high[1])
last1HLow  = request.security(syminfo.tickerid, "60", low[1])

plot(showLast1HLevels ? last1HHigh : na, "Last 1H High", color=color.new(color.red, 0), linewidth=2)
plot(showLast1HLevels ? last1HLow : na, "Last 1H Low", color=color.new(color.green, 0), linewidth=2)

// === LOCAL TREND ===
localBull = emaFast > emaSlow and close > vwapVal
localBear = emaFast < emaSlow and close < vwapVal

adxBull = adx > adxMin and plusDI > minusDI
adxBear = adx > adxMin and minusDI > plusDI

greenPhase = localBull and adxBull
redPhase   = localBear and adxBear

// === PULLBACK CONDITIONS ===
buyPullback  = greenPhase and low <= emaFast and close > emaFast
sellPullback = redPhase and high >= emaFast and close < emaFast

// === CANDLE CONFIRMATION ===
candleRange = high - low
bodySize = math.abs(close - open)
bodyPct = candleRange > 0 ? bodySize / candleRange * 100 : 0

bullCandle = close > open and bodyPct > 35
bearCandle = close < open and bodyPct > 35

// === COOLDOWN ===
var int lastExitBar = na
cooldownOk = na(lastExitBar) ? true : bar_index - lastExitBar > cooldownBars

// === SIGNALS ===
var int phase = 0

buySignal =
     buyPullback and
     bullCandle and
     cooldownOk and
     phase != 1 and
     barstate.isconfirmed

sellSignal =
     sellPullback and
     bearCandle and
     cooldownOk and
     phase != -1 and
     barstate.isconfirmed

// === ENTRY / SL / TP ===
var float entryPrice = na
var float stopLoss = na
var float takeProfit = na

var line entryLine = na
var line stopLine = na
var line targetLine = na
var label tradeBox = na

if buySignal
    phase := 1
    entryPrice := close
    stopLoss := low - atr * 0.25
    takeProfit := entryPrice + ((entryPrice - stopLoss) * riskReward)

    line.delete(entryLine)
    line.delete(stopLine)
    line.delete(targetLine)
    label.delete(tradeBox)

    entryLine := line.new(bar_index, entryPrice, bar_index + 50, entryPrice, extend=extend.right, color=color.white, width=2)
    stopLine := line.new(bar_index, stopLoss, bar_index + 50, stopLoss, extend=extend.right, color=color.red, width=2)
    targetLine := line.new(bar_index, takeProfit, bar_index + 50, takeProfit, extend=extend.right, color=color.green, width=2)

    tradeBox := label.new(
         bar_index,
         low,
         "BUY\nEntry: " + str.tostring(entryPrice, format.mintick) +
         "\nSL: " + str.tostring(stopLoss, format.mintick) +
         "\nTP: " + str.tostring(takeProfit, format.mintick) +
         "\nRR: " + str.tostring(riskReward) + ":1",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.small)

if sellSignal
    phase := -1
    entryPrice := close
    stopLoss := high + atr * 0.25
    takeProfit := entryPrice - ((stopLoss - entryPrice) * riskReward)

    line.delete(entryLine)
    line.delete(stopLine)
    line.delete(targetLine)
    label.delete(tradeBox)

    entryLine := line.new(bar_index, entryPrice, bar_index + 50, entryPrice, extend=extend.right, color=color.white, width=2)
    stopLine := line.new(bar_index, stopLoss, bar_index + 50, stopLoss, extend=extend.right, color=color.red, width=2)
    targetLine := line.new(bar_index, takeProfit, bar_index + 50, takeProfit, extend=extend.right, color=color.green, width=2)

    tradeBox := label.new(
         bar_index,
         high,
         "SELL\nEntry: " + str.tostring(entryPrice, format.mintick) +
         "\nSL: " + str.tostring(stopLoss, format.mintick) +
         "\nTP: " + str.tostring(takeProfit, format.mintick) +
         "\nRR: " + str.tostring(riskReward) + ":1",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small)

// === EXIT LOGIC ===
exitBuy =
     phase == 1 and
     barstate.isconfirmed and
     (close < emaFast or close < vwapVal)

exitSell =
     phase == -1 and
     barstate.isconfirmed and
     (close > emaFast or close > vwapVal)

if exitBuy or exitSell
    phase := 0
    lastExitBar := bar_index

// === VISUALS ===
plot(emaFast, "21 EMA", color=color.green, linewidth=2)
plot(emaSlow, "50 EMA", color=color.red, linewidth=2)
plot(ema200, "200 EMA", color=color.white, linewidth=2)
plot(vwapVal, "VWAP", color=color.orange, linewidth=1)

bgcolor(greenPhase ? color.new(color.green, 88) : redPhase ? color.new(color.red, 88) : na)

plotshape(buySignal, title="BUY Signal", text="BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.large)
plotshape(sellSignal, title="SELL Signal", text="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.large)

plotshape(exitBuy, title="EXIT BUY", text="EXIT", style=shape.xcross, location=location.abovebar, color=color.orange, size=size.small)
plotshape(exitSell, title="EXIT SELL", text="EXIT", style=shape.xcross, location=location.belowbar, color=color.orange, size=size.small)

// === ALERTS ===
alertcondition(buySignal, "XAUUSD BUY", "BUY signal generated on XAUUSD")
alertcondition(sellSignal, "XAUUSD SELL", "SELL signal generated on XAUUSD")
alertcondition(exitBuy, "Exit Buy", "Exit BUY on XAUUSD")
alertcondition(exitSell, "Exit Sell", "Exit SELL on XAUUSD")

// === DASHBOARD ===
var table dash = table.new(position.top_right, 2, 7, border_width=1)

biasText = htfBull ? "BULLISH" : htfBear ? "BEARISH" : "NEUTRAL"
phaseText = greenPhase ? "BUY BIAS" : redPhase ? "SELL BIAS" : "WAIT"
statusText = buySignal ? "BUY NOW" : sellSignal ? "SELL NOW" : buyPullback ? "BUY WATCH" : sellPullback ? "SELL WATCH" : "WAIT"

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "XAUUSD", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(dash, 1, 0, "SIGNAL RR", text_color=color.white, bgcolor=color.black, text_size=size.small)

    table.cell(dash, 0, 1, "1H BIAS", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(dash, 1, 1, biasText, text_color=color.white, bgcolor=htfBull ? color.green : htfBear ? color.red : color.gray, text_size=size.small)

    table.cell(dash, 0, 2, "PHASE", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(dash, 1, 2, phaseText, text_color=color.white, bgcolor=greenPhase ? color.green : redPhase ? color.red : color.gray, text_size=size.small)

    table.cell(dash, 0, 3, "STATUS", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(dash, 1, 3, statusText, text_color=color.white, bgcolor=buySignal or buyPullback ? color.green : sellSignal or sellPullback ? color.red : color.gray, text_size=size.small)

    table.cell(dash, 0, 4, "ADX", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(adx, "#.0"), text_color=color.white, bgcolor=adx > adxMin ? color.green : color.red, text_size=size.small)

    table.cell(dash, 0, 5, "VWAP", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(dash, 1, 5, close > vwapVal ? "ABOVE" : "BELOW", text_color=color.white, bgcolor=close > vwapVal ? color.green : color.red, text_size=size.small)

    table.cell(dash, 0, 6, "RR", text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(riskReward) + ":1", text_color=color.white, bgcolor=color.green, text_size=size.small)
````
