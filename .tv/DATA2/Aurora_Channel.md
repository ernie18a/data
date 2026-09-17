<!-- tradingview-pine-id: PUB;03a11a08970d41cdb716e748ec5868a7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Aurora Channel 

Source: https://www.tradingview.com/script/FojCZ7FN-Aurora-Channel-V1/

## Description

█  Overview
The Aurora Channel is an adaptive multi-layer volatility and expansion framework that fuses Bollinger Bands, Keltner Channels, volume-sensitive dynamics, and intelligent moving-average selection into a single coherent system.
Instead of treating channels as static statistical boundaries, Aurora continuously evaluates market behavior, selects the most suitable moving-average engine in real time, expands or contracts outer envelopes according to volume and width regimes, and projects dynamic trigger and crossover levels that respond to actual price action.
The result is a hybrid channel system that blends:
• Adaptive MA selection (Auto / Adaptive Scoring)
• Volume-modulated Keltner expansion
• Hybrid Bollinger–Keltner “Aurora” bands
• Multi-layer expansion envelopes
• Peak-aware or dynamically tracking Trigger Channel
• Crossover Multiplier Engine with adaptive overlays
• Regime-aware visuals and a live Dashboard HUD
█ Why is this one unique
Most channel indicators are fixed formulas. Aurora is a full adaptive channel engine built in Pine Script v6.
It does not simply plot Bollinger or Keltner bands. It constructs a hybrid core, surrounds it with volume-aware expansion logic, maintains intelligent outer triggers, and generates dynamic crossover projection lines whose multiplier is itself adaptive.
⚪ What it does
At a high level:

Auto MA Selection Engine
Continuously scores SMA, EMA, RMA (SMMA), WMA, and VWMA candidates using a combined lag-error + jitter penalty. The engine automatically selects the MA with the lowest overall score (or lets the user force a manual choice). This becomes the center line for every subsequent calculation.
Hybrid Aurora Core
Builds classic Bollinger Bands and a volume-sensitive Keltner Channel around the selected midline. The Keltner multiplier dynamically expands between 3.0–4.0 during volume spikes. The difference between the two outer bands is then smoothed and re-applied, creating the final Aurora Upper / Lower bands.
Expansion Envelope
Measures the current Aurora width, smooths it, and projects outer envelope levels that react to both width expansion and tick-volume intensity. Optional “Breakouts Only” mode shows the envelope solely when price is already expanding beyond the Aurora bands.
Trigger Channel
Two memory modes:
• Dynamic Tracking – continuously follows expansion and decays when price returns inside.
• Hold Peak Level – latches the highest/lowest expansion extremes.
A proportional buffer is then added, creating clean outer trigger lines.
Crossover Multiplier Engine
Monitors crosses of a user-selected target (Midline, Aurora Bands, Envelope, or Trigger). On every cross it captures the current Keltner multiplier × volume ratio, latches that value, smooths it with the same adaptive MA engine, and projects symmetric overlay lines around the midline. These act as adaptive reaction / target levels.
Multi-Layer Clouds + Regime Visuals
Soft gradient fills between midline → Aurora and Aurora → Envelope, plus a softer fill toward the Trigger. Candles are colored by regime (above/below midline). A compact Dashboard HUD displays the active MA, cross target, current multiplier, expansion state, and regime.

⚪ Why it is good
The strongest aspect is the combination of adaptive center selection, volume-aware expansion, and quality-aware outer structures in one coherent framework.
Most channel tools are either pure statistical (Bollinger) or pure volatility (Keltner/ATR). Aurora merges both, then adds intelligent memory (Trigger modes) and a live crossover-driven multiplier engine. The visual hierarchy (multi-layer clouds) makes regime and expansion instantly readable, while the Dashboard keeps the key adaptive values visible without cluttering the chart.
⚪ What makes it sophisticated
• Real-time adaptive MA scoring with lag + jitter penalty

• Dynamic Keltner multiplier driven by volume ratio

• Hybrid band construction that re-injects smoothed BB–KC difference

• Dual-mode Trigger memory (peak hold vs continuous tracking + decay)

• Crossover-triggered multiplier latching and adaptive projection

• Multi-layer gradient fills that scale with the actual channel hierarchy

• Non-repainting alerts on confirmed crosses
⚪ Why It’s Marketable
Traders looking for more than a simple Bollinger or Keltner band receive a complete adaptive channel ecosystem. The Auto MA engine removes the endless debate of “which MA is best,” the Expansion Envelope and Trigger Channel give clear breakout and reaction zones, and the Crossover Multiplier Engine turns every significant cross into dynamic, volume-aware target lines. The result is a selective, visually rich, and highly configurable system that adapts to the instrument and timeframe instead of forcing a fixed formula onto every market.
⚪ Main weakness
The system is still rule-based adaptive logic, not deep learning. Performance depends on the chosen lengths, the quality of volume data (especially on tick-volume charts), and the current market regime. Over-optimization of the many parameters can reduce robustness.
█ How It Works
⚪ Auto MA Selection Engine

Scores five classic moving averages on tracking error (squared lag) plus a jitter penalty. The lowest combined score becomes the active center line used by every channel component.
⚪ Aurora Core Construction

• Midline = selected MA

• Bollinger = midline ± StdDev × multiplier

• Keltner = midline ± ATR × volume-modulated multiplier (3.0–4.0)

• Aurora bands = Keltner ± smoothed (BB – KC) difference
⚪ Expansion Envelope

Average Aurora width is multiplied by a base factor and further expanded by excess volume. The resulting offset is added outside the Aurora bands. Optional breakout-only plotting keeps the chart clean until genuine expansion occurs.
⚪ Trigger Channel

On expansion the system either latches the extreme (Hold Peak) or follows and slowly decays the level (Dynamic Tracking). A proportional buffer creates the final trigger lines.
⚪ Crossover Multiplier Engine

Detects crosses of the chosen target, captures kcMult × volRatio, latches the value, smooths it with the adaptive MA engine, and projects midline ± ATR × smoothed multiplier as dotted overlay lines.
█ How To Use
• Use the Aurora bands as the primary dynamic support/resistance zone.

• Watch the Expansion Envelope for genuine volatility breakouts.

• Treat the Trigger Channel as outer reaction / invalidation levels.

• The Crossover Multiplier lines act as adaptive targets or reaction zones after significant crosses.

• Candle color and the Dashboard HUD give instant regime and state information.

• Enable alerts on the crossover condition for automated notifications.
█ Settings
Auto MA Selection Engine

• MA Selection Engine (Auto Adaptive / Manual)

• Manual MA type

• Jitter Penalty strength
Core Channel Engine

• Base Center Length

• Bollinger StdDev multiplier

• Keltner ATR Length

• Tick Volume MA Length & Expansion Factor

• Band Difference MA Length
Expansion Envelope

• Show / Breakouts Only

• Expansion MA Length

• Envelope Base Multiplier & Volume Boost
Trigger Channel

• Show Trigger

• Buffer Multiplier

• Memory Mode (Dynamic Tracking / Hold Peak Level)
Crossover Multiplier Engine

• Show Dynamic Lines

• Cross Monitoring Target

• Multiplier MA Smoothing Length
Visual Settings

• Candle Coloring

• Multi-Layer Cloud

• Dashboard HUD

• Full color customization for every layer
█ Disclaimer
The content provided in this script is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. Past performance is not indicative of future results. All trading involves risk, and you are solely responsible for your own trading decisions.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
//@version=6
indicator('Aurora Channel ', overlay = true, max_bars_back = 2100, precision = 2)

// ~~ TOOLTIPS {
var string t1  = "AUTO MA SELECTION MODE\n\n'Auto (Adaptive Scoring)' dynamically evaluates SMA, EMA, WMA, RMA, and VWMA candidates, selecting the MA with the lowest combined tracking error and jitter penalty."
var string t2  = "BASE CENTER LENGTH\n\nThe lookback period for the primary center moving average anchoring Bollinger and Keltner channels."
var string t3  = "BOLLINGER BANDS MULTIPLIER\n\nStandard deviation multiplier for outer Bollinger Bands."
var string t4  = "ATR LENGTH\n\nLookback period for Average True Range used in Keltner Channel calculations."
var string t5  = "TICK VOLUME SENSITIVITY\n\nScales the Keltner expansion multiplier dynamically between 3.0 and 4.0 during volume spikes."
var string t6  = "BAND DIFFERENCE MA LENGTH\n\nLookback period for the Moving Average applied to outer band differences (BB vs KC)."
var string t7  = "ENVELOPE BASE MULTIPLIER\n\nBase width factor applied to the smoothed channel width to project outer envelope bounds."
var string t8  = "ENVELOPE VOLUME BOOST\n\nControls how strongly tick volume expansion pushes the envelope outward."
var string t9  = "TRIGGER BUFFER MULTIPLIER\n\nProportional width scalar determining the outer Trigger bounds."
var string t10 = "TRIGGER TRACKING MODE\n\n'Dynamic Tracking' updates continuously via Expansion MA; 'Hold Peak Level' latches maximum expansion levels."
var string t11 = "CROSSOVER MULTIPLIER ENGINE\n\nTracks band crosses and calculates a dynamic multiplier (Keltner Multiplier × Volume/Pattern Ratio). This product is smoothed by an MA to project adaptive overlay lines."
//}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ INPUTS {
// ~~ Auto MA Engine Settings {
maSelectMode = input.string("Auto (Adaptive AI)", 'MA Selection Engine', options = ["Auto (Adaptive AI)", "Manual Choice"], group = "Auto MA Selection Engine", tooltip = t1)
manualMaType = input.string("EMA", 'Manual MA Selection', options = ["EMA", "SMA", "SMMA (RMA)", "WMA", "VWMA"], group = "Auto MA Selection Engine", active = maSelectMode == "Manual Choice")
noisePenalty = input.float(1.5, 'Auto MA Jitter Penalty', minval = 0.1, maxval = 5.0, step = 0.1, group = "Auto MA Selection Engine", active = maSelectMode == "Auto (Adaptive AI)")
//}

// ~~ Core Channel Engine {
baseLen   = input.int(20, 'Base Center Length', minval = 1, group = "Core Channel Engine", tooltip = t2)
bbMult    = input.float(2.0, 'Bollinger Bands StdDev', minval = 0.1, step = 0.1, group = "Core Channel Engine", tooltip = t3)
atrLen    = input.int(14, 'Keltner ATR Length', minval = 1, group = "Core Channel Engine", tooltip = t4)
volLen    = input.int(20, 'Tick Volume MA Length', minval = 1, group = "Core Channel Engine")
volSens   = input.float(0.5, 'Volume Expansion Factor', minval = 0.0, step = 0.1, group = "Core Channel Engine", tooltip = t5)
diffMaLen = input.int(10, 'Band Diff MA Length', minval = 1, group = "Core Channel Engine", tooltip = t6)
//}

// ~~ Expansion Envelope {
showEnvelope   = input.bool(true, 'Show Expansion Envelope', inline = 'e1', group = "Expansion Envelope")
onlyOnBreakout = input.bool(false, 'Breakouts Only', inline = 'e1', group = "Expansion Envelope")
envLen         = input.int(14, 'Expansion MA Length', minval = 1, group = "Expansion Envelope")
envMult        = input.float(0.5, 'Envelope Base Multiplier', minval = 0.05, step = 0.05, group = "Expansion Envelope", tooltip = t7)
envVolSens     = input.float(0.6, 'Envelope Volume Boost', minval = 0.0, step = 0.1, group = "Expansion Envelope", tooltip = t8)
//}

// ~~ Trigger Channel {
showTrigger    = input.bool(true, 'Show Trigger Channel', group = "Trigger Channel")
trigBuffMult   = input.float(0.25, 'Trigger Buffer Multiplier', minval = 0.0, step = 0.05, group = "Trigger Channel", tooltip = t9)
trigTrackMode  = input.string("Dynamic Tracking", 'Trigger Memory Mode', options = ["Dynamic Tracking", "Hold Peak Level"], group = "Trigger Channel", tooltip = t10)
//}

// ~~ Crossover Multiplier Engine {
showCrossMA   = input.bool(true, 'Show Crossover Dynamic Lines', inline = 'cm', group = "Crossover Multiplier Engine", tooltip = t11)
crossTarget   = input.string("Aurora Bands", 'Cross Monitoring Target', options = ["Midline", "Aurora Bands", "Expansion Envelope", "Trigger Channel"], inline = 'cm', group = "Crossover Multiplier Engine")
crossMaLen    = input.int(14, 'Multiplier MA Smoothing Length', minval = 1, group = "Crossover Multiplier Engine")
//}

// ~~ Visual Settings {
paintBars = input.bool(true, 'Candle Coloring', inline = 'v1', group = "Visual Settings")
showCloud = input.bool(true, 'Multi-Layer Cloud', inline = 'v1', group = "Visual Settings")
showDash  = input.bool(true, 'Show Dashboard HUD', group = "Visual Settings")

// Colors
colUpper  = input.color(#E040FB, 'Upper', inline = 'col', group = "Colors")
colLower  = input.color(#00E5FF, 'Lower', inline = 'col', group = "Colors")
colEnv    = input.color(#FF9800, 'Envelope', inline = 'col2', group = "Colors")
colTrig   = input.color(#00B0FF, 'Trigger', inline = 'col2', group = "Colors")
colCross  = input.color(color.white, 'Crossover', inline = 'col2', group = "Colors")   // ← default black
colMid    = input.color(#FF00E5, 'Midline', inline = 'col2', group = "Colors")
//}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ HELPER FUNCTIONS & AUTO MA ENGINE {
f_scoreMA(float srcVal, float candVal, int len, float penalty) =>
    float lagError = ta.sma(math.pow(candVal - srcVal, 2), len)
    float jitter   = ta.sma(math.pow(ta.change(candVal), 2), len)
    lagError + (jitter * penalty)

f_autoSelectMA(float srcVal, int len, float pen, string manualType, bool isAuto) =>
    candSMA  = ta.sma(srcVal, len)
    candEMA  = ta.ema(srcVal, len)
    candRMA  = ta.rma(srcVal, len)
    candWMA  = ta.wma(srcVal, len)
    candVWMA = ta.vwma(srcVal, len)

    sSMA  = f_scoreMA(srcVal, candSMA, len, pen)
    sEMA  = f_scoreMA(srcVal, candEMA, len, pen)
    sRMA  = f_scoreMA(srcVal, candRMA, len, pen)
    sWMA  = f_scoreMA(srcVal, candWMA, len, pen)
    sVWMA = f_scoreMA(srcVal, candVWMA, len, pen)

    float selectedMA = candEMA
    string maName    = "EMA"

    if isAuto
        float minScore = sEMA
        selectedMA := candEMA
        maName     := "EMA"
        if sSMA < minScore
            minScore   := sSMA
            selectedMA := candSMA
            maName     := "SMA"
        if sWMA < minScore
            minScore   := sWMA
            selectedMA := candWMA
            maName     := "WMA"
        if sRMA < minScore
            minScore   := sRMA
            selectedMA := candRMA
            maName     := "RMA"
        if sVWMA < minScore
            minScore   := sVWMA
            selectedMA := candVWMA
            maName     := "VWMA"
    else
        selectedMA := switch manualType
            "SMA"        => candSMA
            "EMA"        => candEMA
            "SMMA (RMA)" => candRMA
            "WMA"        => candWMA
            "VWMA"       => candVWMA
            => candEMA
        maName := manualType

    [selectedMA, maName]
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ CALCULATIONS {
bool isAutoMA = maSelectMode == "Auto (Adaptive Scoring)"
[midLine, activeMaName] = f_autoSelectMA(close, baseLen, noisePenalty, manualMaType, isAutoMA)

// Volume & Dynamic Keltner Multiplier
volMa    = ta.sma(volume, volLen)
volRatio = volMa > 0 ? volume / volMa : 1.0
kcMult   = math.min(4.0, math.max(3.0, 3.0 + (volRatio - 1.0) * volSens))

bbStd   = ta.stdev(close, baseLen)
bbUpper = midLine + (bbStd * bbMult)
bbLower = midLine - (bbStd * bbMult)

atrVal  = ta.atr(atrLen)
kcUpper = midLine + (atrVal * kcMult)
kcLower = midLine - (atrVal * kcMult)

diffUpper   = bbUpper - kcUpper
diffLower   = bbLower - kcLower
maDiffUpper = ta.sma(diffUpper, diffMaLen)
maDiffLower = ta.sma(diffLower, diffMaLen)

aurUpper = kcUpper + maDiffUpper
aurLower = kcLower + maDiffLower

// Expansion Parameters
aurWidth    = aurUpper - aurLower
avgAurWidth = ta.sma(aurWidth, envLen)

envVolBoost = 1.0 + math.max(0.0, volRatio - 1.0) * envVolSens
envOffset   = (avgAurWidth * 0.5 * envMult) * envVolBoost

envUpper = aurUpper + envOffset
envLower = aurLower - envOffset

isUpperExpansion = high >= aurUpper
isLowerExpansion = low  <= aurLower
isWidthExpanding = aurWidth > avgAurWidth

plotEnvUpper = showEnvelope and (not onlyOnBreakout or isUpperExpansion) ? envUpper : na
plotEnvLower = showEnvelope and (not onlyOnBreakout or isLowerExpansion) ? envLower : na

// Trigger Engine
var float latchedUpperTrigger = na
var float latchedLowerTrigger = na

if isUpperExpansion
    latchedUpperTrigger := trigTrackMode == "Hold Peak Level" ? math.max(nz(latchedUpperTrigger, envUpper), envUpper) : envUpper
else if trigTrackMode == "Dynamic Tracking" and not isUpperExpansion
    latchedUpperTrigger := math.max(aurUpper, nz(latchedUpperTrigger, aurUpper) - (avgAurWidth / envLen))

if isLowerExpansion
    latchedLowerTrigger := trigTrackMode == "Hold Peak Level" ? math.min(nz(latchedLowerTrigger, envLower), envLower) : envLower
else if trigTrackMode == "Dynamic Tracking" and not isLowerExpansion
    latchedLowerTrigger := math.min(aurLower, nz(latchedLowerTrigger, aurLower) + (avgAurWidth / envLen))

rawTrigUpper = nz(latchedUpperTrigger, envUpper)
rawTrigLower = nz(latchedLowerTrigger, envLower)

[smoothedTrigUpper, _]  = f_autoSelectMA(rawTrigUpper, envLen, noisePenalty, manualMaType, isAutoMA)
[smoothedTrigLower, __] = f_autoSelectMA(rawTrigLower, envLen, noisePenalty, manualMaType, isAutoMA)

trigBuffer     = (avgAurWidth * trigBuffMult) * envVolBoost
finalTrigUpper = smoothedTrigUpper + trigBuffer
finalTrigLower = smoothedTrigLower - trigBuffer
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ CROSSOVER MULTIPLIER ENGINE {
bool isCrossUpper = false
bool isCrossLower = false

switch crossTarget
    "Midline" =>
        isCrossUpper := ta.crossover(close, midLine)
        isCrossLower := ta.crossunder(close, midLine)
    "Aurora Bands" =>
        isCrossUpper := ta.crossover(close, aurUpper)
        isCrossLower := ta.crossunder(close, aurLower)
    "Expansion Envelope" =>
        isCrossUpper := ta.crossover(close, envUpper)
        isCrossLower := ta.crossunder(close, envLower)
    "Trigger Channel" =>
        isCrossUpper := ta.crossover(close, finalTrigUpper)
        isCrossLower := ta.crossunder(close, finalTrigLower)

bool isAnyCross = isCrossUpper or isCrossLower

float rawCrossMult = kcMult * volRatio

var float latchedCrossMult = rawCrossMult
if isAnyCross
    latchedCrossMult := rawCrossMult

[smoothedCrossMult, _] = f_autoSelectMA(latchedCrossMult, crossMaLen, noisePenalty, manualMaType, isAutoMA)

float crossOffset    = atrVal * smoothedCrossMult
float crossUpperLine = midLine + crossOffset
float crossLowerLine = midLine - crossOffset

// Crossover lines – black by default + dotted
plot(showCrossMA ? crossUpperLine : na, 'Crossover Upper', 
     color = colCross, linewidth = 2, style = plot.style_line, 
     linestyle = plot.linestyle_dotted)

plot(showCrossMA ? crossLowerLine : na, 'Crossover Lower', 
     color = colCross, linewidth = 2, style = plot.style_line, 
     linestyle = plot.linestyle_dotted)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ REGIME & STYLING {
bool isBull = close > midLine
color regimeColor = isBull ? colUpper : colLower

color barCol = paintBars ? regimeColor : na
plotcandle(open, high, low, close, title = 'Candle Coloring', color = barCol, wickcolor = barCol, bordercolor = barCol)

// Main Aurora Channel
pMid   = plot(midLine,  'Aurora Center', color = color.new(colMid, 15), linewidth = 1)
pUpper = plot(aurUpper, 'Aurora Upper',  color = color.new(colUpper, 10), linewidth = 1)
pLower = plot(aurLower, 'Aurora Lower',  color = color.new(colLower, 10), linewidth = 1)

// Expansion Envelope
pEUpper = plot(plotEnvUpper, 'Envelope Upper', color = color.new(colEnv, 45), linewidth = 1, style = onlyOnBreakout ? plot.style_linebr : plot.style_line)
pELower = plot(plotEnvLower, 'Envelope Lower', color = color.new(colEnv, 45), linewidth = 1, style = onlyOnBreakout ? plot.style_linebr : plot.style_line)

// Trigger Channel
pTUpper = plot(showTrigger and not na(latchedUpperTrigger) ? finalTrigUpper : na, 'Trigger Upper', color = color.new(colTrig, 50), linewidth = 1)
pTLower = plot(showTrigger and not na(latchedLowerTrigger) ? finalTrigLower : na, 'Trigger Lower', color = color.new(colTrig, 50), linewidth = 1)

// ────────────────────────────────────────────────
// MULTI-LAYER CLOUD – Inner (Midline → Aurora)
// ────────────────────────────────────────────────
cloudA_Upper = midLine + (aurUpper - midLine) * 0.25
cloudB_Upper = midLine + (aurUpper - midLine) * 0.50
cloudC_Upper = midLine + (aurUpper - midLine) * 0.75

cloudA_Lower = midLine + (aurLower - midLine) * 0.25
cloudB_Lower = midLine + (aurLower - midLine) * 0.50
cloudC_Lower = midLine + (aurLower - midLine) * 0.75

pUA = plot(showCloud ? cloudA_Upper : na, display = display.none)
pUB = plot(showCloud ? cloudB_Upper : na, display = display.none)
pUC = plot(showCloud ? cloudC_Upper : na, display = display.none)
pLA = plot(showCloud ? cloudA_Lower : na, display = display.none)
pLB = plot(showCloud ? cloudB_Lower : na, display = display.none)
pLC = plot(showCloud ? cloudC_Lower : na, display = display.none)

// Inner Upper cloud
fill(pMid, pUA,  color = showCloud ? color.new(colUpper, 90) : na, title = 'Inner Upper Cloud 1')
fill(pUA,  pUB,  color = showCloud ? color.new(colUpper, 82) : na, title = 'Inner Upper Cloud 2')
fill(pUB,  pUC,  color = showCloud ? color.new(colUpper, 74) : na, title = 'Inner Upper Cloud 3')
fill(pUC,  pUpper, color = showCloud ? color.new(colUpper, 66) : na, title = 'Inner Upper Cloud 4')

// Inner Lower cloud
fill(pMid, pLA,  color = showCloud ? color.new(colLower, 90) : na, title = 'Inner Lower Cloud 1')
fill(pLA,  pLB,  color = showCloud ? color.new(colLower, 82) : na, title = 'Inner Lower Cloud 2')
fill(pLB,  pLC,  color = showCloud ? color.new(colLower, 74) : na, title = 'Inner Lower Cloud 3')
fill(pLC,  pLower, color = showCloud ? color.new(colLower, 66) : na, title = 'Inner Lower Cloud 4')

// ────────────────────────────────────────────────
// MULTI-LAYER CLOUD – Envelope (Aurora → Envelope)
// ────────────────────────────────────────────────
envCloudA_Upper = aurUpper + (envUpper - aurUpper) * 0.25
envCloudB_Upper = aurUpper + (envUpper - aurUpper) * 0.50
envCloudC_Upper = aurUpper + (envUpper - aurUpper) * 0.75

envCloudA_Lower = aurLower + (envLower - aurLower) * 0.25
envCloudB_Lower = aurLower + (envLower - aurLower) * 0.50
envCloudC_Lower = aurLower + (envLower - aurLower) * 0.75

pEUA = plot(showEnvelope and not na(plotEnvUpper) ? envCloudA_Upper : na, display = display.none)
pEUB = plot(showEnvelope and not na(plotEnvUpper) ? envCloudB_Upper : na, display = display.none)
pEUC = plot(showEnvelope and not na(plotEnvUpper) ? envCloudC_Upper : na, display = display.none)

pELA = plot(showEnvelope and not na(plotEnvLower) ? envCloudA_Lower : na, display = display.none)
pELB = plot(showEnvelope and not na(plotEnvLower) ? envCloudB_Lower : na, display = display.none)
pELC = plot(showEnvelope and not na(plotEnvLower) ? envCloudC_Lower : na, display = display.none)

// Envelope Upper cloud layers
fill(pUpper, pEUA, color = showEnvelope and not na(plotEnvUpper) ? color.new(colEnv, 90) : na, title = 'Envelope Upper Cloud 1')
fill(pEUA,   pEUB, color = showEnvelope and not na(plotEnvUpper) ? color.new(colEnv, 82) : na, title = 'Envelope Upper Cloud 2')
fill(pEUB,   pEUC, color = showEnvelope and not na(plotEnvUpper) ? color.new(colEnv, 74) : na, title = 'Envelope Upper Cloud 3')
fill(pEUC,   pEUpper, color = showEnvelope and not na(plotEnvUpper) ? color.new(colEnv, 66) : na, title = 'Envelope Upper Cloud 4')

// Envelope Lower cloud layers
fill(pLower, pELA, color = showEnvelope and not na(plotEnvLower) ? color.new(colEnv, 90) : na, title = 'Envelope Lower Cloud 1')
fill(pELA,   pELB, color = showEnvelope and not na(plotEnvLower) ? color.new(colEnv, 82) : na, title = 'Envelope Lower Cloud 2')
fill(pELB,   pELC, color = showEnvelope and not na(plotEnvLower) ? color.new(colEnv, 74) : na, title = 'Envelope Lower Cloud 3')
fill(pELC,   pELower, color = showEnvelope and not na(plotEnvLower) ? color.new(colEnv, 66) : na, title = 'Envelope Lower Cloud 4')

// Soft fill between Envelope and Trigger
int trigTrans = isWidthExpanding ? 80 : 90
fill(pEUpper, pTUpper, color = showTrigger and not na(latchedUpperTrigger) ? color.new(colTrig, trigTrans) : na, title = 'Trigger Upper Fill')
fill(pELower, pTLower, color = showTrigger and not na(latchedLowerTrigger) ? color.new(colTrig, trigTrans) : na, title = 'Trigger Lower Fill')
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ DASHBOARD HUD {
var table hud = table.new(position = position.top_right, columns = 2, rows = 5, bgcolor = color.new(#0D0B14, 10), border_width = 1, border_color = color.new(color.gray, 60))

if barstate.islast and showDash
    table.cell(hud, 0, 0, "Engine MA",        text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 0, activeMaName + (isAutoMA ? " (AI)" : ""), text_color = colTrig, text_size = size.small)
    
    table.cell(hud, 0, 1, "Cross Target",     text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 1, crossTarget,        text_color = color.yellow, text_size = size.small)
    
    table.cell(hud, 0, 2, "Cross Multiplier", text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 2, str.tostring(smoothedCrossMult, "#.##"), text_color = colCross, text_size = size.small)
    
    table.cell(hud, 0, 3, "Expansion State",  text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 3, isWidthExpanding ? "Expanding" : "Neutral", text_color = isWidthExpanding ? colEnv : color.gray, text_size = size.small)
    
    table.cell(hud, 0, 4, "Regime",           text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 4, isBull ? "Bullish" : "Bearish", text_color = regimeColor, text_size = size.small)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ ALERTS {
alertcondition(isAnyCross, 'Aurora Channel Cross', 'Price crossed selected target channel')

if barstate.isconfirmed and isAnyCross
    alert('🔔 Aurora Channel Cross on ' + syminfo.ticker + ' (' + crossTarget + ') – Mult: ' + str.tostring(smoothedCrossMult, "#.##"), alert.freq_once_per_bar_close)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
