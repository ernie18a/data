# SBP Structured Oscillator

- url: https://www.tradingview.com/script/SpIfROAi-SBP-Structured-Oscillator/
- type: indicator
- pine_id: PUB;690f0be592e54cde83a230ae06576ba4
- version: 5.0

## Description

SBP Structured Oscillator

SBP Structured Oscillator is a composite momentum and market-context oscillator designed to present directional pressure, price displacement, and momentum rotation in a single normalized display.

The purpose of the indicator is not to combine several traditional indicators as separate visual tools. Instead, different measurements are processed together to create one structured oscillator. Each component has a specific role in determining whether price movement is extended, directional pressure is improving or weakening, and the current market environment provides sufficient context for a signal marker.

How the Oscillator Works

The oscillator begins by measuring the distance of price from a smoothed price basis. This distance is normalized by Average True Range (ATR), helping the calculation adapt to instruments with different prices and volatility characteristics.

The normalized displacement is then standardized over a historical lookback period.

A directional composite is added to this displacement measurement. The composite evaluates:

• Price position relative to a smoothed trend basis
• Direction of an adaptive Hull-style weighted average
• ATR-normalized price impulse
• Relative bullish and bearish directional strength
• Changes in directional strength, referred to internally as acceleration

These elements work together because displacement alone can show that price has moved away from its recent equilibrium but does not explain whether directional pressure is strengthening or weakening. The trend and impulse components provide this additional context.

The resulting value is normalized into an oscillator range of approximately -100 to +100.

Adaptive Oscillator Smoothing

The indicator provides three Trading Modes:

SCALPING – uses faster oscillator smoothing and shorter signal spacing.

INTRADAY – applies medium smoothing and spacing for general intraday chart analysis.

SWING – uses stronger smoothing and wider signal spacing to reduce sensitivity to short-term fluctuations.

Volatility is measured relative to its recent ATR average. This volatility relationship is used as a blending weight between faster and smoother oscillator calculations.

The objective is to adjust the oscillator's visual rhythm while maintaining fixed calculation branches suitable for Pine Script execution.

Directional Balance

An adaptive directional-balance calculation compares the position of price within a recent high-low range.

The observation length changes according to a price-efficiency measurement. More directional movement and less efficient movement can therefore produce different observation lengths.

The resulting balance value is used as additional context when evaluating bullish and bearish conditions.

Market Context Filters

Optional context filters are included to reduce signals that occur without sufficient supporting conditions.

Higher-Timeframe Context compares higher-timeframe price with a smoothed higher-timeframe basis.

Structure Context evaluates confirmed pivot progression and recent range expansion.

Directional Context evaluates the current bullish or bearish dominance calculation.

Compressed Regime Filter identifies conditions where both trend separation and ATR are relatively contracted.

These components are intentionally used as contextual filters rather than plotted as separate indicators. Their purpose is to support the oscillator's displacement and rotation logic.

Context Score

The script calculates a deterministic Context Score from directional dominance, directional acceleration, and normalized impulse.

This value is a composite technical score. It is not a statistical probability, prediction, or historical win-rate measurement.

The Minimum Context Score input allows the user to control the amount of directional activity required for primary signal evaluation.

Red and Green Dots

Small dots are plotted directly on the oscillator line to identify filtered changes in oscillator direction.

A green dot marks a change in the smoothed oscillator slope from non-positive to positive.

A red dot marks a change in the smoothed oscillator slope from non-negative to negative.

The dot engine uses mode-dependent smoothing and minimum bar spacing to reduce reactions to minor oscillator fluctuations.

Dots follow an alternating directional sequence so repeated dots of the same colour are suppressed until an opposite directional event occurs.

The dots are analytical rotation markers and should be interpreted together with price structure and the broader chart context.

BUY and SELL Markers

Primary BUY and SELL markers use stricter conditions than the red and green dots.

The oscillator must first reach or recently leave a defined displacement area. Directional rotation, the internally smoothed oscillator trend, selected context conditions, Context Score, and market-regime conditions are then evaluated.

Three Signal Modes are available:

EARLY – uses shallower displacement requirements and less contextual agreement.

BALANCED – provides a middle setting between responsiveness and filtering.

SELECTIVE – requires deeper displacement and greater contextual agreement.

When the Alternate BUY / SELL Sequence option is enabled, repeated primary signals in the same direction are suppressed until an opposite primary signal occurs.

A minimum bar-spacing control is also applied to the primary signal sequence.

Closed-Bar and Higher-Timeframe Handling

When Signals On Closed Bars Only is enabled, signal conditions are evaluated on completed chart bars.

For higher-timeframe context, the script uses completed higher-timeframe values when closed-bar mode is active.

If closed-bar mode is disabled, live higher-timeframe values may change while the higher-timeframe candle is still developing.

Visual Interpretation

The blue oscillator line represents the combined normalized displacement and directional-pressure calculation.

Values above zero generally indicate positive composite pressure, while values below zero generally indicate negative composite pressure.

The optional upper and lower reference bands provide visual displacement references. They should not automatically be interpreted as conventional overbought or oversold levels.

Green and red dots identify filtered oscillator rotations.

BUY and SELL labels identify stronger analytical events where displacement, rotation, and the selected contextual conditions align.

Intended Use

SBP Structured Oscillator is designed as a technical analysis and decision-support tool.

It may be used to study:

• Changes in directional momentum
• Extended price displacement
• Oscillator rotation
• Trend and momentum alignment
• Higher-timeframe context
• Market compression and expansion behaviour

The indicator is not a strategy and does not execute trades.

Signals and markers are generated from deterministic technical conditions based on historical and current chart data. They do not predict future price movement or guarantee a market outcome.

Users should evaluate the indicator together with their own analysis, risk management, and testing process.

Disclaimer

This indicator is provided for educational and analytical purposes only. It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

Trading and investing involve risk. Historical chart behaviour and indicator signals do not guarantee future results.

## Source Code

````pine
//@version=6
indicator("SBP Structured Oscillator", overlay = false, precision = 1, max_lines_count = 500, max_labels_count = 300)

clamp(float value, float lower, float upper) =>
    math.max(lower, math.min(upper, value))

groupCalculation = "Calculation"
groupLevels = "Reference Levels"
groupDivergence = "Divergence"

pathLength = input.int(12, "Price-Path Length", minval = 5, maxval = 50, group = groupCalculation)
normalizationLength = input.int(40, "Normalization Length", minval = 20, maxval = 150, group = groupCalculation)
directionalSmoothing = input.int(5, "Directional Smoothing", minval = 2, maxval = 15, group = groupCalculation)
visualSmoothing = input.int(4, "Visual Smoothing", minval = 2, maxval = 10, group = groupCalculation)
trendConfirmationBars = input.int(2, "Trend Confirmation Bars", minval = 1, maxval = 5, group = groupCalculation)

showUpperLevel = input.bool(true, "Show Upper Level", group = groupLevels)
showMiddleLevel = input.bool(true, "Show Middle Level", group = groupLevels)
showLowerLevel = input.bool(true, "Show Lower Level", group = groupLevels)
referenceBase = input.float(67.0, "Reference Base", minval = 10.0, maxval = 100.0, step = 1.0, group = groupLevels)
upperLevelColor = input.color(color.red, "Upper Level Colour", group = groupLevels)
middleLevelColor = input.color(color.gray, "Middle Level Colour", group = groupLevels)
lowerLevelColor = input.color(color.green, "Lower Level Colour", group = groupLevels)
upperLevelWidth = input.int(1, "Upper Level Width", minval = 1, maxval = 4, group = groupLevels)
middleLevelWidth = input.int(1, "Middle Level Width", minval = 1, maxval = 4, group = groupLevels)
lowerLevelWidth = input.int(1, "Lower Level Width", minval = 1, maxval = 4, group = groupLevels)

showRegularDivergence = input.bool(true, "Show Regular Divergence", group = groupDivergence)
showHiddenDivergence = input.bool(true, "Show Hidden Divergence", group = groupDivergence)
showDivergenceLines = input.bool(true, "Show Divergence Lines", group = groupDivergence)
showDirectionDots = input.bool(true, "Show Direction Dots", group = groupDivergence)
pivotLeft = input.int(3, "Pivot Left Bars", minval = 2, maxval = 10, group = groupDivergence)
pivotRight = input.int(2, "Pivot Right Bars", minval = 1, maxval = 6, group = groupDivergence)
minimumSwingDistance = input.int(3, "Minimum Swing Distance", minval = 2, maxval = 20, group = groupDivergence)
maximumSwingDistance = input.int(120, "Maximum Swing Distance", minval = 20, maxval = 300, group = groupDivergence)
divergenceLineWidth = input.int(2, "Divergence Line Width", minval = 1, maxval = 4, group = groupDivergence)
bullishDivergenceColor = input.color(color.green, "Bullish Divergence Colour", group = groupDivergence)
bearishDivergenceColor = input.color(color.red, "Bearish Divergence Colour", group = groupDivergence)

int atrLength = 14
float middleReference = 0.0
float pressureWeight = 34.0
float efficiencyWeight = 28.0
float displacementWeight = 12.0
float referenceWeight = 14.0
float locationWeight = 6.0
float developingConfidenceThreshold = 55.0
float strongConfidenceThreshold = 78.0

upperReference = referenceBase
lowerReference = -referenceBase
atrValue = ta.atr(atrLength)
safeATR = math.max(atrValue, syminfo.mintick)
oneBarMovement = math.abs(ta.change(close))
netMovement = math.abs(close - close[pathLength])
totalMovement = nz(math.sum(oneBarMovement, pathLength), 0.0)
pathEfficiency = totalMovement > 0.0 ? math.min(netMovement / totalMovement, 1.0) : 0.0
signedEfficiency = close >= close[pathLength] ? pathEfficiency : -pathEfficiency
marketNoise = 1.0 - pathEfficiency
barRange = math.max(high - low, syminfo.mintick)
closeLocation = ((close - low) - (high - close)) / barRange
fastConstant = 2.0 / 4.0
slowConstant = 2.0 / 35.0
adaptiveFactor = math.pow(pathEfficiency * (fastConstant - slowConstant) + slowConstant, 2)
var float adaptiveReference = na
adaptiveReference := na(adaptiveReference[1]) ? close : adaptiveReference[1] + adaptiveFactor * (close - adaptiveReference[1])
referenceSlope = ta.ema((adaptiveReference - adaptiveReference[1]) / safeATR, 3)
channelWidth = 0.65 + marketNoise * 0.85
upperPriceChannel = ta.ema(adaptiveReference + atrValue * channelWidth, 3)
lowerPriceChannel = ta.ema(adaptiveReference - atrValue * channelWidth, 3)
channelSpan = math.max(upperPriceChannel - lowerPriceChannel, syminfo.mintick)
channelPressure = clamp((close - adaptiveReference) / (channelSpan * 0.5), -1.0, 1.0)
pressureSlope = ta.ema(channelPressure - channelPressure[1], 3)
normalizedDisplacement = (close - adaptiveReference) / safeATR
displacementMean = ta.sma(normalizedDisplacement, normalizationLength)
displacementDeviation = ta.stdev(normalizedDisplacement, normalizationLength)
displacementScore = displacementDeviation > 0.0 ? (normalizedDisplacement - displacementMean) / displacementDeviation : 0.0
pressureComponent = channelPressure * pressureWeight
efficiencyComponent = signedEfficiency * efficiencyWeight
displacementComponent = clamp(displacementScore, -2.0, 2.0) * displacementWeight
referenceComponent = clamp(referenceSlope * 4.0, -1.0, 1.0) * referenceWeight
locationComponent = closeLocation * locationWeight
rawPressure = pressureComponent + efficiencyComponent + displacementComponent + referenceComponent + locationComponent
boundedPressure = clamp(rawPressure, -100.0, 100.0)
firstSmooth = ta.ema(boundedPressure, directionalSmoothing)
oscillatorCore = ta.ema(firstSmooth, 3)
oscillator = ta.ema(oscillatorCore, visualSmoothing)
oscillatorVelocity = oscillatorCore - oscillatorCore[1]
trendSlope = ta.ema(oscillatorVelocity, 3)

bullishEvidence = oscillator > middleReference and trendSlope > 0.0 and channelPressure > 0.0 and pressureSlope >= 0.0 and referenceSlope >= 0.0
bearishEvidence = oscillator < middleReference and trendSlope < 0.0 and channelPressure < 0.0 and pressureSlope <= 0.0 and referenceSlope <= 0.0
bullishRecovery = oscillator > oscillator[1] and trendSlope > trendSlope[1] and channelPressure > channelPressure[1] and close > adaptiveReference
bearishRecovery = oscillator < oscillator[1] and trendSlope < trendSlope[1] and channelPressure < channelPressure[1] and close < adaptiveReference
var int bullishEvidenceCount = 0
var int bearishEvidenceCount = 0
bullishEvidenceCount := bullishEvidence or bullishRecovery ? nz(bullishEvidenceCount[1]) + 1 : 0
bearishEvidenceCount := bearishEvidence or bearishRecovery ? nz(bearishEvidenceCount[1]) + 1 : 0
bullishStateConfirmation = barstate.isconfirmed and bullishEvidenceCount >= trendConfirmationBars
bearishStateConfirmation = barstate.isconfirmed and bearishEvidenceCount >= trendConfirmationBars
var int trendState = 0
if bullishStateConfirmation and not bearishStateConfirmation
    trendState := 1
else if bearishStateConfirmation and not bullishStateConfirmation
    trendState := -1
else if trendState == 0
    trendState := oscillator >= middleReference ? 1 : -1

oscillatorPivotLow = ta.pivotlow(oscillator, pivotLeft, pivotRight)
oscillatorPivotHigh = ta.pivothigh(oscillator, pivotLeft, pivotRight)
lowPivotConfirmed = not na(oscillatorPivotLow)
highPivotConfirmed = not na(oscillatorPivotHigh)
pivotBar = bar_index - pivotRight

var int pendingSwingType = 0
var int pendingSwingBar = na
var float pendingSwingOscillator = na
var float pendingSwingPrice = na
var float pendingSwingPressure = na
var float pendingSwingPressureSlope = na
var float pendingSwingTrendSlope = na
var float pendingSwingReferenceSlope = na
var float pendingSwingEfficiency = na
var float pendingSwingATR = na
var int pendingSwingTrendState = 0

var int previousLowBar = na
var float previousLowOscillator = na
var float previousLowPrice = na
var float previousLowPressure = na

var int previousHighBar = na
var float previousHighOscillator = na
var float previousHighPrice = na
var float previousHighPressure = na

bool finalizeLowSwing = false
bool finalizeHighSwing = false

int finalizedBar = na
float finalizedOscillator = na
float finalizedPrice = na
float finalizedPressure = na
float finalizedPressureSlope = na
float finalizedTrendSlope = na
float finalizedReferenceSlope = na
float finalizedEfficiency = na
float finalizedATR = na
int finalizedTrendState = 0

if pendingSwingType == 0
    if lowPivotConfirmed and not highPivotConfirmed
        pendingSwingType := -1
        pendingSwingBar := pivotBar
        pendingSwingOscillator := oscillatorPivotLow
        pendingSwingPrice := low[pivotRight]
        pendingSwingPressure := channelPressure[pivotRight]
        pendingSwingPressureSlope := pressureSlope[pivotRight]
        pendingSwingTrendSlope := trendSlope[pivotRight]
        pendingSwingReferenceSlope := referenceSlope[pivotRight]
        pendingSwingEfficiency := pathEfficiency[pivotRight]
        pendingSwingATR := math.max(atrValue[pivotRight], syminfo.mintick)
        pendingSwingTrendState := trendState[pivotRight]
    else if highPivotConfirmed
        pendingSwingType := 1
        pendingSwingBar := pivotBar
        pendingSwingOscillator := oscillatorPivotHigh
        pendingSwingPrice := high[pivotRight]
        pendingSwingPressure := channelPressure[pivotRight]
        pendingSwingPressureSlope := pressureSlope[pivotRight]
        pendingSwingTrendSlope := trendSlope[pivotRight]
        pendingSwingReferenceSlope := referenceSlope[pivotRight]
        pendingSwingEfficiency := pathEfficiency[pivotRight]
        pendingSwingATR := math.max(atrValue[pivotRight], syminfo.mintick)
        pendingSwingTrendState := trendState[pivotRight]

else if pendingSwingType == -1
    if lowPivotConfirmed and oscillatorPivotLow < pendingSwingOscillator
        pendingSwingBar := pivotBar
        pendingSwingOscillator := oscillatorPivotLow
        pendingSwingPrice := low[pivotRight]
        pendingSwingPressure := channelPressure[pivotRight]
        pendingSwingPressureSlope := pressureSlope[pivotRight]
        pendingSwingTrendSlope := trendSlope[pivotRight]
        pendingSwingReferenceSlope := referenceSlope[pivotRight]
        pendingSwingEfficiency := pathEfficiency[pivotRight]
        pendingSwingATR := math.max(atrValue[pivotRight], syminfo.mintick)
        pendingSwingTrendState := trendState[pivotRight]

    if highPivotConfirmed
        finalizeLowSwing := true
        finalizedBar := pendingSwingBar
        finalizedOscillator := pendingSwingOscillator
        finalizedPrice := pendingSwingPrice
        finalizedPressure := pendingSwingPressure
        finalizedPressureSlope := pendingSwingPressureSlope
        finalizedTrendSlope := pendingSwingTrendSlope
        finalizedReferenceSlope := pendingSwingReferenceSlope
        finalizedEfficiency := pendingSwingEfficiency
        finalizedATR := pendingSwingATR
        finalizedTrendState := pendingSwingTrendState

        pendingSwingType := 1
        pendingSwingBar := pivotBar
        pendingSwingOscillator := oscillatorPivotHigh
        pendingSwingPrice := high[pivotRight]
        pendingSwingPressure := channelPressure[pivotRight]
        pendingSwingPressureSlope := pressureSlope[pivotRight]
        pendingSwingTrendSlope := trendSlope[pivotRight]
        pendingSwingReferenceSlope := referenceSlope[pivotRight]
        pendingSwingEfficiency := pathEfficiency[pivotRight]
        pendingSwingATR := math.max(atrValue[pivotRight], syminfo.mintick)
        pendingSwingTrendState := trendState[pivotRight]

else
    if highPivotConfirmed and oscillatorPivotHigh > pendingSwingOscillator
        pendingSwingBar := pivotBar
        pendingSwingOscillator := oscillatorPivotHigh
        pendingSwingPrice := high[pivotRight]
        pendingSwingPressure := channelPressure[pivotRight]
        pendingSwingPressureSlope := pressureSlope[pivotRight]
        pendingSwingTrendSlope := trendSlope[pivotRight]
        pendingSwingReferenceSlope := referenceSlope[pivotRight]
        pendingSwingEfficiency := pathEfficiency[pivotRight]
        pendingSwingATR := math.max(atrValue[pivotRight], syminfo.mintick)
        pendingSwingTrendState := trendState[pivotRight]

    if lowPivotConfirmed
        finalizeHighSwing := true
        finalizedBar := pendingSwingBar
        finalizedOscillator := pendingSwingOscillator
        finalizedPrice := pendingSwingPrice
        finalizedPressure := pendingSwingPressure
        finalizedPressureSlope := pendingSwingPressureSlope
        finalizedTrendSlope := pendingSwingTrendSlope
        finalizedReferenceSlope := pendingSwingReferenceSlope
        finalizedEfficiency := pendingSwingEfficiency
        finalizedATR := pendingSwingATR
        finalizedTrendState := pendingSwingTrendState

        pendingSwingType := -1
        pendingSwingBar := pivotBar
        pendingSwingOscillator := oscillatorPivotLow
        pendingSwingPrice := low[pivotRight]
        pendingSwingPressure := channelPressure[pivotRight]
        pendingSwingPressureSlope := pressureSlope[pivotRight]
        pendingSwingTrendSlope := trendSlope[pivotRight]
        pendingSwingReferenceSlope := referenceSlope[pivotRight]
        pendingSwingEfficiency := pathEfficiency[pivotRight]
        pendingSwingATR := math.max(atrValue[pivotRight], syminfo.mintick)
        pendingSwingTrendState := trendState[pivotRight]

bool bullishDivergence = false
bool bearishDivergence = false
float bullConfidence = 0.0
float bearConfidence = 0.0

if finalizeLowSwing
    lowDistance = na(previousLowBar) ? 0 : finalizedBar - previousLowBar
    lowDistanceValid = lowDistance >= minimumSwingDistance and lowDistance <= maximumSwingDistance
    regularBullish = showRegularDivergence and not na(previousLowPrice) and lowDistanceValid and finalizedPrice < previousLowPrice and finalizedOscillator > previousLowOscillator
    hiddenBullish = showHiddenDivergence and not na(previousLowPrice) and lowDistanceValid and finalizedPrice > previousLowPrice and finalizedOscillator < previousLowOscillator and finalizedTrendState == 1
    bullishDivergence := barstate.isconfirmed and (regularBullish or hiddenBullish)

    if not na(previousLowOscillator)
        bullOscillatorStrength = clamp(math.abs(finalizedOscillator - previousLowOscillator) / 30.0, 0.0, 1.0) * 25.0
        bullPriceStrength = clamp(math.abs(finalizedPrice - previousLowPrice) / (finalizedATR * 2.0), 0.0, 1.0) * 20.0
        bullPressureStrength = clamp((finalizedPressure - previousLowPressure + 1.0) * 0.5, 0.0, 1.0) * 15.0
        bullEfficiencyStrength = clamp(finalizedEfficiency, 0.0, 1.0) * 15.0
        bullStructureStrength = (finalizedTrendSlope > 0.0 ? 5.0 : 0.0) + (finalizedReferenceSlope > 0.0 ? 5.0 : 0.0)
        bullLocationStrength = clamp((-finalizedOscillator + 20.0) / 90.0, 0.0, 1.0) * 10.0
        bullTurnStrength = clamp(finalizedPressureSlope * 8.0 + 0.5, 0.0, 1.0) * 5.0
        bullConfidence := clamp(bullOscillatorStrength + bullPriceStrength + bullPressureStrength + bullEfficiencyStrength + bullStructureStrength + bullLocationStrength + bullTurnStrength, 0.0, 100.0)

    if bullishDivergence
        if showDivergenceLines
            line.new(previousLowBar, previousLowOscillator, finalizedBar, finalizedOscillator, xloc = xloc.bar_index, extend = extend.none, color = bullishDivergenceColor, style = line.style_solid, width = divergenceLineWidth)
        if showDirectionDots
            label.new(finalizedBar, finalizedOscillator - 2.0, "⬤", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(color.black, 100), style = label.style_none, textcolor = bullishDivergenceColor, size = size.normal)

    previousLowBar := finalizedBar
    previousLowOscillator := finalizedOscillator
    previousLowPrice := finalizedPrice
    previousLowPressure := finalizedPressure

if finalizeHighSwing
    highDistance = na(previousHighBar) ? 0 : finalizedBar - previousHighBar
    highDistanceValid = highDistance >= minimumSwingDistance and highDistance <= maximumSwingDistance
    regularBearish = showRegularDivergence and not na(previousHighPrice) and highDistanceValid and finalizedPrice > previousHighPrice and finalizedOscillator < previousHighOscillator
    hiddenBearish = showHiddenDivergence and not na(previousHighPrice) and highDistanceValid and finalizedPrice < previousHighPrice and finalizedOscillator > previousHighOscillator and finalizedTrendState == -1
    bearishDivergence := barstate.isconfirmed and (regularBearish or hiddenBearish)

    if not na(previousHighOscillator)
        bearOscillatorStrength = clamp(math.abs(finalizedOscillator - previousHighOscillator) / 30.0, 0.0, 1.0) * 25.0
        bearPriceStrength = clamp(math.abs(finalizedPrice - previousHighPrice) / (finalizedATR * 2.0), 0.0, 1.0) * 20.0
        bearPressureStrength = clamp((previousHighPressure - finalizedPressure + 1.0) * 0.5, 0.0, 1.0) * 15.0
        bearEfficiencyStrength = clamp(finalizedEfficiency, 0.0, 1.0) * 15.0
        bearStructureStrength = (finalizedTrendSlope < 0.0 ? 5.0 : 0.0) + (finalizedReferenceSlope < 0.0 ? 5.0 : 0.0)
        bearLocationStrength = clamp((finalizedOscillator + 70.0) / 90.0, 0.0, 1.0) * 10.0
        bearTurnStrength = clamp(-finalizedPressureSlope * 8.0 + 0.5, 0.0, 1.0) * 5.0
        bearConfidence := clamp(bearOscillatorStrength + bearPriceStrength + bearPressureStrength + bearEfficiencyStrength + bearStructureStrength + bearLocationStrength + bearTurnStrength, 0.0, 100.0)

    if bearishDivergence
        if showDivergenceLines
            line.new(previousHighBar, previousHighOscillator, finalizedBar, finalizedOscillator, xloc = xloc.bar_index, extend = extend.none, color = bearishDivergenceColor, style = line.style_solid, width = divergenceLineWidth)
        if showDirectionDots
            label.new(finalizedBar, finalizedOscillator + 2.0, "⬤", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(color.black, 100), style = label.style_none, textcolor = bearishDivergenceColor, size = size.normal)

    previousHighBar := finalizedBar
    previousHighOscillator := finalizedOscillator
    previousHighPrice := finalizedPrice
    previousHighPressure := finalizedPressure

strongBullishDivergence = bullishDivergence and bullConfidence >= strongConfidenceThreshold
strongBearishDivergence = bearishDivergence and bearConfidence >= strongConfidenceThreshold
earlyBullishDivergence = bullishDivergence and bullConfidence >= developingConfidenceThreshold and bullConfidence < strongConfidenceThreshold
earlyBearishDivergence = bearishDivergence and bearConfidence >= developingConfidenceThreshold and bearConfidence < strongConfidenceThreshold

plot(oscillator, "Structured Oscillator", color = color.blue, linewidth = 2)
plot(showUpperLevel ? upperReference : na, "Upper Reference", color = upperLevelColor, linewidth = upperLevelWidth)
plot(showMiddleLevel ? middleReference : na, "Middle Reference", color = middleLevelColor, linewidth = middleLevelWidth)
plot(showLowerLevel ? lowerReference : na, "Lower Reference", color = lowerLevelColor, linewidth = lowerLevelWidth)

alertcondition(strongBullishDivergence, "SBP Structured Oscillator BUY", "SBP Structured Oscillator: confirmed high-confidence bullish divergence")
alertcondition(strongBearishDivergence, "SBP Structured Oscillator SELL", "SBP Structured Oscillator: confirmed high-confidence bearish divergence")
alertcondition(earlyBullishDivergence, "SBP Structured Oscillator Early BUY", "SBP Structured Oscillator: confirmed developing bullish divergence")
alertcondition(earlyBearishDivergence, "SBP Structured Oscillator Early SELL", "SBP Structured Oscillator: confirmed developing bearish divergence")
````
