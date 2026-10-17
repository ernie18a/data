# SBP SBP Trend Phase Navigator

- url: https://www.tradingview.com/script/oGUfhqN5-SBP-SBP-Trend-Phase-Navigator/
- type: indicator
- pine_id: PUB;cbce5b406db6495f8dae06a57a989e76
- version: 3.0

## Description

SBP Trend Phase Navigator

SBP Trend Phase Navigator is a rule-based technical analysis indicator designed to study directional trend phases and identify selected analytical setups when multiple chart conditions align.

Purpose and Component Integration

The indicator combines trend direction, adaptive smoothing, EMA alignment, ATR-normalized momentum, price structure, candle characteristics, optional relative volume, and volatility analysis.

These components are combined because they evaluate different aspects of price behaviour. Trend calculations provide directional context, momentum measures the strength of recent price movement relative to volatility, price structure evaluates movement beyond previous chart levels, and candle analysis examines the characteristics of the current bar.

The script processes these conditions within one rule-based framework rather than treating each component as an independent signal source.

Trend Analysis

The trend engine evaluates price in relation to a smoothed trend filter and measures the direction of the filter's slope.

A fast and slow EMA pair is used to assess directional alignment. The distance between these averages is normalized using Average True Range (ATR) and forms part of the trend-strength calculation.

A Hull-style adaptive average provides an additional directional reference. Its slope is evaluated together with the trend filter and EMA alignment when determining bullish or bearish trend conditions.

ATR-Normalized Momentum

Momentum is calculated from price change over a mode-dependent lookback period and divided by ATR.

This allows the script to evaluate recent directional price movement relative to the instrument's recent volatility rather than using absolute price movement alone.

Bullish and bearish momentum conditions are calculated separately.

Price Structure and Candle Analysis

The Price Structure Engine compares the current closing price with previous structure highs or lows over a selected lookback period.

The current setup candle is excluded from its own structure reference.

The Candle Quality Engine evaluates the candle body relative to the complete candle range and examines where the candle closes within that range. Bullish and bearish candle conditions are assessed separately.

Optional Relative Volume Analysis

The Relative Volume Filter compares current volume with its recent average where usable volume data is available.

This component is optional because volume characteristics can differ between symbols and markets.

When the volume filter is disabled, volume is excluded from both the score contribution and the available score denominator.

Volatility and Signal Distance

The volatility engine compares current ATR with its recent ATR average. The optional volatility filter can restrict setup markers when the ATR expansion ratio exceeds the selected maximum value.

The Maximum Signal Distance setting measures the distance between price and the Adaptive Average in ATR units. This condition can restrict primary setup markers when price is beyond the selected distance from the adaptive trend reference.

Normalized Quality Score

The indicator calculates separate bullish and bearish quality scores.

Trend strength and directional alignment form the core of the score. Momentum, candle characteristics, price structure, and relative volume contribute when their corresponding components are enabled.

The quality percentage is normalized according to the active scoring components. Disabling an optional component removes its contribution from the score calculation and the available score denominator.

The Aggressive, Balanced, and Conservative quality settings adjust the analytical thresholds used by the script. These settings control rule selectivity and do not represent an expected performance or success rate.

Trend Phase Lock

The Trend Phase Lock is used to control repeated same-direction setup markers.

Bullish and bearish trend conditions are counted over consecutive qualifying bars. A directional phase is established after the selected phase-confirmation requirement is met.

Temporary neutral or transition bars do not automatically reset the active phase.

After a primary BUY or SELL setup marker is generated, the active directional phase is marked as used. The primary setup engine does not generate another same-direction marker during that established phase.

A new primary setup becomes available after an opposite directional phase satisfies the script's phase-confirmation rules.

The Trend Phase Lock is a signal-frequency control mechanism. It does not predict future price direction.

Signal Frequency

The indicator provides Selective, Balanced, and Frequent signal-frequency settings.

Selective applies additional phase confirmation and higher quality requirements.

Balanced uses moderate phase and quality requirements.

Frequent uses less restrictive phase-confirmation and quality requirements.

These settings change the selectivity of the rule-based setup engine.

BUY and SELL Setup Labels

BUY and SELL labels identify bars where the enabled trend, momentum, structure, candle, volume, volatility, signal-distance, quality, and directional-phase conditions satisfy the selected settings.

The primary setup engine permits one setup marker per established directional phase.

When Signals On Bar Close is enabled, primary setup markers and related alert conditions are evaluated after the chart bar closes.

The labels represent rule-based analytical conditions generated by the script. They are not automated orders or guarantees of future price movement.

Early Transition Markers

Optional Early Transition Markers evaluate selected crossings of the trend filter together with trend slope, adaptive trend direction, EMA alignment, momentum direction, candle characteristics, volatility, and signal-distance conditions.

These markers are separate from the primary BUY and SELL setup engine. They do not reset the active phase or unlock another same-direction primary setup.

Early Transition Markers are disabled by default.

ATR Risk Guide and Dashboard

The optional ATR Risk Guide plots a volatility-based analytical reference around the Adaptive Average. It is a visual reference only and is not an automated order, strategy exit, or guaranteed stop level.

The optional dashboard displays the selected mode, signal-frequency setting, current trend state, active directional phase, phase-signal status, normalized quality score, market regime, and current setup state.

Modes and User Controls

The indicator provides SCALPING, INTRADAY, and SWING modes. These modes adjust the internal trend, adaptive-average, momentum, and price-structure lookback lengths.

Users can also control trend-strength, momentum, relative-volume, price-structure, candle-quality, and volatility filters through the indicator settings.

Important Information

SBP Trend Phase Navigator is an analytical and technical-analysis tool intended for educational and informational use.

The indicator evaluates chart data according to defined mathematical and rule-based conditions.

BUY and SELL labels identify analytical setups produced by the script's conditions. They do not constitute financial advice, automated trade execution, or guarantees of future market performance.

The script does not place or manage orders. Users are responsible for their own analysis, trading decisions, position sizing, and risk management.

Past performance does not guarantee future results.

## Source Code

````pine
// © SBP Trading Ecosystem
//@version=6
indicator("Trend Phase Navigator", shorttitle="Trend Phase Navigator", overlay=true)

groupSignal = "Signal Settings"

minimumSignalGap = input.int(3, "Minimum Signal Gap", minval=1, maxval=30, tooltip="Minimum bars required between alternating signals.", group=groupSignal)
swingStrength = input.int(3, "Swing Context Strength", minval=2, maxval=10, tooltip="Higher values focus on broader swing structures.", group=groupSignal)
minimumSwingQuality = input.float(64.0, "Minimum Swing Quality", minval=50.0, maxval=90.0, step=1.0, tooltip="Minimum score required for a qualified swing reversal.", group=groupSignal)
minimumContinuationQuality = input.float(58.0, "Minimum Continuation Quality", minval=45.0, maxval=85.0, step=1.0, tooltip="Minimum score required for a flag, accumulation, or distribution continuation signal.", group=groupSignal)
maxVolatilityRatio = input.float(2.10, "Maximum ATR Expansion Ratio", minval=1.00, maxval=5.00, step=0.05, tooltip="Blocks signals during unusually expanded volatility.", group=groupSignal)
showSignals = input.bool(true, "Show BUY / SELL", group=groupSignal)

clamp(float value, float lower, float upper) =>
    math.max(lower, math.min(value, upper))

int atrLength = 14
int equilibriumLength = 16
int efficiencyLength = 7
int compressionLength = 8
int pivotRightBars = 2
int stateLookback = 8

float atr = ta.atr(atrLength)
float safeATR = math.max(atr, syminfo.mintick)
float atrAverage = ta.sma(atr, 20)
float volatilityRatio = atrAverage > 0.0 ? atr / atrAverage : 1.0
bool volatilityPass = volatilityRatio <= maxVolatilityRatio

float oneBarTravel = math.abs(close - close[1])
float totalTravel = math.sum(oneBarTravel, efficiencyLength)
float netTravel = math.abs(close - nz(close[efficiencyLength], close))
float pathEfficiency = totalTravel > 0.0 ? clamp(netTravel / totalTravel, 0.0, 1.0) : 0.0

float fastConstant = 0.50
float slowConstant = 2.0 / (equilibriumLength + 1.0)
float adaptiveConstant = math.pow(pathEfficiency * (fastConstant - slowConstant) + slowConstant, 2)

var float phaseEquilibrium = na
phaseEquilibrium := na(phaseEquilibrium[1]) ? hlc3 : phaseEquilibrium[1] + adaptiveConstant * (hlc3 - phaseEquilibrium[1])

float equilibriumSlope = (phaseEquilibrium - phaseEquilibrium[1]) / safeATR
float slopeVelocity = equilibriumSlope - equilibriumSlope[1]
float displacement = (close - phaseEquilibrium) / safeATR

float barRange = math.max(high - low, syminfo.mintick)
float averageRange = ta.ema(barRange, compressionLength)
float rangeRatio = averageRange > 0.0 ? barRange / averageRange : 1.0
float previousRange = math.max(high[1] - low[1], syminfo.mintick)
float overlap = math.max(math.min(high, high[1]) - math.max(low, low[1]), 0.0)
float overlapRatio = clamp(overlap / math.max(barRange, previousRange), 0.0, 1.0)
float compressionState = clamp((1.10 - rangeRatio) / 0.70, 0.0, 1.0) * 0.50 + overlapRatio * 0.50
float recentCompression = ta.highest(compressionState, compressionLength)[1]
float releaseStrength = clamp((rangeRatio - 0.80) / 0.90, 0.0, 1.0)
float releaseFromCompression = clamp(recentCompression * releaseStrength, 0.0, 1.0)

float bodyPressure = (close - open) / barRange
float closeLocation = ((close - low) - (high - close)) / barRange
float directionalImpulse = bodyPressure * 0.45 + closeLocation * 0.30 + ((close - close[2]) / safeATR) * 0.25
float smoothedImpulse = ta.ema(directionalImpulse, 3)
float impulseVelocity = smoothedImpulse - smoothedImpulse[1]

float fastPhase = ta.ema(close, 8)
float slowPhase = ta.ema(close, 21)
float phaseSpread = (fastPhase - slowPhase) / safeATR
float phaseSpreadSlope = phaseSpread - phaseSpread[1]

float structureHigh = ta.highest(high, 5)[1]
float structureLow = ta.lowest(low, 5)[1]
bool bullStructureBreak = not na(structureHigh) and close > structureHigh
bool bearStructureBreak = not na(structureLow) and close < structureLow

float pivotLow = ta.pivotlow(low, swingStrength, pivotRightBars)
float pivotHigh = ta.pivothigh(high, swingStrength, pivotRightBars)
bool newPivotLow = not na(pivotLow)
bool newPivotHigh = not na(pivotHigh)

float pivotATR = math.max(nz(atr[pivotRightBars], safeATR), syminfo.mintick)
float priorOppositeHigh = ta.highest(high, swingStrength * 2 + pivotRightBars)[pivotRightBars + 1]
float priorOppositeLow = ta.lowest(low, swingStrength * 2 + pivotRightBars)[pivotRightBars + 1]

float bullPivotRecovery = newPivotLow ? (close - pivotLow) / pivotATR : 0.0
float bearPivotRecovery = newPivotHigh ? (pivotHigh - close) / pivotATR : 0.0
float bullSwingAmplitude = newPivotLow and not na(priorOppositeHigh) ? (priorOppositeHigh - pivotLow) / pivotATR : 0.0
float bearSwingAmplitude = newPivotHigh and not na(priorOppositeLow) ? (pivotHigh - priorOppositeLow) / pivotATR : 0.0

float bullSwingQuality =
     clamp(bullSwingAmplitude / 2.20, 0.0, 1.0) * 24.0 +
     clamp(bullPivotRecovery / 0.80, 0.0, 1.0) * 20.0 +
     clamp((smoothedImpulse + 0.20) / 0.80, 0.0, 1.0) * 16.0 +
     clamp((impulseVelocity + 0.10) / 0.35, 0.0, 1.0) * 12.0 +
     clamp(releaseFromCompression / 0.80, 0.0, 1.0) * 10.0 +
     (close > fastPhase ? 8.0 : 0.0) +
     (bullStructureBreak ? 10.0 : 0.0)

float bearSwingQuality =
     clamp(bearSwingAmplitude / 2.20, 0.0, 1.0) * 24.0 +
     clamp(bearPivotRecovery / 0.80, 0.0, 1.0) * 20.0 +
     clamp((-smoothedImpulse + 0.20) / 0.80, 0.0, 1.0) * 16.0 +
     clamp((-impulseVelocity + 0.10) / 0.35, 0.0, 1.0) * 12.0 +
     clamp(releaseFromCompression / 0.80, 0.0, 1.0) * 10.0 +
     (close < fastPhase ? 8.0 : 0.0) +
     (bearStructureBreak ? 10.0 : 0.0)

bool swingReversalBuy =
     barstate.isconfirmed and
     newPivotLow and
     bullSwingQuality >= minimumSwingQuality and
     volatilityPass

bool swingReversalSell =
     barstate.isconfirmed and
     newPivotHigh and
     bearSwingQuality >= minimumSwingQuality and
     volatilityPass

float rangeHigh = ta.highest(high, stateLookback)
float rangeLow = ta.lowest(low, stateLookback)
float rangeWidth = math.max(rangeHigh - rangeLow, syminfo.mintick)
float rangePosition = (close - rangeLow) / rangeWidth
float recentHighSlope = (ta.highest(high, 5) - ta.highest(high, 5)[3]) / safeATR
float recentLowSlope = (ta.lowest(low, 5) - ta.lowest(low, 5)[3]) / safeATR

bool bearishTrendState =
     fastPhase < slowPhase and
     phaseSpread < -0.08 and
     equilibriumSlope < 0.0

bool bullishTrendState =
     fastPhase > slowPhase and
     phaseSpread > 0.08 and
     equilibriumSlope > 0.0

bool distributionShelf =
     bearishTrendState and
     overlapRatio >= 0.35 and
     rangeRatio <= 1.28 and
     rangePosition <= 0.65 and
     recentHighSlope <= 0.02 and
     smoothedImpulse <= 0.10

bool accumulationShelf =
     bullishTrendState and
     overlapRatio >= 0.35 and
     rangeRatio <= 1.28 and
     rangePosition >= 0.35 and
     recentLowSlope >= -0.02 and
     smoothedImpulse >= -0.10

float pullbackHigh = ta.highest(high, 6)[1]
float pullbackLow = ta.lowest(low, 6)[1]
float bullImpulseLow = ta.lowest(low, 12)
float bearImpulseHigh = ta.highest(high, 12)
float bullImpulseRange = math.max(pullbackHigh - bullImpulseLow, syminfo.mintick)
float bearImpulseRange = math.max(bearImpulseHigh - pullbackLow, syminfo.mintick)

float bullPullbackDepth = (pullbackHigh - close) / bullImpulseRange
float bearPullbackDepth = (close - pullbackLow) / bearImpulseRange

bool bullFlagContext =
     bullishTrendState and
     bullPullbackDepth >= 0.10 and
     bullPullbackDepth <= 0.62 and
     overlapRatio >= 0.25 and
     rangeRatio <= 1.38

bool bearFlagContext =
     bearishTrendState and
     bearPullbackDepth >= 0.10 and
     bearPullbackDepth <= 0.62 and
     overlapRatio >= 0.25 and
     rangeRatio <= 1.38

float bullContinuationQuality =
     clamp(phaseSpread / 0.45, 0.0, 1.0) * 20.0 +
     clamp(equilibriumSlope / 0.08, 0.0, 1.0) * 15.0 +
     clamp(pathEfficiency / 0.55, 0.0, 1.0) * 15.0 +
     clamp(recentCompression / 0.80, 0.0, 1.0) * 15.0 +
     clamp(releaseFromCompression / 0.80, 0.0, 1.0) * 15.0 +
     clamp(smoothedImpulse / 0.60, 0.0, 1.0) * 10.0 +
     (bullStructureBreak ? 10.0 : 0.0)

float bearContinuationQuality =
     clamp(-phaseSpread / 0.45, 0.0, 1.0) * 20.0 +
     clamp(-equilibriumSlope / 0.08, 0.0, 1.0) * 15.0 +
     clamp(pathEfficiency / 0.55, 0.0, 1.0) * 15.0 +
     clamp(recentCompression / 0.80, 0.0, 1.0) * 15.0 +
     clamp(releaseFromCompression / 0.80, 0.0, 1.0) * 15.0 +
     clamp(-smoothedImpulse / 0.60, 0.0, 1.0) * 10.0 +
     (bearStructureBreak ? 10.0 : 0.0)

bool accumulationBreakout =
     barstate.isconfirmed and
     accumulationShelf and
     close > rangeHigh[1] and
     bullContinuationQuality >= minimumContinuationQuality and
     volatilityPass

bool distributionBreakdown =
     barstate.isconfirmed and
     distributionShelf and
     close < rangeLow[1] and
     bearContinuationQuality >= minimumContinuationQuality and
     volatilityPass

bool bullFlagBreakout =
     barstate.isconfirmed and
     bullFlagContext and
     close > pullbackHigh and
     bullContinuationQuality >= minimumContinuationQuality and
     volatilityPass

bool bearFlagBreakdown =
     barstate.isconfirmed and
     bearFlagContext and
     close < pullbackLow and
     bearContinuationQuality >= minimumContinuationQuality and
     volatilityPass

float bullPhaseScore =
     clamp(displacement / 1.25, 0.0, 1.0) * 25.0 +
     clamp(equilibriumSlope / 0.12, 0.0, 1.0) * 20.0 +
     clamp(smoothedImpulse / 0.95, 0.0, 1.0) * 25.0 +
     clamp(impulseVelocity / 0.32, 0.0, 1.0) * 10.0 +
     pathEfficiency * 10.0 +
     releaseFromCompression * 10.0

float bearPhaseScore =
     clamp(-displacement / 1.25, 0.0, 1.0) * 25.0 +
     clamp(-equilibriumSlope / 0.12, 0.0, 1.0) * 20.0 +
     clamp(-smoothedImpulse / 0.95, 0.0, 1.0) * 25.0 +
     clamp(-impulseVelocity / 0.32, 0.0, 1.0) * 10.0 +
     pathEfficiency * 10.0 +
     releaseFromCompression * 10.0

bool majorBullReversal =
     swingReversalBuy and
     bullPhaseScore >= 50.0 and
     close > fastPhase

bool majorBearReversal =
     swingReversalSell and
     bearPhaseScore >= 50.0 and
     close < fastPhase

int STATE_NEUTRAL = 0
int STATE_BULL_REVERSAL = 1
int STATE_BEAR_REVERSAL = -1
int STATE_BULL_CONTINUATION = 2
int STATE_BEAR_CONTINUATION = -2
int STATE_ACCUMULATION = 3
int STATE_DISTRIBUTION = -3

int marketState =
     majorBullReversal ? STATE_BULL_REVERSAL :
     majorBearReversal ? STATE_BEAR_REVERSAL :
     accumulationBreakout ? STATE_ACCUMULATION :
     distributionBreakdown ? STATE_DISTRIBUTION :
     bullFlagBreakout ? STATE_BULL_CONTINUATION :
     bearFlagBreakdown ? STATE_BEAR_CONTINUATION :
     STATE_NEUTRAL

bool rawBuy =
     marketState == STATE_BULL_REVERSAL or
     marketState == STATE_BULL_CONTINUATION or
     marketState == STATE_ACCUMULATION

bool rawSell =
     marketState == STATE_BEAR_REVERSAL or
     marketState == STATE_BEAR_CONTINUATION or
     marketState == STATE_DISTRIBUTION

var int lastDirection = 0
var int lastSignalBar = na

bool gapPass = na(lastSignalBar) or bar_index - lastSignalBar >= minimumSignalGap

bool buySignal =
     rawBuy and
     lastDirection != 1 and
     gapPass

bool sellSignal =
     rawSell and
     lastDirection != -1 and
     gapPass and
     not buySignal

if buySignal
    lastDirection := 1
    lastSignalBar := bar_index
else if sellSignal
    lastDirection := -1
    lastSignalBar := bar_index

plotshape(showSignals and buySignal, title="Bullish Trend Phase", location=location.belowbar, style=shape.labelup, text="BUY", color=color.lime, textcolor=color.black, size=size.small, editable=false)
plotshape(showSignals and sellSignal, title="Bearish Trend Phase", location=location.abovebar, style=shape.labeldown, text="SELL", color=color.red, textcolor=color.white, size=size.small, editable=false)

alertcondition(buySignal, title="Bullish Signal", message="Trend Phase Navigator | Bullish signal | {{ticker}} | {{interval}} | Close: {{close}}")
alertcondition(sellSignal, title="Bearish Signal", message="Trend Phase Navigator | Bearish signal | {{ticker}} | {{interval}} | Close: {{close}}")
alertcondition(buySignal or sellSignal, title="Any Signal", message="Trend Phase Navigator | New signal | {{ticker}} | {{interval}} | Close: {{close}}")
````
