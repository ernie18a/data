# SBP Price Response Engine

- url: https://www.tradingview.com/script/F3DWyeKP-SBP-Price-Response-Engine/
- type: indicator
- pine_id: PUB;0996b126f210404eaf96f464238ed129
- version: 2.0

## Description

SBP Price Response Engine is a rule-based analytical indicator that evaluates how price responds to confirmed market reference levels. Rather than attempting to predict future direction or continuously follow trends, the indicator studies completed price interaction around established reference areas and identifies qualified bullish or bearish response observations after objective confirmation.

The methodology is based on the concept that significant price movements are often preceded by measurable interactions with previously confirmed price references. Instead of treating every touch of a level as equally meaningful, the indicator evaluates the quality of the interaction before displaying a BUY or SALE observation.

Methodology

The analytical workflow begins by building dynamic price references from confirmed pivot recurrence. Nearby confirmed pivots are merged into evolving reference zones, allowing the indicator to develop market memory that adapts as additional confirmations occur. References mature over time as they receive additional confirmation while automatically discarding stale levels that no longer remain relevant.

Each completed bar is then evaluated against these active references using several independent response models. Rather than relying on a single condition, the indicator measures different categories of observable market behaviour, including:

Controlled rejection after limited penetration
Closing acceptance beyond a reference
Timely recovery following an accepted break
Decisive directional displacement
Repeated pressure release near active references
Delayed break confirmation using short-term reference memory
Confirmed pivot-response events

Every response family is evaluated independently before contributing to the final analytical decision. The qualification process considers multiple objective measurements, including:

Candle body structure
Upper and lower wick characteristics
Closing location within the candle
ATR-normalized penetration and displacement
Reference maturity
Local price expansion
Optional relative-volume participation

Each response receives an internally calculated quality score. Only observations satisfying their respective qualification requirements become eligible for the final signal-routing process.

Signal Routing

All qualified response families are processed through a unified decision engine rather than operating as independent indicators. The routing process combines the qualified analytical observations into a single BUY or SALE output while enforcing signal alternation and a minimum spacing between consecutive observations. This helps reduce repeated indications during persistent directional movement while maintaining continuous internal analysis of every completed bar.

Visual Output

The indicator can display:

Dynamic upper and lower price reference lines
Qualified BUY observations
Qualified SALE observations
Confirmed pivot-response observations
Alert conditions for all supported analytical event families

The visual output is intentionally designed to remain uncluttered while presenting only qualified analytical observations.

Inputs

Users can adjust several analytical parameters, including:

Reference confirmation depth
Reference clustering tolerance
Minimum reference confirmations
Maximum reference age
Penetration requirements
Recovery requirements
Acceptance confirmation
Recovery window
Minimum response quality
Optional relative-volume participation
Display of reference lines and observations

These settings allow users to adapt the analytical sensitivity without altering the underlying methodology.

Notes

SBP Price Response Engine is an analytical indicator, not a trading strategy. It does not place trades, calculate position sizing, manage portfolio risk, estimate profitability, or predict future price movement. All observations are generated from completed market data according to predefined analytical rules.

Like any technical analysis tool, the indicator should be used alongside independent market analysis, risk management, and appropriate trading discipline.

## Source Code

````pine
//@version=6
indicator("SBP Price Response Engine", overlay=true, behind_chart=false, max_labels_count=250, max_lines_count=500)
// HELPERS
f_clamp(float value, float lowLimit, float highLimit) =>
    math.max(lowLimit, math.min(value, highLimit))
f_ratio(float numerator, float denominator) =>
    denominator != 0.0 ? numerator / denominator : 0.0
// DISPLAY
groupDisplay = "01. Display"
showDirectionalChannel = input.bool(true, "Directional Strength Channel", group=groupDisplay)
showPriceReferences = input.bool(true, "Price Reference Lines", group=groupDisplay)
showAdaptiveEnvelope = input.bool(false, "Adaptive Participation Envelope", group=groupDisplay)
showSignals = input.bool(true, "Buy / Sale Signals", group=groupDisplay)
// SIGNAL AND CHANNEL COLOURS
groupColours = "02. Signal & Channel Colours"
buySignalColor = input.color(color.rgb(20, 150, 105), "Buy Signal", group=groupColours)
saleSignalColor = input.color(color.rgb(185, 55, 65), "Sale Signal", group=groupColours)
bullChannelFill = input.color(color.new(color.blue, 45), "Bullish Channel Fill", group=groupColours)
bearChannelFill = input.color(color.new(color.red, 45), "Bearish Channel Fill", group=groupColours)
// LINE STYLE
groupLines = "03. Line Style"
upperReferenceColor = input.color(color.rgb(185, 55, 65), "Upper Reference Colour", group=groupLines)
upperReferenceWidth = input.int(2, "Upper Reference Width", minval=1, maxval=5, group=groupLines)
lowerReferenceColor = input.color(color.rgb(20, 150, 105), "Lower Reference Colour", group=groupLines)
lowerReferenceWidth = input.int(2, "Lower Reference Width", minval=1, maxval=5, group=groupLines)
upperEnvelopeColor = input.color(color.rgb(210, 110, 70), "Upper Envelope Colour", group=groupLines)
upperEnvelopeWidth = input.int(1, "Upper Envelope Width", minval=1, maxval=5, group=groupLines)
lowerEnvelopeColor = input.color(color.rgb(65, 145, 210), "Lower Envelope Colour", group=groupLines)
lowerEnvelopeWidth = input.int(1, "Lower Envelope Width", minval=1, maxval=5, group=groupLines)
bullChannelBorderColor = input.color(color.rgb(45, 120, 220), "Bullish Channel Border Colour", group=groupLines)
bullChannelBorderWidth = input.int(1, "Bullish Channel Border Width", minval=1, maxval=5, group=groupLines)
bearChannelBorderColor = input.color(color.rgb(210, 70, 80), "Bearish Channel Border Colour", group=groupLines)
bearChannelBorderWidth = input.int(1, "Bearish Channel Border Width", minval=1, maxval=5, group=groupLines)
// INTERNAL CALIBRATION
pivotDepth = 8
clusterToleranceATR = 0.38
maximumReferenceAge = 500
structureLength = 180
liquidityLookback = 8
microLookback = 3
pressureLength = 14
trendLength = 34
liquidityPressureLength = 18
behaviourLength = 16
outerParticipationFactor = 1.88
// CONFIRMED BAR GEOMETRY
barReady = barstate.isconfirmed
atr = ta.atr(14)
barRange = math.max(high - low, syminfo.mintick)
bodyHigh = math.max(open, close)
bodyLow = math.min(open, close)
bodySize = math.abs(close - open)
bodyRatio = f_ratio(bodySize, barRange)
upperWick = high - bodyHigh
lowerWick = bodyLow - low
upperWickRatio = f_ratio(upperWick, barRange)
lowerWickRatio = f_ratio(lowerWick, barRange)
bullCloseLocation = f_ratio(close - low, barRange)
bearCloseLocation = f_ratio(high - close, barRange)
bullCandle = close > open
bearCandle = close < open
// DEVELOPING PARTICIPATION STATE
volumeAverage = ta.sma(volume, 20)
hasUsableVolume = not na(volume) and volume > 0 and not na(volumeAverage) and volumeAverage > 0
effectiveVolume = hasUsableVolume ? volume : 1.0
relativeVolume = hasUsableVolume ? volume / volumeAverage : 1.0
participationExpansion = not hasUsableVolume or relativeVolume >= 1.02
rawVolumeCenter = ta.vwma(hlc3, structureLength)
fallbackCenter = ta.ema(hlc3, structureLength)
volumeCenter = na(rawVolumeCenter) ? fallbackCenter : rawVolumeCenter
priceDeviation = ta.stdev(hlc3, structureLength)
structureDeviation = math.max(nz(priceDeviation, atr), atr * 0.55)
signedParticipation = effectiveVolume * ((bullCloseLocation - 0.50) * 2.0)
participationBase = ta.ema(effectiveVolume, 14)
participationBiasRaw = f_ratio(ta.ema(signedParticipation, 14), participationBase)
participationBias = f_clamp(participationBiasRaw, -1.0, 1.0)
centerSlopeRaw = f_ratio(volumeCenter - volumeCenter[1], atr)
centerSlope = f_clamp(centerSlopeRaw, -1.0, 1.0)
displacementRaw = f_ratio(close - volumeCenter, structureDeviation)
structureDisplacement = f_clamp(displacementRaw, -1.0, 1.0)
directionalEvidence = participationBias * 0.45 + centerSlope * 0.30 + structureDisplacement * 0.25
// CONTROL AND VALUE STRUCTURE
dynamicControl = volumeCenter + structureDeviation * participationBias * 0.32
controlHalfWidth = math.max(structureDeviation * 0.20, atr * 0.18)
dynamicControlUpper = dynamicControl + controlHalfWidth
dynamicControlLower = dynamicControl - controlHalfWidth
valueHalfWidth = math.max(structureDeviation * 0.55, atr * 0.48)
valueUpper = volumeCenter + valueHalfWidth
valueLower = volumeCenter - valueHalfWidth
// SESSION STATE
newSession = timeframe.change("D")
var int sessionStartBar = na
if na(sessionStartBar)
    sessionStartBar := bar_index
if newSession
    sessionStartBar := bar_index
var float sessionControl = na
var float sessionControlUpper = na
var float sessionControlLower = na
if barReady and (na(sessionControl) or newSession)
    sessionControl := dynamicControl
    sessionControlUpper := dynamicControlUpper
    sessionControlLower := dynamicControlLower
// ADAPTIVE PARTICIPATION ENVELOPE
var float sessionVolumeSum = 0.0
var float sessionPriceVolumeSum = 0.0
var float sessionPriceSquaredVolumeSum = 0.0
if newSession
    sessionVolumeSum := 0.0
    sessionPriceVolumeSum := 0.0
    sessionPriceSquaredVolumeSum := 0.0
if barReady
    sessionVolumeSum += effectiveVolume
    sessionPriceVolumeSum += hlc3 * effectiveVolume
    sessionPriceSquaredVolumeSum += hlc3 * hlc3 * effectiveVolume
sessionParticipationMean = sessionVolumeSum > 0.0 ? sessionPriceVolumeSum / sessionVolumeSum : hlc3
sessionSecondMoment = sessionVolumeSum > 0.0 ? sessionPriceSquaredVolumeSum / sessionVolumeSum : hlc3 * hlc3
sessionVariance = math.max(sessionSecondMoment - sessionParticipationMean * sessionParticipationMean, 0.0)
sessionParticipationDeviation = math.sqrt(sessionVariance)
adaptiveEnvelopeDistance = math.max(sessionParticipationDeviation * outerParticipationFactor, atr * 0.65)
adaptiveEnvelopeUpper = sessionParticipationMean + adaptiveEnvelopeDistance
adaptiveEnvelopeLower = sessionParticipationMean - adaptiveEnvelopeDistance
upperEnvelopeRejection = high >= adaptiveEnvelopeUpper and close < adaptiveEnvelopeUpper and upperWickRatio >= 0.25
lowerEnvelopeRejection = low <= adaptiveEnvelopeLower and close > adaptiveEnvelopeLower and lowerWickRatio >= 0.25
// CONFIRMED PRICE REFERENCE MEMORY
pivotHigh = ta.pivothigh(high, pivotDepth, pivotDepth)
pivotLow = ta.pivotlow(low, pivotDepth, pivotDepth)
pivotBar = bar_index - pivotDepth
clusterDistance = atr * clusterToleranceATR
var float upperReference = na
var float lowerReference = na
var int upperStrength = 0
var int lowerStrength = 0
var int upperCreatedBar = na
var int lowerCreatedBar = na
if not na(pivotHigh)
    mergeUpper = not na(upperReference) and math.abs(pivotHigh - upperReference) <= clusterDistance[pivotDepth]
    if mergeUpper
        upperReference := (upperReference * upperStrength + pivotHigh) / (upperStrength + 1)
        upperStrength += 1
    else
        upperReference := pivotHigh
        upperStrength := 1
    upperCreatedBar := pivotBar
if not na(pivotLow)
    mergeLower = not na(lowerReference) and math.abs(pivotLow - lowerReference) <= clusterDistance[pivotDepth]
    if mergeLower
        lowerReference := (lowerReference * lowerStrength + pivotLow) / (lowerStrength + 1)
        lowerStrength += 1
    else
        lowerReference := pivotLow
        lowerStrength := 1
    lowerCreatedBar := pivotBar
upperAge = na(upperCreatedBar) ? 100000 : bar_index - upperCreatedBar
lowerAge = na(lowerCreatedBar) ? 100000 : bar_index - lowerCreatedBar
upperReady = not na(upperReference) and upperAge <= maximumReferenceAge
lowerReady = not na(lowerReference) and lowerAge <= maximumReferenceAge
upperDistanceATR = upperReady and atr > 0.0 ? math.abs(upperReference - close) / atr : 100000.0
lowerDistanceATR = lowerReady and atr > 0.0 ? math.abs(lowerReference - close) / atr : 100000.0
upperVisible = upperReady and upperDistanceATR <= 12.0
lowerVisible = lowerReady and lowerDistanceATR <= 12.0
referenceRejectBuy = upperReady and high >= upperReference and close < upperReference
referenceRejectSale = lowerReady and low <= lowerReference and close > lowerReference
referenceRoomBuy = not upperReady or close > upperReference or upperReference - close >= atr * 0.35
referenceRoomSale = not lowerReady or close < lowerReference or close - lowerReference >= atr * 0.35
// DIRECTIONAL STRENGTH CHANNEL
channelBasis = ta.ema(hlc3, 7)
channelSlope = f_ratio(channelBasis - channelBasis[1], atr)
channelBull = directionalEvidence >= 0.12 and channelSlope >= -0.01 and close >= volumeCenter
channelBear = directionalEvidence <= -0.12 and channelSlope <= 0.01 and close <= volumeCenter
channelBullStart = barReady and channelBull and not channelBull[1]
channelBearStart = barReady and channelBear and not channelBear[1]
channelWidthRaw = math.max(atr * 0.46, math.abs(close - channelBasis) * 0.66)
channelWidth = math.min(channelWidthRaw, atr * 1.05)
float bullChannelUpper = na
float bullChannelLower = na
float bearChannelUpper = na
float bearChannelLower = na
if channelBull
    bullChannelUpper := channelBasis + channelWidth
    bullChannelLower := channelBasis
if channelBear
    bearChannelUpper := channelBasis
    bearChannelLower := channelBasis - channelWidth
// PRICE RESPONSE EVENTS
priorLow = ta.lowest(low[1], liquidityLookback)
priorHigh = ta.highest(high[1], liquidityLookback)
microHigh = ta.highest(high[1], microLookback)
microLow = ta.lowest(low[1], microLookback)
bullSweep = barReady and low < priorLow and close > priorLow
bearSweep = barReady and high > priorHigh and close < priorHigh
bullMicroBreak = barReady and bullCandle and close > microHigh
bearMicroBreak = barReady and bearCandle and close < microLow
bullAcceptance = barReady and bullCandle and close > valueUpper and close > sessionControlUpper and directionalEvidence >= 0.17 and bodyRatio >= 0.36 and bullCloseLocation >= 0.63 and participationExpansion
bearAcceptance = barReady and bearCandle and close < valueLower and close < sessionControlLower and directionalEvidence <= -0.17 and bodyRatio >= 0.36 and bearCloseLocation >= 0.63 and participationExpansion
bullReclaim = barReady and bullCandle and low <= sessionControlLower and close > sessionControlUpper and directionalEvidence >= 0.15 and lowerWickRatio > upperWickRatio and bodyRatio >= 0.27
bearReclaim = barReady and bearCandle and high >= sessionControlUpper and close < sessionControlLower and directionalEvidence <= -0.15 and upperWickRatio > lowerWickRatio and bodyRatio >= 0.27
bullLiquidityTurn = bullSweep and bullMicroBreak and directionalEvidence >= 0.13 and close > sessionControl and participationExpansion
bearLiquidityTurn = bearSweep and bearMicroBreak and directionalEvidence <= -0.13 and close < sessionControl and participationExpansion
// INTRADAY RESPONSE CONFIRMATION
intradayEnabled = timeframe.isintraday
estimatedBuyVolume = effectiveVolume * bullCloseLocation
estimatedSaleVolume = effectiveVolume * bearCloseLocation
buyPressure = ta.sma(estimatedBuyVolume, pressureLength)
salePressure = ta.sma(estimatedSaleVolume, pressureLength)
pressureTotal = buyPressure + salePressure
pressureBalance = pressureTotal > 0.0 ? (buyPressure - salePressure) / pressureTotal : 0.0
pressureShift = pressureBalance - nz(pressureBalance[1], pressureBalance)
trendReference = ta.ema(close, trendLength)
trendSlope = trendReference - nz(trendReference[2], trendReference)
pressurePriorHigh = ta.highest(high[1], liquidityPressureLength)
pressurePriorLow = ta.lowest(low[1], liquidityPressureLength)
bullPressureSweep = low < pressurePriorLow and close > pressurePriorLow and bullCloseLocation >= 0.62
bearPressureSweep = high > pressurePriorHigh and close < pressurePriorHigh and bearCloseLocation >= 0.62
bullRejection = lowerWick >= math.max(bodySize, syminfo.mintick) * 0.90 and bullCloseLocation >= 0.62
bearRejection = upperWick >= math.max(bodySize, syminfo.mintick) * 0.90 and bearCloseLocation >= 0.62
bullInitiative = participationExpansion and bullCandle and bodySize >= atr * 0.48 and bullCloseLocation >= 0.72
bearInitiative = participationExpansion and bearCandle and bodySize >= atr * 0.48 and bearCloseLocation >= 0.72
travel = math.abs(ta.change(close))
netTravel = math.abs(close - nz(close[behaviourLength], close))
totalTravel = nz(ta.sma(travel, behaviourLength), 0.0) * behaviourLength
efficiency = totalTravel > 0.0 ? math.min(netTravel / totalTravel, 1.0) : 0.0
fastConstant = 2.0 / 4.0
slowConstant = 2.0 / 35.0
adaptiveConstant = math.pow(efficiency * (fastConstant - slowConstant) + slowConstant, 2.0)
var float behaviourLine = na
behaviourLine := na(behaviourLine[1]) ? close : behaviourLine[1] + adaptiveConstant * (close - behaviourLine[1])
behaviourSlope = behaviourLine - nz(behaviourLine[1], behaviourLine)
behaviourBull = close > behaviourLine and behaviourSlope > 0.0
behaviourBear = close < behaviourLine and behaviourSlope < 0.0
bullScore = 0
bearScore = 0
bullScore += pressureBalance >= 0.06 ? 20 : 0
bullScore += pressureShift >= 0.035 ? 12 : 0
bullScore += bullPressureSweep ? 18 : 0
bullScore += bullRejection ? 10 : 0
bullScore += bullInitiative ? 14 : 0
bullScore += behaviourBull ? 10 : 0
bullScore += trendSlope > 0.0 ? 8 : 0
bullScore += bullMicroBreak ? 15 : 0
bullScore += channelBull ? 12 : 0
bearScore += pressureBalance <= -0.06 ? 20 : 0
bearScore += pressureShift <= -0.035 ? 12 : 0
bearScore += bearPressureSweep ? 18 : 0
bearScore += bearRejection ? 10 : 0
bearScore += bearInitiative ? 14 : 0
bearScore += behaviourBear ? 10 : 0
bearScore += trendSlope < 0.0 ? 8 : 0
bearScore += bearMicroBreak ? 15 : 0
bearScore += channelBear ? 12 : 0
buySupport = intradayEnabled and bullScore >= 62 and bullScore >= bearScore + 7 and (bullPressureSweep or bullInitiative or (bullRejection and pressureShift > 0.0))
saleSupport = intradayEnabled and bearScore >= 62 and bearScore >= bullScore + 7 and (bearPressureSweep or bearInitiative or (bearRejection and pressureShift < 0.0))
// FINAL RESPONSE QUALIFICATION
bullVotes = 0
bearVotes = 0
bullVotes += bullAcceptance ? 2 : 0
bullVotes += bullReclaim ? 2 : 0
bullVotes += bullLiquidityTurn ? 2 : 0
bullVotes += buySupport ? 1 : 0
bullVotes += channelBull ? 1 : 0
bullVotes += directionalEvidence >= 0.19 ? 1 : 0
bearVotes += bearAcceptance ? 2 : 0
bearVotes += bearReclaim ? 2 : 0
bearVotes += bearLiquidityTurn ? 2 : 0
bearVotes += saleSupport ? 1 : 0
bearVotes += channelBear ? 1 : 0
bearVotes += directionalEvidence <= -0.19 ? 1 : 0
strongBullAcceptance = bullAcceptance and directionalEvidence >= 0.22 and bodyRatio >= 0.43
strongBearAcceptance = bearAcceptance and directionalEvidence <= -0.22 and bodyRatio >= 0.43
bullCoreEvent = bullAcceptance or bullReclaim or bullLiquidityTurn
bearCoreEvent = bearAcceptance or bearReclaim or bearLiquidityTurn
buyCandidate = barReady and bullCandle and not channelBear and not referenceRejectBuy and not upperEnvelopeRejection and referenceRoomBuy and (strongBullAcceptance or (bullVotes >= 4 and bullCoreEvent) or (bullVotes >= 3 and bullCoreEvent and buySupport))
saleCandidate = barReady and bearCandle and not channelBull and not referenceRejectSale and not lowerEnvelopeRejection and referenceRoomSale and (strongBearAcceptance or (bearVotes >= 4 and bearCoreEvent) or (bearVotes >= 3 and bearCoreEvent and saleSupport))
bool finalBuyCandidate = buyCandidate
bool finalSaleCandidate = saleCandidate
if finalBuyCandidate and finalSaleCandidate
    if directionalEvidence > 0.0
        finalSaleCandidate := false
    else if directionalEvidence < 0.0
        finalBuyCandidate := false
    else
        finalBuyCandidate := false
        finalSaleCandidate := false
// AUTHORITATIVE BUY / SALE STATE
var int lastSignalDirection = 0
bool buySignal = false
bool saleSignal = false
channelStartBuyReversal = channelBullStart and lastSignalDirection == -1
channelStartSaleReversal = channelBearStart and lastSignalDirection == 1
if barReady
    if channelStartBuyReversal
        buySignal := true
        lastSignalDirection := 1
    else if channelStartSaleReversal
        saleSignal := true
        lastSignalDirection := -1
    else if lastSignalDirection == 0
        if finalBuyCandidate and not finalSaleCandidate
            buySignal := true
            lastSignalDirection := 1
        else if finalSaleCandidate and not finalBuyCandidate
            saleSignal := true
            lastSignalDirection := -1
    else if lastSignalDirection == 1
        if finalSaleCandidate
            saleSignal := true
            lastSignalDirection := -1
    else
        if finalBuyCandidate
            buySignal := true
            lastSignalDirection := 1
// SESSION PRICE REFERENCE LINES
var line sessionUpperReferenceLine = na
var line sessionLowerReferenceLine = na
if newSession
    sessionUpperReferenceLine := na
    sessionLowerReferenceLine := na
if barReady and showPriceReferences
    if upperVisible
        if na(sessionUpperReferenceLine)
            sessionUpperReferenceLine := line.new(sessionStartBar, upperReference, bar_index, upperReference, xloc=xloc.bar_index, extend=extend.none, color=upperReferenceColor, width=upperReferenceWidth, force_overlay=true)
        else
            line.set_xy1(sessionUpperReferenceLine, sessionStartBar, upperReference)
            line.set_xy2(sessionUpperReferenceLine, bar_index, upperReference)
            line.set_color(sessionUpperReferenceLine, upperReferenceColor)
            line.set_width(sessionUpperReferenceLine, upperReferenceWidth)
    if lowerVisible
        if na(sessionLowerReferenceLine)
            sessionLowerReferenceLine := line.new(sessionStartBar, lowerReference, bar_index, lowerReference, xloc=xloc.bar_index, extend=extend.none, color=lowerReferenceColor, width=lowerReferenceWidth, force_overlay=true)
        else
            line.set_xy1(sessionLowerReferenceLine, sessionStartBar, lowerReference)
            line.set_xy2(sessionLowerReferenceLine, bar_index, lowerReference)
            line.set_color(sessionLowerReferenceLine, lowerReferenceColor)
            line.set_width(sessionLowerReferenceLine, lowerReferenceWidth)
if not showPriceReferences
    if not na(sessionUpperReferenceLine)
        line.delete(sessionUpperReferenceLine)
        sessionUpperReferenceLine := na
    if not na(sessionLowerReferenceLine)
        line.delete(sessionLowerReferenceLine)
        sessionLowerReferenceLine := na
// SESSION ADAPTIVE ENVELOPE LINES
var line sessionAdaptiveUpperLine = na
var line sessionAdaptiveLowerLine = na
if newSession
    sessionAdaptiveUpperLine := na
    sessionAdaptiveLowerLine := na
if barReady and showAdaptiveEnvelope
    if na(sessionAdaptiveUpperLine)
        sessionAdaptiveUpperLine := line.new(sessionStartBar, adaptiveEnvelopeUpper, bar_index, adaptiveEnvelopeUpper, xloc=xloc.bar_index, extend=extend.none, color=upperEnvelopeColor, width=upperEnvelopeWidth, force_overlay=true)
    else
        line.set_xy1(sessionAdaptiveUpperLine, sessionStartBar, adaptiveEnvelopeUpper)
        line.set_xy2(sessionAdaptiveUpperLine, bar_index, adaptiveEnvelopeUpper)
        line.set_color(sessionAdaptiveUpperLine, upperEnvelopeColor)
        line.set_width(sessionAdaptiveUpperLine, upperEnvelopeWidth)
    if na(sessionAdaptiveLowerLine)
        sessionAdaptiveLowerLine := line.new(sessionStartBar, adaptiveEnvelopeLower, bar_index, adaptiveEnvelopeLower, xloc=xloc.bar_index, extend=extend.none, color=lowerEnvelopeColor, width=lowerEnvelopeWidth, force_overlay=true)
    else
        line.set_xy1(sessionAdaptiveLowerLine, sessionStartBar, adaptiveEnvelopeLower)
        line.set_xy2(sessionAdaptiveLowerLine, bar_index, adaptiveEnvelopeLower)
        line.set_color(sessionAdaptiveLowerLine, lowerEnvelopeColor)
        line.set_width(sessionAdaptiveLowerLine, lowerEnvelopeWidth)
if not showAdaptiveEnvelope
    if not na(sessionAdaptiveUpperLine)
        line.delete(sessionAdaptiveUpperLine)
        sessionAdaptiveUpperLine := na
    if not na(sessionAdaptiveLowerLine)
        line.delete(sessionAdaptiveLowerLine)
        sessionAdaptiveLowerLine := na
// DIRECTIONAL STRENGTH CHANNEL DISPLAY
bullUpperPlot = plot(showDirectionalChannel ? bullChannelUpper : na, title="Bullish Channel Upper", color=bullChannelBorderColor, linewidth=bullChannelBorderWidth, editable=false, force_overlay=true)
bullLowerPlot = plot(showDirectionalChannel ? bullChannelLower : na, title="Bullish Channel Lower", color=bullChannelBorderColor, linewidth=bullChannelBorderWidth, editable=false, force_overlay=true)
bearUpperPlot = plot(showDirectionalChannel ? bearChannelUpper : na, title="Bearish Channel Upper", color=bearChannelBorderColor, linewidth=bearChannelBorderWidth, editable=false, force_overlay=true)
bearLowerPlot = plot(showDirectionalChannel ? bearChannelLower : na, title="Bearish Channel Lower", color=bearChannelBorderColor, linewidth=bearChannelBorderWidth, editable=false, force_overlay=true)
fill(bullUpperPlot, bullLowerPlot, color=showDirectionalChannel ? bullChannelFill : na, title="Bullish Directional Strength Channel")
fill(bearUpperPlot, bearLowerPlot, color=showDirectionalChannel ? bearChannelFill : na, title="Bearish Directional Strength Channel")
// SIGNAL DISPLAY
plotshape(showSignals and buySignal, title="Buy", style=shape.labelup, location=location.belowbar, color=buySignalColor, text="Buy", textcolor=color.white, size=size.small, editable=false, force_overlay=true)
plotshape(showSignals and saleSignal, title="Sale", style=shape.labeldown, location=location.abovebar, color=saleSignalColor, text="Sale", textcolor=color.white, size=size.small, editable=false, force_overlay=true)
// ALERTS
alertcondition(buySignal, title="Buy", message="SBP Price Response Engine: Buy on {{ticker}} {{interval}}.")
alertcondition(saleSignal, title="Sale", message="SBP Price Response Engine: Sale on {{ticker}} {{interval}}.")
alertcondition(buySignal or saleSignal, title="Buy or Sale", message="SBP Price Response Engine: New Buy or Sale signal on {{ticker}} {{interval}}.")
````
