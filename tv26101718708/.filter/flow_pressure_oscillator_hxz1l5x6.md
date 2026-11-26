# Flow Pressure Oscillator

- url: https://www.tradingview.com/script/HxZ1l5X6-Flow-Pressure-Oscillator/
- type: indicator
- pine_id: PUB;5a0d8bd3d0544121894889ab0da470ef
- version: 1.0

## Description

Flow Pressure Oscillator visualizes directional market pressure, trend alignment, regime quality, pullback pressure, and extended pressure conditions in a separate oscillator pane.

The tool is built to help traders read whether market pressure is leaning bullish, bearish, or neutral. It combines trend structure, EMA alignment, ATR-normalized movement, ADX, directional efficiency, volatility behavior, and volume participation into a bounded flow reading between -100 and +100.

The main Flow Trail shows the current pressure direction and strength. Positive readings indicate bullish pressure, negative readings indicate bearish pressure, and values near the zero line suggest a more neutral or mixed environment.

Regime Dots show the internal market regime state. Upper dots represent bullish regime pressure, lower dots represent bearish regime pressure, and neutral readings show that no strong directional regime is active.

The Pullback Reload Line is designed to highlight pullback pressure inside an existing bullish or bearish regime. It is not an entry signal by itself. It is meant to be used as context together with the Flow Trail, regime state, and the user’s own chart analysis.

The oscillator also highlights expansion and exhaustion-style pressure conditions. These areas can help identify when pressure is becoming stretched, accelerating, or losing momentum. They should be treated as market-context readings, not as guaranteed reversal or continuation points.

[b]Core components[/b]

[b]Flow Trail:[/b]
The main pressure line. It reacts to trend pressure, momentum slope, acceleration, structure alignment, volatility, and volume participation.

[b]Zero Line:[/b]
A neutral reference level. Readings above zero show bullish pressure dominance. Readings below zero show bearish pressure dominance.

[b]Regime Dots:[/b]
A visual regime filter for bullish, bearish, or neutral pressure conditions.

[b]Pullback Reload Line:[/b]
A secondary pressure line designed to show pullback or reload behavior inside an active regime.

[b]Pressure Fill:[/b]
A visual fill between the Flow Trail and the zero line to make pressure direction easier to read.

[b]Extreme Pressure Coloring:[/b]
Highlights expanded, stretched, or exhaustion-style pressure states.

[b]A simple way to use the oscillator is:[/b]

- Flow Trail above zero = bullish pressure is dominant;
- Flow Trail below zero = bearish pressure is dominant;
- Rising Flow Trail = pressure is strengthening;
- Falling Flow Trail = pressure is weakening;
- Regime Dots help confirm whether the broader pressure environment supports the current flow direction;
- Reload Line can help identify pullback pressure during an existing bullish or bearish regime;
- Extreme pressure areas should be used for awareness, not as automatic trade signals.

[b]Important notes[/b]

Flow Pressure Oscillator is a market-pressure visualization tool only. It does not provide financial advice, trade recommendations, profit targets, stop losses, win-rate calculations, or performance guarantees.

[i]The script should be used together with the trader’s own market structure, support and resistance, risk management, and confirmation process. No single oscillator should be used as a complete trading system.[/i]

## Source Code

````pine
//@version=6
// This source code is subject to the Mozilla Public License 2.0: https://mozilla.org/MPL/2.0/
// Flow Pressure Oscillator
// Deterministic market-pressure oscillator. This script does not provide financial advice, performance guarantees, or standalone trade instructions.

indicator("Flow Pressure Oscillator", shorttitle="Flow Pressure", overlay=false, precision=2)

// Visual settings
groupVisuals = "Visuals"

showZeroLine     = input.bool(true, "Show Zero Line", group=groupVisuals)
showFlowTrail    = input.bool(true, "Show Flow Trail", group=groupVisuals)
showRegimeDots   = input.bool(true, "Show Regime Dots", group=groupVisuals)
showReloadLine   = input.bool(true, "Show Reload Line", group=groupVisuals)
showPressureFill = input.bool(true, "Show Pressure Fill", group=groupVisuals)

groupColors = "Colors"

neutralColor = input.color(color.rgb(125, 132, 155), "Neutral", group=groupColors)
bullishColor = input.color(color.rgb(0, 235, 200), "Bullish", group=groupColors)
bearishColor = input.color(color.rgb(255, 60, 110), "Bearish", group=groupColors)
extremeColor = input.color(color.rgb(255, 190, 75), "Extreme", group=groupColors)

// Fixed internal settings
src = hlc3

FAST_LEN   = 8
MID_LEN    = 21
SLOW_LEN   = 55
SMOOTH_LEN = 6
SIGNAL_LEN = 13
NORM_LEN   = 144
ATR_LEN    = 14

TREND_LEN        = 200
TREND_SMOOTH_LEN = 21

ADX_LEN    = 14
ADX_SMOOTH = 14
EFF_LEN    = 34

BAND_LEN     = 89
INNER_MULT   = 1.15
OUTER_MULT   = 1.90
EXTREME_MULT = 2.60

MIN_ADX        = 16.0
MIN_EFFICIENCY = 0.16

REGIME_FLOOR = 0.35

REGIME_ON   = 0.62
REGIME_OFF  = 0.38
REGIME_EDGE = 0.10

COMPRESSION_POWER  = 2.05
VELOCITY_POWER     = 2.45
ACCELERATION_POWER = 3.40

RELOAD_ZONE = 42.0

FLOW_REVERSAL_ZONE = 70.0
FLOW_EXTREME_ZONE  = 85.0

// Utility functions
f_safeDiv(float num, float den, float fallback) =>
    den != 0.0 and not na(den) and not na(num) ? num / den : fallback

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_sign(float x) =>
    x > 0.0 ? 1.0 : x < 0.0 ? -1.0 : 0.0

f_gate(bool condition, float weight) =>
    condition ? weight : 0.0

f_zscore(float x, int len) =>
    mean = ta.sma(x, len)
    dev = ta.stdev(x, len)
    f_safeDiv(x - mean, dev, 0.0)

f_tanh(float x) =>
    xClamped = f_clamp(x, -10.0, 10.0)
    e2x = math.exp(2.0 * xClamped)
    (e2x - 1.0) / (e2x + 1.0)

f_compress(float x) =>
    100.0 * f_tanh(x / COMPRESSION_POWER)

f_efficiency(float x, int len) =>
    direction = math.abs(x - x[len])
    noise = ta.sma(math.abs(ta.change(x)), len) * len
    f_safeDiv(direction, noise, 0.0)

f_bandClamp(float x) =>
    f_clamp(x, -100.0, 100.0)

f_trendRaw() =>
    _atr = ta.atr(ATR_LEN)
    _emaTrend = ta.ema(close, TREND_LEN)
    _distance = f_safeDiv(close - _emaTrend, _atr, 0.0)
    _slope = f_safeDiv(_emaTrend - _emaTrend[1], _atr, 0.0)
    _distance * 0.62 + _slope * 8.0 * 0.38

// Core structure
atr = ta.atr(ATR_LEN)
atrBase = ta.ema(atr, NORM_LEN)
atrRatio = f_safeDiv(atr, atrBase, 1.0)

emaFast = ta.ema(src, FAST_LEN)
emaMid = ta.ema(src, MID_LEN)
emaSlow = ta.ema(src, SLOW_LEN)
emaTrend = ta.ema(close, TREND_LEN)

bullStack = emaFast > emaMid and emaMid > emaSlow
bearStack = emaFast < emaMid and emaMid < emaSlow

aboveTrend = close > emaTrend
belowTrend = close < emaTrend

bullStructure = bullStack and aboveTrend
bearStructure = bearStack and belowTrend

structurePressure = bullStructure ? 1.0 : bearStructure ? -1.0 : 0.0

// Local trend pressure
trendRaw = f_trendRaw()
trendPressure = ta.ema(trendRaw, TREND_SMOOTH_LEN)
trendSign = f_sign(trendPressure)

trendStrengthScore = f_clamp(math.abs(trendPressure) / 1.20, 0.0, 1.0)

// Adaptive anti-chop quality
[plusDI, minusDI, adx] = ta.dmi(ADX_LEN, ADX_SMOOTH)

adxScore = f_clamp(f_safeDiv(adx - MIN_ADX, 42.0 - MIN_ADX, 0.0), 0.0, 1.0)

efficiency = f_efficiency(src, EFF_LEN)
efficiencyScore = f_clamp(f_safeDiv(efficiency - MIN_EFFICIENCY, 0.70 - MIN_EFFICIENCY, 0.0), 0.0, 1.0)

volatilityScore = f_clamp(f_safeDiv(atrRatio - 0.78, 1.45 - 0.78, 0.0), 0.0, 1.0)

hasVolume = not na(volume) and volume > 0.0
volumeZRaw = f_zscore(volume * 1.0, NORM_LEN)
volumeZ = hasVolume ? volumeZRaw : 0.0
volumeScore = hasVolume ? f_clamp(f_safeDiv(volumeZ + 0.35, 2.75, 0.0), 0.0, 1.0) : 1.0

qualityRaw = adxScore * 0.34 + efficiencyScore * 0.31 + volatilityScore * 0.22 + volumeScore * 0.13

quality = f_clamp(qualityRaw, 0.0, 1.0)

chopLoad = (1.0 - adxScore) * 0.34 + (1.0 - efficiencyScore) * 0.36 + (1.0 - volatilityScore) * 0.20 + (1.0 - volumeScore) * 0.10

adaptiveQualityMin = f_clamp(0.38 + chopLoad * 0.14 - trendStrengthScore * 0.07, 0.32, 0.55)

qualityOK = quality >= adaptiveQualityMin

qualityMultiplier = REGIME_FLOOR + (1.0 - REGIME_FLOOR) * quality

// Momentum engine
fastImpulse = f_safeDiv(emaFast - emaMid, atr, 0.0)
slowImpulse = f_safeDiv(emaMid - emaSlow, atr, 0.0)
rangeImpulse = f_safeDiv(close - emaMid, atr, 0.0)
priceImpulse = f_zscore(ta.roc(src, FAST_LEN), NORM_LEN)

momentumBase = fastImpulse + slowImpulse
momentumSign = f_sign(momentumBase)

volatilityImpulse = (atrRatio - 1.0) * momentumSign
volumeImpulse = hasVolume ? f_clamp(volumeZ / 2.50, -1.0, 1.0) * momentumSign : 0.0

alignmentGate = trendSign == 0.0 or momentumSign == 0.0 ? 0.70 : trendSign == momentumSign ? 1.00 : 0.48

engineRaw = fastImpulse * 0.25 + slowImpulse * 0.21 + priceImpulse * 0.15 + rangeImpulse * 0.11 + trendPressure * 0.15 + structurePressure * 0.07 + volatilityImpulse * 0.04 + volumeImpulse * 0.02

engine = engineRaw * alignmentGate * qualityMultiplier

mainRaw = ta.ema(engine, SMOOTH_LEN)
osc = f_compress(mainRaw)

// Internal signal engine
signalBase = ta.ema(osc, SIGNAL_LEN)

velocity = ta.ema(ta.change(osc), 5)
acceleration = ta.ema(ta.change(velocity), 5)

signalRaw = signalBase + velocity * VELOCITY_POWER + acceleration * ACCELERATION_POWER

signal = f_clamp(ta.ema(signalRaw, 3), -100.0, 100.0)

// Internal momentum pressure engine
histOscDelta = osc - signalBase
histEnginePressure = f_compress(engine * 0.90)

trendBias = trendSign == 0.0 ? 0.0 : trendSign == momentumSign ? trendStrengthScore : -trendStrengthScore * 0.65

histRaw = histOscDelta * 0.48 + velocity * 4.60 + acceleration * 7.00 + histEnginePressure * 0.20 + trendBias * 8.00

histClamped = f_clamp(histRaw, -100.0, 100.0)

histEma2 = ta.ema(histClamped, 2)
histEma3 = ta.ema(histClamped, 3)
histEma5 = ta.ema(histClamped, 5)

histSmooth = quality > 0.70 ? histEma2 : quality > 0.48 ? histEma3 : histEma5

hist = histSmooth * (0.55 + quality * 0.45)

histSlope = hist - nz(hist[1], hist)
histRising = histSlope > 0.0
histFalling = histSlope < 0.0

histStrongBull = hist > 8.0 and histRising
histStrongBear = hist < -8.0 and histFalling

bullMomentumOK = histStrongBull or hist > 0.0 and histSlope >= 0.0 or hist > -8.0 and histSlope > 0.0 and velocity > 0.0

bearMomentumOK = histStrongBear or hist < 0.0 and histSlope <= 0.0 or hist < 8.0 and histSlope < 0.0 and velocity < 0.0

// Adaptive bands used internally by expansion and exhaustion states
basis = ta.ema(osc, BAND_LEN)

stdevDev = nz(ta.stdev(osc, BAND_LEN), 0.0)
madDev = nz(ta.ema(math.abs(osc - basis), BAND_LEN), 0.0) * 1.2533
bandDev = math.max(stdevDev * 0.60 + madDev * 0.40, 1.0)

upperInner = f_bandClamp(basis + bandDev * INNER_MULT)
lowerInner = f_bandClamp(basis - bandDev * INNER_MULT)
upperOuter = f_bandClamp(basis + bandDev * OUTER_MULT)
lowerOuter = f_bandClamp(basis - bandDev * OUTER_MULT)
upperExtreme = f_bandClamp(basis + bandDev * EXTREME_MULT)
lowerExtreme = f_bandClamp(basis - bandDev * EXTREME_MULT)

// Regime scoring
bullRegimeScore = quality * 0.26 + f_gate(bullStructure, 0.24) + f_gate(trendPressure > 0.0, 0.22) + f_gate(momentumBase > 0.0, 0.15) + f_gate(osc > 0.0, 0.13)

bearRegimeScore = quality * 0.26 + f_gate(bearStructure, 0.24) + f_gate(trendPressure < 0.0, 0.22) + f_gate(momentumBase < 0.0, 0.15) + f_gate(osc < 0.0, 0.13)

bullRegimeCandidate = qualityOK and bullRegimeScore >= REGIME_ON and bullRegimeScore > bearRegimeScore + REGIME_EDGE

bearRegimeCandidate = qualityOK and bearRegimeScore >= REGIME_ON and bearRegimeScore > bullRegimeScore + REGIME_EDGE

bullInvalid = close < emaSlow or trendPressure < -0.18 or bearStack

bearInvalid = close > emaSlow or trendPressure > 0.18 or bullStack

var int regimeState = 0

if bullRegimeCandidate
    regimeState := 1
else if bearRegimeCandidate
    regimeState := -1
else
    if regimeState == 1 and (bullInvalid or bullRegimeScore < REGIME_OFF)
        regimeState := 0
    if regimeState == -1 and (bearInvalid or bearRegimeScore < REGIME_OFF)
        regimeState := 0

bullRegime = regimeState == 1
bearRegime = regimeState == -1
neutralRegime = regimeState == 0

// Continuation states
bullContinuation = bullRegime and qualityOK and osc > 0.0 and osc > signalBase and signal > -10.0 and bullMomentumOK

bearContinuation = bearRegime and qualityOK and osc < 0.0 and osc < signalBase and signal < 10.0 and bearMomentumOK

bullExpansion = bullContinuation and osc > upperInner and velocity > 0.0 and histStrongBull

bearExpansion = bearContinuation and osc < lowerInner and velocity < 0.0 and histStrongBear

bullReload = bullRegime and qualityOK and osc > -RELOAD_ZONE and osc < signalBase and hist > -35.0 and histRising and velocity > velocity[1]

bearReload = bearRegime and qualityOK and osc < RELOAD_ZONE and osc > signalBase and hist < 35.0 and histFalling and velocity < velocity[1]

bullSwingHighExhaustion = bullRegime and (osc > 45.0 and velocity < 0.0 and histFalling or osc > upperOuter and velocity < velocity[1] and histSlope < 0.0)

bearSwingLowExhaustion = bearRegime and (osc < -45.0 and velocity > 0.0 and histRising or osc < lowerOuter and velocity > velocity[1] and histSlope > 0.0)

neutralTop = neutralRegime and osc > 55.0 and velocity < 0.0 and histFalling

neutralBottom = neutralRegime and osc < -55.0 and velocity > 0.0 and histRising

exhaustion = bullSwingHighExhaustion or bearSwingLowExhaustion or neutralTop or neutralBottom

noTrade = not qualityOK

// Reload line
reloadStrength = bullReload ? f_clamp((RELOAD_ZONE - math.abs(osc)) / RELOAD_ZONE, 0.0, 1.0) * quality : bearReload ? -f_clamp((RELOAD_ZONE - math.abs(osc)) / RELOAD_ZONE, 0.0, 1.0) * quality : 0.0

reloadLine = ta.ema(reloadStrength * 70.0, 4)

// Regime dots
regimeDot = bullRegime ? 92.0 : bearRegime ? -92.0 : 0.0

// Flow trail
flowRaw = osc * 0.52 + hist * 0.24 + velocity * 5.50 + acceleration * 7.50 + trendPressure * 6.00

flowCompressed = f_clamp(flowRaw, -100.0, 100.0)

flowEma2 = ta.ema(flowCompressed, 2)
flowEma3 = ta.ema(flowCompressed, 3)
flowEma5 = ta.ema(flowCompressed, 5)

flowLine = quality > 0.70 ? flowEma2 : quality > 0.48 ? flowEma3 : flowEma5

flowSlope = flowLine - nz(flowLine[1], flowLine)
flowRising = flowSlope > 0.0
flowFalling = flowSlope < 0.0

flowHotBull = flowLine > RELOAD_ZONE and flowRising and bullRegime
flowHotBear = flowLine < -RELOAD_ZONE and flowFalling and bearRegime

flowReloadBull = bullReload and flowLine > -70.0
flowReloadBear = bearReload and flowLine < 70.0

// Extreme pressure states
flowTopZone = flowLine >= FLOW_REVERSAL_ZONE
flowBottomZone = flowLine <= -FLOW_REVERSAL_ZONE

flowTopExtreme = flowLine >= FLOW_EXTREME_ZONE
flowBottomExtreme = flowLine <= -FLOW_EXTREME_ZONE

topReversalPressure = flowTopZone and (flowFalling or velocity < 0.0 or histFalling or acceleration < 0.0 or exhaustion)

bottomReversalPressure = flowBottomZone and (flowRising or velocity > 0.0 or histRising or acceleration > 0.0 or exhaustion)

hugeTopReversalPotential = flowTopExtreme and (flowFalling or velocity < 0.0 or histFalling or acceleration < 0.0 or exhaustion)

hugeBottomReversalPotential = flowBottomExtreme and (flowRising or velocity > 0.0 or histRising or acceleration > 0.0 or exhaustion)

hugeReversalPotential = hugeTopReversalPotential or hugeBottomReversalPotential
extremePressure = hugeReversalPotential or topReversalPressure or bottomReversalPressure or exhaustion or bullExpansion or bearExpansion

// Visual colors
flowColor = noTrade ? color.new(neutralColor, 10) : extremePressure ? color.new(extremeColor, 0) : flowLine > 0.0 ? color.new(bullishColor, flowRising ? 0 : 32) : flowLine < 0.0 ? color.new(bearishColor, flowFalling ? 0 : 32) : color.new(neutralColor, 10)

reloadColor = reloadLine > 0.0 ? color.new(bullishColor, 15) : reloadLine < 0.0 ? color.new(bearishColor, 15) : color.new(neutralColor, 30)

regimeColor = bullRegime ? color.new(bullishColor, 10) : bearRegime ? color.new(bearishColor, 10) : color.new(neutralColor, 35)

flowFillColor = noTrade ? color.new(neutralColor, 94) : extremePressure ? color.new(extremeColor, 86) : flowLine > 0.0 ? color.new(bullishColor, 90) : flowLine < 0.0 ? color.new(bearishColor, 90) : color.new(neutralColor, 94)

// Zero line
plot(showZeroLine ? 0.0 : na, "Zero Line", color=color.new(neutralColor, 55), linewidth=1)

// Background layers
plot(showReloadLine ? reloadLine : na, "Pullback Reload Line", color=reloadColor, linewidth=2)

plot(showRegimeDots ? regimeDot : na, "Regime Dots", style=plot.style_circles, color=regimeColor, linewidth=2)

// Flow trail design
pFlowGlowOuter = plot(showFlowTrail ? flowLine : na, "Flow Trail Outer Glow", color=color.new(flowColor, hugeReversalPotential ? 62 : 82), linewidth=5)

pFlowGlowInner = plot(showFlowTrail ? flowLine : na, "Flow Trail Inner Glow", color=color.new(flowColor, hugeReversalPotential ? 38 : 58), linewidth=3)

pFlowCore = plot(showFlowTrail ? flowLine : na, "Flow Trail", color=flowColor, linewidth=3)

pHiddenZero = plot(0.0, "Hidden Flow Center", color=color.new(neutralColor, 100), display=display.none)

fill(pFlowCore, pHiddenZero, color=showPressureFill and showFlowTrail ? flowFillColor : na, title="Flow Pressure Fill")

// Alerts
alertcondition(bullContinuation and not bullContinuation[1], "Flow Pressure Bull Continuation", "Flow Pressure Oscillator: bullish continuation pressure detected.")
alertcondition(bearContinuation and not bearContinuation[1], "Flow Pressure Bear Continuation", "Flow Pressure Oscillator: bearish continuation pressure detected.")

alertcondition(bullReload and not bullReload[1], "Flow Pressure Bull Reload", "Flow Pressure Oscillator: bullish reload pressure detected.")
alertcondition(bearReload and not bearReload[1], "Flow Pressure Bear Reload", "Flow Pressure Oscillator: bearish reload pressure detected.")

alertcondition(bullExpansion and not bullExpansion[1], "Flow Pressure Bull Expansion", "Flow Pressure Oscillator: bullish expansion pressure detected.")
alertcondition(bearExpansion and not bearExpansion[1], "Flow Pressure Bear Expansion", "Flow Pressure Oscillator: bearish expansion pressure detected.")

alertcondition(exhaustion and not exhaustion[1], "Flow Pressure Exhaustion", "Flow Pressure Oscillator: exhaustion pressure detected.")
alertcondition(hugeTopReversalPotential and not hugeTopReversalPotential[1], "Flow Pressure Upper Extreme", "Flow Pressure Oscillator: upper extreme pressure detected.")
alertcondition(hugeBottomReversalPotential and not hugeBottomReversalPotential[1], "Flow Pressure Lower Extreme", "Flow Pressure Oscillator: lower extreme pressure detected.")
alertcondition(noTrade and not noTrade[1], "Flow Pressure Low Quality", "Flow Pressure Oscillator: market quality filter is weak.")
````
