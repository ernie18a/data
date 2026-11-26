# SBP Market Behaviour Navigator 

- url: https://www.tradingview.com/script/l4gDvcxV-SBP-Market-Behaviour-Navigator/
- type: indicator
- pine_id: PUB;80000119277d4c4db318327677e08380
- version: 4.0

## Description

SBP Market Behaviour Navigator

SBP Market Behaviour Navigator is a rule-based chart analysis indicator designed to organize trend, price behaviour, volume participation, and continuation conditions into a single visual framework.

The indicator uses several internally calculated components. These components are evaluated together rather than displayed as multiple independent indicators, helping keep the chart simple while preserving the underlying analytical structure.

How the indicator works

The Dynamic Trendline is built from a smoothed price base with an adaptive response mechanism. Its directional state uses price position, trend behaviour, and an ATR-based buffer. The buffer and confirmation logic are intended to reduce frequent trend-state changes caused by smaller pullbacks.

The Trend component evaluates the persistent trendline state together with a smoothed trend filter and an adaptive moving average direction.

The Reversal Behaviour component examines prior price extension, interaction with recent price extremes, candle-body characteristics, and the closing position within the candle range. This component is used as an internal price-behaviour condition and is not displayed as a separate reversal signal.

The Volume Behaviour component compares current volume with its average and evaluates where the candle closes within its range. This helps identify bars showing comparatively higher participation.

The Participation Flow component combines directional price movement, relative volume participation, and candle closing location. It is used internally as an additional directional condition.

A separate Trend Continuation component evaluates price resumption during an established trend. This allows the script to consider continuation behaviour independently from reversal behaviour.

BUY and SALE labels

The internal components are combined through a rule-based alignment process. BUY and SALE labels appear only when the script's directional and separation conditions are satisfied.

Signals follow an alternating sequence:

BUY → SALE → BUY → SALE

After a BUY label, another BUY label is not displayed until a qualifying SALE condition occurs. The same principle applies after a SALE label.

The script also applies internal bar-spacing and ATR-distance requirements between signals. These conditions are intended to reduce closely grouped labels during short-term price fluctuations.

Trading Modes

The indicator provides three calculation modes:

SCALPING uses faster internal parameters for shorter-term chart movement.

INTRADAY uses additional signal spacing and stricter internal alignment to reduce frequent directional changes.

SWING uses slower smoothing and wider trend-state thresholds for broader price movement.

Changing the mode adjusts the internal calculation parameters. It does not change the basic analytical methodology of the indicator.

Visual controls

Users can independently show or hide the Dynamic Trendline, Trend Filter, Adaptive Average, and BUY/SALE labels.

These settings control visual display only. Hiding a visual element does not disable or modify the internal analytical calculations.

Signal calculation

BUY and SALE conditions are evaluated on confirmed chart bars. The script does not use a negative plotting offset to place newly detected signals on earlier bars.

Alerts use the same confirmed-bar BUY and SALE conditions displayed by the indicator.

Important information

This indicator is intended for educational and informational chart analysis. BUY and SALE labels represent conditions defined by the script's rule-based methodology. They do not predict future prices, guarantee a market move, or represent guaranteed trading outcomes.

Market conditions can change, and signals may be followed by adverse price movement. Users should evaluate the indicator together with their own market analysis, trading plan, and risk-management approach.

Developed by SBP Trading Ecosystem

## Source Code

````pine
//@version=6
indicator("SBP Market Behaviour Navigator", overlay = true, max_labels_count = 500, max_bars_back = 600)

string G_SIGNALS = "01. Intraday Signals"
bool showBuySignals = input.bool(true, "Show BUY Signals", group = G_SIGNALS)
bool showSaleSignals = input.bool(true, "Show SALE Signals", group = G_SIGNALS)
string signalSizeInput = input.string("SMALL", "Signal Label Size", options = ["TINY", "SMALL", "NORMAL"], group = G_SIGNALS)
color buyColor = input.color(color.green, "BUY Colour", group = G_SIGNALS, inline = "SC")
color saleColor = input.color(color.red, "SALE Colour", group = G_SIGNALS, inline = "SC")

string G_TREND = "02. Dynamic Trendline"
bool showTrendline = input.bool(false, "Show Dynamic Trendline", group = G_TREND)
color bullishTrendColor = input.color(color.blue, "Bullish Colour", group = G_TREND, inline = "TC")
color bearishTrendColor = input.color(color.red, "Bearish Colour", group = G_TREND, inline = "TC")
int trendlineWidth = input.int(2, "Trendline Width", minval = 1, maxval = 4, group = G_TREND)

string G_CLOUD = "03. Bull / Bear Ribbon"
bool showCloud = input.bool(true, "Show Bull / Bear Ribbon", group = G_CLOUD)
color bullCloudColor = input.color(color.new(color.blue, 55), "Bull Ribbon Colour", group = G_CLOUD)
color bearCloudColor = input.color(color.new(color.red, 55), "Bear Ribbon Colour", group = G_CLOUD)

int profileRows = 30
float valueCoverage = 0.68
int maximumSessionBars = 300
bool confirmedBar = barstate.isconfirmed
bool newSession = timeframe.change("D")

f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

f_addVolume(array<float> bins, int rows, float rangeLow, float rowStep, float candleLow, float candleHigh, float candleVolume) =>
    int firstRow = math.max(0, math.min(rows - 1, int(math.floor((math.min(candleLow, candleHigh) - rangeLow) / rowStep))))
    int lastRow = math.max(0, math.min(rows - 1, int(math.floor((math.max(candleLow, candleHigh) - rangeLow) / rowStep))))
    float distributedVolume = math.max(candleVolume, 0.0) / math.max(lastRow - firstRow + 1, 1)
    for row = firstRow to lastRow
        array.set(bins, row, array.get(bins, row) + distributedVolume)

f_valueBounds(array<float> bins, int peakRow, float totalVolume, float coverage, int rows) =>
    int lowerRow = peakRow
    int upperRow = peakRow
    float includedVolume = array.get(bins, peakRow)
    int guard = 0
    while includedVolume < totalVolume * coverage and guard < rows * 2
        bool canLower = lowerRow > 0
        bool canUpper = upperRow < rows - 1
        if not canLower and not canUpper
            break
        float lowerVolume = canLower ? array.get(bins, lowerRow - 1) : -1.0
        float upperVolume = canUpper ? array.get(bins, upperRow + 1) : -1.0
        if canUpper and (not canLower or upperVolume > lowerVolume)
            upperRow += 1
            includedVolume += math.max(upperVolume, 0.0)
        else
            lowerRow -= 1
            includedVolume += math.max(lowerVolume, 0.0)
        guard += 1
    [lowerRow, upperRow]

f_buildStructure(array<float> bins, int lookback, int rows, float rangeLow, float rangeHigh, float coverage) =>
    array.clear(bins)
    for row = 0 to rows - 1
        array.push(bins, 0.0)
    float rowStep = math.max(rangeHigh - rangeLow, syminfo.mintick * rows) / rows
    for offset = 0 to lookback - 1
        f_addVolume(bins, rows, rangeLow, rowStep, low[offset], high[offset], nz(volume[offset], 0.0))
    float totalVolume = 0.0
    float peakVolume = -1.0
    int peakRow = 0
    for row = 0 to rows - 1
        float rowVolume = array.get(bins, row)
        totalVolume += rowVolume
        if rowVolume > peakVolume
            peakVolume := rowVolume
            peakRow := row
    [lowerRow, upperRow] = f_valueBounds(bins, peakRow, totalVolume, coverage, rows)
    [rangeLow + (peakRow + 0.5) * rowStep, rangeLow + lowerRow * rowStep, rangeLow + (upperRow + 1.0) * rowStep]

var int sessionBars = 0
var float sessionLow = na
var float sessionHigh = na
var float developingControl = na
var float developingLower = na
var float developingUpper = na
var array<float> volumeBins = array.new_float(0)
float rollingSessionLow = ta.lowest(low, maximumSessionBars)
float rollingSessionHigh = ta.highest(high, maximumSessionBars)

if confirmedBar
    sessionBars := newSession ? 1 : math.min(sessionBars + 1, maximumSessionBars)
    sessionLow := newSession or na(sessionLow) ? low : math.min(sessionLow, low)
    sessionHigh := newSession or na(sessionHigh) ? high : math.max(sessionHigh, high)
    float activeLow = sessionBars == maximumSessionBars ? rollingSessionLow : sessionLow
    float activeHigh = sessionBars == maximumSessionBars ? rollingSessionHigh : sessionHigh
    [controlNow, lowerNow, upperNow] = f_buildStructure(volumeBins, sessionBars, profileRows, activeLow, activeHigh, valueCoverage)
    developingControl := controlNow
    developingLower := lowerNow
    developingUpper := upperNow

float atrRaw = ta.atr(14)
float atr = math.max(nz(atrRaw, syminfo.mintick), syminfo.mintick)
float rawCenter = (developingUpper + developingLower) * 0.5
float rawHalfWidth = math.max((developingUpper - developingLower) / 2.5, atr * 0.18)
float centerStepLimit = math.max(atr * 0.22, syminfo.mintick * 2.0)
float widthExpandLimit = math.max(atr * 0.16, syminfo.mintick * 2.0)
float widthContractLimit = math.max(atr * 0.06, syminfo.mintick)
var float valueCenter = na
var float valueHalfWidth = na

if confirmedBar and not na(rawCenter) and not na(rawHalfWidth)
    float centerStep = (rawCenter - nz(valueCenter, rawCenter)) * 0.40
    float widthStep = (rawHalfWidth - nz(valueHalfWidth, rawHalfWidth)) * 0.40
    float widthLimit = widthStep >= 0.0 ? widthExpandLimit : widthContractLimit
    valueCenter := na(valueCenter) ? rawCenter : valueCenter + f_clamp(centerStep, -centerStepLimit, centerStepLimit)
    valueHalfWidth := na(valueHalfWidth) ? rawHalfWidth : math.max(valueHalfWidth + f_clamp(widthStep, -widthLimit, widthLimit), syminfo.mintick * 2.0)

bool valueReady = not na(valueCenter) and not na(valueHalfWidth)
float valueUpper = valueReady ? valueCenter + valueHalfWidth : na
float valueLower = valueReady ? valueCenter - valueHalfWidth : na
float fastReference = ta.ema(close, 9)
float slowReference = ta.ema(close, 24)
float balanceReference = ta.ema(hlc3, 21)
float momentum = ta.ema(ta.change(close), 8)
[plusDI, minusDI, _] = ta.dmi(14, 14)
float diTotal = plusDI + minusDI
float diState = diTotal > 0.0 ? (plusDI - minusDI) / diTotal : 0.0
float alignmentState = fastReference > slowReference ? 1.0 : fastReference < slowReference ? -1.0 : 0.0
float momentumState = f_clamp(momentum / atr / 0.30, -1.0, 1.0)
float displacementState = f_clamp((close - balanceReference) / atr / 1.20, -1.0, 1.0)
float valuePositionState = valueReady ? close > valueUpper ? 1.0 : close < valueLower ? -1.0 : f_clamp((close - valueCenter) / math.max(valueHalfWidth, syminfo.mintick), -1.0, 1.0) : 0.0
float directionScore = diState * 0.30 + alignmentState * 0.25 + momentumState * 0.20 + displacementState * 0.15 + valuePositionState * 0.10
float candleRange = math.max(high - low, syminfo.mintick)
float candleBody = math.abs(close - open)
float bodyEfficiency = candleBody / candleRange
float closeLocation = (close - low) / candleRange
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float averageVolume = ta.sma(volume, 20)
bool volumeAvailable = not na(volume) and volume > 0.0 and not na(averageVolume) and averageVolume > 0.0
float relativeVolume = volumeAvailable ? volume / averageVolume : 1.0
bool participationExpansion = not volumeAvailable or relativeVolume >= 1.02
float compressionPath = math.abs(close - close[1]) + math.abs(close[1] - close[2]) + math.abs(close[2] - close[3]) + math.abs(close[3] - close[4]) + math.abs(close[4] - close[5]) + math.abs(close[5] - close[6]) + math.abs(close[6] - close[7])
float compressionEfficiency = compressionPath > syminfo.mintick ? math.abs(close - close[7]) / compressionPath : 1.0
float compressionRange = ta.highest(high, 8) - ta.lowest(low, 8)
bool compressed = compressionRange <= atr * 1.50 and compressionEfficiency <= 0.30
float priorLow = ta.lowest(low, 6)[1]
float priorHigh = ta.highest(high, 6)[1]
float breakHigh = ta.highest(high, 2)[1]
float breakLow = ta.lowest(low, 2)[1]
bool bullishSweep = low < priorLow and close > priorLow and close > open
bool bearishSweep = high > priorHigh and close < priorHigh and close < open
bool bullishBreak = close > breakHigh and close > open
bool bearishBreak = close < breakLow and close < open
bool bullishAcceptance = valueReady and close > valueUpper and close[1] > valueUpper[1]
bool bearishAcceptance = valueReady and close < valueLower and close[1] < valueLower[1]

float trendSlow = ta.wma(close, 38)
float trendFast = ta.wma(close, 19)
float trendRaw = ta.wma(2.0 * trendFast - trendSlow, 6)
float dynamicTrendline = ta.ema(trendRaw, 5)
float trendSlope = (dynamicTrendline - dynamicTrendline[1]) / atr
float priorTrendSlope = nz(trendSlope[1])
bool bullishTrendTest = low <= dynamicTrendline + atr * 0.12 and close > dynamicTrendline and close > open
bool bearishTrendTest = high >= dynamicTrendline - atr * 0.12 and close < dynamicTrendline and close < open
bool bullishTrendReversal = bullishTrendTest and lowerWick > upperWick and trendSlope >= -0.015 and trendSlope >= priorTrendSlope - 0.02 and directionScore > 0.05
bool bearishTrendReversal = bearishTrendTest and upperWick > lowerWick and trendSlope <= 0.015 and trendSlope <= priorTrendSlope + 0.02 and directionScore < -0.05
bool bullishResponse = (bullishSweep or bullishBreak or bullishAcceptance or bullishTrendReversal) and lowerWick >= upperWick * 0.70
bool bearishResponse = (bearishSweep or bearishBreak or bearishAcceptance or bearishTrendReversal) and upperWick >= lowerWick * 0.70
int bullishVotes = (close > open ? 1 : 0) + (close > close[1] ? 1 : 0) + (momentum > momentum[1] ? 1 : 0) + (fastReference > slowReference ? 1 : 0) + (plusDI > minusDI ? 1 : 0) + (directionScore > 0.10 ? 1 : 0) + (close > developingControl ? 1 : 0) + (bodyEfficiency >= 0.34 and closeLocation >= 0.58 ? 1 : 0)
int bearishVotes = (close < open ? 1 : 0) + (close < close[1] ? 1 : 0) + (momentum < momentum[1] ? 1 : 0) + (fastReference < slowReference ? 1 : 0) + (minusDI > plusDI ? 1 : 0) + (directionScore < -0.10 ? 1 : 0) + (close < developingControl ? 1 : 0) + (bodyEfficiency >= 0.34 and closeLocation <= 0.42 ? 1 : 0)
bool rawBuy = confirmedBar and valueReady and not compressed and participationExpansion and bullishResponse and bullishVotes >= 6 and directionScore >= 0.12 and bullishVotes > bearishVotes
bool rawSale = confirmedBar and valueReady and not compressed and participationExpansion and bearishResponse and bearishVotes >= 6 and directionScore <= -0.12 and bearishVotes > bullishVotes
var int signalDirection = 0
bool finalBuy = false
bool finalSale = false

if confirmedBar
    if signalDirection == 0
        if rawBuy and not rawSale
            finalBuy := true
            signalDirection := 1
        else if rawSale and not rawBuy
            finalSale := true
            signalDirection := -1
    else if signalDirection == 1 and rawSale
        finalSale := true
        signalDirection := -1
    else if signalDirection == -1 and rawBuy
        finalBuy := true
        signalDirection := 1

float effectiveVolume = na(volume) or volume <= 0.0 ? 1.0 : volume
float cloudCloseLocation = f_clamp((close - low) / candleRange, 0.0, 1.0)
float cloudVwma = ta.vwma(hlc3, 180)
float cloudCenter = nz(cloudVwma, ta.ema(hlc3, 180))
float cloudDeviation = math.max(nz(ta.stdev(hlc3, 180), atr), atr * 0.55)
float participationBase = ta.ema(effectiveVolume, 14)
float signedAverage = ta.ema(effectiveVolume * ((cloudCloseLocation - 0.50) * 2.0), 14)
float cloudParticipation = participationBase > 0.0000001 ? f_clamp(signedAverage / participationBase, -1.0, 1.0) : 0.0
float cloudSlope = f_clamp(nz((cloudCenter - cloudCenter[1]) / atr, 0.0), -1.0, 1.0)
float cloudDisplacement = f_clamp((close - cloudCenter) / cloudDeviation, -1.0, 1.0)
float cloudDirection = cloudParticipation * 0.45 + cloudSlope * 0.30 + cloudDisplacement * 0.25
float cloudBasis = ta.ema(hlc3, 7)
float cloudBasisSlope = nz((cloudBasis - cloudBasis[1]) / atr, 0.0)
bool cloudBullRaw = cloudDirection >= 0.12 and cloudBasisSlope >= -0.01 and close >= cloudCenter
bool cloudBearRaw = cloudDirection <= -0.12 and cloudBasisSlope <= 0.01 and close <= cloudCenter
bool cloudBull = confirmedBar and cloudBullRaw and cloudBullRaw[1]
bool cloudBear = confirmedBar and cloudBearRaw and cloudBearRaw[1]
float cloudWidth = math.min(math.max(atr * 0.72, math.abs(close - cloudBasis) * 0.92), atr * 1.55)
float cloudUpper = cloudBull ? cloudBasis + cloudWidth : cloudBear ? cloudBasis : na
float cloudLower = cloudBull ? cloudBasis : cloudBear ? cloudBasis - cloudWidth : na
color trendColour = dynamicTrendline >= dynamicTrendline[1] ? bullishTrendColor : bearishTrendColor
signalLabelSize = signalSizeInput == "TINY" ? size.tiny : signalSizeInput == "NORMAL" ? size.normal : size.small
cloudUpperPlot = plot(showCloud ? cloudUpper : na, "Ribbon Upper", color = color.new(color.gray, 100), editable = false)
cloudLowerPlot = plot(showCloud ? cloudLower : na, "Ribbon Lower", color = color.new(color.gray, 100), editable = false)
fill(cloudUpperPlot, cloudLowerPlot, color = showCloud and cloudBull ? bullCloudColor : na, title = "Bull Ribbon", editable = false)
fill(cloudUpperPlot, cloudLowerPlot, color = showCloud and cloudBear ? bearCloudColor : na, title = "Bear Ribbon", editable = false)
plot(showTrendline ? dynamicTrendline : na, "Dynamic Trendline", color = trendColour, linewidth = trendlineWidth, editable = false)

if showBuySignals and finalBuy
    label.new(bar_index, low, "BUY", yloc = yloc.belowbar, style = label.style_label_up, color = buyColor, textcolor = color.white, size = signalLabelSize)
if showSaleSignals and finalSale
    label.new(bar_index, high, "SALE", yloc = yloc.abovebar, style = label.style_label_down, color = saleColor, textcolor = color.white, size = signalLabelSize)

alertcondition(finalBuy, "INTRADAY BUY", "SBP Market Behaviour Navigator: confirmed intraday BUY")
alertcondition(finalSale, "INTRADAY SALE", "SBP Market Behaviour Navigator: confirmed intraday SALE")
alertcondition(finalBuy or finalSale, "INTRADAY BUY OR SALE", "SBP Market Behaviour Navigator: confirmed intraday BUY or SALE")
alertcondition(cloudBull and not cloudBull[1], "BULL RIBBON", "SBP Market Behaviour Navigator: Bull Ribbon started")
alertcondition(cloudBear and not cloudBear[1], "BEAR RIBBON", "SBP Market Behaviour Navigator: Bear Ribbon started")
````
