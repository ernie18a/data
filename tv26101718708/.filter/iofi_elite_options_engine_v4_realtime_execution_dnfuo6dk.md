# IOFI Elite Options Engine v4 (Realtime Execution)

- url: https://www.tradingview.com/script/DNFUO6DK-IOFI-Elite-Options-Engine-v4-Realtime-Execution/
- type: indicator
- pine_id: PUB;fa6a5ccc5a6f48caa177b5c1b49888ac
- version: 1.0

## Description

THIS INDICATOR IS PURELY FOR STOCK OPTIONS ONLY. The indicator basically shows stock  option entry and exit precisely so that you do not incur losses and make sure you book maximum profit and also it shows you trend strength and rsi value with confidence scores. You may track it and make sure you evauate paper trade before you use it and enjoy making profits. This indicator is only a support system make sure you do your analysis before taking trade. Trade with discipline.

## Source Code

````pine
//@version=6
indicator("IOFI Elite Options Engine v4 (Realtime Execution)", overlay=true, max_labels_count=500)

//====================================================
// INPUTS
//====================================================

emaFastLen = input.int(9, "EMA Fast")
emaMidLen = input.int(21, "EMA Mid")
emaSlowLen = input.int(50, "EMA Slow")

rsiLen = input.int(14, "RSI Length")
adxLen = input.int(14, "ADX Length")
atrLen = input.int(14, "ATR Length")

volumeMultiplier = input.float(1.5, "Volume Multiplier")
signalCooldown = input.int(5, "Signal Cooldown Bars")

//====================================================
// CURRENT TIMEFRAME CALCULATIONS
//====================================================

ema9 = ta.ema(close, emaFastLen)
ema21 = ta.ema(close, emaMidLen)
ema50 = ta.ema(close, emaSlowLen)

vwapValue = ta.vwap(close)
rsiValue = ta.rsi(close, rsiLen)

atrValue = ta.atr(atrLen)
atrAvg = ta.sma(atrValue, 20)

volumeAvg = ta.sma(volume, 20)
volumeSpike = volume > volumeAvg * volumeMultiplier

//====================================================
// ADX MECHANICS
//====================================================

upMove = high - high[1]
downMove = low[1] - low

plusDM = upMove > downMove and upMove > 0 ? upMove : 0
minusDM = downMove > upMove and downMove > 0 ? downMove : 0

trur = ta.rma(ta.tr, adxLen)

plusDI = 100 * ta.rma(plusDM, adxLen) / trur
minusDI = 100 * ta.rma(minusDM, adxLen) / trur

dx = 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)
adx = ta.rma(dx, adxLen)

//====================================================
// MTF CONFIRMATION (15 MIN)
//====================================================

ema9_15 = request.security(syminfo.tickerid, "15", ta.ema(close, emaFastLen))
ema21_15 = request.security(syminfo.tickerid, "15", ta.ema(close, emaMidLen))

mtfBull = ema9_15 > ema21_15
mtfBear = ema9_15 < ema21_15

//====================================================
// ENGINE SCORING MATRIX
//====================================================

trendScore = (ema9 > ema21 and ema21 > ema50 and close > vwapValue) ? 30 : 0
momentumScore = (rsiValue > 60 and rsiValue < 80) ? 20 : 0
volumeScore = volumeSpike ? 15 : 0
adxScore = adx > 25 ? 10 : 0
atrScore = atrValue > atrAvg ? 10 : 0
breakoutScore = close > high[1] ? 10 : 0
mtfScore = mtfBull ? 15 : 0

totalScore = trendScore + momentumScore + volumeScore + adxScore + atrScore + breakoutScore + mtfScore

//====================================================
// CONFIDENCE MATRIX
//====================================================

confidence = totalScore >= 95 ? 85 :
             totalScore >= 90 ? 80 :
             totalScore >= 85 ? 75 :
             totalScore >= 80 ? 70 :
             totalScore >= 70 ? 60 : 50

//====================================================
// TRADING STATE MACHINE (LOCKS ENTRIES & EXITS)
//====================================================

var int direction = 0  // 0 = Flat, 1 = Long (Call), -1 = Short (Put)
var int lastBuyBar = na
var int lastSellBar = na

buyAllowed = na(lastBuyBar) or bar_index - lastBuyBar > signalCooldown
sellAllowed = na(lastSellBar) or bar_index - lastSellBar > signalCooldown

rawBuySignal = totalScore >= 85 and mtfBull and buyAllowed
rawSellSignal = ema9 < ema21 and close < vwapValue and rsiValue < 40 and mtfBear and sellAllowed

// Execution Entry Price & Target Memory
var float entryPrice = na
var float currentSL = na
var float t1 = na
var float t2 = na
var float t3 = na

buySignal = false
sellSignal = false
exitBuySignal = false
exitSellSignal = false

// Triggering Trades
if rawBuySignal and direction == 0
    direction := 1
    buySignal := true
    entryPrice := close
    lastBuyBar := bar_index
   
    risk = atrValue * 1.5
    currentSL := entryPrice - risk
    t1 := entryPrice + risk
    t2 := entryPrice + risk * 2
    t3 := entryPrice + risk * 3

if rawSellSignal and direction == 0
    direction := -1
    sellSignal := true
    entryPrice := close
    lastSellBar := bar_index
   
    risk = atrValue * 1.5
    currentSL := entryPrice + risk
    t1 := entryPrice - risk
    t2 := entryPrice - risk * 2
    t3 := entryPrice - risk * 3

// Tracking Active Exits
if direction == 1 and (close < ema9 or close < vwapValue)
    direction := 0
    exitBuySignal := true

if direction == -1 and (close > ema9 or close > vwapValue)
    direction := 0
    exitSellSignal := true

// Historic tracking assignment to avoid level truncation (prevents floating lines)
plotEntry = direction != 0 ? entryPrice : na
plotSL    = direction != 0 ? currentSL  : na
plotT1    = direction != 0 ? t1         : na
plotT2    = direction != 0 ? t2         : na
plotT3    = direction != 0 ? t3         : na

// Clear data memory completely when flat on the immediate execution bar
if exitBuySignal or exitSellSignal
    entryPrice := na
    currentSL := na
    t1 := na
    t2 := na
    t3 := na

//====================================================
// CHART GRAPHICS & VISUAL ENGINE
//====================================================

bgcolor(direction == 1 ? color.new(color.green, 92) : direction == -1 ? color.new(color.red, 92) : na)

plot(ema9, title="EMA 9", color=color.green, linewidth=1)
plot(ema21, title="EMA 21", color=color.orange, linewidth=1)
plot(ema50, title="EMA 50", color=color.red, linewidth=1)
plot(vwapValue, title="VWAP", color=color.yellow, linewidth=2)

// Dynamic Target Tracking Lines (Aligned with Real Chart history)
plot(plotEntry, title="Trade Entry", color=color.white, style=plot.style_linebr, linewidth=1)
plot(plotSL, title="Stop Loss", color=color.maroon, style=plot.style_linebr, linewidth=2)
plot(plotT1, title="Target 1", color=color.blue, style=plot.style_linebr)
plot(plotT2, title="Target 2", color=color.blue, style=plot.style_linebr)
plot(plotT3, title="Target 3", color=color.blue, style=plot.style_linebr)

// Sharp Label Indicator Shapes
plotshape(buySignal, title="BUY Entry Label", location=location.belowbar, style=shape.labelup, text="BUY / CALL", color=color.green, textcolor=color.white, size=size.normal)
plotshape(sellSignal, title="SELL Entry Label", location=location.abovebar, style=shape.labeldown, text="SELL / PUT", color=color.red, textcolor=color.white, size=size.normal)

plotshape(exitBuySignal, title="Exit Call Label", location=location.abovebar, style=shape.labeldown, text="EXIT CALL", color=color.orange, textcolor=color.black, size=size.small)
plotshape(exitSellSignal, title="Exit Put Label", location=location.belowbar, style=shape.labelup, text="EXIT PUT", color=color.orange, textcolor=color.black, size=size.small)

//====================================================
// ENGINE DASHBOARD (COMPILABLE VISIBILITY VERSION)
//====================================================

var table dash = table.new(position.top_right, 2, 12, bgcolor=color.new(color.black, 20), border_color=color.gray, border_width=1)

if barstate.islast
    // Header
    table.cell(dash, 0, 0, "IOFI ELITE", text_color=color.yellow, text_size=size.large)
    table.cell(dash, 1, 0, "LIVE ENGINE", text_color=color.green, text_size=size.large)

    // Scores
    table.cell(dash, 0, 1, "Total Score", text_color=color.white, text_size=size.normal)
    table.cell(dash, 1, 1, str.tostring(totalScore), text_color=totalScore >= 80 ? color.green : color.red, text_size=size.large)

    table.cell(dash, 0, 2, "Confidence", text_color=color.white)
    table.cell(dash, 1, 2, str.tostring(confidence) + "%", text_color=color.white)

    // BOLD TREND VISIBILITY VIA SIZE AND HIGH CONTRAST
    table.cell(dash, 0, 3, "TREND STRENGTH", text_color=color.blue, text_size=size.normal)
    table.cell(dash, 1, 3, ema9 > ema21 ? "STRONG BULLISH" : "STRONG BEARISH", text_color=color.white, bgcolor=ema9 > ema21 ? color.green : color.red, text_size=size.normal)

    table.cell(dash, 0, 4, "VWAP Line", text_color=color.white)
    table.cell(dash, 1, 4, close > vwapValue ? "Above" : "Below", text_color=close > vwapValue ? color.green : color.red)

    table.cell(dash, 0, 5, "RSI Value", text_color=color.white)
    table.cell(dash, 1, 5, str.tostring(math.round(rsiValue)), text_color=color.white)

    table.cell(dash, 0, 6, "ADX Trend", text_color=color.white)
    table.cell(dash, 1, 6, str.tostring(math.round(adx)), text_color=color.white)

    table.cell(dash, 0, 7, "Volume Volatility", text_color=color.white)
    table.cell(dash, 1, 7, volumeSpike ? "High Spike" : "Normal", text_color=volumeSpike ? color.orange : color.white)

    // Targets Real-time Outputs
    table.cell(dash, 0, 8, "Stop Loss (SL)", text_color=color.white)
    table.cell(dash, 1, 8, direction != 0 ? str.tostring(math.round_to_mintick(plotSL)) : "N/A", text_color=color.red)

    table.cell(dash, 0, 9, "Target 1 (T1)", text_color=color.white)
    table.cell(dash, 1, 9, direction != 0 ? str.tostring(math.round_to_mintick(plotT1)) : "N/A", text_color=color.blue)

    table.cell(dash, 0, 10, "Target 2 (T2)", text_color=color.white)
    table.cell(dash, 1, 10, direction != 0 ? str.tostring(math.round_to_mintick(plotT2)) : "N/A", text_color=color.blue)

    table.cell(dash, 0, 11, "Target 3 (T3)", text_color=color.white)
    table.cell(dash, 1, 11, direction != 0 ? str.tostring(math.round_to_mintick(plotT3)) : "N/A", text_color=color.blue)

//====================================================
// AUTOMATED STRATEGY ALERTS
//====================================================

alertcondition(buySignal, title="BUY Call Entry", message="IOFI Entry Setup: Open Call Option Position")
alertcondition(sellSignal, title="SELL Put Entry", message="IOFI Entry Setup: Open Put Option Position")
alertcondition(exitBuySignal, title="Exit Call Trigger", message="IOFI System Alert: Close Active Call Option")
alertcondition(exitSellSignal, title="Exit Put Trigger", message="IOFI System Alert: Close Active Put Option")
````
