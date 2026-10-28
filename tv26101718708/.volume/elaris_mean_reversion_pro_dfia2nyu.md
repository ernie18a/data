# Elaris Mean Reversion Pro

- url: https://www.tradingview.com/script/dFiA2nyu-Elaris-Mean-Reversion-Pro/
- type: indicator
- pine_id: PUB;1c423780d42b4e70beeaa6e5c5df2fc9
- version: 1.0

## Description

[b]Elaris Mean Reversion Pro[/b]

Elaris Mean Reversion Pro is a multi-factor mean reversion indicator designed to help traders identify situations where price has moved significantly away from its statistical mean and may be entering a potential reversion phase.

The indicator combines adaptive deviation bands, volatility measurements, momentum filters, market regime analysis, and optional higher-timeframe confirmation to provide a structured framework for analyzing stretched market conditions.

Unlike simple overbought and oversold tools, Elaris Mean Reversion Pro allows users to customize how extremes are measured through Z-Score, ATR-based, or hybrid deviation models while incorporating optional confirmation layers such as RSI, MFI, volume, ADX, and higher-timeframe trend filters.

[b]Key Features[/b]

• Multiple mean calculation methods including EMA, SMA, RMA, WMA, VWMA, and HMA.

• Three deviation models:

* Z-Score Bands
* ATR Bands
* Hybrid Bands

• Mean reversion signal engine with multiple confirmation styles:

* Extreme Touch
* Mean Reclaim
* Candle Rejection

• Optional RSI and MFI extreme-condition filters.

• ADX-based market regime filter to help identify environments where mean reversion conditions may be more relevant.

• Optional volume and volatility filters.

• Higher-timeframe confirmation framework.

• Signal quality scoring system.

• Dynamic mean, deviation bands, and reversion zones.

• Built-in dashboard displaying:

* Market state
* Z-Score
* Distance from mean
* Momentum readings
* Regime status
* Higher-timeframe bias

• Alert conditions for:

* Long mean reversion signals
* Short mean reversion signals
* Upper extreme zones
* Lower extreme zones

[b]How It Works[/b]

The indicator calculates a central mean and measures how far price has deviated from that mean using statistical or volatility-based methods.

When price reaches an extreme deviation zone, the indicator evaluates additional confirmation factors such as candle behavior, momentum conditions, volatility, volume, and trend regime before generating a signal.

Signals are intended to highlight potential mean reversion conditions and should be evaluated alongside the trader's own market analysis and risk management process.

[b]Non-Repainting[/b]

This indicator uses confirmed bar logic and higher-timeframe requests with lookahead disabled. Signals are generated using closed-bar information and do not intentionally repaint historical signals.

[b]Notes[/b]

Mean reversion techniques may behave differently across various market conditions. Strong directional trends, high-impact news events, and volatility expansions can influence market behavior and should always be considered when interpreting indicator outputs.

This tool is designed for market analysis and educational purposes only and does not constitute financial advice.

## Source Code

````pine
//====================================================
// Elaris Mean Reversion Pro
// Non-repainting confirmed-bar mean reversion system
// © ElarisGroup
//====================================================


//@version=6
indicator("Elaris Mean Reversion Pro", shorttitle="Elaris MR Pro", overlay=true, max_labels_count=300, max_lines_count=100, max_boxes_count=100)


//====================================================
// Inputs
//====================================================
groupCore = "01. Core Mean Reversion"
src = input.source(close, "Source", group=groupCore)
basisType = input.string("EMA", "Mean Type", options=["SMA", "EMA", "RMA", "WMA", "VWMA", "HMA"], group=groupCore)
basisLen = input.int(50, "Mean Length", minval=5, group=groupCore)
devLen = input.int(50, "Deviation Length", minval=5, group=groupCore)
bandMode = input.string("Z-Score", "Band Mode", options=["Z-Score", "ATR", "Hybrid"], group=groupCore)
zMult = input.float(2.0, "Z-Score Band Multiplier", minval=0.2, step=0.1, group=groupCore)
atrLen = input.int(14, "ATR Length", minval=1, group=groupCore)
atrMult = input.float(2.0, "ATR Band Multiplier", minval=0.2, step=0.1, group=groupCore)

groupSignal = "02. Signal Logic"
signalMode = input.string("Reclaim Mean Direction", "Signal Style", options=["Touch Extreme", "Reclaim Mean Direction", "Candle Rejection"], group=groupSignal)
confirmOnClose = input.bool(true, "Confirm Signals On Bar Close", group=groupSignal)
minBarsBetween = input.int(8, "Minimum Bars Between Signals", minval=0, group=groupSignal)
extremeLookback = input.int(3, "Extreme Touch Lookback", minval=1, group=groupSignal)
useWickReject = input.bool(true, "Require Wick Rejection", group=groupSignal)
wickRatio = input.float(1.2, "Minimum Wick / Body Ratio", minval=0.1, step=0.1, group=groupSignal)
maxOppWickPct = input.float(45.0, "Max Opposite Wick % Of Range", minval=0, maxval=100, group=groupSignal)

groupOsc = "03. Oscillator Filters"
useRsi = input.bool(true, "Use RSI Filter", group=groupOsc)
rsiLen = input.int(14, "RSI Length", minval=2, group=groupOsc)
rsiOS = input.float(35, "RSI Oversold", minval=1, maxval=50, group=groupOsc)
rsiOB = input.float(65, "RSI Overbought", minval=50, maxval=99, group=groupOsc)
useMfi = input.bool(false, "Use MFI Filter", group=groupOsc)
mfiLen = input.int(14, "MFI Length", minval=2, group=groupOsc)
mfiOS = input.float(25, "MFI Oversold", minval=1, maxval=50, group=groupOsc)
mfiOB = input.float(75, "MFI Overbought", minval=50, maxval=99, group=groupOsc)

groupRegime = "04. Market Regime Filters"
useTrendFilter = input.bool(true, "Avoid Strong Trend Conditions", group=groupRegime)
adxLen = input.int(14, "ADX Length", minval=2, group=groupRegime)
maxAdx = input.float(28, "Max ADX For Reversion", minval=5, step=0.5, group=groupRegime)
useEmaRegime = input.bool(false, "Use EMA Regime Filter", group=groupRegime)
regimeEmaLen = input.int(200, "Regime EMA Length", minval=20, group=groupRegime)
allowCounterTrend = input.bool(true, "Allow Counter-Trend Reversions", group=groupRegime)

groupVol = "05. Volume & Volatility Filters"
useVolume = input.bool(false, "Use Volume Confirmation", group=groupVol)
volLen = input.int(20, "Volume MA Length", minval=1, group=groupVol)
volMult = input.float(1.1, "Volume Multiplier", minval=0.1, step=0.1, group=groupVol)
useAtrExpansionBlock = input.bool(false, "Block Extreme Volatility Expansion", group=groupVol)
atrMaLen = input.int(50, "ATR MA Length", minval=5, group=groupVol)
maxAtrExpansion = input.float(1.8, "Max ATR / ATR MA", minval=0.5, step=0.1, group=groupVol)

groupHTF = "06. Higher Timeframe Confirmation"
useHtf = input.bool(false, "Use HTF Mean Filter", group=groupHTF)
htf = input.timeframe("240", "Higher Timeframe", group=groupHTF)
htfLen = input.int(50, "HTF Mean Length", minval=5, group=groupHTF)
htfMode = input.string("Bias Only", "HTF Mode", options=["Bias Only", "Same Side Only"], group=groupHTF)

groupVisual = "07. Visuals"
showBasis = input.bool(true, "Show Mean", group=groupVisual)
showBands = input.bool(true, "Show Bands", group=groupVisual)
showZones = input.bool(true, "Fill Extreme Zones", group=groupVisual)
showLabels = input.bool(true, "Show Signal Labels", group=groupVisual)
showBarColor = input.bool(true, "Color Signal Bars", group=groupVisual)
showDashboard = input.bool(true, "Show Dashboard", group=groupVisual)
theme = input.string("Dark", "Dashboard Theme", options=["Dark", "Light"], group=groupVisual)

groupRisk = "08. Projection Levels"
showTargets = input.bool(true, "Show Mean / Extension Targets", group=groupRisk)
targetMode = input.string("Mean", "Primary Target", options=["Mean", "Mid Band", "Opposite Band"], group=groupRisk)
slMode = input.string("ATR", "Stop Reference", options=["ATR", "Band"], group=groupRisk)
slAtrMult = input.float(1.2, "SL ATR Multiplier", minval=0.1, step=0.1, group=groupRisk)

//====================================================
// Helper Functions
//====================================================
f_ma(_src, _len, _type) =>
    switch _type
        "SMA" => ta.sma(_src, _len)
        "EMA" => ta.ema(_src, _len)
        "RMA" => ta.rma(_src, _len)
        "WMA" => ta.wma(_src, _len)
        "VWMA" => ta.vwma(_src, _len)
        "HMA" => ta.hma(_src, _len)

f_clamp(_value, _min, _max) =>
    math.max(_min, math.min(_value, _max))

//====================================================
// Core Calculations
//====================================================
basis = f_ma(src, basisLen, basisType)
dev = ta.stdev(src, devLen)
atr = ta.atr(atrLen)

zUpper = basis + dev * zMult
zLower = basis - dev * zMult
atrUpper = basis + atr * atrMult
atrLower = basis - atr * atrMult

upper = bandMode == "Z-Score" ? zUpper : bandMode == "ATR" ? atrUpper : math.avg(zUpper, atrUpper)
lower = bandMode == "Z-Score" ? zLower : bandMode == "ATR" ? atrLower : math.avg(zLower, atrLower)
midUpper = math.avg(basis, upper)
midLower = math.avg(basis, lower)

zScore = dev != 0 ? (src - basis) / dev : 0.0
distancePct = basis != 0 ? ((close - basis) / basis) * 100.0 : 0.0

//====================================================
// Candle Anatomy
//====================================================
barRange = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
safeBody = math.max(body, syminfo.mintick)

bullReject = lowerWick / safeBody >= wickRatio and upperWick / barRange * 100 <= maxOppWickPct
bearReject = upperWick / safeBody >= wickRatio and lowerWick / barRange * 100 <= maxOppWickPct

//====================================================
// Filters
//====================================================
rsi = ta.rsi(src, rsiLen)
mfi = ta.mfi(hlc3, mfiLen)

[_, _, adx] = ta.dmi(adxLen, adxLen)
regimeOk = not useTrendFilter or adx <= maxAdx

regimeEma = ta.ema(close, regimeEmaLen)
bullRegime = close >= regimeEma
bearRegime = close <= regimeEma

emaRegimeLongOk = not useEmaRegime or allowCounterTrend or bullRegime
emaRegimeShortOk = not useEmaRegime or allowCounterTrend or bearRegime

volumeMa = ta.sma(volume, volLen)
volumeOk = not useVolume or volume > volumeMa * volMult

atrMa = ta.sma(atr, atrMaLen)
atrExpansion = atrMa != 0 ? atr / atrMa : 1.0
volatilityOk = not useAtrExpansionBlock or atrExpansion <= maxAtrExpansion

rsiLongOk = not useRsi or rsi <= rsiOS
rsiShortOk = not useRsi or rsi >= rsiOB
mfiLongOk = not useMfi or mfi <= mfiOS
mfiShortOk = not useMfi or mfi >= mfiOB

//====================================================
// Higher Timeframe Filter
//====================================================
htfClose = request.security(syminfo.tickerid, htf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfMean = request.security(syminfo.tickerid, htf, ta.ema(close, htfLen), barmerge.gaps_off, barmerge.lookahead_off)

htfBull = htfClose >= htfMean
htfBear = htfClose <= htfMean

htfLongOk = not useHtf or htfMode == "Bias Only" or htfBull
htfShortOk = not useHtf or htfMode == "Bias Only" or htfBear

//====================================================
// Mean Reversion Signal Logic
//====================================================
touchedLower = ta.lowest(low, extremeLookback) <= lower
touchedUpper = ta.highest(high, extremeLookback) >= upper

touchLong = low <= lower
touchShort = high >= upper

reclaimLong = touchedLower and close > lower and close > open
reclaimShort = touchedUpper and close < upper and close < open

candleLong = touchedLower and bullReject and close > open
candleShort = touchedUpper and bearReject and close < open

rawLong =
     signalMode == "Touch Extreme" ? touchLong :
     signalMode == "Reclaim Mean Direction" ? reclaimLong :
     candleLong

rawShort =
     signalMode == "Touch Extreme" ? touchShort :
     signalMode == "Reclaim Mean Direction" ? reclaimShort :
     candleShort

wickLongOk = not useWickReject or bullReject or signalMode != "Candle Rejection"
wickShortOk = not useWickReject or bearReject or signalMode != "Candle Rejection"

confirmed = not confirmOnClose or barstate.isconfirmed

var int lastLongBar = na
var int lastShortBar = na

spacingLongOk = na(lastLongBar) or bar_index - lastLongBar >= minBarsBetween
spacingShortOk = na(lastShortBar) or bar_index - lastShortBar >= minBarsBetween

longSignal =
     confirmed and rawLong and wickLongOk and spacingLongOk and
     regimeOk and emaRegimeLongOk and volumeOk and volatilityOk and
     rsiLongOk and mfiLongOk and htfLongOk

shortSignal =
     confirmed and rawShort and wickShortOk and spacingShortOk and
     regimeOk and emaRegimeShortOk and volumeOk and volatilityOk and
     rsiShortOk and mfiShortOk and htfShortOk

if longSignal
    lastLongBar := bar_index

if shortSignal
    lastShortBar := bar_index

//====================================================
// Signal Quality Score
//====================================================
zStrengthLong = f_clamp(math.abs(zScore) / zMult * 25, 0, 25)
oscScoreLong = ((useRsi and rsi <= rsiOS ? 15 : not useRsi ? 10 : 0) + (useMfi and mfi <= mfiOS ? 10 : not useMfi ? 5 : 0))
oscScoreShort = ((useRsi and rsi >= rsiOB ? 15 : not useRsi ? 10 : 0) + (useMfi and mfi >= mfiOB ? 10 : not useMfi ? 5 : 0))
wickScoreLong = bullReject ? 20 : 8
wickScoreShort = bearReject ? 20 : 8
regimeScore = regimeOk ? 20 : 0
volScore = volumeOk and volatilityOk ? 10 : 0

longScore = f_clamp(zStrengthLong + oscScoreLong + wickScoreLong + regimeScore + volScore, 0, 100)
shortScore = f_clamp(zStrengthLong + oscScoreShort + wickScoreShort + regimeScore + volScore, 0, 100)

//====================================================
// Risk / Target Projections
//====================================================
longTarget = targetMode == "Mean" ? basis : targetMode == "Mid Band" ? midLower : upper
shortTarget = targetMode == "Mean" ? basis : targetMode == "Mid Band" ? midUpper : lower

longSL = slMode == "ATR" ? low - atr * slAtrMult : lower - atr * 0.25
shortSL = slMode == "ATR" ? high + atr * slAtrMult : upper + atr * 0.25

plot(showTargets and longSignal ? longTarget : na, "Long Target", color=color.new(color.lime, 0), style=plot.style_circles, linewidth=2)
plot(showTargets and shortSignal ? shortTarget : na, "Short Target", color=color.new(color.red, 0), style=plot.style_circles, linewidth=2)
plot(showTargets and longSignal ? longSL : na, "Long SL", color=color.new(color.red, 0), style=plot.style_cross, linewidth=2)
plot(showTargets and shortSignal ? shortSL : na, "Short SL", color=color.new(color.red, 0), style=plot.style_cross, linewidth=2)

//====================================================
// Visuals
//====================================================
basisPlot = plot(showBasis ? basis : na, "Mean", color=color.new(color.white, 0), linewidth=2)
upperPlot = plot(showBands ? upper : na, "Upper Extreme Band", color=color.new(color.red, 0), linewidth=2)
lowerPlot = plot(showBands ? lower : na, "Lower Extreme Band", color=color.new(color.lime, 0), linewidth=2)
midUpperPlot = plot(showBands ? midUpper : na, "Upper Mid Band", color=color.new(color.red, 70))
midLowerPlot = plot(showBands ? midLower : na, "Lower Mid Band", color=color.new(color.lime, 70))

fill(upperPlot, midUpperPlot, color=showZones ? color.new(color.red, 88) : na, title="Upper Reversion Zone")
fill(lowerPlot, midLowerPlot, color=showZones ? color.new(color.lime, 88) : na, title="Lower Reversion Zone")

barcolor(showBarColor and longSignal ? color.lime : showBarColor and shortSignal ? color.red : na)

plotshape(longSignal, "Long Mean Reversion", shape.triangleup, location.belowbar, color=color.lime, size=size.small, text="MR+")
plotshape(shortSignal, "Short Mean Reversion", shape.triangledown, location.abovebar, color=color.red, size=size.small, text="MR-")

if showLabels and longSignal
    label.new(bar_index, low, "LONG MR\nScore: " + str.tostring(math.round(longScore)) + "\nZ: " + str.tostring(zScore, "#.##"), style=label.style_label_up, textcolor=color.white, color=color.new(color.green, 0))

if showLabels and shortSignal
    label.new(bar_index, high, "SHORT MR\nScore: " + str.tostring(math.round(shortScore)) + "\nZ: " + str.tostring(zScore, "#.##"), style=label.style_label_down, textcolor=color.white, color=color.new(color.red, 0))

//====================================================
// Dashboard
//====================================================
dashBg = theme == "Dark" ? color.new(color.black, 0) : color.new(color.white, 0)
dashText = theme == "Dark" ? color.white : color.black
dashMuted = theme == "Dark" ? color.new(color.white, 45) : color.new(color.black, 45)

var table dash = table.new(position.top_right, 2, 8, border_width=1)

if showDashboard and barstate.islast
    state = close > upper ? "Overbought" : close < lower ? "Oversold" : "Neutral"
    stateColor = close > upper ? color.red : close < lower ? color.lime : color.gray
    regimeText = regimeOk ? "Reversion OK" : "Trend Too Strong"
    htfText = not useHtf ? "Disabled" : htfBull ? "Bullish" : "Bearish"

    table.cell(dash, 0, 0, "Elaris MR Pro", text_color=dashText, bgcolor=dashBg)
    table.cell(dash, 1, 0, "Live", text_color=color.lime, bgcolor=dashBg)

    table.cell(dash, 0, 1, "State", text_color=dashMuted, bgcolor=dashBg)
    table.cell(dash, 1, 1, state, text_color=stateColor, bgcolor=dashBg)

    table.cell(dash, 0, 2, "Z-Score", text_color=dashMuted, bgcolor=dashBg)
    table.cell(dash, 1, 2, str.tostring(zScore, "#.##"), text_color=dashText, bgcolor=dashBg)

    table.cell(dash, 0, 3, "Distance %", text_color=dashMuted, bgcolor=dashBg)
    table.cell(dash, 1, 3, str.tostring(distancePct, "#.##") + "%", text_color=dashText, bgcolor=dashBg)

    table.cell(dash, 0, 4, "RSI / MFI", text_color=dashMuted, bgcolor=dashBg)
    table.cell(dash, 1, 4, str.tostring(rsi, "#") + " / " + str.tostring(mfi, "#"), text_color=dashText, bgcolor=dashBg)

    table.cell(dash, 0, 5, "ADX Regime", text_color=dashMuted, bgcolor=dashBg)
    table.cell(dash, 1, 5, regimeText, text_color=regimeOk ? color.lime : color.red, bgcolor=dashBg)

    table.cell(dash, 0, 6, "HTF Bias", text_color=dashMuted, bgcolor=dashBg)
    table.cell(dash, 1, 6, htfText, text_color=dashText, bgcolor=dashBg)

    table.cell(dash, 0, 7, "Last Signal", text_color=dashMuted, bgcolor=dashBg)
    table.cell(dash, 1, 7, longSignal ? "Long MR" : shortSignal ? "Short MR" : "None", text_color=longSignal ? color.lime : shortSignal ? color.red : dashText, bgcolor=dashBg)

//====================================================
// Alerts
//====================================================
alertcondition(longSignal, "Elaris MR Pro Long", "Long mean reversion signal detected on {{ticker}} at {{close}}")
alertcondition(shortSignal, "Elaris MR Pro Short", "Short mean reversion signal detected on {{ticker}} at {{close}}")
alertcondition(close > upper, "Upper Extreme Zone", "{{ticker}} entered upper mean reversion extreme zone")
alertcondition(close < lower, "Lower Extreme Zone", "{{ticker}} entered lower mean reversion extreme zone")
````
