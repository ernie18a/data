# Quantum Catalyst Nexus [AnkeAlgo]

- url: https://www.tradingview.com/script/EYwG3zQY-Quantum-Catalyst-Nexus-AnkeAlgo/
- type: indicator
- pine_id: PUB;f374f5f7190b41b68196cbbff233e46c
- version: 1.0

## Description

[b]Quantum Catalyst Nexus [AnkeAlgo][/b]

This publication introduces an institutional-grade catalyst engine built for traders who want more than decorative clouds and generic momentum arrows. Quantum Catalyst Nexus combines structural displacement, participation analysis, internal delta pressure, and higher-timeframe bias into a single execution framework designed for real chart work.

[image]https://www.tradingview.com/x/FPGbmAGW/[/image]

[b]What Makes This Different[/b]

Most public indicators stop at one layer: trend, volume, or market structure. This one was engineered as a decision stack.

[list]
[*][b]Structure Layer:[/b] detects confirmed Market Structure Shift events instead of blindly reacting to every swing break.
[*][b]Participation Layer:[/b] measures relative volume expansion so weak breakouts are filtered out.
[*][b]Internal Delta Layer:[/b] estimates whether the bar closes with true directional pressure inside its own range.
[*][b]Impulse Layer:[/b] checks body efficiency so low-quality candles do not get promoted into premium signals.
[*][b]MTF Bias Layer:[/b] aligns the active chart with a higher-timeframe context, defaulting to an automatic 3x timeframe.
[*][b]Signal Hierarchy:[/b] separates Standard catalysts from Prime catalysts so the chart communicates quality, not just direction.
[/list]

[quote]The goal is not to print more signals. The goal is to rank directional events by quality so the trader can focus on expansion with context.[/quote]

[b]Core Design Philosophy[/b]

Quantum Catalyst Nexus was designed around one institutional idea: meaningful moves tend to occur when structure shifts, participation expands, and directional pressure aligns across timeframes. When these conditions converge, the market is no longer just drifting. It is transitioning.

[b]Indicator Architecture[/b]

[list=1]
[*]Detect local swing structure with confirmed pivots.
[*]Require a minimum ATR-based displacement before labeling a break as an MSS event.
[*]Measure relative volume against a rolling average to detect participation shock.
[*]Compute internal buy-vs-sell pressure from the candle's close location inside its range.
[*]Smooth delta pressure to reduce single-bar noise.
[*]Project a higher-timeframe bias using the default Auto 3x framework.
[*]Score each event and classify it as Standard or Prime.
[*]Render the result through a clean cloud, premium candle coloring, HTF rails, HUD, and alert conditions.
[/list]

[b]Core Code: Auto 3x Higher-Timeframe Engine[/b]

The indicator automatically derives a higher-timeframe context from the active chart. A 5-minute chart reads from 15-minute logic, a 15-minute chart reads from 45-minute logic, a 1-hour chart reads from 3-hour logic, and so on.

[pine]
f_autoTripleTf() =>
    timeframe.isseconds ? str.tostring(timeframe.multiplier * 3) + "S" :
     timeframe.isminutes ? str.tostring(timeframe.multiplier * 3) :
     timeframe.isdaily ? str.tostring(timeframe.multiplier * 3) + "D" :
     timeframe.isweekly ? str.tostring(timeframe.multiplier * 3) + "W" :
     timeframe.ismonthly ? str.tostring(timeframe.multiplier * 3) + "M" :
     timeframe.period

activeHtf = htfMode == "Auto 3x" ? f_autoTripleTf() : customHtf

htfFast = request.security(syminfo.tickerid, activeHtf, ta.ema(hlc3, math.max(3, lookback)))
htfSlow = request.security(syminfo.tickerid, activeHtf, ta.ema(hlc3, math.max(6, lookback * 2)))
htfDelta = request.security(
    syminfo.tickerid,
    activeHtf,
    ta.ema(((close - low) / math.max(high - low, syminfo.mintick) * volume - (high - close) / math.max(high - low, syminfo.mintick) * volume) / math.max(volume, 1) * 100.0, deltaSmooth)
)

htfTrend = htfFast > htfSlow ? 1 : htfFast < htfSlow ? -1 : 0
htfBull = htfTrend >= 0 and htfDelta >= 0
htfBear = htfTrend <= 0 and htfDelta <= 0
[/pine]

[b]Why This Matters[/b]

A signal on the execution timeframe becomes dramatically more relevant when the higher timeframe is already supportive. The default 3x model keeps the workflow fast and practical without forcing the user to manually synchronize timeframes.

[b]Core Code: Market Structure Shift + Participation Logic[/b]

Structure alone is not enough. A true catalyst must displace with intent.

[pine]
atr = ta.atr(14)
priceRange = math.max(high - low, syminfo.mintick)
bodyPct = math.abs(close - open) / priceRange * 100.0

ph = ta.pivothigh(high, lookback, lookback)
pl = ta.pivotlow(low, lookback, lookback)

bullMss = not na(lastPh) and close > lastPh and close[1] <= lastPh and close - lastPh > atr * mssAtrConfirm
bearMss = not na(lastPl) and close < lastPl and close[1] >= lastPl and lastPl - close > atr * mssAtrConfirm

avgVol = ta.sma(volume, volumeLookback)
relVol = avgVol > 0 ? volume / avgVol : 0.0
isVolumeSurprise = relVol >= volThresh

buyIntensity = (close - low) / priceRange * volume
sellIntensity = (high - close) / priceRange * volume
deltaFlow = ((buyIntensity - sellIntensity) / math.max(volume, 1)) * 100.0
deltaTrend = ta.ema(deltaFlow, deltaSmooth)
[/pine]

[b]Logic Walkthrough[/b]

[b]1. MSS Filter[/b]

A break is only accepted when price takes out the last confirmed structural pivot and exceeds an ATR-based displacement threshold. This reduces fragile one-tick violations and improves the quality of structural events.

[b]2. Relative Volume Filter[/b]

The script measures current volume against a rolling average. A catalyst should not just break structure; it should break structure with participation. Relative volume is the proxy for that expansion.

[b]3. Internal Delta Approximation[/b]

The indicator estimates directional pressure by observing where the candle closes inside its own range. A bullish bar closing near the high with strong volume carries very different information from a weak close in the middle of the range.

[b]4. Impulse Quality[/b]

The body percentage test acts as a quality gate. Efficient candles are more likely to represent committed flow rather than indecision.

[b]Core Code: Signal Scoring and Prime Classification[/b]

[pine]
bullImpulse = bodyPct >= bodyImpulseMin and close > fastFlow
bearImpulse = bodyPct >= bodyImpulseMin and close < fastFlow
bullCloudAlign = fastFlow > slowFlow
bearCloudAlign = fastFlow < slowFlow
htfPassBull = not useHtfBias or htfBull
htfPassBear = not useHtfBias or htfBear

bullScore = (bullMss ? 2 : 0) + (isVolumeSurprise ? 1 : 0) + (bullPressure ? 1 : 0) + (bullImpulse ? 1 : 0) + (bullCloudAlign ? 1 : 0) + (htfPassBull ? 1 : 0)
bearScore = (bearMss ? 2 : 0) + (isVolumeSurprise ? 1 : 0) + (bearPressure ? 1 : 0) + (bearImpulse ? 1 : 0) + (bearCloudAlign ? 1 : 0) + (htfPassBear ? 1 : 0)

bullCatalyst = bullMss and htfPassBull and bullScore >= minCatalystScore
bearCatalyst = bearMss and htfPassBear and bearScore >= minCatalystScore
bullPrime = bullCatalyst and bullScore >= primeCatalystScore and relVol >= volThresh * 1.1 and bodyPct >= bodyImpulseMin + 5
bearPrime = bearCatalyst and bearScore >= primeCatalystScore and relVol >= volThresh * 1.1 and bodyPct >= bodyImpulseMin + 5
[/pine]

[b]Prime vs Standard Signals[/b]

[list]
[*][b]Standard Catalyst:[/b] A valid event that satisfies the minimum directional quality threshold.
[*][b]Prime Catalyst:[/b] A higher-grade event with stronger scoring, stronger participation, and cleaner impulse quality.
[*][b]S+ / S-:[/b] Standard Bull and Standard Bear catalysts.
[*][b]P+ / P-:[/b] Prime Bull and Prime Bear catalysts.
[/list]

This hierarchy is important because real markets do not deliver the same quality of expansion every time. The chart should tell you when a move is merely acceptable and when it is exceptional.

[b]Visual System[/b]

The chart is not designed as a toy dashboard. Every element exists to compress information.

[list]
[*][b]Dynamic Delta Cloud:[/b] visualizes local flow direction through a fast-vs-slow trend envelope.
[*][b]Premium Candle Coloring:[/b] reflects trend, delta support, and Prime/Standard signal quality.
[*][b]HTF Structure Rails:[/b] marks the most relevant higher-timeframe pivot references.
[*][b]HUD:[/b] surfaces live structure, HTF bias, catalyst state, score, relative volume, and delta condition.
[/list]

[b]How To Use It[/b]

[b]Trend Continuation Workflow[/b]

[list=1]
[*]Wait for the cloud to align with the higher timeframe.
[*]Look for a fresh Standard or Prime catalyst in the same direction as the HTF bias.
[*]Prioritize Prime signals when relative volume expands and the score remains elevated.
[*]Use the last structural invalidation or the opposite rail as your contextual risk reference.
[/list]

[b]Early Trend Transition Workflow[/b]

[list=1]
[*]Watch for an MSS against the previous intraday bias.
[*]Confirm that relative volume expands.
[*]Require deltaTrend to flip and stay supportive.
[*]Upgrade conviction only if the event becomes Prime or if the HTF bias also begins to turn.
[/list]

[b]Cross-Timeframe Workflow[/b]

[image]https://www.tradingview.com/x/tXY66bEg/[/image]

The default design uses a 3x higher-timeframe relationship.

[list]
[*]5m chart -> 15m bias
[*]15m chart -> 45m bias
[*]1H chart -> 3H bias
[*]4H chart -> 12H bias
[*]1D chart -> 3D bias
[/list]

This keeps the indicator highly usable for intraday traders, swing traders, and multi-session traders without requiring manual reconfiguration. If you need a more specific framework, switch the HTF mode to [b]Custom[/b] and select the exact timeframe yourself.

[b]Recommended Settings[/b]

[list]
[*][b]Fast intraday trading:[/b] lower lookback slightly, keep Auto 3x enabled, keep Prime filtering active.
[*][b]Balanced execution:[/b] default settings are already tuned for practical signal density.
[*][b]Higher selectivity:[/b] increase Min Catalyst Score and Prime Catalyst Score.
[*][b]Cleaner charting:[/b] disable mini levels and pulse background, keep HUD on.
[/list]

[b]HUD Interpretation[/b]

The HUD is meant to answer the six questions a professional trader asks before acting.

[list=1]
[*][b]Structure:[/b] Is the local market structurally bullish, bearish, or neutral?
[*][b]HTF Bias:[/b] Is the larger context supporting the trade?
[*][b]Catalyst:[/b] Is the current event Prime, Standard, or inactive?
[*][b]Score:[/b] How many quality layers are currently aligned?
[*][b]Rel Volume:[/b] Is participation above average?
[*][b]Delta:[/b] Is internal directional pressure reinforcing the move?
[/list]

[b]Alert Setup[/b]

Quantum Catalyst Nexus includes separate alert conditions for precise workflow automation.

[pine]
newBullPrime = bullPrime and not bullPrime[1]
newBearPrime = bearPrime and not bearPrime[1]
newBullStandard = bullStandard and not bullStandard[1]
newBearStandard = bearStandard and not bearStandard[1]
newAnyCatalyst = (bullCatalyst or bearCatalyst) and not (bullCatalyst[1] or bearCatalyst[1])

alertcondition(newBullPrime, "Prime Bull Catalyst", "Prime Bull Catalyst detected on {{ticker}} | TF: {{interval}}")
alertcondition(newBearPrime, "Prime Bear Catalyst", "Prime Bear Catalyst detected on {{ticker}} | TF: {{interval}}")
alertcondition(newBullStandard, "Standard Bull Catalyst", "Standard Bull Catalyst detected on {{ticker}} | TF: {{interval}}")
alertcondition(newBearStandard, "Standard Bear Catalyst", "Standard Bear Catalyst detected on {{ticker}} | TF: {{interval}}")
alertcondition(newAnyCatalyst, "Any Catalyst Signal", "A Catalyst signal was detected on {{ticker}} | TF: {{interval}}")
[/pine]

[b]How To Configure Alerts In TradingView[/b]

[list=1]
[*]Add the indicator to the chart.
[*]Open the TradingView alert dialog.
[*]Select Quantum Catalyst Nexus [AnkeAlgo] as the condition source.
[*]Choose one of the dedicated conditions: Prime Bull, Prime Bear, Standard Bull, Standard Bear, or Any Catalyst Signal.
[*]Use Prime alerts for high-conviction monitoring, or Any Catalyst for broad market scanning.
[/list]

[b]Professional Use Cases[/b]

[list]
[*]Intraday continuation after an opening range shift.
[*]Momentum confirmation after a retest and reclaim.
[*]Bias alignment between execution timeframe and supervisory timeframe.
[*]Event filtering for semi-systematic discretionary trading.
[*]Screening catalyst events across multiple watchlist instruments.
[/list]

[b]Important Interpretation Note[/b]

This indicator is not trying to predict every turning point. It is built to highlight moments when structure, participation, and internal pressure synchronize. In professional execution, that synchronization matters far more than decorative overfitting.

[b]Final Word[/b]

Quantum Catalyst Nexus [AnkeAlgo] is built for traders who want a premium catalyst framework instead of a noisy momentum overlay. If you trade structure, respect participation, and care about cross-timeframe alignment, this tool was engineered for that exact workflow.

If this release helps your process, boost it with a rocket and share how you are using Prime versus Standard catalysts in your own market environment.

## Source Code

````pine
//@version=6
indicator("Quantum Catalyst Nexus [AnkeAlgo]", "QC Nexus", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ============================================================================
// Inputs
// ============================================================================
groupStructure = "Structure Engine"
groupVolume = "Delta & Volume"
groupMtf = "MTF Bias"
groupSignal = "Signal Quality"
groupVisual = "Visual System"
groupHud = "HUD"

lookback = input.int(8, "Swing Sensitivity", minval = 2, group = groupStructure)
mssAtrConfirm = input.float(0.12, "MSS ATR Break Filter", minval = 0.0, step = 0.01, group = groupStructure)
bodyImpulseMin = input.float(42.0, "Min Body % of Range", minval = 5.0, maxval = 100.0, step = 1.0, group = groupStructure)

volumeLookback = input.int(20, "Volume Average Length", minval = 2, group = groupVolume)
volThresh = input.float(1.5, "Volume Surprise Multiplier", minval = 1.0, step = 0.1, group = groupVolume)
deltaSmooth = input.int(5, "Delta Smoothing", minval = 1, group = groupVolume)

useHtfBias = input.bool(true, "Enable HTF Filter", group = groupMtf)
htfMode = input.string("Auto 3x", "HTF Mode", options = ["Auto 3x", "Custom"], group = groupMtf)
customHtf = input.timeframe("240", "Custom HTF", group = groupMtf)
showHtfRibbon = input.bool(true, "Color Cloud With HTF Bias", group = groupMtf)
showHtfStructure = input.bool(true, "Show HTF Structure Rails", group = groupMtf)

minCatalystScore = input.int(4, "Min Catalyst Score", minval = 2, maxval = 7, group = groupSignal)
primeCatalystScore = input.int(6, "Prime Catalyst Score", minval = 4, maxval = 7, group = groupSignal)
showPrimeOnly = input.bool(false, "Show Prime Only", group = groupSignal)
showScoreMarkers = input.bool(true, "Show Score Tag", group = groupSignal)

showCloud = input.bool(true, "Display Dynamic Trend Cloud", group = groupVisual)
showBarColors = input.bool(true, "Color Candles", group = groupVisual)
showSignals = input.bool(true, "Show Catalyst Markers", group = groupVisual)
showMiniLevels = input.bool(false, "Show Active Structure Levels", group = groupVisual)
showSignalPulse = input.bool(false, "Show Pulse Background", group = groupVisual)
showCloudMidline = input.bool(false, "Show Cloud Midline", group = groupVisual)
theme = input.string("Quantum", "Theme", options = ["Quantum", "Infrared", "Mono"], group = groupVisual)

showHud = input.bool(true, "Show HUD", group = groupHud)
hudPosition = input.string("Top Right", "HUD Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = groupHud)
hudSize = input.string("Small", "HUD Size", options = ["Tiny", "Small", "Normal"], group = groupHud)

// ============================================================================
// Theme
// ============================================================================
bullBase = theme == "Quantum" ? color.rgb(0, 255, 204) : theme == "Infrared" ? color.rgb(255, 196, 0) : color.rgb(40, 215, 140)
bearBase = theme == "Quantum" ? color.rgb(255, 73, 137) : theme == "Infrared" ? color.rgb(255, 88, 88) : color.rgb(255, 105, 105)
neutralBase = theme == "Quantum" ? color.rgb(100, 125, 255) : theme == "Infrared" ? color.rgb(182, 138, 255) : color.rgb(140, 150, 170)
cloudBull = color.new(bullBase, 90)
cloudBear = color.new(bearBase, 90)
cloudLineBull = color.new(bullBase, 18)
cloudLineBear = color.new(bearBase, 18)
slowLineCss = color.new(neutralBase, 55)
midLineCss = color.new(neutralBase, 75)
hudBg = color.new(color.rgb(10, 14, 24), 8)
hudBorder = color.new(color.rgb(70, 88, 120), 35)
hudAccent = color.new(neutralBase, 75)

f_autoTripleTf() =>
    timeframe.isseconds ? str.tostring(timeframe.multiplier * 3) + "S" :
     timeframe.isminutes ? str.tostring(timeframe.multiplier * 3) :
     timeframe.isdaily ? str.tostring(timeframe.multiplier * 3) + "D" :
     timeframe.isweekly ? str.tostring(timeframe.multiplier * 3) + "W" :
     timeframe.ismonthly ? str.tostring(timeframe.multiplier * 3) + "M" :
     timeframe.period

f_getPos(string pos) =>
    switch pos
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_getSize(string sizeIn) =>
    switch sizeIn
        "Tiny" => size.tiny
        "Normal" => size.normal
        => size.small

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_scoreBar(int score, int maxScore) =>
    int clamped = math.max(0, math.min(score, maxScore))
    "[" + str.repeat("#", clamped) + str.repeat("-", maxScore - clamped) + "]"

// ============================================================================
// 1. Price Action: Deeper Structure Logic
// ============================================================================
atr = ta.atr(14)
priceRange = math.max(high - low, syminfo.mintick)
bodyPct = math.abs(close - open) / priceRange * 100.0
activeHtf = htfMode == "Auto 3x" ? f_autoTripleTf() : customHtf

ph = ta.pivothigh(high, lookback, lookback)
pl = ta.pivotlow(low, lookback, lookback)

var float lastPh = na
var float lastPl = na
var float lastHtfPh = na
var float lastHtfPl = na
var int trend = 0

if not na(ph)
    lastPh := ph
if not na(pl)
    lastPl := pl

bullMss = not na(lastPh) and close > lastPh and close[1] <= lastPh and close - lastPh > atr * mssAtrConfirm
bearMss = not na(lastPl) and close < lastPl and close[1] >= lastPl and lastPl - close > atr * mssAtrConfirm

if bullMss
    trend := 1
else if bearMss
    trend := -1
else
    trend := nz(trend[1], 0)

// ============================================================================
// 2. Volume Action: Internal Delta + Participation
// ============================================================================
avgVol = ta.sma(volume, volumeLookback)
relVol = avgVol > 0 ? volume / avgVol : 0.0
isVolumeSurprise = relVol >= volThresh

buyIntensity = (close - low) / priceRange * volume
sellIntensity = (high - close) / priceRange * volume
deltaFlow = ((buyIntensity - sellIntensity) / math.max(volume, 1)) * 100.0
deltaTrend = ta.ema(deltaFlow, deltaSmooth)

bullPressure = close > open and deltaFlow > 0 and deltaTrend > 0
bearPressure = close < open and deltaFlow < 0 and deltaTrend < 0

// ============================================================================
// 3. HTF Bias Engine
// ============================================================================
htfFast = request.security(syminfo.tickerid, activeHtf, ta.ema(hlc3, math.max(3, lookback)))
htfSlow = request.security(syminfo.tickerid, activeHtf, ta.ema(hlc3, math.max(6, lookback * 2)))
htfDelta = request.security(syminfo.tickerid, activeHtf, ta.ema(((close - low) / math.max(high - low, syminfo.mintick) * volume - (high - close) / math.max(high - low, syminfo.mintick) * volume) / math.max(volume, 1) * 100.0, deltaSmooth))
htfPh = request.security(syminfo.tickerid, activeHtf, ta.pivothigh(high, lookback, lookback))
htfPl = request.security(syminfo.tickerid, activeHtf, ta.pivotlow(low, lookback, lookback))
htfTrend = htfFast > htfSlow ? 1 : htfFast < htfSlow ? -1 : 0
htfBull = htfTrend >= 0 and htfDelta >= 0
htfBear = htfTrend <= 0 and htfDelta <= 0

if not na(htfPh)
    lastHtfPh := htfPh
if not na(htfPl)
    lastHtfPl := htfPl

// ============================================================================
// 4. Cloud Basis
// ============================================================================
fastFlow = ta.ema(hlc3, math.max(3, lookback))
slowFlow = ta.ema(hlc3, math.max(6, lookback * 2))
cloudBias = fastFlow > slowFlow ? 1 : fastFlow < slowFlow ? -1 : 0
midFlow = (fastFlow + slowFlow) * 0.5

// ============================================================================
// 5. Deep Catalyst Scoring
// ============================================================================
bullImpulse = bodyPct >= bodyImpulseMin and close > fastFlow
bearImpulse = bodyPct >= bodyImpulseMin and close < fastFlow
bullCloudAlign = fastFlow > slowFlow
bearCloudAlign = fastFlow < slowFlow
htfPassBull = not useHtfBias or htfBull
htfPassBear = not useHtfBias or htfBear

bullScore = (bullMss ? 2 : 0) + (isVolumeSurprise ? 1 : 0) + (bullPressure ? 1 : 0) + (bullImpulse ? 1 : 0) + (bullCloudAlign ? 1 : 0) + (htfPassBull ? 1 : 0)
bearScore = (bearMss ? 2 : 0) + (isVolumeSurprise ? 1 : 0) + (bearPressure ? 1 : 0) + (bearImpulse ? 1 : 0) + (bearCloudAlign ? 1 : 0) + (htfPassBear ? 1 : 0)

bullCatalyst = bullMss and htfPassBull and bullScore >= minCatalystScore
bearCatalyst = bearMss and htfPassBear and bearScore >= minCatalystScore
bullPrime = bullCatalyst and bullScore >= primeCatalystScore and relVol >= volThresh * 1.1 and bodyPct >= bodyImpulseMin + 5
bearPrime = bearCatalyst and bearScore >= primeCatalystScore and relVol >= volThresh * 1.1 and bodyPct >= bodyImpulseMin + 5
bullStandard = bullCatalyst and not bullPrime
bearStandard = bearCatalyst and not bearPrime

// ============================================================================
// 6. Cloud Design: Cleaner and More Premium
// ============================================================================
cloudColor = showHtfRibbon ? (cloudBias >= 0 ? (htfPassBull ? cloudBull : color.new(bullBase, 90)) : (htfPassBear ? cloudBear : color.new(bearBase, 90))) : cloudBias >= 0 ? cloudBull : cloudBear

fastPlot = plot(showCloud ? fastFlow : na, "Fast Flow", color = cloudBias >= 0 ? cloudLineBull : cloudLineBear, linewidth = 2)
slowPlot = plot(showCloud ? slowFlow : na, "Slow Flow", color = slowLineCss, linewidth = 1)
fill(fastPlot, slowPlot, cloudColor, "Delta Cloud")
plot(showCloud and showCloudMidline ? midFlow : na, "Cloud Midline", color = midLineCss, linewidth = 1)

// Optional minimalist structure rails
plot(showMiniLevels and trend >= 0 ? lastPh : na, "Bull Structure Rail", color = color.new(bullBase, 55), linewidth = 1, style = plot.style_linebr)
plot(showMiniLevels and trend <= 0 ? lastPl : na, "Bear Structure Rail", color = color.new(bearBase, 55), linewidth = 1, style = plot.style_linebr)
plot(showHtfStructure ? lastHtfPh : na, "HTF Bull Rail", color = color.new(bullBase, 75), linewidth = 1, style = plot.style_linebr)
plot(showHtfStructure ? lastHtfPl : na, "HTF Bear Rail", color = color.new(bearBase, 75), linewidth = 1, style = plot.style_linebr)

// ============================================================================
// 7. Visual Signals
// ============================================================================
barCss = trend == 1 ? (bullPrime ? color.new(bullBase, 0) : deltaTrend > 0 and htfPassBull ? color.new(bullBase, 12) : color.new(bullBase, 62)) : trend == -1 ? (bearPrime ? color.new(bearBase, 0) : deltaTrend < 0 and htfPassBear ? color.new(bearBase, 12) : color.new(bearBase, 62)) : color.new(neutralBase, 72)
barcolor(showBarColors ? barCss : na)

bgcolor(showSignalPulse ? bullPrime ? color.new(bullBase, 92) : bearPrime ? color.new(bearBase, 92) : bullStandard ? color.new(bullBase, 96) : bearStandard ? color.new(bearBase, 96) : na : na, title = "Catalyst Pulse")

plotshape(showSignals and not showPrimeOnly and bullStandard, "Bullish Standard Dot", shape.circle, location.belowbar, color.new(bullBase, 10), size = size.tiny)
plotshape(showSignals and not showPrimeOnly and bearStandard, "Bearish Standard Dot", shape.circle, location.abovebar, color.new(bearBase, 10), size = size.tiny)
plotshape(showSignals and bullPrime, "Bullish Prime Dot", shape.diamond, location.belowbar, color.new(bullBase, 0), size = size.small)
plotshape(showSignals and bearPrime, "Bearish Prime Dot", shape.diamond, location.abovebar, color.new(bearBase, 0), size = size.small)
plotshape(showSignals and not showPrimeOnly and bullStandard, "Bullish Standard Tag", shape.labelup, location.belowbar, color.new(bullBase, 10), text = "S+", textcolor = color.black, size = size.tiny)
plotshape(showSignals and not showPrimeOnly and bearStandard, "Bearish Standard Tag", shape.labeldown, location.abovebar, color.new(bearBase, 10), text = "S-", textcolor = color.white, size = size.tiny)
plotshape(showSignals and bullPrime, "Bullish Prime Tag", shape.labelup, location.belowbar, color.new(bullBase, 0), text = "P+", textcolor = color.black, size = size.tiny)
plotshape(showSignals and bearPrime, "Bearish Prime Tag", shape.labeldown, location.abovebar, color.new(bearBase, 0), text = "P-", textcolor = color.white, size = size.tiny)

plotchar(showScoreMarkers and bullCatalyst ? bullScore : na, "Bull Score", "", location.bottom, color.new(bullPrime ? bullBase : neutralBase, 0), size = size.tiny)
plotchar(showScoreMarkers and bearCatalyst ? bearScore : na, "Bear Score", "", location.top, color.new(bearPrime ? bearBase : neutralBase, 0), size = size.tiny)

// ============================================================================
// 8. HUD
// ============================================================================
var table hud = na

if barstate.islast
    if not na(hud)
        table.delete(hud)

    if showHud
        hud := table.new(f_getPos(hudPosition), 2, 7, bgcolor = hudBg, frame_color = hudBorder, frame_width = 1, border_color = hudBorder, border_width = 1)
        string textSize = f_getSize(hudSize)
        string structureArrow = trend > 0 ? "UP" : trend < 0 ? "DN" : "FLAT"
        string structureState = trend > 0 ? "Bullish" : trend < 0 ? "Bearish" : "Neutral"
        color structureColor = trend > 0 ? bullBase : trend < 0 ? bearBase : neutralBase
        string htfArrow = htfTrend > 0 ? "UP" : htfTrend < 0 ? "DN" : "FLAT"
        string htfState = htfTrend > 0 ? "Bullish" : htfTrend < 0 ? "Bearish" : "Neutral"
        color htfColor = htfTrend > 0 ? bullBase : htfTrend < 0 ? bearBase : neutralBase
        string catalystState = bullPrime ? "Prime Bull" : bearPrime ? "Prime Bear" : bullStandard ? "Std Bull" : bearStandard ? "Std Bear" : "Standby"
        color catalystColor = bullCatalyst ? bullBase : bearCatalyst ? bearBase : neutralBase
        int liveScore = bullCatalyst ? bullScore : bearCatalyst ? bearScore : math.max(bullScore, bearScore)
        string scoreBar = f_scoreBar(liveScore, 7)
        string deltaState = deltaTrend > 0 ? "Positive" : deltaTrend < 0 ? "Negative" : "Flat"
        color deltaColor = deltaTrend > 0 ? bullBase : deltaTrend < 0 ? bearBase : neutralBase

        table.cell(hud, 0, 0, "CATALYST", text_color = color.white, text_size = textSize, bgcolor = hudAccent, text_halign = text.align_center)
        table.cell(hud, 1, 0, activeHtf, text_color = color.white, text_size = textSize, bgcolor = hudAccent, text_halign = text.align_center)
        table.cell(hud, 0, 1, "Structure", text_color = color.white, text_size = textSize, text_halign = text.align_left)
        table.cell(hud, 1, 1, structureArrow + " " + structureState, text_color = structureColor, text_size = textSize, text_halign = text.align_right)
        table.cell(hud, 0, 2, "HTF Bias", text_color = color.white, text_size = textSize, text_halign = text.align_left)
        table.cell(hud, 1, 2, htfArrow + " " + htfState, text_color = htfColor, text_size = textSize, text_halign = text.align_right)
        table.cell(hud, 0, 3, "Catalyst", text_color = color.white, text_size = textSize, text_halign = text.align_left)
        table.cell(hud, 1, 3, catalystState, text_color = catalystColor, text_size = textSize, text_halign = text.align_right)
        table.cell(hud, 0, 4, "Score", text_color = color.white, text_size = textSize, text_halign = text.align_left)
        table.cell(hud, 1, 4, str.tostring(liveScore) + "/7 " + scoreBar, text_color = catalystColor, text_size = textSize, text_halign = text.align_right)
        table.cell(hud, 0, 5, "Rel Volume", text_color = color.white, text_size = textSize, text_halign = text.align_left)
        table.cell(hud, 1, 5, str.tostring(relVol, "#.##") + "x", text_color = relVol >= volThresh ? bullBase : neutralBase, text_size = textSize, text_halign = text.align_right)
        table.cell(hud, 0, 6, "Delta", text_color = color.white, text_size = textSize, text_halign = text.align_left)
        table.cell(hud, 1, 6, deltaState + " | " + str.tostring(deltaTrend, "#.0"), text_color = deltaColor, text_size = textSize, text_halign = text.align_right)

// ============================================================================
// 9. Alerts
// ============================================================================
newBullPrime = bullPrime and not bullPrime[1]
newBearPrime = bearPrime and not bearPrime[1]
newBullStandard = bullStandard and not bullStandard[1]
newBearStandard = bearStandard and not bearStandard[1]
newAnyCatalyst = (bullCatalyst or bearCatalyst) and not (bullCatalyst[1] or bearCatalyst[1])

alertcondition(newBullPrime, "Prime Bull Catalyst", "Prime Bull Catalyst detected on {{ticker}} | TF: {{interval}}")
alertcondition(newBearPrime, "Prime Bear Catalyst", "Prime Bear Catalyst detected on {{ticker}} | TF: {{interval}}")
alertcondition(newBullStandard, "Standard Bull Catalyst", "Standard Bull Catalyst detected on {{ticker}} | TF: {{interval}}")
alertcondition(newBearStandard, "Standard Bear Catalyst", "Standard Bear Catalyst detected on {{ticker}} | TF: {{interval}}")
alertcondition(newAnyCatalyst, "Any Catalyst Signal", "A Catalyst signal was detected on {{ticker}} | TF: {{interval}}")
````
