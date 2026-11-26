# Imbalance Repricing Engine [ZOM]

- url: https://www.tradingview.com/script/DhJa9F8G-Imbalance-Repricing-Engine-ZOM/
- type: indicator
- pine_id: PUB;82bec1416a8d4425b367106b8a5489d5
- version: 1.0

## Description

Imbalance Repricing Engine [ZOM]

The Imbalance Repricing Engine is an overlay framework designed to map displacement imbalances, fair-value-gap style zones, repricing reactions, mitigation behavior, and failed imbalance structures using standard OHLCV data.

The idea behind the tool is that strong displacement often leaves inefficient price areas behind. When price later returns to those zones, the reaction can provide useful context: continuation, mitigation, rejection, or failure.

This script attempts to visualize that process directly on the chart.

Core features:
- Bullish and bearish imbalance zone detection
- Displacement filtering using ATR expansion, candle body share, and relative volume
- Active zone tracking with forward projection
- Midpoint traces for each imbalance
- Zone state changes for active, mitigated, and failed areas
- VWAP cloud for premium/discount context
- Estimated delta-pressure score derived from OHLCV structure and volume
- LONG REPRICE and SHORT REPRICE labels with setup scores
- Optional failure labeling
- Latest projection lines for entry, invalidation, target 1, and target 2
- Compact ZOM dashboard with active zone count, last event, delta pressure, relative volume, VWAP state, and score
- Multiple visual templates: Rogue, Emerald, Gold Rush, Arctic, and Mono

How to read it:
Bullish imbalance zones are areas where upside displacement left a gap-like inefficiency behind. If price later revisits the zone and responds with supportive structure, the tool can mark a LONG REPRICE signal.

Bearish imbalance zones work the opposite way. If price revisits a bearish imbalance and rejects with confirming structure, the tool can mark a SHORT REPRICE signal.

Mitigated zones show areas where price has traded back into the imbalance. Failed zones show areas where price closed through the structure strongly enough to weaken the original imbalance thesis.

This tool is most useful on liquid futures and index products where displacement and repricing behavior are easy to observe. The default view was staged for ES / NQ style 15m and 5m analysis with enough structure to be visually useful without flooding the chart.

Important note:
TradingView Pine scripts do not have access to true order book, time-and-sales, or full market depth. Delta pressure, imbalance behavior, and absorption-style context here are modeled from OHLCV-based proxies. Treat this as a contextual framework, not financial advice or a predictive system.

## Source Code

````pine
//@version=6
indicator("Imbalance Repricing Engine [ZOM]", shorttitle="Repricing Engine [ZOM]", overlay=true, max_boxes_count=120, max_lines_count=120, max_labels_count=100)

// Imbalance Repricing Engine [ZOM]
// Draft candidate for manual review before publication.

// Inputs
mode = input.string("Normal", "Signal Strictness", options=["Aggressive", "Normal", "Strict"], group="Signal Engine")
atrLen = input.int(14, "ATR Length", minval=5, maxval=100, group="Signal Engine")
volLen = input.int(34, "Relative Volume Length", minval=5, maxval=200, group="Signal Engine")
deltaLen = input.int(12, "Delta Pressure Smoothing", minval=2, maxval=80, group="Signal Engine")
minBodyShare = input.float(0.58, "Displacement Body Share", minval=0.25, maxval=0.95, step=0.01, group="Signal Engine")
minAtrExpansion = input.float(0.82, "Displacement ATR Expansion", minval=0.20, maxval=3.00, step=0.05, group="Signal Engine")
minRelVol = input.float(1.10, "Minimum Relative Volume", minval=0.20, maxval=5.00, step=0.05, group="Signal Engine")
cooldownBars = input.int(10, "Signal Cooldown Bars", minval=1, maxval=100, group="Signal Engine")

useVwap = input.bool(true, "Use VWAP State In Score", group="Context")
vwapDevLen = input.int(80, "VWAP Deviation Length", minval=20, maxval=300, group="Context")
vwapDevMult = input.float(1.10, "VWAP Deviation Multiplier", minval=0.25, maxval=4.00, step=0.05, group="Context")
maxZoneAge = input.int(180, "Max Zone Age", minval=25, maxval=800, group="Context")
minZoneTicks = input.int(4, "Minimum Zone Height In Ticks", minval=1, maxval=100, group="Context")

theme = input.string("Rogue", "Aesthetic Template", options=["Rogue", "Emerald", "Gold Rush", "Arctic", "Mono"], group="Visuals")
showZones = input.bool(true, "Imbalance Zones", group="Visuals")
showMidpoints = input.bool(true, "Zone Midpoints", group="Visuals")
showLabels = input.bool(true, "Signal Labels", group="Visuals")
showFailureLabels = input.bool(false, "Failure Labels", group="Visuals")
showVwapCloud = input.bool(true, "VWAP Cloud", group="Visuals")
showProjections = input.bool(true, "Latest Projection", group="Visuals")
showDashboard = input.bool(true, "Dashboard", group="Visuals")
zoneExtend = input.int(72, "Zone Extension Bars", minval=10, maxval=400, group="Visuals")
maxZones = input.int(18, "Stored Imbalance Zones", minval=4, maxval=60, group="Visuals")

// Theme
bullColor = theme == "Emerald" ? color.rgb(0, 190, 135) : theme == "Gold Rush" ? color.rgb(238, 184, 72) : theme == "Arctic" ? color.rgb(88, 190, 255) : theme == "Mono" ? color.rgb(210, 210, 210) : color.rgb(34, 197, 165)
bearColor = theme == "Emerald" ? color.rgb(255, 90, 120) : theme == "Gold Rush" ? color.rgb(192, 84, 48) : theme == "Arctic" ? color.rgb(255, 120, 178) : theme == "Mono" ? color.rgb(130, 130, 130) : color.rgb(228, 76, 118)
accentColor = theme == "Emerald" ? color.rgb(55, 230, 175) : theme == "Gold Rush" ? color.rgb(255, 210, 105) : theme == "Arctic" ? color.rgb(166, 224, 255) : theme == "Mono" ? color.rgb(170, 170, 170) : color.rgb(96, 165, 250)
mutedColor = color.rgb(120, 128, 148)
panelBg = color.new(color.rgb(18, 22, 31), 10)

f_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

// Core metrics
atr = ta.atr(atrLen)
volAvg = ta.sma(volume, volLen)
relVol = volAvg > 0 ? volume / volAvg : 0.0
barRange = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
bodyShare = body / barRange
atrExpansion = barRange / math.max(atr, syminfo.mintick)

vwap = ta.vwap(hlc3)
vwapDev = ta.stdev(close - vwap, vwapDevLen)
vwapUpper = vwap + vwapDev * vwapDevMult
vwapLower = vwap - vwapDev * vwapDevMult

closeLocation = ((close - low) - (high - close)) / barRange
deltaPressure = ta.ema(closeLocation * volume / math.max(volAvg, 1) * 100, deltaLen)
deltaBull = deltaPressure > 5 and deltaPressure > deltaPressure[1]
deltaBear = deltaPressure < -5 and deltaPressure < deltaPressure[1]

// FVG / imbalance discovery
isBullDisplacement = close > open and bodyShare >= minBodyShare and atrExpansion >= minAtrExpansion and relVol >= minRelVol
isBearDisplacement = close < open and bodyShare >= minBodyShare and atrExpansion >= minAtrExpansion and relVol >= minRelVol
bullFvg = barstate.isconfirmed and low > high[2] and isBullDisplacement and (low - high[2]) >= syminfo.mintick * minZoneTicks
bearFvg = barstate.isconfirmed and high < low[2] and isBearDisplacement and (low[2] - high) >= syminfo.mintick * minZoneTicks

// Arrays
var box[] zoneBoxes = array.new_box()
var line[] midLines = array.new_line()
var float[] zoneTops = array.new_float()
var float[] zoneBottoms = array.new_float()
var int[] zoneDirs = array.new_int()
var int[] zoneBars = array.new_int()
var bool[] zoneFailed = array.new_bool()
var bool[] zoneMitigated = array.new_bool()

f_add_zone(_top, _bottom, _dir) =>
    zoneColor = _dir == 1 ? bullColor : bearColor
    zoneText = _dir == 1 ? "BULL IMBALANCE" : "BEAR IMBALANCE"
    b = box.new(bar_index, _top, bar_index + zoneExtend, _bottom, bgcolor=showZones ? color.new(zoneColor, 84) : na, border_color=showZones ? color.new(zoneColor, 34) : na, text=showZones ? zoneText : "", text_color=color.new(zoneColor, 0), text_size=size.tiny)
    m = line.new(bar_index, (_top + _bottom) / 2.0, bar_index + zoneExtend, (_top + _bottom) / 2.0, color=showMidpoints ? color.new(zoneColor, 45) : na, style=line.style_dashed, width=1)
    array.push(zoneBoxes, b)
    array.push(midLines, m)
    array.push(zoneTops, _top)
    array.push(zoneBottoms, _bottom)
    array.push(zoneDirs, _dir)
    array.push(zoneBars, bar_index)
    array.push(zoneFailed, false)
    array.push(zoneMitigated, false)

if bullFvg
    f_add_zone(low, high[2], 1)
if bearFvg
    f_add_zone(low[2], high, -1)

while array.size(zoneBoxes) > maxZones
    box.delete(array.shift(zoneBoxes))
    line.delete(array.shift(midLines))
    array.shift(zoneTops)
    array.shift(zoneBottoms)
    array.shift(zoneDirs)
    array.shift(zoneBars)
    array.shift(zoneFailed)
    array.shift(zoneMitigated)

threshold = mode == "Strict" ? 78.0 : mode == "Aggressive" ? 55.0 : 66.0

var int lastSignalBar = na
cooldownOk = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars
var int bestDir = 0
var int bestIndex = na
var float bestScore = 0.0
var string bestEvent = "NONE"
bestDir := 0
bestIndex := na
bestScore := 0.0
bestEvent := "NONE"

// Update and score active zones
if array.size(zoneBoxes) > 0
    for i = 0 to array.size(zoneBoxes) - 1
        top = array.get(zoneTops, i)
        bottom = array.get(zoneBottoms, i)
        dir = array.get(zoneDirs, i)
        born = array.get(zoneBars, i)
        failed = array.get(zoneFailed, i)
        mitigated = array.get(zoneMitigated, i)
        mid = (top + bottom) / 2.0
        age = bar_index - born
        freshScore = f_clamp(1.0 - age / maxZoneAge, 0.0, 1.0)
        inZone = high >= bottom and low <= top
        throughMid = dir == 1 ? low <= mid : high >= mid
        filled = dir == 1 ? low <= bottom : high >= top
        failBuffer = atr * 0.05
        newFailed = failed or (dir == 1 ? close < bottom - failBuffer : close > top + failBuffer)
        newMitigated = mitigated or throughMid or filled
        array.set(zoneFailed, i, newFailed)
        array.set(zoneMitigated, i, newMitigated)

        z = array.get(zoneBoxes, i)
        ml = array.get(midLines, i)
        zoneColor = dir == 1 ? bullColor : bearColor
        activeAlpha = newFailed ? 92 : newMitigated ? 89 : 82
        borderAlpha = newFailed ? 70 : newMitigated ? 55 : 28
        box.set_right(z, bar_index + zoneExtend)
        box.set_bgcolor(z, showZones ? color.new(newFailed ? mutedColor : zoneColor, activeAlpha) : na)
        box.set_border_color(z, showZones ? color.new(newFailed ? mutedColor : zoneColor, borderAlpha) : na)
        box.set_text(z, showZones ? (newFailed ? "FAILED" : newMitigated ? "MITIGATED" : dir == 1 ? "BULL IMBALANCE" : "BEAR IMBALANCE") : "")
        line.set_x2(ml, bar_index + zoneExtend)
        line.set_color(ml, showMidpoints ? color.new(newFailed ? mutedColor : zoneColor, newMitigated ? 65 : 42) : na)

        wickRejectBull = dir == 1 and inZone and close > mid and close > open and (math.min(open, close) - low) / barRange > 0.18
        wickRejectBear = dir == -1 and inZone and close < mid and close < open and (high - math.max(open, close)) / barRange > 0.18
        touchRepriceBull = dir == 1 and inZone and close > bottom and close > open and (close > mid or low <= mid)
        touchRepriceBear = dir == -1 and inZone and close < top and close < open and (close < mid or high >= mid)
        vwapScoreBull = not useVwap ? 0.55 : close >= vwap ? 0.85 : low <= vwapLower ? 0.70 : 0.35
        vwapScoreBear = not useVwap ? 0.55 : close <= vwap ? 0.85 : high >= vwapUpper ? 0.70 : 0.35
        zoneSizeScore = f_clamp((top - bottom) / math.max(atr, syminfo.mintick), 0.05, 1.20) / 1.20
        dispScore = f_clamp((atrExpansion - minAtrExpansion) / 1.50, 0.0, 1.0)
        volScore = f_clamp((relVol - 1.0) / 1.75, 0.0, 1.0)
        bullScore = freshScore * 18 + zoneSizeScore * 14 + dispScore * 13 + volScore * 16 + vwapScoreBull * 16 + (deltaBull ? 13 : 0) + (wickRejectBull ? 10 : touchRepriceBull ? 6 : 0)
        bearScore = freshScore * 18 + zoneSizeScore * 14 + dispScore * 13 + volScore * 16 + vwapScoreBear * 16 + (deltaBear ? 13 : 0) + (wickRejectBear ? 10 : touchRepriceBear ? 6 : 0)

        longSetup = not newFailed and cooldownOk and (wickRejectBull or touchRepriceBull) and bullScore >= threshold
        shortSetup = not newFailed and cooldownOk and (wickRejectBear or touchRepriceBear) and bearScore >= threshold
        failSetup = not failed and newFailed and cooldownOk and age > 5 and relVol >= minRelVol
        score = dir == 1 ? bullScore : bearScore
        if longSetup and bullScore > bestScore
            bestDir := 1
            bestIndex := i
            bestScore := bullScore
            bestEvent := "LONG REPRICE"
        if shortSetup and bearScore > bestScore
            bestDir := -1
            bestIndex := i
            bestScore := bearScore
            bestEvent := "SHORT REPRICE"
        if failSetup and score > bestScore
            bestDir := dir
            bestIndex := i
            bestScore := math.max(score, threshold)
            bestEvent := dir == 1 ? "BULL FAIL" : "BEAR FAIL"

longSignal = bestEvent == "LONG REPRICE"
shortSignal = bestEvent == "SHORT REPRICE"
bullFail = bestEvent == "BULL FAIL"
bearFail = bestEvent == "BEAR FAIL"
anySignal = longSignal or shortSignal or bullFail or bearFail
if anySignal
    lastSignalBar := bar_index

// Visual context
plotVwap = plot(showVwapCloud ? vwap : na, "VWAP", color=color.new(accentColor, 0), linewidth=2)
plotUpper = plot(showVwapCloud ? vwapUpper : na, "VWAP Premium Band", color=color.new(bearColor, 74), linewidth=1)
plotLower = plot(showVwapCloud ? vwapLower : na, "VWAP Discount Band", color=color.new(bullColor, 74), linewidth=1)
fill(plotUpper, plotVwap, color=showVwapCloud ? color.new(bearColor, 92) : na, title="Premium VWAP Cloud")
fill(plotVwap, plotLower, color=showVwapCloud ? color.new(bullColor, 92) : na, title="Discount VWAP Cloud")

barcolor(longSignal ? color.new(bullColor, 0) : shortSignal ? color.new(bearColor, 0) : bullFail or bearFail ? color.new(accentColor, 10) : na)

if anySignal and showLabels and not na(bestIndex) and (longSignal or shortSignal or showFailureLabels)
    y = longSignal or bullFail ? low : high
    labelStyle = longSignal or bullFail ? label.style_label_up : label.style_label_down
    labelColor = longSignal ? bullColor : shortSignal ? bearColor : accentColor
    label.new(bar_index, y, bestEvent + "\n" + str.tostring(bestScore, "#"), style=labelStyle, color=color.new(labelColor, 0), textcolor=color.white, size=size.small)

// Latest projection
var line entryLine = na
var line invalidLine = na
var line target1Line = na
var line target2Line = na
if showProjections and (longSignal or shortSignal)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(invalidLine)
        line.delete(invalidLine)
    if not na(target1Line)
        line.delete(target1Line)
    if not na(target2Line)
        line.delete(target2Line)
    zTop = array.get(zoneTops, bestIndex)
    zBottom = array.get(zoneBottoms, bestIndex)
    entry = close
    invalid = longSignal ? zBottom - atr * 0.12 : zTop + atr * 0.12
    risk = math.max(math.abs(entry - invalid), syminfo.mintick)
    t1 = longSignal ? entry + risk : entry - risk
    t2 = longSignal ? entry + risk * 2.0 : entry - risk * 2.0
    entryLine := line.new(bar_index, entry, bar_index + zoneExtend, entry, color=color.new(accentColor, 0), width=2)
    invalidLine := line.new(bar_index, invalid, bar_index + zoneExtend, invalid, color=color.new(bearColor, 0), width=2)
    target1Line := line.new(bar_index, t1, bar_index + zoneExtend, t1, color=color.new(bullColor, 0), width=1, style=line.style_dashed)
    target2Line := line.new(bar_index, t2, bar_index + zoneExtend, t2, color=color.new(bullColor, 15), width=1, style=line.style_dashed)

// Dashboard
var table dash = table.new(position.top_right, 2, 7, bgcolor=panelBg, border_color=color.new(color.white, 82), border_width=1)
vwapState = close > vwapUpper ? "PREMIUM" : close < vwapLower ? "DISCOUNT" : close >= vwap ? "ABOVE VWAP" : "BELOW VWAP"
activeZones = array.size(zoneBoxes)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "ZOM Repricing", text_color=color.white, bgcolor=color.new(accentColor, 75), text_size=size.small)
    table.cell(dash, 1, 0, mode, text_color=color.white, bgcolor=color.new(accentColor, 75), text_size=size.small)
    table.cell(dash, 0, 1, "Zones", text_color=color.new(color.white, 18), text_size=size.tiny)
    table.cell(dash, 1, 1, str.tostring(activeZones), text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 2, "Last", text_color=color.new(color.white, 18), text_size=size.tiny)
    table.cell(dash, 1, 2, bestEvent, text_color=longSignal ? bullColor : shortSignal ? bearColor : accentColor, text_size=size.tiny)
    table.cell(dash, 0, 3, "Delta", text_color=color.new(color.white, 18), text_size=size.tiny)
    table.cell(dash, 1, 3, str.tostring(deltaPressure, "#.0"), text_color=deltaPressure >= 0 ? bullColor : bearColor, text_size=size.tiny)
    table.cell(dash, 0, 4, "Rel Vol", text_color=color.new(color.white, 18), text_size=size.tiny)
    table.cell(dash, 1, 4, str.tostring(relVol, "#.00") + "x", text_color=relVol >= minRelVol ? accentColor : mutedColor, text_size=size.tiny)
    table.cell(dash, 0, 5, "VWAP", text_color=color.new(color.white, 18), text_size=size.tiny)
    table.cell(dash, 1, 5, vwapState, text_color=vwapState == "DISCOUNT" ? bullColor : vwapState == "PREMIUM" ? bearColor : mutedColor, text_size=size.tiny)
    table.cell(dash, 0, 6, "Score", text_color=color.new(color.white, 18), text_size=size.tiny)
    table.cell(dash, 1, 6, str.tostring(bestScore, "#"), text_color=bestScore >= threshold ? accentColor : mutedColor, text_size=size.tiny)

alertcondition(longSignal, "Long Reprice [ZOM]", "Long imbalance reprice signal on {{ticker}} {{interval}}.")
alertcondition(shortSignal, "Short Reprice [ZOM]", "Short imbalance reprice signal on {{ticker}} {{interval}}.")
alertcondition(bullFail, "Bullish Zone Failed [ZOM]", "Bullish imbalance zone failed on {{ticker}} {{interval}}.")
alertcondition(bearFail, "Bearish Zone Failed [ZOM]", "Bearish imbalance zone failed on {{ticker}} {{interval}}.")
alertcondition(anySignal and bestScore >= 82, "High-Score Reprice [ZOM]", "High-score imbalance repricing signal on {{ticker}} {{interval}}.")
````
