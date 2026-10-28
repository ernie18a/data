# ORB + VWAP EMA9 Alert

- url: https://www.tradingview.com/script/8mUUgGGc-ORB-VWAP-EMA9-Alert/
- type: indicator
- pine_id: PUB;86bc1957190a40caa6997aaf5240730c
- version: 4.0

## Description

DYODD

Alert to Long or Short ORB using EMA9 and VWAP

## Source Code

````pine
//@version=6
indicator("ORB 15m A-Grade with VWAP - Early Pullback Improved", overlay=true, max_lines_count=500, max_labels_count=500)

// =====================
// Inputs
// =====================
tz              = input.string("America/New_York", "Timezone")
orSession       = input.session("0930-0945", "Opening Range")
tradeSession    = input.session("0945-1130", "Trading Window")

emaLen          = input.int(9, "EMA Length")
atrLen          = input.int(14, "ATR Length")
rvolLen         = input.int(20, "RVOL Length")

atrMultiple     = input.float(1.5, "ATR Multiple for SL / TP1", step=0.1)
touchBufferATR  = input.float(0.15, "Hold Buffer x ATR", step=0.05)
rvolMin         = input.float(1.5, "Minimum RVOL", step=0.1)

maxBarsAfterBreakout = input.int(8, "Max Bars After OR Breakout", minval=1)
emaSlopeBars         = input.int(3, "EMA9 Slope Lookback")
vwapSlopeBars        = input.int(3, "VWAP Slope Lookback")
minSlopeATR          = input.float(0.05, "Minimum Slope x ATR", step=0.01)
volExpandMult        = input.float(1.2, "Signal Volume Expansion", step=0.1)

// Auto-detect tech tickers
techTickers = "AAPL,MSFT,NVDA,GOOGL,GOOG,META,TSLA,AMZN,AMD,QCOM,AVGO,ORCL,CRM,ADBE,INTC,MU,AMAT,KLAC,LRCX,MRVL,SNOW,NOW,PANW,CRWD,ZS,NET,DDOG,MDB,TQQQ,TEAM,SHOP"

isAutoTech      = str.contains(techTickers, syminfo.ticker)
manualOverride  = input.string("Auto", "Market Filter Override", options=["Auto", "SPY + QQQ", "SPY Only"])
isTechStock     = manualOverride == "Auto" ? isAutoTech : manualOverride == "SPY + QQQ"

// =====================
// Sessions
// =====================
inOR        = not na(time(timeframe.period, orSession, tz))
inTradeTime = not na(time(timeframe.period, tradeSession, tz))
newOR       = inOR and not inOR[1]
newDay      = ta.change(time("D")) != 0

// =====================
// Indicators
// =====================
ema9 = ta.ema(close, emaLen)
vwap = ta.vwap(close)
atr  = ta.atr(atrLen)

avgVol = ta.sma(volume, rvolLen)
rvol   = avgVol > 0 ? volume / avgVol : na

buffer = atr * touchBufferATR

emaSlopeUp   = ema9 > ema9[emaSlopeBars] + atr * minSlopeATR
emaSlopeDown = ema9 < ema9[emaSlopeBars] - atr * minSlopeATR

vwapSlopeUp   = vwap > vwap[vwapSlopeBars] + atr * minSlopeATR
vwapSlopeDown = vwap < vwap[vwapSlopeBars] - atr * minSlopeATR

recentVolAvg = ta.sma(volume[1], 5)
volumeExpand = volume > recentVolAvg * volExpandMult

// =====================
// SPY & QQQ VWAP Filter
// =====================
spyClose = request.security("SPY", timeframe.period, close)
spyVWAP  = request.security("SPY", timeframe.period, ta.vwap(close))

qqqClose = request.security("QQQ", timeframe.period, close)
qqqVWAP  = request.security("QQQ", timeframe.period, ta.vwap(close))

spyBullish    = spyClose > spyVWAP
qqqBullish    = qqqClose > qqqVWAP
tickerBullish = close > vwap

spyBearish    = spyClose < spyVWAP
qqqBearish    = qqqClose < qqqVWAP
tickerBearish = close < vwap

marketLongAlign  = isTechStock ? spyBullish and qqqBullish and tickerBullish : spyBullish and tickerBullish
marketShortAlign = isTechStock ? spyBearish and qqqBearish and tickerBearish : spyBearish and tickerBearish

// =====================
// Daily Signal Control
// =====================
var bool longFired  = false
var bool shortFired = false

if newDay
    longFired  := false
    shortFired := false

// =====================
// Opening Range
// =====================
var float orHigh = na
var float orLow  = na
var line[] orhLines = array.new<line>()
var line[] orlLines = array.new<line>()

if newOR
    orHigh := high
    orLow  := low
    longFired  := false
    shortFired := false

    array.push(orhLines, line.new(bar_index, orHigh, bar_index, orHigh, color=color.gray, width=2))
    array.push(orlLines, line.new(bar_index, orLow,  bar_index, orLow,  color=color.gray, width=2))

if inOR
    orHigh := math.max(orHigh, high)
    orLow  := math.min(orLow, low)

    int lastIdx = array.size(orhLines) - 1
    if lastIdx >= 0
        line.set_y1(array.get(orhLines, lastIdx), orHigh)
        line.set_y2(array.get(orhLines, lastIdx), orHigh)
        line.set_x2(array.get(orhLines, lastIdx), bar_index)

        line.set_y1(array.get(orlLines, lastIdx), orLow)
        line.set_y2(array.get(orlLines, lastIdx), orLow)
        line.set_x2(array.get(orlLines, lastIdx), bar_index)

if not inOR and not na(orHigh)
    int lastIdx = array.size(orhLines) - 1
    if lastIdx >= 0
        line.set_x2(array.get(orhLines, lastIdx), bar_index)
        line.set_x2(array.get(orlLines, lastIdx), bar_index)

bgcolor(inOR ? color.new(color.gray, 85) : na)

// =====================
// Breakout Tracking
// =====================
var int  longBreakoutBar  = na
var int  shortBreakoutBar = na
var bool longInvalidated  = false
var bool shortInvalidated = false
var bool longPullbackUsed = false
var bool shortPullbackUsed = false

freshLongBreakout  = not na(orHigh) and close > orHigh and close[1] <= orHigh
freshShortBreakout = not na(orLow) and close < orLow and close[1] >= orLow

if newDay or newOR
    longBreakoutBar   := na
    shortBreakoutBar  := na
    longInvalidated   := false
    shortInvalidated  := false
    longPullbackUsed  := false
    shortPullbackUsed := false

if freshLongBreakout
    longBreakoutBar  := bar_index
    longInvalidated  := false
    longPullbackUsed := false

if freshShortBreakout
    shortBreakoutBar  := bar_index
    shortInvalidated  := false
    shortPullbackUsed := false

if not na(longBreakoutBar) and close < ema9
    longInvalidated := true

if not na(shortBreakoutBar) and close > ema9
    shortInvalidated := true

longFreshEnough  = not na(longBreakoutBar) and bar_index - longBreakoutBar <= maxBarsAfterBreakout
shortFreshEnough = not na(shortBreakoutBar) and bar_index - shortBreakoutBar <= maxBarsAfterBreakout

// =====================
// Long Conditions
// =====================
aboveORH      = not na(orHigh) and close > orHigh
aboveVWAP     = close > vwap
emaAboveVWAP  = ema9 > vwap

holdVWAPLong = low <= vwap + buffer and close > vwap
holdEMA9Long = low <= ema9 + buffer and close > ema9
holdORHLong  = low <= orHigh + buffer and close > orHigh

greenCandle   = close > open
breakPrevHigh = close > high[1]

firstLongPullback = not longPullbackUsed and (holdVWAPLong or holdEMA9Long or holdORHLong)

longSignal =
     inTradeTime and
     not longFired and
     not longInvalidated and
     longFreshEnough and
     aboveORH and
     aboveVWAP and
     emaAboveVWAP and
     emaSlopeUp and
     vwapSlopeUp and
     rvol >= rvolMin and
     volumeExpand and
     greenCandle and
     breakPrevHigh and
     firstLongPullback and
     marketLongAlign

// =====================
// Short Conditions
// =====================
belowORL      = not na(orLow) and close < orLow
belowVWAP     = close < vwap
emaBelowVWAP  = ema9 < vwap

holdVWAPShort = high >= vwap - buffer and close < vwap
holdEMA9Short = high >= ema9 - buffer and close < ema9
holdORLShort  = high >= orLow - buffer and close < orLow

redCandle   = close < open
breakPrevLow = close < low[1]

firstShortPullback = not shortPullbackUsed and (holdVWAPShort or holdEMA9Short or holdORLShort)

shortSignal =
     inTradeTime and
     not shortFired and
     not shortInvalidated and
     shortFreshEnough and
     belowORL and
     belowVWAP and
     emaBelowVWAP and
     emaSlopeDown and
     vwapSlopeDown and
     rvol >= rvolMin and
     volumeExpand and
     redCandle and
     breakPrevLow and
     firstShortPullback and
     marketShortAlign

// =====================
// Entry / SL / TP
// =====================
longEntry = close
longSL    = longEntry - atr * atrMultiple
longTP1   = longEntry + atr * atrMultiple
longTP2   = longEntry + atr * atrMultiple * 2

shortEntry = close
shortSL    = shortEntry + atr * atrMultiple
shortTP1   = shortEntry - atr * atrMultiple
shortTP2   = shortEntry - atr * atrMultiple * 2

if longSignal
    longFired := true
    longPullbackUsed := true

    label.new(
         bar_index,
         low,
         "LONG \nEntry: " + str.tostring(longEntry, format.mintick) +
         "\nSL: "  + str.tostring(longSL,  format.mintick) +
         "\nTP1: " + str.tostring(longTP1, format.mintick) +
         "\nTP2: " + str.tostring(longTP2, format.mintick) +
         "\nRVOL: " + str.tostring(rvol, "#.##"),
         style=label.style_label_up,
         textcolor=color.white,
         color=color.green
     )

    line.new(bar_index, longSL,  bar_index + 50, longSL,  color=color.red,   style=line.style_dotted, width=2)
    line.new(bar_index, longTP1, bar_index + 50, longTP1, color=color.green, style=line.style_dotted, width=2)
    line.new(bar_index, longTP2, bar_index + 50, longTP2, color=color.lime,  style=line.style_dotted, width=2)

if shortSignal
    shortFired := true
    shortPullbackUsed := true

    label.new(
         bar_index,
         high,
         "SHORT \nEntry: " + str.tostring(shortEntry, format.mintick) +
         "\nSL: "  + str.tostring(shortSL,  format.mintick) +
         "\nTP1: " + str.tostring(shortTP1, format.mintick) +
         "\nTP2: " + str.tostring(shortTP2, format.mintick) +
         "\nRVOL: " + str.tostring(rvol, "#.##"),
         style=label.style_label_down,
         textcolor=color.white,
         color=color.red
     )

    line.new(bar_index, shortSL,  bar_index + 50, shortSL,  color=color.red,   style=line.style_dotted, width=2)
    line.new(bar_index, shortTP1, bar_index + 50, shortTP1, color=color.green, style=line.style_dotted, width=2)
    line.new(bar_index, shortTP2, bar_index + 50, shortTP2, color=color.lime,  style=line.style_dotted, width=2)

// =====================
// Filter Mode Display
// =====================
var table filterTable = table.new(position.top_right, 1, 2, border_width=1)

if barstate.islast
    filterLabel = isTechStock ? "SPY + QQQ Filter" : "SPY Only Filter"
    filterColor = isTechStock ? color.new(color.blue, 20) : color.new(color.orange, 20)
    tickerLabel = isTechStock ? "TECH" : "NON-TECH"

    table.cell(filterTable, 0, 0, syminfo.ticker + " — " + tickerLabel, text_color=color.white, bgcolor=filterColor, text_size=size.normal)
    table.cell(filterTable, 0, 1, filterLabel, text_color=color.white, bgcolor=color.new(color.gray, 40), text_size=size.small)

// =====================
// Plots
// =====================
plot(ema9, "EMA 9", color=color.red)
plot(vwap, "VWAP", color=color.green)

plotshape(longSignal, title="Long Early A-Grade Signal", style=shape.triangleup, location=location.belowbar, size=size.small, color=color.green, text="LONG")
plotshape(shortSignal, title="Short Early A-Grade Signal", style=shape.triangledown, location=location.abovebar, size=size.small, color=color.red, text="SHORT")

// =====================
// Alerts
// =====================
alertcondition(longSignal, title="ORB Long Early A-Grade", message="LONG EARLY A-GRADE setup detected.")
alertcondition(shortSignal, title="ORB Short Early A-Grade", message="SHORT EARLY A-GRADE setup detected.")
````
