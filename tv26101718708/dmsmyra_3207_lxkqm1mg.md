# DMS_Myra 3207

- url: https://www.tradingview.com/script/lxKQm1MG-DMS-Myra-3207/
- type: indicator
- pine_id: PUB;b3d88534d06d42d3a7866d51d1091ad0
- version: 1.0

## Description

Engulfing, rsi, breakout, pullback, BOS, CHoch, continuations

## Source Code

````pine
//@version=5
indicator("DSP ROBOT AI v11 - Forward Test Build", overlay=true, max_labels_count=300, max_lines_count=300)

// ==========================
// INPUT
// ==========================
tradeMode = input.string("Sell Only", "Trade Mode", options=["Both", "Buy Only", "Sell Only"])
strategyMode = input.string("Conservative", "Strategy Mode", options=["Aggressive", "Conservative", "Sniper"])

emaFastLen = input.int(20, "EMA Fast")
emaMidLen  = input.int(50, "EMA Mid")
emaSlowLen = input.int(200, "EMA Slow")

atrLen = input.int(14, "ATR Length")
adxLen = input.int(14, "ADX Length")
minADX = input.float(24, "Minimum ADX", step=0.5)

cooldownBars = input.int(10, "Cooldown Bars After Signal", minval=1)
minMoveAfterSignalATR = input.float(1.2, "Min Move After Last Signal x ATR", step=0.1)

useSessionFilter = input.bool(true, "Use Session Filter")
londonSession = input.session("0300-0600", "London Session Durham")
nySession     = input.session("0800-1100", "New York Session Durham")
sessionTZ     = input.string("America/New_York", "Session Timezone")

useEMA200Distance = input.bool(true, "Use EMA200 Distance Filter")
minDistEMA200 = input.float(0.7, "Min Distance From EMA200 x ATR", step=0.1)
maxDistEMA20  = input.float(2.5, "Max Distance From EMA20 x ATR", step=0.1)

pullbackATR = input.float(0.55, "Pullback Distance To EMA x ATR", step=0.05)
structureLen = input.int(5, "Structure Break Length")

rrTP1 = input.float(1.2, "TP1 RR", step=0.1)
rrTP2 = input.float(2.0, "TP2 RR", step=0.1)
slATR = input.float(1.0, "SL ATR Multiplier", step=0.1)

showEMA = input.bool(true, "Show EMA")
showHistoricalTrades = input.bool(true, "Show Historical Trades")
showTextLabels = input.bool(true, "Show Text Labels")
lineLength = input.int(20, "Line Length")

// ==========================
// CALCULATION
// ==========================
ema20  = ta.ema(close, emaFastLen)
ema50  = ta.ema(close, emaMidLen)
ema200 = ta.ema(close, emaSlowLen)

atr = ta.atr(atrLen)

// Manual ADX
upMove = high - high[1]
downMove = low[1] - low

plusDM = upMove > downMove and upMove > 0 ? upMove : 0
minusDM = downMove > upMove and downMove > 0 ? downMove : 0

trur = ta.rma(ta.tr(true), adxLen)
plusDI = 100 * ta.rma(plusDM, adxLen) / trur
minusDI = 100 * ta.rma(minusDM, adxLen) / trur

dx = 100 * math.abs(plusDI - minusDI) / math.max(plusDI + minusDI, 0.0001)
adx = ta.rma(dx, adxLen)

// ==========================
// SESSION FILTER
// ==========================
inLondon = not na(time(timeframe.period, londonSession, sessionTZ))
inNY = not na(time(timeframe.period, nySession, sessionTZ))
sessionOK = useSessionFilter ? (inLondon or inNY) : true

// ==========================
// TREND CONDITION
// ==========================
emaBull = ema20 > ema50 and ema50 > ema200
emaBear = ema20 < ema50 and ema50 < ema200

ema20SlopeUp = ema20 > ema20[3]
ema20SlopeDown = ema20 < ema20[3]

ema50SlopeUp = ema50 > ema50[3]
ema50SlopeDown = ema50 < ema50[3]

ema200SlopeUp = ema200 > ema200[5]
ema200SlopeDown = ema200 < ema200[5]

priceAbove200 = close > ema200
priceBelow200 = close < ema200

adxOK = adx >= minADX

// ==========================
// ANTI CHOP
// ==========================
emaDistance = math.abs(ema20 - ema50)
antiChop = emaDistance > atr * 0.30

distFromEMA200 = math.abs(close - ema200)
ema200DistanceOK = useEMA200Distance ? distFromEMA200 >= atr * minDistEMA200 : true

distFromEMA20 = math.abs(close - ema20)
notTooFarFromEMA20 = distFromEMA20 <= atr * maxDistEMA20

// ==========================
// STRUCTURE
// ==========================
prevHigh = ta.highest(high[1], structureLen)
prevLow  = ta.lowest(low[1], structureLen)

breakHigh = close > prevHigh
breakLow  = close < prevLow

earlyBreakHigh = high > prevHigh and close > ema20
earlyBreakLow  = low < prevLow and close < ema20

bullCandle = close > open and close > close[1]
bearCandle = close < open and close < close[1]

bullEngulf = close > open and close > high[1]
bearEngulf = close < open and close < low[1]

strongBullBody = (close - open) > atr * 0.25
strongBearBody = (open - close) > atr * 0.25

// ==========================
// PULLBACK
// ==========================
pullbackBuy = low <= ema20 + atr * pullbackATR or low <= ema50 + atr * pullbackATR
pullbackSell = high >= ema20 - atr * pullbackATR or high >= ema50 - atr * pullbackATR

// ==========================
// MODE FILTER
// ==========================
allowBuy = tradeMode == "Both" or tradeMode == "Buy Only"
allowSell = tradeMode == "Both" or tradeMode == "Sell Only"

// Aggressive
aggressiveBuyTrend =
     priceAbove200 and
     ema20 > ema50 and
     ema20SlopeUp and
     ema50SlopeUp

aggressiveSellTrend =
     priceBelow200 and
     ema20 < ema50 and
     ema20SlopeDown and
     ema50SlopeDown

// Conservative
conservativeBuyTrend =
     emaBull and
     ema20SlopeUp and
     ema50SlopeUp and
     ema200SlopeUp and
     priceAbove200

conservativeSellTrend =
     emaBear and
     ema20SlopeDown and
     ema50SlopeDown and
     ema200SlopeDown and
     priceBelow200

// Sniper
sniperBuyTrend =
     conservativeBuyTrend and
     close > ema20 and
     close > ema50 and
     plusDI > minusDI

sniperSellTrend =
     conservativeSellTrend and
     close < ema20 and
     close < ema50 and
     minusDI > plusDI

buyTrendOK =
     strategyMode == "Aggressive" ? aggressiveBuyTrend :
     strategyMode == "Conservative" ? conservativeBuyTrend :
     sniperBuyTrend

sellTrendOK =
     strategyMode == "Aggressive" ? aggressiveSellTrend :
     strategyMode == "Conservative" ? conservativeSellTrend :
     sniperSellTrend

// ==========================
// SMART TREND LOCK
// ==========================
// BUY dibuat sangat ketat kalau market besar belum bullish
buyTrendLock =
     priceAbove200 and
     ema20 > ema50 and
     ema20SlopeUp and
     ema50SlopeUp and
     close > ema50 and
     plusDI > minusDI

sellTrendLock =
     priceBelow200 and
     ema20 < ema50 and
     ema20SlopeDown and
     ema50SlopeDown and
     close < ema50 and
     minusDI > plusDI

// ==========================
// TRIGGER
// ==========================
buyTrigger =
     strategyMode == "Sniper" ?
     (bullEngulf and strongBullBody and breakHigh) :
     ((bullCandle and breakHigh) or (strongBullBody and earlyBreakHigh))

sellTrigger =
     strategyMode == "Sniper" ?
     (bearEngulf and strongBearBody and breakLow) :
     ((bearCandle and breakLow) or (strongBearBody and earlyBreakLow))

// ==========================
// COOLDOWN + WAVE FILTER
// ==========================
var int lastSignalBar = na
var float lastSignalPrice = na

cooldownOK = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars

waveMoveOK =
     na(lastSignalPrice) or
     math.abs(close - lastSignalPrice) >= atr * minMoveAfterSignalATR

// ==========================
// FINAL ENTRY RULES
// ==========================
buySignal =
     allowBuy and
     buyTrendOK and
     buyTrendLock and
     adxOK and
     antiChop and
     ema200DistanceOK and
     notTooFarFromEMA20 and
     pullbackBuy and
     buyTrigger and
     sessionOK and
     cooldownOK and
     waveMoveOK

sellSignal =
     allowSell and
     sellTrendOK and
     sellTrendLock and
     adxOK and
     antiChop and
     ema200DistanceOK and
     notTooFarFromEMA20 and
     pullbackSell and
     sellTrigger and
     sessionOK and
     cooldownOK and
     waveMoveOK

// ==========================
// PRICE LEVELS
// ==========================
buyEntry = close
buySL = buyEntry - atr * slATR
buyRisk = buyEntry - buySL
buyTP1 = buyEntry + buyRisk * rrTP1
buyTP2 = buyEntry + buyRisk * rrTP2

sellEntry = close
sellSL = sellEntry + atr * slATR
sellRisk = sellSL - sellEntry
sellTP1 = sellEntry - sellRisk * rrTP1
sellTP2 = sellEntry - sellRisk * rrTP2

// ==========================
// PLOT EMA
// ==========================
plot(showEMA ? ema20 : na, "EMA 20", color=color.blue, linewidth=2)
plot(showEMA ? ema50 : na, "EMA 50", color=color.yellow, linewidth=2)
plot(showEMA ? ema200 : na, "EMA 200", color=color.red, linewidth=3)

// ==========================
// DRAW FUNCTION
// ==========================
drawTrade(_isBuy, _entry, _sl, _tp1, _tp2) =>
    labelColor = _isBuy ? color.green : color.red
    signalText = _isBuy ? "DSP BUY" : "DSP SELL"

    if showHistoricalTrades
        line.new(bar_index, _entry, bar_index + lineLength, _entry, color=color.blue, width=2)
        line.new(bar_index, _sl, bar_index + lineLength, _sl, color=color.red, width=2)
        line.new(bar_index, _tp1, bar_index + lineLength, _tp1, color=color.lime, width=2)
        line.new(bar_index, _tp2, bar_index + lineLength, _tp2, color=color.lime, width=2)

        if showTextLabels
            label.new(bar_index, _entry, "ENTRY " + str.tostring(_entry, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.blue, 75))
            label.new(bar_index, _sl, "SL " + str.tostring(_sl, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.red, 75))
            label.new(bar_index, _tp1, "TP1 " + str.tostring(_tp1, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 75))
            label.new(bar_index, _tp2, "TP2 " + str.tostring(_tp2, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 75))

    label.new(bar_index, _isBuy ? low : high, signalText, style=_isBuy ? label.style_label_up : label.style_label_down, textcolor=color.white, color=labelColor)

// ==========================
// EXECUTION
// ==========================
if buySignal
    drawTrade(true, buyEntry, buySL, buyTP1, buyTP2)
    lastSignalBar := bar_index
    lastSignalPrice := close

if sellSignal
    drawTrade(false, sellEntry, sellSL, sellTP1, sellTP2)
    lastSignalBar := bar_index
    lastSignalPrice := close

// ==========================
// ALERT
// ==========================
alertcondition(buySignal, title="DSP BUY v11", message="DSP ROBOT AI v11 BUY Signal")
alertcondition(sellSignal, title="DSP SELL v11", message="DSP ROBOT AI v11 SELL Signal")

// ==========================
// STATUS TABLE
// ==========================
var table statusTable = table.new(position.top_right, 1, 8)

if barstate.islast
    table.cell(statusTable, 0, 0, "DSP v11", text_color=color.white, bgcolor=color.black)
    table.cell(statusTable, 0, 1, "Mode: " + tradeMode, text_color=color.white, bgcolor=color.black)
    table.cell(statusTable, 0, 2, "Style: " + strategyMode, text_color=color.white, bgcolor=color.black)
    table.cell(statusTable, 0, 3, "ADX: " + str.tostring(adx, "#.##"), text_color=color.white, bgcolor=color.black)
    table.cell(statusTable, 0, 4, "Trend: " + (emaBull ? "BUY" : emaBear ? "SELL" : "NO TRADE"), text_color=color.white, bgcolor=color.black)
    table.cell(statusTable, 0, 5, "Chop: " + (antiChop ? "OK" : "NO"), text_color=color.white, bgcolor=color.black)
    table.cell(statusTable, 0, 6, "Session: " + (sessionOK ? "OK" : "OFF"), text_color=color.white, bgcolor=color.black)
    table.cell(statusTable, 0, 7, "Wave: " + (waveMoveOK ? "OK" : "WAIT"), text_color=color.white, bgcolor=color.black)
````
