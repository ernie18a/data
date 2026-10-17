# Mercator Pressure [JOAT]

- url: https://www.tradingview.com/script/bETbetJH-Mercator-Pressure-JOAT/
- type: indicator
- pine_id: PUB;610f039902874a729caba7b4d1336855
- version: 1.0

## Description

[b]Mercator Pressure [JOAT][/b]

[b]Introduction[/b]

Mercator Pressure is an open-source institutional-style pressure oscillator built to measure directional force using a blended model of candle pressure, close-location behavior, range expansion, optional volume impulse, and volatility-channel context. The goal is to capture not just whether momentum is positive or negative, but how forceful and structurally aligned that movement is.

The problem Mercator Pressure solves is shallow momentum interpretation. Many oscillators react to price movement but fail to distinguish between weak drift, strong displacement, location inside a volatility envelope, and divergence between price and internal force. Mercator Pressure combines those dimensions in one panel and adds confirmed divergence logic, threshold regimes, layered gradients, and a live dashboard.

[image]https://www.tradingview.com/x/0UpggYzF/[/image]

[b]Core Concepts[/b]

[b]1. Weighted Candle Pressure Engine[/b]

The core model scores each bar using a weighted blend of body impulse, close location, range expansion, and optional relative volume impulse. This helps the oscillator react differently to high-conviction bars than to passive movement.

[b]2. Volatility-Channel Context Engine[/b]

Pressure is not evaluated in isolation. The script also measures where price sits inside an adaptive volatility envelope and uses that context as part of the composite regime model.

[b]3. Composite Regime and Signal Layer[/b]

The pressure and context models are blended into a smoothed composite oscillator and signal line. Regime state is then derived from threshold behavior and internal persistence.

[b]4. Confirmed Divergence Detection[/b]

Both regular and hidden divergence are supported using pivot-confirmed logic, which keeps the divergence framework more stable than naive visual divergence methods.

[b]5. Institutional Panel Styling[/b]

Mercator Pressure uses layered fills, gradient regime cues, restrained optional divergence markers, and a top-right dashboard rather than retail-style arrow spam.

[b]Features[/b]

[list]
[*][b]Multi-factor pressure engine:[/b] Body, close location, range expansion, and optional relative volume
[*][b]Volatility envelope context:[/b] Internal force is blended with channel position
[*][b]Composite oscillator and signal line:[/b] Regime interpretation is smoother and more stable
[*][b]Regular and hidden divergence:[/b] Pivot-confirmed divergence conditions
[*][b]Confirmed-bar event gating:[/b] Alerts and key events can be evaluated on closed bars
[*][b]Layered gradient fills:[/b] Smooth panel depth instead of harsh histogram clutter
[*][b]Regime background tint:[/b] Visual context in the panel
[*][b]Top-right dashboard:[/b] Live state readout for regime, slope, context, and divergence
[*][b]Optional divergence markers:[/b] Uses professional square and diamond markers, not arrows
[*][b]Alertconditions:[/b] Regime flips, signal crosses, expansions, and divergences
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Composite Line Versus Signal[/b]
When the composite line is above the signal and above key thresholds, internal pressure is supportive. The opposite applies during bearish pressure.

[b]Step 2: Check Regime State[/b]
Use the dashboard and panel tint to determine whether the script sees a bullish, bearish, or neutral pressure regime.

[b]Step 3: Watch Expansion Conditions[/b]
Expansion events are stronger than ordinary threshold crosses because they imply pressure is extending into a more forceful state.

[b]Step 4: Use Divergence as Context[/b]
Divergence is best used as a warning or contextual signal, not as a blind reversal trigger.

[b]Indicator Limitations[/b]

[list]
[*]Divergence only confirms after pivots confirm, which introduces natural delay by design
[*]Pressure is a proxy model derived from chart data, not exchange-level order flow
[*]The composite engine is adaptive and may behave differently across very low-volatility versus very high-volatility symbols
[*]This script is best used as a directional-quality filter or context tool, not a standalone trading system
[/list]

[b]Originality Statement[/b]

Mercator Pressure is original in the way it combines weighted candle pressure, volatility-envelope context, regime hysteresis, and pivot-confirmed divergence inside one coordinated panel. Its value comes from force measurement, contextualization, and divergence structure rather than from any one common oscillator formula.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Pressure and divergence readings are derived from historical price and volume behavior and do not guarantee future results.

- Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Mercator Pressure [JOAT]", shorttitle="MCP [JOAT]", overlay=false, max_labels_count=500, max_lines_count=100, precision=2)

//==================================================================================================
// INPUTS - CORE ENGINE
//==================================================================================================
groupCore = "Core Pressure Engine"
lengthPressure = input.int(24, "Pressure Memory Length", minval=5, maxval=200, group=groupCore)
lengthBodyNorm = input.int(34, "Body Normalization Length", minval=5, maxval=300, group=groupCore)
lengthRangeNorm = input.int(34, "Range Normalization Length", minval=5, maxval=300, group=groupCore)
lengthVolumeNorm = input.int(34, "Volume Normalization Length", minval=5, maxval=300, group=groupCore)
weightBody = input.float(0.44, "Weight: Body Impulse", minval=0.0, maxval=1.0, step=0.01, group=groupCore)
weightCloseLocation = input.float(0.22, "Weight: Close Location", minval=0.0, maxval=1.0, step=0.01, group=groupCore)
weightRangeExpansion = input.float(0.22, "Weight: Range Expansion", minval=0.0, maxval=1.0, step=0.01, group=groupCore)
weightVolumeImpulse = input.float(0.12, "Weight: Volume Impulse", minval=0.0, maxval=1.0, step=0.01, group=groupCore)
useVolumeImpulse = input.bool(true, "Use Volume Impulse Component", group=groupCore)
normalizationWindow = input.int(120, "Composite Normalization Window", minval=20, maxval=1000, group=groupCore)

//==================================================================================================
// INPUTS - VOLATILITY CONTEXT
//==================================================================================================
groupVol = "Volatility Channel Context"
channelLength = input.int(50, "Channel Length", minval=10, maxval=300, group=groupVol)
channelScalePct = input.float(210.0, "Channel Scale (%)", minval=50.0, maxval=600.0, step=1.0, group=groupVol)
channelBodyBoost = input.float(0.70, "Body Boost Factor", minval=0.0, maxval=2.0, step=0.05, group=groupVol)
contextSmooth = input.int(8, "Context Smoothing Length", minval=1, maxval=100, group=groupVol)
blendPressureVsContext = input.float(0.62, "Blend: Pressure vs Context", minval=0.0, maxval=1.0, step=0.01, group=groupVol)

//==================================================================================================
// INPUTS - SMOOTHING
//==================================================================================================
groupSmooth = "Smoothing"
preSmoothLength = input.int(4, "Pre-Smooth Length", minval=1, maxval=50, group=groupSmooth)
mainSmoothLength = input.int(9, "Main Oscillator Length", minval=1, maxval=100, group=groupSmooth)
signalLength = input.int(18, "Signal Length", minval=1, maxval=200, group=groupSmooth)

//==================================================================================================
// INPUTS - REGIME AND THRESHOLDS
//==================================================================================================
groupRegime = "Regime and Thresholds"
regimeUpper = input.float(18.0, "Regime Upper Threshold", minval=0.0, maxval=80.0, step=0.5, group=groupRegime)
regimeLower = input.float(-18.0, "Regime Lower Threshold", minval=-80.0, maxval=0.0, step=0.5, group=groupRegime)
extremeUpper = input.float(48.0, "Extreme Upper Threshold", minval=10.0, maxval=100.0, step=0.5, group=groupRegime)
extremeLower = input.float(-48.0, "Extreme Lower Threshold", minval=-100.0, maxval=-10.0, step=0.5, group=groupRegime)
regimeHysteresis = input.float(3.0, "Regime Hysteresis Buffer", minval=0.0, maxval=20.0, step=0.25, group=groupRegime)
expansionTrigger = input.float(8.0, "Expansion Trigger (Abs Delta)", minval=1.0, maxval=40.0, step=0.5, group=groupRegime)

//==================================================================================================
// INPUTS - DIVERGENCE
//==================================================================================================
groupDiv = "Divergence Engine"
enableDivergence = input.bool(true, "Enable Divergence Detection", group=groupDiv)
showRegularDivergence = input.bool(true, "Show Regular Divergence", group=groupDiv)
showHiddenDivergence = input.bool(true, "Show Hidden Divergence", group=groupDiv)
pivotLeft = input.int(3, "Pivot Left Bars", minval=1, maxval=20, group=groupDiv)
pivotRight = input.int(3, "Pivot Right Bars", minval=1, maxval=20, group=groupDiv)
divRangeMin = input.int(5, "Min Bars Between Pivots", minval=1, maxval=200, group=groupDiv)
divRangeMax = input.int(90, "Max Bars Between Pivots", minval=2, maxval=400, group=groupDiv)

//==================================================================================================
// INPUTS - VISUALS
//==================================================================================================
groupVis = "Visual System"
showBandGradients = input.bool(true, "Show Threshold Gradients", group=groupVis)
showZeroGradient = input.bool(true, "Show Zero-Line Gradient", group=groupVis)
showMainGlow = input.bool(true, "Show Main-Line Glow", group=groupVis)
showSignalGlow = input.bool(true, "Show Signal-Line Glow", group=groupVis)
showLayeredFill = input.bool(true, "Show Layered Composite Fill", group=groupVis)
showContextHistogram = input.bool(true, "Show Context Histogram", group=groupVis)
showDivergenceMarkers = input.bool(true, "Show Divergence Markers", group=groupVis)
showRegimeBackground = input.bool(true, "Show Regime Background Tint", group=groupVis)

//==================================================================================================
// INPUTS - DASHBOARD
//==================================================================================================
groupDash = "Dashboard"
showDashboard = input.bool(true, "Show Dashboard", group=groupDash)
dashboardBgTransparency = input.int(30, "Dashboard Background Transparency", minval=0, maxval=100, group=groupDash)
dashboardTextSize = input.string("Normal", "Dashboard Text Size", options=["Small", "Normal", "Large"], group=groupDash)

//==================================================================================================
// INPUTS - COLORS (DARK MODE ORIENTED)
//==================================================================================================
groupColor = "Color Theme"
clrBull = input.color(color.rgb(35, 171, 115), "Bull Regime Color", group=groupColor)
clrBear = input.color(color.rgb(197, 71, 102), "Bear Regime Color", group=groupColor)
clrNeutral = input.color(color.rgb(116, 125, 140), "Neutral Regime Color", group=groupColor)
clrMain = input.color(color.rgb(100, 214, 255), "Main Oscillator Color", group=groupColor)
clrSignal = input.color(color.rgb(255, 194, 72), "Signal Line Color", group=groupColor)
clrContextPositive = input.color(color.rgb(62, 136, 255), "Context Positive Color", group=groupColor)
clrContextNegative = input.color(color.rgb(141, 93, 214), "Context Negative Color", group=groupColor)
clrBullDiv = input.color(color.rgb(60, 205, 138), "Bull Divergence Color", group=groupColor)
clrBearDiv = input.color(color.rgb(232, 88, 120), "Bear Divergence Color", group=groupColor)
clrDashText = input.color(color.rgb(230, 233, 240), "Dashboard Text Color", group=groupColor)

//==================================================================================================
// HELPER FUNCTIONS
//==================================================================================================
f_safeDiv(float num, float den) =>
    den == 0.0 ? 0.0 : num / den

f_clamp(float value, float minVal, float maxVal) =>
    math.max(minVal, math.min(maxVal, value))

f_zscore(float src, int len) =>
    float mean = ta.sma(src, len)
    float dev = ta.stdev(src, len)
    dev == 0.0 ? 0.0 : (src - mean) / dev

f_inRange(bool cond, int minBars, int maxBars) =>
    int bars = ta.barssince(cond)
    bars >= minBars and bars <= maxBars

f_regimeName(int regimeState) =>
    regimeState == 1 ? "Bull Bias" : regimeState == -1 ? "Bear Bias" : "Neutral"

f_textSize(string sizeInput) =>
    sizeInput == "Small" ? size.small : sizeInput == "Large" ? size.large : size.normal

f_regimeColor(int regimeState) =>
    regimeState == 1 ? clrBull : regimeState == -1 ? clrBear : clrNeutral

f_intensityColor(float val, color upColor, color downColor, int baseTransp) =>
    float absVal = math.abs(val)
    int extra = int(f_clamp(absVal * 0.7, 0.0, 45.0))
    int finalTransp = int(f_clamp(baseTransp - extra, 5, 95))
    val >= 0 ? color.new(upColor, finalTransp) : color.new(downColor, finalTransp)

//==================================================================================================
// CORE PRICE METRICS
//==================================================================================================
float candleBody = close - open
float bodyAbs = math.abs(candleBody)
float barRange = high - low
float closeLocation = barRange == 0.0 ? 0.0 : ((close - low) / barRange) * 2.0 - 1.0

float avgBody = ta.ema(bodyAbs, lengthBodyNorm)
float avgRange = ta.ema(barRange, lengthRangeNorm)
float avgVolume = ta.ema(volume, lengthVolumeNorm)

// Normalized components around stable denominators.
float bodyImpulse = f_safeDiv(candleBody, math.max(avgBody, syminfo.mintick))
float rangeImpulse = f_safeDiv(barRange - avgRange, math.max(avgRange, syminfo.mintick))
float volumeImpulseRaw = f_safeDiv(volume - avgVolume, math.max(avgVolume, 1.0))
float volumeImpulse = useVolumeImpulse ? volumeImpulseRaw : 0.0

//==================================================================================================
// WEIGHTED PRESSURE ENGINE
//--------------------------------------------------------------------------------------------------
// The pressure engine combines body impulse, location efficiency, volatility impulse, and optional
// volume impulse into a single directional measure before normalization.
//==================================================================================================
float rawPressure =
     (bodyImpulse * weightBody) +
     (closeLocation * weightCloseLocation) +
     (rangeImpulse * weightRangeExpansion) +
     (volumeImpulse * weightVolumeImpulse)

float pressureMemory = ta.ema(rawPressure, lengthPressure)
float pressureZ = f_zscore(pressureMemory, normalizationWindow)
float pressureScaled = f_clamp(pressureZ * 22.0, -100.0, 100.0)

//==================================================================================================
// VOLATILITY CHANNEL CONTEXT ENGINE
//--------------------------------------------------------------------------------------------------
// This context captures where price is inside a volatility-adjusted envelope.
//==================================================================================================
float channelMid = ta.ema(hl2, channelLength)
float channelAvgRange = ta.ema(high - low, channelLength)
float channelAvgBody = ta.ema(math.abs(close - open), channelLength)
float channelBodyRatio = f_safeDiv(channelAvgBody, math.max(channelAvgRange, syminfo.mintick))

float channelOffset = channelAvgRange * (channelScalePct / 100.0) * (1.0 + channelBodyRatio * channelBodyBoost)
float channelUpper = channelMid + channelOffset
float channelLower = channelMid - channelOffset

float channelWidth = math.max(channelUpper - channelLower, syminfo.mintick)
float channelPosRaw = ((close - channelLower) / channelWidth) * 100.0 - 50.0
float channelPos = f_clamp(channelPosRaw, -100.0, 100.0)
float channelPosSmooth = ta.ema(channelPos, contextSmooth)
float channelImpulse = ta.ema(channelPos - channelPos[1], contextSmooth)

//==================================================================================================
// COMPOSITE OSCILLATOR
//--------------------------------------------------------------------------------------------------
// Blend pressure and context into a single regime oscillator.
//==================================================================================================
float compositeRaw = (pressureScaled * blendPressureVsContext) + (channelPosSmooth * (1.0 - blendPressureVsContext))
float compositePre = ta.ema(compositeRaw, preSmoothLength)
float compositeMain = ta.ema(compositePre, mainSmoothLength)
float compositeSignal = ta.ema(compositeMain, signalLength)
float compositeDelta = compositeMain - compositeSignal

// Secondary diagnostics.
float momentumSlope = compositeMain - compositeMain[1]
float acceleration = momentumSlope - momentumSlope[1]
float absExpansion = math.abs(compositeMain - compositeMain[1])

//==================================================================================================
// REGIME STATE ENGINE (WITH HYSTERESIS)
//--------------------------------------------------------------------------------------------------
// State values:
//  1 -> Bull regime
//  0 -> Neutral regime
// -1 -> Bear regime
//==================================================================================================
var int regimeState = 0
int regimePrev = nz(regimeState[1], 0)

if compositeMain > regimeUpper + regimeHysteresis
    regimeState := 1
else if compositeMain < regimeLower - regimeHysteresis
    regimeState := -1
else
    bool neutralFromBull = regimePrev == 1 and compositeMain < regimeUpper - regimeHysteresis
    bool neutralFromBear = regimePrev == -1 and compositeMain > regimeLower + regimeHysteresis
    regimeState := neutralFromBull or neutralFromBear ? 0 : regimePrev

bool flipToBull = regimeState == 1 and regimePrev != 1
bool flipToBear = regimeState == -1 and regimePrev != -1
bool flipToNeutral = regimeState == 0 and regimePrev != 0

// Confirmed-bar event gates for non-repainting alert behavior.
bool flipToBullConfirmed = flipToBull and barstate.isconfirmed
bool flipToBearConfirmed = flipToBear and barstate.isconfirmed
bool flipToNeutralConfirmed = flipToNeutral and barstate.isconfirmed

//==================================================================================================
// SIGNAL EVENTS
//==================================================================================================
bool signalCrossUp = ta.crossover(compositeMain, compositeSignal)
bool signalCrossDown = ta.crossunder(compositeMain, compositeSignal)
bool signalCrossUpConfirmed = signalCrossUp and barstate.isconfirmed
bool signalCrossDownConfirmed = signalCrossDown and barstate.isconfirmed

bool expansionUp = barstate.isconfirmed and regimeState == 1 and compositeMain > extremeUpper and absExpansion > expansionTrigger
bool expansionDown = barstate.isconfirmed and regimeState == -1 and compositeMain < extremeLower and absExpansion > expansionTrigger

//==================================================================================================
// DIVERGENCE ENGINE
//--------------------------------------------------------------------------------------------------
// Divergence is evaluated only on pivot-confirmed bars:
// - ta.pivotlow/high confirms after `pivotRight` bars
// - we compare current pivot values against prior pivot values in bounded spacing
//==================================================================================================
float oscPivotLow = ta.pivotlow(compositeMain, pivotLeft, pivotRight)
float oscPivotHigh = ta.pivothigh(compositeMain, pivotLeft, pivotRight)

bool pivotLowFound = not na(oscPivotLow)
bool pivotHighFound = not na(oscPivotHigh)

float oscLbr = compositeMain[pivotRight]
float oscHbr = compositeMain[pivotRight]
float priceLbr = low[pivotRight]
float priceHbr = high[pivotRight]

float prevOscLow = ta.valuewhen(pivotLowFound, oscLbr, 1)
float prevPriceLow = ta.valuewhen(pivotLowFound, priceLbr, 1)
float prevOscHigh = ta.valuewhen(pivotHighFound, oscHbr, 1)
float prevPriceHigh = ta.valuewhen(pivotHighFound, priceHbr, 1)

bool lowRangeOk = f_inRange(pivotLowFound[1], divRangeMin, divRangeMax)
bool highRangeOk = f_inRange(pivotHighFound[1], divRangeMin, divRangeMax)

bool hasPrevLowData = not na(prevOscLow) and not na(prevPriceLow)
bool hasPrevHighData = not na(prevOscHigh) and not na(prevPriceHigh)

bool bullRegular = enableDivergence and showRegularDivergence and pivotLowFound and lowRangeOk and hasPrevLowData and (priceLbr < prevPriceLow) and (oscLbr > prevOscLow)
bool bearRegular = enableDivergence and showRegularDivergence and pivotHighFound and highRangeOk and hasPrevHighData and (priceHbr > prevPriceHigh) and (oscHbr < prevOscHigh)

bool bullHidden = enableDivergence and showHiddenDivergence and pivotLowFound and lowRangeOk and hasPrevLowData and (priceLbr > prevPriceLow) and (oscLbr < prevOscLow)
bool bearHidden = enableDivergence and showHiddenDivergence and pivotHighFound and highRangeOk and hasPrevHighData and (priceHbr < prevPriceHigh) and (oscHbr > prevOscHigh)

// Confirmed divergence events.
bool bullRegularConfirmed = bullRegular and barstate.isconfirmed
bool bearRegularConfirmed = bearRegular and barstate.isconfirmed
bool bullHiddenConfirmed = bullHidden and barstate.isconfirmed
bool bearHiddenConfirmed = bearHidden and barstate.isconfirmed

bool anyBullDivConfirmed = bullRegularConfirmed or bullHiddenConfirmed
bool anyBearDivConfirmed = bearRegularConfirmed or bearHiddenConfirmed

//==================================================================================================
// VISUAL PREP
//==================================================================================================
color regimeColor = f_regimeColor(regimeState)
color mainColor = f_intensityColor(compositeMain, clrBull, clrBear, 20)
color signalColor = color.new(clrSignal, 5)
color contextColor = channelPosSmooth >= 0 ? color.new(clrContextPositive, 25) : color.new(clrContextNegative, 25)

color bandUpperColor = color.new(clrBear, 72)
color bandLowerColor = color.new(clrBull, 72)
color extremeUpperColor = color.new(clrBear, 40)
color extremeLowerColor = color.new(clrBull, 40)
color zeroColor = color.new(clrNeutral, 55)

//==================================================================================================
// THRESHOLD LINES AND GRADIENT BANDS
//==================================================================================================
hline(0.0, "Zero", color=zeroColor, linestyle=hline.style_dashed)
hline(regimeUpper, "Regime Upper", color=color.new(clrBear, 60), linestyle=hline.style_dashed)
hline(regimeLower, "Regime Lower", color=color.new(clrBull, 60), linestyle=hline.style_dashed)
hline(extremeUpper, "Extreme Upper", color=color.new(clrBear, 40), linestyle=hline.style_dotted)
hline(extremeLower, "Extreme Lower", color=color.new(clrBull, 40), linestyle=hline.style_dotted)

plot(showBandGradients ? regimeUpper : na, "Regime Upper Gradient", color=bandUpperColor, linewidth=8, style=plot.style_line)
plot(showBandGradients ? regimeLower : na, "Regime Lower Gradient", color=bandLowerColor, linewidth=8, style=plot.style_line)
plot(showBandGradients ? extremeUpper : na, "Extreme Upper Gradient", color=extremeUpperColor, linewidth=8, style=plot.style_line)
plot(showBandGradients ? extremeLower : na, "Extreme Lower Gradient", color=extremeLowerColor, linewidth=8, style=plot.style_line)
plot(showZeroGradient ? 0.0 : na, "Zero Gradient", color=color.new(clrNeutral, 80), linewidth=10, style=plot.style_line)

//==================================================================================================
// CONTEXT HISTOGRAM
//==================================================================================================
plot(showContextHistogram ? channelPosSmooth : na, "Channel Context", style=plot.style_columns, color=contextColor, linewidth=2)

//==================================================================================================
// MAIN OSCILLATOR AND SIGNAL
//==================================================================================================
plotMainGlow = plot(showMainGlow ? compositeMain : na, "Main Glow", color=color.new(mainColor, 80), linewidth=8)
plotSignalGlow = plot(showSignalGlow ? compositeSignal : na, "Signal Glow", color=color.new(signalColor, 82), linewidth=6)

plotMain = plot(compositeMain, "Composite Pressure", color=mainColor, linewidth=2)
plotSignal = plot(compositeSignal, "Signal", color=signalColor, linewidth=2)
plotZeroBase = plot(0.0, "Zero Base", color=color.new(color.white, 100), display=display.none)

// Fill between main and signal to emphasize directional spread.
fill(plotMain, plotSignal, color=color.new(compositeDelta >= 0 ? clrBull : clrBear, 80), title="Main-Signal Spread")

// Layered fill between oscillator and zero for depth.
plotMidA = plot(showLayeredFill ? compositeMain * 0.8 : na, "Layer A", color=color.new(color.white, 100), display=display.none)
plotMidB = plot(showLayeredFill ? compositeMain * 0.6 : na, "Layer B", color=color.new(color.white, 100), display=display.none)
plotMidC = plot(showLayeredFill ? compositeMain * 0.4 : na, "Layer C", color=color.new(color.white, 100), display=display.none)
plotMidD = plot(showLayeredFill ? compositeMain * 0.2 : na, "Layer D", color=color.new(color.white, 100), display=display.none)

fill(plotMain, plotMidA, color=showLayeredFill ? color.new(mainColor, 72) : na, title="Layer Fill 1")
fill(plotMidA, plotMidB, color=showLayeredFill ? color.new(mainColor, 78) : na, title="Layer Fill 2")
fill(plotMidB, plotMidC, color=showLayeredFill ? color.new(mainColor, 84) : na, title="Layer Fill 3")
fill(plotMidC, plotMidD, color=showLayeredFill ? color.new(mainColor, 88) : na, title="Layer Fill 4")
fill(plotMidD, plotZeroBase, color=showLayeredFill ? color.new(mainColor, 92) : na, title="Layer Fill 5")

//==================================================================================================
// DIVERGENCE MARKERS (NO ARROW SHAPES)
//--------------------------------------------------------------------------------------------------
// Markers use square and diamond shapes to keep a professional panel style.
//==================================================================================================
plotshape(showDivergenceMarkers and bullRegular ? oscLbr : na, title="Bull Regular Divergence", style=shape.square, location=location.absolute, color=color.new(clrBullDiv, 0), size=size.tiny, text="BR", textcolor=color.new(color.white, 0), offset=-pivotRight)
plotshape(showDivergenceMarkers and bearRegular ? oscHbr : na, title="Bear Regular Divergence", style=shape.square, location=location.absolute, color=color.new(clrBearDiv, 0), size=size.tiny, text="SR", textcolor=color.new(color.white, 0), offset=-pivotRight)
plotshape(showDivergenceMarkers and bullHidden ? oscLbr : na, title="Bull Hidden Divergence", style=shape.diamond, location=location.absolute, color=color.new(clrBullDiv, 10), size=size.tiny, text="BH", textcolor=color.new(color.white, 0), offset=-pivotRight)
plotshape(showDivergenceMarkers and bearHidden ? oscHbr : na, title="Bear Hidden Divergence", style=shape.diamond, location=location.absolute, color=color.new(clrBearDiv, 10), size=size.tiny, text="SH", textcolor=color.new(color.white, 0), offset=-pivotRight)

//==================================================================================================
// REGIME BACKGROUND TINT
//==================================================================================================
bgcolor(showRegimeBackground ? color.new(regimeColor, 92) : na, title="Regime Background")

//==================================================================================================
// DASHBOARD
//--------------------------------------------------------------------------------------------------
// Dashboard is updated only on the last visible bar for performance and clarity.
//==================================================================================================
var table dash = table.new(position.top_right, 2, 9, border_width=1, border_color=color.new(color.gray, 65))

string regimeTxt = f_regimeName(regimeState)
string signalBiasTxt = compositeMain > compositeSignal ? "Pressure > Signal" : compositeMain < compositeSignal ? "Pressure < Signal" : "Aligned"
string contextTxt = channelPosSmooth > 15 ? "Upper Envelope" : channelPosSmooth < -15 ? "Lower Envelope" : "Mid Envelope"
string expansionTxt = expansionUp ? "Bull Expansion" : expansionDown ? "Bear Expansion" : "Normal"
string divergenceTxt = anyBullDivConfirmed ? "Bull Divergence" : anyBearDivConfirmed ? "Bear Divergence" : "None"
string slopeTxt = momentumSlope > 0 ? "Rising" : momentumSlope < 0 ? "Falling" : "Flat"
string accelTxt = acceleration > 0 ? "Accelerating" : acceleration < 0 ? "Decelerating" : "Stable"
string confirmedTxt = "Confirmed Events: ON"

color headerBg = color.new(color.rgb(20, 23, 31), dashboardBgTransparency)
int rowATransp = int(f_clamp(dashboardBgTransparency + 6, 0, 100))
int rowBTransp = int(f_clamp(dashboardBgTransparency + 10, 0, 100))
int rowAccentTransp = int(f_clamp(dashboardBgTransparency + 12, 0, 100))
color rowBgA = color.new(color.rgb(27, 31, 41), rowATransp)
color rowBgB = color.new(color.rgb(32, 36, 47), rowBTransp)
color rowAccent = color.new(regimeColor, rowAccentTransp)
color rowHighlight = color.new(color.rgb(59, 92, 148), rowAccentTransp)

if barstate.islast
    if showDashboard
        table.cell(dash, 0, 0, "Mercator Pressure", text_color=clrDashText, bgcolor=rowHighlight, text_size=f_textSize(dashboardTextSize))
        table.cell(dash, 1, 0, "MCP [JOAT]", text_color=clrDashText, bgcolor=headerBg, text_size=f_textSize(dashboardTextSize))

        table.cell(dash, 0, 1, "Regime", text_color=clrDashText, bgcolor=rowAccent, text_size=f_textSize(dashboardTextSize))
        table.cell(dash, 1, 1, regimeTxt, text_color=clrDashText, bgcolor=rowAccent, text_size=f_textSize(dashboardTextSize))

        table.cell(dash, 0, 2, "Pressure", text_color=clrDashText, bgcolor=rowBgA, text_size=f_textSize(dashboardTextSize))
        table.cell(dash, 1, 2, str.tostring(compositeMain, "#.00"), text_color=clrDashText, bgcolor=rowBgA, text_size=f_textSize(dashboardTextSize))

        table.cell(dash, 0, 3, "Signal", text_color=clrDashText, bgcolor=rowBgB, text_size=f_textSize(dashboardTextSize))
        table.cell(dash, 1, 3, str.tostring(compositeSignal, "#.00"), text_color=clrDashText, bgcolor=rowBgB, text_size=f_textSize(dashboardTextSize))

        table.cell(dash, 0, 4, "Spread", text_color=clrDashText, bgcolor=rowBgA, text_size=f_textSize(dashboardTextSize))
        table.cell(dash, 1, 4, str.tostring(compositeDelta, "#.00"), text_color=clrDashText, bgcolor=rowBgA, text_size=f_textSize(dashboardTextSize))

        table.cell(dash, 0, 5, "Context", text_color=clrDashText, bgcolor=rowBgB, text_size=f_textSize(dashboardTextSize))
        table.cell(dash, 1, 5, contextTxt, text_color=clrDashText, bgcolor=rowBgB, text_size=f_textSize(dashboardTextSize))

        table.cell(dash, 0, 6, "State", text_color=clrDashText, bgcolor=rowBgA, text_size=f_textSize(dashboardTextSize))
        table.cell(dash, 1, 6, signalBiasTxt, text_color=clrDashText, bgcolor=rowBgA, text_size=f_textSize(dashboardTextSize))

        table.cell(dash, 0, 7, "Dynamics", text_color=clrDashText, bgcolor=rowBgB, text_size=f_textSize(dashboardTextSize))
        table.cell(dash, 1, 7, slopeTxt + " / " + accelTxt, text_color=clrDashText, bgcolor=rowBgB, text_size=f_textSize(dashboardTextSize))

        table.cell(dash, 0, 8, "Events", text_color=clrDashText, bgcolor=rowBgA, text_size=f_textSize(dashboardTextSize))
        table.cell(dash, 1, 8, expansionTxt + " | " + divergenceTxt, text_color=clrDashText, bgcolor=rowBgA, text_size=f_textSize(dashboardTextSize))
    else
        // Keep the table hidden by clearing cells when dashboard is disabled.
        for row = 0 to 8
            table.cell(dash, 0, row, "", text_color=color.new(color.white, 100), bgcolor=color.new(color.black, 100))
            table.cell(dash, 1, row, "", text_color=color.new(color.white, 100), bgcolor=color.new(color.black, 100))

//==================================================================================================
// ALERTS
//--------------------------------------------------------------------------------------------------
// Alert conditions are bound to confirmed events to avoid unstable intrabar triggers.
//==================================================================================================
alertcondition(flipToBullConfirmed, "MCP Regime Flip Bull", "Mercator Pressure regime flipped to Bull Bias.")
alertcondition(flipToBearConfirmed, "MCP Regime Flip Bear", "Mercator Pressure regime flipped to Bear Bias.")
alertcondition(flipToNeutralConfirmed, "MCP Regime Flip Neutral", "Mercator Pressure regime returned to Neutral.")

alertcondition(signalCrossUpConfirmed, "MCP Signal Cross Up", "Composite pressure crossed above signal on confirmed bar.")
alertcondition(signalCrossDownConfirmed, "MCP Signal Cross Down", "Composite pressure crossed below signal on confirmed bar.")

alertcondition(expansionUp, "MCP Bull Expansion", "Bullish expansion detected above upper extreme threshold.")
alertcondition(expansionDown, "MCP Bear Expansion", "Bearish expansion detected below lower extreme threshold.")

alertcondition(bullRegularConfirmed, "MCP Bull Regular Divergence", "Bull regular divergence confirmed.")
alertcondition(bearRegularConfirmed, "MCP Bear Regular Divergence", "Bear regular divergence confirmed.")
alertcondition(bullHiddenConfirmed, "MCP Bull Hidden Divergence", "Bull hidden divergence confirmed.")
alertcondition(bearHiddenConfirmed, "MCP Bear Hidden Divergence", "Bear hidden divergence confirmed.")

//==================================================================================================
// DATA WINDOW ONLY DIAGNOSTICS
//==================================================================================================
plot(regimeState, "Regime State Numeric", color=color.new(color.white, 100), display=display.data_window)
plot(channelPosSmooth, "Channel Position", color=color.new(color.white, 100), display=display.data_window)
plot(pressureScaled, "Pressure Scaled", color=color.new(color.white, 100), display=display.data_window)
plot(momentumSlope, "Momentum Slope", color=color.new(color.white, 100), display=display.data_window)
plot(acceleration, "Momentum Acceleration", color=color.new(color.white, 100), display=display.data_window)
plot(absExpansion, "Absolute Expansion", color=color.new(color.white, 100), display=display.data_window)

//==================================================================================================
// END OF SCRIPT
//==================================================================================================
````
