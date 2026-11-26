# Market Condition Gauge

- url: https://www.tradingview.com/script/OKTq6It4-Market-Condition-Gauge/
- type: indicator
- pine_id: PUB;75aeae15c0b64107a676430ef6792971
- version: 1.0

## Description

A market-state indicator that classifies bias, condition, strength, and stretch using a weighted blend of momentum, trend, volatility, participation, and trend-quality inputs.

Market Condition Gauge is a non-signal market-state indicator designed to answer four practical questions:

What is the current market bias?
What kind of environment is price trading in right now?
How strong is that read?
Is the move becoming stretched rather than simply trending?

This script is not intended to generate buy or sell signals. Its purpose is to help the user read context more clearly by separating directional bias from market condition.

What the script does

The indicator builds a composite score from several common market measures, then smooths that score into a single gauge that can be read visually and through an on-chart label.

It classifies the market using four main outputs:

Bias
Bullish, Bearish, or Neutral.

Condition
Trending, Balanced, Mixed / Chop, or Stretch.

Strength
Weak, Moderate, or Strong.

State
A more specific read such as Bull Bias, Bear Bias, Bull Continuation, Bear Continuation, Strong Bull Bias, Strong Bear Bias, Bull Stretch, Bear Stretch, or Mixed / Chop.

The goal is to give traders a cleaner summary of market structure and behaviour, rather than an entry engine.

How it works

The composite score is built from five components:

RSI
Used as a momentum input.

MACD histogram
Used as a directional momentum-pressure input.

Trend distance from EMA
Measures how far price is trading above or below its trend anchor.

Volume ratio
Compares current volume to average volume to estimate participation.

ATR ratio
Compares current ATR to average ATR to estimate activity and expansion.

These components are normalised onto a common scale and blended with user-defined weights. The result is then smoothed to create the final gauge.

In addition, the script uses DMI/ADX to help distinguish between cleaner directional conditions and more mixed or rotational conditions.

What the colours mean

Green tones
Bullish conditions.

Red tones
Bearish conditions.

Grey
Mixed / chop or lower-conviction conditions.

Purple / orange stretch states
A move that looks extended rather than simply healthy and directional.

How to interpret it

A rising score above the bullish region suggests improving upside pressure.
A falling score below the bearish region suggests improving downside pressure.
A score rotating around the middle zone with weak slope and softer ADX conditions suggests a less directional environment.
Stretch states are designed to warn that a move may be extended and becoming less efficient, even if the broader bias remains intact.

In practical terms, this script is best used as a context filter:

to decide whether the market is trending or messy,
to judge whether bullish or bearish pressure has the edge,
to avoid over-reading weak conditions,
and to recognise when a move may be becoming stretched.
Default label fields

The state label displays:

Bias — Bullish, Bearish, or Neutral
Condition — Trending, Balanced, Mixed / Chop, or Stretch
Strength — Weak, Moderate, or Strong
State — the current detailed regime classification
Score — current composite reading
ADX — current ADX value used in the condition logic
TF — the timeframe of the active chart

Timeframe behaviour

This script runs on the active chart timeframe by default. If the chart is on 15 minutes, the gauge is calculated on 15 minutes. If the chart is on 1 hour, 4 hours, or daily, the gauge recalculates on that timeframe automatically. Trading View scripts normally use the chart’s current symbol and timeframe unless a separate timeframe is explicitly requested in code.

Inputs and customisation

The script includes user controls for:

RSI, ATR, MACD, EMA, and averaging lengths
weighting of each component in the composite
bullish and bearish threshold levels
chop and stretch sensitivity
histogram, background, and debug display options
state label size, position, and transparency

This allows the gauge to be tuned for different markets and personal display preferences.

Intended use

This script is designed for traders who want a clearer read on market condition rather than direct trade signals.

Examples of use:

filtering whether a trend is healthy or messy
checking whether bullish or bearish pressure has the edge
spotting periods where conviction is weak
identifying when a move may be stretched
Limitations

This indicator does not predict future price movement with certainty.
It does not generate entries, exits, or guaranteed turning points.
Like any composite indicator, it can lag fast reversals and may behave differently across instruments, sessions, and volatility regimes.
Stretch conditions do not automatically mean reversal; they simply flag that the move may be extended relative to its recent behaviour.

Notes

This script is best read alongside price structure and the trader’s own process.
It is intended as a market-reading tool, not a complete trading system.
No claim is made that the script improves performance on its own or that any threshold will work equally well on every market.

## Source Code

````pine
//@version=6
indicator("Market Condition Gauge", shorttitle="MCG", overlay=false)

//==================================================
// Inputs
//==================================================
rsiLength = input.int(14, "RSI Length", minval=2)
atrLength = input.int(14, "ATR Length", minval=2)
macdFastLength = input.int(12, "MACD Fast Length", minval=1)
macdSlowLength = input.int(26, "MACD Slow Length", minval=2)
macdSignalLength = input.int(9, "MACD Signal Length", minval=1)
emaLength = input.int(50, "Trend EMA Length", minval=2)
volumeLength = input.int(20, "Volume Average Length", minval=2)
normLookback = input.int(100, "Normalization Lookback", minval=20)
smoothLength = input.int(5, "Composite Smoothing", minval=1)

dmiDiLength = input.int(14, "DMI DI Length", minval=2)
dmiAdxSmoothing = input.int(14, "ADX Smoothing", minval=2)

upperThreshold = input.int(70, "Strong Bull Threshold", minval=50, maxval=100)
lowerThreshold = input.int(30, "Strong Bear Threshold", minval=0, maxval=50)
bullBiasLevel = input.int(55, "Bull Bias Level", minval=50, maxval=100)
bearBiasLevel = input.int(45, "Bear Bias Level", minval=0, maxval=50)

chopAdxThreshold = input.float(18.0, "ADX Chop Threshold", minval=1.0, step=0.5)
flatSlopeThreshold = input.float(1.5, "Flat Composite Slope Threshold", minval=0.1, step=0.1)
stretchThreshold = input.float(8.0, "Stretch Threshold", minval=1.0, step=0.5)

//==================================================
// Display controls
//==================================================
showHistogram = input.bool(true, "Show Histogram")
showCompositeLine = input.bool(true, "Show Composite Line")
showBackground = input.bool(true, "Show Background State")
showStateLabel = input.bool(true, "Show State Label")
showStretchMarkers = input.bool(false, "Show Stretch Markers")
showDebugComponents = input.bool(false, "Show Debug Component Scores")

labelSizeInput = input.string("Large", "State Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])
labelPositionInput = input.string("Right", "State Label Position", options=["Left", "Right"])
labelTransparency = input.int(10, "Label Background Transparency", minval=0, maxval=100)

//==================================================
// Weights
//==================================================
weightRSI = input.float(0.30, "Weight RSI", minval=0.0, step=0.05)
weightMACD = input.float(0.30, "Weight MACD", minval=0.0, step=0.05)
weightTrend = input.float(0.20, "Weight Trend", minval=0.0, step=0.05)
weightVolume = input.float(0.10, "Weight Volume", minval=0.0, step=0.05)
weightATR = input.float(0.10, "Weight ATR", minval=0.0, step=0.05)

//==================================================
// Helper functions
//==================================================
clampValue(_value, _min, _max) =>
    math.max(_min, math.min(_value, _max))

normalizeSigned(_value, _absMax) =>
    _absMax > 0 ? clampValue(50.0 + (_value / _absMax) * 50.0, 0.0, 100.0) : 50.0

normalizeRatio(_ratio, _center, _range) =>
    _range > 0 ? clampValue(50.0 + ((_ratio - _center) / _range) * 50.0, 0.0, 100.0) : 50.0

//==================================================
// Label size mapping
//==================================================
labelSize = size.large
if labelSizeInput == "Tiny"
    labelSize := size.tiny
else if labelSizeInput == "Small"
    labelSize := size.small
else if labelSizeInput == "Normal"
    labelSize := size.normal
else if labelSizeInput == "Large"
    labelSize := size.large
else if labelSizeInput == "Huge"
    labelSize := size.huge

labelStyle = label.style_label_right
if labelPositionInput == "Left"
    labelStyle := label.style_label_left

//==================================================
// Core calculations
//==================================================
rsiValue = ta.rsi(close, rsiLength)
atrValue = ta.atr(atrLength)
emaValue = ta.ema(close, emaLength)
[plusDI, minusDI, adxValue] = ta.dmi(dmiDiLength, dmiAdxSmoothing)
[macdLine, signalLine, macdHist] = ta.macd(close, macdFastLength, macdSlowLength, macdSignalLength)

avgVolume = ta.sma(volume, volumeLength)
volumeRatio = avgVolume > 0 ? volume / avgVolume : 1.0

atrAverage = ta.sma(atrValue, atrLength)
atrRatio = atrAverage > 0 ? atrValue / atrAverage : 1.0

//==================================================
// Component scores
//==================================================
rsiScore = rsiValue

macdAbsMax = ta.highest(math.abs(macdHist), normLookback)
macdScore = normalizeSigned(macdHist, macdAbsMax)

trendPct = emaValue != 0 ? ((close - emaValue) / emaValue) * 100.0 : 0.0
trendAbsMax = ta.highest(math.abs(trendPct), normLookback)
trendScore = normalizeSigned(trendPct, trendAbsMax)

volumeScore = normalizeRatio(volumeRatio, 1.0, 1.0)
atrScore = normalizeRatio(atrRatio, 1.0, 1.0)

//==================================================
// Weighted composite
//==================================================
totalWeight = weightRSI + weightMACD + weightTrend + weightVolume + weightATR

weightedSum = 0.0
weightedSum := weightedSum + (rsiScore * weightRSI)
weightedSum := weightedSum + (macdScore * weightMACD)
weightedSum := weightedSum + (trendScore * weightTrend)
weightedSum := weightedSum + (volumeScore * weightVolume)
weightedSum := weightedSum + (atrScore * weightATR)

rawComposite = 50.0
if totalWeight > 0
    rawComposite := weightedSum / totalWeight

compositeScore = ta.ema(rawComposite, smoothLength)
compositeSlope = compositeScore - compositeScore[1]

//==================================================
// State logic
//==================================================
isStrongBull = compositeScore >= upperThreshold
isStrongBear = compositeScore <= lowerThreshold
isBullBias = compositeScore > bullBiasLevel
isBearBias = compositeScore < bearBiasLevel

isMidZone = compositeScore > bearBiasLevel and compositeScore < bullBiasLevel
isFlat = math.abs(compositeSlope) <= flatSlopeThreshold
isChop = adxValue < chopAdxThreshold and isMidZone and isFlat

trendStretchNorm = trendAbsMax > 0 ? (math.abs(trendPct) / trendAbsMax) * 100.0 : 0.0

bullStretch = compositeScore >= upperThreshold and compositeSlope <= 0 and rsiValue >= 65 and trendStretchNorm >= stretchThreshold
bearStretch = compositeScore <= lowerThreshold and compositeSlope >= 0 and rsiValue <= 35 and trendStretchNorm >= stretchThreshold

bullContinuation = isBullBias and compositeSlope > 0 and not bullStretch and not isChop
bearContinuation = isBearBias and compositeSlope < 0 and not bearStretch and not isChop

//==================================================
// Label fields
//==================================================
string biasText = "Neutral"
if isStrongBull or isBullBias
    biasText := "Bullish"
else if isStrongBear or isBearBias
    biasText := "Bearish"

string conditionText = "Balanced"
if isChop
    conditionText := "Mixed / Chop"
else if bullStretch or bearStretch
    conditionText := "Stretch"
else if bullContinuation or bearContinuation
    conditionText := "Trending"

string strengthText = "Weak"
if compositeScore >= 65 or compositeScore <= 35
    strengthText := "Strong"
else if compositeScore >= bullBiasLevel or compositeScore <= bearBiasLevel
    strengthText := "Moderate"

string stateText = "Neutral"
if isChop
    stateText := "Mixed / Chop"
else if bullStretch
    stateText := "Bull Stretch"
else if bearStretch
    stateText := "Bear Stretch"
else if isStrongBull
    stateText := "Strong Bull Bias"
else if isStrongBear
    stateText := "Strong Bear Bias"
else if bullContinuation
    stateText := "Bull Continuation"
else if bearContinuation
    stateText := "Bear Continuation"
else if isBullBias
    stateText := "Bull Bias"
else if isBearBias
    stateText := "Bear Bias"

//==================================================
// Colours
//==================================================
color scoreColor = color.gray
if isChop
    scoreColor := color.silver
else if bullStretch
    scoreColor := color.fuchsia
else if bearStretch
    scoreColor := color.orange
else if isStrongBull
    scoreColor := color.lime
else if isStrongBear
    scoreColor := color.red
else if isBullBias
    scoreColor := color.green
else if isBearBias
    scoreColor := color.maroon

color histColor = color.gray
if isChop
    histColor := color.silver
else if bullStretch
    histColor := color.fuchsia
else if bearStretch
    histColor := color.orange
else if compositeScore >= 50
    histColor := color.green
else
    histColor := color.red

//==================================================
// Main plots
//==================================================
plot(showCompositeLine ? compositeScore : na, title="Market Condition Gauge", color=scoreColor, linewidth=2)
plot(50, title="Neutral", color=color.new(color.gray, 65), linewidth=1)

hline(upperThreshold, "Strong Bull Threshold", color=color.new(color.red, 0), linestyle=hline.style_dashed)
hline(lowerThreshold, "Strong Bear Threshold", color=color.new(color.green, 0), linestyle=hline.style_dashed)
hline(bullBiasLevel, "Bull Bias Level", color=color.new(color.green, 70), linestyle=hline.style_dotted)
hline(bearBiasLevel, "Bear Bias Level", color=color.new(color.red, 70), linestyle=hline.style_dotted)

plot(showHistogram ? compositeScore : na, title="State Histogram", style=plot.style_columns, color=color.new(histColor, 60), linewidth=2)

//==================================================
// Optional debug plots
//==================================================
plot(showDebugComponents ? rsiScore : na, title="RSI Score", color=color.new(color.blue, 35), linewidth=1)
plot(showDebugComponents ? macdScore : na, title="MACD Score", color=color.new(color.orange, 35), linewidth=1)
plot(showDebugComponents ? trendScore : na, title="Trend Score", color=color.new(color.purple, 35), linewidth=1)
plot(showDebugComponents ? volumeScore : na, title="Volume Score", color=color.new(color.teal, 35), linewidth=1)
plot(showDebugComponents ? atrScore : na, title="ATR Score", color=color.new(color.yellow, 35), linewidth=1)

//==================================================
// Background
//==================================================
color bgColor = na
if showBackground
    if isChop
        bgColor := color.new(color.gray, 92)
    else if bullStretch
        bgColor := color.new(color.fuchsia, 92)
    else if bearStretch
        bgColor := color.new(color.orange, 92)
    else if isStrongBull
        bgColor := color.new(color.green, 92)
    else if isStrongBear
        bgColor := color.new(color.red, 92)

bgcolor(bgColor)

//==================================================
// Optional stretch markers
//==================================================
plotshape(showStretchMarkers and bullStretch, title="Bull Stretch", style=shape.circle, location=location.top, color=color.fuchsia, size=size.tiny)
plotshape(showStretchMarkers and bearStretch, title="Bear Stretch", style=shape.circle, location=location.bottom, color=color.orange, size=size.tiny)

//==================================================
// State label
//==================================================
var label stateLabel = na

if showStateLabel and barstate.islast
    if not na(stateLabel)
        label.delete(stateLabel)

    labelY = compositeScore
    labelX = bar_index

    labelText = "Bias: " + biasText
    labelText := labelText + "\nCondition: " + conditionText
    labelText := labelText + "\nStrength: " + strengthText
    labelText := labelText + "\nState: " + stateText
    labelText := labelText + "\nScore: " + str.tostring(compositeScore, "#.0")
    labelText := labelText + "\nADX: " + str.tostring(adxValue, "#.0")
    labelText := labelText + "\nTF: " + timeframe.period

    stateLabel := label.new(labelX, labelY, labelText, xloc=xloc.bar_index, yloc=yloc.price, style=labelStyle, textcolor=color.white, color=color.new(scoreColor, labelTransparency), size=labelSize)
````
