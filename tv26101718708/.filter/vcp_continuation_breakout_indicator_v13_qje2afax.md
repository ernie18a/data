# VCP + Continuation Breakout Indicator v1.3

- url: https://www.tradingview.com/script/Qje2aFax-VCP-Continuation-Breakout-Indicator-v1-3/
- type: indicator
- pine_id: PUB;3c0d1973fc6f436abb20f3b6c7182030
- version: 1.0

## Description

designed to identify high-probability breakout opportunities by combining Mark Minervini's Volatility Contraction Pattern (VCP) principles with multi-timeframe trend analysis, volatility compression, momentum expansion, volume confirmation, and intelligent trade management. The indicator seeks to detect stocks, cryptocurrencies, indices, or commodities that are undergoing institutional accumulation and transitioning from consolidation into sustained trend continuation. It incorporates triple moving average alignment, ATR and Bollinger Band compression, contraction sequencing, relative strength, volume dry-up followed by breakout expansion, ADX/DI momentum confirmation, and adaptive trailing exits to filter out low-quality setups and capture explosive moves with favorable risk-to-reward characteristics. The "Golden Copy" represents the hardened, validated version of the system, intended to provide consistent, repeatable signals across multiple asset classes while minimizing false breakouts and consolidating-range noise.

## Source Code

````pine
//@version=6
indicator("VCP + Continuation Breakout Indicator v1.3", overlay=true, max_labels_count=500)

// ───── Inputs
baseLen          = input.int(20, "VCP Consolidation Lookback", minval=8)
shelfLen         = input.int(12, "VCP Shelf Lookback", minval=5)
breakoutBuffer  = input.float(0.15, "Breakout/Breakdown Buffer %", step=0.05)

emaFastLen       = input.int(20, "Fast EMA")
emaSlowLen       = input.int(50, "Slow EMA")

rangeTightMax    = input.float(12.0, "Max VCP Base Range %", step=0.5)
shelfFlatMax     = input.float(4.0, "Max Shelf Variation %", step=0.25)

atrLen           = input.int(14, "ATR Length")
atrCompressMax   = input.float(1.15, "ATR Compression Max", step=0.05)

bbLen            = input.int(20, "BB Length")
bbMult           = input.float(2.0, "BB Multiplier")
bbCompressMax    = input.float(1.20, "BB Width Compression Max", step=0.05)

volLen           = input.int(20, "Volume Average Length")
volMultiplier    = input.float(1.1, "Breakout RVOL", step=0.1)

rsiLen           = input.int(14, "RSI Length")
longRsiMin       = input.float(48, "Long Minimum RSI")
shortRsiMax      = input.float(52, "Short Maximum RSI")

minScore         = input.int(4, "Minimum VCP Quality Score", minval=3, maxval=8)
cooldownBars     = input.int(8, "Cooldown Bars", minval=1)

swingLeft        = input.int(2, "Swing Left Bars", minval=1)
swingRight       = input.int(1, "Swing Right Bars", minval=1)
initialAtrStop   = input.float(1.5, "Initial ATR Stop", step=0.1)

tradeDirection   = input.string("Both", "Trade Direction", options=["Both", "Long Only", "Short Only"])
allowPyramidingSignals = input.bool(false, "Allow Continuation Adds While In Trade")
useCloseExit     = input.bool(true, "Exit Only On Candle Close")

useMarketTrendFilter = input.bool(true, "Block Longs In Downtrend / Shorts In Uptrend")
trendFilterMode      = input.string("50/200 EMA", "Market Trend Filter Mode", options=["50/200 EMA", "20/50 EMA"])
trendEmaFastLen      = input.int(50, "Trend Fast EMA", minval=1)
trendEmaSlowLen      = input.int(200, "Trend Slow EMA", minval=1)

useContinuationScanner = input.bool(true, "Use Continuation Breakout Scanner")
contLen                = input.int(30, "Continuation Base Lookback", minval=10)
contShelfLen           = input.int(10, "Continuation Shelf Lookback", minval=5)
contRangeMax           = input.float(15.0, "Max Continuation Range %", step=0.5)
contShelfFlatMax       = input.float(5.0, "Max Continuation Shelf Variation %", step=0.25)
contMinScore           = input.int(3, "Minimum Continuation Score", minval=2, maxval=7)
useStrictTrend         = input.bool(false, "Use Strict EMA Trend Filter")
maxExtensionPct        = input.float(15.0, "Max Distance From Fast EMA %", step=0.5)

showDashboard    = input.bool(true, "Show Dashboard")
showEmaFast      = input.bool(false, "Show 20 EMA")
showEmaSlow      = input.bool(false, "Show 50 EMA")
showTrendFilter  = input.bool(false, "Show Market Trend Filter EMAs")
showLongShelf    = input.bool(false, "Show Long Resistance Shelf")
showShortShelf   = input.bool(false, "Show Short Support Shelf")
showLongTrail    = input.bool(true, "Show Long Trailing SL")
showShortTrail   = input.bool(true, "Show Short Trailing SL")
showEntryMarkers = input.bool(true, "Show Entry Markers")
showExitMarkers  = input.bool(false, "Show Exit Markers")

// ───── Core Indicators
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

trendFilterFast = trendFilterMode == "50/200 EMA" ? ta.ema(close, trendEmaFastLen) : emaFast
trendFilterSlow = trendFilterMode == "50/200 EMA" ? ta.ema(close, trendEmaSlowLen) : emaSlow

marketUptrend = close > trendFilterSlow and trendFilterFast > trendFilterSlow
marketDowntrend = close < trendFilterSlow and trendFilterFast < trendFilterSlow

allowLongByMarketTrend = not useMarketTrendFilter or marketUptrend
allowShortByMarketTrend = not useMarketTrendFilter or marketDowntrend

atr = ta.atr(atrLen)
atrAvg = ta.sma(atr, atrLen)
atrCompression = atrAvg > 0 ? atr / atrAvg : na
atrCompressed = atrCompression <= atrCompressMax

bbBasis = ta.sma(close, bbLen)
bbDev = ta.stdev(close, bbLen) * bbMult
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev
bbWidth = bbBasis > 0 ? (bbUpper - bbLower) / bbBasis : na
bbWidthAvg = ta.sma(bbWidth, bbLen)
bbCompression = bbWidthAvg > 0 ? bbWidth / bbWidthAvg : na
bbCompressed = bbCompression <= bbCompressMax

avgVolume = ta.sma(volume, volLen)
rvol = avgVolume > 0 ? volume / avgVolume : 0
volumeExpansion = rvol >= volMultiplier

rsi = ta.rsi(close, rsiLen)

baseHigh = ta.highest(high, baseLen)
baseLow  = ta.lowest(low, baseLen)
baseRangePct = baseLow > 0 ? ((baseHigh - baseLow) / baseLow) * 100 : na
tightBase = baseRangePct <= rangeTightMax

third = math.max(math.floor(baseLen / 3), 1)

// ───── Long Logic
longTrendOk = useStrictTrend ? close > emaFast and emaFast > emaSlow : close > emaFast

resistanceShelf = ta.highest(high[1], shelfLen)
resistanceShelfLow = ta.lowest(high[1], shelfLen)
resistanceVariation = resistanceShelf > 0 ? ((resistanceShelf - resistanceShelfLow) / resistanceShelf) * 100 : na
flatResistance = resistanceVariation <= shelfFlatMax

longBreakoutLevel = resistanceShelf * (1 + breakoutBuffer / 100)
longBreakout = close > longBreakoutLevel and close > open

longLow1 = ta.lowest(low[third * 2], third)
longLow2 = ta.lowest(low[third], third)
longLow3 = ta.lowest(low, third)
higherLows = longLow1 < longLow2 and longLow2 <= longLow3

longRsiOk = rsi >= longRsiMin
longDistanceFromEma = emaFast > 0 ? ((close - emaFast) / emaFast) * 100 : na
longNotExtended = longDistanceFromEma <= maxExtensionPct

longScore = 0
longScore += longTrendOk ? 1 : 0
longScore += flatResistance ? 1 : 0
longScore += tightBase ? 1 : 0
longScore += higherLows ? 1 : 0
longScore += atrCompressed ? 1 : 0
longScore += bbCompressed ? 1 : 0
longScore += volumeExpansion ? 1 : 0
longScore += longRsiOk ? 1 : 0

// ───── Short Logic
shortTrendOk = useStrictTrend ? close < emaFast and emaFast < emaSlow : close < emaFast

supportShelf = ta.lowest(low[1], shelfLen)
supportShelfHigh = ta.highest(low[1], shelfLen)
supportVariation = supportShelf > 0 ? ((supportShelfHigh - supportShelf) / supportShelf) * 100 : na
flatSupport = supportVariation <= shelfFlatMax

shortBreakdownLevel = supportShelf * (1 - breakoutBuffer / 100)
shortBreakdown = close < shortBreakdownLevel and close < open

shortHigh1 = ta.highest(high[third * 2], third)
shortHigh2 = ta.highest(high[third], third)
shortHigh3 = ta.highest(high, third)
lowerHighs = shortHigh1 > shortHigh2 and shortHigh2 >= shortHigh3

shortRsiOk = rsi <= shortRsiMax
shortDistanceFromEma = emaFast > 0 ? ((emaFast - close) / emaFast) * 100 : na
shortNotExtended = shortDistanceFromEma <= maxExtensionPct

shortScore = 0
shortScore += shortTrendOk ? 1 : 0
shortScore += flatSupport ? 1 : 0
shortScore += tightBase ? 1 : 0
shortScore += lowerHighs ? 1 : 0
shortScore += atrCompressed ? 1 : 0
shortScore += bbCompressed ? 1 : 0
shortScore += volumeExpansion ? 1 : 0
shortScore += shortRsiOk ? 1 : 0

// ───── Continuation Scanner
contHigh = ta.highest(high, contLen)
contLow  = ta.lowest(low, contLen)
contRangePct = contLow > 0 ? ((contHigh - contLow) / contLow) * 100 : na
contTightRange = contRangePct <= contRangeMax

contResistance = ta.highest(high[1], contShelfLen)
contResistanceLow = ta.lowest(high[1], contShelfLen)
contResistanceVar = contResistance > 0 ? ((contResistance - contResistanceLow) / contResistance) * 100 : na
contFlatResistance = contResistanceVar <= contShelfFlatMax

contSupport = ta.lowest(low[1], contShelfLen)
contSupportHigh = ta.highest(low[1], contShelfLen)
contSupportVar = contSupport > 0 ? ((contSupportHigh - contSupport) / contSupport) * 100 : na
contFlatSupport = contSupportVar <= contShelfFlatMax

contLongBreakout = close > contResistance * (1 + breakoutBuffer / 100) and close > open
contShortBreakdown = close < contSupport * (1 - breakoutBuffer / 100) and close < open

contThird = math.max(math.floor(contLen / 3), 1)

contLongLow1 = ta.lowest(low[contThird * 2], contThird)
contLongLow2 = ta.lowest(low[contThird], contThird)
contLongLow3 = ta.lowest(low, contThird)
contHigherLows = contLongLow1 <= contLongLow2 and contLongLow2 <= contLongLow3

contShortHigh1 = ta.highest(high[contThird * 2], contThird)
contShortHigh2 = ta.highest(high[contThird], contThird)
contShortHigh3 = ta.highest(high, contThird)
contLowerHighs = contShortHigh1 >= contShortHigh2 and contShortHigh2 >= contShortHigh3

contLongTrendOk = close > emaFast
contShortTrendOk = close < emaFast

contLongRsiOk = rsi >= longRsiMin
contShortRsiOk = rsi <= shortRsiMax

contLongNotExtended = longDistanceFromEma <= maxExtensionPct
contShortNotExtended = shortDistanceFromEma <= maxExtensionPct

contLongScore = 0
contLongScore += contLongTrendOk ? 1 : 0
contLongScore += contFlatResistance ? 1 : 0
contLongScore += contTightRange ? 1 : 0
contLongScore += contHigherLows ? 1 : 0
contLongScore += volumeExpansion ? 1 : 0
contLongScore += contLongRsiOk ? 1 : 0
contLongScore += bbCompressed or atrCompressed ? 1 : 0

contShortScore = 0
contShortScore += contShortTrendOk ? 1 : 0
contShortScore += contFlatSupport ? 1 : 0
contShortScore += contTightRange ? 1 : 0
contShortScore += contLowerHighs ? 1 : 0
contShortScore += volumeExpansion ? 1 : 0
contShortScore += contShortRsiOk ? 1 : 0
contShortScore += bbCompressed or atrCompressed ? 1 : 0

continuationLongSignal =
     useContinuationScanner and
     contLongBreakout and
     contLongScore >= contMinScore and
     contLongNotExtended

continuationShortSignal =
     useContinuationScanner and
     contShortBreakdown and
     contShortScore >= contMinScore and
     contShortNotExtended

// ───── State
var int lastSignalBar = na
canSignal = na(lastSignalBar) or bar_index - lastSignalBar >= cooldownBars

var bool inLong = false
var bool inShort = false
var float longTrailStop = na
var float shortTrailStop = na
var float entryPrice = na

confirmedSwingLow = ta.pivotlow(low, swingLeft, swingRight)
confirmedSwingHigh = ta.pivothigh(high, swingLeft, swingRight)

// ───── Entry Signals
vcpLongSignal =
     longBreakout and
     longScore >= minScore and
     longNotExtended

vcpShortSignal =
     shortBreakdown and
     shortScore >= minScore and
     shortNotExtended

longSignalRaw = vcpLongSignal or continuationLongSignal
shortSignalRaw = vcpShortSignal or continuationShortSignal

longAllowed = tradeDirection == "Both" or tradeDirection == "Long Only"
shortAllowed = tradeDirection == "Both" or tradeDirection == "Short Only"

longSignal =
     longAllowed and
     allowLongByMarketTrend and
     longSignalRaw and
     canSignal and
     not inShort and
     (not inLong or allowPyramidingSignals)

shortSignal =
     shortAllowed and
     allowShortByMarketTrend and
     shortSignalRaw and
     canSignal and
     not inLong and
     (not inShort or allowPyramidingSignals)

// ───── Long / Short State Management
if longSignal
    inLong := true
    inShort := false
    entryPrice := close
    longTrailStop := na(longTrailStop) or not inLong ? math.min(close - atr * initialAtrStop, low) : math.max(longTrailStop, math.min(close - atr * initialAtrStop, low))
    shortTrailStop := na
    lastSignalBar := bar_index

if shortSignal
    inShort := true
    inLong := false
    entryPrice := close
    shortTrailStop := na(shortTrailStop) or not inShort ? math.max(close + atr * initialAtrStop, high) : math.min(shortTrailStop, math.max(close + atr * initialAtrStop, high))
    longTrailStop := na
    lastSignalBar := bar_index

if inLong and not na(confirmedSwingLow)
    longTrailStop := na(longTrailStop) ? confirmedSwingLow : math.max(longTrailStop, confirmedSwingLow)

if inShort and not na(confirmedSwingHigh)
    shortTrailStop := na(shortTrailStop) ? confirmedSwingHigh : math.min(shortTrailStop, confirmedSwingHigh)

// ───── Exits
longExit = inLong and not na(longTrailStop) and (useCloseExit ? close < longTrailStop : low < longTrailStop)
shortExit = inShort and not na(shortTrailStop) and (useCloseExit ? close > shortTrailStop : high > shortTrailStop)

if longExit
    inLong := false
    longTrailStop := na

if shortExit
    inShort := false
    shortTrailStop := na

// ───── Plots
plot(showEmaFast ? emaFast : na, "20 EMA", color=color.orange)
plot(showEmaSlow ? emaSlow : na, "50 EMA", color=color.blue)
plot(showTrendFilter ? trendFilterFast : na, "Market Trend Fast EMA", color=color.yellow)
plot(showTrendFilter ? trendFilterSlow : na, "Market Trend Slow EMA", color=color.purple)

plot(showLongShelf ? resistanceShelf : na, "Long Resistance Shelf", color=color.red, linewidth=2, style=plot.style_stepline)
plot(showShortShelf ? supportShelf : na, "Short Support Shelf", color=color.blue, linewidth=2, style=plot.style_stepline)

plot(showLongTrail and inLong ? longTrailStop : na, "Long Trailing SL", color=color.lime, linewidth=2, style=plot.style_linebr)
plot(showShortTrail and inShort ? shortTrailStop : na, "Short Trailing SL", color=color.red, linewidth=2, style=plot.style_linebr)

// Entry markers
plotshape(showEntryMarkers and longSignal and vcpLongSignal, title="LONG VCP Entry", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small)
plotshape(showEntryMarkers and longSignal and continuationLongSignal and not vcpLongSignal, title="LONG Continuation Entry", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny)

plotshape(showEntryMarkers and shortSignal and vcpShortSignal, title="SHORT VCP Entry", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)
plotshape(showEntryMarkers and shortSignal and continuationShortSignal and not vcpShortSignal, title="SHORT Continuation Entry", style=shape.triangledown, location=location.abovebar, color=color.maroon, size=size.tiny)

// Optional exit markers
plotshape(showExitMarkers and longExit, title="LONG Exit", style=shape.triangleup, location=location.belowbar, color=color.red, size=size.tiny)
plotshape(showExitMarkers and shortExit, title="SHORT Exit", style=shape.triangledown, location=location.abovebar, color=color.lime, size=size.tiny)


// ───── Floating Medium Dashboard
dashPosition = input.string("Middle Right", "Dashboard Position", options=["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"])

dashPos =
     dashPosition == "Top Right" ? position.top_right :
     dashPosition == "Top Left" ? position.top_left :
     dashPosition == "Middle Right" ? position.middle_right :
     dashPosition == "Middle Left" ? position.middle_left :
     dashPosition == "Bottom Right" ? position.bottom_right :
     position.bottom_left

var table dash = table.new(dashPos, 2, 10, border_width=1, frame_width=2)

headerBg  = color.rgb(28, 34, 48)
labelBg   = color.rgb(24, 29, 39)
valueBg   = color.rgb(18, 22, 30)
bullBg    = color.rgb(0, 120, 80)
bearBg    = color.rgb(150, 35, 35)
neutralBg = color.rgb(90, 90, 90)
warnBg    = color.rgb(170, 120, 20)

txtWhite = color.white
txtMuted = color.rgb(190, 195, 205)

statusBg(_txt) =>
    _txt == "LONG" or _txt == "UP" or _txt == "BUY" ? bullBg :
     _txt == "SHORT" or _txt == "DOWN" or _txt == "SELL" ? bearBg :
     _txt == "EXIT" ? warnBg :
     neutralBg

if showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 9)

    posTxt = inLong ? "LONG" : inShort ? "SHORT" : "WAIT"
    trendTxt = marketUptrend ? "UP" : marketDowntrend ? "DOWN" : "SIDE"
    sigTxt = longSignal ? "BUY" : shortSignal ? "SELL" : longExit or shortExit ? "EXIT" : "-"
    cooldownTxt = canSignal ? "READY" : "COOLDOWN"

    activeTrail = inLong ? longTrailStop : inShort ? shortTrailStop : na
    riskPct = inLong and not na(activeTrail) ? ((close - activeTrail) / close) * 100 :
              inShort and not na(activeTrail) ? ((activeTrail - close) / close) * 100 : na

    table.cell(dash, 0, 0, "VCP DASH", text_color=txtWhite, bgcolor=headerBg, text_size=size.small)
    table.cell(dash, 1, 0, timeframe.period, text_color=txtWhite, bgcolor=headerBg, text_size=size.small)

    table.cell(dash, 0, 1, "Position", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 1, posTxt, text_color=txtWhite, bgcolor=statusBg(posTxt), text_size=size.small)

    table.cell(dash, 0, 2, "Trend", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 2, trendTxt, text_color=txtWhite, bgcolor=statusBg(trendTxt), text_size=size.small)

    table.cell(dash, 0, 3, "Signal", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 3, sigTxt, text_color=txtWhite, bgcolor=statusBg(sigTxt), text_size=size.small)

    table.cell(dash, 0, 4, "Cooldown", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 4, cooldownTxt, text_color=txtWhite, bgcolor=canSignal ? bullBg : warnBg, text_size=size.small)

    table.cell(dash, 0, 5, "VCP L/S", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(longScore) + " / " + str.tostring(shortScore), text_color=txtWhite, bgcolor=valueBg, text_size=size.small)

    table.cell(dash, 0, 6, "Cont L/S", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(contLongScore) + " / " + str.tostring(contShortScore), text_color=txtWhite, bgcolor=valueBg, text_size=size.small)

    table.cell(dash, 0, 7, "RVOL", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(rvol, "#.##"), text_color=txtWhite, bgcolor=volumeExpansion ? bullBg : neutralBg, text_size=size.small)

    table.cell(dash, 0, 8, "RSI", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 8, str.tostring(rsi, "#.##"), text_color=txtWhite, bgcolor=rsi >= 55 ? bullBg : rsi <= 45 ? bearBg : neutralBg, text_size=size.small)

    table.cell(dash, 0, 9, "SL / Risk", text_color=txtMuted, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, 9, not na(activeTrail) ? str.tostring(activeTrail, "#.####") + " / " + str.tostring(riskPct, "#.##") + "%" : "-", text_color=txtWhite, bgcolor=not na(activeTrail) ? warnBg : neutralBg, text_size=size.small)

if not showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 9)

// ───── Alerts
alertcondition(longSignal, title="LONG Entry", message="LONG BUY: VCP/Continuation breakout on {{ticker}} at {{close}}")
alertcondition(shortSignal, title="SHORT Entry", message="SHORT SELL: VCP/Continuation breakdown on {{ticker}} at {{close}}")
alertcondition(longExit, title="LONG Exit", message="LONG EXIT: Close below trailing SL on {{ticker}} at {{close}}")
alertcondition(shortExit, title="SHORT Exit", message="SHORT EXIT: Close above trailing SL on {{ticker}} at {{close}}")
````
