# Liquidity Trap Absorption Matrix [ZOM]

- url: https://www.tradingview.com/script/g4OoB0vY-Liquidity-Trap-Absorption-Matrix-ZOM/
- type: indicator
- pine_id: PUB;517f4a9b793a431597dbd757fe977a9f
- version: 1.0

## Description

Liquidity Trap Absorption Matrix [ZOM]

The Liquidity Trap Absorption Matrix is an overlay framework built to visualize liquidity sweeps, wick rejection, absorption zones, VWAP displacement, and estimated delta pressure using standard OHLCV data.

The core idea is simple: when price raids a prior swing high/low or opening-range level, then closes back inside with meaningful wick rejection and elevated relative volume, the move may represent a failed breakout, stop run, or liquidity trap rather than clean continuation.

This script attempts to map those moments visually so the trader can evaluate where liquidity was taken, where absorption appeared, and how price behaves after the reclaim/rejection.

Core features:
- Confirmed swing-high and swing-low liquidity levels
- Opening-range high/low context for futures-style intraday review
- Bullish and bearish trap detection using sweep + reclaim/rejection logic
- Wick absorption scoring
- Relative volume filter
- VWAP displacement cloud with adaptive deviation bands
- Estimated delta-pressure score from candle structure and volume
- 0-100 setup scoring model
- Absorption zone boxes extended forward from the sweep area
- Compact BUY TRAP / SELL TRAP labels with scores
- Optional TP1 / TP2 / SL projection map from the latest signal
- Small ZOM Trap Matrix dashboard
- Multiple visual templates, including Rogue, Emerald, Gold Rush, Arctic, and Mono

How to read it:
A BUY TRAP appears when price sweeps below a tracked liquidity level and reclaims back above it with enough rejection, volume, and contextual confirmation.

A SELL TRAP appears when price sweeps above a tracked liquidity level and rejects back below it under similar conditions.

The absorption zone shows the area where the sweep and reclaim/rejection occurred. The VWAP cloud gives broader mean/displacement context. The dashboard summarizes regime, trap bias, estimated delta pressure, relative volume, active zones, and the latest score.

This works best on liquid instruments where intraday liquidity sweeps are common, especially index futures such as NQ, MNQ, ES, and MES. The default settings were tuned to show meaningful structure on 5m and 15m futures charts without becoming overly noisy.

Important note:
TradingView Pine scripts do not have access to true order book, time-and-sales, dealer positioning, or full market depth. Delta pressure, absorption, and liquidity behavior here are modeled from OHLCV-based proxies. Treat the output as a contextual decision-support framework, not a predictive system or financial advice.

## Source Code

````pine
//@version=6
indicator("Liquidity Trap Absorption Matrix [ZOM]", shorttitle="Trap Matrix [ZOM]", overlay=true, max_lines_count=120, max_boxes_count=80, max_labels_count=80)

// Liquidity Trap Absorption Matrix [ZOM]
// Draft candidate for manual TradingView review before publication.

// Inputs
mode = input.string("Normal", "Signal Strictness", options=["Aggressive", "Normal", "Strict"], group="Signal Engine")
pivotLen = input.int(4, "Pivot Confirmation Bars", minval=2, maxval=20, group="Signal Engine")
cooldownBars = input.int(12, "Signal Cooldown Bars", minval=1, maxval=100, group="Signal Engine")
minWickPct = input.float(0.38, "Minimum Wick Share", minval=0.10, maxval=0.90, step=0.01, group="Signal Engine")
relVolMin = input.float(1.20, "Minimum Relative Volume", minval=0.10, maxval=5.00, step=0.05, group="Signal Engine")

useOpeningRange = input.bool(true, "Track Opening Range", group="Session Context")
openingSession = input.session("0930-1030", "Opening Range Session", group="Session Context")
showOpeningRange = input.bool(true, "Show Opening Range", group="Session Context")

useVwapContext = input.bool(true, "Require VWAP Displacement Context", group="VWAP / Delta")
devLen = input.int(80, "VWAP Deviation Length", minval=20, maxval=300, group="VWAP / Delta")
devMult = input.float(1.25, "VWAP Deviation Multiplier", minval=0.25, maxval=4.00, step=0.05, group="VWAP / Delta")
deltaLen = input.int(12, "Delta Pressure Smoothing", minval=2, maxval=60, group="VWAP / Delta")
volLen = input.int(30, "Relative Volume Length", minval=5, maxval=200, group="VWAP / Delta")
atrLen = input.int(14, "ATR Length", minval=5, maxval=100, group="Risk Map")
rr1 = input.float(1.0, "TP1 R Multiple", minval=0.25, maxval=5.0, step=0.25, group="Risk Map")
rr2 = input.float(2.0, "TP2 R Multiple", minval=0.50, maxval=8.0, step=0.25, group="Risk Map")
slBuffer = input.float(0.20, "Stop ATR Buffer", minval=0.00, maxval=2.00, step=0.05, group="Risk Map")

theme = input.string("Rogue", "Aesthetic Template", options=["Rogue", "Emerald", "Gold Rush", "Arctic", "Mono"], group="Visuals")
showZones = input.bool(true, "Absorption Zones", group="Visuals")
showLabels = input.bool(true, "Signal Labels", group="Visuals")
showVwapCloud = input.bool(true, "VWAP Cloud", group="Visuals")
showProjections = input.bool(true, "Latest TP / SL Projection", group="Visuals")
showDashboard = input.bool(true, "Dashboard", group="Visuals")
showLevels = input.bool(true, "Liquidity Level Traces", group="Visuals")
zoneBars = input.int(48, "Zone Extension Bars", minval=5, maxval=300, group="Visuals")
maxTrackedLevels = input.int(18, "Max Level Traces", minval=4, maxval=50, group="Visuals")
maxZones = input.int(18, "Max Zones", minval=3, maxval=50, group="Visuals")

// Theme
bullColor = theme == "Emerald" ? color.rgb(0, 180, 130) : theme == "Gold Rush" ? color.rgb(238, 184, 72) : theme == "Arctic" ? color.rgb(90, 190, 255) : theme == "Mono" ? color.rgb(210, 210, 210) : color.rgb(33, 190, 150)
bearColor = theme == "Emerald" ? color.rgb(255, 91, 117) : theme == "Gold Rush" ? color.rgb(190, 88, 44) : theme == "Arctic" ? color.rgb(255, 122, 172) : theme == "Mono" ? color.rgb(130, 130, 130) : color.rgb(225, 75, 102)
accentColor = theme == "Emerald" ? color.rgb(42, 228, 174) : theme == "Gold Rush" ? color.rgb(255, 210, 105) : theme == "Arctic" ? color.rgb(150, 220, 255) : theme == "Mono" ? color.rgb(170, 170, 170) : color.rgb(96, 165, 250)
mutedColor = color.rgb(125, 132, 150)
panelBg = color.new(color.rgb(18, 22, 31), 12)

// Core calculations
atr = ta.atr(atrLen)
volAvg = ta.sma(volume, volLen)
relVol = volAvg > 0 ? volume / volAvg : 0.0
barRange = math.max(high - low, syminfo.mintick)
bodyTop = math.max(open, close)
bodyBot = math.min(open, close)
upperWick = high - bodyTop
lowerWick = bodyBot - low
upperWickPct = upperWick / barRange
lowerWickPct = lowerWick / barRange

vwap = ta.vwap(hlc3)
vwapDev = ta.stdev(close - vwap, devLen)
upperBand = vwap + vwapDev * devMult
lowerBand = vwap - vwapDev * devMult

closeLocation = ((close - low) - (high - close)) / barRange
directionalDelta = volume * closeLocation
deltaPressure = ta.ema(directionalDelta / math.max(volAvg, 1), deltaLen) * 100
deltaFlipBull = deltaPressure > deltaPressure[1] and deltaPressure > -15
deltaFlipBear = deltaPressure < deltaPressure[1] and deltaPressure < 15

emaFast = ta.ema(close, 21)
emaSlow = ta.ema(close, 89)
trendUp = emaFast > emaSlow
trendDown = emaFast < emaSlow
regime = trendUp ? "UPDRIFT" : trendDown ? "DOWNDRIFT" : "BALANCE"

// Opening range
inOpening = not na(time(timeframe.period, openingSession))
openingStart = inOpening and not inOpening[1]
openingEnd = not inOpening and inOpening[1]
var float orHigh = na
var float orLow = na
var bool orReady = false
if openingStart
    orHigh := high
    orLow := low
    orReady := false
else if inOpening
    orHigh := math.max(nz(orHigh, high), high)
    orLow := math.min(nz(orLow, low), low)
else if openingEnd
    orReady := true

plot(showOpeningRange and useOpeningRange and orReady ? orHigh : na, "OR High", color=color.new(bearColor, 45), linewidth=1, style=plot.style_linebr)
plot(showOpeningRange and useOpeningRange and orReady ? orLow : na, "OR Low", color=color.new(bullColor, 45), linewidth=1, style=plot.style_linebr)

// Liquidity pivots
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)
var float lastPivotHigh = na
var float lastPivotLow = na
var line[] levelLines = array.new_line()
var box[] zoneBoxes = array.new_box()

if not na(ph)
    lastPivotHigh := ph
    if showLevels
        newHighLine = line.new(bar_index - pivotLen, ph, bar_index + zoneBars, ph, color=color.new(bearColor, 72), style=line.style_dashed, width=1)
        array.push(levelLines, newHighLine)
if not na(pl)
    lastPivotLow := pl
    if showLevels
        newLowLine = line.new(bar_index - pivotLen, pl, bar_index + zoneBars, pl, color=color.new(bullColor, 72), style=line.style_dashed, width=1)
        array.push(levelLines, newLowLine)
if array.size(levelLines) > maxTrackedLevels
    line.delete(array.shift(levelLines))

// Trap detection
pivotBullSweep = not na(lastPivotLow) and low < lastPivotLow and close > lastPivotLow
pivotBearSweep = not na(lastPivotHigh) and high > lastPivotHigh and close < lastPivotHigh
orBullSweep = useOpeningRange and orReady and not na(orLow) and low < orLow and close > orLow
orBearSweep = useOpeningRange and orReady and not na(orHigh) and high > orHigh and close < orHigh

bullLevel = orBullSweep ? orLow : lastPivotLow
bearLevel = orBearSweep ? orHigh : lastPivotHigh
bullVwapOk = not useVwapContext or low <= lowerBand or close > lowerBand or close < vwap
bearVwapOk = not useVwapContext or high >= upperBand or close < upperBand or close > vwap
rawBullTrap = (pivotBullSweep or orBullSweep) and lowerWickPct >= minWickPct and relVol >= relVolMin and bullVwapOk
rawBearTrap = (pivotBearSweep or orBearSweep) and upperWickPct >= minWickPct and relVol >= relVolMin and bearVwapOk

threshold = mode == "Strict" ? 75.0 : mode == "Aggressive" ? 55.0 : 64.0

f_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

bullSweepDepth = not na(bullLevel) ? f_clamp((bullLevel - low) / math.max(atr, syminfo.mintick), 0, 1.5) / 1.5 : 0.0
bearSweepDepth = not na(bearLevel) ? f_clamp((high - bearLevel) / math.max(atr, syminfo.mintick), 0, 1.5) / 1.5 : 0.0
volScore = f_clamp((relVol - 1.0) / 1.75, 0, 1)
bullVwapScore = close < vwap ? f_clamp((vwap - low) / math.max(vwapDev, syminfo.mintick), 0, 1) : 0.35
bearVwapScore = close > vwap ? f_clamp((high - vwap) / math.max(vwapDev, syminfo.mintick), 0, 1) : 0.35
bullTrendScore = trendUp ? 0.75 : trendDown ? 0.35 : 0.55
bearTrendScore = trendDown ? 0.75 : trendUp ? 0.35 : 0.55

bullScore = bullSweepDepth * 22 + lowerWickPct * 24 + volScore * 18 + bullVwapScore * 16 + (deltaFlipBull ? 12 : 0) + bullTrendScore * 8
bearScore = bearSweepDepth * 22 + upperWickPct * 24 + volScore * 18 + bearVwapScore * 16 + (deltaFlipBear ? 12 : 0) + bearTrendScore * 8

var int lastSignalBar = na
cooldownOk = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars
bullTrap = rawBullTrap and bullScore >= threshold and cooldownOk
bearTrap = rawBearTrap and bearScore >= threshold and cooldownOk

if bullTrap or bearTrap
    lastSignalBar := bar_index

// Visuals
plotVwap = plot(showVwapCloud ? vwap : na, "VWAP", color=color.new(accentColor, 0), linewidth=2)
plotUpper = plot(showVwapCloud ? upperBand : na, "VWAP Upper Exhaustion", color=color.new(bearColor, 70), linewidth=1)
plotLower = plot(showVwapCloud ? lowerBand : na, "VWAP Lower Exhaustion", color=color.new(bullColor, 70), linewidth=1)
fill(plotUpper, plotVwap, color=showVwapCloud ? color.new(bearColor, 90) : na, title="Upper VWAP Cloud")
fill(plotVwap, plotLower, color=showVwapCloud ? color.new(bullColor, 90) : na, title="Lower VWAP Cloud")

barcolor(bullTrap ? color.new(bullColor, 5) : bearTrap ? color.new(bearColor, 5) : na)

if bullTrap and showZones and not na(bullLevel)
    z = box.new(bar_index, bullLevel, bar_index + zoneBars, low, bgcolor=color.new(bullColor, 84), border_color=color.new(bullColor, 35), text="ABSORPTION", text_color=color.new(bullColor, 0), text_size=size.tiny)
    array.push(zoneBoxes, z)
if bearTrap and showZones and not na(bearLevel)
    z = box.new(bar_index, high, bar_index + zoneBars, bearLevel, bgcolor=color.new(bearColor, 84), border_color=color.new(bearColor, 35), text="ABSORPTION", text_color=color.new(bearColor, 0), text_size=size.tiny)
    array.push(zoneBoxes, z)
if array.size(zoneBoxes) > maxZones
    box.delete(array.shift(zoneBoxes))

if bullTrap and showLabels
    label.new(bar_index, low, "BUY TRAP\n" + str.tostring(bullScore, "#"), style=label.style_label_up, color=color.new(bullColor, 0), textcolor=color.white, size=size.small)
if bearTrap and showLabels
    label.new(bar_index, high, "SELL TRAP\n" + str.tostring(bearScore, "#"), style=label.style_label_down, color=color.new(bearColor, 0), textcolor=color.white, size=size.small)

// Latest risk projection
var line entryLine = na
var line stopLine = na
var line tp1Line = na
var line tp2Line = na

if showProjections and bullTrap
    if not na(entryLine)
        line.delete(entryLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    entry = close
    stop = low - atr * slBuffer
    risk = math.max(entry - stop, syminfo.mintick)
    entryLine := line.new(bar_index, entry, bar_index + zoneBars, entry, color=color.new(accentColor, 0), width=2)
    stopLine := line.new(bar_index, stop, bar_index + zoneBars, stop, color=color.new(bearColor, 0), width=2)
    tp1Line := line.new(bar_index, entry + risk * rr1, bar_index + zoneBars, entry + risk * rr1, color=color.new(bullColor, 0), width=1, style=line.style_dashed)
    tp2Line := line.new(bar_index, entry + risk * rr2, bar_index + zoneBars, entry + risk * rr2, color=color.new(bullColor, 15), width=1, style=line.style_dashed)

if showProjections and bearTrap
    if not na(entryLine)
        line.delete(entryLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    entry = close
    stop = high + atr * slBuffer
    risk = math.max(stop - entry, syminfo.mintick)
    entryLine := line.new(bar_index, entry, bar_index + zoneBars, entry, color=color.new(accentColor, 0), width=2)
    stopLine := line.new(bar_index, stop, bar_index + zoneBars, stop, color=color.new(bearColor, 0), width=2)
    tp1Line := line.new(bar_index, entry - risk * rr1, bar_index + zoneBars, entry - risk * rr1, color=color.new(bullColor, 0), width=1, style=line.style_dashed)
    tp2Line := line.new(bar_index, entry - risk * rr2, bar_index + zoneBars, entry - risk * rr2, color=color.new(bullColor, 15), width=1, style=line.style_dashed)

// Dashboard
var table dash = table.new(position.top_right, 2, 7, bgcolor=panelBg, border_color=color.new(color.white, 82), border_width=1)
latestBias = bullTrap ? "BULL TRAP" : bearTrap ? "BEAR TRAP" : deltaPressure > 20 ? "BULL PRESS" : deltaPressure < -20 ? "BEAR PRESS" : "NEUTRAL"
latestScore = bullTrap ? bullScore : bearTrap ? bearScore : math.max(bullScore, bearScore)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "ZOM Trap Matrix", text_color=color.white, bgcolor=color.new(accentColor, 75), text_size=size.small)
    table.cell(dash, 1, 0, mode, text_color=color.white, bgcolor=color.new(accentColor, 75), text_size=size.small)
    table.cell(dash, 0, 1, "Regime", text_color=color.new(color.white, 18), text_size=size.tiny)
    table.cell(dash, 1, 1, regime, text_color=trendUp ? bullColor : trendDown ? bearColor : mutedColor, text_size=size.tiny)
    table.cell(dash, 0, 2, "Trap Bias", text_color=color.new(color.white, 18), text_size=size.tiny)
    table.cell(dash, 1, 2, latestBias, text_color=latestBias == "BULL TRAP" or latestBias == "BULL PRESS" ? bullColor : latestBias == "BEAR TRAP" or latestBias == "BEAR PRESS" ? bearColor : mutedColor, text_size=size.tiny)
    table.cell(dash, 0, 3, "Delta", text_color=color.new(color.white, 18), text_size=size.tiny)
    table.cell(dash, 1, 3, str.tostring(deltaPressure, "#.0"), text_color=deltaPressure >= 0 ? bullColor : bearColor, text_size=size.tiny)
    table.cell(dash, 0, 4, "Rel Vol", text_color=color.new(color.white, 18), text_size=size.tiny)
    table.cell(dash, 1, 4, str.tostring(relVol, "#.00") + "x", text_color=relVol >= relVolMin ? accentColor : mutedColor, text_size=size.tiny)
    table.cell(dash, 0, 5, "Zones", text_color=color.new(color.white, 18), text_size=size.tiny)
    table.cell(dash, 1, 5, str.tostring(array.size(zoneBoxes)), text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 6, "Score", text_color=color.new(color.white, 18), text_size=size.tiny)
    table.cell(dash, 1, 6, str.tostring(latestScore, "#"), text_color=latestScore >= threshold ? accentColor : mutedColor, text_size=size.tiny)

// Alerts
alertcondition(bullTrap, "Bullish Liquidity Trap [ZOM]", "Bullish liquidity trap absorption signal on {{ticker}} {{interval}}.")
alertcondition(bearTrap, "Bearish Liquidity Trap [ZOM]", "Bearish liquidity trap absorption signal on {{ticker}} {{interval}}.")
alertcondition((bullTrap and bullScore >= 80) or (bearTrap and bearScore >= 80), "High-Score Trap [ZOM]", "High-score liquidity trap absorption signal on {{ticker}} {{interval}}.")
````
