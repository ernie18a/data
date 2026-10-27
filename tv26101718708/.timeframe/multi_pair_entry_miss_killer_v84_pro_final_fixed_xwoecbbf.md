# Multi Pair Entry Miss Killer V8.4 PRO FINAL FIXED

- url: https://www.tradingview.com/script/xWOeCbBf-Multi-Pair-Entry-Miss-Killer-V8-4-PRO-FINAL-FIXED/
- type: indicator
- pine_id: PUB;ced6a1cae64747e1bd770efb06063b72
- version: 1.0

## Description

Multi Pair Entry Miss Killer V8.4 PRO FINAL FIXED

Advanced institutional multi-pair trading system designed for high-probability ICT/SMC-based entries with smart confirmation logic.

Features
Multi-pair scanner support
Smart Money Concept (SMC) structure detection
ICT liquidity-based entries
BOS / CHoCH / MSS confirmation
Fair Value Gap (FVG) detection
Order Block confirmation
Trend filtering system
ATR-based stop loss & take profit
Entry Miss Prevention Logic
Real-time alerts
Clean professional dashboard
Optimized for XAUUSD, GBPUSD, EURUSD, USDJPY & more

## Source Code

````pine
//@version=6
indicator("Multi Pair Entry Miss Killer V8.4 PRO FINAL FIXED", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

//================ INPUTS ================
tfM15 = input.timeframe("15", "M15 TF")
tfH1  = input.timeframe("60", "H1 TF")
tfH4  = input.timeframe("240", "H4 TF")

emaLen = input.int(50, "EMA Trend")
atrLen = input.int(14, "ATR")
minScore = input.int(7, "Min Trade Score", minval=5, maxval=13)

maxDailyTrades = input.int(500, "Max Daily Trades", minval=1, maxval=500)
cooldownBars = input.int(0, "Cooldown Bars", minval=0)
setupExpireBars = input.int(2000, "Setup Expire Bars", minval=10, maxval=5000)

rr1 = input.float(1.0, "TP1 RR", step=0.25)
rr2 = input.float(2.0, "TP2 RR", step=0.25)
rr3 = input.float(3.0, "TP3 RR", step=0.25)

tradeSession = input.session("1200-2100", "London/NY Karachi")
asiaSession  = input.session("0000-0500", "Asia Session")

newsBlock = input.bool(false, "News Block")
smtManual = input.string("Neutral", "SMT / Correlation", options=["Bullish", "Bearish", "Neutral"])
footprintManual = input.string("Auto Proxy", "Footprint Mode", options=["Auto Proxy", "Bullish Delta", "Bearish Delta", "Neutral"])

showDashboard = input.bool(true, "Show Dashboard")
showPOI = input.bool(true, "Show POI Box")
showHTFLevels = input.bool(true, "Show PDH/PDL/Asia")
showTradeLines = input.bool(true, "Show Entry SL TP")
showDebugLabels = input.bool(false, "Show Small Debug Sweeps")

//================ RISK / LOT SIZE ================
assetType = input.string("XAUUSD", "Asset Type", options=["Forex", "XAUUSD", "BTCUSD", "US100"], group="Risk / Lot")
accountBalance = input.float(10000, "Account Balance ($)", step=100, group="Risk / Lot")
riskPerc = input.float(1.0, "Risk %", options=[0.5, 1.0, 2.0], group="Risk / Lot")
forexContractSize = input.float(100000, "Forex Contract Size", group="Risk / Lot")
xauContractSize = input.float(100, "XAUUSD Contract Size", group="Risk / Lot")
btcContractSize = input.float(1, "BTC Contract Size", group="Risk / Lot")
us100ContractSize = input.float(1, "US100 Contract Size", group="Risk / Lot")

//================ HELPERS ================
f_price(x) => na(x) ? "-" : str.tostring(x, format.mintick)
f_trend(x) => x == 1 ? "BULL" : x == -1 ? "BEAR" : "NEUTRAL"

f_col(x) =>
    str.contains(x, "BUY") or x == "BULL" or x == "ACTIVE" or x == "WIN" or x == "OK" or x == "CLEAR" or x == "DISTRIBUTION" or x == "DISCOUNT" or x == "BULLISH" or x == "SUPPORTIVE" or str.contains(x, "TP") ? color.lime :
     str.contains(x, "SELL") or x == "BEAR" or x == "LOSS" or x == "BLOCK" or x == "PREMIUM" or x == "BEARISH" or x == "CONTRADICTORY" or str.contains(x, "SL") ? color.red :
     str.contains(x, "WAIT") or str.contains(x, "MANIPULATION") or str.contains(x, "REVERSAL") ? color.yellow :
     str.contains(x, "IRL") or str.contains(x, "ERL") ? color.aqua :
     color.gray

f_lot(entryPrice, stopPrice) =>
    riskMoney = accountBalance * riskPerc / 100
    slDistance = math.abs(entryPrice - stopPrice)
    stopLossTicks = math.abs(entryPrice - stopPrice) / syminfo.mintick

    lot = assetType == "Forex" ?
         slDistance > 0 ? riskMoney / (slDistance * forexContractSize) : na :
         assetType == "XAUUSD" ?
         stopLossTicks > 0 ? riskMoney / (stopLossTicks * 0.01 * xauContractSize) * 10 : na :
         assetType == "BTCUSD" ?
         slDistance > 0 ? riskMoney / (slDistance * btcContractSize) : na :
         assetType == "US100" ?
         slDistance > 0 ? riskMoney / (slDistance * us100ContractSize) : na : na
    lot

//================ CORE ================
atr = ta.atr(atrLen)
ema = ta.ema(close, emaLen)
newDay = ta.change(time("D")) != 0

inSession = not na(time(timeframe.period, tradeSession, "Asia/Karachi"))
inSilver = not na(time(timeframe.period, "1200-1300", "Asia/Karachi")) or not na(time(timeframe.period, "1900-2000", "Asia/Karachi"))

m5Trend = close > ema ? 1 : close < ema ? -1 : 0
m15Trend = request.security(syminfo.tickerid, tfM15, close > ta.ema(close, emaLen) ? 1 : -1, lookahead=barmerge.lookahead_off)
h1Trend  = request.security(syminfo.tickerid, tfH1, close > ta.ema(close, emaLen) ? 1 : -1, lookahead=barmerge.lookahead_off)
h4Trend  = request.security(syminfo.tickerid, tfH4, close > ta.ema(close, emaLen) ? 1 : -1, lookahead=barmerge.lookahead_off)

buyTrend = m5Trend == 1 and m15Trend == 1
sellTrend = m5Trend == -1 and m15Trend == -1
buyHTFSoft = buyTrend and (h1Trend == 1 or h4Trend != -1)
sellHTFSoft = sellTrend and (h1Trend == -1 or h4Trend != 1)

//================ DAILY / DOL ================
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)
dOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_off)
prevOpen = request.security(syminfo.tickerid, "D", open[1], lookahead=barmerge.lookahead_off)
prevClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_off)

dailyBias = prevClose > prevOpen ? 1 : prevClose < prevOpen ? -1 : 0
dailyBiasTxt = dailyBias == 1 ? "BULLISH" : dailyBias == -1 ? "BEARISH" : "DUAL"
dol = dailyBias == 1 ? pdh : dailyBias == -1 ? pdl : na
dolTxt = dailyBias == 1 ? "PDH / BSL" : dailyBias == -1 ? "PDL / SSL" : "DUAL"

plot(showHTFLevels ? pdh : na, "PDH", color=color.new(color.green, 45), style=plot.style_linebr)
plot(showHTFLevels ? pdl : na, "PDL", color=color.new(color.red, 45), style=plot.style_linebr)
plot(showHTFLevels ? dOpen : na, "Daily Open", color=color.new(color.blue, 60), style=plot.style_linebr)
plot(showHTFLevels ? dol : na, "DOL", color=color.new(color.yellow, 20), linewidth=1, style=plot.style_linebr)

//================ ASIA ================
inAsia = not na(time(timeframe.period, asiaSession, "Asia/Karachi"))
var float asiaHigh = na
var float asiaLow = na

if newDay
    asiaHigh := na
    asiaLow := na

if inAsia
    asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow := na(asiaLow) ? low : math.min(asiaLow, low)

plot(showHTFLevels ? asiaHigh : na, "Asia High", color=color.new(color.orange, 55), style=plot.style_linebr)
plot(showHTFLevels ? asiaLow : na, "Asia Low", color=color.new(color.orange, 55), style=plot.style_linebr)

//================ LIQUIDITY / SWEEP ================
eqh = ta.highest(high[1], 20)
eql = ta.lowest(low[1], 20)

pdlSweep = barstate.isconfirmed and low < pdl and close > pdl
pdhSweep = barstate.isconfirmed and high > pdh and close < pdh
asiaLowSweep = barstate.isconfirmed and not na(asiaLow) and low < asiaLow and close > asiaLow
asiaHighSweep = barstate.isconfirmed and not na(asiaHigh) and high > asiaHigh and close < asiaHigh
eqlSweep = barstate.isconfirmed and low < eql and close > eql
eqhSweep = barstate.isconfirmed and high > eqh and close < eqh

buySweep = pdlSweep or asiaLowSweep or eqlSweep
sellSweep = pdhSweep or asiaHighSweep or eqhSweep

recentBuySweep = ta.barssince(buySweep) <= 20
recentSellSweep = ta.barssince(sellSweep) <= 20

plotshape(showDebugLabels and buySweep, "SSL Sweep", shape.triangleup, location.belowbar, color=color.lime, size=size.tiny, text="SSL")
plotshape(showDebugLabels and sellSweep, "BSL Sweep", shape.triangledown, location.abovebar, color=color.red, size=size.tiny, text="BSL")

liqRun = buySweep ? "LRLR / SSL" : sellSweep ? "HRLR / BSL" : "WAITING"
sweepTxt = recentBuySweep ? "BUY SWEEP" : recentSellSweep ? "SELL SWEEP" : "NO"

//================ STRUCTURE ================
prevHigh = ta.highest(high[1], 10)
prevLow = ta.lowest(low[1], 10)

body = math.abs(close - open)
bullDisp = barstate.isconfirmed and close > open and body > atr * 0.45
bearDisp = barstate.isconfirmed and close < open and body > atr * 0.45

bullMSS = barstate.isconfirmed and close > prevHigh
bearMSS = barstate.isconfirmed and close < prevLow

bullCISD = recentBuySweep and bullMSS and bullDisp
bearCISD = recentSellSweep and bearMSS and bearDisp

structureTxt = bullCISD ? "BULL CISD" : bearCISD ? "BEAR CISD" : bullMSS ? "BULL MSS" : bearMSS ? "BEAR MSS" : "WAITING"

//================ POI ================
bullFVG = barstate.isconfirmed and low > high[2]
bearFVG = barstate.isconfirmed and high < low[2]

bullOB = barstate.isconfirmed and close[1] < open[1] and close > high[1]
bearOB = barstate.isconfirmed and close[1] > open[1] and close < low[1]

var float bullTop = na
var float bullBot = na
var float bearTop = na
var float bearBot = na
var string poiType = "NONE"

if bullFVG
    bullTop := low
    bullBot := high[2]
    poiType := "BULL FVG"

if bullOB
    bullTop := high[1]
    bullBot := low[1]
    poiType := "BULL OB"

if bearFVG
    bearTop := low[2]
    bearBot := high
    poiType := "BEAR FVG"

if bearOB
    bearTop := high[1]
    bearBot := low[1]
    poiType := "BEAR OB"

bullUnicorn = bullFVG and bullOB and not na(bullTop) and not na(bullBot)
bearUnicorn = bearFVG and bearOB and not na(bearTop) and not na(bearBot)

if bullUnicorn
    poiType := "BULL UNICORN"
if bearUnicorn
    poiType := "BEAR UNICORN"

bullRetest = not na(bullTop) and close <= bullTop and close >= bullBot
bearRetest = not na(bearTop) and close >= bearBot and close <= bearTop
shallowBull = not na(bullTop) and low <= bullTop and close > bullBot
shallowBear = not na(bearBot) and high >= bearBot and close < bearTop

retestType = bullRetest or bearRetest ? "FULL MITIGATION" :
     shallowBull or shallowBear ? "SHALLOW RETEST" :
     "NONE"

var box poiBox = na

if showPOI and (bullFVG or bullOB)
    if not na(poiBox)
        box.delete(poiBox)
    poiBox := box.new(bar_index - 2, bullTop, bar_index + 25, bullBot, bgcolor=color.new(color.green, 89), border_color=color.new(color.green, 35))

if showPOI and (bearFVG or bearOB)
    if not na(poiBox)
        box.delete(poiBox)
    poiBox := box.new(bar_index - 2, bearTop, bar_index + 25, bearBot, bgcolor=color.new(color.red, 89), border_color=color.new(color.red, 35))

//================ PD / PO3 / PROFILE ================
pdHigh = ta.highest(high, 50)
pdLow = ta.lowest(low, 50)
mid = (pdHigh + pdLow) / 2
pdZone = close > mid ? "PREMIUM" : "DISCOUNT"

range20 = ta.highest(high, 20) - ta.lowest(low, 20)
po3 = range20 < atr * 2 and not recentBuySweep and not recentSellSweep ? "ACCUMULATION" :
     (recentBuySweep or recentSellSweep) and not (bullCISD or bearCISD) ? "MANIPULATION" :
     (bullCISD or bearCISD or bullMSS or bearMSS) ? "DISTRIBUTION" : "NEUTRAL"

weeklyProfile = dayofweek == dayofweek.tuesday ? "TUESDAY PROFILE" :
     dayofweek == dayofweek.wednesday ? "WED REVERSAL" :
     dayofweek == dayofweek.thursday ? "THU CONSOLIDATION" :
     dayofweek == dayofweek.friday ? "FRI EXPANSION" : "NORMAL"

dailyProfile = range20 < atr * 2 ? "SEEK/DESTROY RISK" :
     recentBuySweep or recentSellSweep ? "REVERSAL WATCH" :
     "NORMAL"

irlErl = (bullRetest or bearRetest) ? "IRL POI" : (high >= pdh or low <= pdl) ? "ERL LIQ" : "MID RANGE"

//================ FOOTPRINT / SMT / OHLC ================
ohlcSentiment = close > open ? "BULL CANDLE" : close < open ? "BEAR CANDLE" : "DOJI"

volSma = ta.sma(volume, 20)
volSpike = volume > volSma * 1.25
bullDeltaProxy = volSpike and close > open
bearDeltaProxy = volSpike and close < open

autoFoot = bullDeltaProxy ? "BULL DELTA" : bearDeltaProxy ? "BEAR DELTA" : volSpike ? "NEUTRAL" : "MISSING"
footprintTxt = footprintManual == "Bullish Delta" ? "BULL DELTA" :
     footprintManual == "Bearish Delta" ? "BEAR DELTA" :
     footprintManual == "Neutral" ? "NEUTRAL" : autoFoot

smtTxt = smtManual == "Bullish" ? "BULL SMT" : smtManual == "Bearish" ? "BEAR SMT" : "NEUTRAL"

//================ SCORE ================
buyScore = 0
buyScore += buyHTFSoft ? 2 : buyTrend ? 1 : 0
buyScore += recentBuySweep ? 2 : 0
buyScore += bullCISD or bullMSS ? 2 : 0
buyScore += bullFVG or bullOB ? 1 : 0
buyScore += bullRetest or shallowBull ? 2 : 0
buyScore += inSession ? 1 : 0
buyScore += pdZone == "DISCOUNT" ? 1 : 0
buyScore += footprintTxt == "BULL DELTA" or footprintTxt == "NEUTRAL" or footprintTxt == "MISSING" ? 1 : 0
buyScore += smtManual == "Bullish" or smtManual == "Neutral" ? 1 : 0

sellScore = 0
sellScore += sellHTFSoft ? 2 : sellTrend ? 1 : 0
sellScore += recentSellSweep ? 2 : 0
sellScore += bearCISD or bearMSS ? 2 : 0
sellScore += bearFVG or bearOB ? 1 : 0
sellScore += bearRetest or shallowBear ? 2 : 0
sellScore += inSession ? 1 : 0
sellScore += pdZone == "PREMIUM" ? 1 : 0
sellScore += footprintTxt == "BEAR DELTA" or footprintTxt == "NEUTRAL" or footprintTxt == "MISSING" ? 1 : 0
sellScore += smtManual == "Bearish" or smtManual == "Neutral" ? 1 : 0

confidence = buyScore > sellScore ? "BUY STRONG" : sellScore > buyScore ? "SELL STRONG" : "MIXED"

//================ IDEAL ENTRY / EXTENSION ================
idealBuyEntry = not na(bullTop) and not na(bullBot) ? (bullTop + bullBot) / 2 : na
idealSellEntry = not na(bearTop) and not na(bearBot) ? (bearTop + bearBot) / 2 : na

tooFarBuy = not na(idealBuyEntry) and close > idealBuyEntry + atr * 2
tooFarSell = not na(idealSellEntry) and close < idealSellEntry - atr * 2

//================ MODEL ENGINE ================
buyMitigation = recentBuySweep and bullCISD and (bullRetest or shallowBull) and not tooFarBuy
sellMitigation = recentSellSweep and bearCISD and (bearRetest or shallowBear) and not tooFarSell

buyDisplacement = recentBuySweep and bullCISD and bullDisp and (bullFVG or bullOB) and not bullRetest and not tooFarBuy
sellDisplacement = recentSellSweep and bearCISD and bearDisp and (bearFVG or bearOB) and not bearRetest and not tooFarSell

buyUnicornModel = recentBuySweep and (bullMSS or bullCISD) and bullUnicorn and (bullRetest or shallowBull) and not tooFarBuy
sellUnicornModel = recentSellSweep and (bearMSS or bearCISD) and bearUnicorn and (bearRetest or shallowBear) and not tooFarSell

buySilverModel = inSilver and recentBuySweep and bullCISD and (bullFVG or bullOB) and (bullRetest or shallowBull or buyDisplacement) and not tooFarBuy
sellSilverModel = inSilver and recentSellSweep and bearCISD and (bearFVG or bearOB) and (bearRetest or shallowBear or sellDisplacement) and not tooFarSell

buyJudasModel = inSession and recentBuySweep and bullCISD and (bullRetest or shallowBull or buyDisplacement) and not tooFarBuy
sellJudasModel = inSession and recentSellSweep and bearCISD and (bearRetest or shallowBear or sellDisplacement) and not tooFarSell

buyModel = buySilverModel ? "BUY SILVER" :
     buyUnicornModel ? "BUY UNICORN" :
     buyDisplacement ? "BUY DISPLACEMENT" :
     buyMitigation ? "BUY MITIGATION" :
     buyJudasModel ? "BUY JUDAS" : "NONE"

sellModel = sellSilverModel ? "SELL SILVER" :
     sellUnicornModel ? "SELL UNICORN" :
     sellDisplacement ? "SELL DISPLACEMENT" :
     sellMitigation ? "SELL MITIGATION" :
     sellJudasModel ? "SELL JUDAS" : "NONE"

//================ LOCKED TRADE STATE ================
var int state = 0
var int side = 0
var string activeModel = "NONE"
var string activeSignal = "WAIT"
var float entry = na
var float sl = na
var float tp1 = na
var float tp2 = na
var float tp3 = na
var float activeLot = na
var float activeRiskMoney = na
var int setupBar = na
var string result = "WAITING"
var int dailyTrades = 0
var int lastSignalBar = na
var int tpStage = 0
var int dailyBuy = 0
var int dailySell = 0

var int dailySL = 0
var int dailyTP1 = 0
var int dailyTP2 = 0
var int dailyTP3 = 0

if newDay
    dailyTrades := 0
    dailyBuy := 0
    dailySell := 0
    dailySL := 0
    dailyTP1 := 0
    dailyTP2 := 0
    dailyTP3 := 0
    state := 0
    side := 0
    activeModel := "NONE"
    activeSignal := "WAIT"
    result := "WAITING"
    entry := na
    sl := na
    tp1 := na
    tp2 := na
    tp3 := na
    activeLot := na
    activeRiskMoney := na
    tpStage := 0

cooldownOk = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars
dailyOk = dailyTrades < maxDailyTrades
canTake = state == 0 and cooldownOk and dailyOk and not newsBlock

buySignal = canTake and buyScore >= minScore and buyModel != "NONE"
sellSignal = canTake and sellScore >= minScore and sellModel != "NONE"

takeBuy = barstate.isconfirmed and buySignal and buyScore >= sellScore
takeSell = barstate.isconfirmed and sellSignal and sellScore > buyScore

if takeBuy
    state := 1
    side := 1
    activeModel := buyModel
    activeSignal := "BUY"
    entry := close
    sl := math.min(prevLow, low) - atr * 0.2
    activeLot := f_lot(entry, sl)
    activeRiskMoney := accountBalance * riskPerc / 100
    r = entry - sl
    tp1 := entry + r * rr1
    tp2 := entry + r * rr2
    tp3 := entry + r * rr3
    setupBar := bar_index
    result := "BUY ACTIVE"
    tpStage := 0
    dailyTrades += 1
    dailyBuy += 1
    lastSignalBar := bar_index
    label.new(bar_index, low, "BUY\nLot: " + str.tostring(activeLot, "#.###") + "\nRisk: $" + str.tostring(activeRiskMoney, "#.##"), style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.small)

if takeSell
    state := 1
    side := -1
    activeModel := sellModel
    activeSignal := "SELL"
    entry := close
    sl := math.max(prevHigh, high) + atr * 0.2
    activeLot := f_lot(entry, sl)
    activeRiskMoney := accountBalance * riskPerc / 100
    r = sl - entry
    tp1 := entry - r * rr1
    tp2 := entry - r * rr2
    tp3 := entry - r * rr3
    setupBar := bar_index
    result := "SELL ACTIVE"
    tpStage := 0
    dailyTrades += 1
    dailySell += 1
    lastSignalBar := bar_index
    label.new(bar_index, high, "SELL\nLot: " + str.tostring(activeLot, "#.###") + "\nRisk: $" + str.tostring(activeRiskMoney, "#.##"), style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

//================ RESULT MANAGEMENT FINAL FIX ================
if state == 1 and side == 1
    if high >= tp3 and tpStage < 3
        tpStage := 3
        result := "WIN TP3"
        dailyTP3 += 1
        state := 0
        label.new(bar_index, high, "TP3 FINAL", style=label.style_label_down, color=color.lime, textcolor=color.black, size=size.tiny)
    else if high >= tp2 and tpStage < 2
        tpStage := 2
        result := "RUNNING TP2"
        label.new(bar_index, high, "TP2 HIT", style=label.style_label_down, color=color.green, textcolor=color.black, size=size.tiny)
    else if high >= tp1 and tpStage < 1
        tpStage := 1
        result := "RUNNING TP1"
        label.new(bar_index, high, "TP1 HIT", style=label.style_label_down, color=color.aqua, textcolor=color.black, size=size.tiny)

    if state == 1 and low <= sl
        if tpStage == 0
            result := "LOSS SL"
            dailySL += 1
            label.new(bar_index, low, "SL FINAL", style=label.style_label_up, color=color.red, textcolor=color.white, size=size.tiny)
        else if tpStage == 1
            result := "TP1 FINAL"
            dailyTP1 += 1
            label.new(bar_index, low, "TP1 FINAL", style=label.style_label_up, color=color.aqua, textcolor=color.black, size=size.tiny)
        else if tpStage == 2
            result := "TP2 FINAL"
            dailyTP2 += 1
            label.new(bar_index, low, "TP2 FINAL", style=label.style_label_up, color=color.green, textcolor=color.black, size=size.tiny)
        state := 0

if state == 1 and side == -1
    if low <= tp3 and tpStage < 3
        tpStage := 3
        result := "WIN TP3"
        dailyTP3 += 1
        state := 0
        label.new(bar_index, low, "TP3 FINAL", style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.tiny)
    else if low <= tp2 and tpStage < 2
        tpStage := 2
        result := "RUNNING TP2"
        label.new(bar_index, low, "TP2 HIT", style=label.style_label_up, color=color.green, textcolor=color.black, size=size.tiny)
    else if low <= tp1 and tpStage < 1
        tpStage := 1
        result := "RUNNING TP1"
        label.new(bar_index, low, "TP1 HIT", style=label.style_label_up, color=color.aqua, textcolor=color.black, size=size.tiny)

    if state == 1 and high >= sl
        if tpStage == 0
            result := "LOSS SL"
            dailySL += 1
            label.new(bar_index, high, "SL FINAL", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.tiny)
        else if tpStage == 1
            result := "TP1 FINAL"
            dailyTP1 += 1
            label.new(bar_index, high, "TP1 FINAL", style=label.style_label_down, color=color.aqua, textcolor=color.black, size=size.tiny)
        else if tpStage == 2
            result := "TP2 FINAL"
            dailyTP2 += 1
            label.new(bar_index, high, "TP2 FINAL", style=label.style_label_down, color=color.green, textcolor=color.black, size=size.tiny)
        state := 0

if state == 1 and bar_index - setupBar > setupExpireBars
    if tpStage == 0
        result := "EXPIRED"
    else if tpStage == 1
        result := "TP1 FINAL"
        dailyTP1 += 1
    else if tpStage == 2
        result := "TP2 FINAL"
        dailyTP2 += 1
    else if tpStage == 3
        result := "WIN TP3"
    state := 0

//================ CLEAN ACTIVE TRADE PLOTS ================
plot(showTradeLines and state == 1 ? entry : na, "ENTRY", color=color.yellow, linewidth=2, style=plot.style_linebr)
plot(showTradeLines and state == 1 ? sl : na, "SL", color=color.red, linewidth=2, style=plot.style_linebr)
plot(showTradeLines and state == 1 ? tp1 : na, "TP1", color=color.aqua, linewidth=1, style=plot.style_linebr)
plot(showTradeLines and state == 1 ? tp2 : na, "TP2", color=color.green, linewidth=1, style=plot.style_linebr)
plot(showTradeLines and state == 1 ? tp3 : na, "TP3", color=color.lime, linewidth=2, style=plot.style_linebr)

//================ DASHBOARD ================
var table dash = table.new(position.top_right, 2, 49, border_width=1, border_color=color.new(color.gray, 60), bgcolor=color.new(color.black, 75))

if showDashboard and barstate.islast
    finalTxt = state == 1 ? side == 1 ? "BUY ACTIVE" : "SELL ACTIVE" : "WAITING"
    dailyLimitTxt = dailyTrades >= maxDailyTrades ? "STOP" : "OK"

    table.cell(dash, 0, 0, "INDICATOR", text_color=color.white, bgcolor=color.new(color.navy, 20), text_size=size.tiny)
    table.cell(dash, 1, 0, "VALUE", text_color=color.white, bgcolor=color.new(color.navy, 20), text_size=size.tiny)

    table.cell(dash, 0, 1, "FINAL", text_color=color.white, bgcolor=color.new(color.navy, 20), text_size=size.tiny)
    table.cell(dash, 1, 1, finalTxt, text_color=f_col(finalTxt), text_size=size.tiny)

    table.cell(dash, 0, 2, "Result", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 2, result, text_color=f_col(result), text_size=size.tiny)

    table.cell(dash, 0, 3, "Today Trades", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 3, str.tostring(dailyTrades) + " / " + str.tostring(maxDailyTrades), text_color=color.aqua, text_size=size.tiny)

    table.cell(dash, 0, 4, "Today B/S", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 4, str.tostring(dailyBuy) + " / " + str.tostring(dailySell), text_color=color.aqua, text_size=size.tiny)

    table.cell(dash, 0, 5, "Today SL", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 5, str.tostring(dailySL), text_color=color.red, text_size=size.tiny)

    table.cell(dash, 0, 6, "Today TP1", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 6, str.tostring(dailyTP1), text_color=color.aqua, text_size=size.tiny)

    table.cell(dash, 0, 7, "Today TP2", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 7, str.tostring(dailyTP2), text_color=color.green, text_size=size.tiny)

    table.cell(dash, 0, 8, "Today TP3", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 8, str.tostring(dailyTP3), text_color=color.lime, text_size=size.tiny)

    table.cell(dash, 0, 9, "Signal", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 9, activeSignal, text_color=f_col(activeSignal), text_size=size.tiny)

    table.cell(dash, 0, 10, "Trade Model", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 10, activeModel, text_color=f_col(activeModel), text_size=size.tiny)

    table.cell(dash, 0, 11, "Entry", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 11, f_price(entry), text_color=color.rgb(59, 98, 255), text_size=size.tiny)

    table.cell(dash, 0, 12, "SL", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 12, f_price(sl), text_color=color.red, text_size=size.tiny)

    table.cell(dash, 0, 13, "TP1", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 13, f_price(tp1), text_color=color.aqua, text_size=size.tiny)

    table.cell(dash, 0, 14, "TP2", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 14, f_price(tp2), text_color=color.green, text_size=size.tiny)

    table.cell(dash, 0, 15, "TP3", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 15, f_price(tp3), text_color=color.lime, text_size=size.tiny)

    table.cell(dash, 0, 16, "M5 Trend", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 16, f_trend(m5Trend), text_color=f_col(f_trend(m5Trend)), text_size=size.tiny)

    table.cell(dash, 0, 17, "M15 Trend", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 17, f_trend(m15Trend), text_color=f_col(f_trend(m15Trend)), text_size=size.tiny)

    table.cell(dash, 0, 18, "H1 Trend", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 18, f_trend(h1Trend), text_color=f_col(f_trend(h1Trend)), text_size=size.tiny)

    table.cell(dash, 0, 19, "H4 Trend", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 19, f_trend(h4Trend), text_color=f_col(f_trend(h4Trend)), text_size=size.tiny)

    table.cell(dash, 0, 20, "MSS/CISD", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 20, structureTxt, text_color=f_col(structureTxt), text_size=size.tiny)

    table.cell(dash, 0, 21, "PO3 / AMD", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 21, po3, text_color=f_col(po3), text_size=size.tiny)

    table.cell(dash, 0, 22, "Daily Bias", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 22, dailyBiasTxt, text_color=f_col(dailyBiasTxt), text_size=size.tiny)

    table.cell(dash, 0, 23, "Weekly Profile", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 23, weeklyProfile, text_color=color.orange, text_size=size.tiny)

    table.cell(dash, 0, 24, "Daily Profile", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 24, dailyProfile, text_color=color.orange, text_size=size.tiny)

    table.cell(dash, 0, 25, "IRL / ERL", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 25, irlErl, text_color=f_col(irlErl), text_size=size.tiny)

    table.cell(dash, 0, 26, "HRLR / LRLR", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 26, liqRun, text_color=f_col(liqRun), text_size=size.tiny)

    table.cell(dash, 0, 27, "POI", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 27, poiType, text_color=f_col(poiType), text_size=size.tiny)

    table.cell(dash, 0, 28, "DOL", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 28, dolTxt, text_color=color.yellow, text_size=size.tiny)

    table.cell(dash, 0, 29, "OHLC", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 29, ohlcSentiment, text_color=f_col(ohlcSentiment), text_size=size.tiny)

    table.cell(dash, 0, 30, "SMT", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 30, smtTxt, text_color=f_col(smtTxt), text_size=size.tiny)

    table.cell(dash, 0, 31, "Footprint", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 31, footprintTxt, text_color=f_col(footprintTxt), text_size=size.tiny)

    table.cell(dash, 0, 32, "PD Zone", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 32, pdZone, text_color=f_col(pdZone), text_size=size.tiny)

    table.cell(dash, 0, 33, "Session", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 33, inSession ? "ACTIVE" : "OUT", text_color=f_col(inSession ? "ACTIVE" : "OUT"), text_size=size.tiny)

    table.cell(dash, 0, 34, "Silver Time", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 34, inSilver ? "ACTIVE" : "OUT", text_color=f_col(inSilver ? "ACTIVE" : "OUT"), text_size=size.tiny)

    table.cell(dash, 0, 35, "Sweep", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 35, sweepTxt, text_color=f_col(sweepTxt), text_size=size.tiny)

    table.cell(dash, 0, 36, "PDH", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 36, f_price(pdh), text_color=color.lime, text_size=size.tiny)

    table.cell(dash, 0, 37, "PDL", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 37, f_price(pdl), text_color=color.red, text_size=size.tiny)

    table.cell(dash, 0, 38, "Asia High", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 38, f_price(asiaHigh), text_color=color.orange, text_size=size.tiny)

    table.cell(dash, 0, 39, "Asia Low", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 39, f_price(asiaLow), text_color=color.orange, text_size=size.tiny)

    table.cell(dash, 0, 40, "Sweep Buy", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 40, recentBuySweep ? "YES" : "NO", text_color=recentBuySweep ? color.lime : color.gray, text_size=size.tiny)

    table.cell(dash, 0, 41, "Sweep Sell", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 41, recentSellSweep ? "YES" : "NO", text_color=recentSellSweep ? color.red : color.gray, text_size=size.tiny)

    table.cell(dash, 0, 42, "EQH Sweep", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 42, eqhSweep ? "YES" : "NO", text_color=eqhSweep ? color.red : color.gray, text_size=size.tiny)

    table.cell(dash, 0, 43, "EQL Sweep", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 43, eqlSweep ? "YES" : "NO", text_color=eqlSweep ? color.lime : color.gray, text_size=size.tiny)

    table.cell(dash, 0, 44, "Buy / Sell Score", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 44, str.tostring(buyScore) + " / " + str.tostring(sellScore), text_color=color.aqua, text_size=size.tiny)

    table.cell(dash, 0, 45, "Confidence", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 45, confidence, text_color=f_col(confidence), text_size=size.tiny)

    table.cell(dash, 0, 46, "Asset Type", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 46, assetType, text_color=color.yellow, text_size=size.tiny)

    table.cell(dash, 0, 47, "Risk / Lot", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 47, str.tostring(riskPerc) + "% | " + str.tostring(activeLot, "#.###"), text_color=color.aqua, text_size=size.tiny)

    table.cell(dash, 0, 48, "Risk $", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 48, "$" + str.tostring(activeRiskMoney, "#.##"), text_color=color.orange, text_size=size.tiny)

//================ ALERTS ================
alertcondition(takeBuy, "BUY", "BUY Signal")
alertcondition(takeSell, "SELL", "SELL Signal")
````
