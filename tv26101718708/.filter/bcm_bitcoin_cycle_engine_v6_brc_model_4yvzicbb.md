# BCM Bitcoin Cycle Engine v6 BRC Model

- url: https://www.tradingview.com/script/4yvzicBb-BCM-Bitcoin-Cycle-Engine-v6-BRC-Model/
- type: indicator
- pine_id: PUB;098d9fccb380440388bfe3a544fbacea
- version: 4.0

## Description

Bitcoin Cycle Engine v6 — BRC Model

Overview

Bitcoin Cycle Engine v6 (BRC Model) is an advanced Bitcoin macro-cycle analysis framework built upon the excellent Bitcoin Rainbow Wave model originally created by Leo (@leomathheart).

The model combines multiple independent long-term indicators into a single decision engine to estimate Bitcoin’s current position within its market cycle.

It is designed for Daily timeframe analysis and long-term investors.

⸻

Features

• Power Law Regression

• Rainbow Bands

• Rainbow Wave

• Halving Cycle Timing

• Cycle Phase Detection

• Accumulation vs Distribution Engine

• Market Regime Classification

• Dynamic Risk Assessment

• Confidence Score

• Timing Score

• Long-Term Cycle Targets

• Dynamic Buy Zones

⸻

How to Use

The indicator is intended to identify where Bitcoin currently sits within its long-term cycle.

BCM Score

Overall macro-cycle strength.

Higher values indicate stronger long-term accumulation conditions.

⸻

Expected Phase

Shows the most likely market phase.

Examples:

• Bottom Building

• Recovery

• Expansion

• Distribution

⸻

Accumulation / Distribution

Represents the current probability that the market is in an accumulation or distribution environment.

These values are independent probabilities and therefore do not necessarily add up to 100%.

⸻

Risk Mode

Current market risk:

• Low

• Medium

• High

⸻

Rainbow Floor

Estimated long-term support generated from the Power Law Rainbow model.

Historically Bitcoin has respected this area throughout previous market cycles.

⸻

Buy Levels

Next Buy

Major Buy

Extreme Buy

These levels represent progressively stronger accumulation zones rather than exact reversal prices.

⸻

Targets

Mid Target

Cycle Target

Long Target

These are statistical cycle objectives generated from the model and should not be interpreted as guaranteed price predictions.

⸻

Best Timeframe

Recommended timeframe:

Daily (1D)

The model is designed for macro-cycle analysis and is not intended for intraday trading.

⸻

Acknowledgements

Special thanks to Leo (@leomathheart) for creating the original Bitcoin Rainbow Wave model that inspired this work.

The BRC Model significantly extends the original framework with proprietary cycle scoring, market regime analysis, timing models and macro-cycle intelligence.

⸻

Disclaimer

This indicator is intended for educational and research purposes only.

It represents a probabilistic market model and should not be considered financial advice.

## Source Code

````pine
//@version=6
indicator(title="Bitcoin Cycle Engine v8.1 — BRC Live Model", shorttitle="BRC V8.1", overlay=true, max_labels_count=100)

// Built upon the open-source Bitcoin Rainbow Wave model by leoum.
// BRC extension: live cycle scoring, shifted market-phase classification,
// technical confirmation, projections, alerts and dashboard.

// ============================================================================
// INPUTS
// ============================================================================
showPowerLaw = input.bool(true, "Show Power Law", group="Display")
showRainbow  = input.bool(true, "Show Rainbow Bands", group="Display")
showWave     = input.bool(true, "Show Wave Bands", group="Display")
showFills    = input.bool(false, "Show Band Fills", group="Display")
showTable    = input.bool(true, "Show Dashboard", group="Display")
showLabel    = input.bool(true, "Show Current Label", group="Display")
compactMode  = input.bool(false, "Compact Dashboard", group="Dashboard")

tablePositionInput = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group="Dashboard")
tableSizeInput = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal"], group="Dashboard")

projectionStep1 = input.float(0.10, "Recovery Projection Δh", minval=0.01, maxval=1.00, step=0.01, group="Projections")
projectionStep2 = input.float(0.20, "Cycle Projection Δh", minval=0.01, maxval=1.50, step=0.01, group="Projections")
projectionStep3 = input.float(0.30, "Long Projection Δh", minval=0.01, maxval=2.00, step=0.01, group="Projections")

// ============================================================================
// HELPERS
// ============================================================================
tablePosition = tablePositionInput == "Top Left" ? position.top_left : tablePositionInput == "Middle Right" ? position.middle_right : tablePositionInput == "Middle Left" ? position.middle_left : tablePositionInput == "Bottom Right" ? position.bottom_right : tablePositionInput == "Bottom Left" ? position.bottom_left : position.top_right
tableTextSize = tableSizeInput == "Tiny" ? size.tiny : tableSizeInput == "Normal" ? size.normal : size.small

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_score_color(float score) =>
    score >= 75 ? color.lime : score >= 55 ? color.orange : color.red

f_risk_color(string risk) =>
    risk == "LOW" ? color.lime : risk == "MEDIUM" ? color.orange : color.red

f_model_color(string status) =>
    status == "VALID" ? color.lime : status == "WARNING" ? color.orange : color.red

f_progress_bar(float percent) =>
    int segments = 14
    int filled = int(math.round(f_clamp(percent, 0.0, 100.0) / 100.0 * segments))
    string result = ""
    for i = 1 to segments
        result += i <= filled ? "█" : "░"
    result

f_table_row(table tableId, int row, string leftText, string rightText, color rightColor) =>
    table.cell(tableId, 0, row, leftText, text_color=color.white, text_size=tableTextSize)
    table.cell(tableId, 1, row, rightText, text_color=rightColor, text_size=tableTextSize)

f_divider(table tableId, int row) =>
    table.cell(tableId, 0, row, "────────────", text_color=color.new(color.gray, 25), text_size=tableTextSize)
    table.cell(tableId, 1, row, "────────────", text_color=color.new(color.gray, 25), text_size=tableTextSize)

// ============================================================================
// HALVING-TIME ANCHORS
// ============================================================================
H0116 = timestamp(2009, 10, 5, 15, 41, 28)
H025  = timestamp(2010, 4, 22, 12, 15, 34)
H050  = timestamp(2011, 1, 28, 10, 41, 47)
H075  = timestamp(2011, 12, 14, 16, 24, 37)
H100  = timestamp(2012, 11, 28, 16, 24, 38)
H125  = timestamp(2013, 10, 9, 5, 28, 22)
H150  = timestamp(2014, 8, 11, 5, 6, 5)
H175  = timestamp(2015, 7, 29, 15, 45, 38)
H200  = timestamp(2016, 7, 9, 18, 46, 13)
H225  = timestamp(2017, 6, 23, 7, 43, 51)
H250  = timestamp(2018, 5, 29, 22, 24, 42)
H275  = timestamp(2019, 5, 24, 5, 37, 41)
H300  = timestamp(2020, 5, 11, 21, 23, 43)
H325  = timestamp(2021, 5, 8, 5, 20, 11)
H350  = timestamp(2022, 5, 5, 12, 23, 33)
H375  = timestamp(2023, 4, 29, 17, 6, 18)
H400  = timestamp(2024, 4, 20, 2, 9, 27)
H425  = timestamp(2025, 4, 15, 8, 16, 12)

dur0116 = (H025 - H0116) / (0.25 - 0.116)
dur025  = (H050 - H025) * 4
dur050  = (H075 - H050) * 4
dur075  = (H100 - H075) * 4
dur100  = (H125 - H100) * 4
dur125  = (H150 - H125) * 4
dur150  = (H175 - H150) * 4
dur175  = (H200 - H175) * 4
dur200  = (H225 - H200) * 4
dur225  = (H250 - H225) * 4
dur250  = (H275 - H250) * 4
dur275  = (H300 - H275) * 4
dur300  = (H325 - H300) * 4
dur325  = (H350 - H325) * 4
dur350  = (H375 - H350) * 4
dur375  = (H400 - H375) * 4
dur400  = (H425 - H400) * 4
durFuture = H425 - H325

h = if time >= H425
    4.25 + (time - H425) / durFuture
else if time >= H400
    4.00 + (time - H400) / dur400
else if time >= H375
    3.75 + (time - H375) / dur375
else if time >= H350
    3.50 + (time - H350) / dur350
else if time >= H325
    3.25 + (time - H325) / dur325
else if time >= H300
    3.00 + (time - H300) / dur300
else if time >= H275
    2.75 + (time - H275) / dur275
else if time >= H250
    2.50 + (time - H250) / dur250
else if time >= H225
    2.25 + (time - H225) / dur225
else if time >= H200
    2.00 + (time - H200) / dur200
else if time >= H175
    1.75 + (time - H175) / dur175
else if time >= H150
    1.50 + (time - H150) / dur150
else if time >= H125
    1.25 + (time - H125) / dur125
else if time >= H100
    1.00 + (time - H100) / dur100
else if time >= H075
    0.75 + (time - H075) / dur075
else if time >= H050
    0.50 + (time - H050) / dur050
else if time >= H025
    0.25 + (time - H025) / dur025
else
    0.116 + (time - H0116) / dur0116

cyclePhase = h - math.floor(h)

// ============================================================================
// RAINBOW WAVE MODEL
// ============================================================================
powerIntercept = 1.47
powerSlope = 5.38
decayBase = 0.79

f_model(float hValue) =>
    float safeH = math.max(hValue, 0.001)
    float decayValue = math.pow(decayBase, safeH + 1.0)
    float delayValue = safeH < 3.28 ? 0.025 + math.pow(0.3, safeH - 0.05) * (1.05 + math.cos(2.5 * (safeH + 0.15))) : 0.025
    float sineValue = math.sin(2.0 * math.pi * (safeH - delayValue))
    float powerLawValue = math.pow(10.0, powerIntercept + powerSlope * math.log10(safeH))
    float rainbowFloorValue = powerLawValue * math.pow(10.0, -decayValue)
    float rainbowMinus2Value = powerLawValue * math.pow(10.0, -2.0 * decayValue / 3.0)
    float rainbowMinus1Value = powerLawValue * math.pow(10.0, -decayValue / 3.0)
    float rainbowPlus1Value = powerLawValue * math.pow(10.0, decayValue / 3.0)
    float rainbowPlus2Value = powerLawValue * math.pow(10.0, 2.0 * decayValue / 3.0)
    float rainbowPlus3Value = powerLawValue * math.pow(10.0, decayValue)
    float rainbowPlus4Value = powerLawValue * math.pow(10.0, 4.0 * decayValue / 3.0)
    float rainbowTopValue = powerLawValue * math.pow(10.0, 5.0 * decayValue / 3.0)
    float waveFloorValue = powerLawValue * math.pow(10.0, decayValue * math.max(-1.0, sineValue - 5.0 / 6.0))
    float waveLowerValue = powerLawValue * math.pow(10.0, decayValue * math.max(-1.0, sineValue - 5.0 / 12.0))
    float waveMiddleValue = powerLawValue * math.pow(10.0, decayValue * sineValue)
    float waveUpperValue = powerLawValue * math.pow(10.0, decayValue * (sineValue + 5.0 / 12.0))
    float waveTopValue = powerLawValue * math.pow(10.0, decayValue * (sineValue + 5.0 / 6.0))
    [powerLawValue, rainbowFloorValue, rainbowMinus2Value, rainbowMinus1Value, rainbowPlus1Value, rainbowPlus2Value, rainbowPlus3Value, rainbowPlus4Value, rainbowTopValue, waveFloorValue, waveLowerValue, waveMiddleValue, waveUpperValue, waveTopValue]

[powerLaw, rainbowFloor, rainbowMinus2, rainbowMinus1, rainbowPlus1, rainbowPlus2, rainbowPlus3, rainbowPlus4, rainbowTop, waveFloor, waveLower, waveMiddle, waveUpper, waveTop] = f_model(h)
[powerLawP1, floorP1, rM2P1, rM1P1, rP1P1, rP2P1, rP3P1, rP4P1, rTopP1, waveFloorP1, waveLowerP1, waveMiddleP1, waveUpperP1, waveTopP1] = f_model(h + projectionStep1)
[powerLawP2, floorP2, rM2P2, rM1P2, rP1P2, rP2P2, rP3P2, rP4P2, rTopP2, waveFloorP2, waveLowerP2, waveMiddleP2, waveUpperP2, waveTopP2] = f_model(h + projectionStep2)
[powerLawP3, floorP3, rM2P3, rM1P3, rP1P3, rP2P3, rP3P3, rP4P3, rTopP3, waveFloorP3, waveLowerP3, waveMiddleP3, waveUpperP3, waveTopP3] = f_model(h + projectionStep3)

// ============================================================================
// PLOTS
// ============================================================================
pPower = plot(showPowerLaw ? powerLaw : na, "Power Law", color.green, 3)
pFloor = plot(showRainbow ? rainbowFloor : na, "Rainbow Floor", color.purple, 2)
pMinus2 = plot(showRainbow ? rainbowMinus2 : na, "Rainbow -2", color.blue, 1)
pMinus1 = plot(showRainbow ? rainbowMinus1 : na, "Rainbow -1", color.aqua, 1)
pCenter = plot(showRainbow ? powerLaw : na, "Rainbow Center", color.green, 2)
pPlus1 = plot(showRainbow ? rainbowPlus1 : na, "Rainbow +1", color.yellow, 1)
pPlus2 = plot(showRainbow ? rainbowPlus2 : na, "Rainbow +2", color.orange, 1)
pPlus3 = plot(showRainbow ? rainbowPlus3 : na, "Rainbow +3", color.orange, 1)
pTop = plot(showRainbow ? rainbowTop : na, "Rainbow Top", color.red, 2)
pWaveFloor = plot(showWave ? waveFloor : na, "Wave Floor", color.aqua, 2)
pWaveLower = plot(showWave ? waveLower : na, "Wave Lower", color.blue, 1)
pWaveMiddle = plot(showWave ? waveMiddle : na, "Wave Middle", color.fuchsia, 2)
pWaveUpper = plot(showWave ? waveUpper : na, "Wave Upper", color.orange, 1)
pWaveTop = plot(showWave ? waveTop : na, "Wave Top", color.red, 2)

fill(pFloor, pMinus2, color=showFills ? color.new(color.purple, 85) : na)
fill(pMinus2, pMinus1, color=showFills ? color.new(color.blue, 87) : na)
fill(pMinus1, pCenter, color=showFills ? color.new(color.aqua, 90) : na)
fill(pCenter, pPlus1, color=showFills ? color.new(color.green, 90) : na)
fill(pPlus1, pPlus2, color=showFills ? color.new(color.yellow, 89) : na)
fill(pPlus2, pPlus3, color=showFills ? color.new(color.orange, 88) : na)
fill(pPlus3, pTop, color=showFills ? color.new(color.red, 88) : na)

// ============================================================================
// LIVE TECHNICAL DATA
// ============================================================================
dailyRSI = ta.rsi(close, 14)
weeklyRSI = request.security(syminfo.tickerid, "W", ta.rsi(close, 14), barmerge.gaps_off, barmerge.lookahead_off)
[macdLine, macdSignal, macdHistogram] = ta.macd(close, 12, 26, 9)
sma200D = ta.sma(close, 200)
sma200W = request.security(syminfo.tickerid, "W", ta.sma(close, 200), barmerge.gaps_off, barmerge.lookahead_off)
atr14 = ta.atr(14)
atrPercent = close > 0 ? atr14 / close * 100.0 : 0.0
volumeAverage = ta.sma(volume, 30)
volumeRatio = not na(volumeAverage) and volumeAverage > 0 ? volume / volumeAverage : 1.0
macdBullish = macdLine > macdSignal
priceAbove200D = not na(sma200D) and close > sma200D
priceAbove200W = not na(sma200W) and close > sma200W

rainbowFloorDistance = rainbowFloor > 0 ? (close / rainbowFloor - 1.0) * 100.0 : na
waveFloorDistance = waveFloor > 0 ? (close / waveFloor - 1.0) * 100.0 : na
floorsOverlap = rainbowFloor > 0 and waveFloor > 0 ? math.abs(waveFloor / rainbowFloor - 1.0) < 0.005 : false
logFloor = math.log10(math.max(rainbowFloor, 0.000001))
logTop = math.log10(math.max(rainbowTop, 0.000001))
logPrice = math.log10(math.max(close, 0.000001))
rainbowPosition = logTop != logFloor ? f_clamp((logPrice - logFloor) / (logTop - logFloor) * 100.0, 0.0, 100.0) : 50.0

// ============================================================================
// LIVE SCORES
// ============================================================================
rainbowFloorScore = rainbowFloorDistance <= 0 ? 100.0 : rainbowFloorDistance <= 3 ? 97.0 : rainbowFloorDistance <= 7 ? 90.0 : rainbowFloorDistance <= 12 ? 80.0 : rainbowFloorDistance <= 20 ? 65.0 : rainbowFloorDistance <= 35 ? 45.0 : 25.0
waveFloorScore = waveFloorDistance <= 0 ? 100.0 : waveFloorDistance <= 3 ? 95.0 : waveFloorDistance <= 7 ? 88.0 : waveFloorDistance <= 12 ? 76.0 : waveFloorDistance <= 20 ? 60.0 : 35.0
combinedFloorScore = floorsOverlap ? rainbowFloorScore : rainbowFloorScore * 0.55 + waveFloorScore * 0.45
bottomPhaseScore = cyclePhase >= 0.60 and cyclePhase <= 0.65 ? 100.0 : cyclePhase >= 0.57 and cyclePhase <= 0.68 ? 90.0 : cyclePhase >= 0.53 and cyclePhase <= 0.72 ? 75.0 : cyclePhase >= 0.48 and cyclePhase <= 0.78 ? 55.0 : 25.0
topPhaseScore = cyclePhase >= 0.35 and cyclePhase <= 0.42 ? 100.0 : cyclePhase >= 0.30 and cyclePhase <= 0.47 ? 80.0 : cyclePhase >= 0.25 and cyclePhase <= 0.52 ? 60.0 : 20.0
dailyRSIAccumScore = dailyRSI <= 25 ? 100.0 : dailyRSI <= 35 ? 90.0 : dailyRSI <= 45 ? 75.0 : dailyRSI <= 55 ? 55.0 : dailyRSI <= 65 ? 35.0 : 15.0
weeklyRSIAccumScore = weeklyRSI <= 30 ? 100.0 : weeklyRSI <= 40 ? 85.0 : weeklyRSI <= 50 ? 65.0 : weeklyRSI <= 60 ? 40.0 : 20.0
dailyRSIDistScore = dailyRSI >= 80 ? 100.0 : dailyRSI >= 70 ? 90.0 : dailyRSI >= 62 ? 72.0 : dailyRSI >= 55 ? 50.0 : 20.0
weeklyRSIDistScore = weeklyRSI >= 80 ? 100.0 : weeklyRSI >= 70 ? 90.0 : weeklyRSI >= 60 ? 70.0 : weeklyRSI >= 52 ? 48.0 : 20.0
momentumRecoveryScore = macdBullish and dailyRSI < 55 ? 85.0 : macdBullish ? 68.0 : macdHistogram > macdHistogram[1] ? 58.0 : 35.0
trendHealthScore = priceAbove200W and priceAbove200D ? 90.0 : priceAbove200W ? 72.0 : priceAbove200D ? 58.0 : 35.0
upperBandScore = close >= rainbowTop ? 100.0 : close >= rainbowPlus3 ? 85.0 : close >= rainbowPlus2 ? 68.0 : close >= rainbowPlus1 ? 48.0 : 15.0
waveTopScore = close >= waveTop ? 100.0 : close >= waveUpper ? 78.0 : close >= waveMiddle ? 50.0 : 15.0
volatilityRiskScore = atrPercent >= 12 ? 90.0 : atrPercent >= 8 ? 75.0 : atrPercent >= 5 ? 55.0 : atrPercent >= 3 ? 38.0 : 25.0
volumeConfirmation = volumeRatio >= 2.0 ? 90.0 : volumeRatio >= 1.5 ? 75.0 : volumeRatio >= 1.1 ? 60.0 : 45.0

accumulationScore = f_clamp(combinedFloorScore * 0.36 + bottomPhaseScore * 0.26 + dailyRSIAccumScore * 0.12 + weeklyRSIAccumScore * 0.10 + momentumRecoveryScore * 0.10 + volumeConfirmation * 0.06, 0.0, 100.0)
distributionScore = f_clamp(upperBandScore * 0.32 + waveTopScore * 0.23 + topPhaseScore * 0.20 + dailyRSIDistScore * 0.10 + weeklyRSIDistScore * 0.10 + volatilityRiskScore * 0.05, 0.0, 100.0)
netBias = accumulationScore - distributionScore

floorBreak = close < rainbowFloor
deepFloorBreak = close < rainbowFloor * 0.92
floorConfluenceScore = floorsOverlap ? 100.0 : f_clamp(100.0 - math.abs(waveFloor / rainbowFloor - 1.0) * 500.0, 0.0, 100.0)
floorRespectScore = deepFloorBreak ? 15.0 : floorBreak ? 42.0 : rainbowFloorDistance <= 5 ? 95.0 : rainbowFloorDistance <= 12 ? 88.0 : rainbowFloorDistance <= 25 ? 72.0 : 55.0
modelConfidence = f_clamp(floorRespectScore * 0.40 + floorConfluenceScore * 0.25 + bottomPhaseScore * 0.20 + trendHealthScore * 0.15, 0.0, 100.0)
modelStatus = deepFloorBreak ? "BROKEN" : floorBreak ? "WARNING" : "VALID"

rsiTemperature = f_clamp(dailyRSI * 0.55 + weeklyRSI * 0.45, 0.0, 100.0)
btcTemperature = f_clamp(rainbowPosition * 0.45 + distributionScore * 0.30 + rsiTemperature * 0.20 + volatilityRiskScore * 0.05, 0.0, 100.0)
cycleHealth = f_clamp(modelConfidence * 0.30 + trendHealthScore * 0.20 + momentumRecoveryScore * 0.15 + floorConfluenceScore * 0.15 + (100.0 - volatilityRiskScore) * 0.10 + volumeConfirmation * 0.10, 0.0, 100.0)
brcScore = f_clamp(accumulationScore * 0.50 + (100.0 - distributionScore) * 0.20 + modelConfidence * 0.15 + cycleHealth * 0.15, 0.0, 100.0)

// ============================================================================
// CALIBRATED MARKET-PHASE ENGINE
// cyclePhase remains unchanged. The boundaries are aligned with the original
// Rainbow Wave observations: euphoria near 0.35-0.42 and the bottom-building
// transition near 0.50-0.58. Expansion crosses the 1.00 -> 0.00 boundary.
// ============================================================================
float phaseStart = na
float phaseEnd = na
float phasePosition = cyclePhase
string currentPhase = ""
string expectedNextPhase = ""

if cyclePhase < 0.20
    phasePosition := cyclePhase + 1.00
    phaseStart := 0.80
    phaseEnd := 1.20
    currentPhase := "Expansion"
    expectedNextPhase := "Distribution"
else if cyclePhase < 0.35
    phaseStart := 0.20
    phaseEnd := 0.35
    currentPhase := "Distribution"
    expectedNextPhase := "Euphoria"
else if cyclePhase < 0.42
    phaseStart := 0.35
    phaseEnd := 0.42
    currentPhase := "Euphoria"
    expectedNextPhase := "Capitulation"
else if cyclePhase < 0.50
    phaseStart := 0.42
    phaseEnd := 0.50
    currentPhase := "Capitulation"
    expectedNextPhase := "Bottom Building"
else if cyclePhase < 0.58
    phaseStart := 0.50
    phaseEnd := 0.58
    currentPhase := "Bottom Building"
    expectedNextPhase := "Accumulation"
else if cyclePhase < 0.68
    phaseStart := 0.58
    phaseEnd := 0.68
    currentPhase := "Accumulation"
    expectedNextPhase := "Recovery"
else if cyclePhase < 0.80
    phaseStart := 0.68
    phaseEnd := 0.80
    currentPhase := "Recovery"
    expectedNextPhase := "Expansion"
else
    phaseStart := 0.80
    phaseEnd := 1.20
    currentPhase := "Expansion"
    expectedNextPhase := "Distribution"

phaseProgress = f_clamp((phasePosition - phaseStart) / math.max(phaseEnd - phaseStart, 0.000001) * 100.0, 0.0, 100.0)
progressBar = f_progress_bar(phaseProgress)
millisecondsPerDay = 86400000.0
cycleDurationDays = durFuture / millisecondsPerDay
remainingPhaseFraction = math.max(phaseEnd - phasePosition, 0.0)
remainingPhaseDays = remainingPhaseFraction * cycleDurationDays
phaseTechnicalAlignment = currentPhase == "Capitulation" or currentPhase == "Bottom Building" or currentPhase == "Accumulation" ? accumulationScore : currentPhase == "Distribution" or currentPhase == "Euphoria" ? distributionScore : cycleHealth
phaseConfidence = f_clamp(phaseTechnicalAlignment * 0.45 + modelConfidence * 0.35 + cycleHealth * 0.20, 0.0, 100.0)

// ============================================================================
// REGIME AND LEVELS
// ============================================================================
cycleMode = distributionScore >= 80 ? "DISTRIBUTE" : distributionScore >= 65 ? "REDUCE RISK" : accumulationScore >= 82 ? "ACCUMULATION+" : accumulationScore >= 65 ? "ACCUMULATION" : "NEUTRAL"
marketBiasLabel = netBias >= 60 ? "Strong Accumulation" : netBias >= 30 ? "Accumulation Bias" : netBias > -30 ? "Neutral Bias" : netBias > -60 ? "Distribution Bias" : "Strong Distribution"
marketRegime = btcTemperature <= 20 ? "Deep Value" : btcTemperature <= 35 ? "Value" : btcTemperature <= 55 ? "Neutral" : btcTemperature <= 75 ? "Expensive" : "Bubble"
riskMode = deepFloorBreak ? "HIGH" : btcTemperature >= 75 ? "HIGH" : distributionScore >= 65 ? "HIGH" : volatilityRiskScore >= 75 ? "MEDIUM" : modelConfidence >= 75 and accumulationScore >= 65 ? "LOW" : "MEDIUM"
cycleHealthLabel = cycleHealth >= 80 ? "Excellent" : cycleHealth >= 65 ? "Strong" : cycleHealth >= 50 ? "Neutral" : "Weak"

nextLevel = math.max(rainbowFloor, close * 0.98)
modelFloor = rainbowFloor
extremeFloor = math.min(rainbowFloor, waveFloor) * 0.92
recoveryProjection = waveMiddleP1
cycleProjection = waveUpperP2
longProjection = waveTopP3

// ============================================================================
// DASHBOARD
// ============================================================================
var table dashboard = table.new(tablePosition, 2, 34, border_width=1, frame_color=color.new(color.gray, 55), border_color=color.new(color.gray, 78))

if barstate.islast
    table.clear(dashboard, 0, 0, 1, 33)
    if showTable
        table.cell(dashboard, 0, 0, "BRC LIVE SCORE", bgcolor=color.black, text_color=color.white, text_size=tableTextSize)
        table.cell(dashboard, 1, 0, str.tostring(brcScore, "#.0"), bgcolor=brcScore >= 75 ? color.new(color.green, 15) : brcScore >= 55 ? color.new(color.orange, 15) : color.new(color.red, 15), text_color=color.white, text_size=tableTextSize)
        f_table_row(dashboard, 1, "Current Phase", currentPhase, color.lime)
        f_table_row(dashboard, 2, "Progress", progressBar, color.lime)
        f_table_row(dashboard, 3, "Phase Progress", str.tostring(phaseProgress, "#.0") + "%", color.white)
        f_table_row(dashboard, 4, "Days Remaining", str.tostring(math.ceil(remainingPhaseDays), "#") + " days", color.white)
        f_table_row(dashboard, 5, "Next Phase", expectedNextPhase, color.aqua)
        f_table_row(dashboard, 6, "Phase Confidence", str.tostring(phaseConfidence, "#.0") + "%", f_score_color(phaseConfidence))
        f_divider(dashboard, 7)
        f_table_row(dashboard, 8, "Cycle Mode", cycleMode, cycleMode == "DISTRIBUTE" ? color.red : cycleMode == "REDUCE RISK" ? color.orange : color.lime)
        f_table_row(dashboard, 9, "Accumulation", str.tostring(accumulationScore, "#.0") + "%", color.lime)
        f_table_row(dashboard, 10, "Distribution", str.tostring(distributionScore, "#.0") + "%", color.red)
        f_table_row(dashboard, 11, "Market Bias", marketBiasLabel, netBias >= 0 ? color.lime : color.red)
        f_table_row(dashboard, 12, "Market Regime", marketRegime, btcTemperature <= 35 ? color.lime : btcTemperature <= 60 ? color.orange : color.red)
        f_table_row(dashboard, 13, "BTC Temperature", str.tostring(btcTemperature, "#.0") + "/100", btcTemperature <= 35 ? color.lime : btcTemperature <= 65 ? color.orange : color.red)
        f_divider(dashboard, 14)
        f_table_row(dashboard, 15, "Risk Mode", riskMode, f_risk_color(riskMode))
        f_table_row(dashboard, 16, "Model Confidence", str.tostring(modelConfidence, "#.0") + "%", f_score_color(modelConfidence))
        f_table_row(dashboard, 17, "Cycle Health", cycleHealthLabel + " " + str.tostring(cycleHealth, "#.0"), f_score_color(cycleHealth))
        f_table_row(dashboard, 18, "Model Status", modelStatus, f_model_color(modelStatus))
        f_divider(dashboard, 19)
        f_table_row(dashboard, 20, "h", str.tostring(h, "#.000"), color.white)
        f_table_row(dashboard, 21, "Cycle Phase", str.tostring(cyclePhase * 100.0, "#.0") + "%", color.white)
        if not compactMode
            f_table_row(dashboard, 22, "Rainbow Floor", str.tostring(rainbowFloor, "#"), color.white)
            f_table_row(dashboard, 23, "Wave Floor", str.tostring(waveFloor, "#"), color.white)
            f_table_row(dashboard, 24, "Floor Distance", str.tostring(rainbowFloorDistance, "#.0") + "%", rainbowFloorDistance <= 10 ? color.lime : rainbowFloorDistance <= 25 ? color.orange : color.red)
            f_divider(dashboard, 25)
            f_table_row(dashboard, 26, "Next Level", str.tostring(nextLevel, "#"), color.white)
            f_table_row(dashboard, 27, "Model Floor", str.tostring(modelFloor, "#"), color.lime)
            f_table_row(dashboard, 28, "Extreme Floor", str.tostring(extremeFloor, "#"), color.orange)
            f_divider(dashboard, 29)
            f_table_row(dashboard, 30, "Recovery Proj.", str.tostring(recoveryProjection, "#"), color.aqua)
            f_table_row(dashboard, 31, "Cycle Proj.", str.tostring(cycleProjection, "#"), color.orange)
            f_table_row(dashboard, 32, "Long Proj.", str.tostring(longProjection, "#"), color.red)
            f_table_row(dashboard, 33, "Data Source", "LIVE CHART DATA", color.lime)

// ============================================================================
// SINGLE LIVE LABEL
// ============================================================================
labelText = "BRC Live: " + str.tostring(brcScore, "#.0") + "\n" + cycleMode + "\nAcc: " + str.tostring(accumulationScore, "#.0") + "% / Dist: " + str.tostring(distributionScore, "#.0") + "%\nPhase: " + currentPhase + " " + str.tostring(phaseProgress, "#.0") + "%\nDays: " + str.tostring(math.ceil(remainingPhaseDays), "#") + "\nFloor: " + str.tostring(rainbowFloor, "#")
labelColor = distributionScore >= 70 ? color.red : accumulationScore >= 70 ? color.green : color.orange
var label currentLabel = na

if barstate.islast
    if showLabel
        if na(currentLabel)
            currentLabel := label.new(bar_index, close, labelText, style=label.style_label_left, color=labelColor, textcolor=color.white)
        else
            label.set_xy(currentLabel, bar_index, close)
            label.set_text(currentLabel, labelText)
            label.set_color(currentLabel, labelColor)
            label.set_textcolor(currentLabel, color.white)
    else if not na(currentLabel)
        label.delete(currentLabel)
        currentLabel := na

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(ta.crossover(accumulationScore, 70), "Accumulation crossed 70", "BRC accumulation score crossed above 70.")
alertcondition(ta.crossover(accumulationScore, 85), "Accumulation crossed 85", "BRC accumulation score crossed above 85.")
alertcondition(ta.crossover(distributionScore, 70), "Distribution crossed 70", "BRC distribution score crossed above 70.")
alertcondition(ta.crossover(distributionScore, 85), "Distribution crossed 85", "BRC distribution score crossed above 85.")
alertcondition(ta.crossunder(close, rainbowFloor), "Rainbow Floor Broken", "BTC closed below the live Rainbow Floor.")
alertcondition(ta.crossover(close, rainbowFloor), "Rainbow Floor Reclaimed", "BTC reclaimed the live Rainbow Floor.")
alertcondition(ta.crossunder(close, extremeFloor), "Extreme Floor Entered", "BTC entered the live extreme floor zone.")
alertcondition(ta.crossover(btcTemperature, 70), "BTC Temperature Above 70", "BRC BTC Temperature crossed above 70.")
alertcondition(cycleMode == "ACCUMULATION+" and cycleMode[1] != "ACCUMULATION+", "Cycle Mode Accumulation+", "BRC Cycle Mode changed to ACCUMULATION+.")
alertcondition(cycleMode == "DISTRIBUTE" and cycleMode[1] != "DISTRIBUTE", "Cycle Mode Distribute", "BRC Cycle Mode changed to DISTRIBUTE.")
alertcondition(modelStatus == "WARNING" and modelStatus[1] != "WARNING", "Model Warning", "BRC Model Status changed to WARNING.")
alertcondition(modelStatus == "BROKEN" and modelStatus[1] != "BROKEN", "Model Broken", "BRC Model Status changed to BROKEN.")
````
