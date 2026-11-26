# SBP Structured Scalping Indicator

- url: https://www.tradingview.com/script/NoJDyImj-SBP-Structured-Scalping-Indicator/
- type: indicator
- pine_id: PUB;1d927d25bd8b4b00bc77a58b8924f15c
- version: 5.0

## Description

SBP Structured Scalping Indicator

SBP Structured Scalping Indicator is a market-structure and short-turn analysis framework designed to identify selective BUY and SELL observations around developing price turns.

The script is not a simple moving-average crossover mashup. Its purpose is to combine differently timed market observations into a single major-turn framework. A volatility-responsive adaptive trend identifies directional colour changes, while confirmed swing context and recent local extremes study whether that change is occurring near a meaningful price turning area.

Because a confirmed pivot and an adaptive trend change may not occur on the same candle, the script uses a short event-memory window to evaluate their proximity. A local-extreme fallback also studies recent highs or lows and requires a configurable ATR-based price excursion before the area can qualify as meaningful.

Potential turns are then evaluated using a confirmation score derived from adaptive-trend position, Dynamic Trend Filter direction, normalized momentum, candle direction, and liquidity or premium/discount context. Minimum signal spacing and alternating signal-state logic are used to reduce repetitive labels.

The Premium / Discount framework builds a dealing range from confirmed structural highs and lows and displays straight Premium, Equilibrium and Discount reference levels. These levels can be used as visual context or, when enabled, as an additional signal-location filter.

The two-colour Adaptive Trend Line changes between bullish and bearish states only when its confirmed slope exceeds a volatility-adjusted threshold. BUY and SELL signals are plotted on the confirmation bar; the primary signals do not use negative offsets.

Main settings

Minimum Signal Gap controls spacing between major-turn signals. Increasing it produces fewer, more widely separated observations.

Minimum Turn Confirmation Score controls how many supporting conditions are required. A higher value is more selective; a lower value increases sensitivity.

Local Extreme Lookback changes the recent high/low observation range.

Minimum Major Turn Excursion ATR controls how much prior price movement is required before a local extreme can qualify as a meaningful turn area.

Signal Window After Colour Change and Maximum Bars From Swing control the short event-memory relationship between adaptive turns and swing context.

Use Confirmed Swing Context evaluates confirmed pivot proximity. Use Local Extreme Fallback allows meaningful recent extremes to supplement pivot context. Use Premium / Discount Bias restricts BUY observations toward Discount and SELL observations toward Premium.

Optional structure, swing, CHoCH and liquidity displays are included for analysis and can be hidden to maintain a clean chart.

The indicator is intended as an analytical framework for studying short-term market structure, directional transitions and price-location context. Signals are observations generated from the framework's conditions and should be evaluated with the trader's own risk management and trading plan.

## Source Code

````pine
//@version=6
indicator("SBP Structured Scalping Indicator", overlay=true, max_bars_back=500, max_labels_count=200)

string G_DISPLAY = "1. Display"

const int structureRows = 30
const float coreCoveragePercent = 68.0
const int maximumSessionBars = 240
bool showGuide = input.bool(true, "Show Adaptive Regime Guide", group=G_DISPLAY)
bool showSignals = input.bool(true, "Show BUY / SALE", group=G_DISPLAY)
int guideWidth = input.int(2, "Guide Width", minval=1, maxval=4, group=G_DISPLAY)
color bullColor = input.color(color.rgb(0, 160, 105), "Bullish Colour", group=G_DISPLAY)
color bearColor = input.color(color.rgb(210, 55, 65), "Bearish Colour", group=G_DISPLAY)

f_distribution(int rows, int bars, float coverage) =>
    float rangeLow = ta.lowest(low, bars)
    float rangeHigh = ta.highest(high, bars)
    float rangeSpan = math.max(rangeHigh - rangeLow, syminfo.mintick * rows)
    float rowStep = rangeSpan / rows
    array<float> bins = array.new_float(rows, 0.0)
    for offset = 0 to bars - 1
        float candleLow = low[offset]
        float candleHigh = high[offset]
        float candleVolume = math.max(nz(volume[offset]), 0.0)
        float candleSpan = math.max(candleHigh - candleLow, syminfo.mintick)
        int firstRow = math.max(0, math.min(rows - 1, int(math.floor((candleLow - rangeLow) / rowStep))))
        int lastRow = math.max(0, math.min(rows - 1, int(math.floor((candleHigh - rangeLow) / rowStep))))
        for row = firstRow to lastRow
            float rowLow = rangeLow + row * rowStep
            float rowHigh = rowLow + rowStep
            float overlap = math.max(math.min(candleHigh, rowHigh) - math.max(candleLow, rowLow), 0.0)
            float contribution = candleVolume * overlap / candleSpan
            array.set(bins, row, array.get(bins, row) + contribution)
    float totalVolume = 0.0
    float peakVolume = -1.0
    int peakRow = 0
    for row = 0 to rows - 1
        float rowVolume = array.get(bins, row)
        totalVolume += rowVolume
        if rowVolume > peakVolume
            peakVolume := rowVolume
            peakRow := row
    int lowerRow = peakRow
    int upperRow = peakRow
    float accumulatedVolume = math.max(peakVolume, 0.0)
    float targetVolume = totalVolume * coverage
    int expansionGuard = 0
    while accumulatedVolume < targetVolume and expansionGuard < rows * 2
        bool canExpandLower = lowerRow > 0
        bool canExpandUpper = upperRow < rows - 1
        if not canExpandLower and not canExpandUpper
            break
        float nextLowerVolume = canExpandLower ? array.get(bins, lowerRow - 1) : -1.0
        float nextUpperVolume = canExpandUpper ? array.get(bins, upperRow + 1) : -1.0
        if canExpandUpper and (not canExpandLower or nextUpperVolume > nextLowerVolume)
            upperRow += 1
            accumulatedVolume += math.max(nextUpperVolume, 0.0)
        else
            lowerRow -= 1
            accumulatedVolume += math.max(nextLowerVolume, 0.0)
        expansionGuard += 1
    float control = rangeLow + (peakRow + 0.5) * rowStep
    float coreLower = rangeLow + lowerRow * rowStep
    float coreUpper = rangeLow + (upperRow + 1.0) * rowStep
    [control, coreLower, coreUpper]

const int fastLength = 9
const int slowLength = 24
const int atrLength = 14
const int pressureLength = 7
const int structureLookback = 8
const float minimumScore = 68.0
const float minimumAdvantage = 8.0
const int minimumEvidence = 4

bool newSession = timeframe.change("D")
int barsFromSessionStart = nz(ta.barssince(newSession)) + 1
int activeSessionBars = math.min(math.max(barsFromSessionStart, 1), maximumSessionBars)
[developingControl, developingCoreLower, developingCoreUpper] = f_distribution(structureRows, activeSessionBars, coreCoveragePercent / 100.0)
float valueCenter = (developingCoreUpper + developingCoreLower) * 0.5
float valueWidth = math.max(developingCoreUpper - developingCoreLower, syminfo.mintick)

float fastEMA = ta.ema(close, fastLength)
float slowEMA = ta.ema(close, slowLength)
float atrValue = math.max(ta.atr(atrLength), syminfo.mintick)
float barRange = math.max(high - low, syminfo.mintick)
float candleBody = math.abs(close - open)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float closeLocation = (close - low) / barRange
float signedVolume = close > open ? nz(volume) : close < open ? -nz(volume) : 0.0
float averageVolume = math.max(ta.ema(nz(volume), 20), 1.0)
float relativeVolume = nz(volume) > 0.0 ? nz(volume) / averageVolume : 1.0
float pressureBalance = ta.ema(signedVolume / averageVolume, pressureLength)
float pressureChange = pressureBalance - nz(pressureBalance[1], pressureBalance)
float momentum = ta.ema(ta.change(close) / atrValue, pressureLength)
float priorHigh = ta.highest(high[1], structureLookback)
float priorLow = ta.lowest(low[1], structureLookback)
float safePath = math.sum(math.abs(ta.change(close)), 10)
float efficiency = safePath > 0.0 ? math.abs(close - nz(close[10], close)) / safePath : 0.0
float fastConstant = 2.0 / 3.0
float slowConstant = 2.0 / 31.0
float adaptiveConstant = math.pow(efficiency * (fastConstant - slowConstant) + slowConstant, 2)
var float adaptiveCenter = na
adaptiveCenter := na(adaptiveCenter[1]) ? hlc3 : adaptiveCenter[1] + adaptiveConstant * (hlc3 - adaptiveCenter[1])
float centerSlope = adaptiveCenter - nz(adaptiveCenter[2], adaptiveCenter)
bool bullTrend = fastEMA > slowEMA and close >= adaptiveCenter and centerSlope >= 0.0
bool bearTrend = fastEMA < slowEMA and close <= adaptiveCenter and centerSlope <= 0.0
bool strongBullOpposition = bearTrend and pressureBalance < -0.12 and momentum < 0.0
bool strongBearOpposition = bullTrend and pressureBalance > 0.12 and momentum > 0.0

float structureTolerance = math.max(atrValue * 0.10, valueWidth * 0.08)
bool bullCoreRejection = low <= developingCoreLower + structureTolerance and close > developingCoreLower and lowerWick >= math.max(candleBody, syminfo.mintick) * 0.65 and closeLocation >= 0.58
bool bearCoreRejection = high >= developingCoreUpper - structureTolerance and close < developingCoreUpper and upperWick >= math.max(candleBody, syminfo.mintick) * 0.65 and closeLocation <= 0.42
bool bullControlReclaim = low <= developingControl and close > developingControl and close > open and pressureChange > 0.0
bool bearControlReclaim = high >= developingControl and close < developingControl and close < open and pressureChange < 0.0
bool bullLiquiditySweep = low < priorLow and close > priorLow and closeLocation >= 0.60
bool bearLiquiditySweep = high > priorHigh and close < priorHigh and closeLocation <= 0.40
bool bullValueAcceptance = close > developingCoreUpper and close[1] <= developingCoreUpper[1] and closeLocation >= 0.62
bool bearValueAcceptance = close < developingCoreLower and close[1] >= developingCoreLower[1] and closeLocation <= 0.38
bool bullInitiative = relativeVolume >= 1.05 and close > open and candleBody >= atrValue * 0.38 and closeLocation >= 0.68
bool bearInitiative = relativeVolume >= 1.05 and close < open and candleBody >= atrValue * 0.38 and closeLocation <= 0.32
bool bullLocation = close >= valueCenter or bullCoreRejection or bullControlReclaim or bullLiquiditySweep
bool bearLocation = close <= valueCenter or bearCoreRejection or bearControlReclaim or bearLiquiditySweep
int bullEvidence = (bullTrend ? 1 : 0) + (pressureBalance > 0.0 ? 1 : 0) + (pressureChange > 0.0 ? 1 : 0) + (momentum > 0.0 ? 1 : 0) + (bullLocation ? 1 : 0) + (closeLocation >= 0.58 ? 1 : 0)
int bearEvidence = (bearTrend ? 1 : 0) + (pressureBalance < 0.0 ? 1 : 0) + (pressureChange < 0.0 ? 1 : 0) + (momentum < 0.0 ? 1 : 0) + (bearLocation ? 1 : 0) + (closeLocation <= 0.42 ? 1 : 0)
float bullScore = (bullTrend ? 20.0 : 0.0) + (pressureBalance > 0.0 ? 12.0 : 0.0) + (pressureChange > 0.0 ? 8.0 : 0.0) + (momentum > 0.0 ? 10.0 : 0.0) + (bullCoreRejection ? 18.0 : 0.0) + (bullControlReclaim ? 14.0 : 0.0) + (bullLiquiditySweep ? 18.0 : 0.0) + (bullValueAcceptance ? 15.0 : 0.0) + (bullInitiative ? 10.0 : 0.0)
float bearScore = (bearTrend ? 20.0 : 0.0) + (pressureBalance < 0.0 ? 12.0 : 0.0) + (pressureChange < 0.0 ? 8.0 : 0.0) + (momentum < 0.0 ? 10.0 : 0.0) + (bearCoreRejection ? 18.0 : 0.0) + (bearControlReclaim ? 14.0 : 0.0) + (bearLiquiditySweep ? 18.0 : 0.0) + (bearValueAcceptance ? 15.0 : 0.0) + (bearInitiative ? 10.0 : 0.0)
bool bullTrigger = bullCoreRejection or bullControlReclaim or bullLiquiditySweep or bullValueAcceptance or bullInitiative
bool bearTrigger = bearCoreRejection or bearControlReclaim or bearLiquiditySweep or bearValueAcceptance or bearInitiative
bool confirmedBar = barstate.isconfirmed
bool rawBuy = confirmedBar and bullTrigger and bullEvidence >= minimumEvidence and bullScore >= minimumScore and bullScore >= bearScore + minimumAdvantage and not strongBullOpposition
bool rawSale = confirmedBar and bearTrigger and bearEvidence >= minimumEvidence and bearScore >= minimumScore and bearScore >= bullScore + minimumAdvantage and not strongBearOpposition

bool resolvedBuy = rawBuy and not rawSale
bool resolvedSale = rawSale and not rawBuy
if rawBuy and rawSale
    resolvedBuy := bullScore > bearScore
    resolvedSale := bearScore > bullScore
var int signalDirection = 0
bool buySignal = false
bool saleSignal = false
if confirmedBar
    if signalDirection == 0
        if resolvedBuy
            buySignal := true
            signalDirection := 1
        else if resolvedSale
            saleSignal := true
            signalDirection := -1
    else if signalDirection == 1 and resolvedSale
        saleSignal := true
        signalDirection := -1
    else if signalDirection == -1 and resolvedBuy
        buySignal := true
        signalDirection := 1

float guideVolatility = atrValue * 0.42
float bullishGuideTarget = math.max(adaptiveCenter - guideVolatility, developingCoreLower)
float bearishGuideTarget = math.min(adaptiveCenter + guideVolatility, developingCoreUpper)
float neutralGuideTarget = (adaptiveCenter + developingControl) * 0.5
float guideTarget = signalDirection == 1 ? bullishGuideTarget : signalDirection == -1 ? bearishGuideTarget : neutralGuideTarget
const float guideResponse = 0.31
var float adaptiveRegimeGuide = na
adaptiveRegimeGuide := na(adaptiveRegimeGuide[1]) ? guideTarget : adaptiveRegimeGuide[1] + guideResponse * (guideTarget - adaptiveRegimeGuide[1])
color guideColor = signalDirection == 1 ? bullColor : signalDirection == -1 ? bearColor : close >= adaptiveRegimeGuide ? bullColor : bearColor

plot(showGuide ? adaptiveRegimeGuide : na, title="Adaptive Regime Guide", color=guideColor, linewidth=guideWidth, editable=false)
plotshape(showSignals and buySignal, title="BUY", text="BUY", style=shape.labelup, location=location.belowbar, color=bullColor, textcolor=color.white, size=size.small, editable=false)
plotshape(showSignals and saleSignal, title="SALE", text="SALE", style=shape.labeldown, location=location.abovebar, color=bearColor, textcolor=color.white, size=size.small, editable=false)
alertcondition(buySignal, title="SBP Structured Scalping Indicator - BUY", message="SBP Structured Scalping Indicator | BUY | {{ticker}} | {{interval}} | Close: {{close}}")
alertcondition(saleSignal, title="SBP Structured Scalping Indicator - SALE", message="SBP Structured Scalping Indicator | SALE | {{ticker}} | {{interval}} | Close: {{close}}")
alertcondition(buySignal or saleSignal, title="SBP Structured Scalping Indicator - BUY or SALE", message="SBP Structured Scalping Indicator | New signal | {{ticker}} | {{interval}} | Close: {{close}}")
````
