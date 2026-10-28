# Imperium Flow

- url: https://www.tradingview.com/script/8MUcJO3b-Imperium-Flow/
- type: indicator
- pine_id: PUB;de127508249d4a34a7eab0c05fb8e472
- version: 1.0

## Description

Imperium Flow is a market flow indicator designed to evaluate the quality behind price movement. It analyzes pressure, volume participation, candle behavior, wick rejection, Money Flow, and effort versus result to help traders understand whether a move is supported, stretched, weakening, or starting to rotate.

The indicator is built for confirmation and market context. It does not predict price. Its purpose is to help identify when buyers or sellers have stronger control, when continuation remains healthy, and when market conditions are becoming less efficient.

[b]Main Features[/b]
[list]
[*]Exhaustion Zones;
[*]Money Flow;
[*]Price Pressure;
[*]Price Effort;
[*]Exhaustion Warnings;
[*]Reversal Warnings;
[*]Divergence.
[/list]
[i]Each section is designed to give a different view of market quality, from participation and pressure to exhaustion, consolidation, and possible rotation.[/i]

[b]Exhaustion Zones[/b]
https://www.tradingview.com/x/t5thq80C/
Exhaustion Zones highlight areas where directional pressure has become stretched.

Reaching these zones does not mean price must reverse. Strong trends can continue through them. The zones simply warn that late entries may carry more risk because continuation can become less efficient.

They are most useful when combined with pressure shifts, candle rejection, absorption, fading Money Flow, or nearby market structure.

[b]Money Flow[/b]
https://www.tradingview.com/x/4pNt1tF9/
Money Flow shows whether buying or selling participation is stronger.

When Money Flow is above zero, buyer participation is stronger. When it is below zero, seller participation is stronger.

Rising or stable Money Flow can support bullish continuation. Falling or weak Money Flow can support bearish continuation. When price keeps moving in one direction while Money Flow starts fading or improving against it, the move may be losing quality.

High positive or deep negative readings can also show stretched market conditions.

[b]Price Pressure[/b]
https://www.tradingview.com/x/7gl9nIfM/
Price Pressure shows the active balance between bullish and bearish pressure.

Positive pressure suggests stronger buyer control. Negative pressure suggests stronger seller control.

Pressure is most useful when compared with price movement. When pressure supports the direction of price, the move has better confirmation. When pressure starts moving against price, continuation may be losing quality.

The pressure momentum columns help show acceleration, fading pressure, absorption, rejection, or early rotation near key market areas.

[b]Price Effort[/b]
https://www.tradingview.com/x/3zyjNSTn/
Price Effort is the main directional read of Imperium Flow.

It shows whether price movement is supported by strong effort and meaningful follow-through, or whether the move is becoming weak, inefficient, or exhausted.

When Price Effort is above zero and in a bullish state, buyers have stronger control. When it is below zero and in a bearish state, sellers have stronger control. When it turns neutral, the market may be losing direction or entering consolidation.

The strongest continuation conditions usually appear when Price Effort, Price Pressure, and Money Flow support the same direction. When these readings begin to separate, the move should be treated with more caution.

[b]Exhaustion Warnings[/b]
https://www.tradingview.com/x/eQkxPoHf/
Exhaustion warnings are shown with ✦ symbols.

They appear when a strong move may be starting to lose quality. These warnings are not designed to mark the exact top or bottom. They are caution markers showing that the current direction may be becoming more vulnerable.

An exhaustion warning can appear when pressure fades, Money Flow becomes stretched, candles show rejection, volume produces weaker follow-through, or absorption forms against the active move.

The warning is more useful after an extended move or near important market structure, liquidity areas, previous highs or lows, support, or resistance. If price continues with strong pressure after the warning, the trend may remain valid. If it is followed by weak continuation, rejection, or a shift in Price Effort, the market may be preparing for a pullback or rotation.

[b]Reversal Warnings[/b]
https://www.tradingview.com/x/euSLX3ao/
Reversal warnings are shown with ▼ and ▲ symbols.

They appear when an extended move begins to show stronger rotation evidence. These are not automatic buy or sell signals. They highlight moments where the active side may be losing control and the opposite side is starting to react.

A reversal warning can form after rejection from an extreme area, a pressure shift against the active move, fading Money Flow, or a turn in Price Effort from stretched conditions.

The signal is strongest when it appears after exhaustion, near important market structure, or after a failed continuation attempt. If price ignores the warning and continues with strong pressure, the trend may still remain active.

[b]Divergence[/b]
https://www.tradingview.com/x/TSp1aXv0/
Divergence highlights when price continues to extend, but Imperium Flow no longer confirms the move with the same strength.

This can help traders spot moments where momentum, pressure, or participation may be weakening behind the current price movement.

Divergence does not mean price must reverse immediately. It should be checked together with market structure, support, resistance, liquidity areas, rejection, exhaustion, and Price Effort behavior.

Divergence signals are confirmed after the swing confirmation period, so they can appear a few candles after the actual high or low. They are best used as context, not as standalone entry signals.

[b]Practical Use[/b]

Imperium Flow is best used to evaluate whether the current move has strong confirmation or is starting to lose quality.

The main read is Price Effort. Price Pressure and Money Flow should be used as supporting confirmation.

When all three support the same direction, continuation conditions are usually stronger. When they separate, fade, or conflict, traders may choose to become more selective with entries, exits, and trade management.

[b]Mixed or unstable readings usually mean the market does not have clear directional control.[/b]

[b]Important Notes[/b]
[list]
[*]Exhaustion is a caution signal, not a guaranteed reversal;
[*]Reversal warnings are for context and should not be treated as automatic buy or sell signals;
[*]Divergence can appear before price reacts, especially during strong trends;
[*]Money Flow, Price Pressure, and Price Effort should be read together;
[*]Mixed readings usually mean the move lacks clear confirmation;
[*]Readings may be less reliable on symbols with missing, unreliable, or illiquid volume;
[*]Non-standard chart types may produce different readings because candle structure and volume behavior can be altered;
[*]The indicator analyzes current and recent market behavior. It does not predict future price movement.
[/list]
[i]Imperium Flow is intended for structured market analysis and confirmation. It should be used as part of a broader trading process that includes market structure, execution rules, invalidation, and risk management.[/i]

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6

indicator("Imperium Flow", overlay=false, max_labels_count=100, max_bars_back=500, precision=2)

// Inputs
groupVisuals = "Main Settings"
showZones = input.bool(true, "Show Exhaustion Zones", group=groupVisuals)
showMoneyWave = input.bool(true, "Show Money Flow", group=groupVisuals)
showPressureBars = input.bool(true, "Show Price Pressure", group=groupVisuals)
showPriceEffort = input.bool(true, "Show Price Effort", group=groupVisuals)

groupSignals = "Signals Menu"
showDivergences = input.bool(false, "Show Divergence", group=groupSignals)
showExhaustion = input.bool(true, "Show Exhaustion Warnings", group=groupSignals)
showReversals = input.bool(true, "Show Reversal Warnings", group=groupSignals)

groupColors = "Colors Menu"
bullColorInput = input.color(color.rgb(255, 255, 255), "Bull", group=groupColors)
bearColorInput = input.color(color.rgb(0, 115, 255), "Bear", group=groupColors)
neutralColorInput = input.color(color.rgb(125, 130, 145), "Consolidation", group=groupColors)

// Settings
const float PRIME_ZONE = 55.0
const float EXTREME_ZONE = 80.0

const int SMOOTH_LEN = 8
const int SIGNAL_LEN = 5
const int VOL_LEN = 34
const int MFI_LEN = 21
const int ATR_LEN = 21
const int TREND_FAST = 21
const int TREND_SLOW = 55

const int FLOW_LEAD_LEN = 5
const int FLOW_MEMORY_LEN = 13
const int FLOW_CONFIRM_LEN = 8

const int PRESSURE_FAST_LEN = 5
const int PRESSURE_SLOW_LEN = 13

const int DIV_LEFT = 2
const int DIV_RIGHT = 2
const int DIV_MIN_BARS = 8
const int DIV_MAX_BARS = 140
const int DIV_COOLDOWN = 10

const int SWING_LEN = 8
const int DISPLAY_FLOW_SMOOTH = 3
const int REGIME_FAST_LEN = 5
const int REGIME_SLOW_LEN = 13

const float DIV_MIN_MF_DELTA = 7.0
const float DIV_MIN_PRICE_ATR = 0.45
const float DIV_MIN_SCORE = 68.0

const float BULL_ENTER_LEVEL = 15.0
const float BEAR_ENTER_LEVEL = -15.0
const float BULL_FLIP_LEVEL = 25.0
const float BEAR_FLIP_LEVEL = -25.0
const float BULL_EXIT_LEVEL = 3.0
const float BEAR_EXIT_LEVEL = -3.0

const float DEAD_VOL_LEVEL = 0.55
const float LOW_VOL_LEVEL = 0.72
const float HIGH_VOL_LEVEL = 1.35
const float HEAVY_VOL_LEVEL = 1.65

color BULL_COLOR = bullColorInput
color BEAR_COLOR = bearColorInput
color NEUTRAL = neutralColorInput

float src = hlc3
bool barConfirmed = barstate.isconfirmed

int chartSecondsRaw = timeframe.in_seconds(timeframe.period)
int chartSeconds = na(chartSecondsRaw) ? 0 : chartSecondsRaw

// Helpers
f_clamp(float x, float lo, float hi) =>
    math.min(math.max(x, lo), hi)

f_clip100(float x) =>
    f_clamp(nz(x, 0.0), -100.0, 100.0)

f_pos(float x) =>
    f_clamp(x, 0.0, 100.0)

f_neg(float x) =>
    f_clamp(-x, 0.0, 100.0)

f_slope(float x, int len) =>
    ta.ema(x - nz(x[1], x), len)

// Auto settings
f_auto_vwap_anchor() =>
    chartSeconds <= 3600 ? timeframe.change("D") :
     chartSeconds <= 14400 ? timeframe.change("W") :
     chartSeconds <= 86400 ? timeframe.change("M") :
     chartSeconds <= 604800 ? timeframe.change("3M") :
     timeframe.change("12M")

f_auto_rsi_upper() =>
    chartSeconds <= 900 ? 56.0 :
     chartSeconds <= 3600 ? 55.0 :
     chartSeconds <= 14400 ? 54.0 :
     chartSeconds <= 86400 ? 53.0 :
     52.0

f_auto_vwap_base_stretch() =>
    chartSeconds <= 300 ? 0.85 :
     chartSeconds <= 900 ? 0.95 :
     chartSeconds <= 3600 ? 1.10 :
     chartSeconds <= 14400 ? 1.25 :
     chartSeconds <= 86400 ? 1.45 :
     1.65

f_auto_vwap_base_weight() =>
    chartSeconds <= 300 ? 0.27 :
     chartSeconds <= 900 ? 0.25 :
     chartSeconds <= 3600 ? 0.23 :
     chartSeconds <= 14400 ? 0.21 :
     chartSeconds <= 86400 ? 0.18 :
     0.16

f_auto_rsi_base_weight() =>
    chartSeconds <= 300 ? 0.16 :
     chartSeconds <= 900 ? 0.15 :
     chartSeconds <= 3600 ? 0.14 :
     chartSeconds <= 14400 ? 0.13 :
     chartSeconds <= 86400 ? 0.12 :
     0.10

f_auto_rsi_value(float _src) =>
    float value = chartSeconds <= 300 ? ta.rsi(_src, 10) :
     chartSeconds <= 900 ? ta.rsi(_src, 12) :
     chartSeconds <= 3600 ? ta.rsi(_src, 14) :
     chartSeconds <= 14400 ? ta.rsi(_src, 16) :
     chartSeconds <= 86400 ? ta.rsi(_src, 18) :
     ta.rsi(_src, 21)
    nz(value, 50.0)

f_auto_rsi_slope(float slopeRaw) =>
    float slope = chartSeconds <= 300 ? ta.ema(slopeRaw, 3) :
     chartSeconds <= 900 ? ta.ema(slopeRaw, 4) :
     chartSeconds <= 3600 ? ta.ema(slopeRaw, 5) :
     chartSeconds <= 14400 ? ta.ema(slopeRaw, 6) :
     chartSeconds <= 86400 ? ta.ema(slopeRaw, 7) :
     ta.ema(slopeRaw, 8)
    nz(slope, 0.0)

f_auto_absorption_sensitivity(float _volRatio, float _spreadQuality) =>
    float base = chartSeconds <= 300 ? 1.08 :
     chartSeconds <= 900 ? 1.10 :
     chartSeconds <= 3600 ? 1.13 :
     chartSeconds <= 14400 ? 1.16 :
     chartSeconds <= 86400 ? 1.18 :
     1.20
    float volAdj = f_clamp((_volRatio - 1.0) * 0.10, -0.08, 0.12)
    float chopAdj = _spreadQuality < 0.42 ? 0.08 : _spreadQuality > 0.70 ? -0.05 : 0.0
    f_clamp(base + volAdj + chopAdj, 0.85, 1.35)

f_auto_pressure_strength(float _volRatio, float _spreadQuality, float _pressureConfidence) =>
    float base = chartSeconds <= 300 ? 0.70 :
     chartSeconds <= 900 ? 0.72 :
     chartSeconds <= 3600 ? 0.73 :
     chartSeconds <= 14400 ? 0.74 :
     chartSeconds <= 86400 ? 0.76 :
     0.78
    float participationAdj = f_clamp((_volRatio - 1.0) * 0.07, -0.05, 0.08)
    float spreadAdj = f_clamp((_spreadQuality - 0.45) * 0.08, -0.03, 0.04)
    float confidenceAdj = f_clamp((_pressureConfidence - 50.0) * 0.0012, -0.04, 0.05)
    f_clamp(base + participationAdj + spreadAdj + confidenceAdj, 0.58, 0.84)

// Candle data
float volumeSafe = nz(volume, 0.0)
float barRange = math.max(high - low, syminfo.mintick)
float atrValue = math.max(nz(ta.atr(ATR_LEN), syminfo.mintick), syminfo.mintick)
float volBase = math.max(nz(ta.sma(volumeSafe, VOL_LEN), 1.0), 1.0)
float volRatio = f_clamp(volumeSafe / volBase, 0.0, 5.0)

float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float upperWickRatio = f_clamp(upperWick / barRange, 0.0, 1.0)
float lowerWickRatio = f_clamp(lowerWick / barRange, 0.0, 1.0)
float wickBalance = f_clamp((lowerWick - upperWick) / barRange, -1.0, 1.0)

float closeLocation = f_clamp(((close - low) - (high - close)) / barRange, -1.0, 1.0)
float bodyPressure = f_clamp((close - open) / barRange, -1.0, 1.0)
float spreadQuality = f_clamp(math.abs(close - open) / barRange, 0.0, 1.0)

float absorptionSensitivity = f_auto_absorption_sensitivity(volRatio, spreadQuality)

// Core flow
float volumePressureRaw = ((closeLocation * 0.58) + (bodyPressure * 0.28) + (wickBalance * 0.14)) * 100.0 * math.sqrt(math.max(volRatio, 0.05))
float volumePressure = ta.ema(f_clip100(volumePressureRaw), SMOOTH_LEN)

float priceImpulseRaw = ((src - nz(src[1], src)) / atrValue) * 100.0
float priceRatioRaw = priceImpulseRaw / math.max(volRatio, 0.35)
float priceRatio = ta.ema(f_clip100(priceRatioRaw), SMOOTH_LEN)

float mfiRaw = ta.mfi(src, MFI_LEN)
float mfiFallback = ta.rsi(src, MFI_LEN)
float mfiValue = nz(mfiRaw, nz(mfiFallback, 50.0))
float moneyFlow = ta.ema(f_clamp((mfiValue - 50.0) * 2.0, -100.0, 100.0), SMOOTH_LEN)

float fastTrend = ta.ema(src, TREND_FAST)
float slowTrend = ta.ema(src, TREND_SLOW)
float trendRaw = ((fastTrend - slowTrend) / atrValue) * 35.0
float trendBias = ta.ema(f_clip100(trendRaw), SMOOTH_LEN)

// Pressure guide
float aggressivePressureRaw = ((closeLocation * 0.46) + (bodyPressure * 0.34) + (wickBalance * 0.20)) * 100.0 * math.sqrt(math.max(volRatio, 0.05))
float aggressivePressure = ta.ema(f_clip100(aggressivePressureRaw), PRESSURE_FAST_LEN)

float effortNoResultGap = f_clamp(math.abs(volumePressure) - math.abs(priceImpulseRaw), 0.0, 100.0)

float bullAbsorptionRaw = volRatio >= 1.05 and lowerWickRatio > upperWickRatio and closeLocation > -0.18 ?
     f_clamp((lowerWickRatio * 54.0) + (f_clamp(closeLocation + 0.25, 0.0, 1.25) * 24.0) + (effortNoResultGap * 0.32), 0.0, 100.0) : 0.0

float bearAbsorptionRaw = volRatio >= 1.05 and upperWickRatio > lowerWickRatio and closeLocation < 0.18 ?
     f_clamp((upperWickRatio * 54.0) + (f_clamp(0.25 - closeLocation, 0.0, 1.25) * 24.0) + (effortNoResultGap * 0.32), 0.0, 100.0) : 0.0

float bullAbsorption = ta.ema(bullAbsorptionRaw * absorptionSensitivity, PRESSURE_FAST_LEN)
float bearAbsorption = ta.ema(bearAbsorptionRaw * absorptionSensitivity, PRESSURE_FAST_LEN)

float pressureQuality = f_clamp(
     (math.abs(aggressivePressure) * 0.38) +
     (f_clamp((volRatio - 0.70) * 24.0, 0.0, 36.0)) +
     (spreadQuality * 18.0) +
     (math.abs(closeLocation) * 16.0) +
     (math.max(bullAbsorption, bearAbsorption) * 0.20),
     0.0, 100.0)

float absorptionBias = f_clamp(bullAbsorption - bearAbsorption, -100.0, 100.0)

float pressureControlRaw = f_clamp(
     (aggressivePressure * 0.38) +
     (volumePressure * 0.24) +
     (moneyFlow * 0.12) +
     (trendBias * 0.10) +
     (absorptionBias * 0.16),
     -100.0, 100.0)

float pressureControlFast = ta.ema(pressureControlRaw, PRESSURE_FAST_LEN)
float pressureControlSlow = ta.ema(pressureControlRaw, PRESSURE_SLOW_LEN)
float pressureControl = ta.ema(f_clamp((pressureControlFast * 0.64) + (pressureControlSlow * 0.36), -100.0, 100.0), 3)

float pressureMomentum = pressureControl - nz(pressureControl[1], pressureControl)
float pressureConfidence = f_clamp((math.abs(pressureControl) * 0.52) + (pressureQuality * 0.48), 0.0, 100.0)

float pressureSoftGate = f_clamp(8.0 + ((1.0 - math.min(volRatio, 1.0)) * 5.0) + ((100.0 - pressureQuality) * 0.015), 8.0, 14.0)
float pressureConfirmGate = f_clamp(5.0 + ((1.0 - math.min(volRatio, 1.0)) * 4.0) + ((100.0 - pressureQuality) * 0.012), 5.0, 10.0)
float absorptionSoftGate = f_clamp(22.0 + ((1.0 - math.min(volRatio, 1.0)) * 5.0), 22.0, 30.0)
float absorptionConfirmGate = f_clamp(30.0 + ((1.0 - math.min(volRatio, 1.0)) * 5.0), 30.0, 38.0)

bool bullPressureOk = pressureControl > -pressureSoftGate or bullAbsorption > absorptionSoftGate
bool bearPressureOk = pressureControl < pressureSoftGate or bearAbsorption > absorptionSoftGate

bool bullPressureConfirm = pressureControl > pressureConfirmGate or bullAbsorption > absorptionConfirmGate or pressureMomentum > 3.0
bool bearPressureConfirm = pressureControl < -pressureConfirmGate or bearAbsorption > absorptionConfirmGate or pressureMomentum < -3.0

float flowMfSlope = f_slope(moneyFlow, FLOW_LEAD_LEN)
float flowMfAccel = f_slope(flowMfSlope, FLOW_LEAD_LEN)
float flowPressureSlope = f_slope(pressureControl, FLOW_LEAD_LEN)
float flowTrendSlope = f_slope(trendBias, FLOW_LEAD_LEN)

float impulseSmooth = ta.ema(nz(priceImpulseRaw, 0.0), FLOW_LEAD_LEN)
float impulseSlope = f_slope(impulseSmooth, FLOW_LEAD_LEN)

float mfContinuation = f_clamp((moneyFlow * 0.38) + (flowMfSlope * 7.0 * 0.38) + (flowMfAccel * 12.0 * 0.24), -100.0, 100.0)
float pressureContinuation = f_clamp((pressureControl * 0.48) + (flowPressureSlope * 7.0 * 0.30) + (closeLocation * 100.0 * 0.14) + (bodyPressure * 100.0 * 0.08), -100.0, 100.0)
float trendContinuation = f_clamp((trendBias * 0.56) + (flowTrendSlope * 7.0 * 0.44), -100.0, 100.0)
float priceContinuation = f_clamp((priceRatio * 0.38) + (impulseSmooth * 0.28) + (impulseSlope * 8.0 * 0.34), -100.0, 100.0)

float bullMfPrep = f_pos(flowMfSlope * 8.0) + f_pos(flowMfAccel * 14.0)
float bearMfPrep = f_neg(flowMfSlope * 8.0) + f_neg(flowMfAccel * 14.0)

float bullPressurePrep = f_pos(flowPressureSlope * 8.0) + f_pos(pressureControl) + f_pos(absorptionBias)
float bearPressurePrep = f_neg(flowPressureSlope * 8.0) + f_neg(pressureControl) + f_neg(absorptionBias)

float bullTrendSupport = f_pos(trendBias) + f_pos(flowTrendSlope * 7.0)
float bearTrendSupport = f_neg(trendBias) + f_neg(flowTrendSlope * 7.0)

float bullPrepScore = f_clamp((bullPressurePrep * 0.38) + (bullMfPrep * 0.24) + (bullTrendSupport * 0.20) + (f_pos(priceContinuation) * 0.18), 0.0, 100.0)
float bearPrepScore = f_clamp((bearPressurePrep * 0.38) + (bearMfPrep * 0.24) + (bearTrendSupport * 0.20) + (f_neg(priceContinuation) * 0.18), 0.0, 100.0)

float prepBias = bullPrepScore - bearPrepScore

float pressureWeight = f_clamp(0.28 + (f_auto_pressure_strength(volRatio, spreadQuality, pressureConfidence) * 0.26), 0.28, 0.54)
float remainingWeight = 1.0 - pressureWeight

float coreDirection = f_clamp(
     (pressureContinuation * pressureWeight) +
     (mfContinuation * remainingWeight * 0.38) +
     (trendContinuation * remainingWeight * 0.34) +
     (priceContinuation * remainingWeight * 0.28),
     -100.0, 100.0)

float agreementBoost = f_clamp((prepBias * 0.55) + (coreDirection * 0.45), -100.0, 100.0)
float flowRaw = (coreDirection * 0.64) + (agreementBoost * 0.36)

float flowMemory = ta.ema(f_clip100(flowRaw), FLOW_MEMORY_LEN)
float flowConfirm = ta.ema(f_clip100(flowRaw), FLOW_CONFIRM_LEN)
float flow = ta.ema(f_clamp((flowMemory * 0.58) + (flowConfirm * 0.42), -100.0, 100.0), FLOW_LEAD_LEN)

// Rotation
float rotationBasis = ta.ema(src, 144)
float rotationMid = ta.ema(src, 55)
float rotationFast = ta.ema(src, 21)

float longTermStretch = f_clamp(((src - nz(rotationBasis, src)) / atrValue) * 12.0, -100.0, 100.0)
float midRunStretch = f_clamp(((nz(rotationMid, src) - nz(rotationBasis, src)) / atrValue) * 20.0, -100.0, 100.0)
float fastRunStretch = f_clamp(((nz(rotationFast, src) - nz(rotationMid, src)) / atrValue) * 28.0, -100.0, 100.0)

float persistentRun = ta.ema(f_clamp((longTermStretch * 0.50) + (midRunStretch * 0.35) + (fastRunStretch * 0.15), -100.0, 100.0), 13)

float positioningRaw = ((closeLocation * 0.38) + (bodyPressure * 0.24) + (wickBalance * 0.38)) * 100.0 * math.sqrt(math.max(volRatio, 0.05))
float positioningProxy = ta.ema(f_clip100(positioningRaw), SMOOTH_LEN)

float longParticipation = f_clamp((f_pos(positioningProxy) * 0.35) + (f_pos(pressureControl) * 0.35) + (f_pos(moneyFlow) * 0.18) + (bullAbsorption * 0.12), 0.0, 100.0)
float shortParticipation = f_clamp((f_neg(positioningProxy) * 0.35) + (f_neg(pressureControl) * 0.35) + (f_neg(moneyFlow) * 0.18) + (bearAbsorption * 0.12), 0.0, 100.0)

float longCrowding = math.sqrt(math.max(f_pos(persistentRun) * longParticipation, 0.0))
float shortCrowding = math.sqrt(math.max(f_neg(persistentRun) * shortParticipation, 0.0))

float rotPressureSlope = f_slope(pressureControl, 5)
float rotMoneySlope = f_slope(moneyFlow, 5)
float rotImpulseSmooth = ta.ema(nz(priceImpulseRaw, 0.0), 5)
float rotImpulseSlope = f_slope(rotImpulseSmooth, 5)

float upFadeScore = (f_neg(rotPressureSlope * 4.0) * 0.42) + (f_neg(rotMoneySlope * 4.0) * 0.28) + (f_neg(rotImpulseSlope * 3.0) * 0.30)
float downFadeScore = (f_pos(rotPressureSlope * 4.0) * 0.42) + (f_pos(rotMoneySlope * 4.0) * 0.28) + (f_pos(rotImpulseSlope * 3.0) * 0.30)

float upperRejection = f_clamp((upperWickRatio - lowerWickRatio) * 100.0, 0.0, 60.0)
float lowerRejection = f_clamp((lowerWickRatio - upperWickRatio) * 100.0, 0.0, 60.0)

float weakBullClose = f_clamp((0.35 - closeLocation) * 45.0, 0.0, 40.0)
float weakBearClose = f_clamp((closeLocation + 0.35) * 45.0, 0.0, 40.0)

float bearRotationScore = f_clamp((longCrowding * 0.45) + (upFadeScore * 0.30) + (bearAbsorption * 0.15) + (((upperRejection * 0.60) + (weakBullClose * 0.40)) * 0.10), 0.0, 100.0)
float bullRotationScore = f_clamp((shortCrowding * 0.45) + (downFadeScore * 0.30) + (bullAbsorption * 0.15) + (((lowerRejection * 0.60) + (weakBearClose * 0.40)) * 0.10), 0.0, 100.0)

// VWAP
bool vwapAnchor = f_auto_vwap_anchor()
float vwapRaw = ta.vwap(src, vwapAnchor)
float vwap = nz(vwapRaw, nz(ta.ema(src, 50), src))

float vwapBaseStretch = f_auto_vwap_base_stretch()
float vwapBaseWeight = f_auto_vwap_base_weight()

float vwapDevAtr = f_clamp((src - vwap) / atrValue, -5.0, 5.0)
float vwapDevSlope = f_slope(vwapDevAtr, 5)
float vwapSlope = ta.ema(f_clamp(((vwap - nz(vwap[1], vwap)) / atrValue) * 100.0, -100.0, 100.0), 5)

float vwapStretchScore = f_clamp((math.abs(vwapDevAtr) / math.max(vwapBaseStretch, 0.10)) * 100.0, 0.0, 100.0)

bool vwapBullReclaim = src > vwap and nz(src[1], src) <= nz(vwap[1], vwap)
bool vwapBearLoss = src < vwap and nz(src[1], src) >= nz(vwap[1], vwap)

float vwapBearMeanRev = src > vwap ? f_clamp((vwapStretchScore * 0.46) + (f_neg(vwapDevSlope * 55.0) * 0.34) + (f_neg(vwapSlope) * 0.20), 0.0, 100.0) : 0.0
float vwapBullMeanRev = src < vwap ? f_clamp((vwapStretchScore * 0.46) + (f_pos(vwapDevSlope * 55.0) * 0.34) + (f_pos(vwapSlope) * 0.20), 0.0, 100.0) : 0.0

float vwapBullScore = f_clamp(vwapBullMeanRev + (vwapBullReclaim ? 18.0 : 0.0), 0.0, 100.0)
float vwapBearScore = f_clamp(vwapBearMeanRev + (vwapBearLoss ? 18.0 : 0.0), 0.0, 100.0)
float vwapAdaptiveWeight = f_clamp(vwapBaseWeight + ((vwapStretchScore / 100.0) * 0.06) + (f_clamp(volRatio - 1.0, 0.0, 2.0) * 0.015), 0.10, 0.34)

bullRotationScore := f_clamp((bullRotationScore * (1.0 - vwapAdaptiveWeight)) + (vwapBullScore * vwapAdaptiveWeight), 0.0, 100.0)
bearRotationScore := f_clamp((bearRotationScore * (1.0 - vwapAdaptiveWeight)) + (vwapBearScore * vwapAdaptiveWeight), 0.0, 100.0)

// RSI
float rsiUpper = f_auto_rsi_upper()
float rsiLower = 100.0 - rsiUpper
float rsiBaseWeight = f_auto_rsi_base_weight()

float rsiValue = f_auto_rsi_value(src)
float rsiSlope = f_auto_rsi_slope(rsiValue - nz(rsiValue[1], rsiValue))
float rsiAccel = f_auto_rsi_slope(rsiSlope - nz(rsiSlope[1], rsiSlope))

float rsiHighPressure = f_clamp((rsiValue - rsiUpper) * 2.2, 0.0, 100.0)
float rsiLowPressure = f_clamp((rsiLower - rsiValue) * 2.2, 0.0, 100.0)

float rsiBearMomentumLoss = f_clamp((f_neg(rsiSlope * 14.0) * 0.58) + (f_neg(rsiAccel * 24.0) * 0.42), 0.0, 100.0)
float rsiBullMomentumTurn = f_clamp((f_pos(rsiSlope * 14.0) * 0.58) + (f_pos(rsiAccel * 24.0) * 0.42), 0.0, 100.0)

float rsiBearScore = f_clamp((rsiHighPressure * 0.34) + (rsiBearMomentumLoss * 0.66), 0.0, 100.0)
float rsiBullScore = f_clamp((rsiLowPressure * 0.34) + (rsiBullMomentumTurn * 0.66), 0.0, 100.0)
float rsiAdaptiveWeight = f_clamp(rsiBaseWeight + ((math.max(rsiBearMomentumLoss, rsiBullMomentumTurn) / 100.0) * 0.05), 0.07, 0.22)

bullRotationScore := f_clamp((bullRotationScore * (1.0 - rsiAdaptiveWeight)) + (rsiBullScore * rsiAdaptiveWeight), 0.0, 100.0)
bearRotationScore := f_clamp((bearRotationScore * (1.0 - rsiAdaptiveWeight)) + (rsiBearScore * rsiAdaptiveWeight), 0.0, 100.0)

float priceRotation = ta.ema(f_clip100(bullRotationScore - bearRotationScore), 13)

// Price effort
float resultScore = f_clamp(
     f_clamp(math.abs(priceImpulseRaw) * 0.75, 0.0, 42.0) +
     f_clamp(spreadQuality * 34.0, 0.0, 34.0) +
     f_clamp(math.abs(closeLocation) * 26.0, 0.0, 26.0),
     0.0, 100.0)

float directionalResult = f_clamp((priceImpulseRaw * 0.44) + (closeLocation * 30.0) + (bodyPressure * 22.0) + (wickBalance * 14.0), -100.0, 100.0)
float directionalEffort = f_clamp((pressureControl * 0.46) + (volumePressure * 0.22) + (moneyFlow * 0.14) + (positioningProxy * 0.10) + (trendBias * 0.08), -100.0, 100.0)

float effortResultGap = f_clamp(math.abs(directionalEffort) - math.abs(directionalResult), 0.0, 100.0)
float resultEfficiency = f_clamp(math.abs(directionalResult) / math.max(math.abs(directionalEffort), 8.0), 0.0, 1.45)

float cleanContinuation = f_clamp((directionalEffort * 0.42) + (directionalResult * 0.36) + (priceContinuation * 0.22), -100.0, 100.0)

bool bullishEffortNoResult = directionalEffort > 18.0 and directionalResult < 10.0 and effortResultGap > 10.0
bool bearishEffortNoResult = directionalEffort < -18.0 and directionalResult > -10.0 and effortResultGap > 10.0

float bullFailurePenalty = bullishEffortNoResult ? f_clamp(effortResultGap * (0.55 + upperWickRatio + f_clamp(-closeLocation, 0.0, 1.0) * 0.65), 0.0, 75.0) : 0.0
float bearFailureReward = bearishEffortNoResult ? f_clamp(effortResultGap * (0.55 + lowerWickRatio + f_clamp(closeLocation, 0.0, 1.0) * 0.65), 0.0, 75.0) : 0.0

float failureBias = f_clamp(bearFailureReward - bullFailurePenalty, -75.0, 75.0)
float efficientBias = f_clamp(cleanContinuation * (0.68 + math.min(resultEfficiency, 1.20) * 0.32), -100.0, 100.0)

float priceEffortRaw = f_clamp(
     (flow * 0.24) +
     (pressureControl * 0.26) +
     (priceRotation * 0.18) +
     (efficientBias * 0.24) +
     (failureBias * 0.08),
     -100.0, 100.0)

float priceEffortFast = ta.ema(priceEffortRaw, 8)
float priceEffortSlow = ta.ema(priceEffortRaw, 21)
float priceEffortCore = ta.ema(f_clamp((priceEffortFast * 0.62) + (priceEffortSlow * 0.38), -100.0, 100.0), 3)

float priceEffortScale = math.max(ta.ema(math.abs(priceEffortCore), 55), 18.0)
float priceEffort = f_clamp((priceEffortCore / priceEffortScale) * 58.0, -100.0, 100.0)

float priceEffortSignal = ta.ema(nz(priceEffort, 0.0), SIGNAL_LEN)
float priceEffortMomentum = nz(priceEffort, 0.0) - nz(priceEffortSignal, 0.0)

// Regime
float displayPriceEffort = nz(ta.ema(priceEffort, DISPLAY_FLOW_SMOOTH), 0.0)
float displayEffortSignal = nz(ta.ema(priceEffortSignal, DISPLAY_FLOW_SMOOTH), 0.0)

float signedCandleResult = closeLocation * spreadQuality * 32.0
float momentumPower = f_clamp(priceEffortMomentum * 2.2, -32.0, 32.0)

float rawRegimeBias =
     (priceEffort * 0.36) +
     (pressureControl * 0.28) +
     (momentumPower * 0.68) +
     (moneyFlow * 0.12) +
     (trendBias * 0.14) +
     (priceImpulseRaw * 0.08) +
     signedCandleResult

float regimeBiasFast = ta.ema(f_clip100(rawRegimeBias), REGIME_FAST_LEN)
float regimeBias = nz(ta.ema(regimeBiasFast, REGIME_SLOW_LEN), 0.0)

float adaptiveDeadBand = f_clamp(9.0 + ((1.0 - math.min(volRatio, 1.0)) * 8.0) + ((100.0 - pressureConfidence) * 0.05), 9.0, 20.0)

bool noEffortDead = volRatio < DEAD_VOL_LEVEL and resultScore < 28.0 and math.abs(regimeBias) < 18.0
bool lowVolumeFlat = volRatio < LOW_VOL_LEVEL and resultScore < 34.0 and math.abs(regimeBias) < 14.0 and math.abs(priceEffortMomentum) < 5.0
bool highEffortBadResult = volRatio > HIGH_VOL_LEVEL and resultScore < 29.0 and math.abs(regimeBias) < 20.0 and pressureConfidence < 50.0
bool heavyEffortAbsorption = volRatio > HEAVY_VOL_LEVEL and math.abs(priceImpulseRaw) < 16.0 and spreadQuality < 0.43 and math.abs(closeLocation) < 0.36 and math.abs(regimeBias) < 25.0 and math.abs(absorptionBias) < 28.0
bool wickChop = volRatio > HIGH_VOL_LEVEL and math.max(upperWickRatio, lowerWickRatio) > 0.46 and spreadQuality < 0.42 and math.abs(closeLocation) < 0.34 and math.abs(regimeBias) < 24.0 and math.abs(absorptionBias) < 30.0
bool pressurePriceConflict = ((pressureControl > 20.0 and priceImpulseRaw < -7.0) or (pressureControl < -20.0 and priceImpulseRaw > 7.0)) and math.abs(regimeBias) < 22.0
bool deadBalance = math.abs(regimeBias) < adaptiveDeadBand and math.abs(priceEffortMomentum) < 3.8 and math.abs(trendBias) < 11.0 and resultScore < 38.0 and pressureConfidence < 42.0

bool noUsefulRead = noEffortDead or lowVolumeFlat or highEffortBadResult or heavyEffortAbsorption or wickChop or pressurePriceConflict or deadBalance

bool bullSetup = not noUsefulRead and bullPressureOk and regimeBias > BULL_ENTER_LEVEL and displayPriceEffort >= displayEffortSignal and moneyFlow > -35.0
bool bearSetup = not noUsefulRead and bearPressureOk and regimeBias < BEAR_ENTER_LEVEL and displayPriceEffort <= displayEffortSignal and moneyFlow < 35.0

bool bullConfirmed = bullSetup and bullPressureConfirm and (bullSetup[1] or regimeBias > BULL_FLIP_LEVEL or pressureControl > 18.0)
bool bearConfirmed = bearSetup and bearPressureConfirm and (bearSetup[1] or regimeBias < BEAR_FLIP_LEVEL or pressureControl < -18.0)

var int effortState = 0
int nextEffortState = effortState

if effortState == 1
    if bearConfirmed and regimeBias < BEAR_FLIP_LEVEL and bearPressureConfirm
        nextEffortState := -1
    else if noUsefulRead and regimeBias < BULL_EXIT_LEVEL
        nextEffortState := 0
    else if regimeBias < -6.0 and displayPriceEffort < displayEffortSignal and pressureControl < 4.0
        nextEffortState := 0
else if effortState == -1
    if bullConfirmed and regimeBias > BULL_FLIP_LEVEL and bullPressureConfirm
        nextEffortState := 1
    else if noUsefulRead and regimeBias > BEAR_EXIT_LEVEL
        nextEffortState := 0
    else if regimeBias > 6.0 and displayPriceEffort > displayEffortSignal and pressureControl > -4.0
        nextEffortState := 0
else
    nextEffortState := bullConfirmed ? 1 : bearConfirmed ? -1 : 0

if barConfirmed
    effortState := nextEffortState

bool bullEffortFlip = barConfirmed and effortState == 1 and nz(effortState[1], 0) != 1
bool bearEffortFlip = barConfirmed and effortState == -1 and nz(effortState[1], 0) != -1
bool neutralEffortFlip = barConfirmed and effortState == 0 and nz(effortState[1], 0) != 0

// Swings
float priorSwingLow = ta.lowest(low[1], SWING_LEN)
float priorSwingHigh = ta.highest(high[1], SWING_LEN)
float priorLow5 = ta.lowest(low[1], 5)
float priorHigh5 = ta.highest(high[1], 5)

bool atSwingLow = not na(priorSwingLow) and low <= priorSwingLow
bool atSwingHigh = not na(priorSwingHigh) and high >= priorSwingHigh

// Exhaustion and reversal
bool pressureRising = pressureControl > nz(pressureControl[1], pressureControl)
bool pressureFading = pressureControl < nz(pressureControl[1], pressureControl)
bool moneyRising = moneyFlow > nz(moneyFlow[1], moneyFlow)
bool moneyFading = moneyFlow < nz(moneyFlow[1], moneyFlow)

bool moneyFlowTopZoneHit = ta.crossover(moneyFlow, PRIME_ZONE) or moneyFlow >= EXTREME_ZONE
bool moneyFlowBottomZoneHit = ta.crossunder(moneyFlow, -PRIME_ZONE) or moneyFlow <= -EXTREME_ZONE

bool moneyFlowTopZoneActive = moneyFlow >= PRIME_ZONE
bool moneyFlowBottomZoneActive = moneyFlow <= -PRIME_ZONE

bool nearTopPremium = priceEffort >= PRIME_ZONE * 0.72 or displayPriceEffort >= PRIME_ZONE * 0.72 or moneyFlowTopZoneActive or priceRotation <= -22.0
bool nearBottomPremium = priceEffort <= -PRIME_ZONE * 0.72 or displayPriceEffort <= -PRIME_ZONE * 0.72 or moneyFlowBottomZoneActive or priceRotation >= 22.0

bool activeVolatility = volRatio >= 0.95 or math.abs(priceImpulseRaw) >= 12.0 or math.max(upperWickRatio, lowerWickRatio) >= 0.26

bool topWickHunt = (atSwingHigh or high >= priorHigh5) and upperWickRatio >= 0.24 and upperWickRatio > lowerWickRatio * 1.05 and closeLocation < 0.35
bool bottomWickHunt = (atSwingLow or low <= priorLow5) and lowerWickRatio >= 0.24 and lowerWickRatio > upperWickRatio * 1.05 and closeLocation > -0.35

bool topAbsorption = bearAbsorption > 22.0 or (volRatio >= 1.15 and upperWickRatio >= 0.18 and closeLocation < 0.25 and spreadQuality < 0.75)
bool bottomAbsorption = bullAbsorption > 22.0 or (volRatio >= 1.15 and lowerWickRatio >= 0.18 and closeLocation > -0.25 and spreadQuality < 0.75)

bool topFailedPush = high > nz(high[1], high) and closeLocation < 0.15 and close < open
bool bottomFailedPush = low < nz(low[1], low) and closeLocation > -0.15 and close > open

bool bearRotationEvidence = pressureFading or moneyFading or priceRotation < nz(priceRotation[1], priceRotation) or priceEffortMomentum < nz(priceEffortMomentum[1], priceEffortMomentum) or bearAbsorption > 28.0
bool bullRotationEvidence = pressureRising or moneyRising or priceRotation > nz(priceRotation[1], priceRotation) or priceEffortMomentum > nz(priceEffortMomentum[1], priceEffortMomentum) or bullAbsorption > 28.0

bool topMoneyFlowExhaustRaw = moneyFlowTopZoneHit and activeVolatility and (bearRotationEvidence or bearAbsorption > 24.0 or pressureControl < 8.0)
bool bottomMoneyFlowExhaustRaw = moneyFlowBottomZoneHit and activeVolatility and (bullRotationEvidence or bullAbsorption > 24.0 or pressureControl > -8.0)

bool topExhaustRaw = topMoneyFlowExhaustRaw or (nearTopPremium and activeVolatility and bearRotationEvidence and (topAbsorption or topFailedPush))
bool bottomExhaustRaw = bottomMoneyFlowExhaustRaw or (nearBottomPremium and activeVolatility and bullRotationEvidence and (bottomAbsorption or bottomFailedPush))

bool topReversalRaw = nearTopPremium and activeVolatility and bearRotationEvidence and topWickHunt and (bearAbsorption > 18.0 or pressureControl < 15.0)
bool bottomReversalRaw = nearBottomPremium and activeVolatility and bullRotationEvidence and bottomWickHunt and (bullAbsorption > 18.0 or pressureControl > -15.0)

var int lastTopExhaustBar = na
var int lastBottomExhaustBar = na
var int lastTopReversalBar = na
var int lastBottomReversalBar = na

bool topExhaustCandidate = showExhaustion and topExhaustRaw and (na(lastTopExhaustBar) or bar_index - lastTopExhaustBar >= 5)
bool bottomExhaustCandidate = showExhaustion and bottomExhaustRaw and (na(lastBottomExhaustBar) or bar_index - lastBottomExhaustBar >= 5)
bool topReversalCandidate = showReversals and topReversalRaw and (na(lastTopReversalBar) or bar_index - lastTopReversalBar >= 5)
bool bottomReversalCandidate = showReversals and bottomReversalRaw and (na(lastBottomReversalBar) or bar_index - lastBottomReversalBar >= 5)

bool topExhaust = barConfirmed and topExhaustCandidate
bool bottomExhaust = barConfirmed and bottomExhaustCandidate
bool topReversal = barConfirmed and topReversalCandidate
bool bottomReversal = barConfirmed and bottomReversalCandidate

if topExhaust
    lastTopExhaustBar := bar_index
if bottomExhaust
    lastBottomExhaustBar := bar_index
if topReversal
    lastTopReversalBar := bar_index
if bottomReversal
    lastBottomReversalBar := bar_index

// Pressure
bool fallingContext = trendBias < -8.0 or priceEffort < -PRIME_ZONE * 0.45 or ta.falling(src, 3)
bool risingContext = trendBias > 8.0 or priceEffort > PRIME_ZONE * 0.45 or ta.rising(src, 3)

bool highParticipation = volRatio > 1.20
bool heavyParticipation = volRatio > 1.55

bool bullishCounterWick = lowerWickRatio >= 0.34 and lowerWickRatio > upperWickRatio * 1.25 and closeLocation > 0.05
bool bearishCounterWick = upperWickRatio >= 0.34 and upperWickRatio > lowerWickRatio * 1.25 and closeLocation < -0.05

bool stalledHighVolumeMove = heavyParticipation and math.abs(priceImpulseRaw) < 24.0 and spreadQuality < 0.50

bool positivePressureRaw = atSwingLow and fallingContext and highParticipation and bullishCounterWick
bool negativePressureRaw = atSwingHigh and risingContext and highParticipation and bearishCounterWick

bool positiveStallPressureRaw = atSwingLow and fallingContext and stalledHighVolumeMove and lowerWickRatio > upperWickRatio and closeLocation > 0.0
bool negativeStallPressureRaw = atSwingHigh and risingContext and stalledHighVolumeMove and upperWickRatio > lowerWickRatio and closeLocation < 0.0

bool positivePressureMomentum = (positivePressureRaw or positiveStallPressureRaw or bullAbsorption > 38.0) and not (negativePressureRaw or negativeStallPressureRaw or bearAbsorption > 38.0)
bool negativePressureMomentum = (negativePressureRaw or negativeStallPressureRaw or bearAbsorption > 38.0) and not (positivePressureRaw or positiveStallPressureRaw or bullAbsorption > 38.0)

float baseMomentumColumn = priceEffortMomentum * 2.0
float softBoost = f_clamp(22.0 + ((f_clamp(volRatio, 1.0, 3.0) - 1.0) * 3.5) + (math.max(lowerWickRatio, upperWickRatio) * 8.0), 24.0, 36.0)
float effortMomentumVisual = positivePressureMomentum ? math.max(baseMomentumColumn, softBoost) : negativePressureMomentum ? math.min(baseMomentumColumn, -softBoost) : baseMomentumColumn

// Colors
color effortColor = effortState == 1 ? color.new(BULL_COLOR, 0) : effortState == -1 ? color.new(BEAR_COLOR, 0) : color.new(NEUTRAL, 0)
color momentumColor = positivePressureMomentum ? color.new(BULL_COLOR, 0) : negativePressureMomentum ? color.new(BEAR_COLOR, 0) : priceEffortMomentum >= 0 ? color.new(BULL_COLOR, 35) : color.new(BEAR_COLOR, 35)
color pressureCol = pressureControl >= 0 ? color.new(BULL_COLOR, 68) : color.new(BEAR_COLOR, 68)
color moneyCol = moneyFlow >= 0 ? color.new(BULL_COLOR, 88) : color.new(BEAR_COLOR, 88)

// Plots
pUpperExtreme = plot(showZones ? EXTREME_ZONE : na, "Upper Exhaustion", color=color.new(BEAR_COLOR, 35), linewidth=1)
pUpperPrime = plot(showZones ? PRIME_ZONE : na, "Upper Prime Zone", color=color.new(BEAR_COLOR, 70), linewidth=1)

hline(0.0, "Zero Line", color=color.new(color.white, 65), linestyle=hline.style_solid, linewidth=1)

pLowerPrime = plot(showZones ? -PRIME_ZONE : na, "Lower Prime Zone", color=color.new(BULL_COLOR, 70), linewidth=1)
pLowerExtreme = plot(showZones ? -EXTREME_ZONE : na, "Lower Exhaustion", color=color.new(BULL_COLOR, 35), linewidth=1)

fill(pUpperExtreme, pUpperPrime, color=showZones ? color.new(BEAR_COLOR, 92) : na, title="Upper Premium Zone")
fill(pLowerPrime, pLowerExtreme, color=showZones ? color.new(BULL_COLOR, 92) : na, title="Lower Premium Zone")

plot(showMoneyWave ? moneyFlow : na, "Money Flow", style=plot.style_area, color=moneyCol, linewidth=1)

plot(showPressureBars ? pressureControl : na, "Price Pressure", style=plot.style_columns, color=pressureCol)
plot(showPressureBars ? effortMomentumVisual : na, "Price Pressure Momentum", style=plot.style_columns, color=momentumColor)

plot(showPriceEffort ? displayPriceEffort : na, "Price Effort", color=effortColor, linewidth=4)

plotchar(topExhaust ? EXTREME_ZONE : na, "Top Exhaustion", char="✦", location=location.absolute, color=color.new(BEAR_COLOR, 0), size=size.tiny)
plotchar(bottomExhaust ? -EXTREME_ZONE : na, "Bottom Exhaustion", char="✦", location=location.absolute, color=color.new(BULL_COLOR, 0), size=size.tiny)

plotchar(topReversal ? EXTREME_ZONE + 8.0 : na, "Top Reversal", char="▼", location=location.absolute, color=color.new(BEAR_COLOR, 0), size=size.tiny)
plotchar(bottomReversal ? -EXTREME_ZONE - 8.0 : na, "Bottom Reversal", char="▲", location=location.absolute, color=color.new(BULL_COLOR, 0), size=size.tiny)

// Divergence
float priceLowPivot = showDivergences ? ta.pivotlow(low, DIV_LEFT, DIV_RIGHT) : na
float priceHighPivot = showDivergences ? ta.pivothigh(high, DIV_LEFT, DIV_RIGHT) : na

float oscLowPivot = showDivergences ? ta.pivotlow(moneyFlow, DIV_LEFT, DIV_RIGHT) : na
float oscHighPivot = showDivergences ? ta.pivothigh(moneyFlow, DIV_LEFT, DIV_RIGHT) : na

var float prevPriceLow = na
var float prevOscLow = na
var int prevLowBar = na

var float prevPriceHigh = na
var float prevOscHigh = na
var int prevHighBar = na

var int lastBullDivBar = na
var int lastBearDivBar = na

bool bullDivNow = false
bool bearDivNow = false

if showDivergences and barConfirmed and not na(priceLowPivot) and not na(oscLowPivot)
    float currPriceLow = priceLowPivot
    float currOscLow = oscLowPivot
    int currLowBar = bar_index - DIV_RIGHT

    bool hasPrevLow = not na(prevPriceLow) and not na(prevOscLow) and not na(prevLowBar)

    int barsFromPrev = hasPrevLow ? currLowBar - prevLowBar : na
    bool barsOk = hasPrevLow and barsFromPrev >= DIV_MIN_BARS and barsFromPrev <= DIV_MAX_BARS
    bool cooldownOk = na(lastBullDivBar) or currLowBar - lastBullDivBar >= DIV_COOLDOWN

    float pivotAtr = math.max(atrValue[DIV_RIGHT], syminfo.mintick)
    float priceDropAtr = hasPrevLow ? (prevPriceLow - currPriceLow) / pivotAtr : 0.0
    float oscLift = hasPrevLow ? currOscLow - prevOscLow : 0.0

    bool priceLowerLow = hasPrevLow and currPriceLow < prevPriceLow
    bool oscHigherLow = hasPrevLow and oscLift >= DIV_MIN_MF_DELTA
    bool priceMoveOk = priceDropAtr >= DIV_MIN_PRICE_ATR

    bool meaningfulPriceLow = currPriceLow <= ta.lowest(low, SWING_LEN)[DIV_RIGHT] or priceDropAtr >= 0.85

    bool lowerWeakContext =
         currOscLow <= -8.0 or
         prevOscLow <= -12.0 or
         displayPriceEffort[DIV_RIGHT] <= -22.0 or
         priceEffort[DIV_RIGHT] <= -22.0 or
         nearBottomPremium[DIV_RIGHT]

    bool rejectUpperContext =
         nearTopPremium[DIV_RIGHT] or
         currOscLow > 18.0 or
         displayPriceEffort[DIV_RIGHT] > 30.0 or
         priceEffort[DIV_RIGHT] > 30.0 or
         regimeBias[DIV_RIGHT] > 32.0

    bool recoveryEvidence =
         moneyFlow[DIV_RIGHT - 1] > currOscLow or
         pressureControl[DIV_RIGHT] > nz(pressureControl[DIV_RIGHT + 1], pressureControl[DIV_RIGHT]) or
         bullAbsorption[DIV_RIGHT] > 16.0 or
         lowerWickRatio[DIV_RIGHT] > upperWickRatio[DIV_RIGHT]

    float priceScore = f_clamp(priceDropAtr * 28.0, 0.0, 36.0)
    float oscScore = f_clamp(oscLift * 2.6, 0.0, 38.0)
    float contextScore = lowerWeakContext ? 16.0 : 0.0
    float recoveryScore = f_clamp(
         (bullAbsorption[DIV_RIGHT] * 0.35) +
         f_pos(pressureControl[DIV_RIGHT] - nz(pressureControl[DIV_RIGHT + 1], pressureControl[DIV_RIGHT])) * 1.2 +
         f_pos(priceRotation[DIV_RIGHT]) * 0.25,
         0.0, 24.0)

    float bullDivScore = priceScore + oscScore + contextScore + recoveryScore

    bullDivNow := barsOk and cooldownOk and priceLowerLow and oscHigherLow and priceMoveOk and meaningfulPriceLow and lowerWeakContext and not rejectUpperContext and recoveryEvidence and bullDivScore >= DIV_MIN_SCORE

    if bullDivNow
        label.new(currLowBar, currOscLow - 7.0, "BULL DIV", xloc=xloc.bar_index, style=label.style_label_up, color=color.new(BULL_COLOR, 0), textcolor=color.rgb(5, 10, 12), size=size.tiny)
        lastBullDivBar := currLowBar

    prevPriceLow := currPriceLow
    prevOscLow := currOscLow
    prevLowBar := currLowBar

if showDivergences and barConfirmed and not na(priceHighPivot) and not na(oscHighPivot)
    float currPriceHigh = priceHighPivot
    float currOscHigh = oscHighPivot
    int currHighBar = bar_index - DIV_RIGHT

    bool hasPrevHigh = not na(prevPriceHigh) and not na(prevOscHigh) and not na(prevHighBar)

    int barsFromPrev = hasPrevHigh ? currHighBar - prevHighBar : na
    bool barsOk = hasPrevHigh and barsFromPrev >= DIV_MIN_BARS and barsFromPrev <= DIV_MAX_BARS
    bool cooldownOk = na(lastBearDivBar) or currHighBar - lastBearDivBar >= DIV_COOLDOWN

    float pivotAtr = math.max(atrValue[DIV_RIGHT], syminfo.mintick)
    float pricePushAtr = hasPrevHigh ? (currPriceHigh - prevPriceHigh) / pivotAtr : 0.0
    float oscDrop = hasPrevHigh ? prevOscHigh - currOscHigh : 0.0

    bool priceHigherHigh = hasPrevHigh and currPriceHigh > prevPriceHigh
    bool oscLowerHigh = hasPrevHigh and oscDrop >= DIV_MIN_MF_DELTA
    bool priceMoveOk = pricePushAtr >= DIV_MIN_PRICE_ATR

    bool meaningfulPriceHigh = currPriceHigh >= ta.highest(high, SWING_LEN)[DIV_RIGHT] or pricePushAtr >= 0.85

    bool upperStrongContext =
         currOscHigh >= 8.0 or
         prevOscHigh >= 12.0 or
         displayPriceEffort[DIV_RIGHT] >= 22.0 or
         priceEffort[DIV_RIGHT] >= 22.0 or
         nearTopPremium[DIV_RIGHT]

    bool rejectLowerContext =
         nearBottomPremium[DIV_RIGHT] or
         currOscHigh < -18.0 or
         displayPriceEffort[DIV_RIGHT] < -30.0 or
         priceEffort[DIV_RIGHT] < -30.0 or
         regimeBias[DIV_RIGHT] < -32.0

    bool weaknessEvidence =
         moneyFlow[DIV_RIGHT - 1] < currOscHigh or
         pressureControl[DIV_RIGHT] < nz(pressureControl[DIV_RIGHT + 1], pressureControl[DIV_RIGHT]) or
         bearAbsorption[DIV_RIGHT] > 16.0 or
         upperWickRatio[DIV_RIGHT] > lowerWickRatio[DIV_RIGHT]

    float priceScore = f_clamp(pricePushAtr * 28.0, 0.0, 36.0)
    float oscScore = f_clamp(oscDrop * 2.6, 0.0, 38.0)
    float contextScore = upperStrongContext ? 16.0 : 0.0
    float weaknessScore = f_clamp(
         (bearAbsorption[DIV_RIGHT] * 0.35) +
         f_neg(pressureControl[DIV_RIGHT] - nz(pressureControl[DIV_RIGHT + 1], pressureControl[DIV_RIGHT])) * 1.2 +
         f_neg(priceRotation[DIV_RIGHT]) * 0.25,
         0.0, 24.0)

    float bearDivScore = priceScore + oscScore + contextScore + weaknessScore

    bearDivNow := barsOk and cooldownOk and priceHigherHigh and oscLowerHigh and priceMoveOk and meaningfulPriceHigh and upperStrongContext and not rejectLowerContext and weaknessEvidence and bearDivScore >= DIV_MIN_SCORE

    if bearDivNow
        label.new(currHighBar, currOscHigh + 7.0, "BEAR DIV", xloc=xloc.bar_index, style=label.style_label_down, color=color.new(BEAR_COLOR, 0), textcolor=color.white, size=size.tiny)
        lastBearDivBar := currHighBar

    prevPriceHigh := currPriceHigh
    prevOscHigh := currOscHigh
    prevHighBar := currHighBar

// Alerts
alertcondition(topExhaust or bottomExhaust, "Exhaustion", "Exhaustion on {{ticker}} {{interval}}")
alertcondition(topReversal or bottomReversal, "Reversal", "Reversal on {{ticker}} {{interval}}")
alertcondition(bullDivNow or bearDivNow, "Divergence", "Divergence on {{ticker}} {{interval}}")
alertcondition(bullEffortFlip or bearEffortFlip or neutralEffortFlip, "Price Effort Change", "Price Effort changed on {{ticker}} {{interval}}")
````
