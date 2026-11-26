# Adaptive Momentum Strength Score (AMSS)

- url: https://www.tradingview.com/script/eWug1aTf-Adaptive-Momentum-Strength-Score-AMSS/
- type: indicator
- pine_id: PUB;8ba317fe4cdb4c3d90d647ee7cb71076
- version: 1.0

## Description

There is a specific kind of frustration that every serious trader knows.
The setup looks right. The candle closes with conviction. The oscillator confirms. You enter and the move immediately stalls, reverses, or dissolves into noise. Later you realize the volume was weak, volatility never truly expanded, or directional pressure had already started fading before the entry.
That frustration is not a discipline problem. It is an information problem.
Most momentum indicators measure one piece of the puzzle. RSI measures price velocity. Volume indicators measure participation. Bollinger Bands measure volatility state. Each tells part of the story. The Adaptive Momentum Strength Score was built on the conviction that momentum quality can only be evaluated meaningfully when several complementary market forces are read together, not after the fact, but simultaneously, on every bar.

[b]The Core Framework[/b]
The purpose of the composite score is straightforward: to answer not just whether price is moving, but whether the move is supported by the conditions that tend to give momentum its staying power.
The score is normalized between 0 and 100 and built from three independent components. The first measures candle impulse relative to ATR not raw candle size, but how decisive the current bar is in the context of what normal looks like for this asset right now. The second measures volume participation by comparing current volume against its moving average, distinguishing genuine momentum expansion from the kind of low-participation drift that precedes failed breakouts far more often than it precedes continuation. The third measures volatility expansion through Bollinger Band width relative to its own average, detecting the transition from compression into expansion as a market begins releasing stored energy.
Each component is independently normalized before combining. By default, volume participation carries the greatest weight of the three — a deliberate choice reflecting the observation that genuine participation tends to be the most reliable differentiator between momentum that follows through and momentum that fades. Candle impulse and volatility expansion carry equal secondary weight, acknowledging that decisive price movement and volatility expansion both contribute meaningfully to momentum quality without either being treated as a primary condition on its own. All weights remain fully adjustable for traders who prefer a different emphasis across different assets or timeframes.
What separates this framework from most traditional oscillators is that momentum strength, directional pressure, market regime, momentum acceleration, and signal confirmation are kept as independent layers that work together while remaining individually interpretable. The goal is not to compress everything into a single binary output but to provide a structured view of how momentum is developing and whether broader conditions are genuinely supportive.

[b]Adaptive Thresholds[/b]
A composite score is only as useful as the threshold that determines when it becomes meaningful.
The indicator supports two threshold modes. Fixed mode works cleanly in stable trending environments where volatility expression is consistent. Adaptive mode the recommended default calculates the threshold dynamically using rolling score averages and standard deviation scaling, then clamps it within a defined range. As market character shifts, the threshold recalibrates automatically rather than forcing traders to manually adjust a static level every time volatility conditions change.
The practical consequence is worth understanding directly. In a static-threshold oscillator, a compression phase floods the chart with false crossovers while a genuine expansion phase can produce delayed or missed signals. The adaptive threshold adjusts to both conditions without intervention. The active level is always displayed as the orange reference line, there is never ambiguity about where the signal boundary sits.
The score is additionally classified into Weak, Moderate, and Strong states relative to the active threshold, allowing momentum quality to be evaluated quickly without relying on raw numerical values alone.

[b]Directional Pressure[/b]
The score measures momentum magnitude. Direction is handled through a completely separate layer.
Directional bias is established through a two-part confirmation test on every bar. Price must sit on the correct side of a short-period directional EMA, and the average ATR-normalized candle direction over the recent lookback must clear a pressure threshold, meaning a single extended wick or isolated candle cannot flip the directional label on its own. The result is a three-state classification that updates in real time: Bullish, Bearish, or Neutral. This label colors the score line and feeds directly into the signal confirmation logic.

[b]Regime Classification[/b]
Not all momentum signals carry equal weight. A score crossover during an expanding market is a categorically different event from the same crossover inside a compressed, coiling environment and treating them identically is one of the more common ways momentum-based approaches produce inconsistent results.
The indicator measures the range of the score over a lookback window and classifies conditions into three states. Compressed means the score has been operating within a narrow band, the market is coiling, energy may be building, and momentum signals in this state generally exhibit lower follow-through and greater variability, although strong expansions can emerge from prolonged compression. Balanced reflects normal trending or ranging conditions. Expanding means the score range has broken above the expansion threshold the market is releasing energy, and momentum signals carry stronger continuation characteristics during this state.
Regime classification can be applied as a filter to triangle signals or used purely as context within the dashboard.
https://www.tradingview.com/x/LLzFgzHO/
[b]Momentum Velocity[/b]
Knowing where the score is tells you the current momentum level. Knowing how fast it is changing tells you something more useful, where momentum is likely heading before price makes it obvious.
The velocity engine calculates the rate of change of the score relative to its own standard deviation, producing a normalized reading that classifies momentum as Accelerating, Decelerating, or Flat. When the score is rising rapidly against its recent volatility baseline, conditions are classified as Accelerating. When the score is fading even if it remains above the threshold the label shifts to Decelerating, and the score line renders at reduced opacity as a visual signal that underlying momentum may be exhausting before price visibly reacts.
For traders who have held into momentum reversals that showed no obvious price-level warning, this layer provides an early internal warning signal within the indicator's architecture that conditions are beginning to shift.
https://www.tradingview.com/x/9yY3VgaF/
[b]Two Signal Tiers[/b]
The indicator produces signals on two distinct levels, and the distinction between them is worth understanding precisely.
Threshold dots appear whenever the score crosses the active threshold while directional pressure is already aligned. They are intentionally sensitive as early directional momentum awareness signals indicating that conditions are beginning to strengthen, even though the broader filter stack may not yet be confirmed. Experienced traders use them to shift attention and begin evaluating whether a fuller setup is developing.
Triangle signals are the fully confirmed output. A triangle only appears when the score crosses the threshold, directional pressure agrees, and every enabled filter in the active gate stack also confirms simultaneously. This is not a smoothed version of the dot signal. It is a categorically different signal type representing the convergence of multiple independent conditions at the same moment.
The separation is deliberate. Dots keep traders informed of developing momentum. Triangles reserve the strongest visual output for the moments that genuinely earn it.
The Signal Gate Stack
Before any triangle reaches the chart it passes through up to four independent gates, stackable in any combination.
The current-timeframe EMA filter blocks signals running counter to local trend structure. The higher-timeframe EMA filter adds a structural second opinion from a broader timeframe,  4-hour by default with an option to use only confirmed closed bars to avoid incomplete higher-timeframe calculations. The regime filter restricts signals during compressed conditions or limits them to expanding phases only. The cooldown gate enforces a minimum bar gap between consecutive signals, suppressing the cluster of repeat triggers that commonly fire around a single momentum event and dilute signal quality.
The dashboard always displays exactly which gates are active. Traders never need to guess why a triangle did or did not appear, the filter logic is visible at all times.

[b]Reading the Indicator: A Practical Workflow[/b]
1.[b]	Assess market regime first[/b]. Check the Info Table before anything else. Compressed conditions mean the score has been coiling in a tight range crossovers here often require greater selectivity, as follow-through tends to be less reliable until expansion begins, and participation should be approached more selectively. Expanding conditions deserve closer attention, as momentum signals generally carry stronger continuation characteristics during these phases.

2.	[b]Verify directional alignment. [/b]Confirm that the score line color and the Direction label in the dashboard match your intended trade direction. A technically valid score crossover against prevailing directional pressure is a lower-quality setup by design.

3.	[b]Watch for the threshold dot on the score pane[/b]. A small circle plots on the score line the moment momentum crosses the active threshold while directional pressure is already aligned. This is your early awareness signal. It means conditions are beginning to strengthen, but the broader confirmation stack may not yet be complete. Use it to shift attention to the price chart, not necessarily to trigger execution.

4.	[b]Wait for the triangle on the price chart[/b]. The triangle is the confirmed execution signal. It only appears when the score has crossed the threshold, directional pressure agrees, and every enabled gate in your active filter stack has confirmed simultaneously. Depending on your settings, this may include EMA alignment, regime validation, and cooldown logic. No triangle means at least one required condition has not been met, regardless of how the score looks in the pane below.

5.	[b]Check momentum velocity before entry.[/b] An Accelerating label at the point of the triangle adds meaningful weight to the setup. A Decelerating label on an otherwise valid triangle is a caution not necessarily a reason to avoid the trade, but a reminder that momentum quality may be less aggressive, follow-through may develop more gradually, or reversal risk may be beginning to increase.

6.	[b]Manage the trade with velocity as context, not as a standalone exit signal[/b]. If the score remains above or near the threshold but the line has dimmed signaling Decelerating momentum the move may be losing force even while price continues in the same direction. This does not automatically invalidate the trade or imply immediate exit. Instead, use velocity as an additional layer of context alongside price structure, trend conditions, and your existing risk-management framework.
https://www.tradingview.com/x/gEPiRwHL/
[b]What This Indicator Is Designed For[/b]
The Adaptive Momentum Strength Score is not a standalone trading system and does not attempt to be one. It is a momentum context engine — a structured framework for evaluating whether the conditions behind a price move reflect genuine strength and participation or whether they represent the kind of isolated, low-quality momentum that tends to produce less reliable continuation.
Every design decision in this script traces back to a single conviction: durable edge in trading does not come from reacting faster to a single signal. It comes from reading multiple independent market forces simultaneously and acting only when they converge. That is what this indicator was built to do and that is the only thing it claims to do well.

My Scripts/Indicators/Systems are for educational purposes only!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ScriptoPro

//@version=6
indicator("Adaptive Momentum Strength Score (AMSS)", overlay = false)

//════════════════════════════════════════════
// INPUTS
//════════════════════════════════════════════
grpCore = "Core Settings"
lenATR    = input.int(14, "ATR Length", minval = 1, group = grpCore)
lenVolSMA = input.int(20, "Volume SMA Length", minval = 1, group = grpCore)
lenBB     = input.int(20, "BB Length", minval = 1, group = grpCore)
bbMult    = input.float(2.0, "BB StdDev", minval = 0.1, step = 0.1, group = grpCore)
smoothLen = input.int(3, "Score Smoothing", minval = 1, group = grpCore)

grpThresh = "Threshold Settings"
thresholdMode = input.string("Adaptive", "Threshold Mode", options = ["Fixed", "Adaptive"], group = grpThresh)
scoreThresh   = input.float(35.0, "Fixed Threshold", minval = 0, maxval = 100, group = grpThresh)
adaptiveLen   = input.int(50, "Adaptive Threshold Length", minval = 5, group = grpThresh)
adaptiveMult  = input.float(0.5, "Adaptive StdDev Multiplier", minval = 0.0, step = 0.1, group = grpThresh)

grpWeights = "Weights"
wImpulse = input.float(1.5, "Weight: Impulse", minval = 0.0, group = grpWeights)
wVolume  = input.float(2.0, "Weight: Volume Spike", minval = 0.0, group = grpWeights)
wVolExp  = input.float(1.5, "Weight: Volatility Expansion", minval = 0.0, group = grpWeights)

grpComponents = "Component Display"
componentView = input.string("Off", "Show Component", options = ["Off", "All", "Impulse", "Volume Spike", "Volatility Expansion"], group = grpComponents)

grpVelocity = "Score Velocity"
velocityLookback = input.int(3, "Velocity Lookback", minval = 1, group = grpVelocity)
velocityLen      = input.int(20, "Velocity Normalization Length", minval = 5, group = grpVelocity)
velocityThresh   = input.float(0.5, "Velocity Threshold", minval = 0.1, step = 0.1, group = grpVelocity)

grpVisual = "Visuals"
showTable       = input.bool(true, "Show Info Table", group = grpVisual)
tableMode       = input.string("Full", "Table Mode", options = ["Full", "Compact"], group = grpVisual)
tablePosIn      = input.string("Top Right", "Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpVisual)
tableTextSizeIn = input.string("Small", "Table Text Size", options = ["Tiny", "Small", "Normal"], group = grpVisual)
showZones       = input.bool(true, "Show Strength Zones", group = grpVisual)
showBgShade     = input.bool(false, "Background Trend Shade", group = grpVisual)
lineWidth       = input.int(1, "Score Line Width", minval = 1, maxval = 4, group = grpVisual)
showChartTris   = input.bool(true, "Show Chart Triangles", group = grpVisual)
triSizeIn       = input.string("Tiny", "Triangle Size", options = ["Tiny", "Small", "Normal"], group = grpVisual)

grpDir = "Direction Settings"
dirEmaLen = input.int(10, "Direction EMA Length", minval = 1, group = grpDir)
dirLen    = input.int(5, "Pressure Lookback", minval = 3, group = grpDir)
dirThresh = input.float(0.2, "Pressure Threshold ATR", minval = 0.0, step = 0.05, group = grpDir)

grpFilter = "EMA Filter"
emaFilterMode   = input.string("TF EMA", "Triangle EMA Filter", options = ["Off", "TF EMA", "HTF EMA", "TF + HTF EMA"], group = grpFilter)
emaLenFilter    = input.int(200, "EMA Length", minval = 1, group = grpFilter)
emaTF           = input.timeframe("240", "HTF EMA TF", group = grpFilter)
confirmedHTFema = input.bool(true, "Use Confirmed HTF EMA", group = grpFilter)

grpRegime = "Regime Classification"
regimeLen        = input.int(20, "Regime Lookback", minval = 5, group = grpRegime)
compressedLevel  = input.float(15.0, "Compressed Below", minval = 1, group = grpRegime)
expandingLevel   = input.float(35.0, "Expanding Above", minval = 1, group = grpRegime)
regimeSignalMode = input.string("Off", "Regime Filter For Triangles", options = ["Off", "Block Compressed", "Only Expanding"], group = grpRegime)

grpCooldown = "Signal Cooldown"
useCooldown  = input.bool(true, "Use Triangle Cooldown", group = grpCooldown)
cooldownBars = input.int(10, "Cooldown Bars", minval = 1, group = grpCooldown)

//════════════════════════════════════════════
// UI CONVERSIONS
//════════════════════════════════════════════
tablePos = switch tablePosIn
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

tableTextSize = switch tableTextSizeIn
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

//════════════════════════════════════════════
// COMPONENT 1 — IMPULSE
//════════════════════════════════════════════
body = math.abs(close - open)
atr  = ta.atr(lenATR)

bodyToATR       = atr != 0 ? body / atr : 0.0
maxImpulseRatio = 3.0
normImpulse     = math.min(bodyToATR, maxImpulseRatio) / maxImpulseRatio * 100.0

//════════════════════════════════════════════
// COMPONENT 2 — VOLUME SPIKE
//════════════════════════════════════════════
volSMA      = ta.sma(volume, lenVolSMA)
volRatio    = volSMA != 0 ? volume / volSMA : 0.0
maxVolRatio = 3.0
normVolume  = math.min(volRatio, maxVolRatio) / maxVolRatio * 100.0

//════════════════════════════════════════════
// COMPONENT 3 — VOLATILITY EXPANSION
//════════════════════════════════════════════
[bbUpper, bbBasis, bbLower] = ta.bb(close, lenBB, bbMult)

bbWidth       = bbBasis != 0 ? (bbUpper - bbLower) / bbBasis : 0.0
bbWidthSMA    = ta.sma(bbWidth, lenBB)
widthRatio    = bbWidthSMA != 0 ? bbWidth / bbWidthSMA : 0.0
maxWidthRatio = 3.0
normVolExp    = math.min(widthRatio, maxWidthRatio) / maxWidthRatio * 100.0

//════════════════════════════════════════════
// FINAL SCORE
//════════════════════════════════════════════
totalWeight = wImpulse + wVolume + wVolExp

rawScore = totalWeight > 0 ?
     (normImpulse * wImpulse +
      normVolume  * wVolume +
      normVolExp  * wVolExp) / totalWeight : 0.0

score = ta.sma(rawScore, smoothLen)

//════════════════════════════════════════════
// FIXED / ADAPTIVE THRESHOLD
//════════════════════════════════════════════
adaptiveThreshRaw = ta.sma(score, adaptiveLen) + ta.stdev(score, adaptiveLen) * adaptiveMult

adaptiveThresh = math.max(
     20.0,
     math.min(
         80.0,
         nz(adaptiveThreshRaw, scoreThresh)
     )
 )

activeThresh = thresholdMode == "Adaptive" ? adaptiveThresh : scoreThresh

//════════════════════════════════════════════
// REGIME CLASSIFICATION
//════════════════════════════════════════════
scoreRange = ta.highest(score, regimeLen) - ta.lowest(score, regimeLen)

compressed = scoreRange < compressedLevel
expanding  = scoreRange > expandingLevel

regimeTxt = compressed ? "Compressed" : expanding ? "Expanding" : "Balanced"

regimeSignalOK = switch regimeSignalMode
    "Off"              => true
    "Block Compressed" => not compressed
    "Only Expanding"   => expanding

//════════════════════════════════════════════
// DIRECTION — PER-BAR ATR NORMALIZED PRESSURE
//════════════════════════════════════════════
emaDir = ta.ema(close, dirEmaLen)

netPressure = 0.0
for i = 0 to dirLen - 1
    atrSafe = math.max(nz(atr[i]), syminfo.mintick)
    netPressure += (close[i] - open[i]) / atrSafe

avgPressure = netPressure / dirLen

bull = close > emaDir and avgPressure > dirThresh
bear = close < emaDir and avgPressure < -dirThresh

//════════════════════════════════════════════
// EMA FILTER
//════════════════════════════════════════════
tfEMA = ta.ema(close, emaLenFilter)

htfEMA = request.security(
     syminfo.tickerid,
     emaTF,
     confirmedHTFema ? ta.ema(close, emaLenFilter)[1] : ta.ema(close, emaLenFilter),
     lookahead = barmerge.lookahead_off)

bullTFok  = close > tfEMA
bearTFok  = close < tfEMA
bullHTFok = close > htfEMA
bearHTFok = close < htfEMA

bullFilterOK = switch emaFilterMode
    "Off"          => true
    "TF EMA"       => bullTFok
    "HTF EMA"      => bullHTFok
    "TF + HTF EMA" => bullTFok and bullHTFok

bearFilterOK = switch emaFilterMode
    "Off"          => true
    "TF EMA"       => bearTFok
    "HTF EMA"      => bearHTFok
    "TF + HTF EMA" => bearTFok and bearHTFok

//════════════════════════════════════════════
// SIGNAL FILTER TEXT
//════════════════════════════════════════════
emaGateTxt = switch emaFilterMode
    "Off"          => ""
    "TF EMA"       => "TF EMA"
    "HTF EMA"      => "HTF EMA"
    "TF + HTF EMA" => "TF+HTF"

regGateTxt = switch regimeSignalMode
    "Off"              => ""
    "Block Compressed" => "Reg"
    "Only Expanding"   => "Exp"

cdGateTxt = useCooldown ? "CD" : ""

filterParts = array.new_string()

if emaGateTxt != ""
    array.push(filterParts, emaGateTxt)

if regGateTxt != ""
    array.push(filterParts, regGateTxt)

if cdGateTxt != ""
    array.push(filterParts, cdGateTxt)

signalFilterTxt = array.size(filterParts) == 0 ? "None" : array.join(filterParts, " + ")

//════════════════════════════════════════════
// SCORE-VOLATILITY NORMALIZED VELOCITY
//════════════════════════════════════════════
scoreVolatility = math.max(ta.stdev(score, velocityLen), 0.1)
scoreVelocity   = (score - score[velocityLookback]) / scoreVolatility

accelerating = scoreVelocity > velocityThresh
decelerating = scoreVelocity < -velocityThresh

momTxt = accelerating ? "Accelerating" : decelerating ? "Decelerating" : "Flat"

//════════════════════════════════════════════
// ADAPTIVE SCORE STATE
//════════════════════════════════════════════
strong = score >= activeThresh

scoreState =
     score >= activeThresh ? "Strong" :
     score >= activeThresh * 0.75 ? "Moderate" :
     "Weak"

dirTxt    = bull ? "Bullish" : bear ? "Bearish" : "Neutral"
threshTxt = thresholdMode == "Adaptive" ? "Adaptive" : "Fixed"

//════════════════════════════════════════════
// COLORS
//════════════════════════════════════════════
bullStrong = color.rgb(21, 246, 137)
bullWeak   = color.new(color.lime, 60)

bearStrong = color.rgb(241, 86, 86)
bearWeak   = color.new(color.red, 60)

neutralStrong = color.gray
neutralWeak   = color.new(color.gray, 65)

baseColor = bull ? (strong ? bullStrong : bullWeak) : bear ? (strong ? bearStrong : bearWeak) : (strong ? neutralStrong : neutralWeak)
lineColor = decelerating ? color.new(baseColor, 35) : baseColor

bgCol = showBgShade ?
     bull and strong ? color.new(bullStrong, 92) :
     bear and strong ? color.new(bearStrong, 92) :
     na : na

bgcolor(bgCol)

//════════════════════════════════════════════
// ZONES
//════════════════════════════════════════════
z20 = plot(showZones ? 20 : na, "Zone 20 Low", color = color.new(color.gray, 88), linewidth = 1)
z40 = plot(showZones ? 40 : na, "Zone 40 Medium", color = color.new(color.gray, 82), linewidth = 1)
z60 = plot(showZones ? 60 : na, "Zone 60 Strong", color = color.new(color.gray, 76), linewidth = 1)
z80 = plot(showZones ? 80 : na, "Zone 80 Extreme", color = color.new(color.gray, 70), linewidth = 1)

fill(z20, z40, color.new(color.gray, 96))
fill(z40, z60, color.new(color.gray, 94))
fill(z60, z80, color.new(color.gray, 92))

plot(activeThresh, "Active Threshold", color = color.orange, linewidth = 2)

//════════════════════════════════════════════
// MAIN PLOTS
//════════════════════════════════════════════
plot(score, "Momentum Score", color = lineColor, linewidth = lineWidth)

showImpulse = componentView == "All" or componentView == "Impulse"
showVolume  = componentView == "All" or componentView == "Volume Spike"
showVolExp  = componentView == "All" or componentView == "Volatility Expansion"

plot(showImpulse ? normImpulse : na, "Impulse Component", color = color.rgb(13, 28, 240), linewidth = 1)
plot(showVolume ? normVolume : na, "Volume Spike Component", color = color.purple, linewidth = 1)
plot(showVolExp ? normVolExp : na, "Volatility Expansion Component", color = color.rgb(7, 224, 239), linewidth = 1)

//════════════════════════════════════════════
// TRIANGLE SIGNALS + COOLDOWN + REGIME FILTER
//════════════════════════════════════════════
bullTrigDot = bull and ta.crossover(score, activeThresh)
bearTrigDot = bear and ta.crossover(score, activeThresh)

bullBaseTri = bullTrigDot and bullFilterOK and regimeSignalOK
bearBaseTri = bearTrigDot and bearFilterOK and regimeSignalOK

var int lastTriBar = na
cooldownOK = not useCooldown or na(lastTriBar) or bar_index - lastTriBar >= cooldownBars

bullTrigTri = bullBaseTri and cooldownOK
bearTrigTri = bearBaseTri and cooldownOK

if bullTrigTri or bearTrigTri
    lastTriBar := bar_index

plotshape(bullTrigDot ? score : na, title = "Bull Threshold Trigger", style = shape.circle, location = location.absolute, size = size.tiny, color = bullStrong)
plotshape(bearTrigDot ? score : na, title = "Bear Threshold Trigger", style = shape.circle, location = location.absolute, size = size.tiny, color = bearStrong)

plotshape(showChartTris and bullTrigTri and triSizeIn == "Tiny", title = "Bull Chart Triangle Tiny", style = shape.triangleup, location = location.belowbar, color = bullStrong, size = size.tiny, force_overlay = true)
plotshape(showChartTris and bullTrigTri and triSizeIn == "Small", title = "Bull Chart Triangle Small", style = shape.triangleup, location = location.belowbar, color = bullStrong, size = size.small, force_overlay = true)
plotshape(showChartTris and bullTrigTri and triSizeIn == "Normal", title = "Bull Chart Triangle Normal", style = shape.triangleup, location = location.belowbar, color = bullStrong, size = size.normal, force_overlay = true)

plotshape(showChartTris and bearTrigTri and triSizeIn == "Tiny", title = "Bear Chart Triangle Tiny", style = shape.triangledown, location = location.abovebar, color = bearStrong, size = size.tiny, force_overlay = true)
plotshape(showChartTris and bearTrigTri and triSizeIn == "Small", title = "Bear Chart Triangle Small", style = shape.triangledown, location = location.abovebar, color = bearStrong, size = size.small, force_overlay = true)
plotshape(showChartTris and bearTrigTri and triSizeIn == "Normal", title = "Bear Chart Triangle Normal", style = shape.triangledown, location = location.abovebar, color = bearStrong, size = size.normal, force_overlay = true)

//════════════════════════════════════════════
// INFO TABLE
//════════════════════════════════════════════
var table t = table.new(tablePos, 2, 7, border_width = 1)

scoreCol  = score >= activeThresh ? color.lime : score >= activeThresh * 0.75 ? color.orange : color.silver
dirCol    = bull ? color.lime : bear ? color.red : color.silver
momCol    = accelerating ? color.lime : decelerating ? color.orange : color.silver
regimeCol = expanding ? color.lime : compressed ? color.orange : color.silver
gateCol   = signalFilterTxt == "None" ? color.silver : color.lime
threshCol = thresholdMode == "Adaptive" ? color.aqua : color.orange

cellBgHdr = color.new(color.black, 0)
cellBgVal = color.new(color.black, 10)

scoreCompactTxt =
     str.tostring(score, "#.0") +
     (score >= activeThresh ? " > " : " < ") +
     str.tostring(activeThresh, "#.0")

if barstate.islast
    table.clear(t, 0, 0, 1, 6)

    if showTable
        if tableMode == "Compact"
            table.cell(t, 0, 0, "Score", text_color = color.white, bgcolor = cellBgHdr, text_size = tableTextSize)
            table.cell(t, 1, 0, scoreCompactTxt, text_color = scoreCol, bgcolor = cellBgVal, text_size = tableTextSize)

            table.cell(t, 0, 1, "Direction", text_color = color.white, bgcolor = cellBgHdr, text_size = tableTextSize)
            table.cell(t, 1, 1, dirTxt, text_color = dirCol, bgcolor = cellBgVal, text_size = tableTextSize)

            table.cell(t, 0, 2, "Regime", text_color = color.white, bgcolor = cellBgHdr, text_size = tableTextSize)
            table.cell(t, 1, 2, regimeTxt, text_color = regimeCol, bgcolor = cellBgVal, text_size = tableTextSize)

            table.cell(t, 0, 3, "Signal Filter", text_color = color.white, bgcolor = cellBgHdr, text_size = tableTextSize)
            table.cell(t, 1, 3, signalFilterTxt, text_color = gateCol, bgcolor = cellBgVal, text_size = tableTextSize)

        else
            table.cell(t, 0, 0, "Score", text_color = color.white, bgcolor = cellBgHdr, text_size = tableTextSize)
            table.cell(t, 1, 0, str.tostring(score, "#.0"), text_color = scoreCol, bgcolor = cellBgVal, text_size = tableTextSize)

            table.cell(t, 0, 1, "Strength", text_color = color.white, bgcolor = cellBgHdr, text_size = tableTextSize)
            table.cell(t, 1, 1, scoreState, text_color = scoreCol, bgcolor = cellBgVal, text_size = tableTextSize)

            table.cell(t, 0, 2, "Direction", text_color = color.white, bgcolor = cellBgHdr, text_size = tableTextSize)
            table.cell(t, 1, 2, dirTxt, text_color = dirCol, bgcolor = cellBgVal, text_size = tableTextSize)

            table.cell(t, 0, 3, "Momentum", text_color = color.white, bgcolor = cellBgHdr, text_size = tableTextSize)
            table.cell(t, 1, 3, momTxt, text_color = momCol, bgcolor = cellBgVal, text_size = tableTextSize)

            table.cell(t, 0, 4, "Regime", text_color = color.white, bgcolor = cellBgHdr, text_size = tableTextSize)
            table.cell(t, 1, 4, regimeTxt, text_color = regimeCol, bgcolor = cellBgVal, text_size = tableTextSize)

            table.cell(t, 0, 5, "Threshold", text_color = color.white, bgcolor = cellBgHdr, text_size = tableTextSize)
            table.cell(t, 1, 5, threshTxt + " " + str.tostring(activeThresh, "#.0"), text_color = threshCol, bgcolor = cellBgVal, text_size = tableTextSize)

            table.cell(t, 0, 6, "Signal Filter", text_color = color.white, bgcolor = cellBgHdr, text_size = tableTextSize)
            table.cell(t, 1, 6, signalFilterTxt, text_color = gateCol, bgcolor = cellBgVal, text_size = tableTextSize)

//════════════════════════════════════════════
// ALERT CONDITIONS
//════════════════════════════════════════════
anyTrig = bullTrigTri or bearTrigTri

alertcondition(anyTrig, title = "Momentum Signal", message = "Momentum Signal: Bullish or Bearish momentum threshold setup detected")
alertcondition(bullTrigTri, title = "Bullish Momentum Signal", message = "Bullish Momentum: Score crossed active threshold with bullish pressure and filters confirmed")
alertcondition(bearTrigTri, title = "Bearish Momentum Signal", message = "Bearish Momentum: Score crossed active threshold with bearish pressure and filters confirmed")
````
