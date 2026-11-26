# Yzkvng SMC Confirmations & webhook

- url: https://www.tradingview.com/script/HmP5T23G-Yzkvng-SMC-Confirmations-webhook/
- type: strategy
- pine_id: PUB;f7636a6d5cfb41229ae7043a96364bcf
- version: 1.0

## Description

What PineScript Does

Monitors price action
Detects trading signals
Sends alert() with JSON data

What TradingView Does

Shows popup notification
Sends HTTP POST to webhook URL
Stores in console logs

What Your Backend Does

Receives the POST request
Logs the data
Updates database
Sends notifications
Places trades (if automated)

All Three Happen Together
When PineScript detects a signal:

Instantly: Popup appears on TradingView
Instantly: HTTP request sent to backend
Simultaneously: Both happen at the same time

## Source Code

````pine
// @version=6
// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════
// Sends JSON alerts to Node.js webhook for automated trading
// Author: Omekagu Chukwuebuka | Version: 3.0 Webhook
// ═══════════════════════════════════════════════════════════════════════════════

strategy(
     title="Yzkvng SMC Confirmations & webhook",
     shorttitle="Yzkvng SMC Confirmations & webhook",
     overlay=true,
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=0,
     commission_type=strategy.commission.percent,
     commission_value=0.1,
     slippage=2,
     pyramiding=0
 )

// ═══════════════════════════════════════════════════════════════════════════════
// 📊 INPUT PARAMETERS
// ═══════════════════════════════════════════════════════════════════════════════

// --- Risk Management ---
grp1 = "═══ Risk Management ═══"
riskPercent      = input.float(1.0, "Risk Per Trade (%)", minval=0.1, maxval=5, step=0.1, group=grp1)
minRiskUSD       = input.float(10, "Minimum Risk Amount ($)", minval=0, step=1, group=grp1)
rrRatio          = input.float(2.0, "Risk/Reward Ratio", minval=0.5, maxval=10, step=0.1, group=grp1)
maxDailyTrades   = input.int(3, "Max Trades Per Day", minval=1, group=grp1)

// --- Structure Detection ---
grp2 = "═══ Structure Settings ═══"
swingLength      = input.int(5, "Swing Detection Length", minval=2, maxval=20, group=grp2)
atrLength        = input.int(14, "ATR Period", minval=5, maxval=50, group=grp2)
atrMultiplier    = input.float(1.5, "ATR Stop Loss Multiplier", minval=0.5, maxval=5, step=0.1, group=grp2)
zoneBuffer       = input.float(1.0, "Zone Buffer (ATR)", minval=0.5, maxval=3, step=0.1, group=grp2)

// --- Market Context ---
grp3 = "═══ Market Analysis ═══"
trendEmaLength   = input.int(50, "Trend EMA Length", minval=10, maxval=200, group=grp3)
emaSlopeLength   = input.int(5, "EMA Slope Lookback", minval=1, maxval=20, group=grp3)
adxLength        = input.int(14, "ADX Period", minval=5, maxval=50, group=grp3)
adxThreshold     = input.float(25, "ADX Threshold", minval=10, maxval=50, step=1, group=grp3)

// --- Entry Trigger ---
grp_trigger = "═══ 🎯 Entry Trigger ═══"
waitBarsInZone   = input.int(1, "Bars to Wait in Zone", minval=1, maxval=5, group=grp_trigger)
requireTriggerCandle = input.bool(true, "Require Trigger Candle", group=grp_trigger)
triggerCandleType = input.string("Close", "Trigger Type", options=["Close", "Engulfing", "Pin Bar"], group=grp_trigger)

// --- Confirmations ---
grp_confirm = "═══ ⚡ Confirmations ═══"
requireCandleClose    = input.bool(true, "Require Bullish/Bearish Close", group=grp_confirm)
requireVolume         = input.bool(true, "Volume Spike", group=grp_confirm)
volumeMultiplier      = input.float(1.2, "Volume Multiplier", minval=1.0, maxval=3.0, step=0.1, group=grp_confirm)
requireMomentum       = input.bool(true, "RSI Momentum", group=grp_confirm)
rsiPeriod             = input.int(14, "RSI Period", minval=5, maxval=50, group=grp_confirm)
rsiBullThreshold      = input.float(40, "RSI Bull Min", minval=20, maxval=60, step=5, group=grp_confirm)
rsiBearThreshold      = input.float(60, "RSI Bear Max", minval=40, maxval=80, step=5, group=grp_confirm)
requirePriceAction    = input.bool(true, "Wick Rejection", group=grp_confirm)
wickRatio             = input.float(0.3, "Min Wick Ratio", minval=0.1, maxval=0.5, step=0.05, group=grp_confirm)
requireNoOpposingPA   = input.bool(true, "Block Opposing Pressure", group=grp_confirm)
opposingBarCheck      = input.int(3, "Bars to Check", minval=1, maxval=10, group=grp_confirm)
minConfirmations = input.int(3, "Min Confirmations", minval=1, maxval=5, group=grp_confirm)

// --- Trade Settings ---
grp4 = "═══ Trade Settings ═══"
autoTrade        = input.bool(false, "Enable Auto Trading", group=grp4)
tradeOnTrend     = input.bool(true, "Trade Trending Markets", group=grp4)
tradeOnRange     = input.bool(true, "Trade Ranging Markets", group=grp4)

// --- Display Settings ---
grp5 = "═══ Display ═══"
showEMA          = input.bool(true, "Show EMA", group=grp5)
showZones        = input.bool(true, "Show Entry Zones", group=grp5)
showNextTrade    = input.bool(true, "Show Next Trade", group=grp5)
showTable        = input.bool(true, "Show Status Table", group=grp5)

// ═══════════════════════════════════════════════════════════════════════════════
// 🔧 CORE INDICATORS
// ═══════════════════════════════════════════════════════════════════════════════

atr = ta.atr(atrLength)
ema = ta.ema(close, trendEmaLength)
emaSlope = ema - ema[emaSlopeLength]
rsi = ta.rsi(close, rsiPeriod)

// Volume
avgVolume = ta.sma(volume, 20)
volumeSpike = volume > avgVolume * volumeMultiplier

// ADX
calcADX(len) =>
    up = ta.change(high)
    down = -ta.change(low)
    plusDM = na(up) ? na : (up > down and up > 0 ? up : 0)
    minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
    trur = ta.rma(ta.tr, len)
    plus = fixnan(100 * ta.rma(plusDM, len) / trur)
    minus = fixnan(100 * ta.rma(minusDM, len) / trur)
    sum = plus + minus
    adx = 100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), len)
    [adx, plus, minus]

[adxValue, plusDI, minusDI] = calcADX(adxLength)

// ═══════════════════════════════════════════════════════════════════════════════
// 📍 STRUCTURE TRACKING
// ═══════════════════════════════════════════════════════════════════════════════

pivotHigh = ta.pivothigh(high, swingLength, swingLength)
pivotLow = ta.pivotlow(low, swingLength, swingLength)

var float prevPL = na
var int prevPLBar = na
var float prevPH = na
var int prevPHBar = na

if not na(pivotLow)
    prevPL := pivotLow
    prevPLBar := bar_index - swingLength

if not na(pivotHigh)
    prevPH := pivotHigh
    prevPHBar := bar_index - swingLength

// ═══════════════════════════════════════════════════════════════════════════════
// 📈 MARKET ANALYSIS
// ═══════════════════════════════════════════════════════════════════════════════

// Structure
var string structure = "Neutral"
if not na(prevPH) and not na(prevPL)
    structure := emaSlope > 0 ? "Bullish" : emaSlope < 0 ? "Bearish" : "Neutral"

// Trend detection
isTrendingUp = adxValue >= adxThreshold and emaSlope > atr * 0.5
isTrendingDown = adxValue >= adxThreshold and emaSlope < -atr * 0.5

var string marketType = "Neutral"
if isTrendingUp
    marketType := "Trending Up"
else if isTrendingDown
    marketType := "Trending Down"
else
    marketType := "Neutral"

// Range detection
rangeHigh = ta.highest(high, 50)
rangeLow = ta.lowest(low, 50)
rangeSize = rangeHigh - rangeLow
inRange = close >= rangeLow and close <= rangeHigh and rangeSize > atr * 2

if inRange and not isTrendingUp and not isTrendingDown
    marketType := "Ranging"

// ═══════════════════════════════════════════════════════════════════════════════
// ⚡ CONFIRMATION SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════

// Candle patterns
bullishCandleClose = close > open and close > close[1]
bearishCandleClose = close < open and close < close[1]

bullishEngulfing = close > open and close[1] < open[1] and close > open[1] and open < close[1]
bearishEngulfing = close < open and close[1] > open[1] and close < open[1] and open > close[1]

candleBody = math.abs(close - open)
candleRange = high - low
lowerWick = low < math.min(open, close) ? math.min(open, close) - low : 0
upperWick = high > math.max(open, close) ? high - math.max(open, close) : 0

bullishPinBar = lowerWick > candleBody * 2 and upperWick < candleBody * 0.5
bearishPinBar = upperWick > candleBody * 2 and lowerWick < candleBody * 0.5

// Price action
bullWickRejection = not requirePriceAction or (lowerWick >= candleRange * wickRatio)
bearWickRejection = not requirePriceAction or (upperWick >= candleRange * wickRatio)

// Opposing pressure
strongBearishBar(i) => (close[i] < open[i]) and (math.abs(close[i] - open[i]) > atr[i] * 0.5)
strongBullishBar(i) => (close[i] > open[i]) and (math.abs(close[i] - open[i]) > atr[i] * 0.5)

checkOpposingPressure(isLong) =>
    if not requireNoOpposingPA
        true
    else
        noOpposing = true
        for i = 1 to opposingBarCheck
            if isLong and strongBearishBar(i)
                noOpposing := false
                break
            if not isLong and strongBullishBar(i)
                noOpposing := false
                break
        noOpposing

// Volume & RSI
volumeOK = not requireVolume or volumeSpike
rsiBullOK = not requireMomentum or (rsi >= rsiBullThreshold and rsi < 70)
rsiBearOK = not requireMomentum or (rsi <= rsiBearThreshold and rsi > 30)

// Calculate total confirmations
calcBullConfirms() =>
    count = 0
    if not requireCandleClose or bullishCandleClose
        count += 1
    if volumeOK
        count += 1
    if rsiBullOK
        count += 1
    if bullWickRejection
        count += 1
    if checkOpposingPressure(true)
        count += 1
    count

calcBearConfirms() =>
    count = 0
    if not requireCandleClose or bearishCandleClose
        count += 1
    if volumeOK
        count += 1
    if rsiBearOK
        count += 1
    if bearWickRejection
        count += 1
    if checkOpposingPressure(false)
        count += 1
    count

bullConfirms = calcBullConfirms()
bearConfirms = calcBearConfirms()

// ═══════════════════════════════════════════════════════════════════════════════
// 🎯 ENTRY ZONES & LEVELS
// ═══════════════════════════════════════════════════════════════════════════════

// Bull zone
bullZoneTop = not na(prevPL) ? prevPL + atr * zoneBuffer : na
bullZoneBottom = not na(prevPL) ? prevPL - atr * 0.5 : na
bullEntry = prevPL
bullSL = not na(bullEntry) ? bullEntry - atr * atrMultiplier : na
bullTP = not na(bullEntry) and not na(bullSL) ? bullEntry + (bullEntry - bullSL) * rrRatio : na

// Bear zone
bearZoneTop = not na(prevPH) ? prevPH + atr * 0.5 : na
bearZoneBottom = not na(prevPH) ? prevPH - atr * zoneBuffer : na
bearEntry = prevPH
bearSL = not na(bearEntry) ? bearEntry + atr * atrMultiplier : na
bearTP = not na(bearEntry) and not na(bearSL) ? bearEntry - (bearSL - bearEntry) * rrRatio : na

// Range levels
rangeLongEntry = rangeLow
rangeLongSL = rangeLongEntry - atr * atrMultiplier
rangeLongTP = rangeLongEntry + (rangeLongEntry - rangeLongSL) * rrRatio

rangeShortEntry = rangeHigh
rangeShortSL = rangeShortEntry + atr * atrMultiplier
rangeShortTP = rangeShortEntry - (rangeShortSL - rangeShortEntry) * rrRatio

// ═══════════════════════════════════════════════════════════════════════════════
// 🚨 ZONE TRACKING & TRIGGER
// ═══════════════════════════════════════════════════════════════════════════════

var bool inBullZone = false
var int bullZoneBars = 0
var bool bullTriggered = false

var bool inBearZone = false
var int bearZoneBars = 0
var bool bearTriggered = false

// Check if in zone
longZoneTouch = not na(bullZoneTop) and low <= bullZoneTop and low >= bullZoneBottom
shortZoneTouch = not na(bearZoneTop) and high >= bearZoneBottom and high <= bearZoneTop

// Bull zone tracking
if longZoneTouch
    if not inBullZone
        inBullZone := true
        bullZoneBars := 1
        bullTriggered := false
    else
        bullZoneBars += 1
else
    inBullZone := false
    bullZoneBars := 0
    bullTriggered := false

// Bear zone tracking
if shortZoneTouch
    if not inBearZone
        inBearZone := true
        bearZoneBars := 1
        bearTriggered := false
    else
        bearZoneBars += 1
else
    inBearZone := false
    bearZoneBars := 0
    bearTriggered := false

// Trigger detection
getTrigger(isLong) =>
    if not requireTriggerCandle
        true
    else if triggerCandleType == "Close"
        isLong ? bullishCandleClose : bearishCandleClose
    else if triggerCandleType == "Engulfing"
        isLong ? bullishEngulfing : bearishEngulfing
    else if triggerCandleType == "Pin Bar"
        isLong ? bullishPinBar : bearishPinBar
    else
        false

bullTriggerReady = inBullZone and bullZoneBars >= waitBarsInZone and getTrigger(true)
bearTriggerReady = inBearZone and bearZoneBars >= waitBarsInZone and getTrigger(false)

if bullTriggerReady and not bullTriggered
    bullTriggered := true

if bearTriggerReady and not bearTriggered
    bearTriggered := true

// ═══════════════════════════════════════════════════════════════════════════════
// ✅ FINAL ENTRY CONDITIONS
// ═══════════════════════════════════════════════════════════════════════════════

// Trending setups
longReady = bullTriggered and bullConfirms >= minConfirmations and (marketType == "Trending Up" or structure == "Bullish")
shortReady = bearTriggered and bearConfirms >= minConfirmations and (marketType == "Trending Down" or structure == "Bearish")

// Range setups
rangeLongTouch = close <= rangeLow + atr * 0.5
rangeLongReady = rangeLongTouch and bullConfirms >= minConfirmations and marketType == "Ranging"

rangeShortTouch = close >= rangeHigh - atr * 0.5
rangeShortReady = rangeShortTouch and bearConfirms >= minConfirmations and marketType == "Ranging"

// ═══════════════════════════════════════════════════════════════════════════════
// 💼 POSITION SIZING
// ═══════════════════════════════════════════════════════════════════════════════

calcQty(entry, stop) =>
    risk = math.max(strategy.equity * (riskPercent / 100), minRiskUSD)
    riskPer = math.abs(entry - stop)
    riskPer > 0 ? risk / riskPer : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// 🔔 WEBHOOK ALERTS FOR NODE.JS
// ═══════════════════════════════════════════════════════════════════════════════

// LONG trending entry
if longReady
    qty = calcQty(close, bullSL)
    alertJson = '{"action":"BUY","symbol":"' + syminfo.ticker + '","timeframe":"' + timeframe.period + '","price":' + str.tostring(close) + ',"stopLoss":' + str.tostring(bullSL) + ',"takeProfit":' + str.tostring(bullTP) + ',"quantity":' + str.tostring(qty) + ',"riskPercent":' + str.tostring(riskPercent) + ',"rrRatio":' + str.tostring(rrRatio) + ',"confirmations":' + str.tostring(bullConfirms) + ',"marketType":"' + marketType + '","setup":"TREND","atr":' + str.tostring(atr) + ',"adx":' + str.tostring(adxValue) + ',"rsi":' + str.tostring(rsi) + ',"timestamp":"{{timenow}}"}'
    alert(alertJson, alert.freq_once_per_bar_close)

// SHORT trending entry
if shortReady
    qty = calcQty(close, bearSL)
    alertJson = '{"action":"SELL","symbol":"' + syminfo.ticker + '","timeframe":"' + timeframe.period + '","price":' + str.tostring(close) + ',"stopLoss":' + str.tostring(bearSL) + ',"takeProfit":' + str.tostring(bearTP) + ',"quantity":' + str.tostring(qty) + ',"riskPercent":' + str.tostring(riskPercent) + ',"rrRatio":' + str.tostring(rrRatio) + ',"confirmations":' + str.tostring(bearConfirms) + ',"marketType":"' + marketType + '","setup":"TREND","atr":' + str.tostring(atr) + ',"adx":' + str.tostring(adxValue) + ',"rsi":' + str.tostring(rsi) + ',"timestamp":"{{timenow}}"}'
    alert(alertJson, alert.freq_once_per_bar_close)

// LONG range entry
if rangeLongReady and tradeOnRange
    qty = calcQty(close, rangeLongSL)
    alertJson = '{"action":"BUY","symbol":"' + syminfo.ticker + '","timeframe":"' + timeframe.period + '","price":' + str.tostring(close) + ',"stopLoss":' + str.tostring(rangeLongSL) + ',"takeProfit":' + str.tostring(rangeLongTP) + ',"quantity":' + str.tostring(qty) + ',"riskPercent":' + str.tostring(riskPercent) + ',"rrRatio":' + str.tostring(rrRatio) + ',"confirmations":' + str.tostring(bullConfirms) + ',"marketType":"' + marketType + '","setup":"RANGE","atr":' + str.tostring(atr) + ',"adx":' + str.tostring(adxValue) + ',"rsi":' + str.tostring(rsi) + ',"timestamp":"{{timenow}}"}'
    alert(alertJson, alert.freq_once_per_bar_close)

// SHORT range entry
if rangeShortReady and tradeOnRange
    qty = calcQty(close, rangeShortSL)
    alertJson = '{"action":"SELL","symbol":"' + syminfo.ticker + '","timeframe":"' + timeframe.period + '","price":' + str.tostring(close) + ',"stopLoss":' + str.tostring(rangeShortSL) + ',"takeProfit":' + str.tostring(rangeShortTP) + ',"quantity":' + str.tostring(qty) + ',"riskPercent":' + str.tostring(riskPercent) + ',"rrRatio":' + str.tostring(rrRatio) + ',"confirmations":' + str.tostring(bearConfirms) + ',"marketType":"' + marketType + '","setup":"RANGE","atr":' + str.tostring(atr) + ',"adx":' + str.tostring(adxValue) + ',"rsi":' + str.tostring(rsi) + ',"timestamp":"{{timenow}}"}'
    alert(alertJson, alert.freq_once_per_bar_close)

// ═══════════════════════════════════════════════════════════════════════════════
// 📊 TRADE EXECUTION (OPTIONAL AUTO TRADING)
// ═══════════════════════════════════════════════════════════════════════════════

var int dailyTrades = 0
if dayofmonth != dayofmonth[1]
    dailyTrades := 0

if autoTrade and strategy.position_size == 0 and dailyTrades < maxDailyTrades
    
    if longReady and tradeOnTrend
        qty = calcQty(close, bullSL)
        if qty > 0
            strategy.entry("Long", strategy.long, qty=qty)
            strategy.exit("Exit", "Long", stop=bullSL, limit=bullTP)
            dailyTrades += 1
            bullTriggered := false
    
    if shortReady and tradeOnTrend
        qty = calcQty(close, bearSL)
        if qty > 0
            strategy.entry("Short", strategy.short, qty=qty)
            strategy.exit("Exit", "Short", stop=bearSL, limit=bearTP)
            dailyTrades += 1
            bearTriggered := false
    
    if rangeLongReady and tradeOnRange
        qty = calcQty(close, rangeLongSL)
        if qty > 0
            strategy.entry("Range Long", strategy.long, qty=qty)
            strategy.exit("Exit", "Range Long", stop=rangeLongSL, limit=rangeLongTP)
            dailyTrades += 1
    
    if rangeShortReady and tradeOnRange
        qty = calcQty(close, rangeShortSL)
        if qty > 0
            strategy.entry("Range Short", strategy.short, qty=qty)
            strategy.exit("Exit", "Range Short", stop=rangeShortSL, limit=rangeShortTP)
            dailyTrades += 1

// ═══════════════════════════════════════════════════════════════════════════════
// 🎨 CLEAN VISUALS
// ═══════════════════════════════════════════════════════════════════════════════

// EMA
plot(showEMA ? ema : na, "EMA", color=color.new(color.yellow, 30), linewidth=2)

// Entry zones
var box bullBox = na
var box bearBox = na

if showZones
    if not na(prevPL) and not na(bullZoneTop) and not na(bullZoneBottom)
        if not na(bullBox)
            box.delete(bullBox)
        bullBox := box.new(prevPLBar, bullZoneTop, bar_index, bullZoneBottom, 
                           bgcolor=color.new(color.green, 95), 
                           border_color=color.new(color.green, 70), 
                           border_width=1)

    if not na(prevPH) and not na(bearZoneTop) and not na(bearZoneBottom)
        if not na(bearBox)
            box.delete(bearBox)
        bearBox := box.new(prevPHBar, bearZoneTop, bar_index, bearZoneBottom, 
                           bgcolor=color.new(color.red, 95), 
                           border_color=color.new(color.red, 70), 
                           border_width=1)

// Entry signals
plotshape(longReady ? low : na, "LONG", shape.labelup, location.belowbar, 
          color.new(color.green, 0), size=size.normal, text="LONG")
plotshape(shortReady ? high : na, "SHORT", shape.labeldown, location.abovebar, 
          color.new(color.red, 0), size=size.normal, text="SHORT")

// Range signals
plotshape(rangeLongReady ? low : na, "RANGE LONG", shape.labelup, location.belowbar, 
          color.new(color.blue, 0), size=size.small, text="R-LONG")
plotshape(rangeShortReady ? high : na, "RANGE SHORT", shape.labeldown, location.abovebar, 
          color.new(color.orange, 0), size=size.small, text="R-SHORT")

// Next trade projection
var line entryLine = na
var line slLine = na
var line tpLine = na
var label tradeLabel = na

if not na(entryLine)
    line.delete(entryLine)
if not na(slLine)
    line.delete(slLine)
if not na(tpLine)
    line.delete(tpLine)
if not na(tradeLabel)
    label.delete(tradeLabel)

var float nextEntry = na
var float nextSL = na
var float nextTP = na
var string nextType = "None"
var string status = ""

if showNextTrade
    if (marketType == "Trending Up" or structure == "Bullish") and not na(bullEntry)
        nextEntry := bullEntry
        nextSL := bullSL
        nextTP := bullTP
        nextType := "LONG"
        status := inBullZone ? (bullTriggered ? "TRIGGERED ✓" : "Wait Trigger") : "Await Retest"
            
    else if (marketType == "Trending Down" or structure == "Bearish") and not na(bearEntry)
        nextEntry := bearEntry
        nextSL := bearSL
        nextTP := bearTP
        nextType := "SHORT"
        status := inBearZone ? (bearTriggered ? "TRIGGERED ✓" : "Wait Trigger") : "Await Retest"

if not na(nextEntry) and not na(nextSL) and not na(nextTP)
    isLong = nextType == "LONG"
    projLen = 20
    
    entryColor = isLong ? color.new(color.green, 0) : color.new(color.red, 0)
    
    entryLine := line.new(bar_index, nextEntry, bar_index + projLen, nextEntry, 
                          color=entryColor, width=2, style=line.style_solid)
    
    slLine := line.new(bar_index, nextSL, bar_index + projLen, nextSL, 
                       color=color.new(color.red, 50), width=1, style=line.style_dashed)
    
    tpLine := line.new(bar_index, nextTP, bar_index + projLen, nextTP, 
                       color=color.new(color.green, 50), width=1, style=line.style_dashed)
    
    labelText = nextType + "\n" + status + "\nE: " + str.tostring(nextEntry, format.mintick) + "\nSL: " + str.tostring(nextSL, format.mintick) + "\nTP: " + str.tostring(nextTP, format.mintick)
    
    tradeLabel := label.new(bar_index + projLen, nextEntry, labelText,
                            style=label.style_label_left, 
                            color=entryColor, 
                            textcolor=color.white, 
                            size=size.normal)

// Status table
if showTable
    var table statusTable = table.new(position.top_right, 2, 7, border_width=1)
    
    if barstate.islast
        table.cell(statusTable, 0, 0, "SMC WEBHOOK", text_color=color.white, bgcolor=color.new(color.blue, 70))
        table.cell(statusTable, 1, 0, "", bgcolor=color.new(color.blue, 70))
        
        table.cell(statusTable, 0, 1, "Market", text_color=color.white, bgcolor=color.new(color.gray, 80))
        biasColor = structure == "Bullish" ? color.green : structure == "Bearish" ? color.red : color.gray
        table.cell(statusTable, 1, 1, marketType, text_color=biasColor, bgcolor=color.new(color.gray, 90))
        
        table.cell(statusTable, 0, 2, "Next", text_color=color.white, bgcolor=color.new(color.gray, 80))
        nextColor = nextType == "LONG" ? color.green : nextType == "SHORT" ? color.red : color.gray
        table.cell(statusTable, 1, 2, nextType, text_color=nextColor, bgcolor=color.new(color.gray, 90))
        
        table.cell(statusTable, 0, 3, "Status", text_color=color.white, bgcolor=color.new(color.gray, 80))
        table.cell(statusTable, 1, 3, status, text_color=color.white, bgcolor=color.new(color.gray, 90))
        
        table.cell(statusTable, 0, 4, "ADX", text_color=color.white, bgcolor=color.new(color.gray, 80))
        table.cell(statusTable, 1, 4, str.tostring(adxValue, "#.#"), text_color=color.white, bgcolor=color.new(color.gray, 90))
        
        table.cell(statusTable, 0, 5, "RSI", text_color=color.white, bgcolor=color.new(color.gray, 80))
        table.cell(statusTable, 1, 5, str.tostring(rsi, "#.#"), text_color=color.white, bgcolor=color.new(color.gray, 90))
        
        table.cell(statusTable, 0, 6, "Trades", text_color=color.white, bgcolor=color.new(color.gray, 80))
        table.cell(statusTable, 1, 6, str.tostring(dailyTrades) + "/" + str.tostring(maxDailyTrades), text_color=color.white, bgcolor=color.new(color.gray, 90))
````
