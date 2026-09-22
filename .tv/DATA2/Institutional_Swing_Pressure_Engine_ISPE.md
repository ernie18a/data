<!-- tradingview-pine-id: PUB;380c7a62b2564f02b2fd13727a4413d5 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Institutional Swing Pressure Engine [ISPE]

Source: https://www.tradingview.com/script/L009YzuW-Institutional-Swing-Pressure-Engine-ISPE/

## Description

Description

Swing Pressure Engine [ISPE] is a multi-factor swing trading indicator designed to identify periods where directional pressure may be building before or during a larger price expansion.

Rather than relying on a single oscillator or breakout condition, ISPE evaluates several independent characteristics of market behavior and combines them into bullish and bearish pressure models.

The indicator analyzes five primary areas:

Compression — Measures whether volatility and price ranges are contracting relative to the instrument’s own historical behavior. It incorporates ATR, Bollinger Band width, realized volatility, rolling range contraction, candle-body compression, and Bollinger/Keltner squeeze conditions.

Flow — Estimates accumulation and distribution using price-and-volume proxies including closing location, relative volume, OBV behavior, directional volume, price response to volume, and absorption-style behavior. These calculations do not identify actual institutional orders; they infer buying and selling pressure from publicly available price and volume data.

Relative Strength — Measures the instrument against a broad-market benchmark and an optional sector benchmark. It evaluates relative performance, downside resilience, upside participation, and beta-adjusted relative behavior.

Structure — Evaluates the technical structure surrounding price, including proximity to support and resistance, moving-average alignment, higher-low/lower-high behavior, trend efficiency, and changes in rejection strength near important levels.

Multi-Timeframe Context — Uses higher-timeframe trend information to determine whether the current setup is aligned with the broader market structure.

These components are combined into separate Bull Pressure and Bear Pressure scores ranging from 0–100.

ISPE also calculates an Expansion score intended to represent the strength of conditions associated with a potential directional move. These values are composite heuristic scores and should not be interpreted as statistically calibrated probabilities.

Market States

The indicator classifies current conditions into states such as:

Dormant
Compressing
Accumulating
Distributing
Pressurized Bull
Pressurized Bear
Bull Pressure Divergence
Bear Pressure Divergence
Bull Expansion Imminent
Bear Expansion Imminent
Bull Expansion
Bear Expansion
Failed Breakout
Expansion Exhaustion

The purpose of these states is to make the underlying calculations easier to interpret at a glance.

Pressure Divergence

One of ISPE’s distinctive features is its Pressure Divergence model.

Pressure divergence occurs when price remains relatively compressed while the internal bullish or bearish pressure score changes significantly.

For example, price may remain nearly unchanged while accumulation, relative strength, structure, and compression increasingly favor the bullish side. ISPE can identify this as bullish pressure divergence before a traditional price breakout occurs.

The same logic is applied inversely to bearish setups.

How to Use

ISPE is primarily intended as a swing-trading research and confirmation tool.

A potentially favorable bullish setup may show:

Elevated compression
Strong accumulation
Strong relative strength
Favorable bullish structure
Positive higher-timeframe alignment
Bull pressure clearly exceeding bear pressure

A bearish setup uses the inverse conditions.

Higher pressure scores do not automatically represent trade signals. They are intended to identify environments that may deserve additional analysis.

The indicator also displays current structural support and resistance, along with potential entry, invalidation, and target reference levels when directional pressure becomes sufficiently elevated.

These levels are generated from current volatility and market structure and should be treated as analytical references rather than guaranteed entry or exit prices.

Adaptive Normalization

Many components of ISPE are normalized against the instrument’s own historical distribution using rolling percentile calculations.

This allows the indicator to adapt to securities with substantially different volatility characteristics.

For example, volatility that is unusually low for one stock may still be very high for another. ISPE therefore evaluates compression relative to the instrument itself rather than relying exclusively on fixed thresholds.

Relative Strength

By default, the indicator compares the current instrument with SPY and an optional sector ETF.

Users should change the sector benchmark where appropriate.

For example, a technology stock may reasonably be compared with XLK, while stocks from other industries should use a more appropriate sector benchmark.

Multi-Timeframe Data

ISPE incorporates higher-timeframe trend information into its pressure model.

Higher-timeframe calculations use confirmed historical higher-timeframe information to reduce repainting behavior from unfinished higher-timeframe bars.

Limitations

ISPE does not predict future prices and does not guarantee profitable trades.

The Bull Pressure, Bear Pressure, and Expansion readings are composite analytical scores rather than verified probabilities of future returns.

Accumulation and distribution calculations are based on price and volume proxies. The script cannot determine whether specific transactions originate from institutions, market makers, retail traders, or other market participants.

Support, resistance, entry, invalidation, and target levels change as market structure and volatility change.

Relative-strength calculations also depend on the selected benchmarks, so inappropriate benchmark selection can reduce their usefulness.

The indicator should therefore be used as one component of a broader trading process rather than as a standalone decision system.

Intended Use

ISPE was designed primarily for identifying and evaluating developing swing-trading environments where volatility compression, directional pressure, relative strength, and market structure begin aligning before or during price expansion.

Its primary purpose is not simply to identify completed breakouts, but to organize several underlying characteristics of a developing setup into a compact directional pressure model.

---

## Source Code

````pine
//@version=6
indicator("Institutional Swing Pressure Engine [ISPE]", shorttitle="ISPE", overlay=true, max_labels_count=100, max_lines_count=100)

//=============================================================================
// 01. INPUTS
//=============================================================================

string G1 = "01 — Core"
string G2 = "02 — Compression"
string G3 = "03 — Flow"
string G4 = "04 — Relative Strength"
string G5 = "05 — Structure"
string G6 = "06 — Multi-Timeframe"
string G7 = "07 — Signals"
string G8 = "08 — Visuals"

int adaptiveLookback = input.int(252, "Adaptive Lookback", minval=100, maxval=1000, group=G1)
int atrLength = input.int(14, "ATR Length", minval=5, maxval=100, group=G1)

int compressionLength = input.int(20, "Compression Length", minval=5, maxval=100, group=G2)
float bbMult = input.float(2.0, "Bollinger Multiplier", minval=0.5, maxval=4.0, step=0.1, group=G2)
float kcMult = input.float(1.5, "Keltner Multiplier", minval=0.5, maxval=4.0, step=0.1, group=G2)

int flowLength = input.int(20, "Flow Length", minval=5, maxval=100, group=G3)
int volumeLength = input.int(30, "Volume Baseline", minval=10, maxval=200, group=G3)

string benchmark = input.symbol("AMEX:SPY", "Primary Benchmark", group=G4)
bool useSector = input.bool(true, "Use Sector Benchmark", group=G4)
string sectorBenchmark = input.symbol("AMEX:XLK", "Sector Benchmark", group=G4)
int rsLength = input.int(60, "Relative Strength Length", minval=20, maxval=252, group=G4)

int resistanceLength = input.int(50, "Resistance / Support Lookback", minval=10, maxval=250, group=G5)
int structureLength = input.int(20, "Structure Length", minval=5, maxval=100, group=G5)
int swingLength = input.int(10, "Swing Invalidation Length", minval=3, maxval=50, group=G5)

string mtf1 = input.timeframe("D", "Primary Higher Timeframe", group=G6)
string mtf2 = input.timeframe("W", "Macro Higher Timeframe", group=G6)

float pressureThreshold = input.float(72.0, "Pressurized Threshold", minval=50, maxval=95, step=0.5, group=G7)
float extremeThreshold = input.float(82.0, "Extreme Pressure Threshold", minval=60, maxval=99, step=0.5, group=G7)
int failureWindow = input.int(4, "Breakout Failure Window", minval=1, maxval=10, group=G7)

bool showDashboard = input.bool(true, "Show Candle-Attached Dashboard", group=G8)
bool showLevels = input.bool(true, "Show Current Trade Levels", group=G8)
bool showSignals = input.bool(true, "Show Signals", group=G8)
bool showSupportResistance = input.bool(true, "Show Current Support / Resistance", group=G8)
bool showPressureBackground = input.bool(false, "Pressure Background", group=G8)
int lineBarsLeft = input.int(4, "Level Length Left", minval=1, maxval=20, group=G8)
int lineBarsRight = input.int(8, "Level Length Right", minval=1, maxval=50, group=G8)

//=============================================================================
// 02. FUNCTIONS
//=============================================================================

f_clamp(float x) => math.max(0.0, math.min(100.0, x))
f_safeDiv(float a, float b) => na(b) or b == 0.0 ? 0.0 : a / b
f_rank(float src, int len) => f_clamp(nz(ta.percentrank(src, len), 50.0))
f_fmt(float x) => na(x) ? "N/A" : str.tostring(x, "#.0")
f_price(float x) => na(x) ? "N/A" : str.tostring(x, format.mintick)

f_condAverage(float src, bool condition, int len) =>
    float numerator = ta.sma(condition ? nz(src) : 0.0, len)
    float denominator = ta.sma(condition ? 1.0 : 0.0, len)
    denominator > 0.0 ? numerator / denominator : 0.0

f_confirmedTrend() =>
    float e20 = ta.ema(close, 20)
    float e50 = ta.ema(close, 50)
    float e200 = ta.ema(close, 200)
    float bull = 0.0
    float bear = 0.0
    if close[1] > e20[1]
        bull += 0.25
    if e20[1] > e50[1]
        bull += 0.25
    if e50[1] > e200[1]
        bull += 0.25
    if close[1] > e200[1]
        bull += 0.25
    if close[1] < e20[1]
        bear += 0.25
    if e20[1] < e50[1]
        bear += 0.25
    if e50[1] < e200[1]
        bear += 0.25
    if close[1] < e200[1]
        bear += 0.25
    bull - bear

//=============================================================================
// 03. BASE DATA
//=============================================================================

float atr = ta.atr(atrLength)
float candleRange = math.max(high - low, syminfo.mintick)
float body = math.abs(close - open)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float upperWickPct = f_safeDiv(upperWick, candleRange)
float lowerWickPct = f_safeDiv(lowerWick, candleRange)
float closeLocation = f_safeDiv((close - low) - (high - close), candleRange)
float avgVolume = ta.sma(volume, volumeLength)
float relativeVolume = f_safeDiv(volume, avgVolume)
float atrMove = f_safeDiv(ta.change(close), atr)

//=============================================================================
// 04. COMPRESSION ENGINE
//=============================================================================

float atrPct = f_safeDiv(atr, close)
float atrCompression = 100.0 - f_rank(atrPct, adaptiveLookback)

float bbBasis = ta.sma(close, compressionLength)
float bbDev = ta.stdev(close, compressionLength) * bbMult
float bbUpper = bbBasis + bbDev
float bbLower = bbBasis - bbDev
float bbWidth = f_safeDiv(bbUpper - bbLower, bbBasis)
float bbCompression = 100.0 - f_rank(bbWidth, adaptiveLookback)

float rollingRange = ta.highest(high, compressionLength) - ta.lowest(low, compressionLength)
float rollingRangePct = f_safeDiv(rollingRange, close)
float rangeCompression = 100.0 - f_rank(rollingRangePct, adaptiveLookback)

float logReturn = close > 0 and close[1] > 0 ? math.log(close / close[1]) : 0.0
float realizedVol = ta.stdev(logReturn, compressionLength)
float realizedCompression = 100.0 - f_rank(realizedVol, adaptiveLookback)

float bodyPct = f_safeDiv(body, candleRange)
float bodyCompressionRaw = ta.ema(bodyPct, 5)
float bodyCompression = 100.0 - f_rank(bodyCompressionRaw, adaptiveLookback)

float kcBasis = ta.ema(close, compressionLength)
float kcUpper = kcBasis + atr * kcMult
float kcLower = kcBasis - atr * kcMult
bool squeezeActive = bbUpper < kcUpper and bbLower > kcLower
float squeezeScore = squeezeActive ? 100.0 : 0.0

float compressionScore = atrCompression * 0.24 + bbCompression * 0.24 + rangeCompression * 0.20 + realizedCompression * 0.18 + bodyCompression * 0.08 + squeezeScore * 0.06
compressionScore := f_clamp(compressionScore)

//=============================================================================
// 05. ACCUMULATION / DISTRIBUTION ENGINE
//=============================================================================

float volumeFlowRaw = ta.ema(closeLocation * relativeVolume, flowLength)
float volumeFlowBull = f_rank(volumeFlowRaw, adaptiveLookback)
float volumeFlowBear = 100.0 - volumeFlowBull

float signedVolume = math.sign(nz(ta.change(close))) * nz(volume)
float obv = ta.cum(signedVolume)
float obvNow = ta.linreg(obv, flowLength, 0)
float obvPrev = ta.linreg(obv, flowLength, 1)
float obvSlope = f_safeDiv(obvNow - obvPrev, avgVolume)
float obvBull = f_rank(obvSlope, adaptiveLookback)
float obvBear = 100.0 - obvBull

float initiativeBuyRaw = math.max(atrMove, 0.0) * relativeVolume
float initiativeSellRaw = math.max(-atrMove, 0.0) * relativeVolume
float initiativeBuy = f_rank(initiativeBuyRaw, adaptiveLookback)
float initiativeSell = f_rank(initiativeSellRaw, adaptiveLookback)

float downMoveATR = close < close[1] ? math.abs(atrMove) : 0.0
float upMoveATR = close > close[1] ? math.abs(atrMove) : 0.0

float bullAbsorptionRaw = close < close[1] ? relativeVolume * ((1.0 + closeLocation) / 2.0) / (downMoveATR + 0.25) : 0.0
float bearAbsorptionRaw = close > close[1] ? relativeVolume * ((1.0 - closeLocation) / 2.0) / (upMoveATR + 0.25) : 0.0

bullAbsorptionRaw := math.min(bullAbsorptionRaw, 5.0)
bearAbsorptionRaw := math.min(bearAbsorptionRaw, 5.0)

float bullAbsorption = f_rank(bullAbsorptionRaw, adaptiveLookback)
float bearAbsorption = f_rank(bearAbsorptionRaw, adaptiveLookback)

float upVolume = f_condAverage(volume, close > close[1], volumeLength)
float downVolume = f_condAverage(volume, close < close[1], volumeLength)
float totalDirectionalVolume = upVolume + downVolume
float upVolumeShare = totalDirectionalVolume > 0 ? 100.0 * upVolume / totalDirectionalVolume : 50.0
float downVolumeShare = 100.0 - upVolumeShare
float upVolumeScore = f_rank(upVolumeShare, adaptiveLookback)
float downVolumeScore = f_rank(downVolumeShare, adaptiveLookback)

float accumulationScore = volumeFlowBull * 0.24 + obvBull * 0.20 + initiativeBuy * 0.20 + bullAbsorption * 0.20 + upVolumeScore * 0.16
float distributionScore = volumeFlowBear * 0.24 + obvBear * 0.20 + initiativeSell * 0.20 + bearAbsorption * 0.20 + downVolumeScore * 0.16

accumulationScore := f_clamp(accumulationScore)
distributionScore := f_clamp(distributionScore)

//=============================================================================
// 06. RELATIVE STRENGTH ENGINE
//=============================================================================

float benchmarkClose = request.security(benchmark, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float sectorClose = request.security(sectorBenchmark, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

int rsFastLength = math.max(5, int(math.round(rsLength * 0.5)))

float rsBenchmark = f_safeDiv(close, benchmarkClose)
float rsSector = f_safeDiv(close, sectorClose)
float rsBenchmarkSlope = ta.roc(rsBenchmark, rsFastLength)
float rsSectorSlope = ta.roc(rsSector, rsFastLength)
float rsBenchmarkScore = f_rank(rsBenchmarkSlope, adaptiveLookback)
float rsSectorScore = useSector ? f_rank(rsSectorSlope, adaptiveLookback) : 50.0

float assetReturn = f_safeDiv(close - close[1], close[1])
float benchmarkReturn = f_safeDiv(benchmarkClose - benchmarkClose[1], benchmarkClose[1])

float downsideAlpha = f_condAverage(assetReturn - benchmarkReturn, benchmarkReturn < 0, rsLength)
float upsideAlpha = f_condAverage(assetReturn - benchmarkReturn, benchmarkReturn > 0, rsLength)
float downsideResilience = f_rank(downsideAlpha, adaptiveLookback)
float upsideParticipation = f_rank(upsideAlpha, adaptiveLookback)

float assetVol = ta.stdev(assetReturn, rsLength)
float benchmarkVol = ta.stdev(benchmarkReturn, rsLength)
float correlation = ta.correlation(assetReturn, benchmarkReturn, rsLength)
float beta = benchmarkVol > 0 ? correlation * assetVol / benchmarkVol : 1.0
float betaAdjustedReturn = assetReturn - beta * benchmarkReturn
float smoothedBetaAlpha = ta.ema(betaAdjustedReturn, 10)
float betaAlphaScore = f_rank(smoothedBetaAlpha, adaptiveLookback)

float relativeStrengthScore = rsBenchmarkScore * 0.30 + rsSectorScore * 0.20 + downsideResilience * 0.20 + upsideParticipation * 0.15 + betaAlphaScore * 0.15
relativeStrengthScore := f_clamp(relativeStrengthScore)

float relativeWeaknessScore = 100.0 - relativeStrengthScore

//=============================================================================
// 07. STRUCTURE ENGINE
//=============================================================================

float ema20 = ta.ema(close, 20)
float ema50 = ta.ema(close, 50)
float ema200 = ta.ema(close, 200)

float resistance = ta.highest(high[1], resistanceLength)
float support = ta.lowest(low[1], resistanceLength)

float distanceToResistanceATR = f_safeDiv(resistance - close, atr)
float distanceToSupportATR = f_safeDiv(close - support, atr)

float resistancePressure = f_clamp(100.0 - distanceToResistanceATR * 20.0)
float supportPressure = f_clamp(100.0 - distanceToSupportATR * 20.0)

float bullishAlignment = (close > ema20 ? 20.0 : 0.0) + (ema20 > ema50 ? 30.0 : 0.0) + (ema50 > ema200 ? 30.0 : 0.0) + (close > ema200 ? 20.0 : 0.0)
float bearishAlignment = (close < ema20 ? 20.0 : 0.0) + (ema20 < ema50 ? 30.0 : 0.0) + (ema50 < ema200 ? 30.0 : 0.0) + (close < ema200 ? 20.0 : 0.0)

float lowRegressionNow = ta.linreg(low, structureLength, 0)
float lowRegressionPrev = ta.linreg(low, structureLength, 1)
float highRegressionNow = ta.linreg(high, structureLength, 0)
float highRegressionPrev = ta.linreg(high, structureLength, 1)

float lowSlopeATR = f_safeDiv(lowRegressionNow - lowRegressionPrev, atr)
float highSlopeATR = f_safeDiv(highRegressionNow - highRegressionPrev, atr)

float higherLowScore = f_rank(lowSlopeATR, adaptiveLookback)
float lowerHighScore = f_rank(-highSlopeATR, adaptiveLookback)

float pathAverage = ta.sma(math.abs(ta.change(close)), structureLength)
float totalPath = nz(pathAverage) * structureLength
float netMovement = math.abs(close - close[structureLength])
float trendEfficiency = totalPath > 0 ? netMovement / totalPath : 0.0
float bullishEfficiency = close > close[structureLength] ? f_clamp(trendEfficiency * 100.0) : 0.0
float bearishEfficiency = close < close[structureLength] ? f_clamp(trendEfficiency * 100.0) : 0.0

//=============================================================================
// 08. REJECTION DECAY / EXHAUSTION
//=============================================================================

bool nearResistance = not na(resistance) and high >= resistance - atr * 0.35
bool nearSupport = not na(support) and low <= support + atr * 0.35

float recentSellerRejection = f_condAverage(upperWickPct, nearResistance, 10)
float baselineSellerRejection = f_condAverage(upperWickPct, nearResistance, 40)
float sellerExhaustion = baselineSellerRejection > 0 ? f_clamp(50.0 + (baselineSellerRejection - recentSellerRejection) * 200.0) : 50.0

float recentBuyerRejection = f_condAverage(lowerWickPct, nearSupport, 10)
float baselineBuyerRejection = f_condAverage(lowerWickPct, nearSupport, 40)
float buyerExhaustion = baselineBuyerRejection > 0 ? f_clamp(50.0 + (baselineBuyerRejection - recentBuyerRejection) * 200.0) : 50.0

float bullishStructure = resistancePressure * 0.25 + bullishAlignment * 0.25 + higherLowScore * 0.20 + bullishEfficiency * 0.15 + sellerExhaustion * 0.15
float bearishStructure = supportPressure * 0.25 + bearishAlignment * 0.25 + lowerHighScore * 0.20 + bearishEfficiency * 0.15 + buyerExhaustion * 0.15

bullishStructure := f_clamp(bullishStructure)
bearishStructure := f_clamp(bearishStructure)

//=============================================================================
// 09. MULTI-TIMEFRAME ENGINE
//=============================================================================

float primaryTrend = request.security(syminfo.tickerid, mtf1, f_confirmedTrend(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float macroTrend = request.security(syminfo.tickerid, mtf2, f_confirmedTrend(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

float combinedMTF = nz(primaryTrend) * 0.40 + nz(macroTrend) * 0.60
float bullishMTF = f_clamp((combinedMTF + 1.0) * 50.0)
float bearishMTF = 100.0 - bullishMTF

//=============================================================================
// 10. MASTER PRESSURE ENGINE
//=============================================================================

float bullishPressure = compressionScore * 0.18 + accumulationScore * 0.24 + relativeStrengthScore * 0.22 + bullishStructure * 0.28 + bullishMTF * 0.08
float bearishPressure = compressionScore * 0.18 + distributionScore * 0.24 + relativeWeaknessScore * 0.22 + bearishStructure * 0.28 + bearishMTF * 0.08

bullishPressure := f_clamp(bullishPressure)
bearishPressure := f_clamp(bearishPressure)

bool bullishDominant = bullishPressure > bearishPressure
float dominantPressure = math.max(bullishPressure, bearishPressure)
float pressureEdge = bullishPressure - bearishPressure

//=============================================================================
// 11. EXPANSION ENGINE
//=============================================================================

float bullishImpulseRaw = math.max(atrMove, 0.0) * relativeVolume * math.max(closeLocation, 0.0)
float bearishImpulseRaw = math.max(-atrMove, 0.0) * relativeVolume * math.max(-closeLocation, 0.0)

float bullishImpulse = f_rank(bullishImpulseRaw, adaptiveLookback)
float bearishImpulse = f_rank(bearishImpulseRaw, adaptiveLookback)

float bullishExpansion = bullishPressure * 0.75 + bullishImpulse * 0.15 + resistancePressure * 0.10
float bearishExpansion = bearishPressure * 0.75 + bearishImpulse * 0.15 + supportPressure * 0.10

bullishExpansion := f_clamp(bullishExpansion)
bearishExpansion := f_clamp(bearishExpansion)

//=============================================================================
// 12. BREAKOUT ENGINE
//=============================================================================

bool bullBreakout = barstate.isconfirmed and not na(resistance) and close > resistance and close[1] <= resistance[1] and bullishPressure > bearishPressure
bool bearBreakout = barstate.isconfirmed and not na(support) and close < support and close[1] >= support[1] and bearishPressure > bullishPressure

var float lastBullBreakLevel = na
var float lastBearBreakLevel = na
var int lastBullBreakBar = na
var int lastBearBreakBar = na

if bullBreakout
    lastBullBreakLevel := resistance
    lastBullBreakBar := bar_index

if bearBreakout
    lastBearBreakLevel := support
    lastBearBreakBar := bar_index

bool bullFailure = not na(lastBullBreakBar) and bar_index - lastBullBreakBar <= failureWindow and close < lastBullBreakLevel
bool bearFailure = not na(lastBearBreakBar) and bar_index - lastBearBreakBar <= failureWindow and close > lastBearBreakLevel

bool bullFailureNow = bullFailure and not bullFailure[1]
bool bearFailureNow = bearFailure and not bearFailure[1]

//=============================================================================
// 13. PRESSURE DIVERGENCE
//=============================================================================

int divergenceLength = 10

float normalizedPriceMovement = f_safeDiv(math.abs(close - close[divergenceLength]), atr)
float bullPressureChange = bullishPressure - bullishPressure[divergenceLength]
float bearPressureChange = bearishPressure - bearishPressure[divergenceLength]

bool bullishPressureDivergence = barstate.isconfirmed and normalizedPriceMovement < 1.25 and bullPressureChange > 8.0 and accumulationScore > 60 and bullishPressure > bearishPressure
bool bearishPressureDivergence = barstate.isconfirmed and normalizedPriceMovement < 1.25 and bearPressureChange > 8.0 and distributionScore > 60 and bearishPressure > bullishPressure

bool bullPDNow = bullishPressureDivergence and not bullishPressureDivergence[1]
bool bearPDNow = bearishPressureDivergence and not bearishPressureDivergence[1]

//=============================================================================
// 14. EXPANSION EXHAUSTION
//=============================================================================

float rsi = ta.rsi(close, 14)

bool recentBullBreakout = not na(lastBullBreakBar) and bar_index - lastBullBreakBar <= 12
bool recentBearBreakout = not na(lastBearBreakBar) and bar_index - lastBearBreakBar <= 12

bool bullExhaustion = recentBullBreakout and rsi > 70 and ta.falling(bullishPressure, 3)
bool bearExhaustion = recentBearBreakout and rsi < 30 and ta.falling(bearishPressure, 3)

//=============================================================================
// 15. STATE MACHINE
//=============================================================================

string marketState = "DORMANT"

if bullFailure
    marketState := "FAILED BULL"
else if bearFailure
    marketState := "FAILED BEAR"
else if bullExhaustion
    marketState := "BULL EXHAUSTING"
else if bearExhaustion
    marketState := "BEAR EXHAUSTING"
else if bullBreakout
    marketState := "BULL EXPANSION"
else if bearBreakout
    marketState := "BEAR EXPANSION"
else if bullishExpansion >= extremeThreshold and bullishDominant
    marketState := "BULL IMMINENT"
else if bearishExpansion >= extremeThreshold and not bullishDominant
    marketState := "BEAR IMMINENT"
else if compressionScore >= 70 and dominantPressure >= pressureThreshold
    marketState := bullishDominant ? "PRESSURIZED BULL" : "PRESSURIZED BEAR"
else if bullishPressureDivergence
    marketState := "BULL PRESSURE DIV"
else if bearishPressureDivergence
    marketState := "BEAR PRESSURE DIV"
else if accumulationScore >= 65 and bullishDominant
    marketState := "ACCUMULATING"
else if distributionScore >= 65 and not bullishDominant
    marketState := "DISTRIBUTING"
else if compressionScore >= 65
    marketState := "COMPRESSING"

//=============================================================================
// 16. SWING TRADE MAP
//=============================================================================

float bullEntry = resistance
float bullEntryLow = resistance - atr * 0.25
float bullEntryHigh = resistance + atr * 0.10
float bullStop = ta.lowest(low, swingLength) - atr * 0.25
float bullRisk = math.max(bullEntry - bullStop, atr * 0.50)
float bullTarget1 = bullEntry + bullRisk * 2.0
float bullTarget2 = bullEntry + bullRisk * 3.5

float bearEntry = support
float bearEntryLow = support - atr * 0.10
float bearEntryHigh = support + atr * 0.25
float bearStop = ta.highest(high, swingLength) + atr * 0.25
float bearRisk = math.max(bearStop - bearEntry, atr * 0.50)
float bearTarget1 = bearEntry - bearRisk * 2.0
float bearTarget2 = bearEntry - bearRisk * 3.5

bool activeBullMap = bullishDominant and bullishPressure >= pressureThreshold
bool activeBearMap = not bullishDominant and bearishPressure >= pressureThreshold

float activeEntryLow = activeBullMap ? bullEntryLow : activeBearMap ? bearEntryLow : na
float activeEntryHigh = activeBullMap ? bullEntryHigh : activeBearMap ? bearEntryHigh : na
float activeStop = activeBullMap ? bullStop : activeBearMap ? bearStop : na
float activeTarget1 = activeBullMap ? bullTarget1 : activeBearMap ? bearTarget1 : na
float activeTarget2 = activeBullMap ? bullTarget2 : activeBearMap ? bearTarget2 : na

//=============================================================================
// 17. CURRENT CHART-ATTACHED LEVELS
//=============================================================================

var line resistanceLine = na
var line supportLine = na
var line entryLowLine = na
var line entryHighLine = na
var line stopLine = na
var line target1Line = na
var line target2Line = na

if barstate.islast
    if showSupportResistance and not na(resistance)
        if na(resistanceLine)
            resistanceLine := line.new(bar_index - lineBarsLeft, resistance, bar_index + lineBarsRight, resistance, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 45), style=line.style_dashed, width=1)
        else
            line.set_xy1(resistanceLine, bar_index - lineBarsLeft, resistance)
            line.set_xy2(resistanceLine, bar_index + lineBarsRight, resistance)
    else
        if not na(resistanceLine)
            line.delete(resistanceLine)
            resistanceLine := na

    if showSupportResistance and not na(support)
        if na(supportLine)
            supportLine := line.new(bar_index - lineBarsLeft, support, bar_index + lineBarsRight, support, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.green, 45), style=line.style_dashed, width=1)
        else
            line.set_xy1(supportLine, bar_index - lineBarsLeft, support)
            line.set_xy2(supportLine, bar_index + lineBarsRight, support)
    else
        if not na(supportLine)
            line.delete(supportLine)
            supportLine := na

    if showLevels and not na(activeEntryLow)
        if na(entryLowLine)
            entryLowLine := line.new(bar_index - 1, activeEntryLow, bar_index + lineBarsRight, activeEntryLow, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.aqua, 30), width=1)
        else
            line.set_xy1(entryLowLine, bar_index - 1, activeEntryLow)
            line.set_xy2(entryLowLine, bar_index + lineBarsRight, activeEntryLow)
    else
        if not na(entryLowLine)
            line.delete(entryLowLine)
            entryLowLine := na

    if showLevels and not na(activeEntryHigh)
        if na(entryHighLine)
            entryHighLine := line.new(bar_index - 1, activeEntryHigh, bar_index + lineBarsRight, activeEntryHigh, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.aqua, 30), width=1)
        else
            line.set_xy1(entryHighLine, bar_index - 1, activeEntryHigh)
            line.set_xy2(entryHighLine, bar_index + lineBarsRight, activeEntryHigh)
    else
        if not na(entryHighLine)
            line.delete(entryHighLine)
            entryHighLine := na

    if showLevels and not na(activeStop)
        if na(stopLine)
            stopLine := line.new(bar_index - 1, activeStop, bar_index + lineBarsRight, activeStop, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 15), width=1)
        else
            line.set_xy1(stopLine, bar_index - 1, activeStop)
            line.set_xy2(stopLine, bar_index + lineBarsRight, activeStop)
    else
        if not na(stopLine)
            line.delete(stopLine)
            stopLine := na

    if showLevels and not na(activeTarget1)
        if na(target1Line)
            target1Line := line.new(bar_index - 1, activeTarget1, bar_index + lineBarsRight, activeTarget1, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.green, 25), width=1)
        else
            line.set_xy1(target1Line, bar_index - 1, activeTarget1)
            line.set_xy2(target1Line, bar_index + lineBarsRight, activeTarget1)
    else
        if not na(target1Line)
            line.delete(target1Line)
            target1Line := na

    if showLevels and not na(activeTarget2)
        if na(target2Line)
            target2Line := line.new(bar_index - 1, activeTarget2, bar_index + lineBarsRight, activeTarget2, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.green, 5), width=1)
        else
            line.set_xy1(target2Line, bar_index - 1, activeTarget2)
            line.set_xy2(target2Line, bar_index + lineBarsRight, activeTarget2)
    else
        if not na(target2Line)
            line.delete(target2Line)
            target2Line := na

//=============================================================================
// 18. SMALL SIGNAL MARKERS
//=============================================================================

plotshape(showSignals and bullBreakout, title="Bull Expansion", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(showSignals and bearBreakout, title="Bear Expansion", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)

plotshape(showSignals and bullPDNow, title="Bull Pressure Divergence", style=shape.diamond, location=location.belowbar, color=color.aqua, size=size.tiny)
plotshape(showSignals and bearPDNow, title="Bear Pressure Divergence", style=shape.diamond, location=location.abovebar, color=color.orange, size=size.tiny)

plotshape(showSignals and bullFailureNow, title="Failed Bull Breakout", style=shape.xcross, location=location.abovebar, color=color.red, size=size.tiny)
plotshape(showSignals and bearFailureNow, title="Failed Bear Breakout", style=shape.xcross, location=location.belowbar, color=color.lime, size=size.tiny)

//=============================================================================
// 19. BACKGROUND
//=============================================================================

color pressureBackground = na

if dominantPressure >= extremeThreshold
    pressureBackground := bullishDominant ? color.new(color.lime, 93) : color.new(color.red, 93)
else if dominantPressure >= pressureThreshold
    pressureBackground := bullishDominant ? color.new(color.green, 96) : color.new(color.orange, 96)

bgcolor(showPressureBackground ? pressureBackground : na)

//=============================================================================
// 20. CANDLE-ATTACHED COMPACT DASHBOARD
//=============================================================================

string dashText = "ISPE • " + marketState + "\nB " + f_fmt(bullishPressure) + "  R " + f_fmt(bearishPressure) + "  Δ " + f_fmt(pressureEdge) + "\nCmp " + f_fmt(compressionScore) + "  Flow " + f_fmt(bullishDominant ? accumulationScore : distributionScore) + "  Rel " + f_fmt(bullishDominant ? relativeStrengthScore : relativeWeaknessScore) + "\nStr " + f_fmt(bullishDominant ? bullishStructure : bearishStructure) + "  Exp " + f_fmt(bullishDominant ? bullishExpansion : bearishExpansion)

color dashColor = bullishDominant ? color.new(color.green, 72) : color.new(color.red, 72)

var label dashboard = na

if barstate.islast
    if showDashboard
        if na(dashboard)
            dashboard := label.new(bar_index + 2, high, dashText, xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_left, color=dashColor, textcolor=color.white, size=size.tiny, textalign=text.align_left)
        else
            label.set_xy(dashboard, bar_index + 2, high)
            label.set_text(dashboard, dashText)
            label.set_color(dashboard, dashColor)
            label.set_textcolor(dashboard, color.white)
            label.set_size(dashboard, size.tiny)
    else
        if not na(dashboard)
            label.delete(dashboard)
            dashboard := na

//=============================================================================
// 21. ALERTS
//=============================================================================

bool bullPressurized = barstate.isconfirmed and bullishPressure >= pressureThreshold and bullishPressure > bearishPressure and compressionScore >= 65
bool bearPressurized = barstate.isconfirmed and bearishPressure >= pressureThreshold and bearishPressure > bullishPressure and compressionScore >= 65

alertcondition(bullPressurized, "ISPE Bull Pressurized", "ISPE: Bullish swing pressure is elevated.")
alertcondition(bearPressurized, "ISPE Bear Pressurized", "ISPE: Bearish swing pressure is elevated.")
alertcondition(bullBreakout, "ISPE Bull Expansion", "ISPE: Bullish expansion breakout confirmed.")
alertcondition(bearBreakout, "ISPE Bear Expansion", "ISPE: Bearish expansion breakout confirmed.")
alertcondition(bullPDNow, "ISPE Bull Pressure Divergence", "ISPE: Bullish pressure is rising while price remains compressed.")
alertcondition(bearPDNow, "ISPE Bear Pressure Divergence", "ISPE: Bearish pressure is rising while price remains compressed.")
alertcondition(bullFailureNow, "ISPE Failed Bull Breakout", "ISPE: Recent bullish breakout has failed.")
alertcondition(bearFailureNow, "ISPE Failed Bear Breakout", "ISPE: Recent bearish breakout has failed.")
````
