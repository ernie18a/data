# Squeeze Momentum Nexus

- url: https://www.tradingview.com/script/QTqGlrYc-Squeeze-Momentum-Nexus/
- type: indicator
- pine_id: PUB;10b66ab38c894d6895fd4781a3551c6e
- version: 1.0

## Description

Squeeze Momentum Nexus

A market state engine designed around volatility compression, momentum expansion, efficiency, and higher-timeframe confirmation.

Traditional squeeze indicators focus primarily on volatility contraction and expansion. Squeeze Momentum Nexus expands on that concept by translating market conditions into a complete decision framework designed to answer:

• Is energy building?
• Has expansion begun?
• Is momentum strengthening or weakening?
• Does the higher timeframe agree?
• Is trend supporting the move?
• Is current price action efficient or noisy?

Features

Volatility Compression Detection

Identifies squeeze conditions using Bollinger Bands and Keltner Channels
Detects transitions between compression and expansion phases
Helps visualize when market energy is building or releasing

Momentum Expansion Engine

Uses smoothed momentum calculations to evaluate directional pressure
Momentum acceleration and deceleration coloring
Distinguishes strengthening versus weakening movement

Efficiency Ratio Analysis

Measures trend quality relative to noise
Helps identify whether price movement is efficient or choppy
Provides additional confirmation during expansion phases

Higher Timeframe Alignment

Optional higher timeframe confirmation
Compares local conditions against broader market direction
Helps align setups with larger market pressure

Trend Confirmation

EMA-based trend filtering
Identifies whether price is trading with or against directional bias
Decision Dashboard

Squeeze Momentum Nexus converts multiple inputs into a simplified market interpretation system.

Includes:

• Market State analysis
• Signal Strength meter
• Trade Quality grading
• Volatility state classification
• Expected behavior interpretation
• Confirmation panel
• Next-action guidance

Market States

Bullish Expansion

Momentum and directional pressure strengthening

Bearish Expansion

Downside momentum increasing with confirmation

Compression Building

Volatility contracting and energy accumulating

Neutral / No Edge

Mixed or lower-quality conditions
Expected Behavior Examples

Examples may include:

• Bullish bias favored
• Bearish bias favored
• Momentum expanding
• Pullback risk increasing
• Continuation quality improving
• Choppiness present

Confirmation Panel

Displays current conditions for:

• Momentum
• Higher timeframe direction
• Trend alignment
• Efficiency state

Suggested Uses

Can be combined with:

• Market structure
• Supply and demand zones
• Liquidity sweeps
• Volume Profile / POC analysis
• Higher timeframe bias
• Risk management systems

About TrendGenY Indicators

[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=5
indicator("TrendGenY Squeeze Momentum Nexus", shorttitle="TGY SQZ Nexus", overlay=false, max_labels_count=500)

//────────────────────────────
// Inputs
//────────────────────────────
src = input.source(close, "Source")

gSqz = "Squeeze Settings"
bbLen   = input.int(20, "BB Length", group=gSqz)
bbMult  = input.float(2.0, "BB Mult", group=gSqz)
kcLen   = input.int(20, "KC Length", group=gSqz)
kcMult  = input.float(1.5, "KC Mult", group=gSqz)
useTR   = input.bool(true, "Use True Range for KC", group=gSqz)

gMom = "Momentum Engine"
momLen = input.int(20, "Momentum Length", group=gMom)
smoothLen = input.int(5, "Momentum Smoothing", group=gMom)
useEMAFilter = input.bool(true, "Use EMA Trend Filter", group=gMom)
emaLen = input.int(50, "EMA Length", group=gMom)

gEff = "Efficiency Filter"
useEfficiency = input.bool(true, "Use Efficiency Confirmation", group=gEff)
erLen = input.int(20, "Efficiency Length", group=gEff)
erThreshold = input.float(0.35, "Efficiency Threshold", step=0.05, group=gEff)

gMTF = "Multi-Timeframe Confirmation"
useMTF = input.bool(true, "Use HTF Confirmation", group=gMTF)
htf = input.timeframe("60", "Higher Timeframe", group=gMTF)

gVisual = "Dashboard Visuals"
showTable = input.bool(true, "Show Decision Dashboard", group=gVisual)
tablePos = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=gVisual)
tableSize = input.string("Small", "Table Size", options=["Tiny", "Small", "Normal", "Large"], group=gVisual)

headerBg = input.color(color.black, "Header Background", group=gVisual)
headerText = input.color(color.white, "Header Text", group=gVisual)
labelBg = input.color(color.rgb(20, 24, 32), "Label Background", group=gVisual)
labelText = input.color(color.white, "Label Text", group=gVisual)
neutralBg = input.color(color.gray, "Neutral Background", group=gVisual)
neutralText = input.color(color.white, "Neutral Text", group=gVisual)

bullBg = input.color(color.lime, "Bullish Background", group=gVisual)
bearBg = input.color(color.red, "Bearish Background", group=gVisual)
warningBg = input.color(color.orange, "Warning Background", group=gVisual)
compressionBg = input.color(color.yellow, "Compression Background", group=gVisual)
expandedBg = input.color(color.aqua, "Expansion Background", group=gVisual)

bullText = input.color(color.black, "Bullish Text", group=gVisual)
bearText = input.color(color.white, "Bearish Text", group=gVisual)
warningText = input.color(color.black, "Warning Text", group=gVisual)

gPlot = "Plot Colors"
bullStrongColor = input.color(color.lime, "Bull Strong Momentum", group=gPlot)
bullWeakColor = input.color(color.green, "Bull Weakening Momentum", group=gPlot)
bearStrongColor = input.color(color.red, "Bear Strong Momentum", group=gPlot)
bearWeakColor = input.color(color.maroon, "Bear Weakening Momentum", group=gPlot)
zeroNeutralColor = input.color(color.blue, "Zero Neutral", group=gPlot)
zeroSqzColor = input.color(color.black, "Zero Squeeze On", group=gPlot)
zeroReleaseColor = input.color(color.gray, "Zero Released", group=gPlot)

//────────────────────────────
// Squeeze Function
//────────────────────────────
f_squeeze() =>
    basis = ta.sma(src, bbLen)
    dev = bbMult * ta.stdev(src, bbLen)
    upperBB = basis + dev
    lowerBB = basis - dev

    ma = ta.sma(src, kcLen)
    rng = useTR ? ta.tr(true) : high - low
    rangeMA = ta.sma(rng, kcLen)
    upperKC = ma + rangeMA * kcMult
    lowerKC = ma - rangeMA * kcMult

    sqzOn = lowerBB > lowerKC and upperBB < upperKC
    sqzOff = lowerBB < lowerKC and upperBB > upperKC
    noSqz = not sqzOn and not sqzOff

    bbWidth = upperBB - lowerBB
    kcWidth = upperKC - lowerKC
    compressionRatio = kcWidth != 0 ? bbWidth / kcWidth : na

    [sqzOn, sqzOff, noSqz, compressionRatio]

[sqzOn, sqzOff, noSqz, compressionRatio] = f_squeeze()

//────────────────────────────
// Momentum
//────────────────────────────
highestHigh = ta.highest(high, momLen)
lowestLow = ta.lowest(low, momLen)
midpoint = math.avg(highestHigh, lowestLow)
baseline = math.avg(midpoint, ta.sma(close, momLen))

rawMom = ta.linreg(src - baseline, momLen, 0)
mom = ta.ema(rawMom, smoothLen)

momUp = mom > mom[1]
momDown = mom < mom[1]

bullMom = mom > 0
bearMom = mom < 0

//────────────────────────────
// Efficiency
//────────────────────────────
directionalMove = math.abs(close - close[erLen])
volatilityMove = math.sum(math.abs(close - close[1]), erLen)
er = volatilityMove != 0 ? directionalMove / volatilityMove : 0
efficient = er >= erThreshold

//────────────────────────────
// Trend
//────────────────────────────
ema = ta.ema(close, emaLen)
trendBull = close > ema
trendBear = close < ema

//────────────────────────────
// HTF Momentum
//────────────────────────────
f_htfMom() =>
    hHigh = ta.highest(high, momLen)
    hLow = ta.lowest(low, momLen)
    hMid = math.avg(hHigh, hLow)
    hBase = math.avg(hMid, ta.sma(close, momLen))
    ta.ema(ta.linreg(close - hBase, momLen, 0), smoothLen)

htfMom = request.security(syminfo.tickerid, htf, f_htfMom(), barmerge.gaps_off, barmerge.lookahead_off)

htfBull = htfMom > 0
htfBear = htfMom < 0

//────────────────────────────
// State Logic
//────────────────────────────
release = sqzOn[1] and sqzOff

volState =
     sqzOn and compressionRatio <= 0.60 ? "Deep Compression" :
     sqzOn and compressionRatio <= 0.80 ? "Compression" :
     sqzOn ? "Light Compression" :
     compressionRatio > 1.30 ? "Expanded" :
     sqzOff ? "Released" :
     "Neutral"

bullExpansion = sqzOff and bullMom
bearExpansion = sqzOff and bearMom

momentumWeakening = bullMom and momDown or bearMom and momUp
momentumStrengthening = bullMom and momUp or bearMom and momDown

//────────────────────────────
// Weighted Score
//────────────────────────────
score = 0.0

score += sqzOff ? 20 : sqzOn ? 10 : 0
score += momentumStrengthening ? 25 : momentumWeakening ? 10 : 0
score += efficient ? 20 : 0
score += bullMom and htfBull or bearMom and htfBear ? 20 : 0
score += bullMom and trendBull or bearMom and trendBear ? 15 : 0

score := math.min(score, 100)

grade =
     score >= 85 ? "A+" :
     score >= 75 ? "A" :
     score >= 65 ? "B+" :
     score >= 55 ? "B" :
     score >= 45 ? "C" :
     "Avoid"

state =
     bullExpansion and momentumStrengthening ? "Bullish Expansion" :
     bullExpansion and momentumWeakening ? "Bullish Expansion Fading" :
     bearExpansion and momentumStrengthening ? "Bearish Expansion" :
     bearExpansion and momentumWeakening ? "Bearish Expansion Fading" :
     sqzOn ? "Compression Building" :
     "Neutral / No Edge"

stateBg =
     str.contains(state, "Bullish") and momentumStrengthening ? bullBg :
     str.contains(state, "Bearish") and momentumStrengthening ? bearBg :
     str.contains(state, "Fading") ? warningBg :
     sqzOn ? compressionBg :
     neutralBg

stateText =
     str.contains(state, "Bullish") ? bullText :
     str.contains(state, "Bearish") ? bearText :
     str.contains(state, "Fading") ? warningText :
     neutralText

//────────────────────────────
// Expected Behavior
//────────────────────────────
expected1 =
     str.contains(state, "Bullish") ? "✓ Bullish bias favored" :
     str.contains(state, "Bearish") ? "✓ Bearish bias favored" :
     sqzOn ? "✓ Energy building" :
     "✓ Wait for clearer signal"

expected2 =
     momentumStrengthening ? "✓ Momentum expanding" :
     momentumWeakening ? "✓ Momentum weakening" :
     "✓ Momentum neutral"

expected3 =
     momentumWeakening ? "✓ Pullback risk rising" :
     efficient ? "✓ Continuation quality improving" :
     "✓ Choppiness risk present"

//────────────────────────────
// Visuals
//────────────────────────────
momColor =
     mom > 0 and momUp ? bullStrongColor :
     mom > 0 and momDown ? bullWeakColor :
     mom < 0 and momDown ? bearStrongColor :
     mom < 0 and momUp ? bearWeakColor :
     neutralBg

zeroColor =
     sqzOn ? zeroSqzColor :
     sqzOff ? zeroReleaseColor :
     zeroNeutralColor

plot(mom, "Momentum", style=plot.style_histogram, linewidth=4, color=momColor)
plot(0, "Squeeze State", style=plot.style_cross, linewidth=3, color=zeroColor)
hline(0, "Zero Line", color=color.new(color.white, 80))

//────────────────────────────
// Dashboard Helpers
//────────────────────────────
txtSize =
     tableSize == "Tiny" ? size.tiny :
     tableSize == "Small" ? size.small :
     tableSize == "Normal" ? size.normal :
     size.large

pos =
     tablePos == "Top Left" ? position.top_left :
     tablePos == "Bottom Right" ? position.bottom_right :
     tablePos == "Bottom Left" ? position.bottom_left :
     position.top_right

meterBlocks = math.round(score / 10)
meter = ""
for i = 1 to 10
    meter += i <= meterBlocks ? "█" : "░"

momArrow = momentumStrengthening ? "⇊" : momentumWeakening ? "↓" : "→"
htfArrow = htfBull ? "↑" : htfBear ? "↓" : "→"
trendArrow = trendBull ? "↑" : trendBear ? "↓" : "→"
effArrow = er > er[1] ? "↑" : er < er[1] ? "↓" : "→"

//────────────────────────────
// Dashboard
//────────────────────────────
var table dash = table.new(pos, 2, 16, border_width=1)

biasValue =
     str.contains(state, "Bullish") ? "Bullish Favored" :
     str.contains(state, "Bearish") ? "Bearish Favored" :
     sqzOn ? "Waiting / Building" :
     "No Clear Edge"

biasBg =
     str.contains(biasValue, "Bullish") ? bullBg :
     str.contains(biasValue, "Bearish") ? bearBg :
     sqzOn ? compressionBg :
     neutralBg

momentumValue =
     momentumStrengthening ? "Expanding" :
     momentumWeakening ? "Weakening" :
     "Neutral"

momentumBg =
     momentumStrengthening ? stateBg :
     momentumWeakening ? warningBg :
     neutralBg

riskValue =
     er < erThreshold ? "Choppiness Present" :
     momentumWeakening ? "Pullback Risk Rising" :
     "Continuation Quality"

riskBg =
     er < erThreshold ? warningBg :
     momentumWeakening ? warningBg :
     bullBg

nextAction =
     score >= 75 and momentumStrengthening ? "Continuation Setup" :
     score >= 60 and momentumWeakening ? "Wait for Pullback" :
     sqzOn ? "Wait for Release" :
     "Wait for Clarity"

nextActionBg =
     score >= 75 and momentumStrengthening ? bullBg :
     score >= 60 and momentumWeakening ? warningBg :
     sqzOn ? compressionBg :
     neutralBg

momConfirm =
     bullMom ? "Bullish " + momArrow :
     bearMom ? "Bearish " + momArrow :
     "Neutral →"

momConfirmBg =
     bullMom ? bullBg :
     bearMom ? bearBg :
     neutralBg

htfConfirm =
     htfBull ? "Bullish ↑" :
     htfBear ? "Bearish ↓" :
     "Neutral →"

htfConfirmBg =
     htfBull ? bullBg :
     htfBear ? bearBg :
     neutralBg

trendConfirm =
     trendBull ? "Bullish ↑" :
     trendBear ? "Bearish ↓" :
     "Neutral →"

trendConfirmBg =
     trendBull ? bullBg :
     trendBear ? bearBg :
     neutralBg

effConfirm =
     efficient ? "Strong " + str.tostring(er, "#.##") :
     "Weak " + str.tostring(er, "#.##")

effConfirmBg =
     efficient ? bullBg :
     warningBg

if showTable and barstate.islast
    table.cell(dash, 0, 0, "SIGNAL", text_color=headerText, bgcolor=headerBg, text_size=txtSize)
    table.cell(dash, 1, 0, "STATUS", text_color=headerText, bgcolor=headerBg, text_size=txtSize)

    table.cell(dash, 0, 1, "MARKET STATE", text_color=labelText, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 1, state + " (" + str.tostring(score, "#") + "%)", text_color=stateText, bgcolor=stateBg, text_size=txtSize)

    table.cell(dash, 0, 2, "Signal Strength", text_color=labelText, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 2, meter + " " + str.tostring(score, "#") + "%", text_color=neutralText, bgcolor=neutralBg, text_size=txtSize)

    table.cell(dash, 0, 3, "Trade Quality", text_color=labelText, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 3, grade, text_color=stateText, bgcolor=stateBg, text_size=txtSize)

    table.cell(dash, 0, 4, "Volatility State", text_color=labelText, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 4, volState, text_color=neutralText, bgcolor=sqzOn ? compressionBg : compressionRatio > 1.30 ? expandedBg : neutralBg, text_size=txtSize)

    table.cell(dash, 0, 5, "EXPECTED BEHAVIOR", text_color=headerText, bgcolor=headerBg, text_size=txtSize)
    table.cell(dash, 1, 5, "", text_color=headerText, bgcolor=headerBg, text_size=txtSize)

    table.cell(dash, 0, 6, "Bias", text_color=labelText, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 6, biasValue, text_color=neutralText, bgcolor=biasBg, text_size=txtSize)

    table.cell(dash, 0, 7, "Momentum", text_color=labelText, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 7, momentumValue, text_color=neutralText, bgcolor=momentumBg, text_size=txtSize)

    table.cell(dash, 0, 8, "Risk", text_color=labelText, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 8, riskValue, text_color=neutralText, bgcolor=riskBg, text_size=txtSize)

    table.cell(dash, 0, 9, "Next Action", text_color=labelText, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 9, nextAction, text_color=neutralText, bgcolor=nextActionBg, text_size=txtSize)

    table.cell(dash, 0, 10, "CONFIRMATION", text_color=headerText, bgcolor=headerBg, text_size=txtSize)
    table.cell(dash, 1, 10, "", text_color=headerText, bgcolor=headerBg, text_size=txtSize)

    table.cell(dash, 0, 11, "Momentum", text_color=labelText, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 11, momConfirm, text_color=neutralText, bgcolor=momConfirmBg, text_size=txtSize)

    table.cell(dash, 0, 12, "HTF", text_color=labelText, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 12, htfConfirm, text_color=neutralText, bgcolor=htfConfirmBg, text_size=txtSize)

    table.cell(dash, 0, 13, "Trend", text_color=labelText, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 13, trendConfirm, text_color=neutralText, bgcolor=trendConfirmBg, text_size=txtSize)

    table.cell(dash, 0, 14, "Efficiency", text_color=labelText, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 14, effConfirm, text_color=neutralText, bgcolor=effConfirmBg, text_size=txtSize)

    table.cell(dash, 0, 15, "Compression", text_color=labelText, bgcolor=labelBg, text_size=txtSize)
    table.cell(dash, 1, 15, str.tostring(compressionRatio, "#.##"), text_color=neutralText, bgcolor=neutralBg, text_size=txtSize)

//────────────────────────────
// Alerts
//────────────────────────────
alertcondition(release, "Squeeze Released", "Squeeze has released.")
alertcondition(bullExpansion and momentumStrengthening, "Bullish Expansion", "Bullish squeeze expansion with strengthening momentum.")
alertcondition(bearExpansion and momentumStrengthening, "Bearish Expansion", "Bearish squeeze expansion with strengthening momentum.")
alertcondition(momentumWeakening, "Momentum Weakening", "Momentum is weakening after expansion.")
````
