<!-- tradingview-pine-id: PUB;831816462f8c41949047f3843479ec9b -->
<!-- tradingviewscripts-format: 1 -->
# Price Volume Divergence State

Source: https://www.tradingview.com/script/I6nzUbGL/

## Description

Price Volume Divergence State (PVDS)

PVDS is part of the PVD Ecosystem. It is designed to answer one simple question:

What phase is the current price-volume process in?

Price and volume do not always develop together. Pressure can build before price reacts, stored pressure can begin to move into price, an established move can remain well supported, or the underlying process can start to weaken while price is still moving.

PVDS turns these relationships into six simple states:

BUILDING — directional pressure is building while price has not yet fully expressed it.

RELEASING — previously stored pressure is increasingly being expressed through price.

ACTIVE — pressure and price are working together in an established direction.

WEAKENING — the current process is losing underlying support.

TRANSITION — the process is changing and has not yet settled into a clear state.

NEUTRAL — there is currently no clear price-volume process.

Reading the indicator

• Green above zero represents an upward process.
• Red below zero represents a downward process.
• The distance from zero shows how established the directional process is.
• Brighter dots indicate a clearer reading.
• Larger dots show a stronger release of stored pressure into price.

The small information panel gives the current state in plain language and also shows its development, activity and clarity.

How PVDS can help

PVDS is especially interesting when viewed together with the price chart. BUILDING can reveal pressure developing while price is still relatively quiet. RELEASING can show when stored pressure is becoming visible in price. WEAKENING can highlight that the process behind an ongoing price move is beginning to lose support.

This makes PVDS useful for understanding what is happening underneath the visible price movement, rather than looking at price alone.

Within the PVD Ecosystem, PVDS has the specific role of translating the underlying price-volume relationship into an easy-to-read market process state. It can be used on its own as additional context for chart analysis or together with the other PVD tools for a broader view of market behavior.

---

## Source Code

````pine
//@version=6
indicator("Price Volume Divergence State", shorttitle="PVDS", overlay=false)

//=============================================================================
// MODULE 1 — INPUTS
//=============================================================================
priceDeltaType = input.string("Signed High - Low", "Price Movement", options=["Close - Open", "Signed High - Low"])
normLength = input.int(11, "Normalization Length", minval=1)
maType = input.string("EMA", "PVDO MA Type", options=["SMA", "EMA", "HMA", "LMA", "RMA", "WMA", "VWMA", "TEMA"])
pvdoMaLength = input.int(121, "PVDO MA Length", minval=1)
signalMaType = input.string("EMA", "Signal MA Type", options=["SMA", "EMA", "HMA", "LMA", "RMA", "WMA", "VWMA", "TEMA"])
signalMaLength = input.int(44, "Signal MA Length", minval=1)
logisticBandwidth = input.float(121, "Logistic Bandwidth", minval=1)
storedLength = input.int(11, "Stored Imbalance Length", minval=1)

//=============================================================================
// MODULE 2 — PVDO FOUNDATION
//=============================================================================
candleRange = math.max(high - low, syminfo.mintick)
pressure = volume * (close - open) / candleRange
pressureNorm = pressure / ta.sma(math.abs(pressure), normLength)

priceMove = priceDeltaType == "Close - Open" ? close - open : close > open ? high - low : close < open ? -(high - low) : 0.0
priceNorm = priceMove / ta.sma(math.abs(priceMove), normLength)

pvdoRaw = -(priceNorm - pressureNorm) * math.abs(priceNorm)

//=============================================================================
// MODULE 3 — PVDO SMOOTHING
//=============================================================================
tema(src, len) =>
    ema1 = ta.ema(src, len)
    ema2 = ta.ema(ema1, len)
    ema3 = ta.ema(ema2, len)
    3 * ema1 - 3 * ema2 + ema3

ma(src, len, type) =>
    switch type
        "SMA"  => ta.sma(src, len)
        "EMA"  => ta.ema(src, len)
        "HMA"  => ta.hma(src, len)
        "LMA"  => ta.linreg(src, len, 0)
        "RMA"  => ta.rma(src, len)
        "WMA"  => ta.wma(src, len)
        "VWMA" => ta.vwma(src, len)
        "TEMA" => tema(src, len)

mkr_logistic_weight(src, bandwidth) =>
    1.0 / (1.0 + math.exp(-math.abs(src) / bandwidth))

pvdoMain = ma(pvdoRaw, pvdoMaLength, maType)
pvdoSignal = ma(pvdoMain, signalMaLength, signalMaType)

var float pvdoLogistic = na
var float signalLogistic = na

pvdoChange = pvdoMain - nz(pvdoLogistic, pvdoMain)
signalChange = pvdoSignal - nz(signalLogistic, pvdoSignal)
pvdoWeight = mkr_logistic_weight(pvdoChange, logisticBandwidth)
signalWeight = mkr_logistic_weight(signalChange, logisticBandwidth)

pvdoLogistic := na(pvdoLogistic[1]) ? pvdoMain : pvdoLogistic[1] + pvdoWeight * pvdoChange
signalLogistic := na(signalLogistic[1]) ? pvdoSignal : signalLogistic[1] + signalWeight * signalChange

//=============================================================================
// MODULE 4 — STORED IMBALANCE
//=============================================================================
decay = (storedLength - 1.0) / storedLength

var float storedImbalance = na
storedImbalance := na(storedImbalance[1]) ? pvdoMain : storedImbalance[1] * decay + pvdoMain

var float storedLogistic = na
storedChange = storedImbalance - nz(storedLogistic, storedImbalance)
storedWeight = mkr_logistic_weight(storedChange, logisticBandwidth)
storedLogistic := na(storedLogistic[1]) ? storedImbalance : storedLogistic[1] + storedWeight * storedChange

storedScale = ta.sma(math.abs(storedLogistic), storedLength)
storedValue = storedLogistic / math.max(storedScale, syminfo.mintick)
storedNormalized = (math.exp(2 * storedValue) - 1) / (math.exp(2 * storedValue) + 1)

//=============================================================================
// MODULE 5 — PVDS DIRECTION
//=============================================================================

directionNormalize(x) =>
    x / (1.0 + math.abs(x))

storedDirectionEvidence = storedNormalized
pvdoDirectionEvidence = directionNormalize(pvdoLogistic)
pressureDirectionEvidence = directionNormalize(pressureNorm)

directionSum =
     storedDirectionEvidence +
     pvdoDirectionEvidence +
     pressureDirectionEvidence

directionMagnitude =
     math.abs(storedDirectionEvidence) +
     math.abs(pvdoDirectionEvidence) +
     math.abs(pressureDirectionEvidence)

directionAgreement =
     directionMagnitude > 0 ?
     math.abs(directionSum) / directionMagnitude :
     0.0

directionBias =
     directionMagnitude > 0 ?
     directionSum / directionMagnitude :
     0.0

directionAgreementThreshold = 0.25

pvdsDirection =
     directionAgreement < directionAgreementThreshold ? 0 :
     directionBias > 0 ? 1 :
     directionBias < 0 ? -1 :
     0
     
//=============================================================================
// MODULE 6 — PVDS PROCESS DIMENSIONS
//=============================================================================
orientation = pvdsDirection
pressureSupport = orientation * pressureNorm
priceExpression = orientation * priceNorm
storageLevel = orientation * storedNormalized

dynamicLength = 3
pressureBase = ta.ema(pressureNorm, dynamicLength)
expressionBase = ta.ema(priceNorm, dynamicLength)
storageBase = ta.ema(storedNormalized, dynamicLength)

pressureNativeTrend = pressureBase - nz(pressureBase[1], pressureBase)
expressionNativeTrend = expressionBase - nz(expressionBase[1], expressionBase)
storageNativeTrend = storageBase - nz(storageBase[1], storageBase)

pressureTrend = orientation * pressureNativeTrend
expressionTrend = orientation * expressionNativeTrend
storageTrend = orientation * storageNativeTrend

pressureChangeBase = ta.ema(math.abs(pressureNativeTrend), dynamicLength)
expressionChangeBase = ta.ema(math.abs(expressionNativeTrend), dynamicLength)
storageChangeBase = ta.ema(math.abs(storageNativeTrend), dynamicLength)

pressureLossRelative = pressureChangeBase > 0 ? math.max(-pressureTrend, 0.0) / pressureChangeBase : 0.0
expressionRiseRelative = expressionChangeBase > 0 ? math.max(expressionTrend, 0.0) / expressionChangeBase : 0.0
storageBuildRelative = storageChangeBase > 0 ? math.max(storageTrend, 0.0) / storageChangeBase : 0.0
storageReleaseRelative = storageChangeBase > 0 ? math.max(-storageTrend, 0.0) / storageChangeBase : 0.0

pressurePositive = math.max(pressureSupport, 0.0)
expressionPositive = math.max(priceExpression, 0.0)
storagePositive = math.max(storageLevel, 0.0)
pressureLoss = pressureLossRelative / (1.0 + pressureLossRelative)
expressionRise = expressionRiseRelative / (1.0 + expressionRiseRelative)
storageBuild = storageBuildRelative / (1.0 + storageBuildRelative)
storageRelease = storageReleaseRelative / (1.0 + storageReleaseRelative)

balanceDenominator = math.abs(priceExpression) + math.abs(pressureSupport)
expressionBalance = balanceDenominator > 0 ? math.abs(priceExpression) / balanceDenominator : 0.0

//=============================================================================
// MODULE 7 — PVDS STATE EVIDENCE
//=============================================================================
bound01(x) => math.max(0.0, math.min(1.0, x))

pressureEvidence = bound01(pressurePositive / (1.0 + pressurePositive))
expressionEvidence = bound01(expressionPositive / (1.0 + expressionPositive))
storageEvidence = bound01(storagePositive)
buildEvidence = bound01(storageBuild)
releaseStorageEvidence = bound01(storageRelease)
expressionRiseEvidence = bound01(expressionRise)
pressureLossEvidence = bound01(pressureLoss)
limitedExpressionEvidence = bound01(1.0 - expressionBalance)

accumulationEvidence = math.pow(storageEvidence * buildEvidence * pressureEvidence * limitedExpressionEvidence, 0.25)
releaseEvidence = math.pow(releaseStorageEvidence * expressionRiseEvidence * storageEvidence * expressionEvidence, 0.25)
activeBalanceEvidence = bound01(1.0 - math.abs(expressionBalance - 0.5) * 2.0)
activeEvidence = math.pow(pressureEvidence * expressionEvidence * activeBalanceEvidence, 1.0 / 3.0)
weakeningEvidence = math.sqrt(expressionEvidence * pressureLossEvidence)

rawPressureActivity = bound01(math.abs(pressureNorm) / (1.0 + math.abs(pressureNorm)))
rawPriceActivity = bound01(math.abs(priceNorm) / (1.0 + math.abs(priceNorm)))
rawStorageActivity = bound01(math.abs(storedNormalized))
activityLevel = (rawPressureActivity + rawPriceActivity + rawStorageActivity) / 3.0

evidenceSum = accumulationEvidence + releaseEvidence + activeEvidence + weakeningEvidence
evidenceMax = math.max(accumulationEvidence, math.max(releaseEvidence, math.max(activeEvidence, weakeningEvidence)))
evidenceDominance = evidenceSum > 0 ? evidenceMax / evidenceSum : 0.0
evidenceClarity = evidenceSum > 0 ? bound01((evidenceDominance - 0.25) / 0.75) : 0.0

//=============================================================================
// MODULE 8 — RAW STATE SELECTION
//=============================================================================
PVDS_NEUTRAL      = 0
PVDS_ACCUMULATION = 1
PVDS_RELEASE      = 2
PVDS_ACTIVE       = 3
PVDS_WEAKENING    = 4
PVDS_TRANSITION   = 5

activityThreshold = 0.15
clarityThreshold = 0.20

int pvdsCandidate = PVDS_NEUTRAL

if activityLevel < activityThreshold
    pvdsCandidate := PVDS_NEUTRAL
else if directionAgreement < directionAgreementThreshold
    pvdsCandidate := PVDS_TRANSITION
else
    if evidenceMax == accumulationEvidence
        pvdsCandidate := PVDS_ACCUMULATION
    else if evidenceMax == releaseEvidence
        pvdsCandidate := PVDS_RELEASE
    else if evidenceMax == weakeningEvidence
        pvdsCandidate := PVDS_WEAKENING
    else
        pvdsCandidate := PVDS_ACTIVE

//=============================================================================
// MODULE 9 — PVDS STATE STABILITY
//=============================================================================
retainThreshold = 0.15
switchMargin = 0.10
neutralEnterThreshold = 0.12
neutralExitThreshold = 0.18

stateEvidence(state) =>
    switch state
        PVDS_ACCUMULATION => accumulationEvidence
        PVDS_RELEASE => releaseEvidence
        PVDS_ACTIVE => activeEvidence
        PVDS_WEAKENING => weakeningEvidence
        => 0.0

var int pvdsState = PVDS_NEUTRAL
var int establishedDirection = 0

resolvedDirection = pvdsDirection != 0
directionReversal = resolvedDirection and establishedDirection != 0 and pvdsDirection != establishedDirection

if resolvedDirection
    establishedDirection := pvdsDirection

currentEvidence = stateEvidence(pvdsState)
candidateEvidence = stateEvidence(pvdsCandidate)

enterNeutral = activityLevel < neutralEnterThreshold
leaveNeutral = activityLevel >= neutralExitThreshold

if directionReversal
    pvdsState := pvdsCandidate
else if enterNeutral
    pvdsState := PVDS_NEUTRAL
else if pvdsState == PVDS_NEUTRAL
    pvdsState := leaveNeutral ? pvdsCandidate : PVDS_NEUTRAL
else if pvdsCandidate == PVDS_NEUTRAL
    pvdsState := pvdsState
else if pvdsState == PVDS_TRANSITION
    pvdsState := pvdsCandidate
else if pvdsCandidate == pvdsState
    pvdsState := pvdsState
else if pvdsCandidate == PVDS_TRANSITION
    pvdsState := currentEvidence >= retainThreshold ? pvdsState : PVDS_TRANSITION
else if currentEvidence < retainThreshold or candidateEvidence > currentEvidence * (1.0 + switchMargin)
    pvdsState := pvdsCandidate

//=============================================================================
// MODULE 10 — PVDS PROCESS CHANGE
//=============================================================================
accumulationChange = accumulationEvidence - nz(accumulationEvidence[1], accumulationEvidence)
releaseChange = releaseEvidence - nz(releaseEvidence[1], releaseEvidence)
activeChange = activeEvidence - nz(activeEvidence[1], activeEvidence)
weakeningChange = weakeningEvidence - nz(weakeningEvidence[1], weakeningEvidence)

accumulationChangeBase = ta.ema(math.abs(accumulationChange), 3)
releaseChangeBase = ta.ema(math.abs(releaseChange), 3)
activeChangeBase = ta.ema(math.abs(activeChange), 3)
weakeningChangeBase = ta.ema(math.abs(weakeningChange), 3)

processChange = pvdsState == PVDS_ACCUMULATION ? accumulationChange : pvdsState == PVDS_RELEASE ? releaseChange : pvdsState == PVDS_ACTIVE ? activeChange : pvdsState == PVDS_WEAKENING ? weakeningChange : 0.0
processChangeBase = pvdsState == PVDS_ACCUMULATION ? accumulationChangeBase : pvdsState == PVDS_RELEASE ? releaseChangeBase : pvdsState == PVDS_ACTIVE ? activeChangeBase : pvdsState == PVDS_WEAKENING ? weakeningChangeBase : 0.0
processChangeRelative = processChangeBase > 0 ? processChange / processChangeBase : 0.0

PVDS_WEAKER = -1
PVDS_STEADY = 0
PVDS_STRONGER = 1
processChangeState = processChangeRelative > 0.5 ? PVDS_STRONGER : processChangeRelative < -0.5 ? PVDS_WEAKER : PVDS_STEADY

//=============================================================================
// MODULE 11 — PVDS PROCESS MAP
//=============================================================================
trajectoryPressureSupport = establishedDirection * pressureBase
trajectoryPressurePositive = math.max(trajectoryPressureSupport, 0.0)
trajectoryPressureEvidence = bound01(trajectoryPressurePositive / (1.0 + trajectoryPressurePositive))

pressureSq = trajectoryPressureEvidence * trajectoryPressureEvidence
storageSq = storageEvidence * storageEvidence
directionalContinuity = math.sqrt(math.max(pressureSq + storageSq - pressureSq * storageSq, 0.0))

trajectoryDirection = pvdsState == PVDS_NEUTRAL ? 0 : establishedDirection
trajectoryTarget = trajectoryDirection == 0 ? 0.0 : trajectoryDirection * directionalContinuity
visualClarity = math.min(directionAgreement, evidenceClarity)
releaseEffect = math.pow(releaseStorageEvidence * expressionRiseEvidence * expressionEvidence, 1.0 / 3.0)

var float pvdsTrajectory = 0.0
previousTrajectory = nz(pvdsTrajectory[1], 0.0)
previousDirection = previousTrajectory > 0 ? 1 : previousTrajectory < 0 ? -1 : 0
trajectoryReversal = trajectoryDirection != 0 and previousDirection != 0 and trajectoryDirection != previousDirection

if pvdsState == PVDS_NEUTRAL
    pvdsTrajectory := 0.0
else if previousDirection == 0 or trajectoryReversal
    pvdsTrajectory := trajectoryTarget
else
    pvdsTrajectory := previousTrajectory + visualClarity * (trajectoryTarget - previousTrajectory)

upColor = color.green
downColor = color.red
neutralColor = color.gray
trajectoryBaseColor = trajectoryDirection > 0 ? upColor : trajectoryDirection < 0 ? downColor : neutralColor
trajectoryTransparency = trajectoryDirection == 0 ? 80 : int(math.round(75.0 - 65.0 * visualClarity))
trajectoryColor = color.new(trajectoryBaseColor, trajectoryTransparency)

hline(0.0, "Neutral", color=color.new(color.gray, 75))
plot(pvdsTrajectory, title="PVDS Process Path", color=color.new(trajectoryBaseColor, 70), linewidth=1)

releaseLarge = releaseEffect >= 0.66
releaseMedium = releaseEffect >= 0.33 and releaseEffect < 0.66
releaseSmall = releaseEffect < 0.33

plotshape(releaseLarge ? pvdsTrajectory : na, title="PVDS Large Release", style=shape.circle, location=location.absolute, color=trajectoryColor, size=size.large)
plotshape(releaseMedium ? pvdsTrajectory : na, title="PVDS Medium Release", style=shape.circle, location=location.absolute, color=trajectoryColor, size=size.small)
plotshape(releaseSmall ? pvdsTrajectory : na, title="PVDS Small Release", style=shape.circle, location=location.absolute, color=trajectoryColor, size=size.tiny)

stateName = pvdsState == PVDS_ACCUMULATION ? "BUILDING" : pvdsState == PVDS_RELEASE ? "RELEASING" : pvdsState == PVDS_ACTIVE ? "ACTIVE" : pvdsState == PVDS_WEAKENING ? "WEAKENING" : pvdsState == PVDS_TRANSITION ? "TRANSITION" : "NEUTRAL"
stateMeaning = pvdsState == PVDS_ACCUMULATION ? "Pressure building" : pvdsState == PVDS_RELEASE ? "Pressure moving into price" : pvdsState == PVDS_ACTIVE ? "Pressure and price aligned" : pvdsState == PVDS_WEAKENING ? "Process losing support" : pvdsState == PVDS_TRANSITION ? "Process changing" : "No clear process"

activityName = activityLevel < activityThreshold ? "WEAK" : activityLevel > 0.50 ? "STRONG" : "NORMAL"
clarityName = visualClarity >= clarityThreshold ? "CLEAR" : "MIXED"

validProcess = pvdsState == PVDS_ACCUMULATION or pvdsState == PVDS_RELEASE or pvdsState == PVDS_ACTIVE or pvdsState == PVDS_WEAKENING
changeName = not validProcess ? "—" : processChangeState == PVDS_STRONGER ? "STRONGER" : processChangeState == PVDS_WEAKER ? "WEAKER" : "STEADY"

statePanelColor = pvdsState == PVDS_NEUTRAL or pvdsState == PVDS_TRANSITION ? neutralColor : trajectoryBaseColor
var table pvdsPanel = table.new(position.top_right, 2, 4, border_width=1)

if barstate.islast
    table.cell(pvdsPanel, 0, 0, stateName, bgcolor=color.new(statePanelColor, 35), text_color=color.white, text_size=size.small)
    table.cell(pvdsPanel, 1, 0, changeName, bgcolor=color.new(statePanelColor, 75), text_color=chart.fg_color, text_size=size.small)

    table.cell(pvdsPanel, 0, 1, stateMeaning, text_color=chart.fg_color, text_size=size.tiny)
    table.cell(pvdsPanel, 1, 1, "", text_size=size.tiny)

    table.cell(pvdsPanel, 0, 2, "Activity", text_color=chart.fg_color, text_size=size.tiny)
    table.cell(pvdsPanel, 1, 2, activityName, text_color=chart.fg_color, text_size=size.tiny)

    table.cell(pvdsPanel, 0, 3, "Clarity", text_color=chart.fg_color, text_size=size.tiny)
    table.cell(pvdsPanel, 1, 3, clarityName, text_color=chart.fg_color, text_size=size.tiny)
````
