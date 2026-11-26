# Dealer Pin Release Map [ZOM]

- url: https://www.tradingview.com/script/t1ZNmZnS-Dealer-Pin-Release-Map-ZOM/
- type: indicator
- pine_id: PUB;a396121535ba4c99b81dba977d96b1ea
- version: 2.0

## Description

Dealer Pin Release Map [ZOM] is an intraday dealer-magnet model for traders who want a cleaner read on pinning, fade pressure, and volatility release around synthetic strike levels.

The script estimates the nearest live magnet from a configurable strike step, then scores pin pressure using price proximity, ATR compression, relative participation, and synthetic delta pressure. When price compresses around the magnet, the tool highlights the active pin. When price rejects the pin edge or expands away from a prior pin state, it marks potential fade or release conditions.

What it shows:
- Live pin magnet: the current strike-style level price is clustering around.
- Release rails: upside/downside levels where a pinned auction can begin to unwind.
- Pin Fade signals: wick and delta-confirmed rejection from the pin edge.
- Gamma Release alerts: expansion signals after prior pin pressure, relative volume, and directional delta confirm.
- Dashboard: current state, magnet, pin score, release energy, relative volume, and delta pressure.

This is intentionally not a traditional moving-average or support/resistance indicator. It is built to frame the auction as a dealer-style pin/release map, especially on liquid futures and index products where round-number and strike-style magnets can matter.

Notes:
- The model uses proxy calculations from price, volume, ATR, and candle location. It does not read live options open interest or broker order flow.
- Best used with liquid symbols and sensible strike steps, such as 25 or 50 points on major equity index futures.
- Signals are contextual. Use the rails and dashboard as a map, not as standalone financial advice.

## Source Code

````pine
//@version=6
indicator("Dealer Pin Release Map [ZOM]", shorttitle="Pin Release [ZOM]", overlay=true, max_labels_count=80, max_lines_count=40)

// Dealer Pin Release Map [ZOM]
// Candidate for manual TradingView review before publication.

mode = input.string("Normal", "Signal Strictness", options=["Aggressive", "Normal", "Strict"], group="Signal Engine")
strikeStep = input.float(25.0, "Magnet / Strike Step", minval=0.01, step=0.25, group="Dealer Map")
magnetAtrWidth = input.float(0.62, "Pin Magnet ATR Width", minval=0.10, maxval=3.00, step=0.05, group="Dealer Map")
releaseLookback = input.int(8, "Prior Pin Lookback", minval=2, maxval=50, group="Signal Engine")
cooldownBars = input.int(10, "Signal Cooldown Bars", minval=1, maxval=100, group="Signal Engine")
atrLen = input.int(14, "ATR Length", minval=5, maxval=100, group="Signal Engine")
volLen = input.int(34, "Relative Volume Length", minval=5, maxval=200, group="Signal Engine")
deltaLen = input.int(10, "Delta Pressure Smoothing", minval=2, maxval=80, group="Signal Engine")
compressionLen = input.int(40, "Compression Memory", minval=10, maxval=200, group="Signal Engine")
recentLabelBars = input.int(90, "Recent Label Window", minval=10, maxval=500, group="Visuals")

theme = input.string("Rogue", "Aesthetic Template", options=["Rogue", "Emerald", "Gold Rush", "Arctic", "Mono"], group="Visuals")
showMagnetGrid = input.bool(true, "Dealer Magnet Grid", group="Visuals")
showOuterMagnets = input.bool(false, "Outer Magnet Rails", group="Visuals")
showPinGlow = input.bool(false, "Pin Pressure Glow", group="Visuals")
showLabels = input.bool(true, "Signal Labels", group="Visuals")
showDashboard = input.bool(true, "Dashboard", group="Visuals")
showBarColor = input.bool(true, "Signal Bar Color", group="Visuals")

bullColor = theme == "Emerald" ? color.rgb(0, 188, 132) : theme == "Gold Rush" ? color.rgb(239, 180, 72) : theme == "Arctic" ? color.rgb(84, 188, 255) : theme == "Mono" ? color.rgb(214, 214, 214) : color.rgb(34, 197, 165)
bearColor = theme == "Emerald" ? color.rgb(255, 94, 124) : theme == "Gold Rush" ? color.rgb(197, 84, 49) : theme == "Arctic" ? color.rgb(255, 122, 176) : theme == "Mono" ? color.rgb(132, 132, 132) : color.rgb(229, 78, 116)
accentColor = theme == "Emerald" ? color.rgb(60, 232, 178) : theme == "Gold Rush" ? color.rgb(255, 211, 110) : theme == "Arctic" ? color.rgb(170, 225, 255) : theme == "Mono" ? color.rgb(172, 172, 172) : color.rgb(96, 165, 250)
pinColor = theme == "Gold Rush" ? color.rgb(255, 215, 116) : theme == "Arctic" ? color.rgb(206, 236, 255) : color.rgb(167, 139, 250)
warnColor = color.rgb(255, 196, 87)
panelBg = color.new(color.rgb(18, 22, 31), 10)

f_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

atr = ta.atr(atrLen)
atrBase = ta.ema(atr, compressionLen)
atrRatio = atrBase > 0 ? atr / atrBase : 1.0
volAvg = ta.sma(volume, volLen)
relVol = volAvg > 0 ? volume / volAvg : 0.0
barRange = math.max(high - low, syminfo.mintick)
bodyTop = math.max(open, close)
bodyBot = math.min(open, close)
upperWick = high - bodyTop
lowerWick = bodyBot - low
bodyShare = math.abs(close - open) / barRange

closeLocation = ((close - low) - (high - close)) / barRange
deltaPressure = ta.ema(closeLocation * volume / math.max(volAvg, 1) * 100, deltaLen)
deltaSlope = deltaPressure - deltaPressure[1]

nearestMagnet = math.round(close / strikeStep) * strikeStep
priorMagnet = nz(nearestMagnet[1], nearestMagnet)
upperMagnet = nearestMagnet + strikeStep
lowerMagnet = nearestMagnet - strikeStep
upperMagnet2 = nearestMagnet + strikeStep * 2.0
lowerMagnet2 = nearestMagnet - strikeStep * 2.0
distToMagnet = math.abs(close - nearestMagnet)
magnetRange = math.max(atr * magnetAtrWidth, syminfo.mintick)
pinEdgeUpper = priorMagnet + magnetRange
pinEdgeLower = priorMagnet - magnetRange

pinProximity = f_clamp(1.0 - distToMagnet / magnetRange, 0.0, 1.0)
compressionScore = f_clamp((1.20 - atrRatio) / 0.55, 0.0, 1.0)
participationScore = f_clamp(1.25 - relVol, 0.0, 1.0)
pinScore = f_clamp(pinProximity * 58.0 + compressionScore * 26.0 + participationScore * 16.0, 0.0, 100.0)

breakUp = close > pinEdgeUpper and close[1] <= pinEdgeUpper
breakDown = close < pinEdgeLower and close[1] >= pinEdgeLower
expansion = atrRatio > 1.04 and relVol > 1.05 and bodyShare > 0.45
priorPin = ta.highest(pinScore, releaseLookback)[1]
pinEscape = f_clamp(math.abs(close - priorMagnet) / magnetRange, 0.0, 2.2)
releaseEnergy = f_clamp((priorPin - 45.0) * 0.72 + (atrRatio - 1.0) * 38.0 + (relVol - 1.0) * 16.0 + math.abs(deltaPressure) * 0.20 + pinEscape * 16.0, 0.0, 100.0)

fadeUpper = high >= nearestMagnet + magnetRange * 0.72 and close < nearestMagnet + magnetRange * 0.38 and upperWick > lowerWick * 1.25 and deltaSlope < 0
fadeLower = low <= nearestMagnet - magnetRange * 0.72 and close > nearestMagnet - magnetRange * 0.38 and lowerWick > upperWick * 1.25 and deltaSlope > 0

thresholdRelease = mode == "Strict" ? 76.0 : mode == "Aggressive" ? 55.0 : 65.0
thresholdFade = mode == "Strict" ? 70.0 : mode == "Aggressive" ? 50.0 : 60.0
pinThreshold = mode == "Strict" ? 78.0 : mode == "Aggressive" ? 58.0 : 68.0

var int lastSignalBar = na
cooldownOk = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars
labelWindowOk = bar_index >= last_bar_index - recentLabelBars

longRelease = cooldownOk and priorPin >= thresholdFade and breakUp and expansion and releaseEnergy >= thresholdRelease and deltaPressure > 0
shortRelease = cooldownOk and priorPin >= thresholdFade and breakDown and expansion and releaseEnergy >= thresholdRelease and deltaPressure < 0
pinFadeShort = cooldownOk and fadeUpper and ta.highest(pinScore, 4) >= thresholdFade
pinFadeLong = cooldownOk and fadeLower and ta.highest(pinScore, 4) >= thresholdFade
pinActive = pinScore >= pinThreshold

bgcolor(showPinGlow and pinActive ? color.new(pinColor, 93) : na)

plot(showMagnetGrid ? nearestMagnet : na, "Dealer Pin Magnet", color=color.new(pinColor, 0), linewidth=3, style=plot.style_linebr)
plot(showMagnetGrid ? upperMagnet : na, "Upper Release Rail", color=color.new(bearColor, 12), linewidth=2, style=plot.style_linebr)
plot(showMagnetGrid ? lowerMagnet : na, "Lower Release Rail", color=color.new(bullColor, 12), linewidth=2, style=plot.style_linebr)
plot(showMagnetGrid and showOuterMagnets ? upperMagnet2 : na, "Outer Upper Rail", color=color.new(bearColor, 78), linewidth=1, style=plot.style_circles)
plot(showMagnetGrid and showOuterMagnets ? lowerMagnet2 : na, "Outer Lower Rail", color=color.new(bullColor, 78), linewidth=1, style=plot.style_circles)

pinEvent = pinActive and not pinActive[1] and not longRelease and not shortRelease
plotshape(pinEvent ? nearestMagnet : na, "Dealer Pin", shape.circle, location.absolute, color.new(pinColor, 0), size=size.tiny, text="PIN")

var label[] sigLabels = array.new_label()

if longRelease
    lastSignalBar := bar_index
    if showLabels and labelWindowOk
        array.push(sigLabels, label.new(bar_index, low, "GAMMA RELEASE\nLONG " + str.tostring(releaseEnergy, "#"), style=label.style_label_up, color=color.new(bullColor, 0), textcolor=color.white, size=size.small))
if shortRelease
    lastSignalBar := bar_index
    if showLabels and labelWindowOk
        array.push(sigLabels, label.new(bar_index, high, "GAMMA RELEASE\nSHORT " + str.tostring(releaseEnergy, "#"), style=label.style_label_down, color=color.new(bearColor, 0), textcolor=color.white, size=size.small))
if pinFadeLong
    lastSignalBar := bar_index
    if showLabels and labelWindowOk
        array.push(sigLabels, label.new(bar_index, low, "PIN FADE\nLONG " + str.tostring(pinScore, "#"), style=label.style_label_up, color=color.new(accentColor, 0), textcolor=color.white, size=size.tiny))
if pinFadeShort
    lastSignalBar := bar_index
    if showLabels and labelWindowOk
        array.push(sigLabels, label.new(bar_index, high, "PIN FADE\nSHORT " + str.tostring(pinScore, "#"), style=label.style_label_down, color=color.new(warnColor, 0), textcolor=color.rgb(22, 22, 26), size=size.tiny))

while array.size(sigLabels) > 35
    label.delete(array.shift(sigLabels))

barcolor(showBarColor and longRelease ? color.new(bullColor, 22) : showBarColor and shortRelease ? color.new(bearColor, 22) : showBarColor and (pinFadeLong or pinFadeShort) ? color.new(warnColor, 30) : na)

alertcondition(longRelease, "Gamma Release Long [ZOM]", "Dealer pin release long on {{ticker}} {{interval}}.")
alertcondition(shortRelease, "Gamma Release Short [ZOM]", "Dealer pin release short on {{ticker}} {{interval}}.")
alertcondition(pinFadeLong, "Pin Fade Long [ZOM]", "Dealer magnet pin fade long on {{ticker}} {{interval}}.")
alertcondition(pinFadeShort, "Pin Fade Short [ZOM]", "Dealer magnet pin fade short on {{ticker}} {{interval}}.")

var table dash = table.new(position.top_right, 2, 7, bgcolor=panelBg, frame_color=color.new(pinColor, 54), frame_width=1)
if showDashboard and barstate.islast
    stateText = longRelease ? "LONG RELEASE" : shortRelease ? "SHORT RELEASE" : pinFadeLong ? "LONG FADE" : pinFadeShort ? "SHORT FADE" : pinActive ? "PINNED" : "AUCTION"
    stateColor = longRelease or pinFadeLong ? bullColor : shortRelease or pinFadeShort ? bearColor : pinActive ? pinColor : accentColor
    table.cell(dash, 0, 0, "ZOM Dealer", text_color=color.white, bgcolor=color.new(stateColor, 72), text_size=size.tiny)
    table.cell(dash, 1, 0, mode, text_color=color.white, bgcolor=color.new(stateColor, 72), text_size=size.tiny)
    table.cell(dash, 0, 1, "State", text_color=color.new(color.white, 12), text_size=size.tiny)
    table.cell(dash, 1, 1, stateText, text_color=stateColor, text_size=size.tiny)
    table.cell(dash, 0, 2, "Magnet", text_color=color.new(color.white, 12), text_size=size.tiny)
    table.cell(dash, 1, 2, str.tostring(nearestMagnet, format.mintick), text_color=pinColor, text_size=size.tiny)
    table.cell(dash, 0, 3, "Pin", text_color=color.new(color.white, 12), text_size=size.tiny)
    table.cell(dash, 1, 3, str.tostring(pinScore, "#"), text_color=pinScore >= pinThreshold ? pinColor : color.new(color.white, 20), text_size=size.tiny)
    table.cell(dash, 0, 4, "Release", text_color=color.new(color.white, 12), text_size=size.tiny)
    table.cell(dash, 1, 4, str.tostring(releaseEnergy, "#"), text_color=releaseEnergy >= thresholdRelease ? stateColor : warnColor, text_size=size.tiny)
    table.cell(dash, 0, 5, "RelVol", text_color=color.new(color.white, 12), text_size=size.tiny)
    table.cell(dash, 1, 5, str.tostring(relVol, "#.00") + "x", text_color=relVol > 1.05 ? stateColor : color.new(color.white, 20), text_size=size.tiny)
    table.cell(dash, 0, 6, "Delta", text_color=color.new(color.white, 12), text_size=size.tiny)
    table.cell(dash, 1, 6, str.tostring(deltaPressure, "#"), text_color=deltaPressure >= 0 ? bullColor : bearColor, text_size=size.tiny)
````
