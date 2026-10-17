# Tape Pressure Pulse [ZOM]

- url: https://www.tradingview.com/script/cYkciORo-Tape-Pressure-Pulse-ZOM/
- type: indicator
- pine_id: PUB;5369a173fb634d43bbac079d80512fe6
- version: 1.0

## Description

Tape Pressure Pulse [ZOM] is a lower-panel tape pressure monitor built to read effort, directional pressure, absorption, and ignition without drawing over the price chart.

What it shows:

- A normalized signed tape pulse derived from candle location, relative volume, and pressure smoothing.
- A bias rail that tracks whether pressure is sustaining above or below zero.
- A subtle effort meter for volume participation.
- Scored ignition markers when pressure rotates or expands with effort.
- Scored absorption markers when high effort produces wick rejection with limited price progress.
- Heat-wash pane coloring to make pressure regimes readable at a glance.

This script is intentionally designed as a different visual archetype from overlay zone tools. It works best as a lower-panel confirmation layer beside price action, liquidity levels, or existing execution systems.

The model uses price, wick structure, relative volume, ATR-normalized progress, and candle-location pressure. It does not use live order book, broker flow, or exchange-level footprint data.

Signals are contextual and should be combined with market structure and risk controls. This script is for research and education, not standalone financial advice.

## Source Code

````pine
//@version=6
indicator("Tape Pressure Pulse [ZOM]", shorttitle="Tape Pulse [ZOM]", overlay=false, max_labels_count=160)

// Tape Pressure Pulse [ZOM]
// Lower-panel tape/pressure monitor. Designed as a visual break from overlay zone maps.

mode = input.string("Normal", "Signal Strictness", options=["Reactive", "Normal", "Selective"], group="Pulse Engine")
volLen = input.int(34, "Relative Volume Baseline", minval=5, maxval=300, group="Pulse Engine")
normLen = input.int(120, "Pressure Normalization Lookback", minval=30, maxval=500, group="Pulse Engine")
pulseSmooth = input.int(5, "Pulse Smoothing", minval=1, maxval=50, group="Pulse Engine")
biasLen = input.int(21, "Bias Rail Length", minval=3, maxval=120, group="Pulse Engine")
atrLen = input.int(14, "ATR Length", minval=5, maxval=100, group="Pulse Engine")
cooldownBars = input.int(8, "Marker Cooldown Bars", minval=0, maxval=100, group="Pulse Engine")

minRelVol = input.float(1.20, "Minimum Effort", minval=0.20, maxval=8.00, step=0.05, group="Signal Filters")
bodyMin = input.float(0.45, "Ignition Body Share", minval=0.10, maxval=0.95, step=0.01, group="Signal Filters")
wickMin = input.float(0.38, "Absorption Wick Share", minval=0.10, maxval=0.90, step=0.01, group="Signal Filters")
stallMaxAtr = input.float(0.24, "Absorption Max Progress ATR", minval=0.02, maxval=1.50, step=0.02, group="Signal Filters")

theme = input.string("Pulse", "Aesthetic Template", options=["Pulse", "Lime Tape", "Redline", "Ice", "Mono"], group="Visuals")
showHeat = input.bool(true, "Pane Heat Wash", group="Visuals")
showBiasRail = input.bool(true, "Bias Rail", group="Visuals")
showMarkers = input.bool(true, "Ignition / Absorption Markers", group="Visuals")
showMeter = input.bool(true, "Edge Meter", group="Visuals")

bullColor = theme == "Lime Tape" ? color.rgb(95, 255, 120) : theme == "Redline" ? color.rgb(255, 205, 76) : theme == "Ice" ? color.rgb(84, 208, 255) : theme == "Mono" ? color.rgb(230, 230, 230) : color.rgb(46, 230, 176)
bearColor = theme == "Lime Tape" ? color.rgb(255, 82, 118) : theme == "Redline" ? color.rgb(255, 62, 89) : theme == "Ice" ? color.rgb(255, 111, 203) : theme == "Mono" ? color.rgb(125, 125, 125) : color.rgb(255, 78, 134)
accentColor = theme == "Lime Tape" ? color.rgb(198, 255, 112) : theme == "Redline" ? color.rgb(255, 125, 98) : theme == "Ice" ? color.rgb(207, 241, 255) : theme == "Mono" ? color.rgb(175, 175, 175) : color.rgb(126, 164, 255)
absorbColor = color.rgb(255, 202, 91)
panelDark = color.rgb(8, 10, 15)

f_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

atr = ta.atr(atrLen)
rangeSafe = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
bodyShare = body / rangeSafe
bodyTop = math.max(open, close)
bodyBot = math.min(open, close)
upperWickShare = (high - bodyTop) / rangeSafe
lowerWickShare = (bodyBot - low) / rangeSafe
closeLocation = ((close - low) - (high - close)) / rangeSafe

volBase = ta.sma(volume, volLen)
relVol = volBase > 0 ? volume / volBase : 1.0
progressAtr = math.abs(close - close[1]) / math.max(atr, syminfo.mintick)
rawPressure = closeLocation * relVol * 100.0
smoothPressure = ta.ema(rawPressure, pulseSmooth)
pressureMean = ta.sma(smoothPressure, normLen)
pressureDev = ta.stdev(smoothPressure, normLen)
zPressure = pressureDev > 0 ? (smoothPressure - pressureMean) / pressureDev : 0.0
pulseScore = f_clamp(zPressure * 34.0, -100.0, 100.0)
biasRail = ta.ema(pulseScore, biasLen)
effortMeter = f_clamp((relVol - 0.60) / 2.80 * 100.0, 0.0, 100.0)
pulseAccel = pulseScore - pulseScore[1]
bodyDir = close > open ? 1 : close < open ? -1 : 0

threshold = mode == "Selective" ? 68.0 : mode == "Reactive" ? 48.0 : 58.0

hardUpIgnition = pulseScore >= threshold and relVol >= minRelVol and bodyShare >= bodyMin and close > open and close > close[1]
hardDownIgnition = pulseScore <= -threshold and relVol >= minRelVol and bodyShare >= bodyMin and close < open and close < close[1]
rotationUp = ta.crossover(pulseScore, biasRail) and pulseScore > 12 and pulseAccel > 8 and relVol >= minRelVol * 0.85 and bodyDir >= 0
rotationDown = ta.crossunder(pulseScore, biasRail) and pulseScore < -12 and pulseAccel < -8 and relVol >= minRelVol * 0.85 and bodyDir <= 0
upIgnition = hardUpIgnition or rotationUp
downIgnition = hardDownIgnition or rotationDown

lowAbsorption = relVol >= minRelVol and lowerWickShare >= wickMin and progressAtr <= stallMaxAtr and pulseScore > pulseScore[1] and close > low + rangeSafe * 0.50
highAbsorption = relVol >= minRelVol and upperWickShare >= wickMin and progressAtr <= stallMaxAtr and pulseScore < pulseScore[1] and close < high - rangeSafe * 0.50
ignitionQuality = f_clamp(math.abs(pulseScore) * 0.42 + effortMeter * 0.22 + bodyShare * 28.0 + math.abs(pulseAccel) * 0.55, 0.0, 100.0)
absorptionQuality = f_clamp(math.abs(pulseAccel) * 0.70 + effortMeter * 0.25 + math.max(upperWickShare, lowerWickShare) * 45.0 + (stallMaxAtr - math.min(progressAtr, stallMaxAtr)) / stallMaxAtr * 18.0, 0.0, 100.0)

var int lastMarkerBar = na
var label[] pulseLabels = array.new_label()
cooldownOk = na(lastMarkerBar) or bar_index - lastMarkerBar > cooldownBars
markUp = showMarkers and cooldownOk and upIgnition
markDown = showMarkers and cooldownOk and downIgnition
markLowAbsorb = showMarkers and cooldownOk and lowAbsorption and not upIgnition
markHighAbsorb = showMarkers and cooldownOk and highAbsorption and not downIgnition

if markUp or markDown or markLowAbsorb or markHighAbsorb
    lastMarkerBar := bar_index
    markerY = markUp or markLowAbsorb ? -82.0 : 82.0
    markerScore = markUp or markDown ? ignitionQuality : absorptionQuality
    markerText = (markUp ? "IGN +" : markDown ? "IGN -" : markLowAbsorb ? "ABS +" : "ABS -") + " " + str.tostring(markerScore, "#")
    markerColor = markUp ? bullColor : markDown ? bearColor : absorbColor
    markerStyle = markUp or markLowAbsorb ? label.style_label_up : label.style_label_down
    array.push(pulseLabels, label.new(bar_index, markerY, markerText, style=markerStyle, color=color.new(panelDark, 10), textcolor=markerColor, size=size.tiny))

while array.size(pulseLabels) > 55
    label.delete(array.shift(pulseLabels))

heatStrength = int(math.round(92.0 - math.min(math.abs(pulseScore), 100.0) * 0.34))
heatColor = pulseScore >= 0 ? color.new(bullColor, heatStrength) : color.new(bearColor, heatStrength)
bgcolor(showHeat ? heatColor : na, title="Pulse Heat Wash")

hline(0, "Zero Line", color=color.new(accentColor, 70), linestyle=hline.style_solid)
hline(70, "Upper Pressure Shelf", color=color.new(bullColor, 70), linestyle=hline.style_dotted)
hline(-70, "Lower Pressure Shelf", color=color.new(bearColor, 70), linestyle=hline.style_dotted)
hline(35, "Upper Tempo", color=color.new(bullColor, 88), linestyle=hline.style_dotted)
hline(-35, "Lower Tempo", color=color.new(bearColor, 88), linestyle=hline.style_dotted)

barColor = color.from_gradient(pulseScore, -100, 100, color.new(bearColor, 0), color.new(bullColor, 0))
plot(pulseScore, "Tape Pulse", style=plot.style_columns, color=color.new(barColor, 12), histbase=0)
plot(showBiasRail ? biasRail : na, "Bias Rail", color=color.new(accentColor, 0), linewidth=2, style=plot.style_stepline)
plot(showMeter ? effortMeter : na, "Effort Meter", color=color.new(color.white, 86), linewidth=1, style=plot.style_area, histbase=0)

alertcondition(markUp, "Tape Ignition Long [ZOM]", "Tape Pressure Pulse [ZOM]: upside tape ignition on {{ticker}} {{interval}}.")
alertcondition(markDown, "Tape Ignition Short [ZOM]", "Tape Pressure Pulse [ZOM]: downside tape ignition on {{ticker}} {{interval}}.")
alertcondition(markLowAbsorb, "Low Absorption [ZOM]", "Tape Pressure Pulse [ZOM]: low-side absorption detected on {{ticker}} {{interval}}.")
alertcondition(markHighAbsorb, "High Absorption [ZOM]", "Tape Pressure Pulse [ZOM]: high-side absorption detected on {{ticker}} {{interval}}.")
````
