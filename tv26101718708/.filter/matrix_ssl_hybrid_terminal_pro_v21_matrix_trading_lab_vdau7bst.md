# Matrix SSL Hybrid Terminal PRO V2.1 [Matrix Trading Lab]

- url: https://www.tradingview.com/script/VDau7BSt/
- type: indicator
- pine_id: PUB;f8081700b4af41bb928d0813455511a7
- version: 1.0

## Description

Matrix SSL Hybrid Terminal PRO V2.1

Advanced Trend State Lock & Momentum Confirmation System

Matrix SSL Hybrid Terminal PRO V2.1 is a trend-following and momentum confirmation system designed to reduce noisy reversals and improve trend stability through a locked trend-state engine.

Unlike traditional SSL-style systems that rapidly switch between bullish and bearish states during volatility spikes, this version introduces a confirmation-based trend locking mechanism using:

• Multi-bar trend confirmation
• ATR-based volatility buffer
• Optional RSI/MACD momentum validation
• Warning engine for early pressure detection
• Direction lock to avoid repetitive BUY/SELL signals

The indicator focuses on maintaining cleaner trend structure while reducing false reversals caused by short-term price fluctuations.

━━━━━━━━━━━━━━━━━━
Core Features
━━━━━━━━━━━━━━━━━━

• Trend State Lock Engine
Trend color changes require confirmation instead of reacting instantly to every candle fluctuation.

• ATR Buffer Protection
Helps filter out small fake breakouts around the trend line.

• Momentum Confirmation
Optional RSI and MACD validation for stronger trend transitions.

• BUY / SELL Confirmation Logic
Signals only appear after confirmed trend alignment and direction lock validation.

• BUY WARNING / SELL WARNING
Early pressure detection system using:

Volume spikes
MACD crosses
RSI strength/weakness

• Trend Weakening Detection
Identifies potential momentum deterioration before confirmed reversals.

• Take Profit Zone Detection
Highlights extended moves based on ATR distance from entry.

• Professional Dashboard
Displays:

Locked trend bias
Signal state
Warning status
RSI/MACD state
Volume pressure
Last BUY/SELL price & time
ATR risk level
Entry distance condition

━━━━━━━━━━━━━━━━━━
Recommended V2.1 Settings
━━━━━━━━━━━━━━━━━━

4H Swing / Trend Trading:
• Confirmation Bars: 2
• Trend Buffer ATR Multiplier: 0.10
• RSI/MACD Momentum Support: ON

1H Intraday / Crypto:
• Confirmation Bars: 2
• Trend Buffer ATR Multiplier: 0.15
• RSI/MACD Momentum Support: ON

15m Aggressive Intraday:
• Confirmation Bars: 3
• Trend Buffer ATR Multiplier: 0.20
• Warning Filter: ON

━━━━━━━━━━━━━━━━━━
Best Usage
━━━━━━━━━━━━━━━━━━

This indicator is designed primarily for:
• Trend continuation analysis
• Swing trading
• Momentum-based market structure tracking
• Medium-to-high timeframe trend environments

The system generally performs best on:
• 1H
• 4H
• Daily charts

## Source Code

````pine
//@version=6
indicator("Matrix SSL Hybrid Terminal PRO V2.1 [Matrix Trading Lab]", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupMain = "Main Trend Engine"
src      = input.source(close, "Source", group=groupMain)
maType   = input.string("HMA", "Trend Line Type", options=["SMA","EMA","DEMA","TEMA","WMA","HMA","LSMA","TMA","Kijun"], group=groupMain)
baseLen  = input.int(60, "Trend Line Length", minval=1, group=groupMain)
chanMult = input.float(0.25, "Trend Channel Multiplier", step=0.05, group=groupMain)

groupState = "Trend State Lock Engine"
confirmBars = input.int(3, "Color Change Confirmation Bars", minval=1, maxval=10, group=groupState)
bufferAtrMult = input.float(0.10, "Trend Buffer ATR Multiplier", step=0.05, group=groupState)
requireMomentumForFlip = input.bool(true, "Require RSI / MACD Support For Color Flip", group=groupState)

groupSSL = "Optional SSL Lines"
sslType  = input.string("HMA", "SSL Direction Type", options=["SMA","EMA","DEMA","TEMA","WMA","HMA","LSMA","TMA","Kijun"], group=groupSSL)
sslLen   = input.int(10, "SSL Direction Length", minval=1, group=groupSSL)
ssl2Type = input.string("EMA", "SSL2 Continuation Type", options=["SMA","EMA","DEMA","TEMA","WMA","HMA","LSMA","TMA","Kijun"], group=groupSSL)
ssl2Len  = input.int(5, "SSL2 Continuation Length", minval=1, group=groupSSL)

groupWarn = "Warning Engine"
rsiLen       = input.int(14, "RSI Length", minval=1, group=groupWarn)
rsiBullLevel = input.float(55, "RSI Buy Strength Level", step=0.5, group=groupWarn)
rsiBearLevel = input.float(45, "RSI Sell Weakness Level", step=0.5, group=groupWarn)
macdFast     = input.int(12, "MACD Fast", minval=1, group=groupWarn)
macdSlow     = input.int(26, "MACD Slow", minval=1, group=groupWarn)
macdSignal   = input.int(9, "MACD Signal", minval=1, group=groupWarn)
volLen       = input.int(20, "Volume Average Length", minval=1, group=groupWarn)
volMult      = input.float(1.5, "Volume Spike Multiplier", step=0.1, group=groupWarn)

groupRisk = "Risk / Profit Engine"
atrLen          = input.int(14, "ATR Length", minval=1, group=groupRisk)
riskLook        = input.int(100, "ATR Risk Lookback", minval=20, group=groupRisk)
tpAtrMult       = input.float(2.0, "Take Profit Zone ATR Distance", step=0.25, group=groupRisk)
maxDistanceATR  = input.float(2.5, "Max Entry Distance From Trend Line", step=0.25, group=groupRisk)

groupFilter = "Signal Filters"
useConfirmed       = input.bool(true, "Use Candle Close Confirmation", group=groupFilter)
avoidFar           = input.bool(true, "Avoid Very Far Entries", group=groupFilter)
useWarningAsFilter = input.bool(false, "Require Warning Support For Confirmed Signal", group=groupFilter)

groupVisual = "Visual Settings"
showTrendLine = input.bool(true, "Show Main Trend Line", group=groupVisual)
showChannels  = input.bool(false, "Show Upper / Lower Baseline Channel", group=groupVisual)
showSSL       = input.bool(false, "Show SSL Direction Line", group=groupVisual)
showSSL2      = input.bool(false, "Show SSL2 Continuation Line", group=groupVisual)
showSignals   = input.bool(true, "Show BUY / SELL Signals", group=groupVisual)
showDashboard = input.bool(true, "Show Dashboard", group=groupVisual)
colorBars     = input.bool(false, "Color Bars", group=groupVisual)

bullColor = input.color(#00c3ff, "Bullish / Blue Color", group="Colors")
bearColor = input.color(#ff0062, "Bearish / Red Color", group="Colors")
neuColor  = input.color(#777777, "Neutral Color", group="Colors")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MOVING AVERAGE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_tema(_src, _len) =>
    e1 = ta.ema(_src, _len)
    e2 = ta.ema(e1, _len)
    e3 = ta.ema(e2, _len)
    3.0 * e1 - 3.0 * e2 + e3

f_ma(_type, _src, _len) =>
    int lenSafe = math.max(1, _len)
    float result = na

    if _type == "SMA"
        result := ta.sma(_src, lenSafe)
    else if _type == "EMA"
        result := ta.ema(_src, lenSafe)
    else if _type == "DEMA"
        e = ta.ema(_src, lenSafe)
        result := 2.0 * e - ta.ema(e, lenSafe)
    else if _type == "TEMA"
        result := f_tema(_src, lenSafe)
    else if _type == "WMA"
        result := ta.wma(_src, lenSafe)
    else if _type == "HMA"
        halfLen = math.max(1, int(math.round(lenSafe / 2.0)))
        sqrtLen = math.max(1, int(math.round(math.sqrt(lenSafe))))
        result := ta.wma(2.0 * ta.wma(_src, halfLen) - ta.wma(_src, lenSafe), sqrtLen)
    else if _type == "LSMA"
        result := ta.linreg(_src, lenSafe, 0)
    else if _type == "TMA"
        len1 = math.max(1, int(math.ceil(lenSafe / 2.0)))
        len2 = math.max(1, int(math.floor(lenSafe / 2.0)) + 1)
        result := ta.sma(ta.sma(_src, len1), len2)
    else if _type == "Kijun"
        result := math.avg(ta.lowest(low, lenSafe), ta.highest(high, lenSafe))

    result

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLen)
atrRisk = ta.percentrank(atr, riskLook)

trendLine = f_ma(maType, src, baseLen)
rangeMA   = ta.ema(ta.tr(true), baseLen)
upperCh   = trendLine + rangeMA * chanMult
lowerCh   = trendLine - rangeMA * chanMult
buffer    = atr * bufferAtrMult

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WARNING ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsi = ta.rsi(close, rsiLen)
[macdLine, macdSignalLine, macdHist] = ta.macd(close, macdFast, macdSlow, macdSignal)

volMA = ta.sma(volume, volLen)
volumeSpike = volume > volMA * volMult

bullCandle = close > open
bearCandle = close < open

buyVolumePressure  = volumeSpike and bullCandle
sellVolumePressure = volumeSpike and bearCandle

macdBuyWarning  = ta.crossover(macdLine, macdSignalLine)
macdSellWarning = ta.crossunder(macdLine, macdSignalLine)

rsiBuyWarning  = rsi > rsiBullLevel and rsi > rsi[1]
rsiSellWarning = rsi < rsiBearLevel and rsi < rsi[1]

buyWarning  = buyVolumePressure or macdBuyWarning or rsiBuyWarning
sellWarning = sellVolumePressure or macdSellWarning or rsiSellWarning

buyMomentumSupport  = rsi > 50 or macdLine > macdSignalLine or buyVolumePressure
sellMomentumSupport = rsi < 50 or macdLine < macdSignalLine or sellVolumePressure

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND STATE LOCK ENGINE — 3 BAR CONFIRMATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullCondition = close > upperCh + buffer
bearCondition = close < lowerCh - buffer

bullBars = ta.barssince(not bullCondition)
bearBars = ta.barssince(not bearCondition)

bullConfirmed = bullCondition and bullBars >= confirmBars - 1
bearConfirmed = bearCondition and bearBars >= confirmBars - 1

bullFlipOK = bullConfirmed and (requireMomentumForFlip ? buyMomentumSupport : true)
bearFlipOK = bearConfirmed and (requireMomentumForFlip ? sellMomentumSupport : true)

var int trendState = 0

if bullFlipOK and trendState != 1
    trendState := 1

if bearFlipOK and trendState != -1
    trendState := -1

lineIsBlue = trendState == 1
lineIsRed  = trendState == -1

trendColor = lineIsBlue ? bullColor : lineIsRed ? bearColor : neuColor

rawTrendText = bullCondition ? "RAW BULL" : bearCondition ? "RAW BEAR" : "BUFFER"
lockedTrendText = lineIsBlue ? "LOCKED BLUE" : lineIsRed ? "LOCKED RED" : "NEUTRAL"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPTIONAL SSL ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
sslHigh = f_ma(sslType, high, sslLen)
sslLow  = f_ma(sslType, low, sslLen)

var int sslDir = 0
sslDir := close > sslHigh ? 1 : close < sslLow ? -1 : nz(sslDir[1], 0)
sslLine = sslDir < 0 ? sslHigh : sslLow

ssl2High = f_ma(ssl2Type, high, ssl2Len)
ssl2Low  = f_ma(ssl2Type, low, ssl2Len)

var int ssl2Dir = 0
ssl2Dir := close > ssl2High ? 1 : close < ssl2Low ? -1 : nz(ssl2Dir[1], 0)
ssl2Line = ssl2Dir < 0 ? ssl2High : ssl2Low

sslBull = close > sslLine
sslBear = close < sslLine
ssl2Bull = close > ssl2Line
ssl2Bear = close < ssl2Line

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONFIRMED SIGNAL ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
distanceATR = atr > 0 ? math.abs(close - trendLine) / atr : 0.0
entryDistance = distanceATR < 1.0 ? "NEAR" : distanceATR < 2.0 ? "EXTENDED" : "FAR"

distanceOK = avoidFar ? distanceATR <= maxDistanceATR : true
confirmedOK = useConfirmed ? barstate.isconfirmed : true

buyConfirmedRaw = lineIsBlue and close > trendLine and distanceOK and confirmedOK and (useWarningAsFilter ? buyWarning : true)
sellConfirmedRaw = lineIsRed and close < trendLine and distanceOK and confirmedOK and (useWarningAsFilter ? sellWarning : true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SAME DIRECTION LOCK
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int lastSignalDirection = 0

finalBuy  = buyConfirmedRaw and lastSignalDirection != 1
finalSell = sellConfirmedRaw and lastSignalDirection != -1

if finalBuy
    lastSignalDirection := 1

if finalSell
    lastSignalDirection := -1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LAST SIGNAL MEMORY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float lastBuyPrice = na
var float lastSellPrice = na
var string lastBuyTime = "N/A"
var string lastSellTime = "N/A"

if finalBuy
    lastBuyPrice := close
    lastBuyTime := str.format_time(time, "yyyy-MM-dd HH:mm")

if finalSell
    lastSellPrice := close
    lastSellTime := str.format_time(time, "yyyy-MM-dd HH:mm")

lastBuyPriceText = na(lastBuyPrice) ? "N/A" : str.tostring(lastBuyPrice, format.mintick)
lastSellPriceText = na(lastSellPrice) ? "N/A" : str.tostring(lastSellPrice, format.mintick)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POSITION / EXIT / PROFIT ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
inLongMode  = lastSignalDirection == 1
inShortMode = lastSignalDirection == -1

exitWarningLong  = inLongMode and (close < trendLine or sellWarning)
exitWarningShort = inShortMode and (close > trendLine or buyWarning)
exitWarning = exitWarningLong or exitWarningShort

trendWeakLong  = inLongMode and (rsi < 50 or macdHist < macdHist[1] or close < sslLine)
trendWeakShort = inShortMode and (rsi > 50 or macdHist > macdHist[1] or close > sslLine)
trendWeakening = trendWeakLong or trendWeakShort

longProfitATR  = inLongMode and not na(lastBuyPrice) and atr > 0 ? (close - lastBuyPrice) / atr : na
shortProfitATR = inShortMode and not na(lastSellPrice) and atr > 0 ? (lastSellPrice - close) / atr : na

takeProfitLong  = inLongMode and not na(longProfitATR) and longProfitATR >= tpAtrMult
takeProfitShort = inShortMode and not na(shortProfitATR) and shortProfitATR >= tpAtrMult
takeProfitZone = takeProfitLong or takeProfitShort

positionText = inLongMode ? "LONG MODE" : inShortMode ? "SHORT MODE" : "NO POSITION"
biasText = lineIsBlue ? "BULLISH / BLUE" : lineIsRed ? "BEARISH / RED" : "NEUTRAL"
signalText = finalBuy ? "BUY CONFIRMED" : finalSell ? "SELL CONFIRMED" : "WAIT"
riskState = atrRisk >= 75 ? "HIGH" : atrRisk <= 25 ? "LOW" : "NORMAL"

volumePressureText = buyVolumePressure ? "BUY PRESSURE" : sellVolumePressure ? "SELL PRESSURE" : "NORMAL"
macdStateText = macdLine > macdSignalLine ? "BULLISH" : macdLine < macdSignalLine ? "BEARISH" : "NEUTRAL"
rsiStateText = rsi >= rsiBullLevel ? "STRONG" : rsi <= rsiBearLevel ? "WEAK" : "NEUTRAL"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pTrend = plot(showTrendLine ? trendLine : na, "Matrix Locked Trend Line", color=trendColor, linewidth=3)
pUpper = plot(showChannels ? upperCh : na, "Upper Baseline Channel", color=color.new(bullColor, 40))
pLower = plot(showChannels ? lowerCh : na, "Lower Baseline Channel", color=color.new(bearColor, 40))
fill(pUpper, pLower, color=showChannels ? color.new(trendColor, 88) : na, title="Baseline Channel Fill")

plot(showSSL ? sslLine : na, "SSL Direction Line", color=sslBull ? bullColor : sslBear ? bearColor : neuColor, linewidth=2)
plot(showSSL2 ? ssl2Line : na, "SSL2 Continuation Line", color=ssl2Bull ? bullColor : ssl2Bear ? bearColor : neuColor, linewidth=2, style=plot.style_circles)

plotshape(showSignals and finalBuy, title="BUY Confirmed", text="BUY", style=shape.labelup, location=location.belowbar, color=bullColor, textcolor=color.white, size=size.small)
plotshape(showSignals and finalSell, title="SELL Confirmed", text="SELL", style=shape.labeldown, location=location.abovebar, color=bearColor, textcolor=color.white, size=size.small)

barcolor(colorBars ? trendColor : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.islast and showDashboard
    var table dash = table.new(position.top_right, 2, 20, bgcolor=color.new(#111111, 5), border_width=1)

    table.cell(dash, 0, 0, "MATRIX SSL HYBRID", text_color=color.white, bgcolor=color.new(#000000, 0), text_size=size.small)
    table.cell(dash, 1, 0, "PRO V2.1", text_color=color.white, bgcolor=color.new(#000000, 0), text_size=size.small)

    table.cell(dash, 0, 1, "Locked Bias", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, biasText, text_color=color.white, bgcolor=color.new(trendColor, 20), text_size=size.small)

    table.cell(dash, 0, 2, "Raw Trend", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, rawTrendText, text_color=color.white, bgcolor=rawTrendText == "RAW BULL" ? color.new(bullColor, 35) : rawTrendText == "RAW BEAR" ? color.new(bearColor, 35) : color.new(neuColor, 45), text_size=size.small)

    table.cell(dash, 0, 3, "Trend Lock", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 3, lockedTrendText, text_color=color.white, bgcolor=color.new(trendColor, 30), text_size=size.small)

    table.cell(dash, 0, 4, "Signal Status", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 4, signalText, text_color=color.white, bgcolor=finalBuy ? color.new(bullColor, 0) : finalSell ? color.new(bearColor, 0) : color.new(neuColor, 40), text_size=size.small)

    table.cell(dash, 0, 5, "Position Mode", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 5, positionText, text_color=color.white, bgcolor=inLongMode ? color.new(bullColor, 25) : inShortMode ? color.new(bearColor, 25) : color.new(neuColor, 40), text_size=size.small)

    table.cell(dash, 0, 6, "BUY WARNING", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 6, buyWarning ? "ACTIVE" : "CLEAR", text_color=color.white, bgcolor=buyWarning ? color.new(bullColor, 0) : color.new(neuColor, 45), text_size=size.small)

    table.cell(dash, 0, 7, "SELL WARNING", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 7, sellWarning ? "ACTIVE" : "CLEAR", text_color=color.white, bgcolor=sellWarning ? color.new(bearColor, 0) : color.new(neuColor, 45), text_size=size.small)

    table.cell(dash, 0, 8, "Last BUY Price", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 8, lastBuyPriceText, text_color=color.white, bgcolor=color.new(bullColor, 35), text_size=size.small)

    table.cell(dash, 0, 9, "Last BUY Time", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 9, lastBuyTime, text_color=color.white, bgcolor=color.new(bullColor, 45), text_size=size.small)

    table.cell(dash, 0, 10, "Last SELL Price", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 10, lastSellPriceText, text_color=color.white, bgcolor=color.new(bearColor, 35), text_size=size.small)

    table.cell(dash, 0, 11, "Last SELL Time", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 11, lastSellTime, text_color=color.white, bgcolor=color.new(bearColor, 45), text_size=size.small)

    table.cell(dash, 0, 12, "EXIT WARNING", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 12, exitWarning ? "ACTIVE" : "CLEAR", text_color=color.white, bgcolor=exitWarning ? color.new(bearColor, 0) : color.new(neuColor, 45), text_size=size.small)

    table.cell(dash, 0, 13, "TREND WEAKENING", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 13, trendWeakening ? "YES" : "NO", text_color=color.white, bgcolor=trendWeakening ? color.new(color.orange, 0) : color.new(neuColor, 45), text_size=size.small)

    table.cell(dash, 0, 14, "TAKE PROFIT ZONE", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 14, takeProfitZone ? "ACTIVE" : "NO", text_color=color.white, bgcolor=takeProfitZone ? color.new(bullColor, 0) : color.new(neuColor, 45), text_size=size.small)

    table.cell(dash, 0, 15, "RSI State", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 15, rsiStateText + " / " + str.tostring(math.round(rsi, 1)), text_color=color.white, bgcolor=rsiStateText == "STRONG" ? color.new(bullColor, 30) : rsiStateText == "WEAK" ? color.new(bearColor, 30) : color.new(neuColor, 45), text_size=size.small)

    table.cell(dash, 0, 16, "MACD State", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 16, macdStateText, text_color=color.white, bgcolor=macdStateText == "BULLISH" ? color.new(bullColor, 30) : macdStateText == "BEARISH" ? color.new(bearColor, 30) : color.new(neuColor, 45), text_size=size.small)

    table.cell(dash, 0, 17, "Volume Pressure", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 17, volumePressureText, text_color=color.white, bgcolor=buyVolumePressure ? color.new(bullColor, 25) : sellVolumePressure ? color.new(bearColor, 25) : color.new(neuColor, 45), text_size=size.small)

    table.cell(dash, 0, 18, "Entry Distance", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 18, entryDistance, text_color=color.white, bgcolor=entryDistance == "NEAR" ? color.new(bullColor, 25) : entryDistance == "EXTENDED" ? color.new(color.orange, 20) : color.new(bearColor, 20), text_size=size.small)

    table.cell(dash, 0, 19, "ATR Risk", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 19, riskState + " / " + str.tostring(math.round(atrRisk, 1)) + "%", text_color=color.white, bgcolor=riskState == "HIGH" ? color.new(bearColor, 15) : riskState == "LOW" ? color.new(bullColor, 15) : color.new(neuColor, 35), text_size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(finalBuy, title="Matrix SSL V2.1 BUY CONFIRMED", message="Matrix SSL Hybrid Terminal PRO V2.1: BUY confirmed.")
alertcondition(finalSell, title="Matrix SSL V2.1 SELL CONFIRMED", message="Matrix SSL Hybrid Terminal PRO V2.1: SELL confirmed.")
alertcondition(buyWarning, title="Matrix SSL V2.1 BUY WARNING", message="Matrix SSL Hybrid Terminal PRO V2.1: BUY warning active.")
alertcondition(sellWarning, title="Matrix SSL V2.1 SELL WARNING", message="Matrix SSL Hybrid Terminal PRO V2.1: SELL warning active.")
alertcondition(exitWarning, title="Matrix SSL V2.1 EXIT WARNING", message="Matrix SSL Hybrid Terminal PRO V2.1: Exit warning active.")
alertcondition(trendWeakening, title="Matrix SSL V2.1 TREND WEAKENING", message="Matrix SSL Hybrid Terminal PRO V2.1: Trend weakening detected.")
alertcondition(takeProfitZone, title="Matrix SSL V2.1 TAKE PROFIT ZONE", message="Matrix SSL Hybrid Terminal PRO V2.1: Take profit zone active.")
````
